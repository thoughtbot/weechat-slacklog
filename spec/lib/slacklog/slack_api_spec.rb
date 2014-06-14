require "spec_helper"

describe Slacklog::SlackAPI do
  let(:token) { "api-token" }

  it "raises when appropriate" do
    api = Slacklog::SlackAPI.new(token)
    mock_slack_api("channels.list?token=#{token}", ok: false)

    expect { api.find_room("#general") }.to raise_error(/API Error/)
  end

  it "finds channels by name" do
    api = Slacklog::SlackAPI.new(token)
    mock_slack_api("channels.list?token=#{token}", {
      ok: true,
      channels: [{ id: "123", name: "general" }]
    })

    channel = api.find_room("#general")

    expect(channel.id).to eq "123"
    expect(channel.name).to eq "general"
  end

  it "finds groups" do
    api = Slacklog::SlackAPI.new(token)
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

  context Slacklog::SlackAPI::Room do
    context "#history" do
      it "returns the backlog of messages" do
        api = Slacklog::SlackAPI.new(token)
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
          Slacklog::SlackAPI::Message.new("adarsh", "out"),
          Slacklog::SlackAPI::Message.new("joe", "bye"),
        ]
      end
    end
  end

  def mock_slack_api(path, response)
    stub_request(:get, "#{Slacklog::SlackAPI::BASE_URL}/#{path}").
      to_return(body: response.to_json)
  end
end
