using Distributed: addprocs, myid, @everywhere, rmprocs, workers
using OptiTest: OptiTest, Experiment
using OptiTest: iterated_dict!
using OptiTest: tests!, tests, run
using Test

include("test_utils.jl")
include("test_experiment.jl")
include("test_distributed.jl")
