class Pick < ActiveRecord::Base
  attr_accessible :game, :pick, :round

  belongs_to :entry
  #belongs_to :pool
  #belongs_to :pickable, :polymorphic => true

  validates_uniqueness_of :game, :scope => [:round, :pick, :entry_id]

  def samePick?(other)
    if !other.nil? && !other.pick.nil? && !:pick.nil?
      if other.pick == :pick
        return true
      end
    end
    return false
  end
end
