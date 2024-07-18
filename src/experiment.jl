# # some sane defaults
key_filter(key) = last(key) == '!'
key_update(key) = key[1:(end - 1)]
function update_seed(dict)
    if "seed" ∈ keys(dict)
        dict["seed"] += 1
    end
    return dict
end

function tests(experiment_dict::AbstractDict)
    return product_dict(experiment_dict; key_filter=key_filter, key_update=key_update)
end

function run(experiment::AbstractDict, solver::Function)::DataFrame
    results = pmap(solver, tests(experiment))
    df = vcat(DataFrame.(results)...)
    return df
end
