# $LOAD_PATH << '.'
require 'rubygems'
require 'active_record'

module DB
  def DB::save(record)
    # p record
    # puts "saving #{record.class}"
    # begin
      record.save    
    # rescue ActiveRecord::RecordNotUnique => e
      # puts "ERROR" 
      # puts e
    # end
  end
  
  def DB::save_uniq(record, cols)
    look_up = {}
    cols.each {|col| look_up[col] = record[col]}
    existing = record.class.where(look_up) 
    if existing.length == 0
      # puts "saving record"
      DB::save(record)
      existing = record.class.where(look_up)
    end
    return existing[0][:id]
  end
  
  def DB::init()
    $LOAD_PATH.each do |path|
      begin
        file = File.open(path + "/database.yml")
        dbconfig = YAML::load(file)
        ActiveRecord::Base.establish_connection(dbconfig)
        puts "database.yml from #{path}"
        return
      rescue
      end  
    end
  end
end