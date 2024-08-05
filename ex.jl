# # Iterable
struct Iterable
    iterate
end
struct BlindIterable
    iterate
end

# # Experiment
struct Experiment{N,T<:Tuple{Vararg{Any}}}
    nt::NamedTuple{N,T}
end
Experiment(; kwargs...) = Experiment(NamedTuple{keys(kwargs)}(values(kwargs)))
Experiment{names}(tuple::Tuple) where {names} = Experiment(NamedTuple{names}(tuple))
Base.getproperty(ex::Experiment, sym::Symbol) = getfield(getfield(ex, :nt), sym)
Base.keys(::Experiment{names}) where {names} = names
Base.values(ex::Experiment) = values(getfield(ex, :nt))
Base.NamedTuple(ex::Experiment) = NamedTuple{keys(ex)}(values(ex))
Base.Tuple(ex::Experiment) = values(ex)
Base.show(io::IO, ex::Experiment) = print(io, "Experiment", NamedTuple(ex))
Base.iterate(ex::Experiment) = iterate(zip(keys(ex), values(ex)))
Base.iterate(ex::Experiment, state) = iterate(zip(keys(ex), values(ex)), state)
iterators(ex::Experiment) = ((k, v) for (k, v) in ex if v isa Iterable)

# # Test
struct Test
    _ex::Ref{<:Experiment}
    _iterates::NamedTuple
    # make this a hidden mutable that users can iteract with
    _res::Dict{Symbol,Any}
end
Test(ex::Ref{<:Experiment}, iterates) = Test(ex, NamedTuple(iterates), Dict{Symbol,Any}())
Test(ex::Experiment, iterates) = Test(Ref(ex), iterates)
Test(ex) = Test(ex, NamedTuple())
function Base.getproperty(test::Test, sym::Symbol)
    if sym in keys(getfield(test, :_res))
        return get(getfield(test, :_res), sym, nothing)
    end
    val = getproperty(getfield(test, :_ex)[], sym)
    if val isa Iterable && sym in keys(getfield(test, :_iterates))
        return get(getfield(test, :_iterates), sym, nothing)
    end
    return val
end
Base.setproperty!(test::Test, sym::Symbol, val) = getfield(test, :_res)[sym] = val
function Base.keys(test::Test)
    return (keys(getfield(test, :_ex)[])..., keys(getfield(test, :_res))...)
end
Base.values(test::Test) = Tuple(getproperty(test, k) for k in keys(test))
Base.NamedTuple(test::Test) = NamedTuple{keys(test)}(values(test))
Base.Tuple(test::Test) = values(test)
Base.show(io::IO, test::Test) = print(io, "Test", NamedTuple(test))

# # Iterator
function tests_in(ex::Experiment)
    iters = iterators(ex)
    keys = first.(iters)
    prods = Iterators.product(getfield.(last.(iters), :iterate)...)
    return [Test(ex, (k => p for (k, p) in zip(keys, prod))) for prod in prods]
end

ex = Experiment(;#
    x=Iterable([1, 2]),
    y=Iterable(5:8),
    z=100,
    a=BlindIterable([#
        (solver=:cplex, aggression=Iterable([:little, :lot])),
        (solver = :gurobi),
    ]),
)
test = tests_in(ex)
for t in test
    t.solve_time = rand()
end
println(test)
