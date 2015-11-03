require! {
  synaptic: {Neuron, Layer, Network, Trainer, Architect}
  'prelude-ls': {fold}
}

fit = (p) ->
  const perceptron = new Architect.Perceptron 2, p.0, 1

  trainingSet = []

  for n from 0 to 0.5 by 0.1
    for m from 0 to 0.5 by 0.1
      trainingSet.push do
        input: [n,m]
        output: [n+m]

  const trainer = new Trainer perceptron
  trainer.train trainingSet,
    iterations: p.1
    error: p.2

  const standalone = perceptron.standalone!

  r = []
  for n in trainingSet
    const s = standalone([n.input.0,n.input.1])
    r.push Math.pow(n.output.0 - s, 2)

  const f = fold (+), 0, r
  return f/r.length

console.log fit(JSON.parse(process.argv.2))
