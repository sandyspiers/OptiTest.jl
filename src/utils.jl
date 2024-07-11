# helper function to get all keys in a multilevel dict
function all_keys(dict::AbstractDict)::Set{String}
    return Set(_all_keys(dict, String[]))
end

function _all_keys(dict::AbstractDict, keys::Vector{String})::Vector{String}
    for (key, value) in dict
        if typeof(value) <: AbstractDict
            for key in all_keys(value)
                push!(keys, key)
            end
        end
        push!(keys, key)
    end
    return keys
end

# flattens a dictionary into a dictionary with tuple keys
function flatten(dict::AbstractDict; root=true)::AbstractDict
    flattened = Dict()
    for (key, value) in dict
        if typeof(value) <: AbstractDict
            for (k, v) in flatten(value; root=false)
                flattened[(key, k...)] = v
            end
        else
            if root
                flattened[(key)] = value
            else
                flattened[(key,)] = value
            end
        end
    end
    return flattened
end
