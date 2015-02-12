class CorrectPost < ActiveRecord::Base
  has_one :correct_attachment, as: :attachable
end