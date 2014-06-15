module Slacklog
  NAME = "slacklog"
  AUTHOR = "Pat Brisbin <pbrisbin@gmail.com>"
  VERSION = "0.1"
  LICENSE = "MIT"
  DESCRIPTION = "Slack backlog"
  CONFIG_NS = "plugins.var.ruby.#{NAME}"

  def self.tokens
    @tokens ||= Tokens.new(Weechat, CONFIG_NS)
  end
end
