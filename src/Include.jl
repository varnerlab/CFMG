# include standard julia modules, and outside packages -
using JSON
using Dates
using DelimitedFiles
using MAT
using Logging
using LightXML

# constants -
const path_to_package = dirname(pathof(@__MODULE__))

# include my files -
include("Types.jl")
include("Extensions.jl")
include("Report.jl")
include("Parser.jl")
include("Checks.jl")
include("Utility.jl")
include("Sequence.jl")
include("Metabolism.jl")
include("Cobra.jl")

# language specific generation -
include("MakeJulia.jl")
include("MakeMatlab.jl")
include("MakeOctave.jl")
include("MakePython.jl")
include("MakeVFF.jl")
include("MakeSBML.jl")
include("MakeDefaultProject.jl")