@testset "dict.jl" begin
    # test symbol parsing
    test_symbols = ["rand", "maximum"]
    for symbol_label in SYMBOL_NAMES
        for symbol in test_symbols
            orig = AnyDict("x" => AnyDict(symbol_label => symbol))
            new = parse_symbols!(orig)
            # check symbol properlly constructed
            @test new["x"] == Symbol(symbol)
            @test new == AnyDict("x" => Symbol(symbol))
            # test a nested one
            orig = AnyDict(
                "x" => AnyDict(symbol_label => symbol),
                "y" => AnyDict("z" => AnyDict(symbol_label => symbol)),
            )
            new = parse_symbols!(orig)
            @test new["x"] == Symbol(symbol)
            @test new["y"]["z"] == Symbol(symbol)
            @test new ==
                AnyDict("x" => Symbol(symbol), "y" => AnyDict("z" => Symbol(symbol)))
        end
    end

    # test iterate parsing
    for iterate_name in ITERATE_NAMES
        orig = Dict(
            "x" => Dict(iterate_name => [1, 2, 3]),
            "y" => Dict(iterate_name => [4, 5, 6]),
            "z" => 100,
            "v" => Dict("a" => 2, "b" => Dict(iterate_name => [100, 200])),
        )
        iterates = parse_iterates!(orig)
        # check there is correct number
        @test length(collect(iterates)) == 18
        # check the first one
        @test first(iterates) ==
            Dict("x" => 1, "y" => 4, "z" => 100, "v" => Dict("a" => 2, "b" => 100))
        @test last(iterates) ==
            Dict("x" => 3, "y" => 6, "z" => 100, "v" => Dict("a" => 2, "b" => 200))
        # ensure names are removed
        for iterate in iterates
            # make sure name is removed
            @test all(
                last(nested_key) ∉ ITERATE_NAMES for nested_key in nested_keys(iterates)
            )
        end
    end

    return nothing

    # test fully parsed for both
    for symbol_name in SYMBOL_NAMES
        for iterate_name in ITERATE_NAMES
            orig = Dict{Any,Any}(
                "x" => Dict{Any,Any}(symbol_name => "min"),
                "y" => Dict{Any,Any}(iterate_name => [4, 5, 6]),
            )
            tests = parse_experiment!(orig)
            @test length(tests) == 3
            for test in tests
                keys = all_keys(test)
                @test all(symbol_name ∉ key for key in keys)
                @test all(iterate_name ∉ key for key in keys)
            end
        end
    end
end
