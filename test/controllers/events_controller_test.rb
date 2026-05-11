require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published_event = events(:published_event)
    @submitted_event = events(:submitted_event)
    @owner_draft_event = events(:owner_draft_event)
    @member = users(:one)
    @admin = users(:two)
    @other_user = users(:three)
  end

  test "public pages only surface published events" do
    get root_path
    assert_response :success
    assert_includes response.body, @published_event.title

    get explore_events_path
    assert_response :success
    assert_includes response.body, @published_event.title
    refute_includes response.body, @submitted_event.title
    refute_includes response.body, @owner_draft_event.title
  end

  test "public pages exclude expired published events" do
    expired_event = Event.create!(
      user: @member,
      title: "Expired Public Event",
      description: "This event should no longer appear publicly.",
      category: "technology",
      date: 1.minute.ago,
      city: "Online",
      location: "Online",
      status: "published"
    )

    get root_path
    assert_response :success
    refute_includes response.body, expired_event.title

    get explore_events_path
    assert_response :success
    refute_includes response.body, expired_event.title

    get event_path(expired_event)
    assert_response :not_found
  end

  test "homepage hides started ongoing events while explore and show keep them live" do
    ongoing_event = Event.create!(
      user: @member,
      title: "Live External Set",
      description: "An imported event that already started but has not ended yet.",
      category: "music",
      date: 30.minutes.ago,
      end_date: 30.minutes.from_now,
      city: "Online",
      location: "Online",
      status: "published",
      external_source: "etkinlik_io",
      external_id: "live-external-set"
    )

    get root_path
    assert_response :success
    refute_includes response.body, ongoing_event.title

    get explore_events_path
    assert_response :success
    assert_includes results_html, ongoing_event.title
    assert_includes results_html, "Şu anda gerçekleşiyor!"

    get explore_events_path(hide_started: "1")
    assert_response :success
    refute_includes results_html, ongoing_event.title
    assert_includes response.body, "Başlamış etkinlikler gizli"

    get event_path(ongoing_event)
    assert_response :success
    assert_includes response.body, "başladı;"
    assert_includes response.body, "event-live-inline"
    assert_includes response.body, "şu an devam ediyor."
  end

  test "explore applies search category date price and sort params" do
    free_event = Event.create!(
      user: @member,
      title: "Free Build Lab",
      description: "A focused build session for polished community projects.",
      category: "technology",
      date: 2.days.from_now,
      city: "İstanbul",
      location: "Demo Lab",
      price: 0,
      status: "published"
    )
    paid_event = Event.create!(
      user: @member,
      title: "Ticketed Music Night",
      description: "A paid night of live music and compact stage sets.",
      category: "music",
      date: 5.days.from_now,
      city: "Ankara",
      location: "Main Stage",
      price: 25,
      status: "published"
    )
    today_event = Event.create!(
      user: @member,
      title: "Today Design Crit",
      description: "A same-day review table for designers and builders.",
      category: "art_exhibition",
      date: Time.zone.now.change(hour: 23, min: 59),
      city: "İzmir",
      location: "Studio Room",
      price: 0,
      status: "published"
    )
    Attendance.create!(user: @admin, event: paid_event, status: "going")
    Attendance.create!(user: @other_user, event: paid_event, status: "going")

    get explore_events_path(query: "Free Build")
    assert_response :success
    assert_includes results_html, free_event.title
    refute_includes results_html, paid_event.title

    get explore_events_path(category: "music")
    assert_response :success
    assert_includes results_html, paid_event.title
    refute_includes results_html, free_event.title

    get explore_events_path(city: "Ankara")
    assert_response :success
    assert_includes results_html, paid_event.title
    refute_includes results_html, free_event.title
    assert_includes response.body, "Şehir: Ankara"

    get explore_events_path(date_filter: "today")
    assert_response :success
    assert_includes results_html, today_event.title
    refute_includes results_html, paid_event.title

    get explore_events_path(price_filter: "free")
    assert_response :success
    assert_includes results_html, free_event.title
    refute_includes results_html, paid_event.title

    get explore_events_path(sort_by: "popular")
    assert_response :success
    results = results_html
    assert results.index(paid_event.title) < results.index(free_event.title)
    assert_includes response.body, "Sıralama: Popüler"
  end

  test "explore applies advanced time availability and registration filters" do
    evening_event = Event.create!(
      user: @member,
      title: "Evening RSVP Circle",
      description: "An evening event that uses the built-in RSVP flow.",
      category: "networking",
      date: 4.days.from_now.change(hour: 19, min: 0),
      city: "İstanbul",
      location: "Community Room",
      price: 0,
      capacity: 3,
      status: "published"
    )
    morning_event = Event.create!(
      user: @member,
      title: "Morning External Workshop",
      description: "A morning workshop with external registration.",
      category: "workshop",
      date: 4.days.from_now.change(hour: 9, min: 0),
      city: "İstanbul",
      location: "Workshop Studio",
      price: 15,
      ticket_url: "https://example.com/workshop",
      status: "published"
    )
    sold_out_event = Event.create!(
      user: @member,
      title: "Sold Out Tiny Room",
      description: "A tiny room event with no available seats.",
      category: "art_exhibition",
      date: 5.days.from_now.change(hour: 20, min: 0),
      city: "İstanbul",
      location: "Tiny Room",
      price: 5,
      capacity: 1,
      status: "published"
    )
    Attendance.create!(user: @admin, event: evening_event, status: "going")
    Attendance.create!(user: @other_user, event: evening_event, status: "going")
    Attendance.create!(user: @admin, event: sold_out_event, status: "going")

    get explore_events_path(time_filter: "evening")
    assert_response :success
    assert_includes results_html, evening_event.title
    refute_includes results_html, morning_event.title

    get explore_events_path(availability_filter: "limited")
    assert_response :success
    assert_includes results_html, evening_event.title
    refute_includes results_html, sold_out_event.title

    get explore_events_path(registration_filter: "external")
    assert_response :success
    assert_includes results_html, morning_event.title
    refute_includes results_html, evening_event.title
    assert_includes response.body, "Kayıt: Dış kayıt"
  end

  test "explore renders grid and list view modes" do
    get explore_events_path
    assert_response :success
    assert_select ".explore-results-grid"
    assert_select ".event-card"

    get explore_events_path(view: "list")
    assert_response :success
    assert_select ".explore-results-list"
    assert_select ".explore-list-card"
  end

  test "explore renders load more controls when results span multiple pages" do
    13.times do |index|
      Event.create!(
        user: @member,
        title: "Paged Event #{index}",
        description: "A public event used to force pagination.",
        category: "technology",
        date: (index + 2).days.from_now,
        city: "Ankara",
        location: "Pagination Hall",
        status: "published"
      )
    end

    get explore_events_path(city: "Ankara", view: "list", date: Date.current, sort_by: "newest")

    assert_response :success
    assert_select ".explore-list-card", count: 12
    assert_select ".pagination-shell", count: 0
    assert_select ".explore-load-more-progress", text: "1–12 / 13 etkinlik gösteriliyor"
    assert_select "form.explore-load-more-form[action='#{explore_events_path}'][method='get']" do
      assert_select "input[type='hidden'][name='city'][value='Ankara']"
      assert_select "input[type='hidden'][name='view'][value='list']"
      assert_select "input[type='hidden'][name='date'][value='#{Date.current}']"
      assert_select "input[type='hidden'][name='sort_by'][value='newest']"
      assert_select "input[type='hidden'][name='page'][value='2']"
      assert_select "button[type='submit']", text: "Daha fazla etkinlik göster"
    end
  end

  test "explore turbo stream appends next event batch and replaces progress" do
    13.times do |index|
      Event.create!(
        user: @member,
        title: "Paged Event #{index}",
        description: "A public event used to force pagination.",
        category: "technology",
        date: (index + 2).days.from_now,
        city: "Ankara",
        location: "Pagination Hall",
        status: "published"
      )
    end

    get explore_events_path(city: "Ankara", view: "list", page: 2), as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action='append'][target='explore_events_results']" do
      assert_select ".explore-list-card", count: 1
      assert_select "a", text: "Paged Event 12"
    end
    assert_select "turbo-stream[action='replace'][target='explore_load_more']" do
      assert_select ".explore-load-more-progress", text: "13 etkinliğin tamamı gösteriliyor"
      assert_select "form.explore-load-more-form", count: 0
    end
  end

  test "public event cards render proxied optimized image variants" do
    attach_test_image(@published_event)

    get root_path

    assert_response :success
    assert_select "img[src*='/rails/active_storage/representations/proxy/']", minimum: 1
    assert_select "img[src*='/rails/active_storage/blobs/redirect/']", count: 0
  end

  test "sitemap lists public pages and published events" do
    get "/sitemap.xml"

    assert_response :success
    assert_equal "application/xml", response.media_type
    assert_includes response.body, root_url
    assert_includes response.body, event_url(@published_event)
    refute_includes response.body, event_url(@submitted_event)
  end

  test "event show surfaces conversion details" do
    get event_path(@published_event)

    assert_response :success
    assert_includes response.body, "Bilet Al"
    assert_includes response.body, @published_event.ticket_url
    assert_includes response.body, "Kontenjan"
  end

  test "event show surfaces imported attribution and source ticket copy" do
    imported_event = Event.create!(
      user: @member,
      title: "Imported Source Event",
      description: "Imported event description",
      category: "technology",
      date: 1.week.from_now,
      city: "Online",
      location: "Online",
      status: "published",
      external_source: "etkinlik_io",
      external_id: "imported-source-event",
      external_url: "https://etkinlik.io/event/imported-source-event",
      ticket_url: "https://etkinlik.io/event/imported-source-event",
      ticket_url_kind: "etkinlik_detail",
      external_is_free: false,
      remote_poster_url: "https://cdn.example.test/imported.jpg"
    )

    get event_path(imported_event)

    assert_response :success
    assert_includes response.body, "Bilet bilgisi kaynakta"
    assert_includes response.body, "Etkinlik Detayı"
    assert_includes response.body, "Kaynak: Etkinlik.io"
    refute_includes response.body, @member.email
    assert_includes response.body, imported_event.remote_poster_url
  end

  test "event show uses free registration copy for free imported ticket links" do
    imported_event = Event.create!(
      user: @member,
      title: "Imported Free Ticket Event",
      description: "Imported free event description",
      category: "technology",
      date: 1.week.from_now,
      city: "Online",
      location: "Online",
      status: "published",
      external_source: "etkinlik_io",
      external_id: "imported-free-ticket-event",
      external_url: "https://etkinlik.io/event/imported-free-ticket-event",
      ticket_url: "https://tickets.example.test/imported-free-ticket-event",
      ticket_url_kind: "external_ticket",
      external_is_free: true
    )

    get event_path(imported_event)

    assert_response :success
    assert_select "a.event-cta-primary", text: "Ücretsiz Katıl"
    assert_select "a.event-cta-primary", text: "Bilet Al", count: 0
    assert_select ".event-signal-card.is-mint h3", text: "Ücretsiz Katıl"
    assert_includes response.body, "Ücretsiz katılım adımına"
  end

  test "event show invites guests to sign in before choosing attendance" do
    internal_event = Event.create!(
      user: @member,
      title: "Internal Attendance Night",
      description: "A public event that uses the built-in attendance flow.",
      category: "technology",
      date: 1.week.from_now,
      city: "İstanbul",
      location: "Studio",
      price: 0,
      status: "published"
    )

    get event_path(internal_event)

    assert_response :success
    assert_includes response.body, "Katılmak için giriş yap"
    assert_includes response.body, "Hesap oluştur"
    assert_includes response.body, "Ürün, yazılım ve girişim ekosistemine"
    refute_includes response.body, "İlgilendiğini göster!"
    refute_includes response.body, "Pas geç."
  end

  test "guest cannot view non public event" do
    get event_path(@owner_draft_event)

    assert_response :not_found
  end

  test "owner can preview non public event on public show route" do
    sign_in @member

    get event_path(@owner_draft_event)

    assert_response :success
    assert_select "meta[name='robots'][content='noindex, nofollow']"
    assert_includes response.body, "Önizleme modu"
    assert_includes response.body, "Önizleme kilidi"
    refute_includes response.body, "data-action=\"share#share\""
    refute_includes response.body, "data-action=\"click-&gt;attendance#update\""
  end

  test "owner can view organizer event page" do
    sign_in @member

    get organizer_event_path(@owner_draft_event)

    assert_response :success
    assert_select "a[href='#{event_path(@owner_draft_event)}']", text: "Önizle"
    assert_select "a", text: "Yayındaki sayfa", count: 0
  end

  test "organizer event page links to live page once published" do
    sign_in @member

    get organizer_event_path(@published_event)

    assert_response :success
    assert_select "a[href='#{event_path(@published_event)}']", text: "Yayındaki sayfa"
    assert_select "a", text: "Önizle", count: 0
  end

  test "organizer can submit draft for review" do
    sign_in @member

    patch submit_organizer_event_path(@owner_draft_event)

    assert_redirected_to organizer_event_path(@owner_draft_event.reload)
    assert_equal "submitted", @owner_draft_event.reload.status
  end

  test "organizer update keeps existing image unless removal is requested" do
    sign_in @member
    attach_test_image(@owner_draft_event)

    patch organizer_event_path(@owner_draft_event), params: {
      event: {
        title: "Retitled Draft Event"
      }
    }

    assert_response :redirect
    assert @owner_draft_event.reload.image.attached?
    assert_equal "Retitled Draft Event", @owner_draft_event.title
  end

  test "organizer update removes image only when explicitly requested" do
    sign_in @member
    attach_test_image(@owner_draft_event)

    patch organizer_event_path(@owner_draft_event), params: {
      event: {
        title: "Draft Without Poster",
        remove_image: "1"
      }
    }

    assert_response :redirect
    assert_not @owner_draft_event.reload.image.attached?
  end

  test "replacement image wins over remove image checkbox" do
    sign_in @member
    attach_test_image(@owner_draft_event, filename: "old.png")

    file = Tempfile.new([ "replacement", ".png" ])
    file.binmode
    file.write("new image")
    file.rewind
    upload = Rack::Test::UploadedFile.new(file.path, "image/png", true, original_filename: "replacement.png")

    patch organizer_event_path(@owner_draft_event), params: {
      event: {
        title: "Draft With Replacement Poster",
        remove_image: "1",
        image: upload
      }
    }

    assert_response :redirect
    assert @owner_draft_event.reload.image.attached?
    assert_equal "replacement.png", @owner_draft_event.image.filename.to_s
  ensure
    file&.close!
  end

  test "organizer create rerenders invalid form with selected image" do
    sign_in @member

    file = Tempfile.new([ "poster", ".png" ])
    file.binmode
    file.write("png")
    file.rewind

    upload = Rack::Test::UploadedFile.new(file.path, "image/png", true, original_filename: "poster.png")

    assert_no_difference "Event.count" do
      post organizer_events_path, params: {
        event: {
          title: "Missing Date Poster Event",
          description: "This event is intentionally missing a date so the form rerenders.",
          category: "music",
          city: "Ankara",
          location: "Test Hall",
          price: "0",
          image: upload
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Missing Date Poster Event"
    assert_select ".event-form-error", text: /Form kaydedilemedi/
    assert_select "#event-date-error", text: /Tarih ve saati seç/
    assert_select "input[name='event[date]'][aria-invalid='true']"
  ensure
    file&.close!
  end

  test "organizer create surfaces field level validation errors" do
    sign_in @member

    assert_no_difference "Event.count" do
      post organizer_events_path, params: {
        event: {
          title: "",
          description: "Short but valid event description for validation coverage.",
          category: "music",
          date: 2.weeks.from_now,
          city: "Ankara",
          location: "Test Hall",
          price: "-1",
          capacity: "0",
          ticket_url: "not-a-url"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".event-form-error", text: /İşaretli alanları kontrol et|işaretli alanları kontrol et/
    assert_select "#event-title-error", text: /Etkinlik adını yaz/
    assert_select "#event-price-error", text: /0 veya daha yüksek/
    assert_select "#event-capacity-error", text: /en az 1/
    assert_select "#event-ticket-url-error", text: /geçerli bir bağlantı/
    assert_select "input[name='event[title]'][aria-invalid='true']"
  end

  test "admin can publish submitted event" do
    sign_in @admin

    patch publish_admin_event_path(@submitted_event)

    assert_redirected_to admin_event_path(@submitted_event.reload)
    assert_equal "published", @submitted_event.reload.status
  end

  test "non admin cannot access admin moderation" do
    sign_in @member

    get admin_events_path

    assert_redirected_to root_path
  end

  test "non owner cannot access another organizer event" do
    sign_in @other_user

    get organizer_event_path(@owner_draft_event)

    assert_response :not_found
  end

  private

  def results_html
    Nokogiri::HTML(response.body).at_css(".explore-results").to_html
  end

  def attach_test_image(event, filename: "poster.png", content_type: "image/png")
    event.image.attach(io: StringIO.new("image"), filename: filename, content_type: content_type)
  end
end
