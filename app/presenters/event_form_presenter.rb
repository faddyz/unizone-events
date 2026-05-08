class EventFormPresenter
  STEPS = [
    { label: "Temel Bilgiler", title: "Başlık ve Kategori", summary: "İnsanların akışta ilk göreceği sinyali netleştir.", icon: "edit" },
    { label: "Tarih ve Konum", title: "Tarih ve Konum", summary: "Katılımcıların plan yapabilmesi için zaman, mekan ve kontenjan bilgilerini netleştir.", icon: "calendar" },
    { label: "Etkinlik Hikayesi", title: "Etkinlik hikayesi", summary: "Katılımcıların ne bekleyeceğini açık, kısa ve ikna edici şekilde anlat.", icon: "ticket" },
    { label: "Afiş Görseli", title: "Afiş ve Son Kontrol", summary: "Görselini ekle, bilgileri kontrol et ve etkinliğini incelemeye gönder.", icon: "check_circle" }
  ].freeze

  attr_reader :model, :mode, :submit_label, :cancel_path

  def initialize(model:, submit_label:, mode: :new, form_title: nil, form_description: nil, cancel_path: nil, helpers:)
    @model = model
    @mode = mode.to_sym
    @submit_label = submit_label
    @form_title = form_title
    @form_description = form_description
    @cancel_path = cancel_path
    @helpers = helpers
  end

  def edit?
    mode == :edit
  end

  def form_title
    @form_title.presence || (edit? ? "Etkinliği düzenle" : "Etkinlik stüdyosu")
  end

  def form_description
    @form_description.presence || "Detayları adım adım netleştir."
  end

  def rail_eyebrow
    edit? ? "Düzenleme" : "Yeni etkinlik"
  end

  def steps
    STEPS
  end

  def first_step
    steps.first
  end

  def step_count
    steps.length
  end

  def category_options
    @category_options ||= Event.categories.keys.map { |category| [ helpers.event_category_title(category), category ] }
  end

  def city_options
    Event::CITY_OPTIONS
  end

  def field_error?(attribute)
    helpers.event_form_field_error?(model, attribute)
  end

  def field_error_id(attribute)
    helpers.event_form_field_error_id(attribute)
  end

  def field_error_message(attribute)
    helpers.event_form_field_error_message(model, attribute)
  end

  def control_classes(attribute, base: "event-form-control")
    helpers.event_form_control_classes(model, attribute, base: base)
  end

  def aria(attribute, describedby: nil)
    helpers.event_form_aria(model, attribute, describedby: describedby)
  end

  def preview_month
    model.date.present? ? model.date.strftime("%b") : "Ay"
  end

  def preview_day
    model.date.present? ? model.date.strftime("%-d") : "--"
  end

  def preview_title
    model.title.presence || "Etkinlik adı"
  end

  def preview_heading
    model.title.presence || "Etkinlik adı burada parlayacak."
  end

  def preview_description
    model.description.presence || "Etkinliğin atmosferi, akışı ve katılımcıların ne bekleyebileceği burada canlanacak."
  end

  def preview_description_summary
    helpers.truncate(preview_description, length: 130)
  end

  def preview_date
    model.date.present? ? helpers.l(model.date, format: :long) : "Tarih Seçilmedi"
  end

  def preview_city
    model.city.presence || "Şehir Seçilmedi"
  end

  def preview_location
    model.location.presence || "Konum seçilmedi"
  end

  def preview_price
    @preview_price ||= helpers.event_price_text(model)
  end

  def preview_capacity
    model.capacity.present? ? "#{model.capacity} kişi" : "Kontenjan açık"
  end

  def preview_ticket
    model.ticket_url.present? ? "Dış Kayıt / Bilet Buton Önizlemesi" : "Katılım Butonu Önizlemesi"
  end

  def preview_category
    helpers.event_category_title(model)
  end

  def preview_status
    model.persisted? ? helpers.event_status_label(model) : "İncelemeye gidecek"
  end

  def existing_image?
    model.image.attached? && model.image.attachment&.persisted?
  end

  def existing_image_data_value
    existing_image? ? "true" : "false"
  end

  def preview_fallback_classes
    existing_image? ? "hidden" : ""
  end

  def show_remove_image_control?
    model.persisted? && existing_image?
  end

  private

  attr_reader :helpers
end
