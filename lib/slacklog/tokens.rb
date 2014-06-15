module Slacklog
  class Tokens
    def initialize(weechat, namespace)
      @weechat = weechat
      @namespace = namespace
      @tokens = {}
    end

    def read
      update_tokens(config("servers"))
    end

    def update(option, value)
      case option
      when "#{@namespace}.servers"
        update_tokens(value)
      when /^#{Regexp.escape(@namespace)}\.(.*)\.api_token$/
        @tokens[$1] = value
      end
    end

    def [](server)
      @tokens[server]
    end

    private

    def update_tokens(server_list)
      server_list.split(",").map(&:strip).each do |server|
        @tokens[server] = config("#{server}.api_token")
      end
    end

    def config(option)
      @weechat.config_string(@weechat.config_get("#{@namespace}.#{option}"))
    end
  end
end
