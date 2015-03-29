#require "trello_newsletter/version"
require "trello"
require "maruku"
require "pry"

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

class Meta
  attr_reader :cards
  def initialize(list)
    @cards = list.cards
  end 

  def header_image
    text = find_card("Header Image").desc
    # removing the tags because we just want the link
    md_to_html(text).gsub("\n<p>","").gsub("</p>\n","")
  end

  def published_at
    find_card("Date").desc
  end

  def intro_text
    text = find_card("Intro").desc
    md_to_html(text)
  end

  def outro_text
    text = find_card("Outro").desc
    md_to_html(text)
  end
  
  private

  def find_card(name)
    cards.find { |card| card.name == name }
  end

  def md_to_html(text)
    Maruku.new(text).to_html
  end
end

class TrelloNewsletter
  boards = Trello::Board.all
  puts boards.count
  board_name = "CodeNewbie Newsletter"
  board = Trello::Board.all.find { |b| b.name == board_name }
  lists = board.lists
  meta_list = lists.select { |n| n.attributes[:name] == "Meta" }.first
  meta = Meta.new(meta_list)
end

