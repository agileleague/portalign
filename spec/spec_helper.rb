require 'rspec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'portalign')

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = 'progress'
end

