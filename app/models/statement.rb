class Statement < ActiveRecord::Base
  belongs_to :audit
  attr_accessor :attachment
end
