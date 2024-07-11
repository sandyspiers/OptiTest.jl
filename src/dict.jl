# tools to parse and interperate optittest dictionarys

# parse symbols (removes other entries on the same level!)
function parse_symbols!(dict::AbstractDict)
    for (key, value) in dict
        if key ∈ SYMBOL_NAMES
            return Symbol(value)
        elseif typeof(value) <: AbstractDict
            delete!(dict, key)
            dict[key] = parse_symbols!(value)
        end
    end
    return dict
end

function set_iterates!(dict::AbstractDict, keys, values)::AbstractDict
    for (key, value) in zip(keys, values)
        rec_set!(dict, key[1:(end - 1)], value)
    end
    return dict
end

# iterates everything. the iterate keyword must be last!
function parse_iterates!(dict::AbstractDict)
    iterator_keys = filter(key -> last(key) ∈ ITERATE_NAMES, all_keys(dict))
    iterator_values = (rec_get(dict, key) for key in iterator_keys)
    iterator_prod = product(iterator_values...)
    iterates = (set_iterates!(dict, iterator_keys, vals) for vals in iterator_prod)
    return iterates
end

function parse_experiment!(dict::AbstractDict)
    return (parse_symbols!(iterate) for iterate in parse_iterates!(dict))
end
