using Distributed: addprocs, myid, @everywhere, rmprocs, workers
using DataFrames: DataFrame, nrow
using OptiTest: Experiment, Iterable, FlattenIterable, Seed, DataFrame
using OptiTest: tests, run, _iterate
using OptiTest: style
using OptiTest: plot, PerformanceProfile, PLOT_TYPES
using Plots: Plot
using Test

# include("test_experiment.jl")
include("test_plots.jl")
# include("test_examples.jl")
