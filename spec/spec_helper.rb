require "rspec"

class Weechat
  WEECHAT_RC_OK = 1
end

module MockWeechat
  def stub_weechat
    allow(Weechat).to receive(:register)
  end
end

RSpec.configure do |conf|
  conf.include(MockWeechat)
end
