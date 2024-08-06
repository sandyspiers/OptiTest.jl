"""
Named Tuple Utilities
"""

# Overloaders
Base.iterate(nt::NamedTuple) = iterate(zip(keys(nt), values(nt)))
Base.iterate(nt::NamedTuple, state) = iterate(zip(keys(nt), values(nt)), state)

# Copy and overwrite
function _copy_overwrite(nt::NamedTuple, keys, values)::NamedTuple
    return _copy_overwrite(nt, NamedTuple(zip(keys, values)))
end
# Copy and overwrite
function _copy_overwrite(nt::NamedTuple, overwrite::NamedTuple)::NamedTuple
    return NamedTuple((
        k => k ∈ keys(overwrite) ? getfield(overwrite, k) : getfield(nt, k) for
        k in keys(nt)
    ))
end
# Copy and flatten keys
function _copy_flatten(nt::NamedTuple, flatten_keys)::NamedTuple
    _nt = Tuple{Symbol,Any}[]
    for key in keys(nt)
        if key in flatten_keys && getfield(nt, key) isa NamedTuple
            sub_nt = getfield(nt, key)
            push!(_nt, ((_key, getfield(sub_nt, _key)) for _key in keys(sub_nt))...)
        else
            push!(_nt, (key, getfield(nt, key)))
        end
    end
    return NamedTuple(_nt)
end
# copy and apply function
function _copy_apply(nt::NamedTuple, fn::Function)::NamedTuple
    return NamedTuple((k => fn(k, v) for (k, v) in nt))
end

# Tuple Structs
# # assume _nt is the masker tuple property and _mut is an additional mutable component
abstract type MaskedNamedTuple end
function _nt(mnt::MaskedNamedTuple)
    if hasfield(mnt, :_nt)
        if getfield(mnt, :_nt) isa NamedTuple
            return getfield(mnt, :_nt)
        end
    end
    return nothing
end
function _mut(mnt::MaskedNamedTuple)
    if hasfield(mnt, :_mut)
        _mut = getfield(mnt, :_mut)
        if getfield(mnt, :_mut) isa AbstractDict
            return _mut
        end
    end
    return nothing
end
function Base.getproperty(mnt::MaskedNamedTuple, sym::Symbol)
    _mut = _mut(mnt)
    if !isnothing(_mut) && haskey(_mut, sym)
        return get(_mut, sym, nothing)
    end
    _nt = _nt(mnt)
    if !isnothing(_nt) && hasfield(_nt, sym)
        return getfield(_nt, sym)
    end
    throw("type $(typeof(mnt)) has no field $sym")
end
function Base.setproperty!(mnt::MaskedNamedTuple, sym::Symbol, val)
    _mut = _mut(mnt)
    if !isnothing(_mut)
        return _mut[sym] = val
    end
    throw("type $(typeof(mnt)) is not mutable")
end
function Base.keys(mnt::MaskedNamedTuple)
    _nt, _mut = _nt(mnt), _mut(mnt)
    _nt = isnothing(_nt) ? () : _nt
    _mut = isnothing(_mut) ? () : _mut
    return (_nt..., _mut...)
end
function Base.values(mnt::MaskedNamedTuple)
    _nt, _mut = _nt(mnt), _mut(mnt)
    _nt = isnothing(_nt) ? () : values(_nt)
    _mut = isnothing(_mut) ? () : values(_mut)
    return (_nt..., _mut...)
end
Base.Tuple(mnt::MaskedNamedTuple) = values(mnt)
Base.NamedTuple(mnt::MaskedNamedTuple) = NamedTuple(zip(keys(mnt), values(mnt)))
Base.iterate(mnt::MaskedNamedTuple) = iterate(zip(keys(mnt), values(mnt)))
Base.iterate(mnt::MaskedNamedTuple, state) = iterate(zip(keys(mnt), values(mnt)), state)
Base.show(io::IO, mnt::MaskedNamedTuple) = print(io, typeof(mnt), NamedTuple(mnt))
