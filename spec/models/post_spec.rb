require 'spec_helper'

describe Post do
  it "instantiates a new post with a card" do
    post = Post.new("card")
    expect(post.card).to eq("card")
  end
end
