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


"""
    solve_static_problem()
"""
function solve_static_problem()::VLStaticSolution

    # create a default data dictionary -
    data_dictionary = generate_default_data_dictionary()

    # optional: do we need to change the problem setup to maximize the objective function?
    # is_minimum_flag = update_is_minimum_flag(data_dictionary)
    # data_dictionary["is_minimum_flag"] = is_minimum_flag

    # update the objective coefficient array -
    obj_coeff_array = update_objective_coefficient_array(data_dictionary)
    data_dictionary["objective_coefficient_array"] = obj_coeff_array

    # update the initial state arrary -
    species_concentration_array = update_species_concentration_array(data_dictionary)
    data_dictionary["species_concentration_array"] = species_concentration_array
    
    # update the species bounds array -
    species_bounds_array = update_species_bounds_array(data_dictionary)
    data_dictionary["species_bounds_array"] = species_bounds_array

    # update the flux bounds array -
    flux_bounds_array = update_flux_bounds_array(data_dictionary)
    data_dictionary["flux_bounds_array"] = flux_bounds_array

    # create a problem object (use the factory method in utilities ...)
    problem_object = build_static_fba_problem_object(data_dictionary)

    # solve the problem -
    return solve_simulation_problem(problem_object)
end

# execute -
@info("Start: solving the static flux balance analysis problem ...")
static_soln_object = solve_static_problem();
@info("Stop: calculation completed. The solution is stored in the static_soln_object workspace variable (which is of type VLStaticFBAProblem defined in Types.jl)")