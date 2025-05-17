# Unizone 🎉

[![Ruby](https://img.shields.io/badge/Ruby-3.2.x-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0.2-red.svg)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14.x-blue.svg)](https://www.postgresql.org/)
[![TailwindCSS](https://img.shields.io/badge/TailwindCSS-3.x-38B2AC.svg)](https://tailwindcss.com/)

Unizone, kullanıcıların etkinlik oluşturabileceği, keşfedebileceği ve detaylarını görüntüleyebileceği modern bir Ruby on Rails web uygulamasıdır.

## 🚀 Özellikler

- 📝 Etkinlik oluşturma
- 🗓️ Etkinlik listesi ve detay sayfası
- 🔍 Arama ve filtreleme
- 👤 Devise ile kullanıcı girişi
- 🛡️ Pundit ile yetkilendirme
- 📦 Active Storage ile görsel yükleme

## 🧑‍💻 Teknolojiler

- Ruby on Rails
- PostgreSQL
- Tailwind CSS
- Devise, Pundit, Kaminari, Friendly ID


## 🌐 Canlı Demo

https://unizone.onrender.com

## 🗂️ Proje Yapısı

### 🗂️ Önemli Rotalar
```ruby
root "events#index"             # Ana sayfa, etkinlik listesi
/events                         # Etkinlik listesi
/events/new                     # Yeni etkinlik oluşturma
/events/:id                     # Etkinlik detayı
/events/explore                 # Etkinlikleri keşfet
/admin/events                   # Admin etkinlik yönetimi
/admin/events/pending           # Onay bekleyen etkinlikler
```

### 👥 Kullanıcı Rolleri
- Normal kullanıcılar: Etkinlik oluşturabilir ve etkinlik detaylarını görüntüleyebilir ve katılım tercihi belirtebilirler.
- Admin kullanıcılar:  Etkinlikleri onaylayabilir, düzenleyebilir, silebilirler.


## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) ile lisanslanmıştır.  
