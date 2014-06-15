module Slacklog
  NAME = "slacklog"
  AUTHOR = "Pat Brisbin <pbrisbin@gmail.com>"
  VERSION = "0.1"
  LICENSE = "MIT"
  DESCRIPTION = "Slack backlog"
  CONFIG_NS = "plugins.var.ruby.#{NAME}"

  def self.append_history(buffer_id)
    server, name = Weechat.buffer_get_string(buffer_id, "name").split('.')

    return unless token = tokens[server]

    slack_api = SlackAPI.new(token)
    slack_api.find_room(name).history.each do |message|
      Weechat.print(buffer_id, "#{message.nick}\t#{message.body}")
    end
  end

  def self.tokens
    @tokens ||= Tokens.new(Weechat, CONFIG_NS)
  end
end
