$LOAD_PATH.unshift(File.dirname(__FILE__))

unless ENV["RACK_ENV"] == "production"
  require "dotenv"
  Dotenv.load
end

require "reviewbot"
require "web"

Thread.abort_on_exception = true

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
