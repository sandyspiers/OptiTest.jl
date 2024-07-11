@testset "dict.jl" begin
    # test symbol parsing
    test_symbols = ["rand", "maximum"]
    for symbol_label in SYMBOL_NAMES
        for symbol in test_symbols
            orig = Dict("x" => Dict(symbol_label => symbol))
            new = parse_symbols(orig)
            # check symbol properlly constructed
            @test new["x"] == Symbol(symbol)
            # check no more symbol keys left
            @test symbol ∉ all_keys(new)
            # dont touch original
            @test orig == Dict("x" => Dict(symbol_label => symbol))
        end
    end

    # test iterate parsing
    for iterate_name in ITERATE_NAMES
        orig = Dict(
            "x" => Dict(iterate_name => [1, 2, 3]), "y" => Dict(iterate_name => [4, 5, 6])
        )
        new = parse_iterates(orig)
        # check there is correct number
        @test length(new) == 9
        # check that it iterated over 'y'
        for i in 4:6
            @test new[i] == Dict("y" => i)
            # make sure name is removed
            @test iterate_name ∉ all_keys(new[i])
        end
        # dont touch original
        @test orig == Dict("x" => Dict(iterate_name => [1, 2, 3]))
    end

    # test fully parsed for both
    for symbol_name in SYMBOL_NAMES
        for iterate_name in ITERATE_NAMES
            orig = Dict(
                "x" => Dict(symbol_name => "min"), "y" => Dict(iterate_name => [4, 5, 6])
            )
            tests = parse_experiment(orig)
            @test length(tests) == 3
            for test in tests
                keys = all_keys(test)
                @test symbol_name ∉ keys
                @test iterate_name ∉ keys
            end
            @test orig == Dict(
                "x" => Dict(symbol_name => "min"), "y" => Dict(iterate_name => [4, 5, 6])
            )
        end
    end
end
