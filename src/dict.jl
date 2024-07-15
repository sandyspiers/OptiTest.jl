# tools to parse and interperate optittest dictionarys

# parse symbols (removes other entries on the same level!)
function parse_symbols!(dict::AbstractDict)
    for nested_key in nested_keys(dict)
        if last(nested_key) ∈ SYMBOL_NAMES
            sym = Symbol(nested_get(dict, nested_key))
            nested_set!(dict, all_but_last(nested_key), sym)
        end
    end
    return dict
end

function _ziped_nested_set(dict::AbstractDict, key_val)::AbstractDict
    for (key, val) in key_val
        nested_set!(dict, key, val)
    end
    return dict
end

# iterates everything. the iterate keyword must be last!
function parse_iterates!(dict::AbstractDict)
    # get the nest keys with iterators
    iterator_keys = filter(
        nested_key -> last(nested_key) ∈ ITERATE_NAMES, nested_keys(dict)
    )
    # remove the iterate keyword
    iterated_keys = all_but_last.(iterator_keys)
    # get the iterate lists
    iterator_values = (nested_get(dict, nested_key) for nested_key in iterator_keys)
    # product them
    iterator_prod = product(iterator_values...)
    # update dict
    iterates = (_ziped_nested_set(dict, zip(iterated_keys, vals)) for vals in iterator_prod)
    return iterates
end

function parse_experiment!(dict::AbstractDict)
    return (parse_symbols!(iterate) for iterate in parse_iterates!(dict))
end
