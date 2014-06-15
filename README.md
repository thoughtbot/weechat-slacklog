# Slacklog

Pull [Slack][] chat history in when opening a new buffer.

[slack]: https://slack.com/

![shot](shot.png)

## Installation

*This script is very Alpha.*

```
% curl -o ~/.weechat/ruby/slacklog.rb \
  "https://raw.githubusercontent.com/pbrisbin/weechat-slacklog/master/slacklog.rb"
```

## Usage

```
/set plugins.var.ruby.slacklog.servers "thoughtbot"
/set plugins.var.ruby.slacklog.thoughtbot.api_token "abc-123"
/script load slacklog.rb
```

Find your API token [here][docs].

[docs]: https://api.slack.com/

## Known bugs

- The body has escaped HTML entities.
- Any "@-mentions" in the body appear as User IDs.
