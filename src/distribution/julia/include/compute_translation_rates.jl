function calculate_translation_rates(state::Array{Float64,1}, data_dictionary::Dict{String,Any}, vargs...)

    # initialize -
    translation_parameters_array = Array{VLTranslationParameters,1}()
    translation_kinetics_array = Float64[]

    # get stuff from the data_dictionary/biophysical_dictionary -
    species_symbol_type_array = data_dictionary["species_symbol_type_array"]
    protein_coding_length_array = data_dictionary["protein_coding_length_array"]
    time_constant_modifier_array = data_dictionary["time_constant_modifier_array"]
    biophysical_dictionary = data_dictionary["biophysical_dictionary"]
    ribosome_concentration = biophysical_dictionary["ribosome_concentration"]
    translation_elongation_rate = biophysical_dictionary["translation_elongation_rate"]
    characteristic_initiation_time_translation = biophysical_dictionary["characteristic_initiation_time_translation"]
    KL = biophysical_dictionary["translation_saturation_constant"]
    species_symbol_type_array = biophysical_dictionary["species_symbol_type_array"]

    # which indices are protein -
    idx_protein = findall(x->x==:PROTEIN,species_symbol_type_array)

    # compute the translation parameters -
    for (index,protein_length) in enumerate(protein_coding_length_array)

        # compute kE -
        kE = translation_elongation_rate*(1/protein_length)

        # compute kI -
        kI = (1/characteristic_initiation_time_translation)

        # what is the correct index?
        correction_index = idx_protein[index]
        time_scale_parameter = time_constant_modifier_array[correction_index]

        # compute the tau factor -
        tau_factor = (kE/kI)*time_scale_parameter

        # compute the vmax -
        # use a polysome factor of 6 -
        translation_vmax = kE*ribosome_concentration

        # build -
        translationParameters = VLTranslationParameters()
        translationParameters.vmax = translation_vmax*(3600)    # convert to hr
        translationParameters.tau_factor = tau_factor
        translationParameters.KL = KL
        push!(translation_parameters_array, translationParameters)
    end

    # which indicies are mRNA?
    mRNA_index_array = findall(x->x==:MRNA,species_symbol_type_array)
    
    # grab the translation parameters from the data dictionary -
    number_of_translation_rates = length(translation_parameters_array)
    counter = 1
    for index = 1:number_of_translation_rates

        # use the mRNA_index_array to index into the state vector -
        mRNA_concentration = state[mRNA_index_array[index]]

        # grab the parameters struct -
        parameters_struct = translation_parameters_array[index]
        vmax = parameters_struct.vmax
        tau = parameters_struct.tau_factor
        KL = parameters_struct.KL

        # build the rate -
        value = vmax*(mRNA_concentration/(KL*tau+(1+tau)*mRNA_concentration))

        # package -
        push!(translation_kinetics_array, value)
    end

    # return -
    return translation_kinetics_array
end