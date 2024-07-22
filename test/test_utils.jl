@testset "utils.jl" begin
    # test set pairs
    d = Dict("x" => 2, "y" => 4)
    set!(d, ["x", "y"], [3, 5])
    @test d["x"] == 3
    @test d["y"] == 5

    # test flatten
    d = Dict("x" => 1, "y" => Dict("z" => 2))
    @test flatten(d, "_") == Dict("x" => 1, "y_z" => 2)

    # test make any dict
    d = Dict("x" => 1, "y" => Dict("z" => 2), "w" => [1, Dict("v" => :a)])
    any_d = make_any_dict(d)
    @test typeof(any_d) == Dict{Any,Any}
    @test typeof(any_d["y"]) == Dict{Any,Any}
    @test typeof(any_d["w"][2]) == Dict{Any,Any}
    any_d["x"] = :a
    @test any_d["x"] == :a

    # test product_dict
    d = Dict("x!" => [1, 2, 3])
    @test product_dict(d) == d # without a key filter, should do nothing
    k! = k -> last(k) == '!'
    uk = k -> k[1:(end - 1)]
    p = product_dict(d; key_filter=k!)
    for i in 1:3
        @test p[i] == Dict("x!" => i)
    end

    # test nested
    d = Dict("x!" => [1, 2, 3], "y!" => [5, Dict("z!" => [:a, :b])])
    p = product_dict(d; key_filter=k!)
    @test length(p) == 9
    @test p[1]["x!"] == 1
    @test p[1]["y!"] == 5
    @test p[end]["y!"]["z!"] == :b

    # test expressions
    d = Dict("x!" => 1:3, "y!" => 5:7)
    p = product_dict(d; key_filter=k!)
    @test length(p) == 9
    @test p[1]["x!"] == 1
    @test p[1]["y!"] == 5
    @test p[end]["x!"] == 3
    @test p[end]["y!"] == 7

    # test key updates
    d = Dict("x!" => [1, 2, 3], "y!" => [5, Dict("z!" => [:a, :b])])
    p = product_dict(d; key_filter=k!, key_update=uk)
    @test length(p) == 9
    @test p[1]["x"] == 1
    @test "x!" ∉ keys(p[1])
    @test p[1]["y"] == 5
    @test "y!" ∉ keys(p[1])
    @test p[end]["y"]["z"] == :b
    @test "z!" ∉ keys(p[end]["y"])

    # test special functions
    d = Dict("x!" => [1, 2, 3], "y!" => [5, Dict("z!" => [:a, :b])], "seed" => 0)
    function update_seed(dict)
        if "seed" ∈ keys(dict)
            dict["seed"] += 1
        end
        return dict
    end
    prod = product_dict(d; key_filter=k!, key_update=uk, special_fns=update_seed)
    s = 1
    for p in prod
        @test p["seed"] == s
        s += 1
    end
    # nested special fns
    d = Dict("ins!" => Dict("x!" => [1, 2, 3], "seed" => 0), "sol!" => [:g, :c])
    prod = product_dict(d; key_filter=k!, key_update=uk, special_fns=update_seed)
    @test prod[1]["ins"]["seed"] == 1
    @test prod[end]["ins"]["seed"] == 3
end
