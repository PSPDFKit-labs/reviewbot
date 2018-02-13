# frozen_string_literal: true

require "octokit"

module ReviewBot
  class GitHub
    READY_LABELS = ["READY TO REVIEW", "ready for review", "READY", "review"]

    attr_reader :client
    private :client

    def initialize
      token = ENV["GITHUB_ACCESS_TOKEN"]
      raise "Missing ENV[\"GITHUB_ACCESS_TOKEN\"]" unless token
      @client = Octokit::Client.new(access_token: token)
    end

    def reviewable_pull_requests(github_user: nil, repositories:, labels:)
      repositories = repositories.map { |repository| "PSPDFKit/#{repository}" }

      pull_requests = repositories.flat_map do |repository|
        client.pull_requests(repository, state: "open")
      end

      requested_as_reviewer = if github_user.nil?
                                nil
                              else
                                pull_requests.select do |pull_request|
                                  requested_reviewers = pull_request.requested_reviewers.map { |reviewers| reviewers.login }
                                  requested_reviewers.include?(github_user)
                                end
                              end

      pull_requests_by_other_users = if github_user.nil?
                                       pull_requests
                                     else
                                       # Filter out pull requests that are assigned or were created by the user
                                       pull_requests.reject do |pull_request|
                                         assignees = pull_request.assignees
                                         if assignees.empty?
                                           pull_request.user.login == github_user
                                         else
                                           assignees.include?(github_user)
                                         end
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

        reviews = client.pull_request_reviews(repository, pull_request.number).select do |review|
          %w[APPROVED CHANGES_REQUESTED].include?(review.state)
        end

        reviews.empty?
      end

      { requested_as_reviewer: requested_as_reviewer, need_review: need_review }
    end
  end
end
