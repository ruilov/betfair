require 'active_record'

class OddsMatch < ActiveRecord::Base
  self.table_name = 'betfair_matches'
  attr_accessible :id, :date, :home_team, :away_team, :start_time
end

class OddsEntry < ActiveRecord::Base
  self.table_name = 'betfair_odds'
  attr_accessible :id, :match_id, :time, :entry_type, :team, :quote, :size
end