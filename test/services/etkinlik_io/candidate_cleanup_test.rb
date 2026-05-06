require "test_helper"

class EtkinlikIo::CandidateCleanupTest < ActiveSupport::TestCase
  test "marks stale review candidates expired and strips old approved payloads" do
    pending = create_candidate(status: "pending", starts_at: 3.days.ago)
    approved = create_candidate(
      status: "approved",
      starts_at: 60.days.ago,
      raw_data: { "heavy" => "payload" },
      mapped_data: { "mapped" => "payload" }
    )

    report = EtkinlikIo::CandidateCleanup.new.call

    assert_equal 1, report[:expired_marked]
    assert_equal "expired", pending.reload.status
    assert_equal({}, approved.reload.raw_data)
    assert_equal({}, approved.mapped_data)
  end

  private

  def create_candidate(attributes = {})
    ExternalEventCandidate.create!({
      source: ExternalEventCandidate::SOURCE_ETKINLIK_IO,
      external_id: "cleanup-#{SecureRandom.hex(4)}",
      title: "Cleanup Candidate",
      city: "Ankara",
      venue: "Main Hall",
      venue_type: "VENUE",
      starts_at: 2.days.from_now,
      category: "community",
      external_url: "https://etkinlik.io/event/cleanup"
    }.merge(attributes))
  end
end
