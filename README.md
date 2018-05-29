# Reviewbot

![](https://github.com/PSPDFKit-labs/reviewbot/blob/master/reviewbot.png?raw=true)

Reviewbot shows you pull requests on GitHub that are ready to be reviewed. How does it know when a pull request is ready? We have a special label in our repositories, aptly named READY TO REVIEW (all caps so it’s easier to spot). When a pull request is ready for review, the author adds this label to their PR to mark it as finished.

Meanwhile, all pull requests without this label are seen as works in progress and shouldn’t be reviewed. Next, an engineer can pick from the READY TO REVIEW pull requests and start reviewing — all code changes at PSPDFKit get reviewed by at least one other person. After the review is done, the pull request author incorporates the feedback and merges the PR.

You need to have `SLACK_API_TOKEN` and `GITHUB_ACCESS_TOKEN` set. Start the bot with `foreman start`.

Read more on the PSPDFKit Blog: https://pspdfkit.com/blog/2018/reviewbot

# Made with ❤️ by PSPDFKit

The [PSPDFKit SDK](https://pspdfkit.com/pdf-sdk/) is a framework that allows you to view, annotate, sign, and fill PDF forms on iOS, Android, Windows, macOS, and Web. [PSPDFKit Instant](https://pspdfkit.com/instant/) adds real-time collaboration features to seamlessly share, edit, and annotate PDF documents.

# License

```
The MIT License (MIT)

Copyright (c) 2018 PSPDFKit GmbH (pspdfkit.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
