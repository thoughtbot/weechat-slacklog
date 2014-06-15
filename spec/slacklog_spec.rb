require "spec_helper"

context "slacklog.rb" do
  context SlackAPI do
    let(:token) { "api-token" }

    it "raises when appropriate" do
      api = SlackAPI.new(token)
      mock_slack_api("channels.list?token=#{token}", ok: false)

      expect { api.find_room("#general") }.to raise_error(/API Error/)
    end

    it "finds channels by name" do
      api = SlackAPI.new(token)
      mock_slack_api("channels.list?token=#{token}", {
        ok: true,
        channels: [{ id: "123", name: "general" }]
      })

      channel = api.find_room("#general")

      expect(channel.id).to eq "123"
      expect(channel.name).to eq "general"
    end

    it "finds groups" do
      api = SlackAPI.new(token)
      mock_slack_api("channels.list?token=#{token}", {
        ok: true,
        channels: []
      })
      mock_slack_api("groups.list?token=#{token}", {
        ok: true,
        groups: [{ id: "456", name: "code" }]
      })

      group = api.find_room("#code")

      expect(group.id).to eq "456"
      expect(group.name).to eq "code"
    end

    context SlackAPI::Room do
      context "#history" do
        it "returns the backlog of messages" do
          api = SlackAPI.new(token)
          mock_slack_api("channels.list?token=#{token}", {
            ok: true,
            channels: [{ id: "123", name: "general" }]
          })
          mock_slack_api("channels.history?token=#{token}&channel=123", {
            ok: true,
            messages: [
              { user: "1", text: "out" },
              { user: "2", text: "bye" },
            ]
          })
          mock_slack_api("users.list?token=#{token}", {
            ok: true,
            members: [
              { id: "1", name: "adarsh" },
              { id: "2", name: "joe" },
            ]
          })
          channel = api.find_room("#general")

          messages = channel.history

          expect(messages).to match_array [
            SlackAPI::Message.new("adarsh", "out"),
            SlackAPI::Message.new("joe", "bye"),
          ]
        end
      end
    end

    def mock_slack_api(path, response)
      stub_request(:get, "#{SlackAPI::BASE_URL}/#{path}").
        to_return(body: response.to_json)
    end
  end

  context "on_buffer_opened" do
    it "spawns the script if we have a token" do
      API_TOKENS["foo"] = "api-token"
      allow(Weechat).to receive(:buffer_get_string).
        with("1", "name").and_return("foo.#bar")

      on_buffer_opened(nil, nil, "1")

      expect(Weechat).to have_received(:hook_process).
        with(
          "ruby '#{SCRIPT_FILE}' fetch 'api-token' '#bar'",
          0,
          "on_process_complete",
          "1"
        )
    end

    it "does nothing if we have no token" do
      allow(Weechat).to receive(:buffer_get_string).
        with("1", "name").and_return("foo.#bar")

      on_buffer_opened(nil, nil, "1")

      expect(Weechat).not_to have_received(:hook_process)
    end
  end

  context "on_process_complete" do
    it "prints colorized history on success" do
      out = "foo\tbar\nbaz\tbat\n"
      allow(Weechat).to receive(:color).and_return("C")

      on_process_complete("1", nil, 0, out, nil)

      expect(Weechat).to have_received(:print).with("1", "Cfoo\tCbar")
      expect(Weechat).to have_received(:print).with("1", "Cbaz\tCbat")
    end

    it "does nothing if not successful" do
      on_process_complete(nil, nil, 127, nil, nil)

      expect(Weechat).not_to have_received(:print)
    end

    context "read_tokens" do
      it "reads weechat configuration into API_TOKENS" do
        allow(Weechat).to receive(:config_get_plugin).
          with("servers").and_return("foo,bar")
        allow(Weechat).to receive(:config_get_plugin).
          with("foo.api_token").and_return("foo-api-token")
        allow(Weechat).to receive(:config_get_plugin).
          with("bar.api_token").and_return("bar-api-token")

        read_tokens

        expect(API_TOKENS).to eq({
          "foo" => "foo-api-token",
          "bar" => "bar-api-token",
        })
      end

      context "weechat_init" do
        it "registers with Weechat and sets up hooks" do
          weechat_init

          expect(Weechat).to have_received(:register)
          expect(Weechat).to have_received(:hook_config)
          expect(Weechat).to have_received(:hook_signal)
        end

        it "initializes tokens" do
          allow(Weechat).to receive(:config_get_plugin).
            with("servers").and_return("foo")

          weechat_init

          expect(API_TOKENS).to have_key("foo")
        end
      end
    end
  end
end
