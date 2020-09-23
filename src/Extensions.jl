import Base.+

function +(buffer::Array{String,1},content::String)
    push!(buffer,content)
end

function +(buffer::Array{String,1}, content_array::Array{String,1}; padding::Union{String,Nothing}=nothing)
    for line in content_array
        
        if (padding === nothing)
            push!(buffer, line)
        else
            push!(buffer,"$(padding)$(line)")
        end
    end
end