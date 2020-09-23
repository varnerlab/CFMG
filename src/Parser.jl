# --- PRIVATE METHODS ----------------------------------------------------------- #
function parse_vff_reaction_section(reaction_section_buffer)

    # initialize -
    reaction_dictionary = Dict{String,VLMetabolicReaction}()
    reaction_order_array = Array{String,1}()

  
    # process each line -
    for reaction_line in reaction_section_buffer

        # skip comments and empty lines -
        if (occursin("//", reaction_line) == false && isempty(reaction_line) == false)

            # ok, record: name,{ec},LHS,RHS,R,F

            # initialize -
            reaction_wrapper = VLMetabolicReaction()

            # split around ,
            reaction_record_components_array = split(reaction_line,",")

            # get the name/key -
            reaction_key = reaction_record_components_array[1]

            # cache this (we need to keep the order that appears in the VFF) -
            push!(reaction_order_array, reaction_key)

            # populate -
            reaction_wrapper.record = reaction_line
            reaction_wrapper.reaction_name = reaction_key
            reaction_wrapper.ec_number = reaction_record_components_array[2]
            reaction_wrapper.left_phrase = reaction_record_components_array[3]
            reaction_wrapper.right_phrase = reaction_record_components_array[4]
            reaction_wrapper.reversible = reaction_record_components_array[5]

            # cache -
            reaction_dictionary[reaction_key] = reaction_wrapper
        end
    end

    # return -
    return (reaction_order_array, reaction_dictionary)
end

function parse_grn_section(grn_section_buffer::Array{String,1})

    # We are going to load the sentences in the file into a vector
    # if not a valid model file, then throw an error -
    sentence_vector = VLGRNSentence[]
    tmp_array::Array{String,1} = String[]

    try

        for sentence in grn_section_buffer

            # make sentence a string -
            local_sentence = convert(String,sentence)

            if (occursin("//", local_sentence) == false && isempty(local_sentence) == false)

                # Ok, so now we have the array for sentences -
                grn_sentence = VLGRNSentence()
                grn_sentence.original_sentence = local_sentence

                # split the sentence -
                split_array = split(local_sentence," ")

                # sentence_actor_clause::String
                # sentence_action_clause::String
                # sentence_target_clause::String
                # sentence_delimiter::Char
                grn_sentence.sentence_actor_clause = split_array[1]
                grn_sentence.sentence_action_clause = split_array[2]
                grn_sentence.sentence_target_clause = split_array[3]
                grn_sentence.sentence_delimiter = ' '

                # add sentence to sentence_vector =
                push!(sentence_vector, grn_sentence)
            end
        end

  catch err
    showerror(stdout, err, backtrace());println()
  end

  # return - 
  return sentence_vector
end


function parse_vff_sequence_section(seq_section_buffer::Array{String,1}, configuration_dictionary::Dict{AbstractString,Any})
  
  # initialize -
  tmp_buffer::String = "";
  seq_record_object_array = Array{VLSequenceRecord,1}()

  # strip spaces and comments -
  for seq_line in seq_section_buffer
      
      # skip comments and empty lines -
      if (occursin("//", seq_line) == false && isempty(seq_line) == false)
          tmp_buffer *= seq_line
      end
  end
    
  # split around the ;
  seq_record_array = split(tmp_buffer,";")
  for seq_record in seq_record_array
      
      if (isempty(seq_record) == false)
          
          # initialize seq record -
          seq_object = VLSequenceRecord()
      
          # grab the orginal record -
          seq_object.record = seq_record

          # split based upon :: -
          clause_array = split(seq_record,"::")

          # grab the sequence (second index)
          local_seq = clause_array[2]
          seq_object.sequence = local_seq
          seq_object.length = compute_sequence_length(local_seq)

          # split the leader clause -
          leader_fragment_array = split(clause_array[1],",")

          seq_object.operationType = Symbol(leader_fragment_array[1])
          seq_object.modelSpecies = leader_fragment_array[2]
          seq_object.enzymeSymbol = leader_fragment_array[3]

          # cache -
          push!(seq_record_object_array, seq_object) 
      end
  end

  # ok, so we've created an array of records -
  tmp_buffer = "";
  for (index, seq_record_object) in enumerate(seq_record_object_array)
      
      # what is my operationType?
      operationType = seq_record_object.operationType

      # get stuff from the record -
      sequence = seq_record_object.sequence
      enzymeSymbol = seq_record_object.enzymeSymbol
      modelSpecies = seq_record_object.modelSpecies

      # process the data -
      if (operationType == :X)
          
          # generate the TX buffer -
          txtl_reaction_buffer = build_transcription_reaction_buffer_for_gene_sequence(modelSpecies, enzymeSymbol, sequence, configuration_dictionary)
      elseif (operationType == :L)

          # generate the TL buffer -
          txtl_reaction_buffer = build_translation_reaction_buffer_for_protein_sequence(modelSpecies, enzymeSymbol, sequence, configuration_dictionary)
      end

      tmp_buffer *= txtl_reaction_buffer
  end 
    
  # ok, so last thing we need to split along \n, and return the original array of sequence objects (for stuff later) -
  return (split(tmp_buffer,"\n"), seq_record_object_array)
end

function build_grn_connection_list(statement_vector::Array{VLGRNSentence,1}, configuration_dictionary::Dict{String,Any})

    # inner factory functions -
    function _grn_species_object_factory(list_of_symbols::Array{String})
  
        species_set = VLSpeciesSymbol[]
        for symbol_text in list_of_symbols
            tmp_obj = VLSpeciesSymbol()
            tmp_obj.species_type = :GENE
            tmp_obj.species_symbol = symbol_text
            push!(species_set, tmp_obj)
        end
      
        return species_set
    end

    # initialize -
    list_of_connections = VLGRNConnectionObject[]
  
    # iterate through the statement vector -
    for vgrn_sentence in statement_vector
  
      # Create conenction object -
      connection_object = VLGRNConnectionObject()
  
      # Who are my actors?
      list_of_actor_symbols = String[]
      actor_string = vgrn_sentence.sentence_actor_clause
      recursive_grn_species_parser!(reverse(collect(actor_string)),list_of_actor_symbols)
      actor_set::Array{VLSpeciesSymbol} = _grn_species_object_factory(list_of_actor_symbols)
  
      # Who are my targets?
      list_of_target_symbols = String[]
      target_string = vgrn_sentence.sentence_target_clause
      recursive_grn_species_parser!(reverse(collect(target_string)),list_of_target_symbols)
      target_set::Array{VLSpeciesSymbol} = _grn_species_object_factory(list_of_target_symbols)
  
      # set them on the connection object -
      # ok - do we have a compound set of actors -
      if (length(actor_set) == 1)
  
        actor_object = actor_set[1]
        connection_object.connection_symbol = actor_object.species_symbol
      else
  
  
        local_buffer = ""
        number_of_actors = length(actor_set)
        for (index,actor_object::VLSpeciesSymbol) in enumerate(actor_set)
  
          local_buffer *= "$(actor_object.species_symbol)"
          if (index <= number_of_actors - 1)
            local_buffer *= "_"
          end
        end
  
        connection_object.connection_symbol = local_buffer
      end
  
      connection_object.connection_actor_set = actor_set
      connection_object.connection_target_set = target_set
  
      # create a set for list_of_induction_synonyms -
      induction_synonyms = Set{String}()
      list_of_induction_synonyms = configuration_dictionary["list_of_induction_synonyms"]
      for (index,local_dictionary) in enumerate(list_of_induction_synonyms)
  
        # grab the symbol -
        symbol = local_dictionary["symbol"]
        push!(induction_synonyms,symbol)
      end
  
      # create a set of list_of_repression_synonyms -
      repression_synonyms = Set{String}()
      list_of_repression_synonyms = configuration_dictionary["list_of_repression_synonyms"]
      for (index,local_dictionary) in enumerate(list_of_repression_synonyms)
  
        # grab the symbol -
        symbol = local_dictionary["symbol"]
        push!(repression_synonyms,symbol)
      end
  
      # What is my type?
      connection_action_string = vgrn_sentence.sentence_action_clause
      if (in(connection_action_string,induction_synonyms))
        connection_object.connection_type = :activate
      elseif (in(connection_action_string,repression_synonyms))
        connection_object.connection_type = :inhibit
      end
  
      # cache this connection -
      push!(list_of_connections,connection_object)
    end

    # return -
    return list_of_connections
end

function build_grn_species_list(statement_vector::Array{VLGRNSentence})

    function _partition!(list_of_species::Array{VLSpeciesSymbol})

        # ok, frist, we need to split into balanced and unbalanced lists -
        list_of_gene_indexes::Array{Int} = Int[]
        list_of_mRNA_indexes::Array{Int} = Int[]
        list_of_protein_indexes::Array{Int} = Int[]
      
        for (index,species_object) in enumerate(list_of_species)
      
          species_type::Symbol = species_object.species_type
          if (species_type == :GENE)
            push!(list_of_gene_indexes,index)
          elseif (species_type == :MRNA)
            push!(list_of_mRNA_indexes,index)
          elseif (species_type == :PROTEIN)
            push!(list_of_protein_indexes,index)
          end
        end
      
        # combine -
        permutation_index_array = vcat(list_of_gene_indexes,list_of_mRNA_indexes,list_of_protein_indexes)
      
        # permute the array -
        permute!(list_of_species,permutation_index_array)
    end
      
    list_of_symbols = String[]
    for vgrn_sentence in statement_vector
  
      # build species string -
      species_string = vgrn_sentence.sentence_actor_clause*" "*vgrn_sentence.sentence_target_clause
      recursive_grn_species_parser!(reverse(collect(species_string)),list_of_symbols)
    end
  
    # ok, so we need to convert this to a set, and then convert back to an array (set is unique)
    species_set = Set{String}()
    for symbol in list_of_symbols
      push!(species_set,symbol)
    end
  
    # unique list -
    unique_list_of_species = String[]
    for symbol in species_set
      push!(unique_list_of_species,symbol)
    end
  
    # sort -
    sort!(unique_list_of_species)
  
    # ok, so we have a sorted list of *genes* (that is what is in the file)
    # create a list of genes, mRNA and protein -
    list_of_species_objects = VLSpeciesSymbol[]
  
    # build the species objects -
    for species_symbol in unique_list_of_species
  
      # objects -
      gene_object = VLSpeciesSymbol()
      gene_object.species_type = :GENE
      gene_object.species_symbol = species_symbol
  
      # mRNA -
      mRNA_object = VLSpeciesSymbol()
      mRNA_object.species_type = :MRNA
      mRNA_object.species_symbol = species_symbol
        
      # protein -
      protein_object = VLSpeciesSymbol()
      protein_object.species_type = :PROTEIN
      protein_object.species_symbol = species_symbol
  
      # push -
      push!(list_of_species_objects,gene_object)
      push!(list_of_species_objects,mRNA_object)
      push!(list_of_species_objects,protein_object)
    end
  
    # partition by type -
    return _partition!(list_of_species_objects)
end
  
function recursive_grn_species_parser!(sentence_char_array::Array{Char},list_of_symbols::Array{String})

    if (isempty(sentence_char_array) == true)
      return
    end
  
    # process each char -
    test_char = pop!(sentence_char_array)
    if (test_char == '(' || test_char == ' ')
        recursive_grn_species_parser!(sentence_char_array,list_of_symbols)
    elseif (isletter(test_char) == true)
  
        # cache this letter -
        biological_symbol_cache = Char[]
        push!(biological_symbol_cache,test_char)
  
        # When should we stop?
        stop_set = Set{Char}()
        push!(stop_set,' ')
        push!(stop_set,',')
        push!(stop_set,')')
        push!(stop_set,'\n')
        push!(stop_set,'\r')
  
        # ok, so lets read until we hit a space or a comma -
        if (isempty(sentence_char_array))
            stop_flag = true
        else
            stop_flag = false
        end
  
        while (stop_flag == false)
  
            if (isempty(sentence_char_array) == false)
                next_test_char = pop!(sentence_char_array)
  
                if (in(next_test_char,stop_set) == false)
                    push!(biological_symbol_cache,next_test_char)
                else
                    stop_flag = true
                end
            else
                stop_flag = true
            end
        end
  
        # Store the symbol -
        if (isempty(biological_symbol_cache) == false)
            push!(list_of_symbols,String(biological_symbol_cache))
        end
  
        # ok, so we should be ready for another dive -
        recursive_grn_species_parser!(sentence_char_array,list_of_symbols)
    end
end
# ------------------------------------------------------------------------------ #

# --- PUBLIC METHODS ----------------------------------------------------------- #
function parse_vff_model_file(path_to_model_file::String, configuration_dictionary::Dict{String,Any}, 
    default_parameter_dictionary::Dict{String,Any})::Dict{String,Any}

    # check the file path -
    is_file_path_ok(path_to_model_file)
    
    # initialize -
    problem_dictionary = Dict{String,Any}()

    # load the file into an array -
    file_buffer_array = read_file_from_path(path_to_model_file)

    # -- SEQ SECTION --------------------------------------------------------------------------------- #
    sequence_section = extract_section(file_buffer_array, "#TXTL-SEQUENCE::START", "#TXTL-SEQUENCE::STOP")    
    (txtl_reaction_section, seq_object_array) = parse_vff_sequence_section(sequence_section, default_parameter_dictionary)
    (txtl_reaction_order_array, txtl_reaction_dictionary) = parse_vff_reaction_section(txtl_reaction_section)
    
    # cache the array of sequence objects -
    problem_dictionary["sequence_object_array"] = seq_object_array
    # ------------------------------------------------------------------------------------------------ #

    # -- METABOLISM SECTION -------------------------------------------------------------------------- #
    metabolic_reaction_section = extract_section(file_buffer_array, "#METABOLISM::START", "#METABOLISM::STOP")
    (metabolic_reaction_order_array, metabolic_reaction_dictionary) = parse_vff_reaction_section(metabolic_reaction_section)
    
    # merge the TX/TL dictionary with the metabolic dictionary -
    total_reaction_dictionary = merge(metabolic_reaction_dictionary, txtl_reaction_dictionary)
    total_reaction_order_array = vcat(metabolic_reaction_order_array, txtl_reaction_order_array)

    # generate a list of metabolites -
    list_of_species_objects = build_metabolic_symbol_array(total_reaction_order_array, total_reaction_dictionary)

    # # cache -
    problem_dictionary["metabolic_reaction_dictionary"] = total_reaction_dictionary
    problem_dictionary["metabolic_reaction_order_array"] = total_reaction_order_array
    problem_dictionary["list_of_species"] = list_of_species_objects
    # ------------------------------------------------------------------------------------------------ #

    # -- GRN SECTION --------------------------------------------------------------------------------- #
    grn_section = extract_section(file_buffer_array, "#GRN::START", "#GRN::STOP")
    grn_sentence_array = parse_grn_section(grn_section)

    # generate the list of connections and species -
    list_of_grn_connections = build_grn_connection_list(grn_sentence_array, configuration_dictionary)
    list_of_grn_species = build_grn_species_list(grn_sentence_array)
    
    # grab them -
    problem_dictionary["list_of_grn_connections"] = list_of_grn_connections
    problem_dictionary["list_of_grn_species"] = list_of_grn_species
    # ------------------------------------------------------------------------------------------------ # 
    
    # return -
    return problem_dictionary
end
# ------------------------------------------------------------------------------ #