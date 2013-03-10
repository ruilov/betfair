#!/usr/bin/env ruby

require "rubygems"
require "net/http"
require "uri"
require 'nokogiri'
require "./net.rb"
require "./utils.rb"

STDOUT.sync = true

def update_match(link,filename) 
  file = File.new(filename,"a")
  time = Time.new.strftime("%Y-%m-%d %H:%M:%S")
  uri = URI.parse("http://www.betfair.com" + link)
  path = Net::make_path(uri)
  http = Net::HTTP.new(uri.host)
  res = http.get(path)
  doc = Nokogiri::HTML(res.body)

  # ff = File.new("./test.html","w")
  # ff.write(doc)
  # ff.close()
  
  # ff = File.new("./test.html","r")
  # doc = ""
  # while(line = ff.gets); doc += line end
  # doc = Nokogiri::HTML(doc)
  
  matched_val = "nil"
  in_play = "not_in_play"
  matched_val_nodes = doc.xpath("//span[@class=\"total-matched-val\"]")
  if(matched_val_nodes.length > 0)
    matched_val = matched_val_nodes[0].content.strip.gsub(",","")
    
    if(matched_val_nodes[0].parent.parent.xpath(".//span[@title=\"In-play\"]").length > 0)
        in_play = "in_play"
    end
  end
  
  puts "#{time} | #{matched_val} | #{in_play}"
  file.write(time + " | " + matched_val + " | " + in_play + "\n")
  
  runners = doc.xpath("//td[@class=\"runner-name\"]")
  runners.each do |runner|
    # team name
    name = runner.xpath(".//span[@class=\"sel-name\"]")[0].content.strip
    
    # collect all the possible bets
    bets = ""
    backs = runner.parent.xpath(".//button[@data-bettype=\"B\"]")
    backs.each do |back| 
      price = back.xpath(".//span[@class=\"price\"]")[0].content.strip
      size = back.xpath(".//span[@class=\"size\"]")[0].content.strip.gsub(",","")
      bets += "B | " + price + " | " + size + " | "
    end
    lays = runner.parent.xpath(".//button[@data-bettype=\"L\"]")
    lays.each do |back| 
      price = back.xpath(".//span[@class=\"price\"]")[0].content.strip
      size = back.xpath(".//span[@class=\"size\"]")[0].content.strip.gsub(",","")
      bets += "L | " + price + " | " + size + " | "
    end
    puts "#{time} | #{name} | #{bets}"
    file.write(time + " | " + name + " | " + bets + "\n")
  end
  file.close()
end

min_time_diff = 1.0
if(ARGV.length > 0) then
  min_time_diff = ARGV[0].to_f
end

max_time_diff = -2.5
if(ARGV.length > 1) then
  max_time_diff = ARGV[1].to_f
end

while(true) do
  now = Time.now()
  begin
    match_list = load_match_list("./match_list.txt")
    match_list.each_key do |date| 
      match_list[date].each_pair do |team_names,info|
          filename = info[0]
          time = info[1]
          home_name = info[2]
          away_name = info[3]
          event_link = info[4]
          time_diff = (time - now)/60/60  # in hours
          # puts "#{time} | #{now} | #{time_diff} | #{min_time_diff}"
          if time_diff > min_time_diff; next end
          if time_diff < max_time_diff; next end
          puts "#{date} | #{filename} | #{time} | #{home_name} | #{away_name} | #{event_link}"
          update_match(event_link,filename)
      end
    end
  rescue Exception => e
    puts "Error at #{now}"
    puts e
    puts e.backtrace.inspect
  end
  sleep(60) # in seconds
end