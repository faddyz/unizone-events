require "test_helper"

class EventPolicyTest < ActiveSupport::TestCase
  test "guest can only view published events" do
    assert EventPolicy.new(nil, events(:published_event)).show?
    assert_not EventPolicy.new(nil, events(:submitted_event)).show?
    assert_not EventPolicy.new(nil, events(:owner_draft_event)).show?
  end

  test "owner can manage own non public event" do
    policy = EventPolicy.new(users(:one), events(:owner_draft_event))

    assert policy.show?
    assert policy.update?
    assert policy.destroy?
    assert policy.submit?
  end

  test "admin can moderate events" do
    policy = EventPolicy.new(users(:two), events(:owner_draft_event))

    assert policy.publish?
    assert policy.reject?
    assert policy.cancel?
  end

  test "scope includes published for guests and own events for members" do
    guest_scope = EventPolicy::Scope.new(nil, Event).resolve
    member_scope = EventPolicy::Scope.new(users(:one), Event).resolve
    admin_scope = EventPolicy::Scope.new(users(:two), Event).resolve

    assert_includes guest_scope, events(:published_event)
    refute_includes guest_scope, events(:submitted_event)

    assert_includes member_scope, events(:published_event)
    assert_includes member_scope, events(:owner_draft_event)
    refute_includes member_scope, events(:submitted_event)

    assert_includes admin_scope, events(:published_event)
    assert_includes admin_scope, events(:submitted_event)
    assert_includes admin_scope, events(:owner_draft_event)
  end
end
