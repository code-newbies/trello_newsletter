require "maruku"

class Post
  attr_reader :card
  def initialize(card)
    @card = card
  end

  def title
    card.name
  end

  def body
    text = card.desc
    md_to_html(text)
  end

  def sponsored?
    card.labels.any? { |label| label.name == "Sponsored" }
  end

  private

  def md_to_html(text)
    Maruku.new(text).to_html
  end
end
