module ReviewBot
  class ReviewView < SlackRubyBot::MVC::View::Base
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

    def post_reviewable_pull_requests(pull_requests_with_request_for_user, reviewable_pull_requests)
      unless pull_requests_with_request_for_user.empty?
        formatted_pull_requests_with_request_for_user = format_pull_requests(pull_requests_with_request_for_user)

        client.web_client.chat_postMessage(
          channel: data.channel,
          as_user: true,
          attachments: [
            {
              fallback: formatted_pull_requests_with_request_for_user,
              title: "Pull Requests Awaiting Your Review",
              text: formatted_pull_requests_with_request_for_user,
              color: "#00b900"
            }
          ]
        )
      end

      unless reviewable_pull_requests.empty?
        formatted_reviewable_pull_requests = format_pull_requests(reviewable_pull_requests)

        client.web_client.chat_postMessage(
          channel: data.channel,
          as_user: true,
          attachments: [
            {
              fallback: formatted_reviewable_pull_requests,
              title: "Ready for Review Pull Requests",
              text: formatted_reviewable_pull_requests,
              color: "#00b900"
            }
          ]
        )
      end
    end

    private

    def format_pull_requests(pull_requests)
      pull_requests.map do |pull_request|
        number = pull_request.number
        title = pull_request.title
        url = pull_request.html_url
        "##{number} - #{title}:\n#{url}"
      end.join("\n")
    end
  end
end
