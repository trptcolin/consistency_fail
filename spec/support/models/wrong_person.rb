class WrongPerson < ActiveRecord::Base
  validates :email, :name, uniqueness: { scope: [:city, :state] }
end