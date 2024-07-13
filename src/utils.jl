"""
    all_but_last(iterable)

Takes an iterable and returns the set [first,last) element.
I.e., if the iterble is only of lenth one, it will still return
the first element
"""
function all_but_last(iterable)
    return iterable[1:max(1, end - 1)]
end

"""
    nested_keys(dict)

Takes a potentially nested dictionary, and returns a vector of tuples
giving the nested keys.
Warning: Will fail if some of the dictionaries keys are already tuples.

```julia
julia> d = Dict("aa" => 1, "bb" => Dict("xx" => 2, "yy" => Dict("gg"=>3,"hh"=>4)))
Dict{String, Any} with 2 entries:
  "bb" => Dict{String, Any}("xx"=>2, "yy"=>Dict("hh"=>4, "gg"=>3))
  "aa" => 1

julia> nested_keys(d)
4-element Vector{Tuple{String, Vararg{String}}}:
 ("bb", "xx")
 ("bb", "yy", "hh")
 ("bb", "yy", "gg")
 ("aa",)
```
"""
nested_keys(dict) = _nested_keys(dict, ())
function _nested_keys(dict, parent)
    if typeof(dict) <: AbstractDict
        sub_keys = (_nested_keys(sd, (parent..., sk)) for (sk, sd) in dict)
        return typeof(sub_keys) <: Tuple ? sub_keys : vcat(sub_keys...)
    end
    return (parent)
end

"""
    nested_get(dict::AbstractDict, key, fallback=nothing)

Gets the element inside a potentially nested dictionary, where `key`
defines the tuple-key.

```julia
julia> d = Dict("aa" => 1, "bb" => Dict("xx" => 2, "yy" => Dict("gg"=>3,"hh"=>4)))
Dict{String, Any} with 2 entries:
  "bb" => Dict{String, Any}("xx"=>2, "yy"=>Dict("hh"=>4, "gg"=>3))
  "aa" => 1

julia> nested_get(d,("bb","yy"))
Dict{String, Int64} with 2 entries:
  "hh" => 4
  "gg" => 3

julia> nested_get(d,"aa")
1
```
"""
function nested_get(dict::AbstractDict, key, fallback=nothing)
    if key ∈ keys(dict)
        return get(dict, key, fallback)
    end
    return reduce((dict, key) -> get(dict, key, fallback), key; init=dict)
end

"""
    nested_set!(dict::AbstractDict, key, val)::AbstractDict


Sets the element inside a potentially nested dictionary, where `key`
defines the tuple-key.
```julia
julia> d = Dict("aa" => 1, "bb" => Dict("xx" => 2, "yy" => Dict("gg"=>3,"hh"=>4)))
Dict{String, Any} with 2 entries:
  "bb" => Dict{String, Any}("xx"=>2, "yy"=>Dict("hh"=>4, "gg"=>3))
  "aa" => 1

julia> nested_set!(d,("bb","xx"),6)
Dict{String, Any} with 2 entries:
  "bb" => Dict{String, Any}("xx"=>6, "yy"=>Dict("hh"=>4, "gg"=>3))
  "aa" => 1
```
"""
function nested_set!(dict::AbstractDict, key, val)::AbstractDict
    if key ∈ keys(dict)
        dict[key] = val
    else
        sub_dict = nested_get(dict, all_but_last(key))
        sub_dict[last(key)] = val
    end
    return dict
end
