require "rspec"
require "webmock"
require "slacklog/slack_api"
require "slacklog/tokens"

RSpec.configure do |conf|
  conf.include(WebMock::API)
end
