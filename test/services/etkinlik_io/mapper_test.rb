require "test_helper"

class EtkinlikIo::MapperTest < ActiveSupport::TestCase
  test "maps venue events using venue_data and source ticket kind" do
    mapped = EtkinlikIo::Mapper.new(sample_payload).call

    assert_equal ExternalEventCandidate::SOURCE_ETKINLIK_IO, mapped[:source]
    assert_equal "123", mapped[:external_id]
    assert_equal "Ankara", mapped[:city]
    assert_equal "VENUE", mapped[:venue_type]
    assert_includes mapped[:venue], "Main Hall"
    assert_equal "conference", mapped[:category]
    assert_equal "etkinlik_detail", mapped[:ticket_url_kind]
    assert_equal "pending", mapped[:status]
    assert_equal "Hello World", mapped[:mapped_data]["description"]
  end

  test "keeps online events reviewable without a physical city" do
    payload = sample_payload.merge(
      "id" => 124,
      "venue_type" => "ONLINE",
      "venue_data" => nil,
      "format" => { "slug" => "webinar", "name" => "Webinar" },
      "category" => { "slug" => "bilim-teknoloji", "name" => "Bilim Teknoloji" }
    )

    mapped = EtkinlikIo::Mapper.new(payload).call

    assert_equal "Online", mapped[:city]
    assert_equal "ONLINE", mapped[:venue_type]
    assert_equal "technology", mapped[:category]
    assert_equal "pending", mapped[:status]
    assert_includes mapped[:priority_reasons], "online_priority_kept"
  end

  test "hides low priority categories unless explicitly included" do
    payload = sample_payload.merge(
      "id" => 125,
      "format" => { "slug" => "sahne-sanatlari", "name" => "Sahne" },
      "category" => { "slug" => "tiyatro-ve-gosteriler", "name" => "Tiyatro" }
    )

    hidden = EtkinlikIo::Mapper.new(payload).call
    included = EtkinlikIo::Mapper.new(payload, include_low_priority: true).call

    assert_equal "hidden", hidden[:status]
    assert_equal "low_priority_category", hidden[:hidden_reason]
    assert_equal "pending", included[:status]
    assert_equal "theater", included[:category]
  end

  test "concert format overrides low priority other category" do
    payload = sample_payload.merge(
      "id" => 126,
      "format" => { "slug" => "konser", "name" => "Konser" },
      "category" => { "slug" => "diger", "name" => "Diğer" }
    )

    mapped = EtkinlikIo::Mapper.new(payload).call

    assert_equal "pending", mapped[:status]
    assert_nil mapped[:hidden_reason]
    assert_equal "music", mapped[:category]
  end

  test "festival format overrides low priority other category" do
    payload = sample_payload.merge(
      "id" => 127,
      "format" => { "slug" => "festival", "name" => "Festival" },
      "category" => { "slug" => "diger", "name" => "Diğer" }
    )

    mapped = EtkinlikIo::Mapper.new(payload).call

    assert_equal "pending", mapped[:status]
    assert_nil mapped[:hidden_reason]
    assert_equal "festival", mapped[:category]
  end

  test "niche education under diger becomes low priority community" do
    payload = sample_payload.merge(
      "id" => 128,
      "name" => "Heykel - Kucuk Prens ve Collectable Bag Charm",
      "format" => { "slug" => "egitim", "name" => "Egitim" },
      "category" => { "slug" => "diger", "name" => "Diger" }
    )

    mapped = EtkinlikIo::Mapper.new(payload).call

    assert_equal "community", mapped[:category]
    assert_equal "hidden", mapped[:status]
    assert_equal "low_priority_category", mapped[:hidden_reason]
  end

  test "broad education under diger stays prioritized" do
    payload = sample_payload.merge(
      "id" => 129,
      "name" => "Yapay Zeka ve Veri Analizi Egitimi",
      "format" => { "slug" => "egitim", "name" => "Egitim" },
      "category" => { "slug" => "diger", "name" => "Diger" }
    )

    mapped = EtkinlikIo::Mapper.new(payload).call

    assert_equal "workshop", mapped[:category]
    assert_equal "pending", mapped[:status]
    assert_nil mapped[:hidden_reason]
  end

  test "classifies redirect ticket urls and cleans html entities" do
    payload = sample_payload.merge(
      "ticket_url" => "https://etkinlik.io/redirect-ticket-url/abc123",
      "content" => "<p>Rock &amp; Jazz</p><script>alert(1)</script>"
    )

    mapped = EtkinlikIo::Mapper.new(payload).call

    assert_equal "redirect_ticket", mapped[:ticket_url_kind]
    assert_equal "Rock & Jazz", mapped[:mapped_data]["description"]
  end

  test "normalizes non-breaking spaces in descriptions" do
    payload = sample_payload.merge(
      "content" => "<p>Karaoke,&nbsp;JJ ve Ebru Kaval,&nbsp;IF</p>"
    )

    mapped = EtkinlikIo::Mapper.new(payload).call

    assert_equal "Karaoke, JJ ve Ebru Kaval, IF", mapped[:mapped_data]["description"]
  end

  test "treats EtkinlikIO default poster urls as missing poster" do
    payload = sample_payload.merge(
      "poster_url" => "https://ifyazilim.nyc3.digitaloceanspaces.com/EtkIO/PublicSite/VarsayilanAfisler/2.jpg"
    )

    mapped = EtkinlikIo::Mapper.new(payload).call

    assert_nil mapped[:poster_url]
    assert_includes mapped[:review_reasons], "missing_poster"
  end

  test "classifies etkinlik api ticket-url endpoint as ticket redirect" do
    payload = sample_payload.merge(
      "ticket_url" => "https://etkinlik.io/api/v2/events/282895/ticket-url?publisher_code=CBejonrdsX"
    )

    mapped = EtkinlikIo::Mapper.new(payload).call

    assert_equal "redirect_ticket", mapped[:ticket_url_kind]
  end

  private

  def sample_payload
    {
      "id" => 123,
      "name" => "API Conference",
      "start" => 2.days.from_now.iso8601,
      "end" => 2.days.from_now.change(hour: 20).iso8601,
      "content" => "<p>Hello <strong>World</strong><script>alert(1)</script></p>",
      "is_free" => false,
      "poster_url" => "https://cdn.example.test/poster.jpg",
      "ticket_url" => "https://etkinlik.io/event/api-conference",
      "url" => "https://etkinlik.io/event/api-conference",
      "venue_type" => "VENUE",
      "venue_data" => {
        "name" => "Main Hall",
        "district_name" => "Cankaya",
        "address" => "Ataturk Boulevard",
        "city" => { "name" => "Ankara" }
      },
      "format" => { "slug" => "konferans", "name" => "Konferans" },
      "category" => { "slug" => "bilim-teknoloji", "name" => "Bilim Teknoloji" }
    }
  end
end
