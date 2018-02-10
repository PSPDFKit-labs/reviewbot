$LOAD_PATH.unshift(File.dirname(__FILE__))

require "dotenv"
Dotenv.load

require "reviewbot"
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
