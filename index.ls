require! {
  'ascii-table': AsciiTable
  'prelude-ls': {map, sort-by, take, concat, last}
  async
  child_process: {exec}
  'random-js': Random
}

const POPULATION_SIZE = 10
const MUTATE_PROBABILITY = 0.3
const CROSSOVER_PROBABILITY = 0.5

rand = new Random!

global.population = map (-> [rand.integer(1,10), rand.integer(1000,100000), rand.real(0.01, 0.00001)]), [1 to POPULATION_SIZE]

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
    cb null, [JSON.parse(stdout), p]

const printPopulation = ->
  const table = new AsciiTable!
  table.setHeading('MSE', 'Neurons', 'Interations', 'Error Threshold')
  table.setAlignLeft 0
  table.setAlignCenter 1
  table.setAlignRight 2
  table.setAlignLeft 3
  table.addRowMatrix(map (-> [&0.0, &0.1.0, &0.1.1, &0.1.2]), &0)
  console.log table.toString!

global.min = [1,[]]

async.forever (next) ->
  async.map global.population, fit, (err, res) ->
    const p = sort-by (.0), res
    printPopulation(p)

    global.min = if p.0.0 < global.min.0 then p.0 else global.min
    console.dir global.min

    newp = map (.1), concat [(take Math.floor(POPULATION_SIZE/4), p), [last p]]
    const nps = newp.length-1

    while newp.length < POPULATION_SIZE
      if Math.random() > CROSSOVER_PROBABILITY
        child = crossover newp[rand.integer(0, nps)], newp[rand.integer(0, nps)]
      else
        child = newp[rand.integer(0, nps)]

      if Math.random() > MUTATE_PROBABILITY
        child = mutate child

      newp.push child

    global.population = newp

    next!
