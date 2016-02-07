class Airscore
  schema:
    words:
      type: 'object'
      hasLength: true
    text:
      type: 'string'
  attributes:
    words: []
    text: ''
    tones: []
  constructor: ->
    return @
  set: (key, value) ->
    if @attributes.hasOwnProperty(key)
      schema = @schema[key]
      if typeof(value) isnt schema.type
        return throw new Error(
          'Type expected: ' + schema.type + ', but was: ' + typeof(value)
        )
      if (schema.hasLength and typeof(value.length) isnt 'number')
        return throw new Error('Value expected to have length.')
      @attributes[key] = value

      if key is 'text'
        @attributes['words'] = @makeWords(value)
      return @
    else
      throw new Error('This attribute cannot be set.')
  get: (key) ->
    if @attributes.hasOwnProperty(key)
      return @attributes[key]
  add: (key, item) ->
    if key is 'words'
      @attributes['words'].push(item)
    return @
  makeWords: (text) ->
    text = text.toLowerCase()
    words = text.replace(/[^\w\s]|_/g, '')
    words = words.replace(/(^\s*)|(\s*$)/gi,'')
    words = words.replace(/[ ]{2,}/gi,' ')
    words = words.replace(/\n /,'\n')
    return words.split(' ')
  addTone: (name, indicators) ->
    @attributes.tones.push
      name: name
      indicators: indicators
    return @
  getScore: (options) ->
    options = options or {}
    balance = options.balance or 'fair'
    percent = options.percent or false

    if options.decimals is 0
      decimals = options.decimals
    else
      decimals = options.decimals or 2

    scores = {}

    for item in @attributes.tones
      scores[item.name] = calculateSingleScore(@attributes.words, item, decimals, percent)

    if !percent
      scores = balanceScores(@attributes.words.length, scores, balance, decimals)

    if percent
      scores = percentScores(scores, decimals, balance, @attributes.words.length)

    return scores

module.exports = Airscore

calculateSingleScore = (words, tone, decimals, percent) ->
  score = 0
  for indicator in tone.indicators
    matchCount = getMatchesBy(indicator.word, words)
    if matchCount > 0
      indicator.weight = indicator.weight or 1
      score += (indicator.weight*matchCount)
  if !percent
    return score.toFixed(decimals)
  return score

getMatchesBy = (indicator, words) ->
  matches = 0
  for word in words
    if word is indicator
      matches++
  return matches

balanceScores = (wordCount, scores, balance, decimals) ->
  if balance is 'fair'
    for scoreName, score of scores
      scores[scoreName] = (score/wordCount).toFixed(decimals)
  return scores

percentScores = (scores, decimals, balance, wordCount) ->
  sum = 0
  for scoreName, score of scores
    sum += score

  if balance is 'fair'
    sum = wordCount

  for scoreName, score of scores
    scores[scoreName] = ((score/sum)*100).toFixed(decimals) + '%'

  return scores
