#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_COUNT = 3
TAB_WIDTH = 8
MODE_FILE_TYPE_RANGE = (0..1)
MODE_PERMISSION_RANGE = (3..5)
FILE_TYPES = {
  '10' => '-',
  '04' => 'd',
  '12' => 'l'
}.freeze

def main
  options = parse_options
  entries = list_entries(options)
  options[:l] ? print_entries_l(entries) : print_entries(entries)
end

def parse_options
  options = {}
  OptionParser.new do |opt|
    opt.on('-a') { options[:a] = true }
    opt.on('-r') { options[:r] = true }
    opt.on('-l') { options[:l] = true }
    opt.parse!(ARGV)
  end
  options
end

def list_entries(options)
  entries = options[:a] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
  options[:r] ? entries.reverse : entries
end

def print_entries(entries)
  entries_table = create_table(entries)
  max_tab_count = calc_tab_count(entries.max_by(&:length)) + 1

  entries_table.each do |row_entries|
    row_entries.each do |entry|
      delimiter = "\t" * (max_tab_count - calc_tab_count(entry))
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

def calc_tab_count(entry)
  entry.length / TAB_WIDTH
end

def print_entries_l(entries)
  puts "total #{entries.sum { |entry| File.stat(entry).blocks }}"

  metadatas = entries.map { |entry| extract_entry_metadata(entry) }
  formated_metadatas = format_metadatas(metadatas, %i[nlink user group size])
  formated_metadatas.each do |metadata|
    puts metadata.values_at(:mode, :nlink, :user, :group, :size, :datetime, :file).join(' ')
  end
end

def extract_entry_metadata(entry)
  stat = File.stat(entry)
  time = stat.ctime
  {
    mode: get_entry_mode(stat),
    nlink: stat.nlink,
    user: Etc.getpwuid(stat.uid).name,
    group: Etc.getgrgid(stat.gid).name,
    size: stat.size,
    datetime: time.strftime('%_m %_d %H:%M'),
    file: entry
  }
end

def get_entry_mode(stat)
  mode = format('%06o', stat.mode)
  file_type = FILE_TYPES[mode[MODE_FILE_TYPE_RANGE]]
  permission = mode[MODE_PERMISSION_RANGE].chars.map(&:to_i).map do |digit|
    [
      (digit & 4).zero? ? '-' : 'r',
      (digit & 2).zero? ? '-' : 'w',
      (digit & 1).zero? ? '-' : 'x'
    ].join
  end.join
  [file_type, permission].join
end

def format_metadatas(metadatas, format_keys)
  max_lengths = format_keys.map { |key| [key, metadatas.map { |metadata| metadata[key].to_s.length }.max] }.to_h
  metadatas.map do |metadata|
    metadata.map do |key, value|
      max_length = max_lengths[key] || 0
      width_format = value.is_a?(String) ? "%-#{max_length + 1}s" : "%#{max_length}d"
      [key, format(width_format, value)]
    end.to_h
  end
end

main
