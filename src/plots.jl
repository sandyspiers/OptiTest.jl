struct PerformanceProfile <: PlotData
    max_time::Real
    num_tests::Integer
    identifiers::Vector{Vector{Pair}}
    solve_times::Vector{Vector{Real}}
    # some attributes
    function PerformanceProfile(df, identifiers, solve_time)
        max_time = maximum(df[!, solve_time])
        num_tests = 0
        labels = Vector[]
        solve_times = Vector[]
        # for each group
        for g in groupby(df, identifiers)
            # get sorted times and number of tests
            times = sort(g[:, solve_time])
            num_tests = max(num_tests, length(times))
            # add first and last step
            pushfirst!(times, zero(first(times)))
            push!(times, last(times))
            # save time
            push!(solve_times, times)
            # save labels as vector of pairs
            push!(
                labels,
                [(identifier => first(g[!, identifier])) for identifier in identifiers],
            )
        end
        return new(max_time, num_tests, labels, solve_times)
    end
end
function plot!(pp::PerformanceProfile, style_guide::AbstractDict)
    for (label, times) in zip(pp.identifiers, pp.solve_times)
        steps = vcat(0:(length(times) - 2), length(times) - 1)
        plot!(steps, times; seriestype=:steppost, style_kwargs(label, style_guide)...)
    end
    return nothing
end
