# OptiTest.jl

[![Build Status](https://github.com/sandyspiers/OptiTest.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sandyspiers/OptiTest.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/sandyspiers/OptiTest.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/sandyspiers/OptiTest.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A toolkit to run large scale, distributed numerical experiments on your optimisation functions and to analyse the results.
Experiments and setup schemes are written up as yaml files, which are then executed in a Julia shell.
This means you can either run then as a script on a server, or on your own REPL.

## Usage

Each experimental setup a set of test, instance and solver options.
Once these are evaluated you get a single list of (test,instance,solver) combinations.
This is then given to a generic solver routine which executes based on what you require.

Here is an example of the yaml setup
```yml
# test.yml
test:
  name: example-experiment
  logfile: experiment.log
  savefile: experiment.res
  workers: 8
instance:
  generator:
    symbol: rand
  x:
    repeat: [3, 5, 7]
parameters:
  strategy:
    repeat: [min, max]
```

