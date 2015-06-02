require 'nokogiri'

describe "html output" do 
  before :all do
    html_file = File.open("index.html")
    @page = Nokogiri::HTML(html_file)
    html_file.close
  end

  it "contains a head tag" do
    expect(@page.css('head').count).to eq(1)
  end

  it "contains a body tag" do
    expect(@page.css('body').count).to eq(1)
  end
end
