describe TrelloNewsletter do
  describe "#generate" do
    it "generates the html file" do
      newsletter = TrelloNewsletter.new
      VCR.use_cassette("Trello boards", :allow_playback_repeats => true) do
        newsletter.generate
      end
      expect(File.exist?("index.html")).to be_present
    end
  end
end
