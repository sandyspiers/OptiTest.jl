module OptiTest

import Base.Iterators: product
using DataFrames: DataFrame
using Distributed: pmap

# # generic utility functions, include dictionary producting
include("utils.jl")

# # experimental functions, including special functions and keywords
# # special names and sane defaults
include("experiment.jl")

end
