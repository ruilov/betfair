require 'active_record'

class OddEntry < ActiveRecord::Base
  self.table_name = 'betfair_odds'
  attr_accessible :id, :time, :type, :team, :quote, :size 
end