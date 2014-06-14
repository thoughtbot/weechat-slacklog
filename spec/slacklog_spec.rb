require "spec_helper"

describe "slacklog" do
  before do
    stub_weechat
    require_relative "../slacklog.rb"
  end

  context "#weechat_init" do
    it "registers itself with the Weechat class and returns OK" do
      ret = weechat_init

      expect(ret).to eq Weechat::WEECHAT_RC_OK
      expect(Weechat).to have_received(:register).with(
        Slacklog::NAME,
        Slacklog::AUTHOR,
        Slacklog::VERSION,
        Slacklog::LICENSE,
        Slacklog::DESCRIPTION,
        "", ""
      )
    end
  end
end
