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

      command "repositories" do
        desc "Set your repositories comma-separated with: repositories <repository1,repository2>"
      end

      command "labels" do
        desc "Set your labels comma-separated with: labels <label1,label2>"
        long_desc "Labels only apply to the PSPDFKit monorepo."
      end

      command "review" do
        desc "Shows you reviewable pull requests."
      end
    end
  end
end
