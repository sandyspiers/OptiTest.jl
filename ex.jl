# # Utils
function _copy_overwrite(nt::NamedTuple, keys, values)::NamedTuple
    return _copy_overwrite(nt, NamedTuple(zip(keys, values)))
end
function _copy_overwrite(nt::NamedTuple, overwrite::NamedTuple)::NamedTuple
    return NamedTuple((
        k => k ∈ keys(overwrite) ? getfield(overwrite, k) : getfield(nt, k) for
        k in keys(nt)
    ))
end
function _copy_flatten(nt::NamedTuple, flatten)::NamedTuple
    _nt = Tuple{Symbol,Any}[]
    for key in keys(nt)
        if key in flatten && getfield(nt, key) isa NamedTuple
            sub_nt = getfield(nt, key)
            push!(_nt, ((_key, getfield(sub_nt, _key)) for _key in keys(sub_nt))...)
        else
            push!(_nt, (key, getfield(nt, key)))
        end
    end
    return NamedTuple(_nt)
end
function _copy_apply(nt::NamedTuple, fn::Function)::NamedTuple
    return NamedTuple((k => fn(k, v) for (k, v) in zip(keys(nt), values(nt))))
end

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
struct Experiment{N,T<:Tuple{Vararg{Any}}}
    _nt::NamedTuple{N,T}
end
Experiment(; kwargs...) = Experiment(NamedTuple{keys(kwargs)}(values(kwargs)))
Experiment{names}(tuple::Tuple) where {names} = Experiment(NamedTuple{names}(tuple))
Base.getproperty(ex::Experiment, sym::Symbol) = getfield(getfield(ex, :_nt), sym)
Base.keys(::Experiment{names}) where {names} = names
Base.values(ex::Experiment) = values(getfield(ex, :_nt))
Base.NamedTuple(ex::Experiment) = NamedTuple{keys(ex)}(values(ex))
Base.Tuple(ex::Experiment) = values(ex)
Base.show(io::IO, ex::Experiment) = print(io, "Experiment", NamedTuple(ex))
Base.iterate(ex::Experiment) = iterate(zip(keys(ex), values(ex)))
Base.iterate(ex::Experiment, state) = iterate(zip(keys(ex), values(ex)), state)

# # Test
struct Test
    # this is all the information
    _nt::NamedTuple
    # make this a hidden mutable that users can iteract with
    _res::Dict{Symbol,Any}
end
Test(nt::NamedTuple) = Test(nt, Dict{Symbol,Any}())
function Base.getproperty(test::Test, sym::Symbol)
    if sym in keys(getfield(test, :_res))
        return get(getfield(test, :_res), sym, nothing)
    end
    return getproperty(getfield(test, :_nt), sym)
end
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

# # Iterator
function tests_in(ex::Experiment)
    return [Test(nt) for nt in _iterate(NamedTuple(ex))]
end

ex = Experiment(;#
    instances=FlattenIterable((#
        x=Iterable([1, Iterable(100:101)]),
        y=Iterable(5:6),
        z=100,
        s=Seed(0),
    )),
    backend=FlattenIterable([#
        (solver=:cplex, aggression=Iterable([:little, :lot])),
        (solver=:gurobi, aggresssion=nothing),
    ]),
)
test = tests_in(ex)
for t in test
    t.solve_time = rand()
end
map(println, test)
