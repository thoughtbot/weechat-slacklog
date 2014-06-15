FILE = File.join(ENV["HOME"], ".weechat", "ruby", "#{Slacklog::NAME}.rb")

def on_buffer_opened(_, _, buffer_id)
  server, name = Weechat.buffer_get_string(buffer_id, "name").split('.')

  if token = Slacklog.tokens[server]
    run_script = "ruby '#{FILE}' '#{token}' '#{name}'"
    Weechat.hook_process(run_script, 0, "on_process_complete", buffer_id)
  end

  Weechat::WEECHAT_RC_OK
end

def on_process_complete(buffer_id, _, rc, out, _)
  if rc.to_i == 0
    color = Weechat.color("darkgray,normal")

    out.lines do |line|
      nick, text = line.strip.split("\t")
      Weechat.print(buffer_id, "%s%s\t%s%s" % [color, nick, color, text])
    end
  end

  Weechat::WEECHAT_RC_OK
end

def on_config(_, option, value)
  Slacklog.tokens.update(option, value)

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

if ARGV.any?
  token, room_name = ARGV

  slack_api = Slacklog::SlackAPI.new(token)
  slack_api.find_room(room_name).history.each do |message|
    puts "#{message.nick}\t#{message.body}"
  end
end
