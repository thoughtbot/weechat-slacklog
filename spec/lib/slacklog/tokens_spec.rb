require "spec_helper"

describe Slacklog::Tokens do
  it "loads server tokens from weechat" do
    weechat = mock_weechat_config(
      "namespace.servers" => "foo,bar",
      "namespace.foo.api_token" => "123",
      "namespace.bar.api_token" => "456",
    )
    tokens = Slacklog::Tokens.new(weechat, "namespace")

    tokens.read

    expect(tokens.keys).to match_array %w[foo bar]
    expect(tokens["foo"]).to eq "123"
    expect(tokens["bar"]).to eq "456"
  end

  it "handles updates to servers" do
    weechat = mock_weechat_config(
      "namespace.servers" => "foo,bar",
      "namespace.foo.api_token" => "123",
      "namespace.bar.api_token" => "456",
      "namespace.baz.api_token" => "789",
    )
    tokens = Slacklog::Tokens.new(weechat, "namespace")
    tokens.read

    tokens.update("namespace.servers", "bar,baz")

    expect(tokens["baz"]).to eq "789"
  end

  it "handles updates to tokens" do
    weechat = mock_weechat_config(
      "namespace.servers" => "foo",
      "namespace.foo.api_token" => "123",
    )
    tokens = Slacklog::Tokens.new(weechat, "namespace")
    tokens.read

    tokens.update("namespace.foo.api_token", "456")

    expect(tokens["foo"]).to eq "456"
  end

  def mock_weechat_config(values)
    double("Weechat", print: nil).tap do |weechat|
      values.each_with_index do |(option, value), id|
        allow(weechat).to receive(:config_get).with(option).and_return(id)
        allow(weechat).to receive(:config_string).with(id).and_return(value)
      end
    end
  end
end
