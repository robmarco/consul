class Audit < ActiveRecord::Base
  has_many :statements
end
