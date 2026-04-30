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
