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
save(ex) = get(ex, "save", "slr")
dir(ex) = get(ex, "dir", ".")

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
function redirect_logs(func, file_base)
    open(file_base * ".log", "w") do out
        open(file_base * ".err", "w") do err
            redirect_stdout(out) do
                redirect_stderr(err) do
                    func()
                end
            end
        end
    end
end

function run(experiment::AbstractDict, solver::Function)::DataFrame
    # shorthanding (im lazy)
    ex = experiment

    # mkdir
    mkpath(dir(ex))

    # save setup?
    if occursin('s', save(ex))
        open(joinpath(dir(ex), name(ex)) * ".json", "w") do io
            print(io, ex, 4)
        end
    end

    # capture output?
    if occursin('l', save(ex))
        results = redirect_logs(joinpath(dir(ex), name(ex))) do
            pmap(solver, tests(ex))
        end
    else
        results = pmap(solver, tests(ex))
    end

    # create df
    df = vcat(DataFrame.(results)...)

    # save df?
    if occursin('r', save(ex))
        write(joinpath(dir(ex), name(ex)) * ".csv", df)
    end
    return df
end
