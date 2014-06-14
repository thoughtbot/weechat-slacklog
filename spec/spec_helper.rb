require "rspec"
require "webmock"
require "slacklog/slack_api"

RSpec.configure do |conf|
  conf.include(WebMock::API)
end
