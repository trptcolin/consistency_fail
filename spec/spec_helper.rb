$:<< File.expand_path('..', __FILE__)
$:<< File.expand_path('../../lib', __FILE__)

require 'rubygems'

def fake_ar_model(name, options = {})
  double("AR model: #{name}", options.merge(:name => name))
end

def fake_index_on(columns, options = {})
  double("index on #{columns.inspect}", options.merge(:columns => columns))
end

