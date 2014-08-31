# Slacklog

Pull [Slack][] chat history in when opening a new buffer.

[slack]: https://slack.com/

![shot](shot.png)

## Installation

This script is not yet released, please install manually:

```
% curl -o ~/.weechat/ruby/slacklog.rb \
  "https://raw.githubusercontent.com/thoughtbot/weechat-slacklog/master/slacklog.rb"
```

Optionally set the script to autoload when WeeChat starts:

```
% cd ~/.weechat/ruby/autoload && ln -s ../slacklog.rb .
```

Restart WeeChat or load the script manually:

```
/script load slacklog.rb
```

## Required Settings

**Note**: You can generate an API token [here][docs].

```
/set plugins.var.ruby.slacklog.servers "thoughtbot"
/set plugins.var.ruby.slacklog.thoughtbot.api_token "abc-123"
```

These variables can also be modified via the `/slacklog` command:

```
/slacklog add thoughtbot abc-123
```

[docs]: https://api.slack.com#auth

## Optional Settings

By default, the Slack API returns 100 messages when no count is 
specified. You can change this by setting a value between 1 and 1000:

```
/set plugins.var.ruby.slacklog.count 500
```

To change the color of Slacklog lines, change the following WeeChat 
setting:

```
/set logger.color.backlog_line darkgray
```

## Usage

Whenever you open a buffer for a server in your `servers` list (and 
which has a token defined), 100 messages of history will be fetched via 
the Slack API and printed into the buffer.

The `/slacklog` command can be used without arguments to actively fetch 
and print history for an already open buffer.

## Implementation Details

The script can be used outside of WeeChat like so:

```
% ruby ./slacklog.rb fetch API-TOKEN CHANNEL
```

This prints history messages on `stdout` and has no dependencies on the 
`Weechat` module. The implementation is contained in a normal `SlackAPI` 
class which is well tested.

Global functions wire this up as a WeeChat plugin in the following way:

- When a buffer is opened or the `/slacklog` command is invoked, we 
  determine the token and channel then ask `Weechat` to asynchronously 
  execute our script as above with a callback.
- The callback will receive the lines output by our script, and print 
  them into the buffer.
