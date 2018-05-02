# frozen_string_literal: true

require "octokit"

module ReviewBot
  class GitHub
    attr_reader :client
    attr_reader :organization
    attr_reader :ready_labels
    attr_reader :label_repositories
    private :client
    private :organization
    private :ready_labels
    private :label_repositories

    def initialize
      token = ENV["GITHUB_ACCESS_TOKEN"]
      raise "Missing ENV[\"GITHUB_ACCESS_TOKEN\"]" unless token
      @client = Octokit::Client.new(access_token: token)

      @organization = ENV["ORGANIZATION"]
      raise "Missing ENV[\"ORGANIZATION\"]" unless organization

      @ready_labels = ENV["READY_LABELS"]&.split(",")
      raise "Missing ENV[\"READY_LABELS\"]" unless ready_labels

      @label_repositories = ENV["LABEL_REPOSITORIES"]&.split(",")&.map do |repository|
        if repository.include?("/")
          repository
        else
          "#{organization}/#{repository}"
        end
      end
      raise "Missing ENV[\"LABEL_REPOSITORIES\"]" unless label_repositories
    end

    def reviewable_pull_requests(github_user: nil, repositories:, labels:)
      repositories = repositories.map do |repository|
        if repository.include?("/")
          repository
        else
          "#{organization}/#{repository}"
        end
      end

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

        ready = ready_labels.any? { |label| pull_request_labels.include?(label) }
        has_labels =
          if labels.nil?
            true
          elsif label_repositories.include?(repository)
            labels.any? { |label| pull_request_labels.include?(label) }
          else
            true
          end

        ready && has_labels
      end

      # Filter out pull requests with reviews or reviewers
      need_review = ready_pull_requests.select do |pull_request|
        repository = pull_request.base.repo.full_name

        requested_reviewers = pull_request.requested_reviewers
        next false unless requested_reviewers.empty?

        reviews = client.pull_request_reviews(repository, pull_request.number).select do |review|
          %w[APPROVED CHANGES_REQUESTED].include?(review.state)
        end

        reviews.empty?
      end

      { requested_as_reviewer: requested_as_reviewer, need_review: need_review }
    end
  end
end
