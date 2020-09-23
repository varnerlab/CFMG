function contains(string,token)
    return occursin(token,string)
end


function write_combined_program_components_to_disk(file_path::String, set_of_program_components::Set{VLProgramComponent})

    # check - do we have teh file path?
    if (isdir(file_path) == false)
        mkpath(file_path)
    end

    # initialize -
    buffer = ""
    for program_component in set_of_program_components
        component_type = program_component.type
        if (component_type == :buffer)

            # get the data -
            program_buffer = program_component.buffer

            # cache -
            buffer*=program_buffer
            buffer*="\n"
        end
    end

    # all have the same file name, so just grab a component -
    filename = pop!(set_of_program_components).filename
    
    # build the path -
    path_to_program_file = file_path*"/"*filename

    # write -
    outfile = open(path_to_program_file, "w")
    write(outfile, buffer);
    close(outfile);
end

function write_combined_program_components_to_disk(file_path::String, array_of_program_components::Array{VLProgramComponent,1})

    # check - do we have teh file path?
    if (isdir(file_path) == false)
        mkpath(file_path)
    end

    # initialize -
    buffer = ""
    for program_component in array_of_program_components
        component_type = program_component.type
        if (component_type == :buffer)

            # get the data -
            program_buffer = program_component.buffer

            # cache -
            buffer*=program_buffer
            buffer*="\n"
        end
    end

    # all have the same file name, so just grab a component -
    filename = pop!(array_of_program_components).filename
    
    # build the path -
    path_to_program_file = file_path*"/"*filename

    # write -
    outfile = open(path_to_program_file, "w")
    write(outfile, buffer);
    close(outfile);
end

function write_program_components_to_disk(file_path::String, set_of_program_components::Set{VLProgramComponent})

  # check - do we have teh file path?
  if (isdir(file_path) == false)
    mkpath(file_path)
  end

  # go through each component, and dump the buffer to disk -
  for program_component in set_of_program_components

    # We switch on type -
    filename = program_component.filename
    component_type = program_component.type
    if (component_type == :buffer)

        # get the data -
        program_buffer = program_component.buffer

        # build the path -
        path_to_program_file = file_path*"/"*filename

        # Write the file -
        outfile = open(path_to_program_file, "w")
        write(outfile,program_buffer);
        close(outfile);

    elseif (component_type == :matrix || component_type == :vector)
        
        # get the matrix -
        program_matrix = program_component.matrix
    
        # build the path -
        path_to_program_file = file_path*"/"*filename

        # write the file -
        writedlm(path_to_program_file, program_matrix)

    else
        error("unsupported program component type: $(component_type)")
    end
  end
end

function write_file_to_path(path_to_file::String,buffer::Array{String,1})

    # check, is this a legit dir?
    is_dir_path_ok(path_to_file)

    # write -
    open("$(path_to_file)", "w") do f

        for line_item in buffer
            write(f,"$(line_item)\n")
        end
    end
end

function read_file_from_path(path_to_file::String)::Array{String,1}

    # is this mapping file path legit?
    is_file_path_ok(path_to_file)

    # initialize -
    buffer = String[]

    # Read in the file -
    open("$(path_to_file)", "r") do file
        for line in eachline(file)
            +(buffer,line)
        end
    end

    # return -
    return buffer
end

function move_existing_project_at_path(path_to_existing_project::String)::Bool

    # we are getting called *if* we already know there is a dir conflict -
    # if this is getting called, we have an existing dir where the user wants to write code.
    # we need then create a new dir called *.0, and mv the offending dir to this location?
    # return true if this worked, otherwise false -

    # parent and child dir that we are generating into -
    parent_dir = dirname(path_to_existing_project)
    child_dir = basename(path_to_existing_project)
    destination_path = ""

    # current backup index  -
    current_backup_index = 0

    # do we already have the destination?
    loop_flag = true
    while loop_flag

         # make a destination path - 
        destination_path = joinpath(parent_dir,"$(child_dir).$(current_backup_index)")

        # we don't have this dir, we are done -
        if (isdir(destination_path) == false)
            loop_flag = false
        end    

        # ok, looks like we already have this dir, update the counter -
        current_backup_index = current_backup_index + 1
    end
    
    # mv -
    mv(path_to_existing_project, destination_path)

    # check - 
    if (isdir(destination_path) == false)
        return false
    end

    return true
end

function extract_section(file_buffer_array::Array{String,1}, start_section_marker::String, end_section_marker::String)::Array{String,1}

    # initialize -
    section_buffer = String[]

    # find the SECTION START AND END -
    section_line_start = 1
    section_line_end = 1
    for (index,line) in enumerate(file_buffer_array)

        if (occursin(start_section_marker,line) == true)
            section_line_start = index
        elseif (occursin(end_section_marker,line) == true)
            section_line_end = index
        end
    end

    for line_index = (section_line_start+1):(section_line_end-1)
        line_item = file_buffer_array[line_index]
        push!(section_buffer,line_item)
    end

    # return -
    return section_buffer
end

function transfer_distribution_file(path_to_distribution_files::String,
                                      input_file_name_with_extension::String,
                                      path_to_output_files::String,
                                      output_file_name_with_extension::String)

    # Load the specific file -
    # create src_buffer -
    src_buffer::Array{String} = String[]

    # check - do we have the file path?
    if (isdir(path_to_output_files) == false)
        mkpath(path_to_output_files)
    end

    # path to distrubtion -
    path_to_src_file = path_to_distribution_files*"/"*input_file_name_with_extension
    open(path_to_src_file,"r") do src_file
        for line in eachline(src_file)

            # need to add a new line for some reason in Julia 0.6
            new_line_with_line_ending = line*"\n"
            push!(src_buffer,new_line_with_line_ending)
        end
    end

    # Write the file to the output -
    path_to_program_file = path_to_output_files*"/"*output_file_name_with_extension
    outfile = open(path_to_program_file, "w")
    write(outfile,src_buffer);
    close(outfile);
end

function transfer_distribution_files(path_to_distribution_files::String,
                                      path_to_output_files::String,
                                      file_extension::String)


    # Search the directory for src files -
    # load the files -
    searchdir(path,key) = filter(x->contains(x,key),readdir(path))

    # build src file list -
    list_of_src_files = searchdir(path_to_distribution_files,file_extension)

    # check - do we have the file path?
    if (isdir(path_to_output_files) == false)
        mkpath(path_to_output_files)
    end

    # go thru the src file list, and copy the files to the output path -
    for src_file in list_of_src_files

        # create src_buffer -
        src_buffer::Array{String,1} = String[]

        # path to distrubtion -
        path_to_src_file = path_to_distribution_files*"/"*src_file
        open(path_to_src_file,"r") do src_file
            for line in eachline(src_file)

                # need to add a new line for some reason in Julia 0.6
                new_line_with_line_ending = line*"\n"
                push!(src_buffer,new_line_with_line_ending)
            end
        end

        # Write the file to the output -
        path_to_program_file = path_to_output_files*"/"*src_file
        open(path_to_program_file, "w") do f
            for line in src_buffer
                write(f,line)
            end
        end
    end
end

function include_function(path_to_src_file::String)::Array{String,1}

    # create src_buffer -
    src_buffer::Array{String,1} = String[]

    # read -
    open(path_to_src_file,"r") do src_file
        for line in eachline(src_file)

            new_line_with_line_ending = line*"\n"
            push!(src_buffer,new_line_with_line_ending)
        end
    end

    # return the raw buffer -
    return src_buffer
end

function include_function(path_to_src_file::String, prefix_pad_string::String)::String

    # create src_buffer -
    src_buffer::Array{String,1} = String[]

    # read -
    open(path_to_src_file,"r") do src_file
        for line in eachline(src_file)

            new_line_with_line_ending = line*"\n"
            push!(src_buffer,new_line_with_line_ending)
        end
    end

    string_value = ""
    for line in src_buffer
        string_value *= prefix_pad_string*line
    end

    return src_buffer
end