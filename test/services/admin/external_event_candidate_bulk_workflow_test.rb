require "test_helper"

class Admin::ExternalEventCandidateBulkWorkflowTest < ActiveSupport::TestCase
  test "returns selected candidate alert when no ids are submitted" do
    result = Admin::ExternalEventCandidateBulkWorkflow.new(
      action: "skip",
      candidate_ids: [],
      scope: ExternalEventCandidate.all,
      filtered_scope: ExternalEventCandidate.none
    ).call

    assert_equal "Once aday sec.", result.alert
    assert_nil result.notice
  end

  test "updates selected candidates through bulk action" do
    candidate = create_candidate

    result = Admin::ExternalEventCandidateBulkWorkflow.new(
      action: "skip",
      candidate_ids: [ candidate.id ],
      scope: ExternalEventCandidate.all,
      filtered_scope: ExternalEventCandidate.none
    ).call

    assert_equal "1 aday guncellendi.", result.notice
    assert_nil result.alert
    assert_equal "skipped", candidate.reload.status
  end

  test "approves pending candidates in filtered scope" do
    candidate = create_candidate

    assert_difference "Event.count", 1 do
      result = Admin::ExternalEventCandidateBulkWorkflow.new(
        action: "approve_filtered",
        candidate_ids: [],
        scope: ExternalEventCandidate.all,
        filtered_scope: ExternalEventCandidate.where(id: candidate.id)
      ).call

      assert_equal "1 aday yayinlandi.", result.notice
      assert_nil result.alert
    end

    assert_equal "approved", candidate.reload.status
  end

  test "validates approvals before publishing" do
    valid = create_candidate
    invalid = create_candidate(starts_at: nil, ends_at: nil)

    assert_no_difference "Event.count" do
      result = Admin::ExternalEventCandidateBulkWorkflow.new(
        action: "approve",
        candidate_ids: [ valid.id, invalid.id ],
        scope: ExternalEventCandidate.all,
        filtered_scope: ExternalEventCandidate.none
      ).call

      assert_match "Yayina alinamayan adaylar", result.alert
      assert_nil result.notice
    end

    assert_equal "pending", valid.reload.status
    assert_equal "pending", invalid.reload.status
  end

  private

  def create_candidate(attributes = {})
    ExternalEventCandidate.create!({
      source: ExternalEventCandidate::SOURCE_ETKINLIK_IO,
      external_id: "bulk-workflow-#{SecureRandom.hex(4)}",
      status: "pending",
      title: "Bulk Workflow Candidate",
      city: "Online",
      venue: "Online",
      venue_type: "ONLINE",
      starts_at: 5.days.from_now,
      ends_at: 5.days.from_now.change(hour: 18),
      category: "technology",
      format: "webinar",
      poster_url: "https://cdn.example.test/bulk.jpg",
      ticket_url: "https://etkinlik.io/event/bulk",
      external_url: "https://etkinlik.io/event/bulk",
      ticket_url_kind: "etkinlik_detail",
      mapped_data: {
        "title" => "Bulk Workflow Candidate",
        "description" => "Bulk workflow description",
        "category" => "technology",
        "city" => "Online",
        "location" => "Online",
        "external_is_free" => false
      }
    }.merge(attributes))
  end
end
