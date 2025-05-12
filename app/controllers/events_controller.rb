class EventsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :explore, :show]
    before_action :set_event, only: [:show, :edit, :update, :destroy]
    before_action :authorize_user!, only: [:edit, :update, :destroy]
  
    def index
      @events = Event.approved
      @events = @events.by_query(params[:query]) if params[:query].present?
      @events = @events.by_category(params[:category]) if params[:category].present?
      @events = @events.by_date(params[:date]) if params[:date].present?
      @events = @events.upcoming if params[:upcoming].present?
      
      # Popüler etkinlikleri getir - index sayfası için
      @popular_events = Event.approved
                            .left_joins(:attendances)
                            .where(attendances: {status: 'attending'})
                            .group('events.id')
                            .order(Arel.sql('COUNT(attendances.id) DESC'))
                            .limit(6)
    end
  
    def explore
      @events = Event.approved
      
      # Gelişmiş arama ve filtreleme
      @events = @events.by_query(params[:query]) if params[:query].present?
      
      # Kategori parametresini düzgün işle - iç içe dizileri düzleştir
      if params[:category].present?
        category_params = params[:category].is_a?(Array) ? params[:category].flatten.reject(&:blank?).uniq : [params[:category]].reject(&:blank?)
        @events = @events.by_category(category_params) if category_params.present?
      end
      
      # Tarih filtreleme seçenekleri (bugün, bu hafta, bu ay, özel tarih aralığı)
      if params[:date_filter].present?
        case params[:date_filter]
        when 'today'
          @events = @events.where('DATE(date) = ?', Date.today)
        when 'tomorrow'
          @events = @events.where('DATE(date) = ?', Date.tomorrow)
        when 'this_week'
          @events = @events.where('date BETWEEN ? AND ?', Date.today.beginning_of_week, Date.today.end_of_week)
        when 'this_weekend'
          @events = @events.where('date BETWEEN ? AND ?', Date.today.end_of_week - 2.days, Date.today.end_of_week)
        when 'this_month'
          @events = @events.where('date BETWEEN ? AND ?', Date.today.beginning_of_month, Date.today.end_of_month)
        when 'next_month'
          next_month = Date.today.next_month
          @events = @events.where('date BETWEEN ? AND ?', next_month.beginning_of_month, next_month.end_of_month)
        when 'past'
          # Geçmiş etkinlikler
          @events = @events.where('date < ?', Date.today)
        when 'upcoming'  
          # Gelecek etkinlikler
          @events = @events.where('date >= ?', Date.today)
        end
      end
      
      # Özel tarih aralığı
      if params[:start_date].present? && params[:end_date].present?
        start_date = Date.parse(params[:start_date]) rescue nil
        end_date = Date.parse(params[:end_date]) rescue nil
        @events = @events.where('date BETWEEN ? AND ?', start_date, end_date) if start_date && end_date
      elsif params[:start_date].present?
        start_date = Date.parse(params[:start_date]) rescue nil
        @events = @events.where('date >= ?', start_date) if start_date
      end
      
      # Fiyat filtreleme
      if params[:price_filter].present?
        case params[:price_filter]
        when 'free'
          @events = @events.where('price = 0 OR price IS NULL')
        when 'paid'
          @events = @events.where('price > 0')
        end
      end
      
      # Sıralama seçenekleri
      if params[:sort_by].present?
        case params[:sort_by]
        when 'date_asc'
          @events = @events.order(date: :asc)
        when 'date_desc'
          @events = @events.order(date: :desc)
        when 'popular'
          # Popülerlik için katılımcı sayısına göre sıralama - SQL güvenli şekilde düzeltildi
          @events = @events.left_joins(:attendances)
                           .group('events.id')
                           .order(Arel.sql('COUNT(CASE WHEN attendances.status = \'attending\' THEN 1 ELSE NULL END) DESC'))
        when 'newest'
          @events = @events.order(created_at: :desc)
        else
          @events = @events.order(date: :asc) # Varsayılan olarak yaklaşan tarihe göre sırala
        end
      else
        @events = @events.order(date: :asc) # Varsayılan olarak yaklaşan tarihe göre sırala
      end
      
      # Sayfalandırma - controller'da gerekli gem eklenmiş olmalı (örn: kaminari veya will_paginate)
      @events = @events.page(params[:page]).per(12) if defined?(Kaminari)
      
      # Kategoriler ve diğer filtreleme seçenekleri için veri hazırlama
      @categories = Event.categories.keys.map { |c| [Event.new(category: c).category_title, c] }
    end
  
    def show
      unless @event.approved? || (current_user && (current_user.admin? || current_user == @event.user))
        redirect_to events_path, alert: 'Bu etkinliği görüntüleme yetkiniz yok.'
        return
      end
      
      # Similar events ve organizer_other_events verilerini hazırla
      @similar_events = @event.similar_events
      @organizer_other_events = @event.organizer_other_events
      
      # Kullanıcının katılım durumunu kontrol et
      if current_user
        @attendance = current_user.attendances.find_by(event: @event)
      end
    end
  
    def new
      @event = Event.new
    end
  
    def create
      @event = current_user.events.build(event_params)
      @event.approved = false # Yeni etkinlikler varsayılan olarak onaylanmamış olacak
      if @event.save
        redirect_to @event, notice: 'Etkinlik başarıyla oluşturuldu. Admin onayından sonra yayınlanacaktır.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    def edit
    end
  
    def update
      if @event.update(event_params)
        redirect_to @event, notice: 'Etkinlik başarıyla güncellendi.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    def destroy
      begin
        @event.destroy
        redirect_to events_path, notice: 'Etkinlik başarıyla silindi.'
      rescue ActiveRecord::RecordNotFound
        redirect_to events_path, alert: 'Etkinlik bulunamadı.'
      end
    end
  
    private
  
    def set_event
      @event = Event.friendly.find(params[:id])
    end
  
    def event_params
      params.require(:event).permit(:title, :description, :date, :location, :category, :price, :image)
    end
    
    def authorize_user!
      unless current_user == @event.user || current_user.admin?
        redirect_to events_path, alert: "Bu işlemi gerçekleştirmeye yetkiniz yok."
      end
    end
  end