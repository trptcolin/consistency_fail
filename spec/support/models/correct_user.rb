class CorrectUser < ActiveRecord::Base
  has_one :correct_address

  validates :email, uniqueness: true
end
