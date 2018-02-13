# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require "slack-ruby-bot"
require "slack-ruby-client"
require "reviewbot/github"
require "reviewbot/reviewbot_view"

unless ENV["RACK_ENV"] == "production"
  require "dotenv"
  Dotenv.load
end

Slack.configure do |config|
  config.token = ENV["SLACK_API_TOKEN"]
  raise "Missing ENV[\"SLACK_API_TOKEN\"]" unless config.token
end

task :post_reviewable_pull_requests do
  slack_client = Slack::Web::Client.new
  github = ReviewBot::GitHub.new
  repositories = %w[PSPDFKit]
  labels = %w[iOS]

  need_review = github.reviewable_pull_requests(repositories: repositories, labels: labels)[:need_review]
  formatted_need_review = ReviewBot::ReviewBotView.format_pull_requests(need_review)

  slack_client.chat_postMessage(
    channel: "ios",
    as_user: true,
    attachments: [
      {
        fallback: "Ready for Review Pull Requests:\n\n#{formatted_need_review}",
        title: "Ready for Review Pull Requests",
        pretext: "The following pull requests need to be reviewed:",
        text: formatted_need_review,
        color: "#03b70b"
      }
    ]
  )
end
