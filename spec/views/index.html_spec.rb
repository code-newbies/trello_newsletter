require "nokogiri"
require "spec_helper"

describe "html output" do 
  before :all do
    newsletter = TrelloNewsletter.new
    VCR.use_cassette("Newsletter generate", :allow_playback_repeats => true) do
      newsletter.generate
    end
    html_file = File.open("index.html")
    @page = Nokogiri::HTML(html_file)
    html_file.close
  end

  it "contains a head tag" do
    expect(@page.css("head").count).to eq(1)
  end

  it "contains a body tag" do
    expect(@page.css("body").count).to eq(1)
  end

  it "contains newsletter content" do
    expect(@page.text).to include("Podcast")
    expect(@page.text).to include("ICYMI")
    expect(@page.text).to include("callout")
    expect(@page.text).to include("Sponsors")
    expect(@page.text).to include("Join us")
    # Test for picture post method
    expect(@page.text).to include("photo-content")
    # Test for section title method
    expect(@page.search("hr").count).to be > 0
    # Test for callout content method
    expect(@page.text).to include("callout")
  end
end
