require 'rspec'
require 'faker'
require 'bitly'
require 'debugger'
require 'social_msg/version'
require 'social_msg'

files = Dir[ "#{Dir.pwd}/spec/support/**/*.rb" ]
files.each { |f| require f }

$VERBOSE = nil

