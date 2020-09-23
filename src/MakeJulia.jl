# we are making a Julia model if this gets called, so lets load the Julia strategy -
include("./strategy/General.jl")
include("./strategy/JuliaStrategy.jl")

function make_julia_model(path_to_model_file::String, path_to_output_dir::String; 
    defaults_file_name::String="Defaults.toml", model_type::Symbol=:static)

    # start -
    time_start = time();

    # Fix: Need to generate a Default.toml project first #2
    # check, do we have the Defaults file? 
    path_to_defaults_file = "$(dirname(path_to_model_file))/$(defaults_file_name)"
    if (isfile(path_to_defaults_file) == false)
        throw(ArgumentError("Ooops! We are missing the Defaults.toml file. Please generate a default project using the generate_default_project function. For details see the generate_default_project help in the REPL"))
    end

    @info "Loading the $(defaults_file_name)"
    
    # Load the defaults file -
    tmp_dict =  TOML.parsefile(path_to_defaults_file)
    default_parameter_dictionary = tmp_dict["default_parameter_values"]
    author_metadata_dictionary = tmp_dict["author_metadata"]

    # legit path to model file?
    is_file_path_ok(path_to_model_file)
    
    # before we get too far along, we need to check if the user already has code in the location that we want to generate at -
    # if they do, then move it -    
    if (isdir(path_to_output_dir) == true)

        @info "Ooops! We found some code where you wanted to generate your model. Moving ..."
        
        # ok, looks like we may have a conflict - mv the offending code
        if (move_existing_project_at_path(path_to_output_dir) == false)
            
            # Something happend ... the world is ending ...
            throw(ArgumentError("automatic directory conflict resolution failed. Unable to move existing directory $(path_to_output_dir)"))
        end
    end

    # let the uset know what is going on -
    @info "Starting a new code genration job: reading model file at $(path_to_model_file)"

    # initialize -
    src_component_set = Set{VLProgramComponent}()
    config_component_set = Set{VLProgramComponent}()
    root_component_set = Set{VLProgramComponent}()

    # Load the JSON configuration file -
    path_to_configuration_file = "$(path_to_package)/configuration/Configuration.json"
    config_dict = JSON.parsefile(path_to_configuration_file)

    # let the uset know what is going on -
    @info "Loaded the configuration file $(path_to_configuration_file)"
    
    # parse the model file -
    problem_dictionary = parse_vff_model_file(path_to_model_file, config_dict, default_parameter_dictionary)
    problem_dictionary["configuration_dictionary"] = config_dict
    problem_dictionary["default_parameter_dictionary"] = default_parameter_dictionary
    problem_dictionary["author_metadata_dictionary"] = author_metadata_dictionary

    # let the uset know what is going on -
    @info "Model file parsing complete"

    # generate a parameters toml file -
    (program_component_parameter_dictionary, runtime_model_parameter_name_array) = generate_control_parameters_dictionary_component(problem_dictionary)
    push!(config_component_set, program_component_parameter_dictionary)
    problem_dictionary["runtime_model_parameter_name_array"] = runtime_model_parameter_name_array

    @info "Control function generation complete"

    # generate the data dictionary component -
    program_component_data_dictionary = build_data_dictionary_program_component(problem_dictionary)
    push!(src_component_set, program_component_data_dictionary)

    @info "Data dictionary generation complete"

    # generate the kinetics component -
    program_component_kinetics = build_kinetics_program_component(problem_dictionary)
    push!(src_component_set, program_component_kinetics)

    @info "Kinetics function generation complete"

    # Write the Control functions -
    program_component_control = build_control_program_component(problem_dictionary)
    push!(src_component_set,program_component_control)
    
    @info "Control function generation complete ..."

    # Write the stoichiometric_matrix --
    program_component_stoichiometric_matrix = generate_stoichiomteric_matrix_program_component(problem_dictionary)
    push!(src_component_set,program_component_stoichiometric_matrix)

    @info "The stoichiometric matrix has been generated  ... writing model files to $(path_to_output_dir)"

    # Transfer distrubtion jl files to the output -> these files are shared between model types
    transfer_distribution_files("$(path_to_package)/distribution/julia/src", "$(path_to_output_dir)/src",".jl")

    # Transfer root jl files -> these files are moved to the root dir of the file
    transfer_distribution_files("$(path_to_package)/distribution/julia/root", "$(path_to_output_dir)",".jl")

    # Transfer dynamic or static jl files -
    if (model_type == :static)

        # Transfer root jl files -> these files are moved to the root dir of the project -
        transfer_distribution_files("$(path_to_package)/distribution/julia/root/static", "$(path_to_output_dir)",".jl")
    elseif (model_type == :dynamic)
        # Transfer root jl files -> these files are moved to the root dir of the project -
        transfer_distribution_files("$(path_to_package)/distribution/julia/root/dynamic", "$(path_to_output_dir)",".jl")
    else
        # Something happend ... the world is ending ...
        throw(ArgumentError("Oooops! Unsupported model type has been requested: $(model_type). Model type must be either static or dynamic."))
    end


    # Transfer distibution TOML files to output -
    transfer_distribution_files("$(path_to_package)/distribution","$(path_to_output_dir)/src/config",".toml")

    # transfer the README files -
    path_to_readme_file = splitdir(path_to_model_file)[1]
    transfer_distribution_files("$(path_to_package)/distribution",path_to_readme_file,".md")

    # dump src and config components to disk -
    write_program_components_to_disk("$(path_to_output_dir)/src", src_component_set)
    write_program_components_to_disk("$(path_to_output_dir)/src/config", config_component_set)

    # stop timer -
    elapsed_time = (time() - time_start)    # in ns
    problem_dictionary["elapsed_time"] = elapsed_time
    problem_dictionary["path_to_model_file"] = path_to_model_file
    problem_dictionary["path_to_output_dir"] = path_to_output_dir

    # generate model report file (useful for debugging) -
    program_component_report = build_model_generation_report(problem_dictionary)
    push!(root_component_set, program_component_report)

    # Dump the component_set to disk -
    write_program_components_to_disk("$(path_to_output_dir)", root_component_set)
    @info "Done! elapsed_time: $(time() - time_start)s"
end