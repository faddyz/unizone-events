class SitemapsController < ApplicationController
  SITEMAP_EVENT_LIMIT = 1_000

  def show
    @sitemap_entries = static_entries + event_entries

    expires_in 12.hours, public: true
    render formats: :xml
  end

  private

  def static_entries
    [
      sitemap_entry(root_url, priority: "1.0", changefreq: "daily"),
      sitemap_entry(explore_events_url, priority: "0.9", changefreq: "daily"),
      sitemap_entry(faq_url, priority: "0.4", changefreq: "monthly"),
      sitemap_entry(contact_url, priority: "0.4", changefreq: "monthly"),
      sitemap_entry(terms_url, priority: "0.2", changefreq: "monthly"),
      sitemap_entry(privacy_policy_url, priority: "0.2", changefreq: "monthly")
    ]
  end

  def event_entries
    Event
      .published_visible
      .order(updated_at: :desc)
      .limit(SITEMAP_EVENT_LIMIT)
      .map do |event|
        sitemap_entry(
          event_url(event),
          lastmod: event.updated_at&.to_date&.iso8601,
          priority: "0.8",
          changefreq: "weekly"
        )
      end
  end

  def sitemap_entry(loc, lastmod: nil, priority: nil, changefreq: nil)
    {
      loc: loc,
      lastmod: lastmod,
      priority: priority,
      changefreq: changefreq
    }.compact
  end
end
