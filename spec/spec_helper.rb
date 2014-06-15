require "rspec"
require "webmock"
require_relative "../slacklog"

RSpec.configure do |conf|
  conf.include(WebMock::API)
end
