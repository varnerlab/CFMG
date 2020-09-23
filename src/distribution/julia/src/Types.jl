# ----------------------------------------------------------------------------------- #
# Copyright (c) 2020 Varnerlab
# Robert Frederick School of Chemical and Biomolecular Engineering
# Cornell University, Ithaca NY 14850

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ----------------------------------------------------------------------------------- #

mutable struct VLTranslationParameters

    vmax::Float64
    tau_factor::Float64
    KL::Float64

    function VLTranslationParameters()
		this = new()
	end
end

# Create some abstract parent types -
abstract type VLAbstractProblem end
abstract type VLAbstractSolution end

# Concrete subtypes -
mutable struct VLStaticFBAProblem<:VLAbstractProblem

  # initialize -
  flux_bounds_array::Array{Float64,2}
  species_bounds_array::Array{Float64,2}
  stoichiometric_matrix::Array{Float64,2}
  obj_coeff_vector::Array{Float64,1}
  is_minimum_flag::Bool

  function VLStaticFBAProblem()
    this = new()
  end
end

mutable struct VLDynamicFBAProblem<:VLAbstractProblem

  # fields -
  species_bounds_array::Array{Float64,2}
  flux_bounds_arrray::Array{Float64,2}
  # ...


  function VLDynamicFBAProblem()
    this = new()
  end
end

struct VLStaticSolution<:VLAbstractSolution
  
  objective_value::Float64
  flux::Array{Float64,1}
  exit_flag::Int64
  status_flag::Int64

end

struct VLDynamicSolutionStep<:VLAbstractSolution
end

mutable struct VLDynamicSolution<:VLAbstractSolution

  # initialize -
  solution_object_array::Array{VLDynamicSolutionStep,1}

  function VLDynamicSolution()
    this = new()
  end
end