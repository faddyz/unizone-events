require "test_helper"

class ProductFlowsTest < ActionDispatch::IntegrationTest
  setup do
    @member = users(:one)
    @admin = users(:two)
    @other_user = users(:three)
    @published_event = events(:published_event)
    @submitted_event = events(:submitted_event)
    @draft_event = events(:owner_draft_event)
  end

  test "guest can browse published events but is redirected from member areas" do
    get root_path
    assert_response :success
    assert_includes response.body, @published_event.title
    refute_includes response.body, @submitted_event.title

    get dashboard_path
    assert_redirected_to new_user_session_path

    get organizer_events_path
    assert_redirected_to new_user_session_path
  end

  test "member dashboard shows owned events and RSVP history" do
    Attendance.create!(user: @member, event: @published_event, status: "interested")
    sign_in @member

    get dashboard_path

    assert_response :success
    assert_includes response.body, @draft_event.title
    assert_includes response.body, @published_event.title
    assert_includes response.body, "İlgileniyorum"
    assert_includes response.body, "Etkinlik bul"
    assert_includes response.body, "Son RSVP"
  end

  test "organizer workbench filters searches and surfaces key actions" do
    rejected_event = Event.create!(
      user: @member,
      title: "Rejected Workshop Draft",
      description: "A workshop draft that needs clearer public details before publishing.",
      category: "workshop",
      date: 4.weeks.from_now,
      city: "İstanbul",
      location: "Review Studio",
      price: 0,
      status: "rejected",
      review_note: "Needs clearer details"
    )

    sign_in @member

    get organizer_events_path(status: "draft")
    assert_response :success
    assert_includes response.body, @draft_event.title
    refute_includes response.body, @published_event.title

    get organizer_events_path(query: "Main Hall")
    assert_response :success
    assert_includes response.body, @published_event.title
    refute_includes response.body, @draft_event.title

    get organizer_events_path(status: "rejected")
    assert_response :success
    assert_includes response.body, rejected_event.title
    assert_includes response.body, "Needs clearer details"
    assert_includes response.body, "İncelemeye gönder"

    get organizer_events_path(status: "published")
    assert_response :success
    assert_includes response.body, "Yayındaki sayfa"
  end

  test "organizer can create an event directly for review" do
    sign_in @member

    assert_difference -> { @member.events.count }, 1 do
      post organizer_events_path, params: {
        event: {
          title: "Launch Meetup",
          description: "A focused meetup for builders shipping polished community projects.",
          category: "technology",
          date: 3.weeks.from_now,
          city: "İstanbul",
          location: "Demo Studio",
          price: 0
        }
      }
    end

    event = @member.events.order(:created_at).last
    assert_redirected_to organizer_event_path(event)
    assert_equal "submitted", event.status
  end

  test "editing a published organizer event moves it back to review" do
    sign_in @member

    patch organizer_event_path(@published_event), params: {
      event: {
        title: "Updated Published Event",
        description: @published_event.description,
        category: @published_event.category,
        date: @published_event.date,
        city: @published_event.city,
        location: @published_event.location,
        price: @published_event.price
      }
    }

    assert_redirected_to organizer_event_path(@published_event.reload)
    assert_equal "submitted", @published_event.status
    assert_equal "Updated Published Event", @published_event.title
  end

  test "admin can review, reject, publish, and cancel events" do
    sign_in @admin

    get admin_events_path
    assert_response :success
    assert_includes response.body, @submitted_event.title

    patch reject_admin_event_path(@submitted_event)
    assert_redirected_to admin_event_path(@submitted_event.reload)
    assert_equal "rejected", @submitted_event.status

    @submitted_event.update!(status: "submitted")
    patch publish_admin_event_path(@submitted_event)
    assert_redirected_to admin_event_path(@submitted_event.reload)
    assert_equal "published", @submitted_event.status
    assert @submitted_event.published_at.present?

    patch cancel_admin_event_path(@submitted_event)
    assert_redirected_to admin_event_path(@submitted_event.reload)
    assert_equal "cancelled", @submitted_event.status
  end

  test "admin review panel filters searches and renders decision tools" do
    searchable_event = Event.create!(
      user: @member,
      title: "Admin Searchable Studio Review",
      description: "A submitted event for admins to search by title, city, category, host, and venue.",
      category: "conference",
      date: 2.weeks.from_now,
      city: "Ankara",
      location: "Admin Review Hall",
      price: 0,
      status: "submitted"
    )

    sign_in @admin

    get admin_events_path(query: "Review Hall")
    assert_response :success
    admin_results = Nokogiri::HTML(response.body).at_css(".admin-review-results").to_html
    assert_includes admin_results, searchable_event.title
    refute_includes admin_results, @submitted_event.title

    get admin_events_path(category: "conference", city: "Ankara")
    assert_response :success
    assert_includes response.body, searchable_event.title

    get admin_event_path(searchable_event)
    assert_response :success
    assert_includes response.body, "Karar paneli"
    assert_includes response.body, "Poster kontrolü"
    assert_includes response.body, "Yayına al"
    assert_includes response.body, "Düzenlemeye gönder"
  end

  test "member can manage account profile without touching another account" do
    sign_in @other_user

    patch account_profile_path, params: {
      user: {
        name: "Updated Member",
        email: @other_user.email
      }
    }

    assert_redirected_to account_profile_path
    assert_equal "Updated Member", @other_user.reload.name
    refute_equal "Updated Member", @member.reload.name
  end
end
