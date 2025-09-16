#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_COUNT = 3
TAB_WIDTH = 8

def main
  entries = list_entries
  print_entries(entries)
end

def list_entries
  Dir.glob('*').map do |file|
    File.basename(file)
  end
end

def print_entries(entries)
  entries_table = create_table(entries)
  max_tab_num = calc_tab_num(entries.max_by(&:length)) + 1

  entries_table.each do |row_entries|
    row_entries.each do |entry|
      delimiter = "\t" * (max_tab_num - calc_tab_num(entry))
      printf("%s#{delimiter}", entry)
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

def calc_tab_num(entry)
  entry.length / TAB_WIDTH
end

main
