require "test_helper"

class Admin::ExternalEventCandidateIndexPresenterTest < ActiveSupport::TestCase
  test "normalizes index params and exposes scan state" do
    recent = ImportRun.create!(
      source: ExternalEventCandidate::SOURCE_ETKINLIK_IO,
      status: "completed",
      started_at: 1.hour.ago
    )
    older = ImportRun.create!(
      source: ExternalEventCandidate::SOURCE_ETKINLIK_IO,
      status: "completed",
      started_at: 1.day.ago
    )

    presenter = Admin::ExternalEventCandidateIndexPresenter.new(
      scope: ExternalEventCandidate.all,
      params: { preset: "missing", query: "  demo  ", per_page: "999" }
    )

    assert_equal Admin::ExternalEventCandidateFilter::PRESETS, presenter.preset_tabs
    assert_equal "complete", presenter.preset
    assert_equal "demo", presenter.query
    assert_equal 20, presenter.per_page
    assert_equal recent, presenter.last_run
    assert_includes presenter.recent_runs, recent
    assert_includes presenter.recent_runs, older
    assert presenter.stats.key?("pending")
    assert presenter.scan_city_options.any?
    assert presenter.scan_format_options.any?
    assert presenter.scan_category_options.any?
  end

  test "filters candidates with normalized state" do
    match = create_candidate(title: "Presenter Search Match")
    other = create_candidate(title: "Unrelated Candidate")
    presenter = Admin::ExternalEventCandidateIndexPresenter.new(
      scope: ExternalEventCandidate.where(id: [ match.id, other.id ]),
      params: { preset: "complete", query: "search", per_page: "50" }
    )

    assert_equal 50, presenter.per_page
    assert_equal [ match ], presenter.filtered_candidates.to_a
  end

  private

  def create_candidate(attributes = {})
    ExternalEventCandidate.create!({
      source: ExternalEventCandidate::SOURCE_ETKINLIK_IO,
      external_id: "index-presenter-#{SecureRandom.hex(4)}",
      status: "pending",
      title: "Presenter Candidate",
      city: "Online",
      venue: "Online",
      venue_type: "ONLINE",
      starts_at: 5.days.from_now,
      ends_at: 5.days.from_now.change(hour: 18),
      category: "technology",
      poster_url: "https://cdn.example.test/presenter.jpg",
      ticket_url: "https://etkinlik.io/event/presenter",
      external_url: "https://etkinlik.io/event/presenter",
      ticket_url_kind: "etkinlik_detail",
      mapped_data: {
        "description" => "Presenter description",
        "external_is_free" => false
      }
    }.merge(attributes))
  end
end
