# frozen_string_literal: true

PASSWORD = "password123"
RESET_PASSWORDS = ENV["DEMO_SEED_RESET_PASSWORDS"].to_s == "1"

ADMIN_USER = {
  email: "admin@example.com",
  name: "Unizone Demo Admin",
  admin: true
}.freeze

ORGANIZER_USERS = [
  { email: "mina@example.com", name: "Kadıköy Stage Collective" },
  { email: "leo@example.com", name: "Ankara Tech Circle" },
  { email: "zeynep@example.com", name: "Moda Design Lab" },
  { email: "deniz@example.com", name: "İzmir Open Air" },
  { email: "arya@example.com", name: "Campus Makers Club" },
  { email: "can@example.com", name: "Galata Workroom" },
  { email: "mel@example.com", name: "Antalya Night Office" },
  { email: "organizer@example.com", name: "Pazar Studio" }
].freeze

MEMBER_USERS = [
  { email: "member@example.com", name: "Jordan Member" },
  { email: "ayse.demo@example.com", name: "Ayşe Demir" },
  { email: "emir.demo@example.com", name: "Emir Kaya" },
  { email: "ece.demo@example.com", name: "Ece Arslan" },
  { email: "mert.demo@example.com", name: "Mert Şahin" },
  { email: "selin.demo@example.com", name: "Selin Yalçın" },
  { email: "arda.demo@example.com", name: "Arda Özkan" },
  { email: "naz.demo@example.com", name: "Naz Aydın" },
  { email: "deniz.member@example.com", name: "Deniz Korkmaz" },
  { email: "ipek.demo@example.com", name: "İpek Ergin" },
  { email: "kaan.demo@example.com", name: "Kaan Polat" },
  { email: "lara.demo@example.com", name: "Lara Ersoy" },
  { email: "burak.demo@example.com", name: "Burak Çelik" },
  { email: "duru.demo@example.com", name: "Duru Kaplan" },
  { email: "baran.demo@example.com", name: "Baran Eren" },
  { email: "melis.demo@example.com", name: "Melis Tuna" },
  { email: "efe.demo@example.com", name: "Efe Yılmaz" },
  { email: "sena.demo@example.com", name: "Sena Aksoy" },
  { email: "ali.demo@example.com", name: "Ali Sarı" },
  { email: "nil.demo@example.com", name: "Nil Acar" },
  { email: "ozge.demo@example.com", name: "Özge Işık" },
  { email: "kerem.demo@example.com", name: "Kerem Uslu" },
  { email: "zara.demo@example.com", name: "Zara Koç" },
  { email: "cem.demo@example.com", name: "Cem Doğan" }
].freeze

DEMO_USERS = [ ADMIN_USER, *ORGANIZER_USERS, *MEMBER_USERS ].freeze

def demo_time(days_from_now, hour:, min: 0)
  days_from_now.days.from_now.change(hour: hour, min: min, sec: 0)
end

EVENTS = [
  {
    host: "mina@example.com",
    title: "Kadıköy Indie Sahne Gecesi",
    legacy_titles: [ "Rooftop Indie Session" ],
    description: "Kadıköy'de yeni sesleri keşfetmek isteyenler için sıcak, kompakt ve sahneye yakın bir gece. Üç bağımsız grup, kısa DJ geçişleri ve set aralarında tanışmaya açık bir atmosfer var.",
    location: "Kadıköy Sahne",
    city: "İstanbul",
    date: demo_time(3, hour: 20, min: 30),
    category: "concert",
    price: 450,
    capacity: 220,
    ticket_url: "https://tickets.unizone.test/kadikoy-indie-sahne",
    status: "published",
    rsvps: { going: 30, interested: 1 }
  },
  {
    host: "leo@example.com",
    title: "AI Ürün Sprinti",
    legacy_titles: [ "AI Builders Jam" ],
    description: "Fikir aşamasındaki yapay zeka ürünlerini bir akşamda somut prototipe çevirmek isteyen ekipler için pratik bir sprint. Kısa yönlendirmeler, çalışma masaları ve kapanışta demo turu yapılacak.",
    location: "Levent Product Loft",
    city: "İstanbul",
    date: demo_time(5, hour: 18, min: 30),
    category: "technology",
    price: 0,
    capacity: 80,
    status: "published",
    rsvps: { going: 25, interested: 5, not_going: 1 }
  },
  {
    host: "zeynep@example.com",
    title: "Moda Tasarım Pazarı",
    legacy_titles: [ "Street Poster Walk" ],
    description: "Bağımsız tasarımcılar, küçük yayınlar, posterler ve seramik işleri Moda'da tek günlük bir pazarda buluşuyor. Sakin gezmek, üreticilerle konuşmak ve yeni işler keşfetmek için ideal.",
    location: "Moda Sahil Atölyeleri",
    city: "İstanbul",
    date: demo_time(6, hour: 12),
    category: "art",
    price: 0,
    status: "published",
    rsvps: { going: 23, interested: 5 }
  },
  {
    host: "deniz@example.com",
    title: "Bomonti Gece Pazarı",
    legacy_titles: [ "Late Night Vinyl Market" ],
    description: "Plak seçkileri, küçük yemek stantları ve geceye yayılan DJ setleriyle Bomonti'de sosyal bir pazar akışı. Kalabalık ama rahat; keşif, sohbet ve müzik aynı hatta ilerliyor.",
    location: "Bomonti Avlu",
    city: "İstanbul",
    date: demo_time(8, hour: 21),
    category: "party",
    price: 320,
    capacity: 180,
    status: "published",
    rsvps: { going: 21, interested: 6, not_going: 1 }
  },
  {
    host: "mina@example.com",
    title: "Boğazda Akustik Seri",
    legacy_titles: [ "Tiny Theater Lab" ],
    description: "Gün batımından sonra başlayan bu akustik seri, vokal ve gitar ağırlıklı kısa performansları Boğaz hattında sakin bir dinleme deneyimine dönüştürüyor. Oturarak dinlenen, detaylı ve yakın bir konser.",
    location: "Üsküdar İskele Terası",
    city: "İstanbul",
    date: demo_time(10, hour: 20),
    category: "music",
    price: 650,
    capacity: 160,
    ticket_url: "https://tickets.unizone.test/bogazda-akustik-seri",
    status: "published",
    rsvps: { going: 20, interested: 5 }
  },
  {
    host: "zeynep@example.com",
    title: "Galata Yeni Medya Rotası",
    legacy_titles: [ "New Media Exhibition Night" ],
    description: "Projeksiyon, ses ve etkileşimli işlerin yer aldığı kısa bir sergi rotası. Her durakta sanatçı notları, küçük konuşmalar ve işi anlamayı kolaylaştıran pratik açıklamalar bulunuyor.",
    location: "Galata Studio Rooms",
    city: "İstanbul",
    date: demo_time(12, hour: 17, min: 30),
    category: "exhibition",
    price: 250,
    capacity: 90,
    status: "published",
    rsvps: { going: 18, interested: 6, not_going: 1 }
  },
  {
    host: "can@example.com",
    title: "Üsküdar Kahve ve Kod Buluşması",
    legacy_titles: [ "Founder Breakfast Circle" ],
    description: "Hafta sonu sabahını kod, ürün ve kahve etrafında geçirmek isteyenler için küçük ölçekli bir buluşma. Yeni başlayanlar da ürününü büyütenler de kısa masalarda deneyim paylaşacak.",
    location: "Üsküdar Atölye Kafe",
    city: "İstanbul",
    date: demo_time(13, hour: 10, min: 30),
    category: "networking",
    price: 0,
    status: "published",
    rsvps: { going: 15, interested: 4 }
  },
  {
    host: "arya@example.com",
    title: "İstanbul Kampüs Açık Mikrofon",
    legacy_titles: [ "Creator Crit Night" ],
    description: "Üniversite kulüplerinin hazırladığı açık mikrofon gecesinde kısa stand-up denemeleri, şiir okumaları ve akustik performanslar aynı sahneyi paylaşacak. Katılım rahat, tempo yüksek.",
    location: "Beşiktaş Kampüs Avlusu",
    city: "İstanbul",
    date: demo_time(15, hour: 19),
    category: "general",
    price: 0,
    capacity: 140,
    status: "published",
    rsvps: { going: 17, interested: 5 }
  },
  {
    host: "leo@example.com",
    title: "Ankara Tech Circle: Founder Night",
    legacy_titles: [ "Rails Product Night" ],
    description: "Ankara'daki erken aşama girişimler için net, gösterişsiz ve faydaya odaklanan bir akşam. Ürün notları, kullanıcı bulma deneyimleri ve kısa tanışma turları programın merkezinde.",
    location: "ODTÜ Teknokent Hub",
    city: "Ankara",
    date: demo_time(16, hour: 18, min: 45),
    category: "technology",
    price: 250,
    capacity: 70,
    status: "published",
    rsvps: { going: 29, interested: 2 }
  },
  {
    host: "organizer@example.com",
    title: "Ankara Kısa Film Seçkisi",
    description: "Yeni mezun yönetmenlerin kısa filmlerinden oluşan seçki, gösterim sonrası sakin bir söyleşiyle tamamlanıyor. Bağımsız sinemaya yakın durmak isteyenler için yalın ve iyi kürate edilmiş bir akşam.",
    location: "Kızılay Cep Sineması",
    city: "Ankara",
    date: demo_time(18, hour: 20),
    category: "theater",
    price: 180,
    capacity: 60,
    status: "published",
    rsvps: { going: 10, interested: 4 }
  },
  {
    host: "deniz@example.com",
    title: "İzmir Açık Hava Plak Pazarı",
    legacy_titles: [ "Campus Food Festival" ],
    description: "Kordon'a yakın açık alanda plak seçkileri, küçük sahaf masaları ve gün boyu kısa DJ setleri olacak. Koleksiyon arayanlar ve müzikle vakit geçirmek isteyenler için rahat bir rota.",
    location: "Alsancak Açık Alan",
    city: "İzmir",
    date: demo_time(20, hour: 14),
    category: "music",
    price: 150,
    status: "published",
    rsvps: { going: 15, interested: 5 }
  },
  {
    host: "deniz@example.com",
    title: "Kordon Gün Batımı Cazı",
    description: "Deniz kenarında üç parçalık caz programı, gün batımı saatine denk gelen sakin bir akışla ilerliyor. Büyük festival kalabalığı değil; iyi ses, yakın sahne ve temiz program hedefleniyor.",
    location: "Kordon İskele Sahnesi",
    city: "İzmir",
    date: demo_time(22, hour: 19, min: 30),
    category: "concert",
    price: 550,
    capacity: 120,
    ticket_url: "https://tickets.unizone.test/kordon-caz",
    status: "published",
    rsvps: { going: 28, interested: 3 }
  },
  {
    host: "zeynep@example.com",
    title: "Bursa İpek Yolu Tasarım Turu",
    description: "Bursa'nın üretim hafızasını çağdaş tasarım işleriyle birleştiren yürüyüşlü bir program. Küçük atölye ziyaretleri, malzeme hikayeleri ve kısa bir kapanış sohbeti var.",
    location: "Hanlar Bölgesi",
    city: "Bursa",
    date: demo_time(24, hour: 11),
    category: "art",
    price: 200,
    capacity: 35,
    status: "published",
    rsvps: { going: 12, interested: 4 }
  },
  {
    host: "mel@example.com",
    title: "Antalya Sahil Elektronik Set",
    description: "Sahil hattında gün batımıyla başlayan, elektronik setlerle geceye uzanan bir buluşma. Program dans etmek isteyenler kadar müziği açık havada dinlemek isteyenlere de alan bırakıyor.",
    location: "Konyaaltı Sahil Sahnesi",
    city: "Antalya",
    date: demo_time(27, hour: 21, min: 30),
    category: "party",
    price: 700,
    capacity: 200,
    status: "published",
    rsvps: { going: 17, interested: 6 }
  },
  {
    host: "mel@example.com",
    title: "Eskişehir Kampüs Oyun Gecesi",
    legacy_titles: [ "Open Court 3v3 Night" ],
    description: "Masa oyunları, mini turnuvalar ve ekip kurmaya açık sosyal oyun masalarıyla öğrenciler için tempolu bir kampüs gecesi. Yeni gelenlerin kolayca dahil olabileceği şekilde planlandı.",
    location: "Anadolu Üniversitesi Öğrenci Merkezi",
    city: "Eskişehir",
    date: demo_time(29, hour: 18, min: 30),
    category: "general",
    price: 0,
    capacity: 90,
    status: "published",
    rsvps: { going: 11, interested: 5 }
  },
  {
    host: "arya@example.com",
    title: "Konya Maker Atölyesi",
    legacy_titles: [ "Creative Coding Picnic" ],
    description: "Basit sensörler, küçük prototipler ve birlikte deneme kültürü üzerine uygulamalı bir atölye. Teknik seviyesi orta; ekipman paylaşımı ve yönlendirmeli çalışma alanı hazır olacak.",
    location: "Konya Tasarım Kuluçkası",
    city: "Konya",
    date: demo_time(32, hour: 13),
    category: "workshop",
    price: 300,
    capacity: 22,
    status: "published",
    rsvps: { going: 13, interested: 3 }
  },
  {
    host: "organizer@example.com",
    title: "Adana Sokak Lezzetleri Rotası",
    description: "Adana'nın farklı mahallelerinden küçük işletmeleri gezen, yemek kadar hikayeye de alan açan rehberli bir rota. Program kalabalık tur hissinden uzak, yerel duraklara odaklı.",
    location: "Taşköprü Buluşma Noktası",
    city: "Adana",
    date: demo_time(35, hour: 16),
    category: "festival",
    price: 350,
    capacity: 45,
    status: "published",
    rsvps: { going: 12, interested: 5 }
  },
  {
    host: "mel@example.com",
    title: "Mersin Deniz Kenarı Yoga",
    legacy_titles: [ "Zero Waste Supper Club" ],
    description: "Sabah erken saatte deniz kenarında, başlangıç seviyesine uygun sakin bir yoga buluşması. Matını getirmen yeterli; program nefes, esneme ve kısa çay molasıyla tamamlanıyor.",
    location: "Mersin Marina Çim Alan",
    city: "Mersin",
    date: demo_time(38, hour: 8, min: 30),
    category: "sports",
    price: 180,
    capacity: 40,
    status: "published",
    rsvps: { going: 9, interested: 4 }
  },
  {
    host: "zeynep@example.com",
    title: "Pera Tipografi Atölyesi",
    description: "Afiş üretimi, harf aralığı ve görsel hiyerarşi üzerine pratik bir atölye. Katılımcılar gün sonunda kendi mini etkinlik afişlerini dijital taslak olarak çıkaracak.",
    location: "Pera Tasarım Odası",
    city: "İstanbul",
    date: demo_time(41, hour: 15),
    category: "workshop",
    price: 420,
    capacity: 18,
    status: "published",
    rsvps: { going: 15, interested: 2 }
  },
  {
    host: "organizer@example.com",
    title: "Kadıköy Community Table",
    description: "Mahallede üretim yapan küçük ekipleri, öğrencileri ve yeni taşınanları aynı masada buluşturan sade bir topluluk yemeği. Herkes kısa bir tanışma cümlesi ve paylaşacak bir fikirle geliyor.",
    location: "Yeldeğirmeni Ortak Mutfak",
    city: "İstanbul",
    date: demo_time(45, hour: 19),
    category: "general",
    price: 0,
    capacity: 50,
    status: "published",
    rsvps: { going: 14, interested: 6 }
  },
  {
    host: "can@example.com",
    title: "Beyoğlu Poster Jam",
    legacy_titles: [ "Neighborhood Photo Sprint" ],
    description: "Etkinlik afişi üretmek isteyen tasarımcılar için hızlı, uygulamalı ve paylaşmaya açık bir çalışma seansı. Taslaklar gün sonunda kısa bir kritik turuyla değerlendirilecek.",
    location: "Beyoğlu Grafik Odası",
    city: "İstanbul",
    date: demo_time(49, hour: 17, min: 30),
    category: "art",
    price: 200,
    capacity: 28,
    status: "submitted"
  },
  {
    host: "zeynep@example.com",
    title: "Ankara Veri Görselleştirme Mini Conf",
    legacy_titles: [ "Design Systems Mini Conf" ],
    description: "Veriyi anlaşılır, okunabilir ve görsel olarak güçlü anlatmak isteyen ekipler için yarım günlük mini konferans. Konuşmalar kısa, örnekler gerçek ürün ekranlarından seçildi.",
    location: "Ankara Dijital Sahne",
    city: "Ankara",
    date: demo_time(53, hour: 10),
    category: "conference",
    price: 450,
    capacity: 110,
    status: "submitted"
  },
  {
    host: "mina@example.com",
    title: "İzmir Sahne Arkası Söyleşisi",
    description: "Bağımsız müzik ekiplerinin turne, prova, mekan ve bütçe tarafını konuşacağı küçük bir söyleşi. Sahne önünden çok sahne arkasını merak edenlere göre.",
    location: "Alsancak Kültür Odası",
    city: "İzmir",
    date: demo_time(58, hour: 18),
    category: "theater",
    price: 0,
    capacity: 70,
    status: "submitted"
  },
  {
    host: "organizer@example.com",
    title: "Pazar Takas Günü Taslağı",
    legacy_titles: [ "Sunday Swap Draft" ],
    description: "Kitap, giysi ve küçük ev eşyaları için planlanan rahat bir takas günü. Mekan ve katılım kuralları netleşince incelemeye gönderilecek.",
    location: "Mekan netleşecek",
    city: "İstanbul",
    date: demo_time(62, hour: 13),
    category: "general",
    price: 0,
    status: "draft"
  },
  {
    host: "mina@example.com",
    title: "Gizli Depo Partisi",
    legacy_titles: [ "Secret Warehouse Party" ],
    description: "Gece hayatı odaklı bu taslakta mekan bilgisi, giriş akışı ve güvenlik detayları henüz yeterince açık değil. Düzenleme sonrası tekrar incelenmesi gerekiyor.",
    location: "Doğrulanmamış mekan",
    city: "İstanbul",
    date: demo_time(66, hour: 23),
    category: "party",
    price: 900,
    status: "rejected",
    review_note: "Mekan adı, giriş koşulları, yaş politikası ve güvenlik planı netleşmeden yayına alınamaz."
  },
  {
    host: "leo@example.com",
    title: "İptal: Donanım Hack Masası",
    legacy_titles: [ "Cancelled: Hardware Hack Table" ],
    description: "Mekan erişimi iptal edildiği için bu donanım odaklı çalışma masası yayına alınmadan kapatıldı.",
    location: "Maker Garage",
    city: "İstanbul",
    date: demo_time(21, hour: 18),
    category: "technology",
    price: 0,
    status: "cancelled"
  }
].freeze

def demo_user(email:, name:, admin: false)
  user = User.find_or_initialize_by(email: email)
  user.name = name
  user.admin = admin

  if user.encrypted_password.blank? || RESET_PASSWORDS
    user.password = PASSWORD
    user.password_confirmation = PASSWORD
  end

  user.save!
  user
end

def demo_event(users_by_email, attrs)
  host = users_by_email.fetch(attrs.fetch(:host))
  titles = [ attrs.fetch(:title), *Array(attrs[:legacy_titles]) ].uniq
  event = host.events.where(title: titles).order(:id).first || host.events.build
  status = attrs.fetch(:status)

  event.assign_attributes(
    title: attrs.fetch(:title),
    description: attrs.fetch(:description),
    location: attrs.fetch(:location),
    city: attrs.fetch(:city),
    date: attrs.fetch(:date),
    category: attrs.fetch(:category),
    price: attrs.fetch(:price),
    capacity: attrs[:capacity],
    ticket_url: attrs[:ticket_url],
    status: status,
    published_at: status == "published" ? (event.published_at || Time.current) : nil,
    review_note: attrs[:review_note]
  )
  event.save!
  event
end

def desired_rsvps_for(event, demo_users, counts, offset)
  eligible_users = demo_users.reject { |user| user.admin? || user == event.user }
  eligible_users = eligible_users.rotate(offset % eligible_users.length)
  desired = {}

  %i[going interested not_going].each do |status|
    eligible_users.shift(counts.fetch(status, 0).to_i).each do |user|
      desired[user] = status.to_s
    end
  end

  desired
end

def reconcile_demo_attendances(event, desired_statuses, demo_users)
  demo_user_ids = demo_users.map(&:id)
  desired_user_ids = desired_statuses.keys.map(&:id)
  stale_scope = Attendance.where(event: event, user_id: demo_user_ids)
  stale_scope = stale_scope.where.not(user_id: desired_user_ids) if desired_user_ids.any?
  stale_scope.destroy_all

  desired_statuses.each do |user, status|
    attendance = Attendance.find_or_initialize_by(user: user, event: event)
    attendance.status = status
    attendance.save!
  end
end

users_by_email = DEMO_USERS.to_h { |attrs| [ attrs.fetch(:email), demo_user(**attrs) ] }
events = EVENTS.map { |attrs| demo_event(users_by_email, attrs) }
demo_users = users_by_email.values

events.each_with_index do |event, index|
  rsvp_counts = EVENTS.fetch(index).fetch(:rsvps, {})
  desired_statuses = event.published? ? desired_rsvps_for(event, demo_users, rsvp_counts, index * 5) : {}
  reconcile_demo_attendances(event, desired_statuses, demo_users)
end

puts "Seeded Unizone demo data."
puts "Users: #{DEMO_USERS.size} demo accounts"
puts "Events: #{events.size} demo events"
puts "Admin: admin@example.com / #{PASSWORD}"
puts "Sample user: member@example.com / #{PASSWORD}"
puts "Sample organizer: mina@example.com / #{PASSWORD}"
puts "Set DEMO_SEED_RESET_PASSWORDS=1 to reset existing demo account passwords."
