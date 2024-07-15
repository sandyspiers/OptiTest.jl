# # Tools used to parse, interperate and iterate OptiTest dictionarys

"""
    parse_symbols!(dict::AbstractDict)

Anywhere in `dict` where a key matches one of the names listed in
`SYMBOL_NAMES`, that key and element pair is replaced by the Symbol
given by the string element. For example:

```julia
julia> orig = AnyDict(
           "x" => AnyDict("symbol" => "rand"),
           "y" => AnyDict("z" => AnyDict("symbol" => "max")),
       );

julia> parse_symbols!(orig)
Dict{Any, Any} with 2 entries:
  "x" => :rand
  "y" => Dict{Any, Any}("z"=>:max)
```

Warnings:
 - The symbol **must** be loaded into the current environement
   by the user. It is not up to OptiTest to manage the imported symbols.
 - In to change element types, it is best to use `Dict{Any,Any}` for the
   original. You can import the synonym `AnyDict` to achieve this.
 - If a `SYMBOL_NAMES` is found, then every other key value pair on the
   same level is removed.
"""
function parse_symbols!(dict::AbstractDict)
    for nested_key in nested_keys(dict)
        if last(nested_key) ∈ SYMBOL_NAMES
            sym = Symbol(nested_get(dict, nested_key))
            nested_set!(dict, all_but_last(nested_key), sym)
        end
    end
    return dict
end

# private helper function that iterates over key, value pairs and uses
# nested set on each
function _ziped_nested_set(dict::AbstractDict, key_val_pairs)::AbstractDict
    for (key, val) in key_val_pairs
        nested_set!(dict, key, val)
    end
    return dict
end

"""
    parse_iterates!(dict::AbstractDict)

Anywhere in `dict` where a key matches one of the names listed in
`ITERATE_NAMES`, that 

Returns a generater function that replaces each occurance of an `ITERATE_NAME`
with once of its elements. For multiple `ITERATE_NAME`'s, products over them.
For example:

```julia
julia> orig = Dict(
           "x" => Dict("iterate_name" => [1, 2, 3]),
           "y" => Dict("iterate" => [4, 5, 6]),
           "z" => 100,
           "v" => Dict("a" => 2, "b" => Dict("iterate" => [100, 200])),
       );

julia> collect(parse_iterates!(orig))
2×3 Matrix{Dict{String, Any}}:
 Dict("v"=>Dict{String, Any}("b"=>200, "a"=>2), "x"=>Dict("iterate_name"=>[1, 2, 3]), "z"=>100, "y"=>6)  …  Dict("v"=>Dict{String, Any}("b"=>200, "a"=>2), "x"=>Dict("iterate_name"=>[1, 2, 3]), "z"=>100, "y"=>6)
 Dict("v"=>Dict{String, Any}("b"=>200, "a"=>2), "x"=>Dict("iterate_name"=>[1, 2, 3]), "z"=>100, "y"=>6)     Dict("v"=>Dict{String, Any}("b"=>200, "a"=>2), "x"=>Dict("iterate_name"=>[1, 2, 3]), "z"=>100, "y"=>6)
```

Warnings:
 - In to change element types, it is best to use `Dict{Any,Any}` for the
   original. You can import the synonym `AnyDict` to achieve this.
 - If a `ITERATE_NAME` is found, then every other key value pair on the
   same level is removed.
"""
function parse_iterates!(dict::AbstractDict)
    # get the nest keys with iterator keywords
    iterator_keys = filter(
        nested_key -> last(nested_key) ∈ ITERATE_NAMES, nested_keys(dict)
    )
    # remove the iterate keyword
    iterated_keys = all_but_last.(iterator_keys)
    # get the iterate lists
    iterator_values = (nested_get(dict, nested_key) for nested_key in iterator_keys)
    # product them
    iterator_prod = product(iterator_values...)
    # update dict
    iterates = (_ziped_nested_set(dict, zip(iterated_keys, vals)) for vals in iterator_prod)
    return iterates
end

function parse_experiment!(dict::AbstractDict)
    return (parse_symbols!(iterate) for iterate in parse_iterates!(dict))
end
