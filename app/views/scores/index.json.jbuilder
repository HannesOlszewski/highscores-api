json.array! @scores.each.with_index(1).to_a do |(score, rank)|
  json.partial! "scores/score", score:, rank:
end
