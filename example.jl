using Base: length_continued
using DataFrames
using Plots
import Plots: plot, plot!
using OptiTest: run

# # # Actual code

abstract type PlotData end

struct PerformanceProfile <: PlotData
    max_time::Real
    num_tests::Integer
    labels::Vector{AbstractDict}
    solve_times::Vector{Vector{Real}}
    # some attributes
    function PerformanceProfile(df, identifiers, solve_time)
        max_time = maximum(df[!, solve_time])
        num_tests = 0
        labels = AbstractDict[]
        solve_times = Vector[]
        # for each group
        for g in groupby(df, identifiers)
            # get times and number of tests
            times = sort(g[:, solve_time])
            num_tests = max(num_tests, length(times))
            # sort times
            # add first and last step
            pushfirst!(times, zero(first(times)))
            push!(times, last(times))
            # save time
            push!(solve_times, times)
            # save labels as dictionary
            push!(
                labels,
                Dict(identifier => first(g[!, identifier]) for identifier in identifiers),
            )
        end
        return new(max_time, num_tests, labels, solve_times)
    end
end
function plot!(pp::PerformanceProfile, style_guide::AbstractDict)
    for (label, times) in zip(pp.labels, pp.solve_times)
        steps = vcat(0:(length(times) - 2), length(times) - 1)
        plot!(steps, times; label="$label", seriestype=:steppost)
    end
    return nothing
end

function style_kwargs(plot_data::PlotData)::Dict
    return nothing
end

empty_plot() = plot(1; label=nothing)
function plot(plot_data::PlotData, style_guide::AbstractDict=Dict())
    # create plot...
    p = empty_plot()
    # add plots...
    plot!(plot_data, style_guide)
    # return...
    return p
end

# # # Test
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

pp = PerformanceProfile(df, [:speed, :motivation], :solve_time)
plot(pp)
