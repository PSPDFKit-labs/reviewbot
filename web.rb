require "sinatra/base"

module ReviewBot
  class Web < Sinatra::Base
    get "/" do
      "ReviewBot"
    end
  end
