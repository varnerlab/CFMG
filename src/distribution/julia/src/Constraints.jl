"""
    update_is_minimum_flag(data_dictionary, vargs...)

    Updates where the problem is setup as either a min (is_minimum_flag = true) or max (is_minimum_flag = false)
"""
function update_is_minimum_flag(data_dictionary::Dict{String,Any}, vargs...)::Bool
    @warn("Ooops! You've called an autoegenerated dummy implementation that uses the default problem parameters and setup. Replace this implementation with your code to customize")

    # return the default -
    return true
end

"""
    update_species_bounds_array(data_dictionary, vargs...)

    Update the species bounds array with current state or measurements
"""
function update_species_bounds_array(data_dictionary::Dict{String,Any}, vargs...)::Array{Float64,2}
    @warn("Ooops! You've called an autoegenerated dummy implementation that uses the default problem parameters and setup. Replace this implementation with your code to customize")

    # return the default -
    return data_dictionary["species_bounds_array"]
end

"""
    update_flux_bounds_array(data_dictionary, vargs...)
"""
function update_flux_bounds_array(data_dictionary::Dict{String,Any}, vargs...)::Array{Float64,2}
    @warn("Ooops! You've called an autoegenerated dummy implementation that uses the default problem parameters and setup. Replace this implementation with your code to customize")

    # return the default -
    return data_dictionary["flux_bounds_array"]
end

"""
    update_objective_coefficient_array(data_dictionary, vargs...)
"""
function update_objective_coefficient_array(data_dictionary::Dict{String,Any}, vargs...)::Array{Float64,1}
    @warn("Ooops! You've called an autoegenerated dummy implementation that uses the default problem parameters and setup. Replace this implementation with your code to customize")

    # return the default -
    return data_dictionary["objective_coefficient_array"]
end

"""
    update_species_concentration_array(data_dictionary, vargs...)
"""
function update_species_concentration_array(data_dictionary::Dict{String,Any}, vargs...)::(Union{T, Nothing} where T<:Any)
    @warn("Ooops! You've called an autoegenerated dummy implementation that uses the default problem parameters and setup. Replace this implementation with your code to customize")

    # return the default -
    return data_dictionary["species_concentration_array"]
end