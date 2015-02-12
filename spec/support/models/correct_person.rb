class CorrectPerson < ActiveRecord::Base
  validates :email, uniqueness: { scope: [:city, :state] }
end