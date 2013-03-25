require './db_utils.rb'
require './models.rb'
require './utils.rb'

DB::init()

entry = OddEntry.new(:time => get_now(), :type => "back", :team => "test", :quote => 1.1, :size => 11)
# DB::save(entry)