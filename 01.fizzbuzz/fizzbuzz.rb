# frozen_string_literal: true

fizz = 'Fizz'
buzz = 'Buzz'
[*1..20].each do |num|
  if (num % 3).zero? && (num % 5).zero?
    puts "#{fizz}#{buzz}"
  elsif (num % 3).zero?
    puts fizz
  elsif (num % 5).zero?
    puts buzz
  else
    puts num
  end
end
