module OptiTest

import DataFrames: DataFrame

using Distributed: pmap
using NamedTupleTools: merge, split
using TypedNamedTuples: @MutableTypedNamedTuple, @TypedNamedTuple

# # generic utility functions
include("utils.jl")

# # setup for running experiments
# # including special iterables and sane defaults
include("experiment.jl")

# # the generic semi-abstract procedure for producing plots
# include("ploter.jl")

# # a list of predefined plots and performance profiles
# include("plots.jl")
# const PLOT_TYPES = [PerformanceProfile]

end
