require_relative "trello_newsletter/version"
require_relative "meta.rb"
require_relative "post.rb"
require_relative "html_stitcher.rb"
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
    #headlines_list = lists.select { |n| n.attributes[:name] == "Headlines" }.first
    content_lists = lists.reject { |n| REJECTED_LISTS.include?(n.attributes[:name]) }
    callouts = lists.find { |n| n.attributes[:name] == "Callouts" }
    sponsors = lists.find { |n| n.attributes[:name] == "Sponsors" }

    puts "starting html output"
    html_output(meta, content_lists, callouts, sponsors)
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


  def html_output(meta, content_lists, callouts, sponsors)
    template = File.open("index.html", "w")
    html_stitch = HtmlStitcher.new
    template.puts(html_stitch.head)
    template.puts(html_stitch.body_start(meta))
    content_lists.each do |list|
      template.puts "<tr>"
      template.puts "<td valign=\"top\">"
      template.puts "<div class=\"clearfix\">"
      template.puts "<h1 class=\"h1\">#{list.name}</h1>"
      template.puts"<hr />"
      template.puts "</div>"
      list.cards.each do |card|
        post = Post.new(card)
        if post.attachment
          stripped_post = post.body.gsub("<p>","").gsub("</p>","")
          template.puts "<div class=\"clearfix\" style=\"clear:both;\">"
          template.puts "    <a href=\"#{post.link}\"><h2 class=\"h2\">#{post.title}</h2></a>"
          template.puts "    <p class=\"photo-content\">#{stripped_post}</p>"
          template.puts "    <a href=\"#{post.link}\" target=\"_blank\"><img class=\"photo\" src=\"#{post.attachment}\" alt=\"Blog guest picture\"></a>"
          template.puts "</div>"
        else
          template.puts "<div class=\"clearfix\">"
          template.puts "    <a href=\"#{post.link}\"><h2 class=\"h2\">#{post.title}<span class=\"label-#{post.label.gsub(" ", "-") if post.label}\">#{post.label}</span></h2></a>"
          template.puts "    #{post.body}"
          template.puts "</div>"
        end
      end
      template.puts "</td>"
      template.puts "</tr>"
    end
    template.puts "<tr>"
    template.puts "<td valign=\"top\">"
    template.puts "<div class=\"clearfix\">"
    template.puts "<h1 class=\"h1\">#{sponsors.name}</h1>"
    template.puts"<hr />"
    template.puts "</div>"
    sponsors.cards.each do |card|
      post = Post.new(card)
      stripped_post = post.body.gsub("<p>","").gsub("</p>","")
      template.puts "<div class=\"clearfix\" style=\"clear:both;\">"
      template.puts "    <a href=\"#{post.link}\"><h2 class=\"h2\">#{post.title}</h2></a>"
      template.puts "    <p class=\"photo-content\">#{stripped_post}</p>"
      template.puts "    <a href=\"#{post.link}\" target=\"_blank\"><img class=\"photo\" src=\"#{post.attachment}\" alt=\"Blog guest picture\"></a>"
      template.puts "</div>"
    end
    template.puts "</td>"
    template.puts "</tr>"
    template.puts "<tr>"
    template.puts "<td valign=\"top\">"
    template.puts "<div class=\"clearfix\">"
    template.puts "<h1 class=\"callout-title\">Join us</h1>"
    template.puts "</div>"
    callouts.cards.each do |card|
      post = Post.new(card)
      template.puts "<div class=\"callout\">"
      template.puts "    <a href=\"#{post.link}\"><h2 class=\"h2\">#{post.title}</h2></a>"
      template.puts "    #{post.body}"
      template.puts "</div>"
    end
    template.puts "</td>"
    template.puts "</tr>"
    template.puts "<tr>"
    template.puts "</tr>"
    template.puts(html_stitch.body_end)
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
