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
    
  markets = doc.xpath("//em[@class=\"market-title\"]")
  markets.each do |market| 
    if(market.content.strip!="Match Odds") then next end;
    odds_table = market.parent.parent.next.next.xpath(".//table[@class=\"runner-table\"]")[0]
    rows = odds_table.xpath(".//tr[@class]")
    
    rows.each do |row|
      cols = row.xpath(".//td")
      name = cols[0].xpath(".//div[@class=\"runner-name\"]//span")[0].content
      
      back_price = cols[1].xpath(".//span[@class=\"price\"]")[0].content.strip
      lay_price = cols[2].xpath(".//span[@class=\"price\"]")[0].content.strip
      puts "#{time} | #{name} | #{back_price} | #{lay_price}"
      file.write(time.to_s + " | " + name + " | " + back_price + " | " + lay_price + "\n")
    end
    break
  end
  file.close()
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
          if time_diff > 1; next end
          puts "#{date} | #{filename} | #{time} | #{home_name} | #{away_name} | #{event_link}"
          update_match(event_link,filename)
      end
    end
  rescue Exception => e
    puts "Error at #{time}"
    puts e
    puts e.backtrace.inspect
  end
  sleep(60) # in seconds
end