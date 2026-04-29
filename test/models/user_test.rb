require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "organizer predicate follows owned events" do
    assert users(:one).organizer?
    assert_not users(:three).organizer?
  end
end
