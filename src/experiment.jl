# # Iterable
# # There is an abstract Iterator supertype, each other can do something different
# # Then, given a named tuple it will iterate over it all
abstract type AbstractIterable end
struct Iterable <: AbstractIterable
    iterate
end
struct FlattenIterable <: AbstractIterable
    iterate
end
struct Seed
    seed::Integer
    seed_ref::Ref{<:Integer}
    Seed(seed) = new(seed, Ref(seed))
end
_iterate(any) = any
_iterate(iter::AbstractIterable) = _iterate(getfield(iter, :iterate))
_iterate(nt::Vector) = vcat(_iterate.(nt)...)
function _iterate(nt::NamedTuple)
    iterator_pairs = (
        (k, v) for (k, v) in zip(keys(nt), values(nt)) if v isa AbstractIterable
    )
    if iterator_pairs == ()
        return nt
    end
    names, iterates = (first.(iterator_pairs), last.(iterator_pairs))
    prods = Iterators.product(_iterate.(iterates)...)
    iterates = (_copy_overwrite(nt, names, prod) for prod in prods)

    # specials
    seed_fn(k, v) = v isa Seed ? v.seed_ref[] += 1 : v
    iterates = (_copy_apply(iter, seed_fn) for iter in iterates)

    flatten = (k for (k, v) in iterator_pairs if v isa FlattenIterable)
    iterates = (_copy_flatten(iter, flatten) for iter in iterates)

    return collect(iterates)
end

# # Experiment
# TODO can I macro this?
struct Experiment <: MaskedNamedTuple
    _nt::NamedTuple
    _mut::Dict{Symbol,Any}
end
Experiment(; kwargs...) = Experiment(NamedTuple{keys(kwargs)}(values(kwargs)))
Experiment{names}(tuple::Tuple) where {names} = Experiment(NamedTuple{names}(tuple))

# # Test
struct Test <: MaskedNamedTuple
    _nt::NamedTuple
    _mut::Dict{Symbol,Any}
end
Test(nt::NamedTuple) = Test(nt, Dict{Symbol,Any}())
Base.setproperty!(test::Test, sym::Symbol, val) = getfield(test, :_res)[sym] = val
function Base.keys(test::Test)
    return (keys(getfield(test, :_nt))..., keys(getfield(test, :_res))...)
end
Base.values(test::Test) = Tuple(getproperty(test, k) for k in keys(test))
Base.NamedTuple(test::Test) = NamedTuple{keys(test)}(values(test))
Base.Tuple(test::Test) = values(test)
Base.show(io::IO, test::Test) = print(io, "Test", NamedTuple(test))
function safe_get(test::Test, key)
    try
        return getproperty(test, key)
    catch
        return nothing
    end
end
function comma_line(test::Test)
    return reduce(
        (ln, key) -> ln * string(safe_get(test, key)) * ", ", keys(test); init=""
    )[1:(end - 2)]
end
