# # Utils
function _copy_overwrite_flatten(nt::NamedTuple, keys, values, flatten)
    return _copy_overwrite_flatten(nt, NamedTuple(zip(keys, values)), flatten)
end
function _copy_overwrite_flatten(nt::NamedTuple, overwrite::NamedTuple, flatten)
    _nt = Tuple{Symbol,Any}[]
    for key in keys(nt)
        if key in flatten && key in keys(overwrite)
            sub_nt = getfield(overwrite, key)
            push!(_nt, ((_key, getfield(sub_nt, _key)) for _key in keys(sub_nt))...)
        else
            if key in keys(overwrite)
                push!(_nt, (key, getfield(overwrite, key)))
            else
                push!(_nt, (key, getfield(nt, key)))
            end
        end
    end
    return NamedTuple(_nt)
end

# # Iterable
# # There is an abstract Iterator supertype, each other can do something different
# # Then, given a named tuple it will iterate over it all
abstract type AbstractIterable end
struct Iterable <: AbstractIterable
    iterate
end
struct BlindIterable <: AbstractIterable
    iterate
end
_iterate(any) = [any]
_iterate(rng::AbstractRange) = rng
_iterate(iter::AbstractIterable) = _iterate(getfield(iter, :iterate))
_iterate(nt::Vector) = collect(Iterators.flatten(_iterate.(nt)))
function _iterate(nt::NamedTuple)
    iterators = ((k, v) for (k, v) in zip(keys(nt), values(nt)) if v isa AbstractIterable)
    blinds = (k for (k, v) in iterators if v isa BlindIterable)
    names = first.(iterators)
    prods = Iterators.product(_iterate.(last.(iterators))...)
    return [_copy_overwrite_flatten(nt, names, prod, blinds) for prod in prods]
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

# # Iterator
function tests_in(ex::Experiment)
    return [Test(nt) for nt in _iterate(NamedTuple(ex))]
end

ex = Experiment(;#
    x=Iterable([1, 2, Iterable(100:101)]),
    y=Iterable(5:8),
    z=100,
    backend=BlindIterable([#
        (solver=:cplex, aggression=Iterable([:little, :lot])),
        (solver=:gurobi, aggresssion=nothing),
    ]),
)
test = tests_in(ex)
for t in test
    t.solve_time = rand()
end
map(println, test)
