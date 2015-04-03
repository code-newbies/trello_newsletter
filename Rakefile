require "bundler/gem_tasks"
require_relative "lib/trello_newsletter"

# http://bundler.io/bundler_setup.html
Bundler.setup

desc "Generate HTML from Trello board"
task :generate do
  TrelloNewsletter.new.generate
end
