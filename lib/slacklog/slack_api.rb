require "json"
require "net/https"
require "uri"

module Slacklog
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
end
