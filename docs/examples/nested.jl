# A small example usage to see if motivation improves random run times.
using OptiTest: run, plot
using OptiTest: PerformanceProfile
using Distributed: addprocs, rmprocs, workers, @everywhere

# add some workers
rmprocs(workers())
addprocs(2)

# test how speed and motivation levels improve solve times
experiment = Dict(
    "num_tests!" => 1:100,
    "speed!" => [:slow, :medium, :fast],
    "wellbeing!" => [
        Dict("happiness" => :poor, "motivation" => :low),
        Dict("happiness" => :high, "motivation!" => [:low, :high]),
    ],
    "save_results" => false,
)
@everywhere function random_solve_time!(ex::AbstractDict)::AbstractDict
    if ex["speed"] == :slow
        ex["solve_time"] = rand() * 8
    elseif ex["speed"] == :medium
        ex["solve_time"] = rand() * 5
    elseif ex["speed"] == :fast
        ex["solve_time"] = rand() * 3
    else
        ex["solve_time"] = 0
    end
    return ex
end
# run experiment
df = run(experiment, random_solve_time!)

# create style guide
style_guide = Dict(
    (:speed => :fast) => Dict(
        :color => "red", (:wellbeing_happiness => :poor) => Dict(:markershape => :star5)
    ),
    (:speed => :medium) => Dict(:color => "blue"),
    (:speed => :slow) => Dict(:color => "purple"),
    (:wellbeing_motivation => :low) => Dict(:linestyle => :dash),
)

# for each uniqup combo of speed, motivate, plot a performance profile
identifiers = [:speed, :wellbeing_motivation, :wellbeing_happiness]
solve_time = :solve_time
plot(PerformanceProfile(df, identifiers, solve_time); style_guide=style_guide)
