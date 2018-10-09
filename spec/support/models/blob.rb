class Blob < ActiveRecord::Base
  require_dependency 'blob/edible'
  include Edible
end
