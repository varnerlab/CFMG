# -- PRIVATE METHODS BELOW ------------------------------------------------------------------------------ #
# Function to build symbol list -
function build_metabolic_symbol_array(reaction_order_array::Array{String,1}, reaction_dictionary::Dict{String, VLMetabolicReaction})

  # Method variables -
  species_symbol_array::Array{VLSpeciesSymbol,1} = []
  reaction_array = Array{VLMetabolicReaction,1}()
  partitioned_symbol_array = VLSpeciesSymbol[]
  final_partitioned_symbol_array = VLSpeciesSymbol[]

  # build the reaction array -
  for reaction_key in reaction_order_array
      
      # grab -
      reaction_object = reaction_dictionary[reaction_key]

      # cache -
      push!(reaction_array, reaction_object)
  end


  # Helper function to parse the reaction phrases, split out the symbols
  function _classify_species_type(species_symbol)::Symbol 
      
      # check: gene -
      if (occursin("GENE_",species_symbol) == true)
        if (occursin("OPEN",species_symbol) == true)
          return :UNCLASSIFIED
        else
          return :GENE
        end
      end

  
      # check: mRNA -
      if (occursin("mRNA_",species_symbol) == true)
          return :MRNA
      end

      # check: protein -
      if (occursin("PROTEIN_",species_symbol) == true)
          return :PROTEIN
      end

      # check: METABOLITE
      if (occursin("M_",species_symbol) == true)
          if (occursin("tRNA", species_symbol) == true)
              return :TRNA
          end
      
          # else -
          return :METABOLITE
      end

      # check: tRNA -
      if (occursin("tRNA",species_symbol) == true)
          return :TRNA
      end

      # default -
      return :UNCLASSIFIED
  end

  function _parse_phrase(reaction_phrase::String)

    # Method variables -
    local_species_array::Array{VLSpeciesSymbol} = []

    # Split around + -
    fragment_array = split(reaction_phrase,"+")
    for fragment in fragment_array

      if (contains(fragment,"*"))

          local_fragment_array = split(fragment,"*");
          species_symbol = VLSpeciesSymbol();
          species_symbol.species_symbol = local_fragment_array[2];

          # classify -
          species_symbol.species_type = _classify_species_type(species_symbol.species_symbol)
      else

          # Build -
          species_symbol = VLSpeciesSymbol()
          species_symbol.species_symbol = fragment

          # classify -
          species_symbol.species_type = _classify_species_type(species_symbol.species_symbol)
      end

      # grab -
      push!(local_species_array,species_symbol)
    end

    # return -
    return local_species_array
  end

  function _isequal(species_model_1::VLSpeciesSymbol,species_model_2::VLSpeciesSymbol)
    if (species_model_1.species_symbol == species_model_2.species_symbol)
      return true
    end
    return false
  end

  function _add_symbol!(species_symbol_array,species_symbol)

    contains_species_already = false
    for cached_species_model in species_symbol_array

      if (_isequal(cached_species_model,species_symbol))
        contains_species_already = true
        break
      end
    end

    if (contains_species_already == false)
      push!(species_symbol_array,species_symbol)
    end
  end

  # iterate through and get the symbols -
  for reaction in reaction_array

    tmp_species_array_left = _parse_phrase(reaction.left_phrase)
    tmp_species_array_right = _parse_phrase(reaction.right_phrase)
    append!(tmp_species_array_left,tmp_species_array_right)

    for species_model in tmp_species_array_left
      _add_symbol!(species_symbol_array,species_model)
    end
  end

  # ok, so the species symbol array is *not* sorted)
  # let's sort the species -
  tmp_array = String[]
  for species_symbol::VLSpeciesSymbol in species_symbol_array
      push!(tmp_array,species_symbol.species_symbol)
  end

  # generate permutation array -
  idxa_sorted = sortperm(tmp_array)
  sorted_symbol_array = species_symbol_array[idxa_sorted]
  
  # find all the species of type METABOLITE -
  idx_all_e = findall(x->x.species_type == :METABOLITE, sorted_symbol_array)
  for index in idx_all_e
      push!(partitioned_symbol_array,sorted_symbol_array[index])
  end

  # find all the species of type TRNA -
  idx_all_e = findall(x->x.species_type == :TRNA, sorted_symbol_array)
  for index in idx_all_e
      push!(partitioned_symbol_array,sorted_symbol_array[index])
  end

  # find all the species of type GENE -
  idx_all_e = findall(x->x.species_type == :GENE, sorted_symbol_array)
  for index in idx_all_e
      push!(partitioned_symbol_array,sorted_symbol_array[index])
  end

  # find all the species of type MRNA -
  idx_all_e = findall(x->x.species_type == :MRNA, sorted_symbol_array)
  for index in idx_all_e
      push!(partitioned_symbol_array,sorted_symbol_array[index])
  end

  # find all the species of type PROTEIN -
  idx_all_e = findall(x->x.species_type == :PROTEIN, sorted_symbol_array)
  for index in idx_all_e
      push!(partitioned_symbol_array,sorted_symbol_array[index])
  end

  # find all the species of type UNCLASSIFIED -
  idx_all_e = findall(x->x.species_type == :UNCLASSIFIED, sorted_symbol_array)
  for index in idx_all_e
      push!(partitioned_symbol_array,sorted_symbol_array[index])
  end
  
  # lastly - filter out [] -
  idx_all_e = findall(x->x.species_symbol != "[]", partitioned_symbol_array)
  for index in idx_all_e
      push!(final_partitioned_symbol_array, partitioned_symbol_array[index])
  end

  # return -
  return final_partitioned_symbol_array
end

# Function to build the stoichiometric_matrix from reaction list -
function build_metabolic_stoichiometric_matrix(species_symbol_array::Array{VLSpeciesSymbol,1}, reaction_array::Array{VLMetabolicReaction,1})

  # Method variables -
  number_of_species = length(species_symbol_array)
  number_of_reactions = length(reaction_array);
  stoichiometric_matrix = zeros(number_of_species,number_of_reactions);

  function _parse_reaction_phrase(lexeme,reaction_phrase)

    # Split around + -
    coefficient = 0.0;
    fragment_array = split(reaction_phrase,"+")
    for fragment in fragment_array

      if (contains(fragment,"*"))
          local_fragment_array = split(fragment,"*");
          test_lexeme = local_fragment_array[2];

          if (lexeme == test_lexeme)
            coefficient = parse(Float64,local_fragment_array[1]);
            break
          end

      else

        # Build -
        test_lexeme = fragment;
        if (lexeme == test_lexeme)
          coefficient = 1.0;
          break
        end
      end
    end

    return coefficient;
  end

  function _find_stoichiometric_coefficient(species_model::VLSpeciesSymbol, reaction::VLMetabolicReaction)

    # Method variables -
    stoichiometric_coefficient = 0.0

    # Check the left and right phrase -
    stoichiometric_coefficient += -1.0*(_parse_reaction_phrase(species_model.species_symbol,reaction.left_phrase))
    stoichiometric_coefficient += _parse_reaction_phrase(species_model.species_symbol,reaction.right_phrase)
    return stoichiometric_coefficient;
  end

  # setup counters -
  for (row_index,species_symbol) in enumerate(species_symbol_array)
    for (col_index,reaction) in enumerate(reaction_array)

      # Is this species involved in this reaction?
      stoichiometric_matrix[row_index,col_index] = _find_stoichiometric_coefficient(species_symbol,reaction);

    end
  end

  # return -
  return stoichiometric_matrix
end
# -- PRIVATE METHODS ABOVE ------------------------------------------------------------------------------ #

# -- PUBLIC METHODS BELOW ------------------------------------------------------------------------------- #
function generate_stoichiomteric_matrix_program_component(problem_dictionary::Dict{String,Any})::VLProgramComponent

  # initialize -
  filename = "Network.dat"
  program_component = VLProgramComponent()
  reaction_array = Array{VLMetabolicReaction,1}()

  # grab the array of reactions -
  reaction_order_array = problem_dictionary["metabolic_reaction_order_array"]
  reaction_dictionary = problem_dictionary["metabolic_reaction_dictionary"]
  for (index, reaction_key) in enumerate(reaction_order_array)

    # check do we have this key?
    if (haskey(reaction_dictionary,reaction_key) == true)
        
      # grab this reaction object -
      reaction_object = reaction_dictionary[reaction_key]

      # cache -
      push!(reaction_array, reaction_object)
    else
      error("$(reaction_key) not found in the problem dictionary")
    end   
  end

  # get the species array -
  list_of_species_objects = problem_dictionary["list_of_species"]

  # build the stoichiometric_matrix -
  stm_buffer = build_metabolic_stoichiometric_matrix(list_of_species_objects, reaction_array)

  # package and return -
  program_component.matrix = stm_buffer
  program_component.filename = filename
  program_component.type = :matrix

  return program_component
end
# -- PUBLIC METHODS ABOVE ------------------------------------------------------------------------------- #