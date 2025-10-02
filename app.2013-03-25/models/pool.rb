class Pool < ActiveRecord::Base
  attr_accessible :poolname, :teams_attributes

  has_many :teams, :dependent => :destroy
  accepts_nested_attributes_for :teams#, :reject_if => lambda { |a| a[:content].blank? }, :allow_destroy => true

  has_many :entries , :dependent => :destroy
end
