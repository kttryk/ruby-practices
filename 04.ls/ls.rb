#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_NUM = 3

def main
  entries = get_entries()
  print_entries(entries)
end

def get_entries()
  Dir.glob("*").map do |file|
    File.basename(file)
  end
end

def print_entries(entries)
  entries_table = create_table(entries)
  col_widths = entries_table.map { |col| get_max_length(col) }

  entries_table[0].each_index do |row_index|
    entries_table.each_index do |col_index|
      printf("%-#{col_widths[col_index]}s\t", entries_table[col_index][row_index])
    end
    puts
  end
end

def create_table(array)
  row_num = (array.size + COLUMN_NUM - 1) / COLUMN_NUM
  cols = Array.new(COLUMN_NUM)
  (0..COLUMN_NUM - 1).each do |col_index|
    cols[col_index] = array.slice(row_num * col_index, row_num) || []
  end
  cols
end

def get_max_length(array)
  array.max_by(&:length)&.length || 0
end

main
