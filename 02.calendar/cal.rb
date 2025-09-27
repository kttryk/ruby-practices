#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

def parse_options
  options = {}
  OptionParser.new do |opt|
    opt.on('-y YEAR',  Integer) { |v| options[:year]  = v }
    opt.on('-m MONTH', Integer) { |v| options[:month] = v }
    opt.parse!(ARGV)
  end
  options
end

def create_days(year, month)
  first_wday_of_month = Date.new(year, month, 1).wday
  last_day_of_month = Date.new(year, month, -1).day
  days = ' ' * 3 * first_wday_of_month
  (1..last_day_of_month).each do |day|
    days += format('%2d ', day)
    days += "\n" if Date.new(year, month, day).saturday?
  end
  days
end

def create_calendar(year, month)
  calendar = ''
  calendar += format("     %<month>2d月 %<year>d\n", month: month, year: year)
  calendar += "日 月 火 水 木 金 土\n"
  calendar += create_days(year, month)
  calendar
end

options = parse_options
today = Date.today
year  = options[:year]  || today.year
month = options[:month] || today.month
puts create_calendar(year, month)
