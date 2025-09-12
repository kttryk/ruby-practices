#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_NUM = 3

def main
  pwd_path = Dir.pwd
  array = get_directory_data(pwd_path)
  print_array_column(array, COLUMN_NUM)
end

def get_max_length(array)
  !array.empty? ? array.max_by(&:length).length : 0
end

def create_cols_array(array, column_num)
  row_num = (array.size + column_num - 1) / column_num
  cols = Array.new(column_num)
  (0..column_num - 1).each do |col_index|
    cols[col_index] = array.slice(row_num * col_index, row_num) || []
  end
  cols
end

def print_array_column(array, column_num)
  cols = create_cols_array(array, column_num)
  cols_width = cols.map { |col| get_max_length(col) }

  cols[0].each_index do |row_index|
    cols.each_index do |col_index|
      printf("%-#{cols_width[col_index]}s\t", cols[col_index][row_index])
    end
    puts
  end
end

def get_directory_data(path)
  Dir.glob("#{path}/*").map do |file|
    File.basename(file)
  end
end

main
