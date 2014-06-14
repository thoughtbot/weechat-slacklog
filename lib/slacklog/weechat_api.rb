module Slacklog
  class WeechatAPI
    Buffer = Struct.new(:weechat, :id, :server, :name) do
      def print(message)
        weechat.print(id, message)
      end
    end

    def initialize(weechat)
      @weechat = weechat
    end

    def find_buffer(buffer_id)
      server, name = @weechat.buffer_get_string(buffer_id, "name").split('.')
      server && name && Buffer.new(@weechat, buffer_id, server, name)
    end
  end
end
