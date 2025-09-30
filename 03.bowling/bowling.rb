#!/usr/bin/env ruby
# frozen_string_literal: true

def get_shot_score(shot)
  shot == 'X' ? 10 : shot.to_i
end

result = ARGV[0]
shots = result.split(',')
scores = shots.map { get_shot_score(it) }

point = 0
frame_begin = 0
frame_score_end = nil
frame_shot_cnt = nil

(1..10).each do |frame_no|
  if frame_no == 10
    frame_score_end = scores.length - 1
  elsif shots[frame_begin] == 'X' # strike
    frame_shot_cnt = 1
    frame_score_end = frame_begin + 2
  else
    frame_shot_cnt = 2
    frame_score_end = frame_begin + 1
    frame_score_end += 1 if scores[frame_begin..frame_begin + 1].sum == 10
  end
  point += scores[frame_begin..frame_score_end].sum
  frame_begin += frame_shot_cnt
end

puts point
