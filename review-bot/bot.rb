module ReviewBot
  class Bot < SlackRubyBot::Bot
    model = ReviewBotModel.new
    view = ReviewBotView.new
    @controller = ReviewBotController.new(model, view)

    help do
      title "Review Bot"
      desc "Shows you reviewable pull requests."

      command "username" do
        desc "Set your GitHub username with: username <github-username>"
      end

      command "repos" do
        desc "Set your repos with: repos <repo1,repo2>"
      end

      command "labels" do
        desc "Set your labels with: labels <label1,label2>"
        long_desc "Labels only apply to the PSPDFKit monorepo."
      end
    end
  end
end

ReviewBot::Bot.run
