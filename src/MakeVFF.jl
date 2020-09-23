# we are making a Julia model if this gets called, so lets load the Julia strategy -
include("./strategy/VFFStrategy.jl")

function extract_model_name(tree_root::XMLElement)::String

    # get model, and extract name attribute -
    model_tag = get_elements_by_tagname(tree_root,"model")[1] # only one model tag -
    return attribute(model_tag,"id")
end

function make_vff_model(path_to_sbml_file::String, path_to_output_dir::String)

    # TODO: checks - are paths legit?

    # start -
    time_start = time();

    # initialize -
    vff_component_set = Array{VLProgramComponent,1}()

    @info "Parsing $(path_to_sbml_file) ... "

    # load up ETree -
    sbml_tree = parse_file(path_to_sbml_file)
    sbml_tree_root = root(sbml_tree)

    # build the filename = 
    model_name = extract_model_name(sbml_tree_root) # bad code - we need to check for this method not returning what we want
    filename = "$(model_name).vff"

    @info "Starting generation of $(filename) ... "

    # build the global header -
    global_header_program_component = build_global_header_program_component(sbml_tree_root, filename)
    push!(vff_component_set, global_header_program_component)

    # build txtl section -
    txtl_program_component = build_txtl_program_component(sbml_tree_root, filename)
    push!(vff_component_set, txtl_program_component)

    # build metabolism section -
    metabolism_program_component = build_metabolism_program_component(sbml_tree_root, filename)
    push!(vff_component_set, metabolism_program_component)

    # build global header section -
    grn_program_component = build_grn_program_component(sbml_tree_root, filename)
    push!(vff_component_set, grn_program_component)

    # Dump the vff_component_set to disk -
    write_combined_program_components_to_disk("$(path_to_output_dir)", vff_component_set)

    # stop timer -
    elapsed_time = (time() - time_start)    # in ns
    @info "Done! elapsed_time: $(time() - time_start)s"

    # free the document memory -
    free(sbml_tree)
end