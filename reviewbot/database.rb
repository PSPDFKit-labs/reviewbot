require "active_record"

module ReviewBot
  class Database
    def self.connect
      if ENV["DATABASE_URL"]
        ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
      else
        ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "test.db")
      end
    end

    def self.table_exists?(table)
      ActiveRecord::Base.connection.table_exists?(table)
    end

    def self.create_table
      ActiveRecord::Schema.define do
        create_table :users do |table|
          table.string :slack_user
          table.string :github_user
          table.string :repos
          table.string :labels
        end
      end
    end
  end
end
