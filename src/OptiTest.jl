module OptiTest

import Plots: plot, plot!, hline!

# # generic utility functions, include dictionary producting
include("utils.jl")

# # special struct stype
include("masked_named_tuple.jl")

# # experimental functions, including special functions and keywords
# # special names and sane defaults
include("experiment.jl")

# # the generic semi-abstract procedure for producing plots
# include("ploter.jl")

# # a list of predefined plots and performance profiles
# include("plots.jl")
# const PLOT_TYPES = [PerformanceProfile]

end
