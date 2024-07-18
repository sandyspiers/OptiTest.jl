# # some sane defaults
key!(key) = last(key) == '!'
rm!(key) = key[1:(end - 1)]
function update_seed(dict)
    if "seed" ∈ keys(dict)
        dict["seed"] += 1
    end
    return dict
end
name(ex) = get(ex, "name", "optitest_" * format(now(), "yyyy-mm-dd:HM"))
dir(ex) = get(ex, "dir", pwd())
save_setup(ex) = get(ex, "save_setup", false)
save_log(ex) = get(ex, "save_log", false)
save_results(ex) = get(ex, "save_results", true)
setup_file(ex) = joinpath(dir(ex), name(ex) * ".json")
log_file(ex) = joinpath(dir(ex), name(ex) * ".log")
results_file(ex) = joinpath(dir(ex), name(ex) * ".csv")

function tests(experiment_dict::AbstractDict)
    key_filter = get(experiment_dict, "key_filter", key!)
    key_update = get(experiment_dict, "key_update", rm!)
    special_fns = get(experiment_dict, "special_fns", update_seed)
    return product_dict(
        experiment_dict;
        key_filter=key_filter,
        key_update=key_update,
        special_fns=special_fns,
    )
end

# # redirect stdout and stderr
function redirect_logs(func, log_file)
    open(log_file, "w") do out
        redirect_stdout(out) do
            redirect_stderr(out) do
                func()
            end
        end
    end
end

function run(experiment::AbstractDict, solver::Function)::DataFrame
    # shorthanding (im lazy)
    ex = experiment

    # save setup?
    if save_setup(ex)
        mkpath(dirname(setup_file(ex)))
        open(setup_file(ex), "w") do io
            print(io, ex, 4)
        end
    end

    # capture output?
    if save_log(ex)
        results = redirect_logs(log_file(ex)) do
            pmap(solver, tests(ex))
        end
    else
        results = pmap(solver, tests(ex))
    end

    # create df
    df = vcat(DataFrame.(results)...)

    # save df?
    if save_setup(ex)
        write(results_file(ex), df)
    end
    return df
end
