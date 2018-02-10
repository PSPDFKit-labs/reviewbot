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
      user = User.find_by(slack_user: data.user)
      if user.nil?
        user = User.new(slack_user: data.user, repositories: match[:expression])
        user.save
      else
        user.update(repositories: match[:expression])
      end
    end

    def set_labels
      user = User.find_by(slack_user: data.user)
      if user.nil?
        user = User.new(slack_user: data.user, labels: match[:expression])
        user.save
      else
        user.update(labels: match[:expression])
      end
    end

    def github_user
      user = User.find_by(slack_user: data.user)
      if user.nil?
        nil
      else
        user.github_user
      end
    end

    def repositories
      user = User.find_by(slack_user: data.user)
      if user.nil?
        nil
      else
        user.repositories
      end
    end

    def labels
      user = User.find_by(slack_user: data.user)
      if user.nil?
        nil
      else
        user.labels
      end
    end
  end
end
