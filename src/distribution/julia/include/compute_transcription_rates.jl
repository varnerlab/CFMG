function calculate_transcription_rates(state::Array{Float64,1}, data_dictionary::Dict{String,Any}, vargs...)

    # initialize -
    transcription_kinetics_array = Float64[]
    
    # get stuff from the data_dictionary/biophysical_dictionary -
    species_symbol_type_array = data_dictionary["species_symbol_type_array"]
    gene_coding_length_array = data_dictionary["gene_coding_length_array"]
    time_constant_modifier_array = data_dictionary["time_constant_modifier_array"]
    species_concentration_array = data_dictionary["species_concentration_array"]
    biophysical_dictionary = data_dictionary["biophysical_dictionary"]
    characteristic_length = biophysical_dictionary["characteristic_transcript_length"]
    transcription_elongation_rate = biophysical_dictionary["transcription_elongation_rate"]
    characteristic_initiation_time = biophysical_dictionary["characteristic_initiation_time_transcription"]
    KX = biophysical_dictionary["transcription_saturation_constant"]
    RNAPII_concentration = biophysical_dictionary["RNAPII_concentration"]
    species_symbol_type_array = biophysical_dictionary["species_symbol_type_array"]

    # which indices are mRNA (the production of transcription)?
    idx_gene = findall(x->x==:GENE,species_symbol_type_array)

    # compute the kinetic limit -
    for (gene_index, gene_length) in enumerate(gene_coding_length_array)

        # how much gene do we have?
        # for host_type == :cell_free this is in concentration units -
        G = species_concentration_array[idx_gene[gene_index]]

        # what is the correction index?
        correction_index = idx_gene[gene_index]
        time_scale_parameter = time_constant_modifier_array[correction_index]

        # compute kE -
        kE = transcription_elongation_rate*(1/gene_length)

        # compute kI -
        kI = (1/characteristic_initiation_time)

        # compute the tau factor -
        tau_factor = (kE/kI)*time_scale_parameter

        # Compute the rate -
        sat_term = (G/(KX*tau_factor+(1+tau_factor)*G))
        value = kE*RNAPII_concentration*sat_term*(3600) # nmol/gDW-hr

        # push -
        push!(transcription_kinetics_array, value)
    end

    # return -
    return transcription_kinetics_array
end