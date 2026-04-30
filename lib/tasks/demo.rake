# frozen_string_literal: true

namespace :demo do
  desc "Refresh the idempotent fictional demo dataset without dropping the database"
  task refresh: :environment do
    Rails.application.load_seed
  end
end
