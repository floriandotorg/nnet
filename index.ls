require! {
  'ascii-table': AsciiTable
  'prelude-ls': {map, zip}
  async
  child_process: {exec}
  'random-js': Random
  './evolve': {Task}
}

rand = new Random!

const crossover = ->
  c = []
  for n from 0 to &0.length-1
    const r = Math.random()
    c.push &0[n]*r + &1[n]*(1-r)
  c.0 = Math.round(c.0)
  c.1 = Math.round(c.1)
  return c

const mutate = ->
  const m = -> &0 + &0 * Math.random() * 0.4 * (if Math.random() > 0.5 then -1 else 1)
  &0.0 = Math.round(m(&0.0))
  &0.1 = Math.round(m(&0.1))
  &0.2 = m(&0.2)
  return &0

const fit = (p, cb) ->
  exec 'lsc fit.ls ' + JSON.stringify(p), (error, stdout, stderr) ->
    cb null, JSON.parse(stdout)

const printPopulation = ->
  table = new AsciiTable!
    ..setHeading('MSE', 'Neurons', 'Iterations', 'Error Threshold')
    ..setAlignLeft 0
    ..setAlignCenter 1
    ..setAlignRight 2
    ..setAlignLeft 3
    ..addRowMatrix(map (-> [&0.0, &0.1.0, &0.1.1, &0.1.2]), zip @results, @population)
  console.log table.toString!
  console.log @best.0

const task = new Task do
  generate: !-> &1(null, [rand.integer(1,10), rand.integer(1000,100000), rand.real(0.01, 0.00001)])
  crossover: !-> &0(crossover(&1,&2))
  mutate: !-> &0(mutate(&1))
  fitness: fit
  isValid: !-> &1(true)
  stopCriteria: -> false
  printStats: printPopulation
  populationSize: 10
  crossoverProbability: 0.3
  mutateProbability: 0.5

task.run!
