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

# includes -
include("Include.jl")

function update_species_bounds_array(time_value::Float64, time_index::Int64, data_dictionary::Dict{String,Any}, vargs...)::Array{Float64,2}
    error("Ooops! You've call an autoegenerated dummy implementation. Please implement the update_species_bounds_array function before executing this file!")
end

function update_flux_bounds_array(time_value::Float64, time_index::Int64, data_dictionary::Dict{String,Any}, vargs...)::Array{Float64,2}
    error("Ooops! You've call an autoegenerated dummy implementation. Please implement the update_flux_bounds_array function before executing this file!")
end

function update_objective_coefficient_array(time_value::Float64, time_index::Int64, data_dictionary::Dict{String,Any}, vargs...)::Array{Float64,1}
    error("Ooops! You've call an autoegenerated dummy implementation. Please implement the update_objective_coefficient_array function before executing this file!")
end

function update_species_concentration_array(time_value::Float64, time_index::Int64, data_dictionary::Dict{String,Any}, vargs...)::Array{Float64,1}
    error("Ooops! You've call an autoegenerated dummy implementation. Please implement the update_species_concentration_array function before executing this file!")
end

function solve_dynamic_problem(time_array::Array{Float64,1})::VLDynamicSolution

    # initialize -
    tmp_results_array = Array{VLDynamicSolutionStep,1}() 

    # create a default data dictionary -
    data_dictionary = generate_default_data_dictionary()

    # create an empty problem object -
    dynamic_problem_object = build_dynamic_fba_problem_object(data_dictionary)

    # main run loop -
    simulation_time_array = reverse(time_array)
    simulation_index_counter = 1
    while (isempty(simulation_time_array) == false)
        
        # pop the time -
        time_value = pop!(simulation_time_array)
        
        # update the problem components for the current time -
        # ...

        # solve -
        step_solution = solve_simulation_problem(dynamic_problem_object)

        # check - is this solution ok?
        # ...

        # capture the solution -
        push!(tmp_results_array, step_solution)

        # update the simulation_index_counter -
        simulation_index_counter += 1
    end

    # build the solution -
    dynamic_soln_object = VLDynamicSolution()
    dynamic_soln_object.solution_object_array = tmp_results_array

    # solve the problem -
    return dynamic_soln_object
end

# execute -
dynamic_soln_object = solve_dynamic_problem()