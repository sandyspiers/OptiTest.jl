using Distributed: addprocs, myid, @everywhere, rmprocs, workers
using OptiTest: OptiTest, Experiment
using OptiTest: iterated_dict!
using OptiTest: tests!, tests, run
using Test
using Aqua

include("test_utils.jl")
include("test_experiment.jl")
include("test_distributed.jl")

# @testset "Code quality (Aqua.jl)" begin
#     Aqua.test_all(OptiTest)
# end
