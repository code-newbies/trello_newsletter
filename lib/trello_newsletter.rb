require_relative "trello_newsletter/version"
require_relative "meta.rb"
require_relative "post.rb"
require "trello"
require "mailchimp"

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

class TrelloNewsletter
  def board_name
    "CodeNewbie Newsletter"
  end

  def board
    Trello::Board.all.find { |b| b.name == board_name }
  end

  def generate
    lists = board.lists

    meta_list = lists.select { |n| n.attributes[:name] == "Meta" }.first
    meta = Meta.new(meta_list)

    headlines_list = lists.select { |n| n.attributes[:name] == "Headlines" }.first
    html_output(meta, headlines_list)
    puts "Finished generating issue"
  end

  def html_output(meta, headlines_list)
    template = File.open("index.html", "w")
    template.puts <<-DOC.gsub(/^ {4}/, '')
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
      </head>
      <body>
        <img src=#{meta.header_image} alt="Header Image">
        <p>Published at: #{meta.published_at}</p>
        <p>#{meta.intro_text}</p>
    DOC
    headlines_list.cards.each do |card|
      post = Post.new(card)
      template.puts "   <div>"
      template.puts "    <h2>#{post.title}</h2>"
      template.puts "    #{post.body}"
      template.puts "   </div>"
    end
    template.puts "<p>#{meta.outro_text}</p>"
    template.puts "FINISHED!"
    template.close
  end

  # https://apidocs.mailchimp.com/api/2.0/campaigns/create.php
  # https://apidocs.mailchimp.com/api/2.0/lists/list.php
  def export_to_mailchimp
    mailchimp = Mailchimp::API.new(MAILCHIMP-API-KEY)
    all_lists = mailchimp.lists.list
    from_website_list = all_lists.select { |n| n.attributes['data']['name'] == "From Website" }
    # Zip index.html and css
    # create new mailchimp campaign and import the zip folder to it.
    # Line 1539 in Mailchimp api gem source code
    # Everything in the tracking option defaults to true except text clicks.
    mailchimp.campaigns.create("regular", {list_id: from_website_list, subject: "Subject line", 
                                           from_email: "hello@codenewbie.org", from_name: "#CodeNewbie", to_name: "*|FNAME|*",
                                            tracking: {text_clicks: true}},
                                           {archive: "archive name", archive_type: "zip"})
  end 
end
