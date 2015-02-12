class WrongPost < ActiveRecord::Base
  has_one :wrong_attachment, as: :attachable
end