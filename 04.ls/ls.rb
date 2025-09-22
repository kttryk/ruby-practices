#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_COUNT = 3
TAB_WIDTH = 8

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
  %i[nlink user group size].each { |format_key| format_width(entries, format_key) }
  entries.each do |metadata|
    print "#{metadata[:mode]} "
    print "#{metadata[:nlink]} "
    print "#{metadata[:user]} "
    print "#{metadata[:group]} "
    print "#{metadata[:size]} "
    print "#{metadata[:month]} "
    print "#{metadata[:day]} "
    print "#{metadata[:time]} "
    print metadata[:file]
    puts
  end
end

def extract_entry_metadata(entry)
  stat = File.stat(entry)
  time = stat.ctime
  metadata = {}
  metadata[:mode]  = get_entry_mode(stat)
  metadata[:nlink] = stat.nlink
  metadata[:user]  = Etc.getpwuid(stat.uid).name
  metadata[:group] = Etc.getgrgid(stat.gid).name
  metadata[:size]  = stat.size
  metadata[:month] = format('%2d', time.month)
  metadata[:day]   = format('%2d', time.day)
  metadata[:time]  = format('%<hour>02d:%<min>02d', hour: time.hour, min: time.min)
  metadata[:file]  = entry
  metadata
end

def get_entry_mode(stat)
  mode = format('%06o', stat.mode)
  mode_string = { '10' => '-', '04' => 'd', '12' => 'l' }[mode.slice(0, 2)]
  (3..5).each do |i|
    mode_string += create_permission_string(mode.slice(i).to_i)
  end
  mode_string
end

def create_permission_string(permission)
  permission_binary = format('%03b', permission)
  permission_string = ''
  (0..2).each do |i|
    permission_string += { '0' => '-', '1' => %w[r w x][i] }[permission_binary.slice(i)]
  end
  permission_string
end

def format_width(entries, key)
  max_length = entries.map { |entry| entry[key].to_s.length }.max.to_i
  if entries[0][key].is_a?(String)
    entries.each { |entry| entry[key] += ' ' * (max_length - entry[key].length + 1) }
  else
    entries.each { |entry| entry[key] = format("%#{max_length}d", entry[key]) }
  end
  entries
end

main
