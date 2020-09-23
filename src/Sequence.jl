# --- PRIVATE METHODS ---------------------------------------------------------------------------------------- #
function parse_gene_seq(gene_seq::String)

    # We will return a dictionary w/nucleotide keys and the number of nucleotides as values -
    nucleotide_dictionary = Dict();
    nucleotide_dictionary["a"] = 0;
    nucleotide_dictionary["t"] = 0;
    nucleotide_dictionary["g"] = 0;
    nucleotide_dictionary["c"] = 0;
  
    # What is the length of the gene sequence -
    number_of_nucleotides = length(gene_seq);
  
    for nucleotide_index = collect(1:number_of_nucleotides)
  
      # get the test nucleotide -
      test_nucleotide = gene_seq[nucleotide_index];
      if (test_nucleotide == 'a')
        value = nucleotide_dictionary["a"];
        nucleotide_dictionary["a"] = value + 1;
      end
  
      if (test_nucleotide == 't')
        value = nucleotide_dictionary["t"];
        nucleotide_dictionary["t"] = value + 1;
      end
  
      if (test_nucleotide == 'g')
        value = nucleotide_dictionary["g"];
        nucleotide_dictionary["g"] = value + 1;
      end
  
      if (test_nucleotide == 'c')
        value = nucleotide_dictionary["c"];
        nucleotide_dictionary["c"] = value + 1;
      end
    end
  
    # return -
    return nucleotide_dictionary;
end

function parse_protein_seq(protein_seq::String)
end

function compute_sequence_length(local_sequence::AbstractString)

  # initialize -
  sequence_count = 0

  # iterate through the array, don't count \n
  for nucleotide in local_sequence
    if (nucleotide != '\n')
      sequence_count = sequence_count + 1
    end
  end
    

  # return -
  return sequence_count
end

function build_translation_reaction_buffer_for_protein_sequence(protein_name::String, enzymeSymbol::String, protein_seq::String, configuration_dictionary::Dict{AbstractString,Any})

    # get default values for biological types -
    MRNA_type = configuration_dictionary["mRNA_type_prefix"]
    TRNA_type = configuration_dictionary["tRNA_type_prefix"]
    GENE_type = configuration_dictionary["gene_type_prefix"]
    PROTEIN_type = configuration_dictionary["protein_type_prefix"]

    # Load the AA symbol map -
    path_to_mapping_file = joinpath(path_to_package,"configuration/aa_map.csv")
    map_array = readdlm(path_to_mapping_file,','); #metabolite 1, one letter 2
    protein_aa_dictionary = Dict();
  
    # Create a mapping dictionary -
    symbol_metabolite_map = Dict();
    for map_index in collect(1:20)
  
      one_letter_aa_symbol = map_array[map_index,2];
      metabolite_symbol = map_array[map_index,1];
      symbol_metabolite_map[one_letter_aa_symbol] = metabolite_symbol;
      protein_aa_dictionary[metabolite_symbol] = 0.0;
    end
  
    # Parse the protein seq -
    number_aa_residues = length(protein_seq);
    local_counter = 0;
    for aa_index in collect(1:number_aa_residues)
  
      # What AA do we have?
      aa_value = string(protein_seq[aa_index]);
      if (aa_value != "\n" && aa_value != " ")
  
        key = symbol_metabolite_map[aa_value];
  
        # Update the dictionary -
        quantity_aa = protein_aa_dictionary[key];
        protein_aa_dictionary[key] = quantity_aa + 1;
        local_counter+=1;
      end
    end
  
    # Ok, we have the protein sequence , build the reaction string buffer -
    buffer="";
    buffer*="translation_initiation_$(protein_name),[],$(MRNA_type)_$(protein_name)+$(enzymeSymbol),$(enzymeSymbol)_START_$(protein_name),false\n"
    buffer*="translation_$(protein_name),[],$(enzymeSymbol)_START_$(protein_name)+$(2*local_counter)*M_gtp_c+$(2*local_counter)*M_h2o_c";
    for aa_index in collect(1:20)
  
      # Get charged tRNA -
      metabolite_symbol = map_array[aa_index,1];
  
      # number of this AA -
      value = protein_aa_dictionary[metabolite_symbol];
  
      # Add charged tRNA species to buffer -
      buffer*="+$(value)*$(metabolite_symbol)_$(TRNA_type)";
    end
  
    # products -
    buffer*=",$(enzymeSymbol)+$(MRNA_type)_$(protein_name)+$(PROTEIN_type)_$(protein_name)+$(2*local_counter)*M_gdp_c+$(2*local_counter)*M_pi_c+$(local_counter)*$(TRNA_type),false\n"
  
    # Write the reactions for charing the tRNA -
    for aa_index in collect(1:20)
  
      # Get charged tRNA -
      metabolite_symbol = map_array[aa_index,1];
  
      # number of this AA -
      value = protein_aa_dictionary[metabolite_symbol];
  
      # Add charged tRNA species to buffer -
      buffer*="$(TRNA_type)_charging_$(metabolite_symbol)_$(protein_name),[],$(value)*$(metabolite_symbol)+$(value)*M_atp_c+$(value)*$(TRNA_type)+$(value)*M_h2o_c,";
      buffer*="$(value)*$(metabolite_symbol)_$(TRNA_type)+$(value)*M_amp_c+$(value)*M_ppi_c,false\n";
    end
  
    return buffer;
end

function build_transcription_reaction_buffer_for_gene_sequence(gene_name::String, enzymeSymbol::String, gene_seq::String, configuration_dictionary::Dict{AbstractString,Any})

    # get default values for biological types -
    MRNA_type = configuration_dictionary["mRNA_type_prefix"]
    TRNA_type = configuration_dictionary["tRNA_type_prefix"]
    GENE_type = configuration_dictionary["gene_type_prefix"]
    PROTEIN_type = configuration_dictionary["protein_type_prefix"]
  
    # function variables -
    buffer= "";
    total_ntp = 0;
  
    # generate the sequence dictionary -
    nucleotide_dictionary = parse_gene_seq(gene_seq);
  
    # write the RNAP binding step -
    buffer*="transcriptional_initiation_$(gene_name),[],$(GENE_type)_$(gene_name)+$(enzymeSymbol),$(enzymeSymbol)_OPEN_$(GENE_type)_$(gene_name),false\n";
    buffer*="transcription_$(gene_name),[],$(enzymeSymbol)_OPEN_$(GENE_type)_$(gene_name)";
  
    # go through by dictionary, and get the base count -
    for (key,value) in nucleotide_dictionary
  
      if (key == "a")
  
        # write the M_atp_c line -
        buffer*="+$(value)*M_atp_c"
  
        # How many a's do we have?
        total_ntp += value;
  
      elseif (key == "t")
  
        # write the M_utp_c line -
        buffer*="+$(value)*M_utp_c"
  
        # How many u's do we have?
        total_ntp += value;
  
      elseif (key == "g")
  
        # write the M_gtp_c line -
        buffer*="+$(value)*M_gtp_c"
  
        # How many g's do we have?
        total_ntp += value;
  
      else
  
        # write the M_gtp_c line -
        buffer*="+$(value)*M_ctp_c"
  
        # How many c's do we have?
        total_ntp += value;
      end
    end
  
    # mRNA+GENE+RNAP+1320*M_pi_c,0,inf;
    buffer*="+$(total_ntp)*M_h2o_c,$(MRNA_type)_$(gene_name)+$(GENE_type)_$(gene_name)+$(enzymeSymbol)+$(total_ntp)*M_ppi_c,false\n"
  
    # mRNA_decay degradation reaction -
    # mRNA_decay,[],mRNA,144*M_cmp_c+151*M_gmp_c+189*M_ump_c+176*M_amp_c,0,inf;
    buffer*="$(MRNA_type)_degradation_$(gene_name),[],$(MRNA_type)_$(gene_name),"
    local_buffer = "";
    for (key,value) in nucleotide_dictionary
  
      if (key == "a")
  
        # write the M_atp_c line -
        local_buffer*="+$(value)*M_amp_c"
  
      elseif (key == "t")
  
        # write the M_utp_c line -
        local_buffer*="+$(value)*M_ump_c"
  
      elseif (key == "g")
  
        # write the M_gtp_c line -
        local_buffer*="+$(value)*M_gmp_c"
  
      else
  
        # write the M_gtp_c line -
        local_buffer*="+$(value)*M_cmp_c"
  
      end
    end
  
    buffer*="$(local_buffer[2:end]),false\n"
  
    # dump -
    # outfile = open("./transcription_$(gene_name).txt", "w")
    # write(outfile,buffer);
    # close(outfile);
  
    # return the buffer -
    return buffer;
end
# ----------------------------------------------------------------------------------------------------------- #