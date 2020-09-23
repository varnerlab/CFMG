# we are making a Python model if this gets called, so lets load the Python strategy -
include("./strategy/PythonStrategy.jl")

function make_python_model(path_to_model_file::String, path_to_output_dir::String; model_type::Symbol = :static)
    error("Ooops! Python model generation has not yet been implemented.")
end