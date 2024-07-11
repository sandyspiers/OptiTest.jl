# tools to parse and interperate optittest dictionarys

function parse_symbols(dict::AbstractDict)
    new_dict = Dict()
    for (key, value) in dict
        if key ∈ SYMBOL_NAMES
            return Symbol(value)
        elseif typeof(value) <: AbstractDict
            new_dict[key] = parse_symbols(value)
        else
            new_dict[key] = value
        end
    end
    return new_dict
end

function parse_iterates(dict::AbstractDict)#::Vector{AbstractDict}
    listed = AbstractDict[]
    while !isdisjoint(all_keys(dict), ITERATE_NAMES)
    end
    # for (key, value) in dict
    #     if key ∈ ITERATE_NAMES
    #         return value
    #     end
    # end
end

function parse_experiment(dict::AbstractDict)::Vector{AbstractDict}
    return []
end
