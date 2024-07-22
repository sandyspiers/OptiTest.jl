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
            push!(times, max_time)
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
        steps = vcat(0:(length(times) - 2), length(times) - 2)
        sg = style_kwargs(label, style_guide)
        sg[:label] = get(sg, :label, "$(last.(label))")
        plot!(times, steps; seriestype=:steppost, sg...)
    end
    # add max test line
    hline!(
        [pp.num_tests];
        color=:grey,
        linestyle=:dot,
        title="Performance Profile",
        ylabel="Num Tests Solved",
        xlabel="Solve Time",
        ylims=(0, pp.num_tests * 1.025),
        xlims=(0, pp.max_time),
        label=nothing,
    )
    return nothing
end
