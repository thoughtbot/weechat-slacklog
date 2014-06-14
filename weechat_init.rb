Slacklog.token = ""
Slacklog.servers = []

def on_buffer_opened(_, _, buffer_id)
  Slacklog.append_history(Weechat, buffer_id)
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

  Weechat.hook_signal("buffer_opened", "on_buffer_opened", "")

  Weechat::WEECHAT_RC_OK
end
