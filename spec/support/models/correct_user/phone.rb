require_relative "../correct_user"
class CorrectUser::Phone < ActiveRecord::Base
  belongs_to :phoneable, polymorphic: true
end
