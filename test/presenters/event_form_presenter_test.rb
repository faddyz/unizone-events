require "test_helper"

class EventFormPresenterTest < ActionView::TestCase
  include EventsHelper

  test "exposes default new form copy and empty preview state" do
    event = Event.new(category: "music")
    event.city = nil
    presenter = EventFormPresenter.new(model: event, submit_label: "İncelemeye gönder", helpers: self)

    assert_equal "Etkinlik stüdyosu", presenter.form_title
    assert_equal "Detayları adım adım netleştir.", presenter.form_description
    assert_equal "Yeni etkinlik", presenter.rail_eyebrow
    assert_equal 4, presenter.step_count
    assert_equal "Tarih Seçilmedi", presenter.preview_date
    assert_equal "Şehir Seçilmedi", presenter.preview_city
    assert_equal "Katılım Butonu Önizlemesi", presenter.preview_ticket
    assert_equal "false", presenter.existing_image_data_value
    assert_not presenter.show_remove_image_control?
  end

  test "delegates field error output to form helper behavior" do
    event = Event.new(category: "music")
    event.valid?
    presenter = EventFormPresenter.new(model: event, submit_label: "Kaydet", helpers: self)

    assert presenter.field_error?(:title)
    assert_equal event_form_field_error_id(:title), presenter.field_error_id(:title)
    assert_equal event_form_field_error_message(event, :title), presenter.field_error_message(:title)
    assert_equal event_form_control_classes(event, :title), presenter.control_classes(:title)
    assert_equal event_form_aria(event, :title, describedby: "event-title-hint"),
                 presenter.aria(:title, describedby: "event-title-hint")
  end

  test "exposes persisted preview and image state" do
    event = events(:owner_draft_event)
    event.update!(capacity: 42, ticket_url: "https://example.com/ticket")
    event.image.attach(io: StringIO.new("image"), filename: "poster.png", content_type: "image/png")

    presenter = EventFormPresenter.new(model: event, mode: :edit, submit_label: "Değişiklikleri kaydet", helpers: self)

    assert_equal "Düzenleme", presenter.rail_eyebrow
    assert_equal event.title, presenter.preview_heading
    assert_equal "42 kişi", presenter.preview_capacity
    assert_equal "Dış Kayıt / Bilet Buton Önizlemesi", presenter.preview_ticket
    assert_equal "true", presenter.existing_image_data_value
    assert presenter.show_remove_image_control?
  end
end
