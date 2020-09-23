function extract_node_list!(node::XMLElement, nodeArray::Array{XMLElement,1}, label::String)

    # get kids of node -
    list_of_children = collect(child_elements(node))
    for child_node in list_of_children
        
        if (name(child_node) == label)
            push!(nodeArray, child_node)
        else
            extract_node_list!(child_node, nodeArray, label)
        end
    end
end

function extract_reactant_list(node::XMLElement)

    species_array = Array{XMLElement,1}()
    list_of_reactants_node = Array{XMLElement,1}()

    # get list of reactants -
    extract_node_list!(node,list_of_reactants_node,"listOfReactants")
    
    # get the species ref kids -
    list_of_children = collect(child_elements(list_of_reactants_node[1])) # we *should* have only one of these -
    for child_node in list_of_children
        push!(species_array,child_node)
    end

    return species_array
end

function extract_product_list(node::XMLElement)

    species_array = Array{XMLElement,1}()
    list_of_products_node = Array{XMLElement,1}()

    # get list of reactants -
    extract_node_list!(node,list_of_products_node,"listOfProducts")
    
    # get the species ref kids -
    list_of_children = collect(child_elements(list_of_products_node[1])) # we *should* have only one of these -
    for child_node in list_of_children
        push!(species_array,child_node)
    end

    return species_array
end

function build_metabolic_reaction_object_array(tree_root::XMLElement)::Array{VLMetabolicReaction,1}

    # initialize -
    reaction_object_array = Array{VLMetabolicReaction,1}()
    tmp_reaction_array = Array{XMLElement,1}()

    # extract the list of reaction objects -
    extract_node_list!(tree_root, tmp_reaction_array, "reaction")
    for xml_reaction_object in tmp_reaction_array
        
        # build new reaction object -
        robject = VLMetabolicReaction()

        # get data -
        rname = attribute(xml_reaction_object,"id")
        rev_flag = attribute(xml_reaction_object,"reversible")

        # build reactions phrases -
        list_of_reactants = extract_reactant_list(xml_reaction_object)
        list_of_products = extract_product_list(xml_reaction_object)

        # left phase -
        left_phrase = ""
        for species_ref_tag in list_of_reactants
            
            # species id and stoichiometry -
            species = attribute(species_ref_tag,"species")
            stcoeff = attribute(species_ref_tag, "stoichiometry")

            left_phrase *= "$(stcoeff)*$(species)+"
        end
        left_phrase = left_phrase[1:end-1]  # cutoff the trailing + 

        # right phrase -
        right_phrase = ""
        for species_ref_tag in list_of_products
            
            # species id and stoichiometry -
            species = attribute(species_ref_tag,"species")
            stcoeff = attribute(species_ref_tag, "stoichiometry")

            right_phrase *= "$(stcoeff)*$(species)+"
        end
        right_phrase = right_phrase[1:end-1]    # cuttoff the trailing + 


        # populate the reaction object -
        robject.reaction_name = rname
        robject.ec_number = "[]"
        robject.reversible = rev_flag
        robject.left_phrase = left_phrase
        robject.right_phrase = right_phrase

        # cache -
        push!(reaction_object_array, robject)
    end

    # return -
    return reaction_object_array
end

function build_txtl_program_component(tree_root::XMLElement, filename::String)::VLProgramComponent

    # initialize -
    program_component = VLProgramComponent()
    
    # load the header text for TXTL -
    path_to_impl = "$(path_to_package)/distribution/julia/include/TXTL-Header-Section.txt"
    buffer = include_function(path_to_impl)
    
    # collapse -
    flat_buffer = ""
    [flat_buffer *= line for line in buffer]

    # add data to program_component -
    program_component.filename = filename;
    program_component.buffer = flat_buffer
    program_component.type = :buffer

    # return -
    return program_component
end

function build_grn_program_component(tree_root::XMLElement, filename::String)::VLProgramComponent

    # initialize -
    program_component = VLProgramComponent()
    
    # load the header text for TXTL -
    path_to_impl = "$(path_to_package)/distribution/julia/include/GRN-Header-Section.txt"
    buffer = include_function(path_to_impl)
    
    # collapse -
    flat_buffer = ""
    [flat_buffer *= line for line in buffer]

    # add data to program_component -
    program_component.filename = filename;
    program_component.buffer = flat_buffer
    program_component.type = :buffer

    # return -
    return program_component
end

function build_global_header_program_component(tree_root::XMLElement, filename::String)::VLProgramComponent

    # initialize -
    program_component = VLProgramComponent()
    
    # load the header text for TXTL -
    path_to_impl = "$(path_to_package)/distribution/julia/include/Global-Header-Section.txt"
    buffer = include_function(path_to_impl)
    
    # collapse -
    flat_buffer = ""
    [flat_buffer *= line for line in buffer]

    # add data to program_component -
    program_component.filename = filename;
    program_component.buffer = flat_buffer
    program_component.type = :buffer

    # return -
    return program_component
end

function build_metabolism_program_component(tree_root::XMLElement, filename::String)::VLProgramComponent

    # initialize -
    buffer = Array{String,1}()
    program_component = VLProgramComponent()
    
    # header information -
    +(buffer, "// ***************************************************************************** //\n")
    +(buffer, "#METABOLISM::START\n")
    +(buffer, "// Metabolism record format:\n")
    +(buffer, "// reaction_name (unique), [{; delimited set of ec numbers | []}],reactant_string,product_string,reversible\n")
    +(buffer,"//\n")
    +(buffer, "// Rules:\n");
    +(buffer, "// The reaction_name field is unique, and metabolite symbols can not have special chars or spaces\n")
    +(buffer, "//\n")
    +(buffer, "// Example:\n")
    +(buffer, "// R_A_syn_2,[6.3.4.13],M_atp_c+M_5pbdra+M_gly_L_c,M_adp_c+M_pi_c+M_gar_c,false\n")
    +(buffer, "//\n")
    +(buffer, "// Stochiometric coefficients are pre-pended to metabolite symbol, for example:\n")
    +(buffer, "// R_adhE,[1.2.1.10; 1.1.1.1],M_accoa_c+2*M_h_c+2*M_nadh_c,M_coa_c+M_etoh_c+2*M_nad_c,true\n")
    +(buffer, "\n")
    
    # build the reaction array of objects -
    reaction_object_array = build_metabolic_reaction_object_array(tree_root)
    tmp_string = ""
    for reaction_object::VLMetabolicReaction in reaction_object_array

        # get data -
        reaction_name = reaction_object.reaction_name
        ec_number = reaction_object.ec_number
        left_phrase = reaction_object.left_phrase
        right_phrase = reaction_object.right_phrase
        reversible_flag = reaction_object.reversible

        # build a reaction string -
        tmp_string = "$(reaction_name),$(ec_number),$(left_phrase),$(right_phrase),$(reversible_flag)\n"

        # push onto the buffer -
        +(buffer, tmp_string)

        # clear -
        tmp_string = []
    end

    # close the section -
    +(buffer, "\n")
    +(buffer, "#METABOLISM::STOP\n")
    +(buffer, "// ***************************************************************************** //\n")

    # collapse -
    flat_buffer = ""
    [flat_buffer *= line for line in buffer]

    # add data to program_component -
    program_component.filename = filename;
    program_component.buffer = flat_buffer
    program_component.type = :buffer

    # return -
    return program_component
end