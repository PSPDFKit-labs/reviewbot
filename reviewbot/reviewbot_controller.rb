# frozen_string_literal: true

require "reviewbot/github"

module ReviewBot
  class ReviewBotController < SlackRubyBot::MVC::Controller::Base
    define_callbacks :react
    set_callback :react, :around, :around_reaction

    attr_reader :github
    private :github

    def initialize(model, view)
      super(model, view)
      @github = GitHub.new
    end

    def username
      user_attribute(attribute: :github_user, value: match[:expression], attribute_string: "GitHub username")
    end

    def repositories
      user_attribute(attribute: :repositories, value: match[:expression]&.split(","), attribute_string: "repositories")
    end

    def labels
      user_attribute(attribute: :labels, value: match[:expression]&.split(","), attribute_string: "labels")
    end

    def review
      return unless values_set?

      github_user = model.user_attribute(:github_user)
      repositories = model.user_attribute(:repositories)
      labels = model.user_attribute(:labels)

      run_callbacks :react do
        pull_requests = github.reviewable_pull_requests(github_user: github_user, repositories: repositories, labels: labels)
        requested_as_reviewer = pull_requests[:requested_as_reviewer]
        need_review = pull_requests[:need_review]
        view.post_reviewable_pull_requests(requested_as_reviewer: requested_as_reviewer, need_review: need_review)
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

    def user_attribute(attribute:, value:, attribute_string:)
      if value.nil?
        user_attribute = model.user_attribute(attribute)
        if user_attribute.nil?
          say("No #{attribute_string} set.")
        else
          user_attribute_string = user_attribute.is_a?(Array) ? user_attribute.join(", ") : user_attribute
          say("#{attribute_string.capitalize}: #{user_attribute_string}")
        end
      else
        model.set_user_attribute(attribute, value)
        say("Set #{attribute_string}.")
      end
    end

    def values_set?
      values_set = true

      attributes = {
        github_user: "GitHub username",
        repositories: "repositories"
      }

      attributes.each do |attribute, attribute_string|
        if model.user_attribute(attribute).nil?
          say("Please set #{attribute_string} first.")
          values_set = false
        end
      end

      values_set
    end
  end
end
