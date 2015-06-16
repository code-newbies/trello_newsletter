require "rspec"
require "rspec/core"
require "vcr"
require "pry"
require_relative "../lib/trello_newsletter.rb"
# Dir["#{Dir.pwd}/lib/*.rb"].each {|file| require file}

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.order = :random
end
