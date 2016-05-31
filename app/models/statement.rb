class Statement < ActiveRecord::Base
  belongs_to :audit
  attr_accessor :attachment

  validates :filename, presence: true
  validates :audit, presence: true
end
