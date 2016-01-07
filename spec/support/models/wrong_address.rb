class CorrectAddress < ActiveRecord::Base
  belongs_to :correct_user

  validates :city, uniqueness: { scope: :correct_user }
end
