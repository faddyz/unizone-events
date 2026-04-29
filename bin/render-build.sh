#!/usr/bin/env bash

set -o errexit
set -x

bundle install

mkdir -p app/assets/builds

RAILS_ENV=production bundle exec rails tailwindcss:build --trace
RAILS_ENV=production bundle exec rails assets:precompile --trace

bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rails assets:clean