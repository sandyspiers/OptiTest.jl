# OptiTest.jl

[![Build Status](https://github.com/sandyspiers/OptiTest.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sandyspiers/OptiTest.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/sandyspiers/OptiTest.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/sandyspiers/OptiTest.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

A semi-automated toolkit to run large-scale, distributed numerical experiments on your optimisation functions and to analyse the results.
Includes several experiment-level helper functions, settings and setups used to run your tests.
Experiments can be defined using an easy to read and reuse dictionary format.
This allows experiments to be easily run in your Julia REPL, or run as a script on a server.
The results are saved in a standardized format, and several analysis tools are included.
Style guides can be provided to produce semi-automated performance metrics with a standard formatting (such as colouring and labelling).

## Usage

An _experiment_ defines a set of _tests_ which should be conducted.
Each tests is defined fully by a dictionary, for instance:

```julia
test = Dict(
    "generator" => random_knapsack_instance,
    "n" => 100,
    "solver" => :CPLEX
)
```

This test defines a knapsack instance of size 100, which should be solver by CPLEX.
The user must then provide a generic solver function which can be used on dictionaries of this format.
The results should then be appended to this dictionary and returned, for instance:

```julia
function solve!(test::AbstractDict)::AbstractDict
    instance = test["generator"](test["n"])
    solve_time, obj_val = solve_test_instance() # fill this in yourself
    test["solve_time"] = solve_time
    test["obj_val"] = obj_val
    return test
end
```

You can then run this test and get the resultant dataframe by doing

```julia
using OptiTest: run
df = run(test, solve!)
```

Which will return a data farm with 5 columns (generator, n, ..., obj_val) and 1 row (from the one experiment).

### Repeatable Parameters

The key part of this package is the ability to product over certain parameters to run many tests with different parameters.
We achieve this by _producting_ over the dictionary.
By default, this is achieved by suffixing a dictionary key by '!' and making use the element is a vector.
This is then processed to return a dictionary without the '!', and with one of the elements in the vector.
For instance:

```julia
julia> using OptiTest: tests

julia> dict = Dict("x!" => [1, 2, 3]);

julia> tests(dict)
3-element Vector{Dict{Any, Any}}:
 Dict("x" => 1)
 Dict("x" => 2)
 Dict("x" => 3)

julia> dict = Dict("x!" => [1, 2, 3], "y!" => [5, Dict("z!" => [:a, :b])]);

julia> vcat(tests(dict)...)
9-element Vector{Dict{Any, Any}}:
 Dict("x" => 1, "y" => 5)
 Dict("x" => 2, "y" => 5)
 Dict("x" => 3, "y" => 5)
 Dict("x" => 1, "y" => Dict{Any, Any}("z" => :a))
 Dict("x" => 2, "y" => Dict{Any, Any}("z" => :a))
 Dict("x" => 3, "y" => Dict{Any, Any}("z" => :a))
 Dict("x" => 1, "y" => Dict{Any, Any}("z" => :b))
 Dict("x" => 2, "y" => Dict{Any, Any}("z" => :b))
 Dict("x" => 3, "y" => Dict{Any, Any}("z" => :b))

julia> dict = Dict("x!" => 1:3, "y!" => 5:7);

julia> vcat(tests(dict)...)
9-element Vector{Dict{Any, Any}}:
 Dict("x" => 1, "y" => 5)
 Dict("x" => 2, "y" => 5)
 Dict("x" => 3, "y" => 5)
 Dict("x" => 1, "y" => 6)
 Dict("x" => 2, "y" => 6)
 Dict("x" => 3, "y" => 6)
 Dict("x" => 1, "y" => 7)
 Dict("x" => 2, "y" => 7)
 Dict("x" => 3, "y" => 7)

julia> dict = Dict("x!" => Dict("a!" => [1, 2, 3], "b!" => [:a, :b], "seed" => 0), "y!" => 1:2);

julia> vcat(tests(dict)...)
12-element Vector{Dict{Any, Any}}:
 Dict("x" => Dict{Any, Any}("b" => :a, "seed" => 1, "a" => 1), "y" => 1)
 Dict("x" => Dict{Any, Any}("b" => :a, "seed" => 2, "a" => 2), "y" => 1)
 Dict("x" => Dict{Any, Any}("b" => :a, "seed" => 3, "a" => 3), "y" => 1)
 Dict("x" => Dict{Any, Any}("b" => :b, "seed" => 4, "a" => 1), "y" => 1)
 Dict("x" => Dict{Any, Any}("b" => :b, "seed" => 5, "a" => 2), "y" => 1)
 Dict("x" => Dict{Any, Any}("b" => :b, "seed" => 6, "a" => 3), "y" => 1)
 Dict("x" => Dict{Any, Any}("b" => :a, "seed" => 1, "a" => 1), "y" => 2)
 Dict("x" => Dict{Any, Any}("b" => :a, "seed" => 2, "a" => 2), "y" => 2)
 Dict("x" => Dict{Any, Any}("b" => :a, "seed" => 3, "a" => 3), "y" => 2)
 Dict("x" => Dict{Any, Any}("b" => :b, "seed" => 4, "a" => 1), "y" => 2)
 Dict("x" => Dict{Any, Any}("b" => :b, "seed" => 5, "a" => 2), "y" => 2)
 Dict("x" => Dict{Any, Any}("b" => :b, "seed" => 6, "a" => 3), "y" => 2)
```

You may have noticed the special behaviour of the _seed_ key.
This is one of several special keys discussed later.

### Parallel Tests

When the user calls `run(experiment, solver)` the each experiment is run in parallel **by default** using the `Distributed` package.
By default, it will use all avaliable workers.
It is therefore the users responsibility to populate as many or as few workers they need for the experiment.
This may seem annoying, but it allows for warmstarting, precompling, image building (maybe?) and remote workers.

### Post Experiment Analysis

todo

### Special Keywords and Functions

todo

### Suggested Usage

todo
