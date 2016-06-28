# Contributing

We welcome ideas and contributions on Coderwall. If you want to contribute something, here's how:

1. Check the product [readme][readme] for the latest product direction and how to run the code locally.

[readme]: https://github.com/coderwall/coderwall-next/compare/

2. For new feature ideas, we recommend creating an issue first that briefly describes the feature you want to add. This gives others involved with Coderwall an opportunity to discuss and provide feedback.

3. [Submit a pull request][pr] with your code and design changes.

[pr]: https://github.com/coderwall/coderwall-next/compare/


3. Please give us up to a week to review the pull request and comment. We may suggest
some changes or improvements or alternatives. If you don't receive a timely response you can escalate your PR by contacting support@coderwall.com

## Pull Request Guidelines

Some things that will increase the chance that your pull request is accepted:

* Write test for your changes and make sure all the tests pass.
* Keep it as conventional and simple as possible. Coderwall serves 100,000 of devs each month on very minimal oversight. We want the product quick to support and easy to enhance. This includes being very thoughtful before adding external dependencies or deviating from the conventional vanilla rails project structure.
* Use [basscss](http://www.basscss.com) for all css. It is a really really really good atomic class based CSS library. You should rarely have to add a new style or custom css but if you do, please only do so in application.scss.
* Make any settings a configuration accessible through ENV with an example setting in .env.sample
