class Team < ActiveRecord::Base
  attr_accessible :game, :name

  belongs_to :pool
end
