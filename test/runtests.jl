using Distributed: addprocs, myid, @everywhere, rmprocs, workers
using DataFrames: DataFrame, nrow
using OptiTest: Experiment, Iterable, FlattenIterable, Seed, DataFrame
using OptiTest: tests, run, _iterate
# using OptiTest: PLOT_TYPES, plot, style_kwargs
using Test

include("test_experiment.jl")
# include("test_plots.jl")
# include("test_examples.jl")
