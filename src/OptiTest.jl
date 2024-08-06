module OptiTest

# import Plots: plot, plot!, hline!

using NamedTupleTools: merge, split
using TypedNamedTuples: @TypedNamedTuple, @MutableTypedNamedTuple

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
