require "test_helper"

class EventRankerTest < ActiveSupport::TestCase
  test "returns a relation compatible with includes and pagination" do
    ranked = EventRanker.rank(Event.where(id: events(:published_event).id).includes(:user))

    assert_kind_of ActiveRecord::Relation, ranked
    assert_equal 1, ranked.page(1).per(1).total_count
    assert_equal events(:published_event), ranked.page(1).per(1).first
  end

  test "does not duplicate events with multiple attendances" do
    event = create_ranked_event(title: "Ranked Multi Attendance Event")
    Attendance.create!(user: users(:one), event: event, status: "going")
    Attendance.create!(user: users(:two), event: event, status: "interested")
    Attendance.create!(user: users(:three), event: event, status: "going")

    ids = EventRanker.rank(Event.where(id: event.id)).map(&:id)

    assert_equal [ event.id ], ids
  end

  test "nil editor score uses auto score while zero editor score overrides it" do
    automatic = create_ranked_event(title: "Automatic Score Event", editor_score: nil)
    suppressed = create_ranked_event(title: "Suppressed Score Event", editor_score: 0)

    automatic_rank = ranked_event(automatic)
    suppressed_rank = ranked_event(suppressed)

    assert_operator automatic_rank[:auto_score].to_f, :>, 0
    assert_equal automatic_rank[:auto_score].to_f, automatic_rank[:final_score].to_f
    assert_operator suppressed_rank[:auto_score].to_f, :>, 0
    assert_equal 0, suppressed_rank[:final_score].to_i
  end

  test "real attendance interest affects ranking between otherwise similar events" do
    quiet = create_ranked_event(title: "Quiet Ranked Event", date: 7.days.from_now.change(hour: 20))
    active = create_ranked_event(title: "Active Ranked Event", date: quiet.date)
    Attendance.create!(user: users(:three), event: active, status: "going")

    ranked_ids = EventRanker.rank(Event.where(id: [ quiet.id, active.id ])).map(&:id)

    assert_equal active.id, ranked_ids.first
  end

  test "quality external event can be ranked without attendance" do
    imported = create_ranked_event(
      title: "Imported Quality Event",
      external_source: "etkinlik_io",
      external_id: "quality-event",
      external_url: "https://etkinlik.io/event/quality-event",
      remote_poster_url: "https://cdn.example.test/quality.jpg",
      ticket_url: "https://etkinlik.io/event/quality-event",
      ticket_url_kind: "etkinlik_detail",
      external_is_free: false
    )

    ranked = ranked_event(imported)

    assert_equal 0, ranked[:going_score].to_i
    assert_operator ranked[:final_score].to_f, :>, 0
  end

  private

  def ranked_event(event)
    EventRanker.rank(Event.where(id: event.id)).first
  end

  def create_ranked_event(attributes = {})
    defaults = {
      user: users(:one),
      title: "Ranked Event #{SecureRandom.hex(3)}",
      description: "A complete event description with enough detail for a reliable automatic score.",
      category: "technology",
      date: 6.days.from_now.change(hour: 19),
      city: "Online",
      location: "Online",
      price: 0,
      status: "published"
    }

    Event.create!(defaults.merge(attributes))
  end
end
