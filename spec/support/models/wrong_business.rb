class WrongBusiness < ActiveRecord::Base
  validates :name, uniqueness: { scope: [:city, :state] }
end