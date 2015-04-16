require "bundler/gem_tasks"
require "pry"
require_relative "lib/trello_newsletter"

# http://bundler.io/bundler_setup.html
Bundler.setup

# Setup objects
@newsletter = TrelloNewsletter.new
desc "Generate HTML from Trello board"
task :generate do
  @newsletter.generate
  @email_subject = @newsletter.newsletter_title
  @newsletter.export_to_mailchimp(@email_subject)
end
