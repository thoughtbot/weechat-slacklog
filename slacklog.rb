class Slacklog
  NAME = "slacklog"
  AUTHOR = "Pat Brisbin <pbrisbin@gmail.com>"
  VERSION = "0.1"
  LICENSE = "MIT"
  DESCRIPTION = "Slack backlog"
end

def weechat_init
  Weechat.register(
    Slacklog::NAME,
    Slacklog::AUTHOR,
    Slacklog::VERSION,
    Slacklog::LICENSE,
    Slacklog::DESCRIPTION,
    "", ""
  )

  return Weechat::WEECHAT_RC_OK
end
