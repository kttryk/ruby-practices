#!/usr/bin/env ruby
# frozen_string_literal: true

def get_shot_score(shot)
  shot == 'X' ? 10 : shot.to_i
end

score = ARGV[0]
scores = score.split(',')
scores_index = 0
point = 0
(1..10).each do |f|
  shot1 = scores[scores_index]
  shot2 = scores[scores_index + 1]
  shot3 = scores[scores_index + 2]
  if f == 10
    scores[scores_index..].each { |s| point += get_shot_score(s) }
  elsif shot1 == 'X' # strike
    point += 10
    point += get_shot_score(shot2)
    point += get_shot_score(shot3)
    scores_index += 1
  else
    frame_score = get_shot_score(shot1) + get_shot_score(shot2)
    point += frame_score
    point += get_shot_score(shot3) if frame_score == 10 # spare
    scores_index += 2
  end
end
puts point
