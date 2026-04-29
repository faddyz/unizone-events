#!/usr/bin/env bash

# Exit on error
set -o errexit

bundle install
mkdir -p app/assets/builds
bin/rails assets:precompile
bin/rails assets:clean
bin/rails db:migrate
