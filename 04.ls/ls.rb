#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_NUM = 3

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
  row_num = (entries.size + COLUMN_NUM - 1) / COLUMN_NUM
  entries_table = create_table(entries, row_num)
  col_widths = get_col_widths(entries, row_num)

  entries_table.each do |row_entries|
    row_entries.each_index do |col_index|
      printf("%-#{col_widths[col_index]}s\t", row_entries[col_index])
    end
    puts
  end
end

def create_table(entries, row_num)
  Array.new(row_num) do |row_index|
    Array.new(COLUMN_NUM) { |col_index| entries[col_index * row_num + row_index] || '' }
  end
end

def get_col_widths(entries, row_num)
  Array.new(COLUMN_NUM) do |col_index|
    entries.slice(row_num * col_index, row_num).max_by(&:length)&.length
  end
end

main
