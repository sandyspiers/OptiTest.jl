abstract type PlotData end

function plot(plot_data::PlotData; style_guide::AbstractDict=Dict())
    # create empty
    p = plot(1; label=nothing)
    # add plots...
    plot!(plot_data, style_guide)
    # return...
    return p
end

function style_kwargs(labels::T where {T<:Pair}, style_guide::AbstractDict)::AbstractDict
    return _style_kwargs([labels], style_guide, Dict(), 0)
end
function style_kwargs(
    labels::Vector{T} where {T<:Pair}, style_guide::AbstractDict
)::AbstractDict
    return _style_kwargs(labels, style_guide, Dict(), 0)
end
function _style_kwargs(
    labels::Vector{T} where {T<:Pair}, style_guide::AbstractDict, depths, depth
)
    style = Dict()
    for (k, v) in style_guide
        if isa(k, Pair) && isa(v, AbstractDict)
            if k ∈ labels
                for (kk, vv) in _style_kwargs(labels, v, depths, depth + 1)
                    style = _update_style_depths!(kk, vv, style, depths, depth)
                end
            end
        else
            style = _update_style_depths!(k, v, style, depths, depth)
        end
    end
    return style
end
function _update_style_depths!(key, val, style, depths, depth)
    if key ∉ keys(depths)
        depths[key] = depth
    end
    if key ∉ keys(style) || depths[key] <= depth
        style[key] = val
    end
    return style
end
