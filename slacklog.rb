# Copyright (c) 2014 Pat Brisbin <pbrisbin@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Fetch Slack chat history when opening a buffer.
#
# Required settings:
#
# - plugins.var.ruby.slacklog.servers "foo,bar"
# - plugins.var.ruby.slacklog.foo.api_token "foo-api-token"
# - plugins.var.ruby.slacklog.bar.api_token "bar-api-token"
#
###
require "json"
require "net/https"
require "uri"

SCRIPT_NAME = "slacklog"
SCRIPT_AUTHOR = "Pat Brisbin <pbrisbin@gmail.com>"
SCRIPT_VERSION = "0.1"
SCRIPT_LICENSE = "MIT"
SCRIPT_DESCRIPTION = "Slack backlog"
SCRIPT_FILE = File.join(ENV["HOME"], ".weechat", "ruby", "#{SCRIPT_NAME}.rb")

NAMESPACE = "plugins.var.ruby.#{SCRIPT_NAME}"
API_TOKENS = {}

class SlackAPI
  BASE_URL = "https://slack.com/api"

  Message = Struct.new(:nick, :body)

  User = Struct.new(:name) do
    def self.find(api, user_id)
      @list ||= api.rpc("users.list").fetch("members")

      object = @list.detect { |o| o["id"] == user_id }
      object && new(object["name"])
    end
  end

  class Room
    class << self
      attr_accessor :name
    end

    def self.find(api, room_name)
      room_name = room_name.sub(/^#/, '')

      @list ||= api.rpc("#{name}.list").fetch(name)

      object = @list.detect { |o| o["name"] == room_name }
      object && new(api, object["id"], object["name"])
    end

    attr_reader :id, :name

    def initialize(api, id, name)
      @api = api
      @id = id
      @name = name
    end

    def history
      messages.reverse.map do |object|
        user = object["user"]
        text = object["text"]

        if user && text
          nick = User.find(@api, user).name
          nick && Message.new(nick, text)
        end
      end.compact
    end

    private

    def messages
      @api.rpc("#{self.class.name}.history", channel: id).fetch("messages")
    end
  end

  class Channel < Room
    self.name = "channels"
  end

  class Group < Room
    self.name = "groups"
  end

  def initialize(token)
    @token = token
  end

  def find_room(name)
    Channel.find(self, name) || Group.find(self, name)
  end

  def rpc(method, arguments = {})
    params = parameterize({ token: @token }.merge(arguments))
    uri = URI.parse("#{BASE_URL}/#{method}?#{params}")
    response = Net::HTTP.get_response(uri)

    JSON.parse(response.body).tap do |result|
      result["ok"] or raise "API Error: #{result.inspect}"
    end
  rescue JSON::ParserError
    raise "API Error: unable to parse HTTP response"
  end

  private

  def parameterize(query)
    query.map { |k,v| "#{escape(k)}=#{escape(v)}" }.join("&")
  end

  def escape(value)
    URI.escape(value.to_s)
  end
end

def on_buffer_opened(_, _, buffer_id)
  server, name = Weechat.buffer_get_string(buffer_id, "name").split('.')

  if token = API_TOKENS[server]
    run_script = "ruby '#{SCRIPT_FILE}' fetch '#{token}' '#{name}'"
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

def read_tokens
  server_list = Weechat.config_get_plugin("servers")
  server_list.split(",").map(&:strip).each do |server|
    API_TOKENS[server] = Weechat.config_get_plugin("#{server}.api_token")
  end

  Weechat::WEECHAT_RC_OK
end

def weechat_init
  Weechat.register(
    SCRIPT_NAME,
    SCRIPT_AUTHOR,
    SCRIPT_VERSION,
    SCRIPT_LICENSE,
    SCRIPT_DESCRIPTION,
    "", ""
  )

  Weechat.hook_config("#{NAMESPACE}.*", "read_tokens", "")
  Weechat.hook_signal("buffer_opened", "on_buffer_opened", "")

  read_tokens

  Weechat::WEECHAT_RC_OK
end

if ARGV.first == "fetch"
  _, token, room_name = ARGV

  slack_api = SlackAPI.new(token)
  slack_api.find_room(room_name).history.each do |message|
    puts "#{message.nick}\t#{message.body}"
  end
end
