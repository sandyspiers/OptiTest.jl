function flatten(nt::NamedTuple, flat)::NamedTuple
    sub, top = split(nt, Tuple(flat))
    return merge(values(sub)..., top)
end

function key_vals(collection)
    return zip(keys(collection), values(collection))
end

function apply(nt::NamedTuple, fn::Function)::NamedTuple
    return NamedTuple((k => fn(k, v) for (k, v) in key_vals(nt)))
end

function unzip(collection)
    return (first.(collection), last.(collection))
end
