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
          say("Repositories: #{repositories.join(", ")}")
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
          say("Labels: #{labels.join(", ")}")
        end
      else
        model.set_labels
        say("Set labels.")
      end
    end

    def review
      return unless values_set?

      run_callbacks :react do
        pull_requests = github.reviewable_pull_requests(github_user: model.github_user, repositories: model.repositories, labels: model.labels)
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
  end
end
