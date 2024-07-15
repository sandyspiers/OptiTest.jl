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
