require "rspec"
require "rspec/core"
require "vcr"
require "pry"
require_relative "../lib/trello_newsletter.rb"
# Dir["#{Dir.pwd}/lib/*.rb"].each {|file| require file}

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data("MAILCHIMP_API_KEY") { ENV["MAILCHIMP_KEY"] }
  config.filter_sensitive_data("TRELLO_MEMBER_TOKEN") { ENV["TRELLO_MEMBER_TOKEN"] }
  config.filter_sensitive_data("TRELLO_DEVELOPER_PUBLIC_KEY") { ENV["TRELLO_DEVELOPER_PUBLIC_KEY"] }
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
