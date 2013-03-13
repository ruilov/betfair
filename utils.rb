require "date.rb"
require "time.rb"

def load_match_list(filename) 
  file = File.new(filename,"r")
  matches = {}
  while(line = file.gets) do
    vals = parse_match_list_line(line)
    if(!matches.has_key? vals[:date]); matches[vals[:date]] = {} end
    matches[vals[:date]][vals[:team_names]] = {
      :filename => vals[:filename],
      :time => vals[:time],
      :home_name => vals[:home_name],
      :away_name => vals[:away_name],
      :event_link => vals[:event_link]
    }
  end
  return matches
end

def parse_match_list_line(line)
  split = line.split("|")
  date = Date.parse(split[0].strip)
  filename = split[1].strip
  time = Time.parse(split[2].strip)
  home_name = split[3].strip
  away_name = split[4].strip
  event_link = split[5].strip
  team_names = home_name.gsub(" ","_") + "_x_" + away_name.gsub(" ","_")
  return {
    :date => date,
    :filename => filename,
    :time => time,
    :home_name => home_name,
    :away_name => away_name,
    :event_link => event_link,
    :team_names => team_names
  }
end

def parse_match_line(line)
  split = line.split("|")
  ans = {
    :time => Time.parse(split[0].strip),
    :name => split[1].strip,
    :bets => [],
  }
  (2...split.length).step(3) do |i|
    ans[:bets] << {:type => split[i], :price => split[i+1], :size => split[2]}
  end
  return ans
end

MY_TZ_OFFSET = 14400 # note that below there's also a call in match_finder.rb I pass EST and true for DST

def get_now() 
    t = Time.now()
    t -= (t.gmtoff+MY_TZ_OFFSET)
    return t
end

def get_today()
  return Date.parse(get_now.strftime('%Y/%m/%d'))
end
