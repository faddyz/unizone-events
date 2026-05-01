class EventsController < ApplicationController
  before_action :set_event, only: :show

  def index
    @events = EventSearch.new(scope: published_scope, params: search_params).results.limit(8).to_a
    @featured_events = published_scope
                       .left_joins(:attendances)
                       .select("events.*, COALESCE(SUM(CASE WHEN attendances.status = 'going' THEN 1 ELSE 0 END), 0) AS going_score")
                       .group("events.id")
                       .order(Arel.sql("going_score DESC"), date: :asc)
                       .limit(6)
                       .to_a
    @categories = Event.categories.keys.map { |category| [ Event.new(category: category).category_title, category ] }
    prepare_event_card_data(@events + @featured_events)
  end

  def explore
    @events = EventSearch.new(scope: published_scope, params: search_params).results.page(params[:page]).per(12)
    @categories = Event.categories.keys.map { |category| [ Event.new(category: category).category_title, category ] }
    @active_filters = active_explore_filters
    prepare_event_card_data(@events.to_a)
  end

  def show
    authorize @event

    @preview_mode = !@event.published?
    @similar_events = @event.similar_events.to_a
    @organizer_other_events = @event.organizer_other_events.to_a
    @attendance = current_user&.attendances&.find_by(event: @event)
    prepare_event_card_data([ @event ] + @similar_events + @organizer_other_events, preview_limit: 5)
    @attendee_preview = @event_attendee_previews.fetch(@event.id, [])
  end

  private

  def set_event
    @event = policy_scope(Event).with_attached_image.includes(:user).friendly.find(params[:id])
  end

  def published_scope
    Event.published.with_attached_image.includes(:user)
  end

  def search_params
    params.permit(
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
      :sort_by,
      :view,
      :category,
      category: []
    )
  end

  def active_explore_filters
    filters = []

    if params[:query].present?
      filters << { key: "query", value: params[:query].to_s, label: "Arama: #{params[:query]}" }
    end

    Array(params[:category]).flatten.reject(&:blank?).uniq.each do |category|
      next unless Event.categories.key?(category)

      filters << { key: "category", value: category, label: "Kategori: #{Event.new(category: category).category_title}" }
    end

    city = params[:city].to_s
    if Event::CITY_OPTIONS.include?(city)
      filters << { key: "city", value: city, label: "Şehir: #{city}" }
    end

    date_labels = {
      "today" => "Bugün",
      "tomorrow" => "Yarın",
      "tonight" => "Bu akşam",
      "this_week" => "Bu hafta",
      "weekend" => "Hafta sonu",
      "this_month" => "Bu ay",
      "past" => "Geçmiş",
      "upcoming" => "Yaklaşan"
    }
    date_filter = params[:date_filter].to_s
    if date_labels.key?(date_filter)
      filters << { key: "date_filter", value: date_filter, label: "Tarih: #{date_labels[date_filter]}" }
    end

    time_labels = {
      "morning" => "Sabah",
      "afternoon" => "Öğleden sonra",
      "evening" => "Akşam",
      "night" => "Gece"
    }
    time_filter = params[:time_filter].to_s
    if time_labels.key?(time_filter)
      filters << { key: "time_filter", value: time_filter, label: "Saat: #{time_labels[time_filter]}" }
    end

    price_labels = {
      "free" => "Ücretsiz",
      "paid" => "Ücretli"
    }
    price_filter = params[:price_filter].to_s
    if price_labels.key?(price_filter)
      filters << { key: "price_filter", value: price_filter, label: "Ücret: #{price_labels[price_filter]}" }
    end

    availability_labels = {
      "available" => "Yer var",
      "limited" => "Az yer kaldı"
    }
    availability_filter = params[:availability_filter].to_s
    if availability_labels.key?(availability_filter)
      filters << { key: "availability_filter", value: availability_filter, label: "Kontenjan: #{availability_labels[availability_filter]}" }
    end

    registration_labels = {
      "unizone" => "Unizone RSVP",
      "external" => "Dış kayıt"
    }
    registration_filter = params[:registration_filter].to_s
    if registration_labels.key?(registration_filter)
      filters << { key: "registration_filter", value: registration_filter, label: "Kayıt: #{registration_labels[registration_filter]}" }
    end

    sort_labels = {
      "date_desc" => "En uzak",
      "popular" => "Popüler",
      "newest" => "En yeni"
    }
    sort_by = params[:sort_by].to_s
    if sort_labels.key?(sort_by)
      filters << { key: "sort_by", value: sort_by, label: "Sıralama: #{sort_labels[sort_by]}" }
    end

    filters
  end
end
