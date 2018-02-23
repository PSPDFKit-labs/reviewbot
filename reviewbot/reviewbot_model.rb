# frozen_string_literal: true

require "reviewbot/database"
require "reviewbot/user"

module ReviewBot
  class ReviewBotModel < SlackRubyBot::MVC::Model::Base
    def initialize
      Database.connect

      return if Database.table_exists?("users")
      Database.create_table
    end

    def set_user_attribute(attribute, value)
      user = User.find_by(slack_user: data.user)
      if user.nil?
        arguments = { slack_user: data.user, attribute => value }
        user = User.new(**arguments)
        user.save
      else
        arguments = { attribute => value }
        user.update(**arguments)
      end
    end

    def user_attribute(attribute)
      user = User.find_by(slack_user: data.user)
      user&.send(attribute)
    end
  end
end
