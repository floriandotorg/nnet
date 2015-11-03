require! {
  'ascii-table': AsciiTable
  'prelude-ls': {map, sort-by}
  async
  child_process: {exec}
  'random-js': Random
}

rand = new Random!

global.population = map (-> [rand.integer(1,10), rand.integer(1000,100000), rand.real(0.01, 0.00001)]), [1 to 20]

const crossover = ->
  c = []
  for n from 0 to &0.length-1
    const r = Math.random()
    c.push &0[n]*r + &1[n]*(1-r)
  c.0 = Math.round(c.0)
  c.1 = Math.round(c.1)
  return c

const mutate = ->
  const m = -> &0 + &0 * Math.random() * 0.05 * (if Math.random() > 0.5 then -1 else 1)
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

async.forever (next) ->
  async.map global.population, fit, (err, res) ->
    const np = sort-by (.0), res

    printPopulation(np)

    newp = []
    for from 0 to global.population.length-1
      newp.push mutate(crossover(np.0.1, np.1.1))

    global.population = newp

    next!
