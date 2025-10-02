class Entry < ActiveRecord::Base
  attr_accessible :entryname, :maxpoints, :points, :tiebreaker
  validates :entryname, :presence => true
  validates :tiebreaker, :presence => true,
    :numericality => true
  
  belongs_to :pool
  #has_many :picks
  has_many :picks, :dependent => :destroy

  validates_uniqueness_of :entryname, :scope => [:pool_id]
end
