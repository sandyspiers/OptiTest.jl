using DataFrames
using OptiTest: run

struct PerformanceProfile
    labels::AbstractDict
    times::AbstractVecOrMat
end

mutable struct PerformanceProfileData
    max_time::Real
    num_tests::Real
    profiles::Vector{PerformanceProfile}
end

function random_solve_time(dict)
    if dict["speed"] == :slow
        dict["solve_time"] = rand() * 8
    elseif dict["speed"] == :medium
        dict["solve_time"] = rand() * 5
    elseif dict["speed"] == :fast
        dict["solve_time"] = rand() * 3
    else
        dict["solve_time"] = 0
    end
    return dict
end

experiment = Dict(
    "test!" => 1:100, "speed!" => [:slow, :medium, :fast], "motivation!" => [:low, :high]
)

df = run(experiment, random_solve_time)

solve_time = :solve_time
parameters = [:speed, :motivation]

ppd = Dict{Any,Any}()
ppd["max_time"] = maximum(df[!, solve_time])
ppd["max_tests"] = 0

for g in groupby(df, parameters)
    # get times and number of tests
    times = g[:, solve_time]
    ppd["max_tests"] = max(ppd["max_tests"], length(times))
    # add first and last step
    pushfirst!(times, zero(first(times)))
    push!(times, last(times))
    # println(g)
    println([(p => first(g[!, p])) for p in parameters], times)
    println(Dict("times" => times, ((p => first(g[!, p])) for p in parameters)...))
end
