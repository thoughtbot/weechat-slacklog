require "spec_helper"

context "slacklog.rb" do
  context SlackAPI do
    let(:token) { "api-token" }

    it "raises when appropriate" do
      api = SlackAPI.new(token)
      mock_slack_api("users.list?token=#{token}" => { ok: false })

      expect { api.backlog("#general") }.to raise_error(/API Error/)
    end

    context "with thoughtbot's rooms" do
      before do
        mock_slack_api(
          "users.list?token=#{token}" => {
            ok: true,
            members: [
              { id: "1", name: "adarsh" },
              { id: "2", name: "joe" },
            ]
          },
          "channels.list?token=#{token}" => {
            ok: true,
            channels: [{ id: "123", name: "general" }]
          },
          "groups.list?token=#{token}" => {
            ok: true,
            groups: [{ id: "456", name: "dev" }]
          },
          "channels.history?token=#{token}&channel=123" => {
            ok: true,
            messages: [
              { user: "1", text: "hello" },
              { user: "2", text: "good bye" },
            ]
          },
          "groups.history?token=#{token}&channel=456" => {
            ok: true,
            messages: [
              { user: "1", text: "see ya" },
              { user: "2", text: "later" },
            ]
          },
        )
      end

      it "finds the backlog for the #general channel" do
        api = SlackAPI.new(token)

        backlog = api.backlog("#general")

        expect(backlog).to match_array ["adarsh\thello", "joe\tgood bye"]
      end

      it "finds the backlog for the #dev group" do
        api = SlackAPI.new(token)

        backlog = api.backlog("#dev")

        expect(backlog).to match_array ["adarsh\tsee ya", "joe\tlater"]
      end
    end

    it "handles multi-line messages correctly" do
      api = SlackAPI.new(token)
      message = %{```
m = MyModel.new(whatever: 'foo')
m.whatever
m.my_hstore
```}
      mock_history_message("general", "pat", message)

      backlog = api.backlog("#general")

      expect(backlog).to eq [
        "pat\t```",
        "pat\tm = MyModel.new(whatever: 'foo')",
        "pat\tm.whatever",
        "pat\tm.my_hstore",
        "pat\t```",
      ]
    end

    it "de-escapes HTML entities" do
      api = SlackAPI.new(token)
      mock_history_message("general", "pat", "My code &gt; your code")

      backlog = api.backlog("#general")

      expect(backlog).to eq ["pat\tMy code > your code"]
    end

    it "can have the number of messages to display configured" do
      api = SlackAPI.new(token)
      mock_slack_api(
        "users.list?token=#{token}" => {
          ok: true, members: [{ id: "1", name: "pat" }]
        },
        "channels.list?token=#{token}" => {
          ok: true, channels: [{ id: "123", name: "general" }]
        },
        "channels.history?token=#{token}&channel=123&count=2" => {
          ok: true, messages: [
            { user: "1", text: "One" },
            { user: "1", text: "Two" },
          ]
        },
      )

      backlog = api.backlog("#general", 2)

      expect(backlog).to eq ["pat\tTwo", "pat\tOne"]
    end

    def mock_history_message(channel, user, message)
      mock_slack_api(
        "users.list?token=#{token}" => {
          ok: true, members: [{ id: "1", name: user }]
        },
        "channels.list?token=#{token}" => {
          ok: true, channels: [{ id: "123", name: channel }]
        },
        "channels.history?token=#{token}&channel=123" => {
          ok: true, messages: [{ user: "1", text: message }]
        },
      )
    end

    def mock_slack_api(requests)
      requests.each do |path, response|
        stub_request(:get, "#{SlackAPI::BASE_URL}/#{path}").
          to_return(body: response.to_json)
      end
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

    it "prints error messages when unsuccessful" do
      err = "foo\nbar\nbaz\nbat\n"

      on_process_complete("1", nil, 127, nil, err)

      expect(Weechat).to have_received(:print).with("", "slacklog error: foo")
      expect(Weechat).to have_received(:print).with("", "slacklog error: bar")
      expect(Weechat).to have_received(:print).with("", "slacklog error: baz")
      expect(Weechat).to have_received(:print).with("", "slacklog error: bat")
    end

    it "does nothing if not finished" do
      on_process_complete(nil, nil, -1, nil, nil)

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
          expect(Weechat).to have_received(:hook_command)
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
