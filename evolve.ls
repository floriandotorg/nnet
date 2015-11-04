require! {
  'prelude-ls': {map, sort-by, take, last, floor, zip}
  async
  'random-js': Random
}

const rand = new Random!

const aif = !-> if &0! then &1(&3) else &2(&3)

export class Task
  ({@generate, @crossover, @mutate, @fitness, @isValid, @stopCriteria, @printStats, @populationSize, @crossoverProbability, @mutateProbability}) !->
    @best = [Number.MAX_VALUE]
    @generation = 0

  run: (cb = !->) !->
    cb = cb.bind(@)

    @results = [0] * @populationSize
    async.map [1 to @populationSize], @generate, (err, @population) !~>
      return cb(err) if err
      @printStats!

      async.doUntil (next) !~>
        ++@generation

        async.map @population, @fitness, (err, res) !~>
          const pop = sort-by (.0), zip res, @population
          @best = pop.0 if pop.0.0 < @best.0

          @results = map (.0), pop
          @population = map (.1), (take floor(@populationSize/4), pop) ++ [last(pop)]
          const nps = @population.length-1

          async.whilst (~> @population.length < @populationSize), (end) ~>
            aif (~> Math.random! > @crossoverProbability)
            , !~> @crossover &0, @population[rand.integer(0, nps)], @population[rand.integer(0, nps)]
            , !~> &0(@population[rand.integer(0, nps)])
            , (child) ~>
              aif (~> Math.random! > @mutateProbability)
              , !~> @mutate &0, child
              , !-> &0(child)
              , (child) !~>
                valid <~ @isValid child
                @population.push child if valid
                end!
          , !~>
            @printStats!
            setTimeout(next)
      , @stopCriteria.bind(@), (!-> cb(&0))
