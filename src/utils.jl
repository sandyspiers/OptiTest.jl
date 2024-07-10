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
