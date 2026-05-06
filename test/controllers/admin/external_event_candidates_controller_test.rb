require "test_helper"

class Admin::ExternalEventCandidatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:two)
    @member = users(:one)
    @candidate = create_candidate
  end

  test "admin can view candidate inbox and preview" do
    sign_in @admin

    get admin_external_event_candidates_path
    assert_response :success

    get admin_external_event_candidate_path(@candidate)
    assert_response :success
    assert_includes response.body, @candidate.title
  end

  test "non admin cannot view candidate inbox" do
    sign_in @member

    get admin_external_event_candidates_path

    assert_redirected_to root_path
  end

  test "admin can reject and skip candidates" do
    sign_in @admin

    patch reject_admin_external_event_candidate_path(@candidate)
    assert_redirected_to admin_external_event_candidates_path(preset: "rejected")
    assert_equal "rejected", @candidate.reload.status

    other = create_candidate(external_id: "skip-me")
    patch skip_admin_external_event_candidate_path(other)
    assert_redirected_to admin_external_event_candidates_path(preset: "skipped")
    assert_equal "skipped", other.reload.status
  end

  test "admin can approve candidate into public event" do
    sign_in @admin

    assert_difference "Event.count", 1 do
      patch approve_admin_external_event_candidate_path(@candidate), params: {
        approval: {
          title: "Approved API Event",
          category: "technology",
          city: "Online",
          location: "Online",
          description: "Approved description",
          starts_at: 5.days.from_now.iso8601,
          ends_at: 5.days.from_now.change(hour: 18).iso8601,
          ticket_url: @candidate.ticket_url,
          external_url: @candidate.external_url,
          external_is_free: "false",
          editor_score: "42"
        }
      }
    end

    assert_redirected_to admin_external_event_candidate_path(@candidate)
    event = @candidate.reload.resolved_event
    assert_equal "approved", @candidate.status
    assert event.published?
    assert_equal "Approved API Event", event.title
    assert_equal 42, event.editor_score
  end

  test "admin can approve from list without approval params" do
    sign_in @admin

    assert_difference "Event.count", 1 do
      patch approve_admin_external_event_candidate_path(@candidate),
            headers: { "HTTP_REFERER" => admin_external_event_candidates_url }
    end

    assert_redirected_to admin_external_event_candidates_path
    assert_equal "approved", @candidate.reload.status
    assert @candidate.resolved_event.published?
  end

  test "bulk approve validates all selected candidates before publishing" do
    sign_in @admin
    invalid = create_candidate(external_id: "missing-date", starts_at: nil, ends_at: nil)

    assert_no_difference "Event.count" do
      patch bulk_admin_external_event_candidates_path, params: {
        bulk_action: "approve",
        preset: "complete",
        candidate_ids: [ @candidate.id, invalid.id ]
      }
    end

    assert_redirected_to admin_external_event_candidates_path(preset: "complete", per_page: 20)
    assert_equal "pending", @candidate.reload.status
    assert_equal "pending", invalid.reload.status
    assert_match "Yayina alinamayan adaylar", flash[:alert]
  end

  test "admin can reset import pool while preserving approved skipped rejected" do
    sign_in @admin
    approved = create_candidate(external_id: "approved", status: "approved")
    skipped = create_candidate(external_id: "skipped", status: "skipped")
    rejected = create_candidate(external_id: "rejected", status: "rejected")
    hidden = create_candidate(external_id: "hidden", status: "hidden")
    pending = create_candidate(external_id: "pending", status: "pending")

    assert_difference "ExternalEventCandidate.count", -3 do
      delete reset_import_pool_admin_external_event_candidates_path
    end

    assert_redirected_to admin_external_event_candidates_path
    assert_not ExternalEventCandidate.exists?(@candidate.id)
    assert ExternalEventCandidate.exists?(approved.id)
    assert ExternalEventCandidate.exists?(skipped.id)
    assert ExternalEventCandidate.exists?(rejected.id)
    assert_not ExternalEventCandidate.exists?(hidden.id)
    assert_not ExternalEventCandidate.exists?(pending.id)
  end

  private

  def create_candidate(attributes = {})
    ExternalEventCandidate.create!({
      source: ExternalEventCandidate::SOURCE_ETKINLIK_IO,
      external_id: "controller-#{SecureRandom.hex(4)}",
      status: "pending",
      title: "Controller Candidate",
      city: "Online",
      venue: "Online",
      venue_type: "ONLINE",
      starts_at: 5.days.from_now,
      ends_at: 5.days.from_now.change(hour: 18),
      category: "technology",
      format: "webinar",
      poster_url: "https://cdn.example.test/controller.jpg",
      ticket_url: "https://etkinlik.io/event/controller",
      external_url: "https://etkinlik.io/event/controller",
      ticket_url_kind: "etkinlik_detail",
      mapped_data: {
        "description" => "Controller description",
        "external_is_free" => false
      }
    }.merge(attributes))
  end
end
