require 'rspec'
require 'faker'
require 'debugger'
require 'social_msg/version'
require 'social_msg'

support = "#{Dir.pwd}/spec/support/**/*.rb"
files = Dir[ support ]
files.each { |f| require f }

