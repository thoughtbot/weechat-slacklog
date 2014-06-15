require "rspec"
require "webmock"
require_relative "../slacklog"

class Weechat
  WEECHAT_RC_OK = 1

  def self.print(*); end
end

RSpec.configure do |conf|
  conf.include(WebMock::API)

  conf.before(:each) do
    allow(Weechat).to receive(:config_get_plugin).and_return("")
    allow(Weechat).to receive(:hook_config)
    allow(Weechat).to receive(:hook_process)
    allow(Weechat).to receive(:hook_signal)
    allow(Weechat).to receive(:print)
    allow(Weechat).to receive(:register)
  end

  conf.after(:each) { API_TOKENS.clear }
end
