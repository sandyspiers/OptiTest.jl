using OptiTest: Experiment, Test, Iterable, FlattenIterable, Seed, tests_in

ex = Experiment(;#
    instances=FlattenIterable((#
        x=Iterable([1, Iterable(100:101)]),
        y=Iterable(5:6),
        z=100,
        s=Seed(0),
    )),
    backend=FlattenIterable([#
        (solver=:cplex, aggression=Iterable([:little, :lot])),
        (solver=:gurobi, aggresssion=nothing),
    ]),
)

test = tests_in(ex)
for t in test
    t.solve_time = rand()
end
map(println, test)
