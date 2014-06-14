require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = "--color --format documentation"
end

SOURCES = %w[
  lib/slacklog.rb
  lib/slacklog/slack_api.rb
  lib/slacklog/weechat_api.rb
  weechat_init.rb
]

file "slacklog.rb" => SOURCES do |task|
  File.open(task.name, 'w') do |fh|
    fh.puts "###"
    fh.puts "#"
    fh.puts "# DO NOT EDIT. This file is auto-generated."
    fh.puts "# Last generated on #{Time.now}"
    fh.puts "#"
    fh.puts "###"

    task.prerequisites.each do |source|
      fh.puts "", File.read(source)
    end
  end
end

task build: "slacklog.rb"
task default: :spec
