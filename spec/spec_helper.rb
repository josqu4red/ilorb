require "rubygems"
require "bundler/setup"
require "ilorb"
require "webmock/rspec"
require "pry"

RSpec.configure do |config|
  config.order = "random"
end
