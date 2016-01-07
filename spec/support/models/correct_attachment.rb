class CorrectAttachment < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  validates :name, uniqueness: { scope: :attachable }
end
