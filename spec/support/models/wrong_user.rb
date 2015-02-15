class WrongUser < ActiveRecord::Base
  has_one :wrong_address
end