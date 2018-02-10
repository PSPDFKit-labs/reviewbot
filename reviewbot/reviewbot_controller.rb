require "octokit"

module ReviewBot
  class ReviewBotController < SlackRubyBot::MVC::Controller::Base
    define_callbacks :react
    set_callback :react, :around, :around_reaction

    attr_reader :gh_client

    def initialize(model, view)
      super(model, view)

      gh_token = ENV["GITHUB_ACCESS_TOKEN"]
      raise "Missing ENV[\"GITHUB_ACCESS_TOKEN\"]" unless gh_token
      @gh_client = Octokit::Client.new(access_token: gh_token)
    end

    def username
      if match[:expression].nil?
        github_user = model.github_user
        if github_user.nil?
          say("No GitHub username set")
        else
          say("GitHub username: #{github_user}")
        end
      else
        model.set_github_user
        say("Set GitHub username")
      end
    end

    def repos
      if match[:expression].nil?
        repos = model.repos
        if repos.nil?
          say("No repos set")
        else
          say("Repos: #{repos}")
        end
      else
        model.set_repos
        say("Set repos")
      end
    end

    def labels
      if match[:expression].nil?
        labels = model.labels
        if labels.nil?
          say("No labels set")
        else
          say("Labels: #{labels}")
        end
      else
        model.set_labels
        say("Set labels")
      end
    end

    def review
      return unless values_set?

      run_callbacks :react do
        pull_requests = find_pull_requests
        requested_as_reviewer = pull_requests[:requested_as_reviewer]
        need_review = pull_requests[:need_review]
        view.post_reviewable_pull_requests(requested_as_reviewer, need_review)
      end
    end

    private

    def say(text)
      view.say(channel: data.channel, text: text)
    end

    def around_reaction
      view.react_wait
      yield
      view.unreact_wait
    end

    def values_set?
      values_set = true

      if model.github_user.nil?
        say("Please set GitHub username first")
        values_set = false
      end

      if model.repos.nil?
        say("Please set repositories first")
        values_set = false
      end

      if model.labels.nil?
        say("Please set labels first")
        values_set = false
      end

      values_set
    end

    def find_pull_requests
      github_user = model.github_user
      repos = model.repos.split(",")
      labels = model.labels.split(",")

      all_pull_requests_with_request_for_user = []
      all_reviewable_pull_requests = []

      repos.each do |repo|
        repo = "PSPDFKit/#{repo}"
        pull_requests = gh_client.pull_requests(repo, state: "open")

        # Remove pull requests created by the GitHub user
        pull_requests.reject! { |pr| pr.user.login == github_user }

        # Find pull requests with reviewers
        pull_requests_with_request_for_user = []
        pull_requests_with_request = pull_requests.select do |pull_request|
          id = pull_request.number
          review_requests = gh_client.pull_request_review_requests(repo, id)
          if review_requests.users.any? { |user| user.login == github_user }
            pull_requests_with_request_for_user << pull_request
          end
          !review_requests.users.empty?
        end

        # Find pull requests that are ready for review
        reviewable_pull_requests = pull_requests - pull_requests_with_request
        reviewable_pull_requests.select! do |pull_request|
          id = pull_request.number
          pr_labels = gh_client.labels_for_issue(repo, id).map(&:name)
          ready_for_review = pr_labels.any? do |label|
            label == "READY TO REVIEW" ||
            label == "ready to review" ||
            label == "READY" ||
            label == "ready"
          end

          if repo == "PSPDFKit/PSPDFKit"
            pr_has_all_labels = (labels - pr_labels).empty?
            ready_for_review && pr_has_all_labels
          else
            ready_for_review
          end
        end

        all_pull_requests_with_request_for_user += pull_requests_with_request_for_user
        all_reviewable_pull_requests += reviewable_pull_requests
      end

      { requested_as_reviewer: all_pull_requests_with_request_for_user, need_review: all_reviewable_pull_requests }
    end
  end
end
