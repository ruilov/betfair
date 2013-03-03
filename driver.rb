#!/usr/bin/env ruby

require "rubygems"
require "net/http"
require "uri"
require 'nokogiri'
require "./net.rb"

if(ARGV.length==0) do id = "26967072"
else id = ARGV[0] end

STDOUT.sync = true

while(true) do
  time = Time.new.strftime("%Y-%m-%d %H:%M:%S")
  
  begin
    uri = URI.parse("http://www.betfair.com/exchange/football/event?id=" + id)
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
      end
      break  
    end
  rescue Exception => e
    puts "Error at #{time}"
    puts e
    puts e.backtrace.inspect
  end
  sleep(60) # in seconds
end

# file = File.new('./testpage.html','w')
# file.write(res.body)
# file.close
  
# file = File.new("./testpage.html","r")
# doc = ""
# while( line = file.gets); doc += line end
# doc = Nokogiri::HTML(doc)
# puts doc