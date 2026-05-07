require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "category badge classes are fixed Tailwind class strings" do
    classes = event_category_badge_classes(events(:published_event))

    assert_includes classes, "bg-[#1a3a6b]"
    assert_includes classes, "text-[#c8e6ff]"
    refute_includes classes, "<%="
  end

  test "event views do not interpolate category Tailwind classes dynamically" do
    view_paths = Dir[Rails.root.join("app/views/{events,admin/events,organizer/events}/**/*.erb")]

    view_paths.each do |path|
      content = File.read(path)

      refute_match(/category_color.*%>-/, content, "#{path} still interpolates category colors")
      refute_match(/-\s*<%=\s*.*category_color/, content, "#{path} still interpolates category colors")
    end
  end

  test "event image options include stable dimensions and async decoding" do
    options = event_image_options(:card, alt: "Poster", class_name: "event-poster-image", loading: "lazy")

    assert_equal 960, options[:width]
    assert_equal 540, options[:height]
    assert_equal "async", options[:decoding]
    assert_equal "lazy", options[:loading]
    assert_equal "event-poster-image", options[:class]
  end

  test "remote poster helper renders remote url before active storage" do
    event = events(:published_event)
    event.remote_poster_url = "https://cdn.example.test/poster.jpg"

    assert event_has_poster?(event)

    html = event_poster_image_tag(event, :card, alt: "Remote poster", class_name: "poster")

    assert_includes html, "https://cdn.example.test/poster.jpg"
    assert_includes html, "width=\"960\""
    assert_includes html, "height=\"540\""
  end

  test "imported pricing labels do not invent prices" do
    event = events(:published_event)
    event.external_source = "etkinlik_io"
    event.external_is_free = false
    event.price = nil

    event.ticket_url = "https://tickets.example.test/event"
    event.ticket_url_kind = "external_ticket"
    assert_equal "Biletli Etkinlik", event_price_text(event)

    event.ticket_url = "https://etkinlik.io/event/source"
    event.ticket_url_kind = "etkinlik_detail"
    assert_equal "Bilet bilgisi kaynakta", event_price_text(event)

    event.ticket_url = nil
    event.external_url = nil
    assert_equal "Bilet bilgisi dış kaynakta", event_price_text(event)
  end

  test "event cards hide source-only imported price copy" do
    event = events(:published_event)
    event.external_source = "etkinlik_io"
    event.external_is_free = false
    event.price = nil
    event.ticket_url = "https://etkinlik.io/event/source"
    event.ticket_url_kind = "etkinlik_detail"

    assert_nil event_card_price_text(event)

    event.ticket_url = "https://etkinlik.io/api/v2/events/282895/ticket-url?publisher_code=CBejonrdsX"
    event.ticket_url_kind = "redirect_ticket"
    assert_equal "Biletli", event_card_price_text(event)
  end

  test "short location keeps venue and district without full address" do
    assert_equal "Mask Beach · Beylikdüzü, İstanbul",
                 short_location_text("Mask Beach, Beylikdüzü, Marmara Mahallesi, Ulusum Caddesi No:34/6 G İç Kapı:0, İstanbul", "İstanbul")
  end

  test "event card dates use Turkish abbreviated month names" do
    date = Time.zone.local(2026, 8, 6, 16, 30)

    assert_equal "Ağu", event_card_month_label(date)
    assert_equal "06 Ağu, 16:30", event_card_datetime_label(date)
  end

  test "ongoing events use live timing labels" do
    event = events(:published_event)
    event.date = 30.minutes.ago
    event.end_date = 30.minutes.from_now
    event.external_source = "etkinlik_io"

    assert_equal "Şu anda gerçekleşiyor!", event_card_time_label(event)
    assert_includes event_card_time_classes(event), "is-live"
    assert_includes event_list_time_classes(event), "is-live"
    assert_includes event_show_datetime_label(event), "başladı;"
    assert_includes event_show_datetime_label(event), "event-live-inline"
    assert_includes event_show_datetime_label(event), "şu an devam ediyor."
  end

  test "imported events hide zero crowd counts in signal copy" do
    event = events(:published_event)
    event.external_source = "etkinlik_io"

    assert_equal "Katılım bilgisi kaynakta", event_crowd_signal_title(event, 0)
    assert_includes event_crowd_signal_copy(event, 0), "Dış kaynak katılım sayısı"
    assert_equal "2 kişi katılıyor!", event_crowd_signal_title(event, 2)
  end

  test "imported event decision signals stay decision oriented" do
    event = events(:published_event)
    event.external_source = "etkinlik_io"
    event.ticket_url = "https://tickets.example.test/event"
    event.ticket_url_kind = "external_ticket"

    assert_equal "Kaynak sinyali", event_decision_crowd_signal_label(event, 0)
    assert_equal "Kaynakta öne çıkan plan", event_decision_crowd_signal_title(event, 0)
    assert_includes event_decision_crowd_signal_copy(event, 0), "hızlıca değerlendirebilirsin"
    assert_equal "Biletli", event_decision_price_signal_title(event)
    assert_includes event_decision_registration_signal_copy(event, event.ticket_url), "doğrudan kaynak sayfadan"
  end

  test "display text decodes entities and strips imported html" do
    assert_equal "Rock & Jazz",
                 plain_display_text("<p>Rock &amp; Jazz</p><script>alert(1)</script>")
  end

  test "event counts use loaded attendances when present" do
    event = events(:published_event)
    event.association(:attendances).load_target
    queries = []

    callback = lambda do |_name, _started, _finished, _unique_id, payload|
      queries << payload[:sql] unless payload[:name] == "SCHEMA"
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      event.attendees_count
      event.total_responses_count
    end

    assert_empty queries
  end
end
