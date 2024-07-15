module OptiTest

using Base.Iterators: product

const SYMBOL_NAMES = ["symbol", "eval"]
const ITERATE_NAMES = ["iterate", "repeat"]
const AnyDict = Dict{Any,Any}

include("utils.jl")
include("dict.jl")

end
