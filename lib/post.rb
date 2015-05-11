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

  def attachment
    attachment = card.attachments.first
    if attachment
      attachment.attributes[:url]  # Any attachments are hosted by trello
    end
  end

  def label
    label = card.labels.first
    if label
      label.name
    end
  end

  def link
    comment_texts = card.actions({filter: 'commentCard'})
    comment_texts.collect do |comment|
      comment.data["text"] if comment.data["text"].include?("http")
    end.first
  end

  def sponsored?
    card.labels.any? { |label| label.name == "Sponsored" }
  end

  private

  def md_to_html(text)
    Maruku.new(text).to_html
  end
end
