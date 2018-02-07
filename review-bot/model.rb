module ReviewBot
  class ReviewModel < SlackRubyBot::MVC::Model::Base
    def initialize
      ActiveRecord::Base.establish_connection(
        adapter: "sqlite3",
        host: "localhost",
        database: "test.db"
      )

      unless ActiveRecord::Base.connection.table_exists?("users")
        ActiveRecord::Schema.define do
          create_table :users do |t|
            t.string :slack_user
            t.string :github_user
            t.string :repos
            t.string :labels
          end
        end
      end
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

    def set_repos
      user = User.find_by(slack_user: data.user)
      if user.nil?
        user = User.new(slack_user: data.user, repos: match[:expression])
        user.save
      else
        user.update(repos: match[:expression])
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

    def repos
      user = User.find_by(slack_user: data.user)
      if user.nil?
        nil
      else
        user.repos
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
