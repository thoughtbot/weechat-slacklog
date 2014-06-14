# Slacklog

Pull [Slack][] chat history in when opening a new buffer.

[slack]: https://slack.com/

## Usage

*Eventually...*

```
/script install slacklog.rb
/set plugins.var.ruby.slacklog.servers "foo,bar"
/set plugins.var.ruby.slacklog.api_token "default api token"
/set plugins.var.ruby.slacklog.foo.api_token "foo's api token"
/set plugins.var.ruby.slacklog.bar.api_token "bar's api token"
```

You can find your API token [here][docs].

[docs]: https://api.slack.com/

## What's working?

- Slack API calls for history
- Printing the results into the buffer

## What's left?

- Order the history correctly
- Don't just `Weechat.print` to the buffer, add them as messages
- Weechat configuration hooks

## Try it

To test this in a real weechat:

- Enter real values for `servers` and `token` in `lib/slacklog.rb`
- Use `rake build` to generate `slacklog.rb`
- Copy or move `slacklog.rb` to `~/.weechat/ruby/slacklog.rb`
- In weechat, run `/script load slacklog.rb`
- `/join` a new channel for a Slack-based server
- See backlog!

![simple](simple.png)

*Note that the messages in that shot are reversed...*
