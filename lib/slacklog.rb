module Slacklog
  NAME = "slacklog"
  AUTHOR = "Pat Brisbin <pbrisbin@gmail.com>"
  VERSION = "0.1"
  LICENSE = "MIT"
  DESCRIPTION = "Slack backlog"

  class << self
    attr_accessor :token
    attr_accessor :servers
  end

  def self.append_history(weechat, buffer_id)
    weechat_api = WeechatAPI.new(weechat)

    if buffer = weechat_api.find_buffer(buffer_id)
      if servers.include?(buffer.server)
        slack_api = SlackAPI.new(token)
        slack_api.find_room(buffer.name).history.each do |message|
          buffer.print("[#{message.nick}]: #{message.body}")
        end
      end
    end
  end
end
