# Slacklog

Pull [Slack][] chat history in when opening a new buffer.

[slack]: https://slack.com/

![shot](shot.png)

## Installation

This script is not yet released, please install manually:

```
% curl -o ~/.weechat/ruby/slacklog.rb \
  "https://raw.githubusercontent.com/pbrisbin/weechat-slacklog/master/slacklog.rb"
```

Optionally set the script to autoload when weechat starts:

```
% cd ~/.weechat/ruby/autoload && ln -s ../slacklog.rb .
```

Restart weechat or load the script manually:

```
/script load slacklog.rb
```

## Required Settings

**Note**: You can generate an API token [here][docs].

```
/set plugins.var.ruby.slacklog.servers "thoughtbot"
/set plugins.var.ruby.slacklog.thoughtbot.api_token "abc-123"
```

[docs]: https://api.slack.com#auth

## Known bugs

- Message bodies have escaped HTML entities.
- Any "@-mentions" in message bodies appear as User IDs.
