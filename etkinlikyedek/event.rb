class Event < ApplicationRecord
  belongs_to :user
  
  # Validasyonlar düzgün hizalandı
  validates :title, presence: true
  validates :description, presence: true
  validates :date, presence: true
  validates :location, presence: true
  validates :category, presence: true
  validates :price, numericality: { 
    greater_than_or_equal_to: 0, 
    allow_nil: true 
  }

  # SQL Injection korumalı scope'lar
  scope :by_query, ->(query) {
    query = query.to_s.downcase.strip
    where(
      "LOWER(title) LIKE :query OR LOWER(description) LIKE :query OR LOWER(location) LIKE :query", 
      query: "%#{query}%"
    )
  }

  scope :by_topic, ->(topic) {
    topic = topic.to_s.downcase.strip
    where("LOWER(title) LIKE ?", "%#{topic}%") if topic.present?
  }

  scope :by_date, ->(date) { 
    where("date >= ?", date) if date.present? 
  }

  scope :by_category, ->(category) { 
    where(category: category) if category.present? 
  }

  # Zaman dilimi duyarlı sorgu
  scope :upcoming, -> { 
    where("date >= ?", Time.current).order(date: :asc) 
  }

  # Enum ve metodlarda tutarlılık
  enum :category, {
    general: 'general',
    technology: 'technology',
    music: 'music',
    art: 'art',
    sports: 'sports',
    education: 'education'
  }, default: 'general'

  def category_title
    category.humanize # ActiveSupport'in humanize metodu daha temiz
  rescue
    'Belirsiz'
  end

  def category_color
    {
      general: 'gray',
      technology: 'blue',
      music: 'purple',
      art: 'pink',
      sports: 'green',
      education: 'indigo'
    }.fetch(category.to_sym, 'gray') # Sembol tutarlılığı
  end

  def free?
    price.nil? || price.to_f.zero? # Nil değerler açıkça kontrol ediliyor
  end
end