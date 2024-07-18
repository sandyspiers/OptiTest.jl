module OptiTest

using Base.Iterators: product
using CSV: write
using DataFrames: DataFrame
using Dates: format, now
using Distributed: pmap
using JSON: print

# # generic utility functions, include dictionary producting
include("utils.jl")

# # experimental functions, including special functions and keywords
# # special names and sane defaults
include("experiment.jl")

end
