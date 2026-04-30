#!/usr/bin/env bash

set -o errexit
set -x

bundle install
npm ci --include=dev --no-audit --no-fund

mkdir -p app/assets/builds

RAILS_ENV=production bundle exec rails tailwindcss:build --trace
RAILS_ENV=production bundle exec rails assets:precompile --trace

bundle exec rails db:migrate
bundle exec rails assets:clean
