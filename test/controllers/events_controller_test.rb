require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published_event = events(:published_event)
    @submitted_event = events(:submitted_event)
    @owner_draft_event = events(:owner_draft_event)
    @member = users(:one)
    @admin = users(:two)
    @other_user = users(:three)
  end

  test "public pages only surface published events" do
    get root_path
    assert_response :success
    assert_includes response.body, @published_event.title

    get explore_events_path
    assert_response :success
    assert_includes response.body, @published_event.title
    refute_includes response.body, @submitted_event.title
    refute_includes response.body, @owner_draft_event.title
  end

  test "explore applies search category date price and sort params" do
    free_event = Event.create!(
      user: @member,
      title: "Free Build Lab",
      description: "A focused build session for polished community projects.",
      category: "technology",
      date: 2.days.from_now,
      city: "İstanbul",
      location: "Demo Lab",
      price: 0,
      status: "published"
    )
    paid_event = Event.create!(
      user: @member,
      title: "Ticketed Music Night",
      description: "A paid night of live music and compact stage sets.",
      category: "music",
      date: 5.days.from_now,
      city: "Ankara",
      location: "Main Stage",
      price: 25,
      status: "published"
    )
    today_event = Event.create!(
      user: @member,
      title: "Today Design Crit",
      description: "A same-day review table for designers and builders.",
      category: "art",
      date: Time.zone.now.change(hour: 18, min: 0),
      city: "İzmir",
      location: "Studio Room",
      price: 0,
      status: "published"
    )
    Attendance.create!(user: @admin, event: paid_event, status: "going")
    Attendance.create!(user: @other_user, event: paid_event, status: "going")

    get explore_events_path(query: "Free Build")
    assert_response :success
    assert_includes results_html, free_event.title
    refute_includes results_html, paid_event.title

    get explore_events_path(category: "music")
    assert_response :success
    assert_includes results_html, paid_event.title
    refute_includes results_html, free_event.title

    get explore_events_path(city: "Ankara")
    assert_response :success
    assert_includes results_html, paid_event.title
    refute_includes results_html, free_event.title
    assert_includes response.body, "Şehir: Ankara"

    get explore_events_path(date_filter: "today")
    assert_response :success
    assert_includes results_html, today_event.title
    refute_includes results_html, paid_event.title

    get explore_events_path(price_filter: "free")
    assert_response :success
    assert_includes results_html, free_event.title
    refute_includes results_html, paid_event.title

    get explore_events_path(sort_by: "popular")
    assert_response :success
    results = results_html
    assert results.index(paid_event.title) < results.index(free_event.title)
    assert_includes response.body, "Sıralama: Popüler"
  end

  test "explore applies advanced time availability and registration filters" do
    evening_event = Event.create!(
      user: @member,
      title: "Evening RSVP Circle",
      description: "An evening event that uses the built-in RSVP flow.",
      category: "networking",
      date: 4.days.from_now.change(hour: 19, min: 0),
      city: "İstanbul",
      location: "Community Room",
      price: 0,
      capacity: 3,
      status: "published"
    )
    morning_event = Event.create!(
      user: @member,
      title: "Morning External Workshop",
      description: "A morning workshop with external registration.",
      category: "workshop",
      date: 4.days.from_now.change(hour: 9, min: 0),
      city: "İstanbul",
      location: "Workshop Studio",
      price: 15,
      ticket_url: "https://example.com/workshop",
      status: "published"
    )
    sold_out_event = Event.create!(
      user: @member,
      title: "Sold Out Tiny Room",
      description: "A tiny room event with no available seats.",
      category: "art",
      date: 5.days.from_now.change(hour: 20, min: 0),
      city: "İstanbul",
      location: "Tiny Room",
      price: 5,
      capacity: 1,
      status: "published"
    )
    Attendance.create!(user: @admin, event: evening_event, status: "going")
    Attendance.create!(user: @other_user, event: evening_event, status: "going")
    Attendance.create!(user: @admin, event: sold_out_event, status: "going")

    get explore_events_path(time_filter: "evening")
    assert_response :success
    assert_includes results_html, evening_event.title
    refute_includes results_html, morning_event.title

    get explore_events_path(availability_filter: "limited")
    assert_response :success
    assert_includes results_html, evening_event.title
    refute_includes results_html, sold_out_event.title

    get explore_events_path(registration_filter: "external")
    assert_response :success
    assert_includes results_html, morning_event.title
    refute_includes results_html, evening_event.title
    assert_includes response.body, "Kayıt: Dış kayıt"
  end

  test "explore renders grid and list view modes" do
    get explore_events_path
    assert_response :success
    assert_select ".explore-results-grid"
    assert_select ".event-card"

    get explore_events_path(view: "list")
    assert_response :success
    assert_select ".explore-results-list"
    assert_select ".explore-list-card"
  end

  test "event show surfaces conversion details" do
    get event_path(@published_event)

    assert_response :success
    assert_includes response.body, "Kayıt / bilet al"
    assert_includes response.body, @published_event.ticket_url
    assert_includes response.body, "Kontenjan"
  end

  test "guest cannot view non public event" do
    get event_path(@owner_draft_event)

    assert_response :not_found
  end

  test "owner can view organizer event page" do
    sign_in @member

    get organizer_event_path(@owner_draft_event)

    assert_response :success
  end

  test "organizer can submit draft for review" do
    sign_in @member

    patch submit_organizer_event_path(@owner_draft_event)

    assert_redirected_to organizer_event_path(@owner_draft_event.reload)
    assert_equal "submitted", @owner_draft_event.reload.status
  end

  test "admin can publish submitted event" do
    sign_in @admin

    patch publish_admin_event_path(@submitted_event)

    assert_redirected_to admin_event_path(@submitted_event.reload)
    assert_equal "published", @submitted_event.reload.status
  end

  test "non admin cannot access admin moderation" do
    sign_in @member

    get admin_events_path

    assert_redirected_to root_path
  end

  test "non owner cannot access another organizer event" do
    sign_in @other_user

    get organizer_event_path(@owner_draft_event)

    assert_response :not_found
  end

  private

  def results_html
    Nokogiri::HTML(response.body).at_css(".explore-results").to_html
  end
end
