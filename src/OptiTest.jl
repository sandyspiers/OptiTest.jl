module OptiTest

using Base.Iterators: product
using DataFrames: DataFrame
using Distributed: pmap

struct Experiment
    name::String
    generic_solver::Function
    instance_generator::Function
    instance_params::AbstractDict
    solver_params::AbstractDict
end

run(experiment::Experiment) = _run(experiment::Experiment)

include("utils.jl")
include("experiment.jl")

end
