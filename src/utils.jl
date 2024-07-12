# # helper function to get all keys in a multilevel dict
function all_keys(dict, key_list=Tuple[], parent_key=())::Vector{Tuple}
    if typeof(dict) <: AbstractDict
        for (key, sub_dict) in dict
            all_keys(sub_dict, key_list, (parent_key..., key))
        end
    else
        push!(key_list, parent_key)
    end
    return key_list
end

function rec_set!(dict::AbstractDict, key, val)::AbstractDict
    if key ∈ keys(dict)
        dict[key] = val
    elseif typeof(key) <: Tuple
        if first(key) ∈ keys(dict)
            sub_dict = dict[first(key)]
            if (typeof(sub_dict) <: AbstractDict) & (length(key) > 1)
                rec_set!(sub_dict, key[2:end], val)
            else
                dict[first(key)] = val
            end
        end
    end
    return dict
end

function rec_get(dict::AbstractDict, key, fallback=nothing)
    if typeof(key) <: Tuple
        if first(key) ∈ keys(dict)
            sub_dict = dict[first(key)]
            if typeof(sub_dict) <: AbstractDict
                return rec_get(sub_dict, key[2:end], fallback)
            else
                return sub_dict
            end
        end
    end
    return get(dict, key, fallback)
end
