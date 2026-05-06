ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: Gem.win_platform? ? 1 : :number_of_processors)

    # Setup all top-level fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    self.fixture_paths = [ "test/fixtures" ]
    fixtures(*Dir["test/fixtures/*.yml"].map { |path| File.basename(path, ".yml").to_sym })

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
