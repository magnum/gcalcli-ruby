#!/usr/bin/env ruby

# see readme.md for usage
require 'date'
require 'pry'
require 'dotenv/load'
Dotenv.load

DATE_FORMAT = "%d/%m/%Y"
TIME_FORMAT = "%H:%M"

class Event
  ATTRIBUTES = [:date_start, :time_start, :date_end, :time_end, :url, :description, :title]
  attr_accessor *ATTRIBUTES
  attr_accessor :source_string, :from, :to
  
  def initialize(str)
    @source_string = str
    ATTRIBUTES.map.with_index do |key, index|
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

  def open!
    `open #{url}`
  end

end


ACTIONS = ["list", "search", "daily-summary"]
action = ARGV[0]
param = (ARGV[1] || "").strip.gsub("*", "\"*\"")
options = (ARGV[2..-1] || []).map do |option|
  option+="=true" if option.split("=").count == 1
  option.split("=").map(&:strip)
end.to_h.transform_keys(&:to_sym)
ACTIONS.include?(action) || raise("Action #{action} not found. Available ACTIONS: #{ACTIONS.join(", ")}")


CALENDARS = {
  "Antonio": "incode - antonio",
  "Luca": "incode - luca",
  "Andrea": "Incode – Andrea",
  "Federica": "incode - federica",
  "Martina": "incode - martina",
  "Matteo": "incode - matteo",
}


def execute(command)
  base_command = "gcalcli --nocolor"
  command = "#{base_command} #{command}"
  #puts command; return "" #debug
  `#{command}`
end


def search_events(query, **options)
  calendar = options[:calendar] || ENV["CALENDAR_DEFAULT"]
  from = options[:from] || DateTime.now
  to = options[:to] || DateTime.parse(Time.now.strftime("%Y-12-31"))
  execute("--cal='#{calendar}' search --military --tsv --details={end,length,description,url} #{query} #{from.strftime("%Y-%m-%d")} #{to.strftime("%Y-%m-%d")}")
  .split("\n")
  .filter{|line| line != ""}
  .map do |line|
    Event.new(line)
  end
end


output = ""
case action
  when "list"
    output = execute "list"
  
  when "search"
    from = options[:from] ? DateTime.parse(options[:from]) : DateTime.now
    to = options[:to] ? DateTime.parse(options[:to]) : nil
    events = search_events(param, calendar: options[:calendar], from: from, to: to)
    hours = events.map(&:duration).sum / 60.0
    working_days = hours / 8.0
    output = (events.map(&:to_s)+[
      "#{events.count} event(s)",
      "#{working_days} working day(s), #{hours} hour(s)",
    ]).join("\n")

  when "daily-summary"
    today = !param.empty? ? DateTime.parse(param) : DateTime.now
    tomorrow = (today + 1)
    output = ["Daily summary #{today.strftime(DATE_FORMAT)}\n\n"]
    CALENDARS.each do |name, calendar|
      output << "#{name}"+"\n"
      events = search_events("'*'", calendar: calendar, from: today, to: tomorrow)
      events.each_with_index do |event, index| 
        output << "#{event.from.strftime(TIME_FORMAT)}-#{event.to.strftime(TIME_FORMAT)} #{event.title}"
        # add a line if there is a gap between events #todo
        #event_next = events[index+1]
        #event_next_span = event_next ? (event_next.from - event.to) * 60 : 0
        #output << "event_next_span #{event_next_span}"
        #output << "###" if event_next_span > 1
      end
      available_hours = (8-events.map(&:duration).sum/60.0)
      output << "available hours: #{'%.2f' % available_hours}h"
      output << "\n"
    end
    output.join("\n")
end


binding.pry if options[:debug]
puts output

events&.first&.open! if options[:openfirst]
