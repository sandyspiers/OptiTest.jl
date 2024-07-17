# # Takes an iterable of (key,value) and sets each in Dict
function set!(dict::AbstractDict, key, val)
    dict[key] = val
    return dict
end
function set!(dict::AbstractDict, keys::AbstractVector, vals::AbstractVector)::AbstractDict
    for (key, val) in zip(keys, vals)
        dict[key] = val
    end
    return dict
end
function set!(
    dict::AbstractDict, old_keys::AbstractVector, new_keys::AbstractVector, vals
)::AbstractDict
    for (old, new, val) in zip(old_keys, new_keys, vals)
        delete!(dict, old)
        dict[new] = val
    end
    return dict
end

# # flatten a nested dictionary
function flatten(dict::AbstractDict, delim::String="_")::AbstractDict
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

# # make a dictionary into an any dictionary
function make_any_dict(dict::AbstractDict)::Dict{Any,Any}
    any_dict = Dict{Any,Any}()
    for (key, val) in dict
        any_dict[key] = make_any_dict(val)
    end
    return any_dict
end
make_any_dict(vec::AbstractVecOrMat) = [make_any_dict(v) for v in vec]
make_any_dict(any) = any

# # Turns a dictionary with iterator keywords into a generator of dictionary without them
product_dict(dict::AbstractDict; kwargs...) = last(_product(make_any_dict(dict); kwargs...))
function _product(
    dict::AbstractDict; key_filter::Function=k -> false, key_update::Function=k -> k
)::Tuple{Bool,Any}
    old_keys = Any[]
    new_keys = Any[]
    iterates = Any[]
    for (key, val) in dict
        iterable, sub_iterates = _product(val; key_filter=key_filter, key_update=key_update)
        if iterable || key_filter(key)
            push!(old_keys, key)
            push!(new_keys, key_filter(key) ? key_update(key) : key)
            sub_iterates =
                isa(sub_iterates, AbstractVecOrMat) ? vcat(sub_iterates...) : sub_iterates
            push!(iterates, sub_iterates)
        end
    end
    if !isempty(iterates)
        return true,
        [set!(deepcopy(dict), old_keys, new_keys, val) for val in product(iterates...)]
    end
    return false, dict
end
function _product(vec::AbstractVecOrMat; kwargs...)::Tuple{Bool,Any}
    sub_iterables = [_product(val; kwargs...) for val in vec]
    return any(first.(sub_iterables)), last.(sub_iterables)
end
function _product(any; _...)::Tuple{Bool,Any}
    return false, any
end
