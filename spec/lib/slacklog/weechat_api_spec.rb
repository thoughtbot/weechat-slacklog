require "spec_helper"

describe Slacklog::WeechatAPI do
  context "#find_buffer" do
    it "finds a Buffer by ID" do
      weechat = double("Weechat")
      allow(weechat).to receive("buffer_get_string").with("1", "name").
        and_return("thoughtbot.#general")
      api = Slacklog::WeechatAPI.new(weechat)

      buffer = api.find_buffer("1")

      expect(buffer.server).to eq "thoughtbot"
      expect(buffer.name).to eq "#general"
    end
  end

  context Slacklog::WeechatAPI::Buffer do
    context "#print" do
      it "prints the message to the buffer" do
        weechat = double("Weechat", print: nil)
        buffer = Slacklog::WeechatAPI::Buffer.new(weechat, "1", "", "")

        buffer.print("hello world")

        expect(weechat).to have_received(:print).with("1", "hello world")
      end
    end
  end
end
