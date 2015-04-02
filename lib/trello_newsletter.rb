require_relative "trello_newsletter/version"
require_relative "meta.rb"
require_relative "post.rb"
require "trello"
require "pry"

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

class TrelloNewsletter
  boards = Trello::Board.all
  puts boards.count
  board_name = "CodeNewbie Newsletter"
  board = Trello::Board.all.find { |b| b.name == board_name }
  lists = board.lists

  meta_list = lists.select { |n| n.attributes[:name] == "Meta" }.first
  meta = Meta.new(meta_list)

  headlines_list = lists.select { |n| n.attributes[:name] == "Headlines" }.first
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
  puts "Finished generating issue"
end

