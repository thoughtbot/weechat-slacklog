def on_config(_, option, value)
  Slacklog.tokens.update(option, value)

  Weechat::WEECHAT_RC_OK
end

def on_buffer_opened(_, _, buffer_id)
  Slacklog.append_history(buffer_id)

  Weechat::WEECHAT_RC_OK
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

  Weechat.hook_config("#{Slacklog::CONFIG_NS}.*", "on_config", "")
  Weechat.hook_signal("buffer_opened", "on_buffer_opened", "")

  Slacklog.tokens.read

  Weechat::WEECHAT_RC_OK
end
