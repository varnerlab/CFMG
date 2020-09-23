function is_file_path_ok(path_to_file::String)

    if (isfile(path_to_file) == false)
        throw(ArgumentError("$(path_to_file) does not exist."))
    end
end

function is_dir_path_ok(path_to_file::String)

    # get the dir of the path -
    dir_name = dirname(path_to_file)

    # check, is this a legit dir?
    if (isdir(dir_name) == false)
        throw(ArgumentError("$(dir_name) does not exist."))
    end
end

function is_cobra_dictionary_ok(cobra_dictionary::Dict{String,Any})
end

function is_kegg_organism_code_ok(kegg_organism_code::Symbol)
end