# # Takes an iterable of (key,value) and sets each in Dict
function set_pairs!(dict::AbstractDict, key_value_pairs)::AbstractDict
    for (key, value) in key_value_pairs
        dict[key] = value
    end
    return dict
end

# # Turns a dictionary with iterator keywords into a generator of dictionary without them
function iterated_dict!(
    dict::AbstractDict, key_filter::Function, key_update::Function, special_fn=nothing
)
    # get the nest keys that finish with a !
    iter_keys = filter(key_filter, keys(dict))
    # get the iterate lists
    lists = (get(dict, key, nothing) for key in iter_keys)
    # product them
    prod = product(lists...)
    # update keys
    for key in iter_keys
        delete!(dict, key)
    end
    iter_keys = key_update.(iter_keys)
    # update dict
    if isnothing(special_fn)
        return (set_pairs!(dict, zip(iter_keys, vals)) for vals in prod)
    end
    return (special_fn(set_pairs!(dict, zip(iter_keys, vals))) for vals in prod)
end

# # fakes a vector if it is not already one
function vectorize(maybe_vector)::Vector
    return typeof(maybe_vector) <: AbstractVecOrMat ? maybe_vector : [maybe_vector]
end

# # flatten a nested dictionary
function flatten(dict::AbstractDict, delim::String="::")::AbstractDict
    d = empty(dict)
    for (key, val) in dict
        if typeof(val) <: AbstractDict
            for (k, v) in flatten(val, delim)
                d[key * delim * k] = v
            end
        else
            d[key] = val
        end
    end
    return d
end
