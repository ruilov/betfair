require './db_utils.rb'
require './models.rb'
require './utils.rb'
require 'fileutils'

def parse_file(filename)
  puts filename

  # in the first pass get the match info
  home_team = nil
  away_team = nil
  start_time = nil
  
  file = File.new(filename,"r")
  while(line=file.gets) do
    parts = line.split("|")
    
    if( parts[1] =~ / GBP (\d+) /) then
      if(start_time==nil) then
        in_play = (parts[-1].strip=="in_play")
        if(in_play); start_time = Time.parse(parts[0].strip) end    
      end
    else
      if(home_team==nil); home_team = parts[1].strip
      elsif(away_team==nil); away_team = parts[1].strip
      end
    end
  end
  
  if(start_time==nil || home_team==nil || away_team==nil) then
    puts "failed to parse #{filename}"
    puts "#{start_time} | #{home_team} | #{away_team}"
    return false
  end
  
  match = OddsMatch.new(:date => Date.parse(start_time.strftime('%Y/%m/%d')), :home_team => home_team, :away_team => away_team, :start_time => start_time)
  match[:id] = DB::save_uniq(match,[:date,:home_team,:away_team])
  
  # now create the match entrys
  file = File.new(filename,"r")
  while(line=file.gets) do
    # puts line
    parts = line.split("|")
    
    # get the time for this entry
    time = Time.parse(parts[0].strip)
    dT = (time - start_time)/60
    
    # if it's GBP something, then it's a record of the amount of money matched so far
    if( parts[1] =~ / GBP (\d+) /) then
      matched = $1.to_i
      
      entry = OddsEntry.new(:match_id => match[:id], :time => dT, :entry_type => "matched", :size => matched)
      res = OddsEntry.where(:time => (dT-0.01)..(dT+0.01), :match_id => entry[:match_id], :entry_type => entry[:entry_type])
      if(res.length==0) then
        DB::save(entry) 
      end
    else
      # otherwise it's the stack for one of the teams
      team = parts[1].strip
      if(team=="nil"); next end
      
      res = OddsEntry.where(:match_id => match[:id], :entry_type => "back1", :team => team, :time => (dT-0.01)..(dT+0.01))
      if(res.length>0); next end
      
      (3..18).step(3) do |i|
        quote = parts[i].strip.to_f
        size = parts[i+1].gsub("£","").strip.to_i
        type = "back#{4-i/3}"
        if(i>9) then type = "lay#{i/3-3}" end
        entry = OddsEntry.new(:match_id => match[:id], :time => dT, :team => team, :entry_type => type, :size => size, :quote => quote)
        DB::save(entry)
      end
    end
  end
  return true
end

DB::init()
dir = "./results"
proc_dir = "./processed_results"

Dir.foreach(dir) do |filename|
  if( !filename.start_with? "2013"); next end
  
  fullname = dir+"/"+filename
  answer = parse_file(fullname)
  if(answer) then
    FileUtils.cp(fullname,proc_dir+"/"+filename)
    FileUtils.rm(fullname)
  end
end