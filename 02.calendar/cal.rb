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

def create_calendar_string_header(year, month)
  format("     %<month>2d月 %<year>d\n", month: month, year: year)
end

def create_weekdays_string
  "日 月 火 水 木 金 土\n"
end

def create_days_string(year, month)
  first_day_wday = Date.new(year, month, 1).wday
  last_day_of_month = Date.new(year, month, -1).day
  days_string = ' ' * 3 * first_day_wday
  [*1..last_day_of_month].each do |day|
    days_string += format('%2d ', day)
    days_string += "\n" if Date.new(year, month, day).saturday?
  end
  days_string
end

def create_calendar_string(year, month)
  calendar_string = ''
  calendar_string += create_calendar_string_header(year, month)
  calendar_string += create_weekdays_string
  calendar_string += create_days_string(year, month)
  calendar_string
end

options = parse_options
year  = options[:year]  || Date.today.year
month = options[:month] || Date.today.month
puts create_calendar_string(year, month)
