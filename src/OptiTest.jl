module OptiTest

import DataFrames: DataFrame
import Plots: plot, plot!

using DataFrames: groupby
using Distributed: pmap
using NamedTupleTools: merge, split
using Plots: hline!
using TypedNamedTuples: @MutableTypedNamedTuple, @TypedNamedTuple

export Experiment, TestRun, Iterable, FlattenIterable, Seed, DataFrame
export run, plot, plot!
export PerformanceProfile

# # generic utility functions
include("utils.jl")

# # setup for running experiments
# # including special iterables and sane defaults
include("experiment.jl")

# # a list of predefined plots and performance profiles
include("plots.jl")
const PLOT_TYPES = [PerformanceProfile]

end
