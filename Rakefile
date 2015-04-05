require "bundler/gem_tasks"
require_relative "lib/trello_newsletter"

# http://bundler.io/bundler_setup.html
Bundler.setup

desc "Generate HTML from Trello board"
task :generate do
  TrelloNewsletter.new.generate
end

desc "Create new mailchimp campaign from HTML and CSS zip folder"
task :create_campaign do
  TrelloNewsletter.new.export_to_mailchimp
end
