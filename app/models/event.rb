class Event < ApplicationRecord
  require 'friendly_id'
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  belongs_to :user
  
  # Active Storage ilişkisi
  has_one_attached :image
  
  # Attendance ilişkisi
  has_many :attendances, dependent: :destroy
  has_many :attendees, -> { where(attendances: { status: 'attending' }) },
           through: :attendances,
           source: :user
  
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
  # Resim boyut sınırlaması
  validate :acceptable_image

  # Katılımcı sayıları
  def attendees_count
    attendances.where(status: 'attending').count
  end
  
  def maybe_attendees_count
    attendances.where(status: 'maybe').count
  end
  
  def declined_attendees_count
    attendances.where(status: 'declined').count
  end
  
  # Tüm katılım sayısı (belirsizler dahil)
  def total_responses_count
    attendances.count
  end
  
  # Bu etkinliğe katılacak olan kullanıcılar
  def attending_users
    User.joins(:attendances).where(attendances: { event_id: id, status: 'attending' })
  end
  
  # Katılım durumu belirsiz olan kullanıcılar
  def maybe_users
    User.joins(:attendances).where(attendances: { event_id: id, status: 'maybe' })
  end
  
  # Katılmayacak olan kullanıcılar
  def declined_users
    User.joins(:attendances).where(attendances: { event_id: id, status: 'declined' })
  end

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

  scope :by_category, ->(categories) { 
    return if categories.blank?
    
    # Tek bir kategori ya da bir dizi kategori kabul et
    if categories.is_a?(Array)
      where(category: categories)
    else
      where(category: categories) 
    end
  }

  # Zaman dilimi duyarlı sorgu
  scope :upcoming, -> { 
    where("date >= ?", Time.current).order(date: :asc) 
  }

  # Onaylanmış etkinlikler
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }

  # Benzer etkinlikleri getir (aynı kategoride, farklı ID'ye sahip, onaylanmış)
  def similar_events(limit = 6)
    Event.approved
        .where(category: self.category)
        .where.not(id: self.id)
        .where("date >= ?", Time.current)
        .order(date: :asc)
        .limit(limit)
  end
  
  # Aynı organizatörün diğer etkinliklerini getir
  def organizer_other_events(limit = 4)
    user.events
        .approved
        .where.not(id: self.id)
        .order(date: :asc)
        .limit(limit)
  end

  # Genişletilmiş kategori listesi
  enum :category, {
    general: 'general',          # Genel
    technology: 'technology',    # Teknoloji
    music: 'music',              # Müzik
    art: 'art',                  # Sanat
    sports: 'sports',            # Spor
    education: 'education',      # Eğitim
    concert: 'concert',          # Konser
    festival: 'festival',        # Festival
    workshop: 'workshop',        # Workshop
    party: 'party',              # Parti
    theater: 'theater',          # Tiyatro
    exhibition: 'exhibition',    # Sergi
    conference: 'conference',    # Konferans
    networking: 'networking'     # Networking
  }, default: 'general'

  # Türkçe kategori isimleri
  def category_title
    {
      general: 'Genel',
      technology: 'Teknoloji',
      music: 'Müzik',
      art: 'Sanat',
      sports: 'Spor',
      education: 'Eğitim',
      concert: 'Konser',
      festival: 'Festival',
      workshop: 'Workshop',
      party: 'Parti',
      theater: 'Tiyatro',
      exhibition: 'Sergi', 
      conference: 'Konferans',
      networking: 'Networking'
    }.fetch(category.to_sym, category.humanize)
  rescue
    'Belirsiz'
  end

  # Genişletilmiş renk listesi
  def category_color
    {
      general: 'slate',
      technology: 'sky',
      music: 'violet',
      art: 'fuchsia',
      sports: 'green',
      education: 'indigo',
      concert: 'purple',
      festival: 'pink',
      workshop: 'blue',
      party: 'orange',
      theater: 'cyan',
      exhibition: 'amber',
      conference: 'rose',
      networking: 'emerald'
    }.fetch(category.to_sym, 'gray')
  end

  def free?
    price.nil? || price.to_f.zero? # Nil değerler açıkça kontrol ediliyor
  end

  def approved?
    approved
  end

  # Resim validasyonu
  def acceptable_image
    return unless image.attached?
    
    # Kabul edilebilir dosya boyutu (5MB)
    unless image.blob.byte_size <= 5.megabytes
      errors.add(:image, 'boyutu çok büyük (maksimum 5MB)')
    end

    # Kabul edilebilir formatlar
    acceptable_types = ['image/jpeg', 'image/jpg', 'image/png']
    unless acceptable_types.include?(image.blob.content_type)
      errors.add(:image, 'formatı geçersiz. JPEG, JPG veya PNG olmalı')
    end
  end
  
  # Görsel yoksa placeholder döndür
  def display_image
    if image.attached?
      image
    else
      # Placeholder image URL
      "https://placehold.co/600x350/0f172a/67e8f9?text=#{title.truncate(20)}"
    end
  end

  # Slug oluşturma yöntemini özelleştirelim (Türkçe karakterler için)
  def normalize_friendly_id(string)
    string.to_s.parameterize(preserve_case: false, separator: '-')
  end
  
  # Başlık değiştiğinde slug'ı yeniden oluşturalım
  def should_generate_new_friendly_id?
    title_changed? || super
  end
end