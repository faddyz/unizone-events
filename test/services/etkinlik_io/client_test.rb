require "test_helper"

class EtkinlikIo::ClientTest < ActiveSupport::TestCase
  test "requires a token" do
    assert_raises EtkinlikIo::Client::MissingTokenError do
      EtkinlikIo::Client.new(token: "")
    end
  end

  test "sends token header and query params" do
    client = RecordingClient.new(token: "secret-token", base_url: "https://api.example.test")

    response = client.events(take: 5, city_ids: 7)

    assert_equal [], response.fetch("items")
    assert_equal "secret-token", client.recorded_request["X-Etkinlik-Token"]
    assert_equal "application/json", client.recorded_request["Accept"]
    assert_equal "/events", client.recorded_uri.path
    assert_includes client.recorded_uri.query, "take=5"
    assert_includes client.recorded_uri.query, "city_ids=7"
  end

  private

  class RecordingClient < EtkinlikIo::Client
    attr_reader :recorded_uri, :recorded_request

    private

    def perform_request(uri, request)
      @recorded_uri = uri
      @recorded_request = request
      FakeSuccess.new('{"items":[]}', "200")
    end
  end

  FakeSuccess = Struct.new(:body, :code) do
    def is_a?(klass)
      klass == Net::HTTPSuccess || super
    end
  end
end
