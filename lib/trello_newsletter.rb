require_relative "trello_newsletter/version"
require_relative "meta.rb"
require_relative "post.rb"
require_relative "html_factory.rb"
require "pry"
require "trello"
require "gibbon"
require "zip"
require "base64"

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

class TrelloNewsletter
  REJECTED_LISTS = [ "Meta", "Mailchimp doc info", "Callouts", "Sponsors" ]

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

    @title = meta.title
    content_lists = lists.reject { |n| REJECTED_LISTS.include?(n.attributes[:name]) }
    callouts = lists.find { |n| n.attributes[:name] == "Callouts" }
    sponsors = lists.find { |n| n.attributes[:name] == "Sponsors" }
    newsletter_content = {content_lists: content_lists, callouts: callouts,
                          sponsors: sponsors}

    puts "starting html output"
    html_output(meta, newsletter_content)
    puts "zippity zip zip"
    zip_output
    puts "Finished generating issue"
  end

  def newsletter_title
    @title
  end

  def zip_output # It would be nice to pass in a filename rather than hardcoding it
    # This tells zip to overwrite the zip
    Zip.continue_on_exists_proc = true # Should put this in a configuration file.
    Zip::File.open("newsletter_html.zip", Zip::File::CREATE) do |zip|
      zip.add("index.html", "./index.html")
      if File.exists?("header_image.png")
        zip.add("header_image.png", "./header_image.png")
      end
    end
  end


  def html_output(meta, newsletter_content)
    template = File.open("index.html", "w")
    html_page = HtmlFactory.new
    template.puts(html_page.head)
    template.puts(html_page.body_start(meta))
    template.puts(html_page.content(newsletter_content))
    template.puts(html_page.body_end)
    template.close
  end

  # https://apidocs.mailchimp.com/api/2.0/campaigns/create.php
  # https://apidocs.mailchimp.com/api/2.0/lists/list.php
  def export_to_mailchimp(email_subject)
    puts "exporting to mailchimp!"
    gb = Gibbon::API.new(ENV['MAILCHIMP_KEY'])
    recipient_list = gb.lists.list({:filters => {:list_name => "From Website"}})
    list_id = recipient_list['data'].first['id']
    zipfile = File.open("newsletter_html.zip", "r") { |fp| fp.read }
    begin
      gb.campaigns.create({type: "regular", options: {list_id: list_id, subject: email_subject, 
                                                    from_email: "hello@codenewbie.org", from_name: "#CodeNewbie", 
                                                    generate_text: true, inline_css: true}, 
                                                    content: {archive:Base64.encode64(zipfile) , archive_type: "zip"}})
    rescue Gibbon::MailChimpError => e
      puts "The zip file upload errored: #{e.message}"
      puts "Try to upload contents of index.html"
      file = File.open("index.html", "r")
      contents = file.read
      gb.campaigns.create({type: "regular", options: {list_id: list_id, subject: email_subject, 
                                                    from_email: "hello@codenewbie.org", from_name: "#CodeNewbie", 
                                                    generate_text: true, inline_css: true}, 
                                                    content: {html: contents}})
    end
  end
end
