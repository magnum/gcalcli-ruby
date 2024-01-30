#!/usr/bin/env ruby

# see readme.md for usage
require 'date'
require 'pry'
require 'dotenv/load'
Dotenv.load

class Event
  DATE_FORMAT = "%d/%m/%Y"
  TIME_FORMAT = "%H:%M"
  ATTRIBUTES = [:date_start, :time_start, :date_end, :time_end, :url, :description, :title]
  attr_accessor *ATTRIBUTES

  attr_accessor :from, :to
  
  def initialize(str)
    ATTRIBUTES .map.with_index do |key, index|
      self.send("#{key}=", str.split("\t")[index])
    end
    @from = DateTime.parse("#{date_start} #{time_start}")
    @to = DateTime.parse("#{date_end} #{time_end}")
  end

  def duration
    ((to - from) * 24 * 60).to_i
  end

  def to_s
    date_from = from.strftime(DATE_FORMAT)
    time_from = from.strftime(TIME_FORMAT)
    date_to = to.strftime(DATE_FORMAT)
    time_to = to.strftime(TIME_FORMAT)
    "#{date_from} #{time_from} - #{time_to} #{title}"
  end

end


ACTIONS = ["list", "search"]
action = ARGV[0]
param = (ARGV[1] || "").strip.gsub("*", "\"*\"")
options = (ARGV[2..-1] || []).map do |option|
  option+="=true" if option.split("=").count == 1
  option.split("=").map(&:strip)
end.to_h.transform_keys(&:to_sym)


ACTIONS.include?(action) || raise("Action #{action} not found. Available ACTIONS: #{ACTIONS.join(", ")}")
command = nil
base_command = "gcalcli --nocolor"

case action
  when "list"
    command = "#{base_command} list"
    output = `#{command}`
  when "search"
    calendar = options[:calendar] || ENV["CALENDAR_DEFAULT"]
    query = param
    from = options[:from] || Time.now.strftime("%Y-%m-%d")
    to = options[:to] || Time.now.strftime("%Y-12-31")
    command = "#{base_command} --cal='#{calendar}' search --military --tsv --details={end,length,description,url} #{query} #{from} #{to}"
    events = `#{command}`
    .split("\n")
    .filter{|line| line != ""}
    .map do |line|
      Event.new(line)
    end
    output = (events.map(&:to_s)+["#{events.count} event(s)"]).join("\n")
end


binding.pry if options[:debug]
puts output
