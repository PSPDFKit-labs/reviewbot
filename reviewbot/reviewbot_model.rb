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

    def set_github_user
      user = User.find_by(slack_user: data.user)
      if user.nil?
        user = User.new(slack_user: data.user, github_user: match[:expression])
        user.save
      else
        user.update(github_user: match[:expression])
      end
    end

    def set_repositories
      repositories = match[:expression].split(",")
      user = User.find_by(slack_user: data.user)
      if user.nil?
        user = User.new(slack_user: data.user, repositories: repositories)
        user.save
      else
        user.update(repositories: repositories)
      end
    end

    def set_labels
      labels = match[:expression].split(",")
      user = User.find_by(slack_user: data.user)
      if user.nil?
        user = User.new(slack_user: data.user, labels: labels)
        user.save
      else
        user.update(labels: labels)
      end
    end

    def github_user
      user = User.find_by(slack_user: data.user)
      user&.github_user
    end

    def repositories
      user = User.find_by(slack_user: data.user)
      user&.repositories
    end

    def labels
      user = User.find_by(slack_user: data.user)
      user&.labels
    end
  end
end
