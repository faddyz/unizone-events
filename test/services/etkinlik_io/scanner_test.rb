require "test_helper"

class EtkinlikIo::ScannerTest < ActiveSupport::TestCase
  test "dry run fetches and records stats without saving candidates" do
    client = FakeEtkinlikClient.new([ sample_payload("dry-run-1") ])

    assert_no_difference "ExternalEventCandidate.count" do
      run = EtkinlikIo::Scanner.new(scan_params, client: client, save: false).call

      assert run.dry_run?
      assert_equal "completed", run.status
      assert_equal 1, run.fetched_count
      assert_equal 0, run.new_candidate_count
    end

    assert_equal 7, client.requests.first[:city_ids]
    assert_equal 2, client.requests.first[:take]
    assert_equal "19", client.requests.first[:format_ids]
  end

  test "save creates new candidates and preserves hard duplicates" do
    payload = sample_payload("save-1")
    client = FakeEtkinlikClient.new([ payload ])

    assert_difference "ExternalEventCandidate.count", 1 do
      run = EtkinlikIo::Scanner.new(scan_params, client: client, save: true).call

      assert_equal 1, run.new_candidate_count
      assert_equal 0, run.duplicate_count
    end

    second_client = FakeEtkinlikClient.new([ payload ])

    assert_no_difference "ExternalEventCandidate.count" do
      run = EtkinlikIo::Scanner.new(scan_params, client: second_client, save: true).call

      assert_equal 0, run.new_candidate_count
      assert_equal 1, run.duplicate_count
    end
  end

  private

  def scan_params
    {
      city_slugs: [ "ankara" ],
      format_ids: [ "19" ],
      category_ids: [ "1423" ],
      batch_size: "2",
      max_scan_limit: "10"
    }
  end

  def sample_payload(id)
    {
      "id" => id,
      "name" => "Scanner Concert",
      "start" => 3.days.from_now.iso8601,
      "end" => 3.days.from_now.change(hour: 22).iso8601,
      "content" => "Scanner content",
      "is_free" => true,
      "poster_url" => "https://cdn.example.test/#{id}.jpg",
      "ticket_url" => "https://etkinlik.io/event/#{id}",
      "url" => "https://etkinlik.io/event/#{id}",
      "venue_type" => "VENUE",
      "venue_data" => {
        "name" => "Concert Hall",
        "city" => { "name" => "Ankara" }
      },
      "format" => { "slug" => "konser", "name" => "Konser" },
      "category" => { "slug" => "alternatif-muzik", "name" => "Alternatif Muzik" }
    }
  end

  class FakeEtkinlikClient
    attr_reader :requests

    def initialize(items)
      @items = items
      @requests = []
    end

    def events(params)
      @requests << params
      { "items" => @items }
    end

    def cities
      [
        { "id" => 7, "name" => "Ankara", "slug" => "ankara" }
      ]
    end
  end
end
