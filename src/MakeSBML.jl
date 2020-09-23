# we are making a SBML model if this gets called, so lets load the SBML strategy -
include("./strategy/SBMLStrategy.jl")

function make_sbml_model(path_to_model_file::String, path_to_output_dir::String; 
    defaults_file_name::String="Defaults.toml", default_model_file_name::String="Model.sbml")

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

    # build the SMBL program component -
    sbml_file_program_component = build_sbml_model_program_component(problem_dictionary, default_model_file_name)
    push!(root_component_set, sbml_file_program_component)

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