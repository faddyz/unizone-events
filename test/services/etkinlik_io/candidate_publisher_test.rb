require "test_helper"

class EtkinlikIo::CandidatePublisherTest < ActiveSupport::TestCase
  test "approves candidate by creating a published imported event" do
    candidate = create_candidate

    assert_difference "Event.count", 1 do
      event = EtkinlikIo::CandidatePublisher.new(candidate).call

      assert event.published?
      assert event.approved?
      assert event.imported?
      assert_equal candidate.source, event.external_source
      assert_equal candidate.external_id, event.external_id
      assert_equal "Online", event.city
      assert_equal "technology", event.category
      assert_equal "https://cdn.example.test/poster.jpg", event.remote_poster_url
      assert_equal "etkinlik_detail", event.ticket_url_kind
      assert_equal "importer@unizone.local", event.user.email
    end

    candidate.reload
    assert candidate.approved?
    assert_not_nil candidate.resolved_event
    assert_not_nil candidate.resolved_at
  end

  test "approved candidate is not published twice" do
    candidate = create_candidate
    first_event = EtkinlikIo::CandidatePublisher.new(candidate).call

    assert_no_difference "Event.count" do
      second_event = EtkinlikIo::CandidatePublisher.new(candidate.reload).call
      assert_equal first_event, second_event
    end
  end

  test "approval attributes can edit public event fields" do
    candidate = create_candidate

    event = EtkinlikIo::CandidatePublisher.new(candidate, {
      "title" => "Edited Title",
      "city" => "Ankara",
      "location" => "Edited Hall",
      "category" => "conference",
      "ticket_url" => "https://tickets.example.test/demo",
      "external_is_free" => "false"
    }).call

    assert_equal "Edited Title", event.title
    assert_equal "Ankara", event.city
    assert_equal "Edited Hall", event.location
    assert_equal "conference", event.category
    assert_equal "https://tickets.example.test/demo", event.ticket_url
    assert_not event.free?
  end

  test "approval decodes entities and strips imported html" do
    candidate = create_candidate
    candidate.update!(
      mapped_data: candidate.mapped_data.merge(
        "description" => "<p>Rock &amp; Jazz</p><script>alert(1)</script>"
      )
    )

    event = EtkinlikIo::CandidatePublisher.new(candidate).call

    assert_equal "Rock & Jazz", event.description
  end

  private

  def create_candidate
    ExternalEventCandidate.create!(
      source: ExternalEventCandidate::SOURCE_ETKINLIK_IO,
      external_id: "publish-#{SecureRandom.hex(4)}",
      status: "pending",
      title: "Imported Webinar",
      city: "Online",
      venue: "Online",
      venue_type: "ONLINE",
      starts_at: 4.days.from_now,
      ends_at: 4.days.from_now.change(hour: 20),
      category: "technology",
      format: "webinar",
      poster_url: "https://cdn.example.test/poster.jpg",
      ticket_url: "https://etkinlik.io/event/imported-webinar",
      external_url: "https://etkinlik.io/event/imported-webinar",
      ticket_url_kind: "etkinlik_detail",
      mapped_data: {
        "title" => "Imported Webinar",
        "description" => "Plain imported description.",
        "category" => "technology",
        "city" => "Online",
        "location" => "Online",
        "starts_at" => 4.days.from_now.iso8601,
        "ends_at" => 4.days.from_now.change(hour: 20).iso8601,
        "external_is_free" => false
      }
    )
  end
end
