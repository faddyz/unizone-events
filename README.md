# Unizone 🎉

[![Ruby](https://img.shields.io/badge/Ruby-3.2.x-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0.2-red.svg)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14.x-blue.svg)](https://www.postgresql.org/)
[![TailwindCSS](https://img.shields.io/badge/TailwindCSS-3.x-38B2AC.svg)](https://tailwindcss.com/)

Unizone, kullanıcıların etkinlik oluşturabileceği, keşfedebileceği ve detaylarını görüntüleyebileceği modern bir web uygulamasıdır.

## 🚀 Özellikler

- 📝 Kullanıcılar etkinlik oluşturabilir
- 🗓️ Tüm etkinlikler listelenir ve detayları görüntülenebilir
- 🔍 Etkinlik arama ve filtreleme
- 👤 Devise ile kullanıcı girişi
- 🛡️ Pundit ile yetkilendirme sistemi
- ⚙️ Active Storage ile görsel yükleme

## 🧑‍💻 Kullanılan Teknolojiler

- Ruby on Rails 8.0.2
- PostgreSQL
- Tailwind CSS
- Devise (authentication)
- Pundit (authorization)
- Kaminari (pagination)
- Friendly ID (SEO-friendly URLs)


## 🌐 Canlı Demo

https://unizone.onrender.com

## 🗂️ Proje Yapısı

### Önemli Rotalar
```ruby
root "events#index"             # Ana sayfa, etkinlik listesi
/events                         # Etkinlik listesi
/events/new                     # Yeni etkinlik oluşturma
/events/:id                     # Etkinlik detayı
/events/explore                 # Etkinlikleri keşfet
/admin/events                   # Admin etkinlik yönetimi
/admin/events/pending           # Onay bekleyen etkinlikler
```

### Kullanıcı Rolleri
- Normal kullanıcılar: Etkinlik oluşturabilir ve katılabilir
- Admin kullanıcılar: Etkinlikleri onaylayabilir ve yönetebilir
