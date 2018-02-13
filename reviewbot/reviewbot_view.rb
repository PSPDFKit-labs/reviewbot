module ReviewBot
  class ReviewBotView < SlackRubyBot::MVC::View::Base
    def react_wait
      client.web_client.reactions_add(
        name: :hourglass_flowing_sand,
        channel: data.channel,
        timestamp: data.ts,
        as_user: true
      )
    end

    def unreact_wait
      client.web_client.reactions_remove(
        name: :hourglass_flowing_sand,
        channel: data.channel,
        timestamp: data.ts,
        as_user: true
      )
    end

    def post_reviewable_pull_requests(requested_as_reviewer:, need_review:)
      if requested_as_reviewer.empty?
        say(channel: data.channel, text: "There are no pull requests that requested your review.")
      else
        formatted_requested_as_reviewer = self.class.format_pull_requests(requested_as_reviewer)

        client.web_client.chat_postMessage(
          channel: data.channel,
          as_user: true,
          attachments: [
            {
              fallback: "Pull Requests Awaiting Your Review:\n\n#{formatted_requested_as_reviewer}",
              title: "Pull Requests Awaiting Your Review",
              pretext: "Your review was requested in the following pull requests:",
              text: formatted_requested_as_reviewer,
              color: "#03b70b"
            }
          ]
        )
      end

      if need_review.empty?
        say(channel: data.channel, text: "There are no pull requests that need to be reviewed.")
      else
        formatted_need_review = self.class.format_pull_requests(need_review)

        client.web_client.chat_postMessage(
          channel: data.channel,
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
    end

    def self.format_pull_requests(pull_requests)
      pull_requests.map do |pull_request|
        number = pull_request.number
        title = pull_request.title
        url = pull_request.html_url
        "##{number} - #{title}:\n#{url}"
      end.join("\n\n")
    end
  end
end
