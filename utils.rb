require "date.rb"
require "time.rb"

def load_match_list(filename) 
  file = File.new(filename,"r")
  matches = {}
  while(line = file.gets) do
    split = line.split("|")
    date = Date.parse(split[0].strip)
    filename = split[1].strip
    time = Time.parse(split[2].strip)
    home_name = split[3].strip
    away_name = split[4].strip
    event_link = split[5].strip
    team_names = home_name.gsub(" ","_") + "_x_" + away_name.gsub(" ","_")
    
    if(!matches.has_key? date); matches[date] = {} end
    matches[date][team_names] = [filename,time,home_name,away_name,event_link]
  end
  return matches
end