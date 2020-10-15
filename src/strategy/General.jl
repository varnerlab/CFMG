function iterate_parameters_grn_control_control_connection(gene_object::VLSpeciesSymbol, list_of_connections::Array{VLGRNConnectionObject}, 
    default_parameter_dictionary::Dict{String,Any})

    # get default values -
    default_tx_weight = default_parameter_dictionary["default_tx_weight"]

    # What is my gene_symbol -
    gene_symbol = gene_object.species_symbol
    parameter_name_array = Array{String,1}()
  
    tmp_buffer = ""
    for connection_object in list_of_connections
  
      # actor -
      connection_symbol = connection_object.connection_symbol
      pname = "W_$(gene_symbol)_$(connection_symbol)"
      tmp_buffer *= "$(pname) = $(default_tx_weight)\n"

      # capture -
      push!(parameter_name_array, pname)
    end

  
    return (tmp_buffer, parameter_name_array)
end
  
function iterate_parameters_grn_binding_control_connection(gene_object::VLSpeciesSymbol,list_of_connections::Array{VLGRNConnectionObject}, 
    default_parameter_dictionary::Dict{String,Any})
  
    # get default values -
    default_tx_control_binding_order = default_parameter_dictionary["default_tx_control_binding_order"]
    default_tx_control_binding_saturation_constant = default_parameter_dictionary["default_tx_control_binding_saturation_constant"]

    # What is my gene_symbol -
    gene_symbol = gene_object.species_symbol
    parameter_name_array = Array{String,1}()

    tmp_buffer = ""
    for connection_object in list_of_connections
  
        # actor -
        connection_symbol = connection_object.connection_symbol

        # name 1,2 -
        pname_1 = "n_$(gene_symbol)_$(connection_symbol)"
        pname_2 = "K_$(gene_symbol)_$(connection_symbol)"
  
        # write records -
        tmp_buffer *= "$(pname_1) = $(default_tx_control_binding_order)\n"
        tmp_buffer *= "$(pname_2) = $(default_tx_control_binding_saturation_constant)\n"
  
        # capture -
        push!(parameter_name_array, pname_1)
        push!(parameter_name_array, pname_2)
    end
  
    return (tmp_buffer, parameter_name_array)
end

function get_enzyme_symbol(model_species_name::String,list_of_seq_objects::Array{VLSequenceRecord})::String

    # TODO: we should check for empty index arrays, and throw an error
    # ...

    # lets get the :X sequences -
    idx_gene_list = findall(x->x.operationType ==:X,list_of_seq_objects)
    gene_list = list_of_seq_objects[idx_gene_list]

    # grab the names -
    tmp = [model.modelSpecies for model in gene_list]

    # find index of the record -
    idx_record = findfirst(x->(occursin(x,model_species_name) == true),tmp)

    # grab the record,m and return the enzymeSymbol -
    return gene_list[idx_record].enzymeSymbol
end

# function to build the Parameters.toml file -
function generate_control_parameters_dictionary_component(problem_dictionary::Dict{String,Any})::Tuple{VLProgramComponent,Array{String,1}}

    # this file holds control parameters for the model -
    # initialize -
    filename = "Control.toml"
    program_component = VLProgramComponent()
    buffer = Array{String,1}()
    parameter_name_buffer = Array{String,1}()

    # build the header -
    header_buffer = build_copyright_header_buffer(problem_dictionary)
    +(buffer, header_buffer)

    # TODO: put comment header here?

    # get list of connections and species -
    list_of_grn_connections::Array{VLGRNConnectionObject} = problem_dictionary["list_of_grn_connections"]
    list_of_grn_species::Array{VLSpeciesSymbol} = problem_dictionary["list_of_species"]
    list_of_seq_objects::Array{VLSequenceRecord} = problem_dictionary["sequence_object_array"]

    # get default values -
    default_parameter_dictionary = problem_dictionary["default_parameter_dictionary"]
    default_tx_background_weight = default_parameter_dictionary["default_tx_background_weight"]

    # get the list of genes -
    idx_genes = findall(x->(x.species_type == :GENE), list_of_grn_species)
    list_of_genes = list_of_grn_species[idx_genes]

    # binding parameters -
    +(buffer, "\n")
    +(buffer,"[parameter_value_dictionary]\n")
    for (index,gene_object) in enumerate(list_of_genes)

        # get gene symbol -
        gene_symbol = gene_object.species_symbol
    
        # connections -
        activating_connections = is_species_a_target_in_connection_list(list_of_grn_connections,gene_object,:activate)
        inhibiting_connections = is_species_a_target_in_connection_list(list_of_grn_connections,gene_object,:inhibit)
    
        # activating connections -
        (tmp, pname_array_1) = iterate_parameters_grn_binding_control_connection(gene_object, activating_connections, default_parameter_dictionary)
        +(buffer, tmp)
    
        # inhibiting_connections -
        (tmp, pname_array_2) = iterate_parameters_grn_binding_control_connection(gene_object, inhibiting_connections, default_parameter_dictionary)
        +(buffer, tmp)

        # capture -
        total_pname_array = [pname_array_1 ; pname_array_2]
        for pname in total_pname_array
            push!(parameter_name_buffer, pname)
        end
    end

    # weights -
    for (index,gene_object) in enumerate(list_of_genes)

        # get gene symbol -
        gene_symbol = gene_object.species_symbol
    
        # connections -
        activating_connections = is_species_a_target_in_connection_list(list_of_grn_connections, gene_object, :activate)
        inhibiting_connections = is_species_a_target_in_connection_list(list_of_grn_connections, gene_object, :inhibit)
    
        # for this gene, what is my enzyme symbol?
        enzyme_symbol = get_enzyme_symbol(gene_symbol, list_of_seq_objects)

        # get the RNAp binding symbol out -
        background_pname = "W_$(gene_symbol)_$(enzyme_symbol)"
        +(buffer, "$(background_pname)=$(default_tx_background_weight)\n")

        # grab the background parameter -
        push!(parameter_name_buffer,background_pname)
    
        # activating -
        (tmp, pname_array_1) = iterate_parameters_grn_control_control_connection(gene_object, activating_connections, default_parameter_dictionary)
        +(buffer, tmp)
    
        # inhibiting -
        (tmp, pname_array_2) = iterate_parameters_grn_control_control_connection(gene_object, inhibiting_connections, default_parameter_dictionary)
        +(buffer, tmp)

        # capture -
        total_pname_array = [pname_array_1 ; pname_array_2]
        for pname in total_pname_array
            push!(parameter_name_buffer, pname)
        end
    end

    +(buffer,"\n")
    +(buffer,"# These species were discovered in the GRN section, but did not have a corresponding sequence.\n")
    +(buffer,"# In these cases, we treat these species as parameters in the simulation \n")

    # ok, so sometimes we have species that are mentioned in the control section of the model that are not encoded for by a sequence -
    # These species will be treated as parameters -
    list_of_grn_species = problem_dictionary["list_of_grn_species"]
    list_of_seq_objects = problem_dictionary["sequence_object_array"]
    
    # create a set of species that we have sequences for -
    seq_symbol_set = Set{String}()
    for seq_object in list_of_seq_objects
        
        # get the name of the seq item -
        model_species = seq_object.modelSpecies
        push!(seq_symbol_set,model_species)
    end

    # for now, just print these out so I can see what is going on -
    for grn_species_object in list_of_grn_species
    
        # ok, lets check - do my seq_symbol_set have a particular species -
        species_symbol = grn_species_object.species_symbol
        if (in(species_symbol,seq_symbol_set) == false)
            
            # ok, so we have species in my grn logic that we don't have a species sequence for.
            # In this case, we assume this species is a parameter

            # get type -
            type_arg = grn_species_object.species_type

            # build a pname -
            pname = "$(type_arg)_$(species_symbol)"
            push!(parameter_name_buffer,pname) 

            # add a record to the buffer -
            +(buffer, "$(pname)=0.0\n")
        end
    end

    +(buffer, "\n")
    +(buffer, "[parameter_order_dictionary]\n")
    for (index,pname) in enumerate(parameter_name_buffer)
        +(buffer,"$(pname)=$(index)\n")
    end


    +(buffer, "\n")
    +(buffer, "[order_parameter_dictionary]\n")
    for (index,pname) in enumerate(parameter_name_buffer)
        +(buffer,"$(index)=\"$(pname)\"\n")
    end

    # collapse -
    flat_buffer = ""
    [flat_buffer *= line for line in buffer]

    # add data to program_component -
    program_component.filename = filename;
    program_component.buffer = flat_buffer
    program_component.type = :buffer

    # return -
    return (program_component, parameter_name_buffer)
end