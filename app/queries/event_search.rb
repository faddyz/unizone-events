class EventSearch
  SORT_OPTIONS = %w[date_asc date_desc popular newest].freeze

  attr_reader :scope, :params

  def initialize(scope:, params:)
    @scope = scope
    @params = params.to_h.symbolize_keys
  end

  def results
    relation = scope
    relation = filter_by_query(relation)
    relation = filter_by_city(relation)
    relation = filter_by_category(relation)
    relation = filter_by_exact_date(relation)
    relation = filter_by_date_filter(relation)
    relation = filter_by_custom_dates(relation)
    relation = filter_by_time(relation)
    relation = filter_by_price(relation)
    relation = filter_by_availability(relation)
    relation = filter_by_registration(relation)
    sort(relation)
  end

  private

  def filter_by_query(relation)
    return relation unless params[:query].present?

    relation.by_query(params[:query])
  end

  def filter_by_category(relation)
    categories = Array(params[:category]).flatten.reject(&:blank?).uniq
    return relation if categories.blank?

    relation.by_category(categories)
  end

  def filter_by_city(relation)
    city = params[:city].to_s
    return relation unless Event::CITY_OPTIONS.include?(city)

    relation.by_city(city)
  end

  def filter_by_exact_date(relation)
    return relation unless params[:date].present?

    relation.by_date(params[:date])
  end

  def filter_by_date_filter(relation)
    case params[:date_filter].to_s
    when "", "all"
      relation
    when "today"
      relation.where("DATE(date) = ?", Time.zone.today)
    when "tomorrow"
      relation.where("DATE(date) = ?", Time.zone.tomorrow)
    when "tonight"
      relation.where(date: Time.zone.today.beginning_of_day + 18.hours..Time.zone.tomorrow.beginning_of_day + 5.hours)
    when "this_week"
      relation.where(date: Time.zone.today.beginning_of_week..Time.zone.today.end_of_week.end_of_day)
    when "weekend"
      relation.where(date: weekend_range)
    when "this_month"
      relation.where(date: Time.zone.today.beginning_of_month..Time.zone.today.end_of_month.end_of_day)
    when "past"
      relation.where("date < ?", Time.zone.now.beginning_of_day)
    when "upcoming"
      relation.where("date >= ?", Time.zone.now.beginning_of_day)
    else
      relation
    end
  end

  def filter_by_time(relation)
    case params[:time_filter].to_s
    when "morning"
      relation.where("EXTRACT(HOUR FROM date) >= 5 AND EXTRACT(HOUR FROM date) < 12")
    when "afternoon"
      relation.where("EXTRACT(HOUR FROM date) >= 12 AND EXTRACT(HOUR FROM date) < 17")
    when "evening"
      relation.where("EXTRACT(HOUR FROM date) >= 17 AND EXTRACT(HOUR FROM date) < 22")
    when "night"
      relation.where("(EXTRACT(HOUR FROM date) >= 22 OR EXTRACT(HOUR FROM date) < 5)")
    else
      relation
    end
  end

  def filter_by_custom_dates(relation)
    start_date = parsed_date(params[:start_date])
    end_date = parsed_date(params[:end_date])

    if start_date && end_date
      relation.where(date: start_date.beginning_of_day..end_date.end_of_day)
    elsif start_date
      relation.where("date >= ?", start_date.beginning_of_day)
    else
      relation
    end
  end

  def filter_by_price(relation)
    case params[:price_filter].to_s
    when "free"
      relation.where("price = 0 OR price IS NULL")
    when "paid"
      relation.where("price > 0")
    else
      relation
    end
  end

  def filter_by_availability(relation)
    going_count = "SELECT COUNT(*) FROM attendances WHERE attendances.event_id = events.id AND attendances.status = 'going'"

    case params[:availability_filter].to_s
    when "available"
      relation.where("capacity IS NULL OR capacity > (#{going_count})")
    when "limited"
      relation.where("capacity IS NOT NULL AND capacity > (#{going_count}) AND capacity - (#{going_count}) BETWEEN 1 AND 5")
    else
      relation
    end
  end

  def filter_by_registration(relation)
    case params[:registration_filter].to_s
    when "unizone"
      relation.where(ticket_url: [ nil, "" ])
    when "external"
      relation.where.not(ticket_url: [ nil, "" ])
    else
      relation
    end
  end

  def sort(relation)
    case normalized_sort
    when "date_desc"
      relation.order(date: :desc)
    when "popular"
      relation.left_joins(:attendances)
              .group("events.id")
              .order(Arel.sql("COUNT(CASE WHEN attendances.status = 'going' THEN 1 ELSE NULL END) DESC"))
    when "newest"
      relation.order(created_at: :desc)
    else
      relation.order(date: :asc)
    end
  end

  def normalized_sort
    sort = params[:sort_by].to_s
    SORT_OPTIONS.include?(sort) ? sort : "date_asc"
  end

  def parsed_date(value)
    return if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end

  def weekend_range
    saturday = Time.zone.today.beginning_of_week + 5.days
    saturday = saturday + 7.days if saturday < Time.zone.today
    saturday.beginning_of_day..(saturday + 1.day).end_of_day
  end
end
