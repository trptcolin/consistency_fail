class WrongAccount < ActiveRecord::Base
  validates :email, uniqueness: true
end