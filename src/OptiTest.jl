module OptiTest

using Base.Iterators: product

using Distributed: pmap

struct Experiment
    name::String
    generic_solver::Function
    instance_generator::Function
    instance_params::Union{Vector{AbstractDict},AbstractDict}
    solver_params::Union{Vector{AbstractDict},AbstractDict}
end

function run(experiment::Experiment)
    return pmap(experiment.generic_solver, tests(experiment))
end

include("utils.jl")
include("experiment.jl")

end
