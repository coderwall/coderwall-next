# Coderwall

The codebase for (coderwall.com)[https://coderwall.com]. Coderwall is a developer community used by nearly half a million developers each month to learn and share programming tips.

## Prerequisites

* Ruby
* Postgres
* Heroku Toolbelt (or foreman gem)


## Getting Started

* cp .env.sample .env (most settings are not required for core functionality)
* bundle install
* rake db:create db:migrate
* heroku local
