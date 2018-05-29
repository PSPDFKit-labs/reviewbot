# Reviewbot



Reviewbot shows you pull requests on GitHub that are ready to be reviewed. How does it know when a pull request is ready? We have a special label in our repositories, aptly named "READY TO REVIEW" (all caps so it's easier to spot). The pull request author adds this label to his or her PR to mark it as finished. All pull requests without this label are seen as work in progress and shouldn't be reviewed yet. An engineer can pick from the "ready to review" pull requests and start reviewing. All code changes at PSPDFKit get reviewed by at least one other person. After the review is done the pull request author incorporates the feedback and merges the PR.

Read more: https://pspdfkit.com/blog/2018/reviewbot

You need to have `SLACK_API_TOKEN` and `GITHUB_ACCESS_TOKEN` set. Start the bot with `foreman start`.
