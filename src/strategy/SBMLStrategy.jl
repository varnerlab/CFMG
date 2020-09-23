
#-- PRIVATE METHODS BELOW ------------------------------------------------------------------------------- #
function _build_sbml_species_section(problem_dictionary::Dict{String,Any})::Array{String,1}

    # initialize -
    buffer = Array{String,1}()

    # setup list of species -
    # start tag -
    +(buffer, "<listOfSpecies>\n")

    # grab the list of species -
    list_of_species_objects = problem_dictionary["list_of_species"]
    for (index,species) in enumerate(list_of_species_objects)
        
        # get species information -
        species_symbol = species.species_symbol

        # tmp line -
        tmp_line = "\t<species id=\"$(species_symbol)\" compartment=\"default\" boundaryCondition=\"false\"/>\n"

        # push -
        +(buffer, tmp_line)
    end

    # end tag -
    +(buffer, "</listOfSpecies>\n")

    # return -
    return buffer
end

function _build_sbml_reaction_section(problem_dictionary::Dict{String,Any})::Array{String,1}

    # inner functions -
    function _process_reaction_string(reaction_phrase::String)::Array{VLMetabolicSpeciesReference,1}

        # Split around + -
        species_ref_array = Array{VLMetabolicSpeciesReference,1}()
        fragment_array = split(reaction_phrase,"+")
        for fragment in fragment_array

            if (contains(fragment,"*"))
                local_fragment_array = split(fragment,"*");
                coefficient = local_fragment_array[1]
                species_symbol = local_fragment_array[2];

                # build -
                species_ref_object = VLMetabolicSpeciesReference()
                species_ref_object.species_symbol = species_symbol
                species_ref_object.stoichiometry = coefficient

                # cache -
                push!(species_ref_array, species_ref_object)
            else

                # Build -
                species_symbol = fragment;
                coefficient = "1.0"

                # build -
                species_ref_object = VLMetabolicSpeciesReference()
                species_ref_object.species_symbol = species_symbol
                species_ref_object.stoichiometry = coefficient

                # cache -
                push!(species_ref_array, species_ref_object)
            end
        end

        # return -
        return species_ref_array
    end

    # initialize -
    buffer = Array{String,1}()

    # setup list of reactions -
    # start tag -
    +(buffer, "<listOfReactions>\n")

    # grab the array of reactions -
    reaction_order_array = problem_dictionary["metabolic_reaction_order_array"]
    reaction_dictionary = problem_dictionary["metabolic_reaction_dictionary"]
    for (index, reaction_key) in enumerate(reaction_order_array)

        # check do we have this key?
        if (haskey(reaction_dictionary,reaction_key) == true)
        
            # grab this reaction object -
            reaction_object = reaction_dictionary[reaction_key]

            # get stuff from the reaction object -
            reaction_name = reaction_object.reaction_name
            reversible = reaction_object.reversible
            left_phrase = reaction_object.left_phrase
            right_phrase = reaction_object.right_phrase

            # tmp line -
            reaction_open_line = "\t<reaction id=\"$(reaction_name)\" name=\"$(reaction_name)\" reversible=\"$(reversible)\">\n"
            
            # process the left phrase -
            left_species_ref_list = _process_reaction_string(left_phrase)
            list_of_reactants_buffer = Array{String,1}()
            +(list_of_reactants_buffer, "\t\t<listOfReactants>\n")
            for (index,specief_ref) in enumerate(left_species_ref_list)
                
                species_symbol = specief_ref.species_symbol
                stoichiometry = specief_ref.stoichiometry

                # build tmp line -
                tmp_line = "\t\t\t<speciesReference species=\"$(species_symbol)\" stoichiometry=\"$(stoichiometry)\"/>\n"
            
                # add -
                +(list_of_reactants_buffer,tmp_line)
            end
            +(list_of_reactants_buffer, "\t\t</listOfReactants>\n")
            
            # process the right phrase -
            right_species_ref_list = _process_reaction_string(right_phrase)
            list_of_products_buffer = Array{String,1}()
            +(list_of_products_buffer, "\t\t<listOfProducts>\n")
            for (index,specief_ref) in enumerate(right_species_ref_list)
                
                species_symbol = specief_ref.species_symbol
                stoichiometry = specief_ref.stoichiometry

                # build tmp line -
                tmp_line = "\t\t\t<speciesReference species=\"$(species_symbol)\" stoichiometry=\"$(stoichiometry)\"/>\n"
            
                # add -
                +(list_of_products_buffer,tmp_line)
            end
            +(list_of_products_buffer, "\t\t</listOfProducts>\n")

            # close -
            reaction_close_line = "\t</reaction>\n"

            # grab -
            +(buffer, reaction_open_line)
            +(buffer, list_of_reactants_buffer)
            +(buffer, list_of_products_buffer)
            +(buffer, reaction_close_line)
        else
            error("$(reaction_key) not found in the problem dictionary")
        end   
  end

    # end tag -
    +(buffer,"</listOfReactions>\n")

    # return -
    return buffer
end

function _build_sbml_header_section(problem_dictionary::Dict{String,Any})::Array{String,1}
    
    # initialize -
    buffer = Array{String,1}()

    # add header lines -
    +(buffer,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    +(buffer,"<sbml xmlns=\"http://www.sbml.org/sbml/level2\" level=\"2\" version=\"1\">\n")
    +(buffer,"<model id=\"default_model\" name=\"default_model\">\n")

    # return -
    return buffer
end

function _build_sbml_footer_section(problem_dictionary::Dict{String,Any})::Array{String,1}

    # initialize -
    buffer = Array{String,1}()

    # add footer lines -
    +(buffer, "</model>\n")
    +(buffer, "</sbml>\n")

    # return -
    return buffer
end

function _build_smbl_compartments_section(problem_dictionary::Dict{String,Any})::Array{String,1}

    # initialize -
    buffer = Array{String,1}()

    # <listOfCompartments>
	#     <compartment id="Extra_organism"/>
    # </listOfCompartments>

    # add footer lines -
    +(buffer, "<listOfCompartments>\n")
    +(buffer, "\t<compartment id=\"default\"/>\n")
    +(buffer, "</listOfCompartments>\n")
 
    # return -
    return buffer
end
# ------------------------------------------------------------------------------------------------------ #

#-- PUBLIC METHODS BELOW ------------------------------------------------------------------------------- #
function build_sbml_model_program_component(problem_dictionary::Dict{String,Any}, filename::String)::VLProgramComponent

    # initalize -
    sbml_buffer = Array{String,1}()
    program_component = VLProgramComponent()

    # build the header buffer -
    header_buffer = _build_sbml_header_section(problem_dictionary)

    # build the list of compartments buffer -
    compartments_buffer = _build_smbl_compartments_section(problem_dictionary)

    # build the species buffer -
    species_buffer = _build_sbml_species_section(problem_dictionary)

    # build the reaction buffer -
    reaction_buffer = _build_sbml_reaction_section(problem_dictionary)

    # build the footer buffer -
    footer_buffer = _build_sbml_footer_section(problem_dictionary)

    # combine the different sections together -
    +(sbml_buffer, header_buffer)

    # compartments -
    +(sbml_buffer, compartments_buffer)

    # add the species -
    +(sbml_buffer,species_buffer)

    # add the reactions -
    +(sbml_buffer, reaction_buffer)

    # add the footer -
    +(sbml_buffer, footer_buffer)

    # collapse -
    flat_buffer = ""
    [flat_buffer *= line for line in sbml_buffer]

    # add data to program_component -
    program_component.filename = filename;
    program_component.buffer = flat_buffer
    program_component.type = :buffer

    # return -
    return program_component
end
# ------------------------------------------------------------------------------------------------------ #