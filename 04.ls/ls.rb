#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_COUNT = 3
TAB_WIDTH = 8

def main
  options = parse_options
  entries = list_entries(options)
  print_entries(entries)
end

def parse_options
  options = {}
  OptionParser.new do |opt|
    opt.on('-a') { options[:a] = true }
    opt.parse!(ARGV)
  end
  options
end

def list_entries(options)
  options[:a] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
end

def print_entries(entries)
  entries_table = create_table(entries)
  max_tab_num = calc_tab_cnt(entries.max_by(&:length)) + 1

  entries_table.each do |row_entries|
    row_entries.each do |entry|
      delimiter = "\t" * (max_tab_num - calc_tab_cnt(entry))
      print "#{entry}#{delimiter}"
    end
    puts
  end
end

def create_table(entries)
  row_num = (entries.size + COLUMN_COUNT - 1) / COLUMN_COUNT
  Array.new(row_num) do |row_index|
    Array.new(COLUMN_COUNT) { |col_index| entries[col_index * row_num + row_index] || '' }
  end
end

def calc_tab_cnt(entry)
  entry.length / TAB_WIDTH
end

main
