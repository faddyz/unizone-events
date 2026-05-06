# Unizone 🎉

[![Ruby](https://img.shields.io/badge/Ruby-3.4.2-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0.2-red.svg)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-ready-blue.svg)](https://www.postgresql.org/)
[![TailwindCSS](https://img.shields.io/badge/TailwindCSS-4.x-38B2AC.svg)](https://tailwindcss.com/)

Unizone, kullanıcıların etkinlikleri keşfedebildiği, kendi etkinliklerini oluşturup incelemeye gönderebildiği ve yayınlanan etkinliklere katılım durumlarını belirtebildiği modern bir Ruby on Rails web uygulamasıdır.

Proje aynı zamanda admin paneli üzerinden Etkinlik.io API kaynaklı etkinlik adaylarını tarama, inceleme, filtreleme ve yayına alma akışını destekler.

## 🚀 Öne Çıkan Özellikler

- 🗓️ Yayındaki etkinlikleri listeleme ve detay sayfasında görüntüleme
- 🔍 Keşfet sayfası, arama, şehir, tarih ve kategori filtreleri
- 👤 Devise ile kullanıcı kaydı, giriş ve hesap yönetimi
- 🧭 Kullanıcı paneli üzerinden katılım planları ve oluşturulan etkinlikleri takip etme
- 📝 Organizer alanında etkinlik oluşturma, düzenleme ve incelemeye gönderme
- ✅ Admin onay akışı: taslak, incelemede, yayında, reddedildi ve iptal edildi durumları
- 🙋 Katılım durumları: gidiyorum, ilgileniyorum, gitmiyorum
- 🖼️ Active Storage ile etkinlik görseli yükleme ve görsel varyantları
- 🔗 FriendlyId ile SEO dostu etkinlik URL'leri
- 📄 SSS, gizlilik politikası ve iletişim gibi statik bilgi sayfaları
- 📱 Stimulus destekli etkileşimler ve mobil uyumlu arayüz

## 🔌 Etkinlik.io API Entegrasyonu

Unizone, Etkinlik.io API üzerinden etkinlik verilerini admin kontrollü bir import havuzuna alabilir.

- 🌐 Harici etkinlikler API üzerinden taranır ve aday havuzuna eklenir
- 🧹 Eksik, süresi geçmiş veya düşük öncelikli kayıtlar ayrıştırılır
- ✅ Admin kullanıcılar adayları inceleyip yayına alabilir, reddedebilir veya pas geçebilir
- 🚀 Onaylanan adaylar otomatik olarak yayınlanmış etkinlik kaydına dönüştürülür


## 🧑‍💻 Teknolojiler

- Ruby 3.4.2
- Ruby on Rails 8.0.2
- PostgreSQL
- Tailwind CSS
- Hotwire, Turbo ve Stimulus
- Devise
- Pundit
- Kaminari
- FriendlyId
- Active Storage
- Solid Queue, Solid Cache ve Solid Cable
- Docker / Docker Compose

## 🌐 Canlı Demo

https://unizone.onrender.com

## 🗂️ Önemli Rotalar

```ruby
root "events#index"                         # Ana sayfa
/explore                                    # Etkinlik keşfetme
/events                                     # Etkinlik listesi
/events/:id                                 # Etkinlik detay sayfası
/dashboard                                  # Kullanıcı paneli
/account/profile                            # Profil yönetimi
/organizer/events                           # Kullanıcının oluşturduğu etkinlikler
/organizer/events/new                       # Yeni etkinlik oluşturma
/admin/events                               # Admin etkinlik yönetimi
/admin/api-adaylari                         # Etkinlik.io import adayları
/admin/kullanicilar                         # Admin kullanıcı yönetimi
/faq                                        # Sıkça sorulan sorular
/gizlilik-politikasi                        # Gizlilik politikası
/iletisim                                   # İletişim
```

## 👥 Kullanıcı Rolleri

- 👤 Normal kullanıcılar etkinlikleri keşfedebilir, etkinlik detaylarını görüntüleyebilir ve katılım tercihlerini belirtebilir.
- 🧑‍🎤 Organizer akışında kullanıcılar kendi etkinliklerini oluşturabilir, düzenleyebilir ve admin incelemesine gönderebilir.
- 🛡️ Admin kullanıcılar etkinlikleri yayınlayabilir, reddedebilir, iptal edebilir, kullanıcıları yönetebilir ve Etkinlik.io import havuzunu kontrol edebilir.

## 📄 Lisans

Bu proje portfolyo, demo ve kod inceleme amacıyla herkese açık olarak görüntülenebilir. Kaynak kodu yalnızca inceleme ve değerlendirme amacıyla erişime açıktır.

Proje sahibinden önceden yazılı izin alınmadan kullanılamaz, kopyalanamaz, değiştirilemez, dağıtılamaz, yeniden yayınlanamaz, deploy edilemez, barındırılamaz veya türev çalışmalara dönüştürülemez.

Detaylar için `LICENSE` dosyasına bakınız.
