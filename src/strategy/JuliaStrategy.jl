# -- PRIVATE METHODS BELOW ------------------------------------------------------------------------------ #
function build_function_header_buffer(comment_dictionary)

    # initialize -
    buffer = ""
  
    # get some data from the comment_dictionary -
    function_name = comment_dictionary["function_name"]
    function_description = comment_dictionary["function_description"]
    input_arg_array = comment_dictionary["input_args"]
    output_arg_array = comment_dictionary["output_args"]
  
    buffer *= "# ----------------------------------------------------------------------------------- #\n"
    buffer *= "# Function: $(function_name)\n"
    buffer *= "# Description: $(function_description)\n"
    buffer *= "# Generated on: $(now())\n"
    buffer *= "#\n"
    buffer *= "# Input arguments:\n"
  
    for argument_dictionary in input_arg_array
  
      arg_symbol = argument_dictionary["symbol"]
      arg_description = argument_dictionary["description"]
  
      # write the buffer -
      buffer *= "# $(arg_symbol) => $(arg_description) \n"
    end
  
    buffer *= "#\n"
    buffer *= "# Output arguments:\n"
    for argument_dictionary in output_arg_array
  
      arg_symbol = argument_dictionary["symbol"]
      arg_description = argument_dictionary["description"]
  
      # write the buffer -
      buffer *= "# $(arg_symbol) => $(arg_description) \n"
    end
    buffer *= "# ----------------------------------------------------------------------------------- #\n"
  
    # return the buffer -
    return buffer
end
  
function build_copyright_header_buffer(problem_dictionary::Dict{String,Any})
  
    # What is the current year?
    current_year = string(Dates.year(now()))
  
    # Get comment data from
    buffer = ""
    buffer*= "# ----------------------------------------------------------------------------------- #\n"
    buffer*= "# Copyright (c) $(current_year) Varnerlab\n"
    buffer*= "# Robert Frederick Smith School of Chemical and Biomolecular Engineering\n"
    buffer*= "# Cornell University, Ithaca NY 14850\n"
    buffer*= "#\n"
    buffer*= "# Permission is hereby granted, free of charge, to any person obtaining a copy\n"
    buffer*= "# of this software and associated documentation files (the \"Software\"), to deal\n"
    buffer*= "# in the Software without restriction, including without limitation the rights\n"
    buffer*= "# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"
    buffer*= "# copies of the Software, and to permit persons to whom the Software is\n"
    buffer*= "# furnished to do so, subject to the following conditions:\n"
    buffer*= "#\n"
    buffer*= "# The above copyright notice and this permission notice shall be included in\n"
    buffer*= "# all copies or substantial portions of the Software.\n"
    buffer*= "#\n"
    buffer*= "# THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"
    buffer*= "# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"
    buffer*= "# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"
    buffer*= "# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"
    buffer*= "# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"
    buffer*= "# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"
    buffer*= "# THE SOFTWARE.\n"
    buffer*= "# ----------------------------------------------------------------------------------- #\n"
  
    # return -
    return buffer  
end

function build_transcription_rate_buffer(problem_dictionary::Dict{String,Any})::Array{String,1}

  # initialize -
  buffer = Array{String,1}()

  # get the comment buffer -
  comment_header_dictionary = problem_dictionary["configuration_dictionary"]["function_comment_dictionary"]["calculate_transcription_rates"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)
  +(buffer, function_comment_buffer)

  # function -
  path_to_impl = "$(path_to_package)/distribution/julia/include/compute_transcription_rates.jl"
  buffer = include_function(path_to_impl)

  # return -
  return buffer
end

function build_translation_rate_buffer(problem_dictionary::Dict{String,Any})::Array{String,1}

  # initialize -
  buffer = Array{String,1}()

  # get the comment buffer -
  comment_header_dictionary = problem_dictionary["configuration_dictionary"]["function_comment_dictionary"]["calculate_translation_rates"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)
  +(buffer, function_comment_buffer)

  # function -
  path_to_impl = "$(path_to_package)/distribution/julia/include/compute_translation_rates.jl"
  buffer = include_function(path_to_impl)

  # return -
  return buffer
end

function build_translation_control_buffer(problem_dictionary::Dict{String,Any})::Array{String,1}

  # initialize -
  buffer = Array{String,1}()

  # get the comment buffer -
  comment_header_dictionary = problem_dictionary["configuration_dictionary"]["function_comment_dictionary"]["translation_control_function"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)
  +(buffer, function_comment_buffer)

  # function -
  +(buffer,"function calculate_translation_control(state::Array{Float64,1}, data_dictionary::Dict{String,Any},vargs...)\n")
  +(buffer,"\n")

  # how many proteins do we have?
  list_of_seq_objects::Array{VLSequenceRecord} = problem_dictionary["sequence_object_array"]
  idx_proteins = findall(x->(x.operationType == :L), list_of_seq_objects)

  # initialize -
  +(buffer,"\t# initialize -\n")
  +(buffer, "\tw = ones($(length(idx_proteins)))\n")
  +(buffer, "\n")

  # comment -
  +(buffer,"\t# User: override the default translation control impl here - \n")
  +(buffer,"\t# TODO: override ... \n")
 
  # # list of proteins -
  # list_of_protein_objects = list_of_species_objects[idx_proteins]
  # for (index,species_object) in enumerate(list_of_protein_objects)
    
  #   +(buffer,"\tw[$(index)] = 1.0")
  #   +(buffer,"\t# $(index) TL control variable: $(species_object.species_symbol)\n")
  
  # end 

  +(buffer,"\n")
  +(buffer,"\t# return - \n")
  +(buffer,"\treturn w\n")
  +(buffer,"end\n")

  # return -
  return buffer
end

function does_set_contain_species(species_set::Array{VLSpeciesSymbol},species_object::VLSpeciesSymbol)

  # initilize -
  does_set_contains_species_flag = false
  for local_species_object in species_set

    # get type and name -
    local_species_type = local_species_object.species_type
    local_species_symbol = "$(string(local_species_type))_"*local_species_object.species_symbol

    # get the test symbol and type -
    test_species_type = species_object.species_type
    test_species_symbol = species_object.species_symbol

    if (local_species_type == test_species_type && test_species_symbol == local_species_symbol)
      does_set_contains_species_flag = true
      return does_set_contains_species_flag
    end
  end

  return does_set_contains_species_flag
end

function is_species_a_target_in_connection_list(list_of_connections::Array{VLGRNConnectionObject}, target_species::VLSpeciesSymbol, connection_type::Symbol)

  target_connection_list = VLGRNConnectionObject[]
  for connection_object in list_of_connections

    # get targets -
    local_target_set = connection_object.connection_target_set
    local_connection_type = connection_object.connection_type
    if (local_connection_type == connection_type && does_set_contain_species(local_target_set,target_species) == true)
      push!(target_connection_list,connection_object)
    end
  end

  return target_connection_list
end

function iterate_grn_control_control_connection(gene_object::VLSpeciesSymbol, list_of_connections::Array{VLGRNConnectionObject})

  # What is my gene_symbol -
  gene_symbol = gene_object.species_symbol

  tmp_buffer = ""
  for connection_object in list_of_connections

    # actor -
    connection_symbol = connection_object.connection_symbol
    tmp_buffer *= "\tW_$(gene_symbol)_$(connection_symbol) = parameter_value_dictionary[\"W_$(gene_symbol)_$(connection_symbol)\"]\n"
  end

  return tmp_buffer
end

function iterate_grn_binding_control_connection(gene_object::VLSpeciesSymbol,list_of_connections::Array{VLGRNConnectionObject})

  # What is my gene_symbol -
  gene_symbol = gene_object.species_symbol

  tmp_buffer = ""
  for connection_object in list_of_connections

    # actor -
    connection_symbol = connection_object.connection_symbol

    tmp_buffer *= "\tn_$(gene_symbol)_$(connection_symbol) = parameter_value_dictionary[\"n_$(gene_symbol)_$(connection_symbol)\"]\n"
    tmp_buffer *= "\tK_$(gene_symbol)_$(connection_symbol) = parameter_value_dictionary[\"K_$(gene_symbol)_$(connection_symbol)\"]\n"

  end

  return tmp_buffer
end

function build_transcription_control_buffer(problem_dictionary::Dict{String,Any})::Array{String,1}

  # initialize -
  buffer = Array{String,1}()

  # get the comment buffer -
  comment_header_dictionary = problem_dictionary["configuration_dictionary"]["function_comment_dictionary"]["transcription_control_function"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)
  +(buffer, function_comment_buffer)

  # get list of connections and species -
  list_of_grn_connections::Array{VLGRNConnectionObject} = problem_dictionary["list_of_grn_connections"]
  list_of_grn_species::Array{VLSpeciesSymbol} = problem_dictionary["list_of_species"]
  list_of_seq_objects::Array{VLSequenceRecord} = problem_dictionary["sequence_object_array"]

  # get the list of genes -
  idx_genes = findall(x->(x.species_type == :GENE), list_of_grn_species)
  list_of_genes = list_of_grn_species[idx_genes]

  # function -
  +(buffer,"function calculate_transcription_control(state::Array{Float64,1}, data_dictionary::Dict{String,Any}, vargs...)\n")
  +(buffer, "\n")
  +(buffer, "\t# initialize the control_array - \n")
  +(buffer, "\tcontrol_array = zeros($(length(list_of_genes)))\n")
  +(buffer, "\n")

  # alias the species list -
  +(buffer, "\t# Alias the species - \n")
  for (index,species_object) in enumerate(list_of_grn_species)

    # Grab the symbol -
    species_symbol = species_object.species_symbol

    # write the record -
    +(buffer, "\t$(species_symbol) = state[$(index)]\n")
  end
  +(buffer, "\n")

  # alias the binding parameters -
  +(buffer, "\t# Alias the model parameters - \n")
  +(buffer, "\tparameter_value_dictionary = data_dictionary[\"parameter_dictionary\"][\"parameter_value_dictionary\"]\n")

  # alias the parameter values -
  runtime_model_parameter_name_array = problem_dictionary["runtime_model_parameter_name_array"]
  for parameter_name in runtime_model_parameter_name_array
    +(buffer,"\t$(parameter_name)=parameter_value_dictionary[\"$(parameter_name)\"]\n")
  end
  +(buffer,"\n")

  # get list of genes -
  for (gene_index,gene_object) in enumerate(list_of_genes)

    # get gene symbol -
    gene_symbol = gene_object.species_symbol

    # for this gene, what is my enzyme symbol?
    enzyme_symbol = get_enzyme_symbol(gene_symbol, list_of_seq_objects)

    # connections -
    activating_connections = is_species_a_target_in_connection_list(list_of_grn_connections,gene_object,:activate)
    inhibiting_connections = is_species_a_target_in_connection_list(list_of_grn_connections,gene_object,:inhibit)

    # generate the binding functions -
    list_of_all_connections = VLGRNConnectionObject[]
    append!(list_of_all_connections, activating_connections)
    append!(list_of_all_connections, inhibiting_connections)
    for (index,connection_object) in enumerate(list_of_all_connections)

      # actor -
      actor_list = connection_object.connection_actor_set
      connection_symbol = connection_object.connection_symbol

      +(buffer, "\t# Transfer function target:$(gene_symbol) actor:$(connection_symbol)\n")
      +(buffer, "\tactor_set_$(gene_symbol)_$(connection_symbol) = [\n")
      for actor_object in actor_list

        actor_symbol = actor_object.species_symbol
        actor_type = actor_object.species_type
        +(buffer, "\t\tPROTEIN_$(actor_symbol)\n")
      end

      +(buffer, "\t]\n")
      +(buffer, "\tactor = prod(actor_set_$(gene_symbol)_$(connection_symbol))\n")
      +(buffer, "\tb_$(gene_symbol)_$(connection_symbol) = (actor^(n_$(gene_symbol)_$(connection_symbol)))/")
      +(buffer, "(K_$(gene_symbol)_$(connection_symbol)^(n_$(gene_symbol)_$(connection_symbol))+actor^(n_$(gene_symbol)_$(connection_symbol)))\n")
      +(buffer, "\n")
    end

    +(buffer, "\t# Control function for $(gene_symbol) - \n")
    +(buffer,"\tcontrol_array[$(gene_index)] = (")
    numerator = ""
    if (isempty(activating_connections) == true)
      +(buffer, "W_$(gene_symbol)_$(enzyme_symbol)")
    else

      numerator *= "W_$(gene_symbol)_$(enzyme_symbol)+"
      for connection_object in activating_connections
        # actor -
        connection_symbol = connection_object.connection_symbol
        numerator *= "W_$(gene_symbol)_$(connection_symbol)*b_$(gene_symbol)_$(connection_symbol)+"
      end
      +(buffer, numerator[1:end-1])
    end

    +(buffer, ")/(1+W_$(gene_symbol)_$(enzyme_symbol)")

    if (isempty(activating_connections) == false)
      demoninator = ""
      for connection_object in activating_connections
        # actor -
        connection_symbol = connection_object.connection_symbol
        demoninator *= "+W_$(gene_symbol)_$(connection_symbol)*b_$(gene_symbol)_$(connection_symbol)"
      end

      +(buffer, demoninator[1:end])
    end

    # ok - do we have inhibitory statements?
    if (isempty(inhibiting_connections) == true)
      +(buffer, ")\n")
      +(buffer, "\n")
    else

      demoninator = ""
      for connection_object in inhibiting_connections
        # actor -
        connection_symbol = connection_object.connection_symbol
        demoninator *= "+W_$(gene_symbol)_$(connection_symbol)*b_$(gene_symbol)_$(connection_symbol)"
      end

      +(buffer, demoninator[1:end])
      +(buffer, ")\n")
      +(buffer, "\n")
    end
  end

  +(buffer, "\t# return - \n")
  +(buffer, "\treturn control_array\n")
  +(buffer,"end\n")

  # return -
  return buffer
end

function build_allosteric_control_buffer(problem_dictionary::Dict{String,Any})::Array{String,1}

  # initialize -
  buffer = Array{String,1}()

  # get the comment buffer -
  comment_header_dictionary = problem_dictionary["configuration_dictionary"]["function_comment_dictionary"]["transcription_control_function"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)
  +(buffer, function_comment_buffer)

  # get a list of reaction names -
  list_of_reactions = problem_dictionary["metabolic_reaction_order_array"]
  number_of_reactions = length(list_of_reactions)

  # function -
  +(buffer,"function calculate_allosteric_control(state::Array{Float64,1}, data_dictionary::Dict{String,Any}, vargs...)\n")
  +(buffer,"\n")

  +(buffer,"\t# initialize the v-vector - \n")
  +(buffer,"\tv = ones($(number_of_reactions))\n");

  +(buffer, "\n")
  +(buffer,"\t# User: override the default allosteric control impl here - \n")
  +(buffer,"\t# TODO: override ... \n")

  +(buffer,"\n")
  +(buffer,"\t# return - \n")
  +(buffer,"\treturn v\n")
  +(buffer,"end\n")

  # return -
  return buffer
end

# -- PRIVATE METHODS ABOVE ------------------------------------------------------------------------------ #

# -- PUBLIC METHODS BELOW ------------------------------------------------------------------------------- #

# function to build Control.jl 
function build_control_program_component(problem_dictionary::Dict{String,Any})::VLProgramComponent

  # initialize -
  filename = "Control.jl"
  program_component = VLProgramComponent()
  buffer = Array{String,1}()

  # build the header -
  header_buffer = build_copyright_header_buffer(problem_dictionary)
  +(buffer, header_buffer)
  +(buffer, "\n")
  
  # build the TX buffer -
  tx_control_buffer = build_transcription_control_buffer(problem_dictionary)
  +(buffer, tx_control_buffer)
  +(buffer, "\n")

  # build the TL buffer -
  tl_control_buffer = build_translation_control_buffer(problem_dictionary)
  +(buffer, tl_control_buffer)

  # build the TL buffer -
  allosteric_control_buffer = build_allosteric_control_buffer(problem_dictionary)
  +(buffer, allosteric_control_buffer)
  
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

# function to build Kinetics.jl
function build_kinetics_program_component(problem_dictionary::Dict{String,Any})::VLProgramComponent

  # initialize -
  filename = "Kinetics.jl"
  program_component = VLProgramComponent()
  buffer = Array{String,1}()

  # build the header -
  header_buffer = build_copyright_header_buffer(problem_dictionary)
  +(buffer, header_buffer)
  +(buffer, "\n")

  # build the TX buffer -
  tx_buffer = build_transcription_rate_buffer(problem_dictionary)
  +(buffer, tx_buffer)
  +(buffer, "\n")

  # build the TL buffer -
  tl_buffer = build_translation_rate_buffer(problem_dictionary)
  +(buffer, tl_buffer)

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

# function to build the Data.jl -
function build_data_dictionary_program_component(problem_dictionary::Dict{String,Any})::VLProgramComponent

  # initialize -
  filename = "Data.jl"
  program_component = VLProgramComponent()
  buffer = Array{String,1}()

  # grab the default value dictionary, the get default values that we put in the code -
  default_parameter_dictionary = problem_dictionary["default_parameter_dictionary"]
  lower_flux_bound_value = default_parameter_dictionary["default_flux_lower_bound"]
  upper_flux_bound_value = default_parameter_dictionary["default_flux_upper_bound"]
  lower_species_bound_value = default_parameter_dictionary["default_species_lower_bound"]
  upper_species_bound_value = default_parameter_dictionary["default_species_upper_bound"]
  default_transcription_time_constant_modifier = default_parameter_dictionary["default_transcription_time_constant_modifier"]
  default_translation_time_constant_modifier = default_parameter_dictionary["default_translation_time_constant_modifier"]

  # build the header -
  header_buffer = build_copyright_header_buffer(problem_dictionary)
  +(buffer, header_buffer)

  # get the comment buffer -
  comment_header_dictionary = problem_dictionary["configuration_dictionary"]["function_comment_dictionary"]["data_dictionary_function"]
  function_comment_buffer = build_function_header_buffer(comment_header_dictionary)
  +(buffer, function_comment_buffer)

  # before we get too far, get some stuff from the problem_dictionary -
  list_of_species = problem_dictionary["list_of_species"]
  list_of_sequence_objects = problem_dictionary["sequence_object_array"]

  # get the order of reactions -
  metabolic_reaction_name_array = problem_dictionary["metabolic_reaction_order_array"]
  metabolic_reaction_object_dictionary = problem_dictionary["metabolic_reaction_dictionary"]

  # function -
  +(buffer,"function generate_default_data_dictionary(")
  +(buffer,"path_to_biophysical_constants_file::String = \"./src/config/Biophysics.toml\",\n");
  +(buffer,"\tpath_to_ec_file::String = \"./src/config/EC.toml\", path_to_control_constants_file::String=\"./src/config/Control.toml\",\n");
  +(buffer,"\tbiophysical_constants_file_parser::Function=build_biophysical_dictionary, ec_constants_file_parser::Function=build_ec_data_dictionary,\n\tcontrol_constants_parser::Function=build_control_constants_dictionary, vargs...)\n")
  +(buffer,"\n")
  +(buffer,"\t# initialize - \n")
  +(buffer,"\tdata_dictionary = Dict{String,Any}()\n")
  +(buffer,"\n")
  +(buffer,"\t# load the stoichiometric array - \n")
  +(buffer,"\tstoichiometric_matrix = readdlm(\"./src/Network.dat\")")
  +(buffer,"\t# WARNING: loads default stm from the expected location. If you've changed the location (or stm) => change the path.\n")
  +(buffer,"\t(number_of_species, number_of_reactions) = size(stoichiometric_matrix)\n")
  +(buffer, "\n")
  +(buffer, "\t# Load the biophysical dictionary - \n")
  +(buffer, "\tbiophysical_dictionary = biophysical_constants_file_parser(path_to_biophysical_constants_file)\n")
  +(buffer, "\n")
  +(buffer, "\t# Load the ec data dictionary - \n")
  +(buffer, "\tec_data_dictionary = ec_constants_file_parser(path_to_ec_file)\n")
  +(buffer, "\n")
  +(buffer, "\t# Load the parameter dictionary - \n")
  +(buffer, "\tparameter_dictionary = control_constants_parser(path_to_control_constants_file)\n")
  +(buffer, "\n")

  # generate default value for is_minimum_flag -
  +(buffer, "\n")
  +(buffer, "\t# The default behavior for the solver is to minimize - \n")
  +(buffer, "\tis_minimum_flag = true\n")
  +(buffer, "\n") 

  # generate default object coeff array -
  +(buffer, "\n")
  +(buffer, "\t# Initialize an empty objective coefficient array - \n")
  +(buffer, "\tobjective_coefficient_array = zeros(number_of_reactions)\n")
  +(buffer, "\n")

  # generate species_symbol_type_array -
  +(buffer, "\t# List of the species types - \n")
  +(buffer, "\tspecies_symbol_type_array = [\n")
  for (index,species_object) in enumerate(list_of_species)
    +(buffer, "\t\t:$(species_object.species_type)\t;\t")
    +(buffer, "# $(index) $(species_object.species_symbol)\n")
  end
  +(buffer,"\t]\n")

  # generate gene_coding_length_array -
  +(buffer, "\n")
  +(buffer, "\t# Gene coding length array holds the length (nt) for model genes - \n")
  +(buffer, "\tgene_coding_length_array = [\n")
  idx_gene = findall(x->(x.operationType == :X), list_of_sequence_objects)
  list_of_genes = list_of_sequence_objects[idx_gene]
  for (index, seq_object) in enumerate(list_of_genes)
    
    +(buffer, "\t\t$(seq_object.length)\t;\t")
    +(buffer, "# $(index) GENE $(seq_object.modelSpecies)\n")
  end
  +(buffer,"\t]\n")


  # generate protein_coding_length_array
  +(buffer, "\n")
  +(buffer, "\t# Protein coding length array holds the length (aa) for model proteins - \n")
  +(buffer, "\tprotein_coding_length_array = [\n")
  idx_proteins = findall(x->(x.operationType == :L), list_of_sequence_objects)
  list_of_proteins = list_of_sequence_objects[idx_proteins]
  for (index, seq_object) in enumerate(list_of_proteins)
    
    +(buffer, "\t\t$(seq_object.length)\t;\t")
    +(buffer, "# $(index) PROTEIN $(seq_object.modelSpecies)\n")
  end
  +(buffer,"\t]\n")

  # generate time_constant_modifier_array -
  +(buffer, "\n")
  +(buffer, "\t# Time constant modifier array holds a modifier for the TX and TL time constants - \n")
  +(buffer, "\ttime_constant_modifier_array = [\n")
  ordered_seq_array = [list_of_genes list_of_proteins]
  for (index, seq_object) in enumerate(ordered_seq_array)
    
    # what type of operation -
    if (seq_object.operationType == :X)
      +(buffer, "\t\t$(default_transcription_time_constant_modifier)\t;\t")  
    else
      +(buffer, "\t\t$(default_translation_time_constant_modifier)\t;\t")
    end
      

    +(buffer, "# $(index) $(seq_object.operationType) $(seq_object.modelSpecies)\n")
  end
  +(buffer,"\t]\n")

  # generate a default initial state array -
  +(buffer, "\n")
  +(buffer, "\t# Default: Initial concentrations for all model species are assumed to be 0 \n")
  +(buffer, "\t# Default: You can override this setting in the update_species_concentration_array function \n")
  +(buffer, "\tspecies_concentration_array = zeros(number_of_species)\n")

  # generate dummy impl for species bounds array -
  +(buffer, "\n")
  +(buffer, "\t# Default: all species are assumed to be bounded by [0,0] \n")
  +(buffer, "\t# Default: You can override this setting in the update_species_bounds_array function \n")
  +(buffer, "\tLSB = $(lower_species_bound_value)\n")
  +(buffer, "\tUSB = $(lower_species_bound_value)\n")
  +(buffer, "\tspecies_bounds_array = [LSB*ones(number_of_species,1) USB*ones(number_of_species,1)]\n")

  # generate dummy impl for flux bounds array -
  +(buffer, "\n")
  +(buffer, "\t# Default: all fluxes are assumed to assumed to be bounded by [0,U] where U is some uper bound \n")
  +(buffer, "\t# Default: You can override this choice in the update_flux_bounds_array function \n")
  +(buffer, "\tLFB = $(lower_flux_bound_value)\n")
  +(buffer, "\tUFB = $(upper_flux_bound_value)\n")
  +(buffer, "\tflux_bounds_array = [LFB*ones(number_of_reactions,1) UFB*ones(number_of_reactions,1)]\n")

  # generate list of species symbols -
  +(buffer,"\n")
  +(buffer, "\t# List of the species symbol names - \n")
  +(buffer, "\tspecies_symbol_array = [\n")
  for (index,species_object) in enumerate(list_of_species)
    +(buffer, "\t\t\"$(species_object.species_symbol)\"\t;\t")
    +(buffer, "# $(index) $(species_object.species_type)\n")
  end
  +(buffer,"\t]\n")

  # generate species-order dictionary -
  +(buffer,"\n")
  +(buffer,"\t# Forward species order dictionary -\n")
  +(buffer,"\tspecies_order_dictionary = Dict{String,Int}(species_symbol_array[i]=>i for i=1:number_of_species)\n")

  # generate inverse species-order dictionary -
  +(buffer,"\n")
  +(buffer,"\t# Inverse species order dictionary -\n")
  +(buffer,"\tinverse_species_order_dictionary = Dict{Int,String}(i=>species_symbol_array[i] for i=1:number_of_species)\n")

  
  # generate list of reaction names -
  +(buffer,"\n")
  +(buffer, "\t# List of the reaction names - \n")
  +(buffer, "\treaction_name_array = [\n")
  for (index,reaction_tag) in enumerate(metabolic_reaction_name_array)
    
    # lookup the reaction object -
    reaction_object = metabolic_reaction_object_dictionary[reaction_tag]
    
    # get stuff -
    +(buffer, "\t\t\"$(reaction_tag)\"\t;\t")
    +(buffer, "# $(index) $(reaction_object.left_phrase)=$(reaction_object.right_phrase) $(reaction_object.reversible)\n")
  end
  +(buffer,"\t]\n")

  # generate species-order dictionary -
  +(buffer,"\n")
  +(buffer,"\t# Forward reaction order dictionary - \n")
  +(buffer,"\treaction_order_dictionary = Dict{String,Int}(reaction_name_array[i]=>i for i=1:number_of_reactions)\n")

  # generate inverse species-order dictionary -
  +(buffer,"\n")
  +(buffer,"\t# Inverse reaction order dictionary - \n")
  +(buffer,"\tinverse_reaction_order_dictionary = Dict{Int,String}(i=>reaction_name_array[i] for i=1:number_of_reactions)\n")


  +(buffer, "\n")
  +(buffer,"\t# -- DO NOT EDIT BELOW THIS LINE ------------------------------------------------------------------------------------ # \n")
  +(buffer,"\tdata_dictionary[\"stoichiometric_matrix\"] = stoichiometric_matrix\n")
  +(buffer,"\tdata_dictionary[\"number_of_species\"] = number_of_species\n")
  +(buffer,"\tdata_dictionary[\"number_of_reactions\"] = number_of_reactions\n")
  +(buffer,"\tdata_dictionary[\"is_minimum_flag\"] = is_minimum_flag\n")
  +(buffer,"\tdata_dictionary[\"objective_coefficient_array\"] = objective_coefficient_array\n")
  +(buffer,"\tdata_dictionary[\"species_concentration_array\"] = species_concentration_array\n")
  +(buffer,"\tdata_dictionary[\"species_bounds_array\"] = species_bounds_array\n")
  +(buffer,"\tdata_dictionary[\"flux_bounds_array\"] = flux_bounds_array\n")
  +(buffer,"\tdata_dictionary[\"species_symbol_type_array\"] = species_symbol_type_array\n")
  +(buffer,"\tdata_dictionary[\"gene_coding_length_array\"] = gene_coding_length_array\n")
  +(buffer,"\tdata_dictionary[\"protein_coding_length_array\"] = protein_coding_length_array\n")
  +(buffer,"\tdata_dictionary[\"time_constant_modifier_array\"] = time_constant_modifier_array\n")
  +(buffer,"\tdata_dictionary[\"biophysical_dictionary\"] = biophysical_dictionary\n")
  +(buffer,"\tdata_dictionary[\"ec_data_dictionary\"] = ec_data_dictionary\n")
  +(buffer,"\tdata_dictionary[\"parameter_dictionary\"] = parameter_dictionary\n")

  +(buffer, "\n") 
  +(buffer, "\t# Order information - \n")
  +(buffer,"\tdata_dictionary[\"reaction_name_array\"] = reaction_name_array\n")
  +(buffer,"\tdata_dictionary[\"species_symbol_array\"] = species_symbol_array\n")
  +(buffer,"\tdata_dictionary[\"species_order_dictionary\"] = species_order_dictionary\n")
  +(buffer,"\tdata_dictionary[\"inverse_species_order_dictionary\"] = inverse_species_order_dictionary\n")
  +(buffer,"\tdata_dictionary[\"reaction_order_dictionary\"] = reaction_order_dictionary\n")
  +(buffer,"\tdata_dictionary[\"inverse_reaction_order_dictionary\"] = inverse_reaction_order_dictionary\n")
  +(buffer, "\n")
  +(buffer,"\treturn data_dictionary\n")
  +(buffer,"\t# -- DO NOT EDIT ABOVE THIS LINE ------------------------------------------------------------------------------------ # \n")
  +(buffer,"end\n")

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
# -- PUBLIC METHODS ABOVE ------------------------------------------------------------------------------- #"