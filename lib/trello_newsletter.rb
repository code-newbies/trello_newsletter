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
  headlines_list.cards.each do |card|
    post = Post.new(card)
    binding.pry
  end
end

