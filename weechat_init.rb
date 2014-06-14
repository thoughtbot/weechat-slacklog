def on_buffer_open(_, _, buffer_id)
  weechat = Slacklog::WeechatAPI.new(Weechat)
  weechat.handle_buffer_open(buffer_id)
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

  return Weechat::WEECHAT_RC_OK
end
