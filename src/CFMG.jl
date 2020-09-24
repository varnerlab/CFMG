module CFMG

# includes -
include("Include.jl")

# methods to make various types of models -
export make_julia_model
export make_octave_model
export make_python_model
export make_matlab_model
export make_vff_model
export make_sbml_model

# method to make a default project structure the user can edit -
export generate_default_project

# method to export MAT files to an editable format -
export extract_files_from_cobra_model

end # module
