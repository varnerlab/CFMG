
"""
    generate_default_project(path_to_project_dir::String)

    Generates a default project structure which contains an empty model file and Defaults.toml file.

    Inputs:
    path_to_project_dir = path to where you want model code to be generated
"""
function generate_default_project(path_to_project_dir::String)
    
    # before we get too far along, we need to check if the user already has code in the location that we want to generate at -
    # if they do, then move it -    
    if (isdir(path_to_project_dir) == true)
        
        # ok, looks like we may have a conflict - mv the offending code
        if (move_existing_project_at_path(path_to_project_dir) == false)
            
            # Something happend ... the world is ending ...
            throw(ArgumentError("automatic directory conflict resolution failed. Unable to move existing directory $(path_to_project_dir)"))
        end
    else
        
        # ok, no code at our target directory -
        mkpath(path_to_project_dir)
    end

    # ok, if we get here, then we have a clean place to generate the default project structure -
    # We need to two things for a project, the defaults file, and a blank network file with all the sections -
    
    # Transfer distrubtion files to the output -> these files are shared between model types
    transfer_distribution_files("$(path_to_package)/distribution/julia/default_project_files", "$(path_to_project_dir)",".vff")
    transfer_distribution_files("$(path_to_package)/distribution/julia/default_project_files", "$(path_to_project_dir)",".toml")
end