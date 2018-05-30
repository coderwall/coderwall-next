# Coderwall

[![Build Status](https://travis-ci.org/coderwall/coderwall-next.svg?branch=master)](https://travis-ci.org/coderwall/coderwall-next)

The codebase for [coderwall.com](https://coderwall.com). Coderwall is a developer community used by nearly half a million developers each month to learn and share programming tips.

## Prerequisites

* Ruby
* Postgres
* Heroku Toolbelt (or foreman gem)

## Get Started

```bash
cp .env.sample .env  # (most settings are not required for core functionality)
bundle install
rake db:create db:migrate
heroku local
```

## Updating SSL

```
$ ./update-ssl.sh
```
