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
  time = get_now().strftime("%Y-%m-%d %H:%M:%S")
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

def last_match_update(filename)
  begin
    last_line = IO.readlines(filename)[-1]
    return parse_match_line(last_line)
  rescue Exception => e
    return nil
  end
end

start_time_offset = -1.0
if(ARGV.length > 0) then
  start_time_offset = ARGV[0].to_f
end

end_time_offset = 2.5
if(ARGV.length > 1) then
  end_time_offset = ARGV[1].to_f
end

while(true) do
  now = get_now()
  today = Date.parse(now.to_s)
  begin
    match_list = load_match_list("./match_list.txt")
    match_list.each_key do |date|
      match_list[date].each_pair do |team_names,info|
        if date == today then
          # if the date is toady, then we do some real time logging
          time_diff = (now-info[:time])/60/60  # in hours
          # puts "#{info[:time]} | #{now} | #{time_diff} | #{start_time_offset}"
          if time_diff < start_time_offset; next end
          if time_diff > end_time_offset; next end
          puts "#{date} | #{info[:filename]} | #{info[:time]} | #{info[:home_name]} | #{info[:away_name]} | #{info[:event_link]}"
          update_match(info[:event_link],info[:filename])
        elsif date - today > 0
          # if the date is not today then we only collect is every 12 hours
          last_info = last_match_update(info[:filename])
          time_diff = 1000
          if(last_info!=nil) then
            time_diff = (now - last_info[:time])/60/60 # in hours
          end
          if time_diff > 1/60
            puts "#{date} | #{info[:filename]} | #{info[:time]} | #{info[:home_name]} | #{info[:away_name]} | #{info[:event_link]}"
            update_match(info[:event_link],info[:filename]) 
          end
        end  
      end
    end
  rescue Exception => e
    puts "Error at #{now}"
    puts e
    puts e.backtrace.inspect
  end
  puts "#{now}: sleeping..."
  sleep(60) # in seconds
end