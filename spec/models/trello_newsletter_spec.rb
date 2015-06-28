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

  describe "#run" do
    it "calls the generate and export methods" do
      newsletter = TrelloNewsletter.new
      allow(newsletter).to receive(:generate)
      allow(newsletter).to receive(:export_to_mailchimp)

      newsletter.run

      expect(newsletter).to have_received(:generate)
      expect(newsletter).to have_received(:export_to_mailchimp)
    end
  end
end
