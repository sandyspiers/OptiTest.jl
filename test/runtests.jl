# using Distributed: addprocs, myid, @everywhere, rmprocs, workers
# using DataFrames: nrow
# using OptiTest: set!, flatten, make_any_dict, product_dict
# using OptiTest: run
# using OptiTest: PLOT_TYPES, plot, style_kwargs
using OptiTest: Experiment, Iterable, FlattenIterable, Seed
using OptiTest: tests, _iterate
using Test

include("test_experiment.jl")
# include("test_plots.jl")
# include("test_examples.jl")
