$:.unshift File.expand_path("../..", __FILE__)

require 'localbitcoins'
require 'rest-client'
require 'webmock'
require 'webmock/rspec'

RSpec.configure do |config|
  config.color_enabled = true
end
