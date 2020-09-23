function build_model_generation_report(problem_dictionary::Dict{String,Any})::VLProgramComponent

    # initialize -
    buffer = Array{String,1}()
    program_component = VLProgramComponent()

    # get metadata -
    metadata_dictionary = problem_dictionary["author_metadata_dictionary"]

    # get metadata stuff -
    author_first_name = metadata_dictionary["author_first_name"]
    author_last_name = metadata_dictionary["author_last_name"]
    author_email_address = metadata_dictionary["author_email_address"]
    author_address=metadata_dictionary["author_address"]
    job_description=metadata_dictionary["job_description"]
    job_version=metadata_dictionary["job_version"]

    # get some path information -
    path_to_model_file = problem_dictionary["path_to_model_file"]
    path_to_output_dir = problem_dictionary["path_to_output_dir"]
    elapsed_time = problem_dictionary["elapsed_time"]

    # add a metadata section -
    +(buffer, "// --------------------------------------------------------------------------- //\n")
    +(buffer, "// Metadata - \n")
    +(buffer, "// author: ")
    +(buffer, "$(author_first_name) $(author_last_name)\n")
    +(buffer, "// email: $(author_email_address)\n")
    +(buffer, "// address: $(author_address)\n")
    +(buffer, "// description: $(job_description)\n")
    +(buffer, "// version: $(job_version)\n")
    +(buffer, "//\n");
    +(buffer, "// path to model file: $(path_to_model_file)\n")
    +(buffer, "// path to output: $(path_to_output_dir)\n")
    +(buffer, "// elapsed time: $(elapsed_time) s\n")
    +(buffer, "// --------------------------------------------------------------------------- //\n")
    +(buffer, "\n");

    # add reaction header -
    +(buffer, "// --------------------------------------------------------------------------- //\n")
    +(buffer, "// Reaction list - \n")
    +(buffer, "// record: index name [ec number(s)] left<=>right is_reversible {true|false}\n")
    +(buffer, "// --------------------------------------------------------------------------- //\n")

    # grab the reaction ordering array -
    reaction_order_array = problem_dictionary["metabolic_reaction_order_array"]
    reaction_dictionary = problem_dictionary["metabolic_reaction_dictionary"]
    for (index, reaction_key) in enumerate(reaction_order_array)
        
        # check do we have this key?
        if (haskey(reaction_dictionary,reaction_key) == true)
        
            # VLMetabolicReaction -
            # record::String
            # reaction_name::String
            # ec_number::String
            # left_phrase::String
            # right_phrase::String
            # reverse::String
            # forward::String

            # grab this reaction object -
            reaction_object = reaction_dictionary[reaction_key]   
            +(buffer, "$(index) ")
            +(buffer, "$(reaction_object.reaction_name) ")
            +(buffer, "$(reaction_object.ec_number) ")
            +(buffer, "$(reaction_object.left_phrase)")
            +(buffer, "<=>")                
            +(buffer, "$(reaction_object.right_phrase)")
             
            # direction -
            reverse_flag = reaction_object.reversible
            +(buffer," ")
            +(buffer, reverse_flag)
            +(buffer, "\n")

        else
            error("$(reaction_key) not found in the problem dictionary")
        end
    end

    # add metabolite header -
    +(buffer,"\n")
    +(buffer, "// --------------------------------------------------------------------------- //\n")
    +(buffer, "// Metabolite list - \n")
    +(buffer, "// record: index name type \n")
    +(buffer, "// --------------------------------------------------------------------------- //\n")

    # metabolites 
    list_of_species_objects = problem_dictionary["list_of_species"]
    for (index, species_object) in enumerate(list_of_species_objects)
        
        # grab the symbol -
        species_symbol = species_object.species_symbol
        species_type = string(species_object.species_type)

        # write -
        +(buffer, "$(index) ")
        +(buffer, "$(species_symbol) ")
        +(buffer, "$(species_type)")
        +(buffer, "\n")

    end

    # collapse -
    flat_buffer = ""
    [flat_buffer *= line for line in buffer]

    # add stuff to component -
    program_component.filename = "Report.log"
    program_component.buffer = flat_buffer
    program_component.type = :buffer

    # return -
    return program_component
end