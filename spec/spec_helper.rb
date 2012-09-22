require 'simplecov'
require 'rspec'
require 'faker'
require 'bitly'
require 'debugger'

files = Dir[ "#{Dir.pwd}/spec/support/**/*.rb" ]
files.each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) { $VERBOSE=nil }
end

SimpleCov.start
require 'social_msg/version'
require 'social_msg'

