@testset "utils.jl" begin
    # test dictionary iterates
    orig = Dict("x!" => [1, 2, 3], "y!" => [4, 5, 6], "z" => 100, "a!" => [100, 200])
    iterates = iterated_dict!(orig, key -> last(key) == '!', key -> key[1:(end - 1)])
    # check there is correct number
    @test length(collect(iterates)) == 18
    # check the first one
    @test first(iterates) == Dict("x" => 1, "y" => 4, "z" => 100, "a" => 100)
    @test last(iterates) == Dict("x" => 3, "y" => 6, "z" => 100, "a" => 200)
    # check its mutating correctly
    orig = Dict("x!" => [1, 2, 3], "y!" => [4, 5, 6], "z" => 100, "a!" => [100, 200])
    for _ in iterated_dict!(orig, key -> last(key) == '!', key -> key[1:(end - 1)])
        @test orig == Dict("x" => 1, "y" => 4, "z" => 100, "a" => 100)
        break
    end
    # check special functions
    function update_seed(dict)
        dict["seed"] = get(dict, "seed", 0) + 1
        return dict
    end
    orig = Dict("x!" => [1, 2, 3], "y!" => [4, 5, 6], "z" => 100, "a!" => [100, 200])
    iterates = iterated_dict!(
        orig, key -> last(key) == '!', key -> key[1:(end - 1)], update_seed
    )
    i = 1
    for _ in iterates
        @test orig["seed"] == i
        i += 1
    end
end
