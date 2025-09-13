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
  max_tab_num = get_tab_num(entries.max_by(&:length)) + 1

  entries_table.each do |row_entries|
    row_entries.each do |entry|
      delimiter = "\t" * (max_tab_num - get_tab_num(entry))
      printf("%s#{delimiter}", entry)
    end
    puts
  end
end

def create_table(entries, row_num)
  Array.new(row_num) do |row_index|
    Array.new(COLUMN_NUM) { |col_index| entries[col_index * row_num + row_index] || '' }
  end
end

def get_tab_num(entry)
  (entry&.length || 0) / 8
end

main
