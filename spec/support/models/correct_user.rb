class CorrectUser < ActiveRecord::Base
  has_one :correct_address
  has_one :credential
  has_one :phone, as: :phoneable

  validates :email, uniqueness: true
end
