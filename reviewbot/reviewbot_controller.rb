require "octokit"

module ReviewBot
  class ReviewBotController < SlackRubyBot::MVC::Controller::Base
    READY_LABELS = ["READY TO REVIEW", "ready for review", "READY", "review"]

    define_callbacks :react
    set_callback :react, :around, :around_reaction

    attr_reader :gh_client
    private :gh_client

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
          say("No GitHub username set.")
        else
          say("GitHub username: #{github_user}")
        end
      else
        model.set_github_user
        say("Set GitHub username.")
      end
    end

    def repositories
      if match[:expression].nil?
        repositories = model.repositories
        if repositories.nil?
          say("No repositories set.")
        else
          say("Repositories: #{repositories}")
        end
      else
        model.set_repositories
        say("Set repositories.")
      end
    end

    def labels
      if match[:expression].nil?
        labels = model.labels
        if labels.nil?
          say("No labels set.")
        else
          say("Labels: #{labels}")
        end
      else
        model.set_labels
        say("Set labels.")
      end
    end

    def review
      return unless values_set?

      run_callbacks :react do
        pull_requests = find_pull_requests
        requested_as_reviewer = pull_requests[:requested_as_reviewer]
        need_review = pull_requests[:need_review]
        view.post_reviewable_pull_requests(requested_as_reviewer: requested_as_reviewer, need_review: need_review)
      end
    end

    private

    def say(text)
      view.say(channel: data.channel, text: text)
    end

    def log(text)
      SlackRubyBot::Client.logger.info(text)
    end

    def around_reaction
      view.react_wait
      yield
      view.unreact_wait
    end

    def values_set?
      values_set = true

      if model.github_user.nil?
        say("Please set GitHub username first.")
        values_set = false
      end

      if model.repositories.nil?
        say("Please set repositories first.")
        values_set = false
      end

      if model.labels.nil?
        say("Please set labels first.")
        values_set = false
      end

      values_set
    end

    def find_pull_requests
      github_user = model.github_user
      log("Finding reviewable pull requests for GitHub user #{github_user}")

      repositories = model.repositories.split(",").map { |repository| "PSPDFKit/#{repository}" }
      labels = model.labels.split(",")

      pull_requests = repositories.flat_map do |repository|
        gh_client.pull_requests(repository, state: "open")
      end

      requested_as_reviewer = pull_requests.select do |pull_request|
        requested_reviewers = pull_request.requested_reviewers.map { |reviewers| reviewers.login }
        requested_reviewers.include?(github_user)
      end

      # Filter out pull requests that are assigned or were created by the user
      pull_requests_by_other_users = pull_requests.reject do |pull_request|
        assignees = pull_request.assignees
        if assignees.empty?
          pull_request.user.login == github_user
        else
          assignees.include?(github_user)
        end
      end

      # Select all pull requests with a ready label
      ready_pull_requests = pull_requests_by_other_users.select do |pull_request|
        repository = pull_request.base.repo.full_name
        pull_request_labels = pull_request.labels.map { |label| label.name }

        ready = READY_LABELS.any? { |label| pull_request_labels.include?(label) }
        has_labels =
          if repository == "PSPDFKit/PSPDFKit"
            labels.all? { |label| pull_request_labels.include?(label) }
          else
            true
          end

        ready && has_labels
      end

      # Filter out pull requests with reviews or reviewers
      need_review = ready_pull_requests.select do |pull_request|
        repository = pull_request.base.repo.full_name

        requested_reviewers = pull_request.requested_reviewers
        return false unless requested_reviewers.empty?

        reviews = gh_client.pull_request_reviews(repository, pull_request.number).select do |review|
          %w[APPROVED CHANGES_REQUESTED].include?(review.state)
        end

        reviews.empty?
      end

      { requested_as_reviewer: requested_as_reviewer, need_review: need_review }
    end
  end
end
