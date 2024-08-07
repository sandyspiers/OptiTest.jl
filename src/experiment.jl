# # Experiment
@TypedNamedTuple Experiment

# # Test
@MutableTypedNamedTuple Test
function tests(ex::Experiment)
    return (Test(nt) for nt in _iterate(NamedTuple(ex)))
end

# # Runner
function run(ex::Experiment, solver::Function)
    results = pmap(solver, tests(ex))
    return results
end

# # Iterable
abstract type AbstractIterable end
struct Iterable <: AbstractIterable
    iterate
end
struct FlattenIterable <: AbstractIterable
    iterate
end

# # Special Iterables
struct Seed
    seed::Integer
    seed_ref::Ref{<:Integer}
    Seed(seed) = new(seed, Ref(seed))
end

# # Iterate method
_iterate(any) = any
_iterate(vec::Vector) = vcat(_iterate.(vec)...)
_iterate(iter::AbstractIterable) = _iterate(getfield(iter, :iterate))
function _iterate(nt::NamedTuple)
    iter_pairs = ((k, v) for (k, v) in key_vals(nt) if v isa AbstractIterable)
    if iter_pairs == ()
        return nt
    end

    names, iter = unzip(iter_pairs)
    prods = Iterators.product(_iterate.(iter)...)
    iterates = (merge(nt, NamedTuple(zip(names, prod))) for prod in prods)

    # specials
    seed_fn(k, v) = v isa Seed ? v.seed_ref[] += 1 : v
    iterates = (apply(iter, seed_fn) for iter in iterates)

    flat = (k for (k, v) in iter_pairs if v isa FlattenIterable)
    iterates = (flatten(iter, flat) for iter in iterates)

    return collect(iterates)
end
