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
    relation = filter_by_category(relation)
    relation = filter_by_exact_date(relation)
    relation = filter_by_date_filter(relation)
    relation = filter_by_custom_dates(relation)
    relation = filter_by_price(relation)
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
    when "this_week"
      relation.where(date: Time.zone.today.beginning_of_week..Time.zone.today.end_of_week.end_of_day)
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
end
