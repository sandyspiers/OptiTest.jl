@testset "dict.jl" begin
    # test symbol parsing
    test_symbols = ["rand", "maximum"]
    for symbol_label in SYMBOL_NAMES
        for symbol in test_symbols
            orig = Dict{Any,Any}("x" => Dict{Any,Any}(symbol_label => symbol))
            new = parse_symbols!(orig)
            # check symbol properlly constructed
            @test new["x"] == Symbol(symbol)
            # check no more symbol keys left
            @test all(symbol ∉ key for key in all_keys(new))
        end
    end

    # test iterate parsing
    for iterate_name in ITERATE_NAMES
        orig = Dict(
            "x" => Dict(iterate_name => [1, 2, 3]),
            "y" => Dict(iterate_name => [4, 5, 6]),
            "z" => 100,
        )
        iterates = parse_iterates!(orig)
        # check there is correct number
        @test length(iterates) == 9
        for iterate in iterates
            # make sure name is removed
            @test all(iterate_name ∉ keys for keys in all_keys(iterate))
        end
    end

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
