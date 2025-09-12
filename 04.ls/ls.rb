#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_NUM = 3

def main
  array = get_directory_data()
  print_array_column(array)
end

def get_directory_data()
  Dir.glob("*").map do |file|
    File.basename(file)
  end
end

def print_array_column(array)
  cols = create_cols_array(array)
  cols_width = cols.map { |col| get_max_length(col) }

  cols[0].each_index do |row_index|
    cols.each_index do |col_index|
      printf("%-#{cols_width[col_index]}s\t", cols[col_index][row_index])
    end
    puts
  end
end

def create_cols_array(array)
  row_num = (array.size + COLUMN_NUM - 1) / COLUMN_NUM
  cols = Array.new(COLUMN_NUM)
  (0..COLUMN_NUM - 1).each do |col_index|
    cols[col_index] = array.slice(row_num * col_index, row_num) || []
  end
  cols
end

def get_max_length(array)
  !array.empty? ? array.max_by(&:length).length : 0
end

main
