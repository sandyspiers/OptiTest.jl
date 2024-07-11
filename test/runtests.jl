using OptiTest: SYMBOL_NAMES, ITERATE_NAMES
using OptiTest: all_keys, flatten
using OptiTest: parse_symbols, parse_iterates, parse_experiment
using Base: isapprox
using Test
using Aqua

function isapprox(x::AbstractDict, y::AbstractDict)::Bool
    kx = Set(keys(x))
    ky = Set(keys(y))
    if kx != ky
        return false
    end
    for k in kx
        if x[k] != y[k]
            return false
        end
    end
    return true
end

include("test_utils.jl")
include("test_dict.jl")

# @testset "Code quality (Aqua.jl)" begin
#     Aqua.test_all(OptiTest)
# end
