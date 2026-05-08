class EventSearchParams
  PERMITTED_KEYS = [
    :query,
    :city,
    :date,
    :date_filter,
    :start_date,
    :end_date,
    :time_filter,
    :price_filter,
    :availability_filter,
    :registration_filter,
    :hide_started,
    :sort_by,
    :view,
    :category
  ].freeze

  def self.from(params)
    params.permit(*PERMITTED_KEYS, category: [])
  end
end
