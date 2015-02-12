class CorrectAccount < ActiveRecord::Base
  validates :email, uniqueness: true
end