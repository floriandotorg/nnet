require! {
  'prelude-ls': {map, unique, pow, empty, difference, take, drop, any, all, zip-all, find-indices}
  async
  lodash
  'random-js': Random
  './evolve': {Task}
}

const rand = new Random!

# const cities = map (-> [rand.integer(-10,10), rand.integer(-10,10)]), [1 to 20]
const cities =
  * [ -9, 8 ]
  * [ -8, -1 ]
  * [ 10, -8 ]
  * [ -6, 3 ]
  * [ -10, 4 ]
  * [ 5, 9 ]
  * [ 8, -4 ]
  * [ 2, 9 ]
  * [ -7, -2 ]
  * [ -5, 9 ]
  * [ 5, 2 ]
  * [ -3, 1 ]
  * [ 0, 1 ]
  * [ 4, -1 ]
  * [ -5, 7 ]
  * [ -1, -8 ]
  * [ 5, 7 ]
  * [ 4, -3 ]
  * [ 5, 8 ]
  * [ 0, 0 ]

const arreq = (a,b) --> all (-> unique(&0).length is 1), zip-all(a,b)
const valid = (a) -> all ((it) -> find-indices(arreq(it), a).length is 1), a
const distance = (c1 ,c2) -> pow(c1.0 - c2.0, 2) + pow(c1.1 - c2.1, 2)
const totalDistance = (s) -> lodash.reduce s, ((t, _, n) -> if n > 0 then t + distance(s[n-1], s[n]) else t), 0
Array.prototype.swap = (a,b) ->
  const t = @[a]
  @[a] = @[b]
  @[b] = t
  return @

const task = new Task do
  generate: !-> &1(null, lodash.shuffle(cities))
  crossover: !->
    const r = rand.integer 0, &1.length-1
    const a = take(r,&1) ++ drop(r,&2)
    throw if not (&1.length is &2.length is a.length)
    &0(a)
  mutate: !-> &0(&1.swap rand.integer(0,&1.length-1), rand.integer(0,&1.length-1))
  fitness: (s, cb) !-> cb(null, totalDistance(s))
  isValid: !-> &1(valid &0)
  stopCriteria: -> false
  printStats: !->
    console.log "#{@best.0} | g: #{@generation}"
    # console.dir @best
    # console.dir @population
  populationSize: 20
  crossoverProbability: 0.2
  mutateProbability: 0.8

task.run!
