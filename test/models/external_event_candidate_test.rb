require "test_helper"

class ExternalEventCandidateTest < ActiveSupport::TestCase
  test "source and external id are unique together" do
    create_candidate(external_id: "same")

    duplicate = build_candidate(external_id: "same")

    assert_not duplicate.valid?
    assert duplicate.errors[:external_id].present?
  end

  test "expired by clock uses end date before start date" do
    candidate = build_candidate(starts_at: 2.days.ago, ends_at: 1.hour.from_now)

    assert_not candidate.expired_by_clock?

    candidate.ends_at = 1.minute.ago

    assert candidate.expired_by_clock?
  end

  test "ticket helpers distinguish real ticket links from source links" do
    candidate = build_candidate(ticket_url: "https://tickets.example.test/event", ticket_url_kind: "external_ticket")
    source_candidate = build_candidate(ticket_url: "https://etkinlik.io/event/demo", ticket_url_kind: "etkinlik_detail")

    assert candidate.real_ticket_url?
    assert_not source_candidate.real_ticket_url?
    assert_equal "https://etkinlik.io/event/demo", source_candidate.source_url
  end

  test "redirect ticket links count as real ticket urls" do
    candidate = build_candidate(
      ticket_url: "https://etkinlik.io/redirect-ticket-url/demo",
      ticket_url_kind: "redirect_ticket",
      external_url: nil
    )

    assert candidate.real_ticket_url?
    assert_nil candidate.source_url
  end

  private

  def build_candidate(attributes = {})
    ExternalEventCandidate.new({
      source: ExternalEventCandidate::SOURCE_ETKINLIK_IO,
      external_id: "evt-#{SecureRandom.hex(4)}",
      title: "Candidate Event",
      city: "Ankara",
      venue: "Main Hall",
      venue_type: "VENUE",
      starts_at: 2.days.from_now,
      category: "technology",
      ticket_url: "https://etkinlik.io/event/demo",
      ticket_url_kind: "etkinlik_detail",
      external_url: "https://etkinlik.io/event/demo"
    }.merge(attributes))
  end

  def create_candidate(attributes = {})
    build_candidate(attributes).tap(&:save!)
  end
end
