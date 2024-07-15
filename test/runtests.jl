using OptiTest: SYMBOL_NAMES, ITERATE_NAMES
using OptiTest: AnyDict
using OptiTest: nested_keys, nested_get, nested_set!
using OptiTest: parse_symbols!, parse_iterates!, parse_experiment!
using Test
using Aqua

include("test_utils.jl")
include("test_dict.jl")

# @testset "Code quality (Aqua.jl)" begin
#     Aqua.test_all(OptiTest)
# end
