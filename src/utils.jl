# helper function to get all keys in a multilevel dict
function all_keys(dict::AbstractDict, parent_key::Tuple=())::Set{Tuple}
    key_list = Set(Tuple[])
    for (key, value) in dict
        if typeof(value) <: AbstractDict
            for key in all_keys(value, (parent_key..., key))
                push!(key_list, key)
            end
        else
            push!(key_list, (parent_key..., key))
        end
    end
    return key_list
end

function rec_get(dict::AbstractDict, key, fallback=nothing)
    if typeof(key) <: Tuple
        if first(key) ∈ keys(dict)
            val = dict[first(key)]
            if typeof(val) <: AbstractDict
                return rec_get(val, key[2:end], fallback)
            else
                return val
            end
        end
    end
    return get(dict, key, fallback)
end
