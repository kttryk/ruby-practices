#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_COUNT = 3
TAB_WIDTH = 8
MODE_FILE_TYPE_BEGIN = 0
MODE_FILE_TYPE_LENGTH = 2
MODE_PERMISSION_BEGIN = 3
MODE_PERMISSION_LENGTH = 3

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
  return if entries.empty?

  entries.map! do |entry|
    extract_entry_metadata(entry)
  end
  formated_entries = format_entries(entries, %i[nlink user group size])
  formated_entries.each do |metadata|
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
  mode_string = { '10' => '-', '04' => 'd', '12' => 'l' }[mode.slice(MODE_FILE_TYPE_BEGIN, MODE_FILE_TYPE_LENGTH)]
  mode.slice(MODE_PERMISSION_BEGIN, MODE_PERMISSION_LENGTH).chars.map(&:to_i).each do |digit|
    mode_string += [
      (digit & 4).zero? ? '-' : 'r',
      (digit & 2).zero? ? '-' : 'w',
      (digit & 1).zero? ? '-' : 'x'
    ].join
  end
  mode_string
end

def format_entries(entries, format_keys)
  max_lengths = format_keys.map { |key| [key, entries.map { |entry| entry[key].to_s.length }.max.to_i] }.to_h
  entries.map do |entry|
    entry.map do |key, value|
      max_length = max_lengths[key] || 0
      width_format = value.is_a?(String) ? "%-#{max_length + 1}s" : "%#{max_length}d"
      [key, format(width_format, value)]
    end.to_h
  end
end

main
