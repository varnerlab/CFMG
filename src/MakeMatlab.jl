# we are making an Octave model if this gets called, so lets load the Octave strategy -
include("./strategy/MatlabStrategy.jl")

function make_matlab_model(path_to_model_file::String, path_to_output_dir::String; model_type::Symbol = :static)
    error("Ooops! Matlab model generation has not yet been implemented.")
end