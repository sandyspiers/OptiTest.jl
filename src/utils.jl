function set_pairs!(dict::AbstractDict, key_value_pairs)
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
function vectorize(maybe_vector)
    return typeof(maybe_vector) <: AbstractVecOrMat ? maybe_vector : [maybe_vector]
end
