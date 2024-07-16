# some sane defaults
key_filter(key) = last(key) == '!'
key_update(key) = key[1:(end - 1)]
function update_seed(dict)
    if "seed" ∈ keys(dict)
        dict["seed"] += 1
    end
    return dict
end

function tests!(experiment::Experiment)
    return (
        experiment for _ in product(
            iterated_dict!(experiment.solver_params, key_filter, key_update),
            iterated_dict!(experiment.instance_params, key_filter, key_update, update_seed),
        )
    )
end

function tests(experiment::Experiment)
    return map(deepcopy, tests!(deepcopy(experiment)))
end

function _run(experiment::Experiment)::DataFrame
    tsts = tests(experiment)
    results = pmap(experiment.generic_solver, tsts)
    all = (
        Dict(
            "instance" => test.instance_params,
            "solver" => test.solver_params,
            "result" => res,
        ) for (test, res) in zip(tsts, results)
    )
    return DataFrame(vcat(flatten.(all)...))
end
