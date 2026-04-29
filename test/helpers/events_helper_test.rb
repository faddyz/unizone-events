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
end
