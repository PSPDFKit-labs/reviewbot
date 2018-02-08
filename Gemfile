source "https://rubygems.org"

gem "slack-ruby-bot"
gem "celluloid-io"
gem "puma"
gem "sinatra"
gem "activerecord"
gem "octokit"

group :development do
  gem "sqlite3"
  gem "foreman"
end

group :production do
  # pg v1.0.0 doesn't work with Active Record yet
  gem "pg", "~> 0.21"
end
