module OptiTest

import Plots: plot, plot!, hline!

using Base.Iterators: product
using CSV: write
using DataFrames: DataFrame, groupby
using Dates: format, now
using Distributed: pmap, @everywhere
using JSON: print
using ProgressMeter: @showprogress
using Pkg: installed

# # generic utility functions, include dictionary producting
include("utils.jl")

# # experimental functions, including special functions and keywords
# # special names and sane defaults
include("experiment.jl")

# # the generic semi-abstract procedure for producing plots
include("ploter.jl")

# # a list of predefined plots and performance profiles
include("plots.jl")
const PLOT_TYPES = [PerformanceProfile]

end
