# frozen_string_literal: true

require "sinatra/base"

module ReviewBot
  class Web < Sinatra::Base
    get "/" do
      "ReviewBot"
    end
  end
end
