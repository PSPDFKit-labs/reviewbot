$LOAD_PATH.unshift(File.dirname(__FILE__))

require "review-bot"
require "web"

Thread.new do
  begin
    ReviewBot::Bot.run
  rescue Exception => e
    STDERR.puts "ERROR: #{e}"
    STDERR.puts e.backtrace
    raise e
  end
end

run ReviewBot::Web
