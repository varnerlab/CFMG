function lookup_gene_ec_mapping_record(kegg_gene_id::String)::Union{Set{String},Nothing}

    # initialize -
    record_set = Set{String}()

    # call the KEGG API to get the ec number -
    list_of_ec_numbers = get_ec_number_for_gene(kegg_gene_id)
    if list_of_ec_numbers !== nothing

        # create a record, add to the mapping buffer -
        for ec_number in list_of_ec_numbers
            push!(record_set,ec_number)
        end

        # return -
        return record_set
    end

    return nothing
end

function load_cobra_model_file(path_to_cobra_mat_file::String, model_name::String)::Dict{String,Any}

    # open the cobra file -
    file = matopen(path_to_cobra_mat_file)
    cobra_dictionary = read(file,model_name)
    close(file)

    # return -
    return cobra_dictionary
end

function export_reaction_mapping_file(cobra_dictionary::Dict{String,Any}, path_to_mapping_file::String)

    # Check the dictionary -
    is_cobra_dictionary_ok(cobra_dictionary)

    # initalize -
    mapping_buffer = String[]

    # add header text to mapping file -
    filename = splitdir(path_to_mapping_file)[2]
    +(mapping_buffer,"// ------------------------------------------------------------- //")
    +(mapping_buffer,"// $(filename)")
    +(mapping_buffer,"// GENERATED BY: CBModelTools")
    +(mapping_buffer,"// GENERATED ON: $(Dates.now())")
    +(mapping_buffer,"// SOURCE: https://github.com/varnerlab/CBModelTools")
    +(mapping_buffer,"//")
    +(mapping_buffer,"// Reaction->reaction name map")
    +(mapping_buffer,"// record: reacton_tag=reaction_name")
    +(mapping_buffer,"// reaction_tag: from the rxns field of the COBRA mat file")
    +(mapping_buffer,"// reaction_name: from the rxnNames field of the COBRA mat file")
    +(mapping_buffer,"//")
    +(mapping_buffer,"// The order of the reactions in this file is used to order the")
    +(mapping_buffer,"// columns of the stoichiometric matrix.")
    +(mapping_buffer,"// ------------------------------------------------------------ //")

    list_of_reactions = cobra_dictionary["rxns"]
    list_of_reaction_names = cobra_dictionary["rxnNames"]

    # process each gene -
    for (index,reaction_tag) in enumerate(list_of_reactions)

        # init -
        line = ""

        # get content -
        reaction_name = list_of_reaction_names[index]

        # build line -
        line *= "$(reaction_tag)=$(reaction_name)"

        # cache -
        +(mapping_buffer, line)
    end

    # Write out the mapping file
    write_file_to_path(path_to_mapping_file,mapping_buffer)
end

function export_gene_order_file(cobra_dictionary::Dict{String,Any}, kegg_organism_code::String, path_to_mapping_file::String)

    # initalize -
    mapping_buffer = String[]
    list_of_genes = cobra_dictionary["genes"]

    # process each gene -
    for gene_id in list_of_genes

        # make the KEGG gene id -
        kegg_gene_id = "$(kegg_organism_code):$(gene_id)"

        # cache -
        +(mapping_buffer, kegg_gene_id)
    end

    # Write out the vff file -
    open("$(path_to_mapping_file)", "w") do f

        for line_item in mapping_buffer
            write(f,"$(line_item)\n")
        end
    end
end

function export_reaction_tag_to_gene_mapping_file(cobra_dictionary::Dict{String,Any}, kegg_organism_code::String, path_to_mapping_file::String)

    # initalize -
    mapping_buffer = String[]

    # add header text to mapping file -
    filename = splitdir(path_to_mapping_file)[2]
    +(mapping_buffer,"// --------------------------------------------------------- //")
    +(mapping_buffer,"// $(filename)")
    +(mapping_buffer,"// GENERATED BY: CBModelTools")
    +(mapping_buffer,"// GENERATED ON: $(Dates.now())")
    +(mapping_buffer,"// SOURCE: https://github.com/varnerlab/CBModelTools")
    +(mapping_buffer,"")
    +(mapping_buffer,"// Reaction->gene mapping - ")
    +(mapping_buffer,"// record: reacton_tag={gene_id}")
    +(mapping_buffer,"// reaction_tag: from the rxns field of the COBRA mat file")
    +(mapping_buffer,"// gene_id: (kegg organism code):(gene location code)")
    +(mapping_buffer,"// --------------------------------------------------------- //")

    # get the list of reaction tags, and genes from the cobra dictionary -
    list_of_reaction_tags = cobra_dictionary["rxns"]
    list_of_genes = cobra_dictionary["genes"]

    # get the rxn gene mapping matrix -
    RGM = Matrix(cobra_dictionary["rxnGeneMat"])

    # What is the size of the system?
    (number_of_reactions, number_of_genes) = size(RGM)

    # main loop -
    for reaction_index = 1:number_of_reactions

        # what is the tag for this reaction?
        reaction_tag = list_of_reaction_tags[reaction_index]

        # initialize -
        record = ""
        record *= "$(reaction_tag)="

        # does this reaction have associated genes?
        idx_genes = findall(x->x==1,RGM[reaction_index,:])
        local_gene_set = Set{String}()
        if (!isempty(idx_genes))

            # ok, we have genes, grab them -
            gene_id_array = list_of_genes[idx_genes]

            # process each gene -
            for gene_id in gene_id_array

                # make the KEGG gene id -
                kegg_gene_id = gene_id
                if (occursin(".",gene_id) == true)
                    # need to cutoff the trailing *.1
                    kegg_gene_id = "$(kegg_organism_code):$(gene_id[1:end-2])"
                else
                    kegg_gene_id = "$(kegg_organism_code):$(gene_id)"
                end

                # cache -
                push!(local_gene_set,kegg_gene_id)
            end
        end

        if (isempty(local_gene_set) == false)

            # make an ec record -
            gene_record = ""
            for gene_number in local_gene_set
                gene_record*="$(gene_number),"
            end

            # remove trailing ,
            gene_record = gene_record[1:end-1]

            # add the record -
            record*="$(gene_record)"

            # push into buffer and go around again -
            +(mapping_buffer,record)
        end
    end

    # Write out the file -
    write_file_to_path(path_to_mapping_file, mapping_buffer)
end

function export_reaction_tag_to_ec_mapping_file(cobra_dictionary::Dict{String,Any}, kegg_organism_code::String, path_to_mapping_file::String)

    # initalize -
    mapping_buffer = String[]

    # add header text to mapping file -
    filename = splitdir(path_to_mapping_file)[2]
    +(mapping_buffer,"// --------------------------------------------------------- //")
    +(mapping_buffer,"// $(filename)")
    +(mapping_buffer,"// GENERATED BY: CBModelTools")
    +(mapping_buffer,"// GENERATED ON: $(Dates.now())")
    +(mapping_buffer,"// SOURCE: https://github.com/varnerlab/CBModelTools")
    +(mapping_buffer,"//")
    +(mapping_buffer,"// Reaction->ecnumber mapping - ")
    +(mapping_buffer,"// record: reacton_tag={ecnumber}")
    +(mapping_buffer,"// reaction_tag: from the rxns field of the COBRA mat file")
    +(mapping_buffer,"// ec_number: possible ecnumber estimated from KEGG")
    +(mapping_buffer,"// --------------------------------------------------------- //")


    # get the list of reaction tags, and genes from the cobra dictionary -
    list_of_reaction_tags = cobra_dictionary["rxns"]
    list_of_genes = cobra_dictionary["genes"]

    # get the rxn gene mapping matrix -
    RGM = Matrix(cobra_dictionary["rxnGeneMat"])

    # What is the size of the system?
    (number_of_reactions, number_of_genes) = size(RGM)

    # main loop -
    for reaction_index = 1:number_of_reactions

        # what is the tag for this reaction?
        reaction_tag = list_of_reaction_tags[reaction_index]

        # user message -
        msg = "Starting $(reaction_tag) ($(reaction_index) of $(number_of_reactions))"

        # initialize -
        record = ""
        record *= "$(reaction_tag)="

        # does this reaction have associated genes?
        idx_genes = findall(x->x==1,RGM[reaction_index,:])

        # init -
        ec_record_set = Set{String}()
        if (!isempty(idx_genes))

            # ok, we have genes, grab them -
            gene_id_array = list_of_genes[idx_genes]

            # process each gene -
            for gene_id in gene_id_array

                # make the KEGG gene id -
                kegg_gene_id = gene_id
                if (occursin(".",gene_id) == true)
                    # need to cutoff the trailing *.1
                    kegg_gene_id = "$(kegg_organism_code):$(gene_id[1:end-2])"
                else
                    kegg_gene_id = "$(kegg_organism_code):$(gene_id)"
                end

                # lookup -
                local_ec_record_set = lookup_gene_ec_mapping_record(kegg_gene_id)
                if local_ec_record_set != nothing

                    # push into ec_record_set -
                    for ec_number in local_ec_record_set
                        push!(ec_record_set,ec_number)
                    end
                end
            end
        end

        if (isempty(ec_record_set) == false)

            # make an ec record -
            ec_record = ""
            for ec_number in ec_record_set
                ec_record*="$(ec_number),"
            end

            # remove trailing ,
            ec_record = ec_record[1:end-1]

            # add the record -
            record*="$(ec_record)"

            # push into buffer and go around again -
            +(mapping_buffer,record)
        end
    end

    # Write out the file -
    write_file_to_path(path_to_mapping_file,mapping_buffer)
end


# --- PUBLIC METHODS ------------------------------------------------------------------------------------------ #
function extract_files_from_cobra_model(path_to_cobra_mat_file::String, path_to_exported_files::String, modelName::String; 
    kegg_organism_code_symbol::Symbol = :eco)    

    # checks - do the paths exist?
    is_file_path_ok(path_to_cobra_mat_file)
    is_dir_path_ok(path_to_exported_files)

    # load the cobra dictionary -
    cobra_dictionary = load_cobra_model_file(path_to_cobra_mat_file, modelName)

    # check the cobra dictionary - is it legit?
    is_cobra_dictionary_ok(cobra_dictionary)

    # ok, looks ok if we get here - write out a bunch of files that we'll need -
    kegg_organism_code = String(kegg_organism_code_symbol)

    # reaction mapping -
    path_to_reaction_mapping_file = joinpath(path_to_exported_files,"ReactionNameMap.dat")
    export_reaction_mapping_file(cobra_dictionary,path_to_reaction_mapping_file)

    # gene order -
    path_to_gene_order_file = joinpath(path_to_exported_files,"GeneOrder.dat")
    export_gene_order_file(cobra_dictionary, kegg_organism_code, path_to_gene_order_file)

    # reaction tags to gene mapping -
    path_reaction_gene_mapping_file = joinpath(path_to_exported_files,"ReactionGeneMap.dat")
    export_reaction_tag_to_gene_mapping_file(cobra_dictionary, kegg_organism_code, path_reaction_gene_mapping_file)

    # reaction tag to ec mapping -
    path_reaction_to_ec_number_mapping = joinpath(path_to_exported_files, "ReactionECNumberMap.dat")
    export_reaction_tag_to_ec_mapping_file(cobra_dictionary, kegg_organism_code, path_reaction_to_ec_number_mapping)
end
# ------------------------------------------------------------------------------------------------------------- #