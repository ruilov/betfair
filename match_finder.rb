# looks a competition in betfair, and finds matches and at what time those matches will run

require "rubygems"
require "net/http"
require "uri"
require 'nokogiri'
require "./net.rb"
require "./utils.rb"

def webpage_request(competition_path) 
  uri = URI.parse(competition_path)
  path = Net::make_path(uri)
  http = Net::HTTP.new(uri.host)
  res = http.get(path)
  doc = Nokogiri::HTML(res.body)
  return doc
end

def parse_webpage(doc,match_dict)
  current_date_str = nil
  rows = doc.xpath("//h2[@class=\"competition-header open\"]")[0].parent.parent.parent.parent.xpath(".//tbody")
  rows.each do |row|
    date_header = row.xpath(".//h2[@class=\"competition-header open\"]")
    if(date_header.length>0) then
      current_date_str = date_header[0].content.strip
    else
      if current_date_str == nil; next end
      
      home_name = row.xpath(".//span[@class=\"home-team\"]")
      if(home_name.length==0); next end
      home_name = home_name[0].content.strip
      
      away_name = row.xpath(".//span[@class=\"away-team\"]")
      if(away_name.length==0); next end
      away_name = away_name[0].content.strip
      
      start_time = row.xpath(".//span[@class=\"start-time \"]")
      if(start_time.length==0); next end
      start_time = start_time[0].content.strip
      if(start_time.end_with?"'") then
        t = get_now()
        t -= 60 * start_time.gsub("'","").to_i
        start_time = t.strftime("%H:%M")
      end
      
      event_link = row.xpath(".//a[@title=\"View full market\"]")
      if(event_link.length==0); next end
      event_link = event_link[0]["href"]
      
      if(current_date_str != "Today") then
        split = current_date_str.split(",")
        if(split.length < 2); next end
        date_str = split[1].strip
        date = Date.parse(date_str)
      else
        date = Date.today()
      end
      hour = start_time.split(":")[0].to_i
      minutes = start_time.split(":")[1].to_i
      # puts start_time
      time = Time.mktime(0,minutes,hour,date.day,date.month,date.year,nil,nil,true,"EST")   
      
      team_names = home_name.gsub(" ","_") + "_x_" + away_name.gsub(" ","_")
      filename = date.to_s.gsub("-","_")
      filename += "_" + team_names
      # puts "#{time} | #{home_name} | #{away_name} | #{filename}"
      
      if(!match_dict.has_key? date) then
        match_dict[date] = {}
      end
      
      if(!match_dict[date].has_key?team_names); puts "new key on #{date} and #{start_time}: #{team_names}" end
      match_dict[date][team_names] = {
        :filename => filename,
        :time => time,
        :home_name => home_name,
        :away_name => away_name,
        :event_link => event_link
      }
    end
  end
  return match_dict
end

def write_results(match_dict,filename) 
  output_file = File.new(filename,"w")
  match_dict.each_key do |date| 
    match_dict[date].each_pair do |team_names,info|
      filename = info[:filename]
      time = info[:time]
      home_name = info[:home_name]
      away_name = info[:away_name]
      event_link = info[:event_link]
      puts "#{date} | #{filename} | #{time} | #{home_name} | #{away_name} | #{event_link}"
      output_file.write(date.to_s + " | " + filename + " | " + time.to_s + " | " + home_name + " | " + away_name + " | " + event_link + "\n")
    end  
  end
  output_file.close()
end

match_dict = load_match_list("./match_list.txt")
competition_path = "http://www.betfair.com/exchange/football/competition?id=2490975"
doc = webpage_request(competition_path)
new_match_dict = parse_webpage(doc,match_dict)
write_results(new_match_dict,"./match_list.txt")


