# UNIZONE — Design & UX Specification v2.0
> **Hedef kitle:** Antigravity ekibi için tasarım & geliştirme brief'i  
> **Versiyon:** 2.0 — Sıfırdan tasarım  
> **Dil:** Türkçe (içerik) / İngilizce (teknik terimler)  
> **Tarih:** Nisan 2026

---

## 1. Ürün Vizyonu

Unizone, gençlerin etkinlik düzenleyip katılabileceği, topluluk hissi yaşatan bir platform. Eski versiyon temel işlevleri kapsıyor fakat görsel kimlik jenerik, UX akışı tamamlanmamış, bazı kritik sayfalar eksik.

**Yeni vizyon:**  
*"Bir müzik festivalinin afişi kadar enerji yüklü, bir sanat dergisinin editoryal kalitesinde, bir nachtclub uygulaması kadar karanlık ve çekici."*

Platform bir üniversite uygulaması değil. Şehir yaşamının tam ortasında, gece ve gündüz etkinliklerin, konser öncesi heyecanın, "burada bir şeyler oluyor" hissinin platformu.

---

## 2. Marka Kimliği

### 2.1 Marka Sesi (Brand Voice)

| Özellik | Unizone |
|---|---|
| Yaş | 18–28 |
| Ton | Direkt, cool, samimi — marketing dilinden uzak |
| Enerji | Yüksek ama bunaltıcı değil |
| Referans | Dice.fm + RA (Resident Advisor) + Notion'ın sadeliği |

Unizone asla "etkinlik platformu" gibi konuşmaz. Sloganlar:
- *"İnsanları bir araya getiren, anları anlamlı kılan yer."* ✓ (mevcut, iyi — koru)
- Sub-tagline önerisi: *"Şehrinde ne oluyor? Bul, katıl, unutma."*

### 2.2 Logo

Mevcut SVG logosu :
 <svg class="w-16 h-16 md:w-24 md:h-24 mb-3 md:mb-5 text-cyan-300 animate-pulse-slow animate-hologram" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M13 10V3L4 14h7v7l9-11h-7z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 14v7l-9-11h7v-7l9 11h-7z" class="text-purple-400"/>
          </svg>
          
   mantık olarak doğru — geometrik, modüler, "U+Z" kombinasyonunu yansıtıyor. Fakat köşeleri yumuşatılmış, renk paleti çok parlak ve plastik görünüyor.

**Logo Revizyonu Prensipleri:**
- Aynı geometrik modüler yapı korunacak
- Stroke-tabanlı, dolgu azaltılacak veya tek renk stroke + vurgu aksanı
- Köşe yarıçapları sıfırlanacak veya çok minimale indirilecek (keskin, modern)
- Renk: sadece 1 ana renk (electric amber `#F5A623` veya icy white `#E8E8E0`) + gece arkaplanında parlayan mono versiyon
- Light modda: koyu/siyah logo; dark modda: krem veya amber
- Animasyonlu versiyon: loading ekranında tile'lar yerleşiyor (piece-by-piece assembly)

---

## 3. Görsel Dil (Visual Language)

### 3.1 Renk Paleti

**Ana Palet — "Midnight City"**

```
--color-bg-primary:    #0A0A0B   /* Tam siyah değil, çok hafif sıcak */
--color-bg-secondary:  #111113   /* Kart ve panel yüzeyleri */
--color-bg-elevated:   #1C1C1F   /* Hover, overlay yüzeyler */
--color-surface:       #242428   /* Input, chip yüzeyler */

--color-accent-amber:  #F5A623   /* ANA VURGU — elektrik sarısı/amber */
--color-accent-coral:  #FF5C38   /* İkincil — konser, festival etiketleri */
--color-accent-violet: #8B5CF6   /* Üçüncül — sanat, kültür */

--color-text-primary:  #EEEEE8   /* Krem beyaz — saf beyaz değil */
--color-text-secondary:#8A8A8F   /* Soluk gri — tarih, meta bilgi */
--color-text-muted:    #4A4A50   /* Placeholder, disabled */

--color-border:        #242428   /* Subtle border */
--color-border-light:  #333338   /* Hover border */
```

**Palet Mantığı:**  
Amber (`#F5A623`) — gece konserinde sahne ışığı, şehir sokak lambası. Coral (`#FF5C38`) — aciliyet, katıl butonu, "son biletler". Violet — kültürel etkinlikler için kimlik rengi.

**Gradient Kullanımı:**  
- Hero section: `radial-gradient` merkezden yayılan amber/coral glow, karanlık zemin üzerinde
- Kart hover: subtle `linear-gradient` `#1C1C1F` → `#242428`
- Kategori chip'leri: renk-blur efekti, opak değil

### 3.2 Tipografi

```
Display font:  "Neue Haas Grotesk Display" (veya alternatif: "DM Sans ExtraBold")
               fallback: "Cabinet Grotesk", sans-serif

Body font:     "Geist" (Vercel'in fontu — şık, okunaksal, modern)  
               fallback: "Plus Jakarta Sans", sans-serif

Mono font:     "Geist Mono" — tarih, saat, kod bloğu alanları
```

**Tipografi Hiyerarşisi:**

| Rol | Font | Weight | Size | Line Height |
|---|---|---|---|---|
| Hero headline | Display | 900 | clamp(52px, 8vw, 96px) | 0.92 |
| Section title | Display | 700 | 32–48px | 1.05 |
| Card title | Body | 600 | 16–20px | 1.3 |
| Body text | Body | 400 | 15px | 1.65 |
| Meta / tarih | Mono | 400 | 12–13px | 1.4 |
| Button | Body | 600 | 14px | 1 |

**Tipografi Notu:**  
Hero headline'da `letter-spacing: -0.03em` — sıkıştırılmış, güçlü görünüm. Meta bilgiler (tarih, saat, konum) monospace font ile — "bilet" estetiği.

### 3.3 Spacing & Grid

```
Base unit: 8px
Grid: 12-column, max-width 1280px, gutter 24px (desktop), 16px (mobile)

Container paddings:
  Mobile:  16px
  Tablet:  32px
  Desktop: 48px

Section vertical padding: 80px (desktop) / 48px (mobile)
Card padding: 20px (inner content)
```

### 3.4 Border Radius

```
--radius-sm:   6px   (chip, badge, input)
--radius-md:   12px  (kart)
--radius-lg:   20px  (büyük kart, modal)
--radius-xl:   32px  (hero pill, featured card)
--radius-full: 9999px (avatar, tag)
```

### 3.5 Gölge & Derinlik

```css
--shadow-card: 0 1px 3px rgba(0,0,0,0.4), 0 8px 24px rgba(0,0,0,0.3);
--shadow-hover: 0 4px 12px rgba(0,0,0,0.5), 0 20px 48px rgba(0,0,0,0.4);
--shadow-accent: 0 0 32px rgba(245,166,35,0.2); /* amber glow on hover */
```

### 3.6 Motion & Animasyon

**Genel Prensipler:**
- Easing: `cubic-bezier(0.16, 1, 0.3, 1)` — "snappy ease out"
- Hiçbir şey birden "pof" diye çıkmaz; her şey slide veya fade ile gelir
- Sayfa yüklenmesinde stagger animasyonu (kart kartı takip eder, 60ms delay)
- Hover'da scale değil, shadow ve border-color değişimi — daha sofistike

**Özel Animasyonlar:**
1. **Logo Assembly**: Sayfa ilk açıldığında logo tile'ları 0.8s içinde birleşiyor
2. **Hero Text Reveal**: Kelimeler clip-path ile yukarıdan açılıyor (Barba.js / GSAP tarzı)
3. **Card Hover Glow**: Kart hover'da amber shadow yayılıyor
4. **Category Pill Slide**: Kategori filtreleri horizontal scroll'da momentum ile kayıyor
5. **Skeleton Loading**: Kart içerikleri loading sırasında shimmer skeleton gösteriyor

---

## 4. Sayfa Yapısı & UX Akışı

### 4.1 Navigation

**Desktop:**
```
[LOGO] ................. [Etkinlikler] [Neler Oluyor?] [Topluluk]    [Giriş Yap] [Etkinlik Oluştur ↗]
```

- Sticky, backdrop-blur ile glassmorphism effect (subtle — `rgba(10,10,11,0.85)`)
- "Etkinlik Oluştur" butonu amber accent — CTA olarak öne çıkıyor
- Scroll sonrası nav biraz küçülüyor (padding azalıyor), logo kompakt versiyona geçiyor

**Mobile:**
- Hamburger menu değil — bottom navigation bar
- 4 icon: Ana Sayfa, Keşfet, Etkinlik Oluştur (+), Profil
- Bottom bar transparent değil — solid `#111113` + subtle top border

### 4.2 Ana Sayfa (Homepage)

#### Hero Section
```
┌─────────────────────────────────────────────────────┐
│  [ambient glow background — radial amber/coral]      │
│                                                      │
│  ┌──────────────────────────────┐                   │
│  │ UNIZONE                      │  ← Logo + wordmark│
│  └──────────────────────────────┘                   │
│                                                      │
│  İnsanları bir araya getiren,        ← H1 büyük     │
│  anları anlamlı kılan yer.                           │
│                                                      │
│  Şehrinde 248 etkinlik seni bekliyor. ← dinamik sayı│
│                                                      │
│  [Keşfetmeye Başla →]  [Etkinlik Oluştur]           │
│                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│  Bu Hafta: 🎵 Müzik  🎨 Sanat  💻 Teknoloji  +11  │
└─────────────────────────────────────────────────────┘
```

**Hero Arkaplan:**
- SVG/CSS tabanlı animated noise texture
- 2-3 büyük daire `radial-gradient` — amber, coral, violet — çok yavaş yüzer (CSS animation, 20s loop)
- `mix-blend-mode: screen` efekti ile üst katmana eklemlenen grain
- Fotoğraf yok — tamamen grafik

**Hero Alt Bant:**
- Bu haftanın kategori breakdown'u — küçük pill'ler, hızlı filtre için tıklanabilir
- Animasyonlu sayaç: etkinlik sayısı yukarı sayıyor (0'dan 248'e, 1.5s)

#### "Bu Hafta Öne Çıkanlar" Section
- 3 büyük featured kart — horizontal scroll (mobile) veya 3-col grid (desktop)
- Featured kart tasarımı: büyük görsel (event poster veya oluşturulan gradient), üste overlay, altta tarih + kategori + katılımcı sayısı
- "Organizatör" badge'i gökyüzü mavisi verified icon ile

#### Kategori Keşif Section
```
Tümü  ·  🎵 Müzik  ·  💻 Teknoloji  ·  🎨 Sanat  ·  ⚽ Spor  ·  🎓 Eğitim  ·  🎪 Festival  →
```
- Horizontal scrollable pill row
- Her kategorinin kendi accent rengi var (Müzik: coral, Teknoloji: violet, vb.)
- Seçili kategori: solid fill, diğerleri: outline

#### Etkinlik Grid
- Masonry değil, düzenli grid: 3-col desktop, 2-col tablet, 1-col mobile
- Kart tasarımı detayı: bkz. Section 5.1
- Infinite scroll (pagination değil) — "yükleniyor" skeleton ile

#### "Nasıl Çalışır?" Section (yeni — şu an yok)
```
3 adım, ikonlu, horizontal layout:

①  Keşfet          ②  Katıl           ③  Hatıra Biriktir
İlgi alanına göre   Tek tıkla katılım   Profilde anılarını
filtrele, bul       durumu belirt       arşivle
```
- Minimalist, ikonu büyük, kısa metin
- Arkaplan biraz farklı (surface-2) section'ı ayırt etmek için

#### Newsletter / Bildirim Section
- Minimal — sadece email input + "Abone Ol"
- Büyük başlık: *"Kaçırmak istemediğin anlar var."*
- Arkaplan: amber gradient, dark section

---

### 4.3 Etkinlikleri Keşfet (/events/explore)

**Mevcut Sorunlar:**
- Filter panel çok kalabalık ve dikey — kullanıcı kayboluyor
- Mobilde filter panel tamamen çökmüş

**Yeni Layout:**

```
┌─────────────────────────────────────────────────────┐
│  Etkinlikleri Keşfet                                │
│  [🔍 Etkinlik ara...                    ] [Filtrele]│
│                                                      │
│  [Tümü] [Bu Hafta] [Ücretsiz] [Müzik] [Teknoloji]  │ ← Quick filters
│                                                      │
│  248 etkinlik bulundu  ↕ Sırala: Yaklaşan ▾        │
│                                                      │
│  [Kart] [Kart] [Kart]                               │
│  [Kart] [Kart] [Kart]                               │
└─────────────────────────────────────────────────────┘
```

**Filter Drawer (mobile) / Filter Sidebar (desktop):**
- Desktop: sol sidebar, sticky, collapsible sections
- Mobile: bottom sheet drawer — "Filtrele" butonuna basınca yukarı kayıyor
- Filter kategorileri accordion ile — açık/kapalı

**Arama:**
- Real-time search (debounced, 300ms)
- Arama sırasında skeleton göster
- Sonuç yoksa: büyük illüstrasyon + "Farklı bir şey ara" önerisi

---

### 4.4 Etkinlik Detay Sayfası (/events/:id)

**Mevcut:** Temel bilgiler var ama düzen zayıf, katılım durumu seçenekleri küçük ve belirsiz.

**Yeni Layout:**

```
┌─────────────────────────────┬────────────────────────┐
│  [Event Poster / Gradient]  │  Başlık                 │
│  [Full bleed, aspect 16:9]  │  📅 Tarih & Saat (mono) │
│                             │  📍 Konum               │
│                             │  👤 Organizatör         │
│                             │  ─────────────────────  │
│                             │  [✅ Katılacağım]        │
│                             │  [❓ Belki]              │
│                             │  [❌ Katılmıyorum]       │
│                             │  ─────────────────────  │
│                             │  👥 43 katılımcı        │
│                             │  [Avatar] [Avatar] +38  │
├─────────────────────────────┴────────────────────────┤
│  Açıklama                                            │
│                                                      │
│  Etiketler: [Workshop] [Ücretsiz] [Online]          │
└──────────────────────────────────────────────────────┘
```

**Detay Sayfası Özellikleri:**
- Katılım durumu seçimi: büyük, net — aktif seçim amber fill
- Katılımcı avatar row: küçük daire avatarlar, üstüste gelen stack
- Etkinlik poster yoksa: kategoriye göre otomatik gradient (Müzik → coral gradient, Sanat → violet gradient)
- "Paylaş" butonu: native share API + link copy
- Organizatör kartı: mini profil preview, "Diğer Etkinlikleri" linki
- Benzer Etkinlikler section (aşağıda)

---

### 4.5 Etkinlik Oluştur (/events/new)

**Mevcut:** Temel form var, UX akışı belli değil.

**Yeni: Adım Adım Wizard**

```
Adım 1/4: Temel Bilgiler
─────────────────────────
Etkinlik Adı
Açıklama (markdown desteği)
Kategori (grid'den seç, icon ile)

Adım 2/4: Zaman & Yer
─────────────────────────
Başlangıç Tarihi & Saati
Bitiş Tarihi & Saati
Konum (mekan adı + adres)
Online mı?

Adım 3/4: Görsel & Etiketler
─────────────────────────
Poster yükle (drag & drop)
Veya: otomatik gradient seç (preview canlı)
Etiketler (chip input)
Katılımcı limiti?
Ücretli mi?

Adım 4/4: Önizleme & Yayınla
─────────────────────────
Etkinlik kartı preview (gerçek kart görünümü)
Detay sayfa preview
[Kaydet Taslak]  [Yayınla →]
```

**Wizard UX:**
- Progress bar üstte — adım adım ilerleme
- Geri git butonu her adımda
- Form state kaybolmuyor (localStorage fallback)
- Yayınla sonrası: confetti animasyonu + "Etkinliğin yayında!" confirmation

---

### 4.6 Kullanıcı Profili (/users/:id veya /profile)

**Mevcut:** Belirsiz.

**Yeni Profil Sayfası:**

```
┌────────────────────────────────────────┐
│  [Cover gradient — dinamik]            │
│  [Avatar]  İsim Soyisim               │
│            @kullaniciadi              │
│            📍 İstanbul · Üye: Mar 2025│
├────────────────────────────────────────┤
│  [Katıldığım] [Düzenlediğim] [Geçmiş] │ ← Tab navigation
├────────────────────────────────────────┤
│  Etkinlik kartları grid               │
└────────────────────────────────────────┘
```

**Profil Özellikleri:**
- Cover: kullanıcının en çok gittiği kategorinin gradient'i (gamification hissi)
- İstatistikler: "14 etkinliğe katıldı · 3 etkinlik düzenledi"
- Profil düzenleme: inline, modal değil

---

### 4.7 Giriş / Kayıt Sayfaları

**Mevcut:** Default Devise görünümü, tamamen stil yok.

**Yeni:**
- Full-page split layout
  - Sol: Platform identity — büyük slogan, animated background, featured bir etkinlik kartı
  - Sağ: Form (email + şifre, social login butonları)
- Social login: Google, GitHub (varsa)
- Form validation: inline, hata mesajları kart altında değil field yanında
- "Şifremi Unuttum" — aynı sayfada toggle, yeni sayfaya gitme

---

### 4.8 SSS Sayfası (/faq)

**Mevcut:** Temel accordion, ama stil yok.

**Yeni:**
- Arama çubuğu üstte — SSS içinde filtrele
- Kategori grupları: "Hesap", "Etkinlikler", "Ödeme", "Organizatörler"
- Accordion: smooth open/close animasyonu, aktif item amber left-border
- Altta: "Cevap bulamadın mı?" — büyük CTA ile iletişim formu açma

---

### 4.9 Eksik & Önerilen Yeni Sayfalar

| Sayfa | Açıklama | Öncelik |
|---|---|---|
| `/about` | Platform hikayesi, ekip (varsa), misyon | Orta |
| `/profile/settings` | Hesap ayarları, bildirim tercihleri, şifre | Yüksek |
| `/profile/notifications` | Etkinlik bildirimleri, katılımcı güncellemeleri | Yüksek |
| `/events/:id/attendees` | Katılımcı listesi (organizatör görünümü) | Yüksek |
| `/dashboard` | Organizatör dashboard — etkinlik yönetimi | Yüksek |
| `/404` | Custom 404 sayfası — "Bu etkinlik uçup gitti" | Orta |
| `/onboarding` | İlk kayıt sonrası ilgi alanı seçimi | Düşük |

---

## 5. Component Library

### 5.1 Event Card

```
┌─────────────────────────────┐
│  [Poster / Gradient] 16:9   │  ← aspect-ratio fixed
│  [Kategori pill] [Ücretsiz] │  ← absolute üstte
├─────────────────────────────┤
│  Etkinlik Adı               │  ← 600 weight, 2 satır max
│  📅 15 Haz · 20:00          │  ← monospace, secondary color
│  📍 Kadıköy, İstanbul       │  
├─────────────────────────────┤
│  [Avatar][Avatar] +12       ↗ │  ← katılımcı stack + share
└─────────────────────────────┘
```

**Card Hover State:**
- Border rengi `--color-accent-amber`'a geçiyor
- Subtle shadow yayılıyor
- Poster hafifçe scale(1.03) — clip ile taşmıyor

**Card Varyantları:**
- `default` — standart grid kartı
- `featured` — büyük, yatay layout, daha fazla bilgi
- `compact` — horizontal, liste görünümü
- `skeleton` — loading state

### 5.2 Category Chip

```
[🎵 Müzik]  [💻 Teknoloji]  [🎨 Sanat]
```

- Default: `background: transparent; border: 1px solid --color-border`
- Aktif: kategori renginde solid fill, text: dark
- Hover: border rengi kategoriye göre

### 5.3 Button Sistemi

```
Primary:   amber fill, dark text, hover: brightness +10%
Secondary: transparent, amber border, amber text
Ghost:     transparent, no border, text: primary
Danger:    coral fill — silme, iptal işlemleri
```

- Tüm butonlar: `height: 40px` (small), `48px` (default), `56px` (large)
- Padding: `0 20px`
- Loading state: spinner + text "Yükleniyor..."
- Disabled: `opacity: 0.4`, cursor: not-allowed

### 5.4 Input Sistemi

- Background: `--color-surface`
- Border: `--color-border`; focus: `--color-accent-amber`
- Placeholder: `--color-text-muted`
- Error state: coral border + hata mesajı altında
- Height: 48px — mobilde kolay tıklanabilir

### 5.5 Badge / Tag

```
[Workshop]  [Ücretsiz]  [✓ Onaylandı]  [Son 5 Bilet!]
```

- Small, pill-shaped
- Ücretsiz: yeşil; Ücretli: amber; Son biletler: coral + pulse animation

---

## 6. İkon & İllüstrasyon Dili

### İkonlar
- Lucide Icons (MIT lisanslı, React uyumlu)
- Boyut: 16px (inline), 20px (nav/card), 24px (section)
- Stroke width: 1.5px — ince, modern

### İllüstrasyonlar
- Boş durumlar (empty state) için: minimal line art, monochrome
- Onboarding için: bold, renkli geometric shapes
- Fotoğraf kullanımı yok — tamamen grafik/illüstrasyon

---

## 7. Responsive & Erişilebilirlik

### Breakpoints
```
xs:  < 480px   (küçük mobil)
sm:  480-768px  (büyük mobil / küçük tablet)
md:  768-1024px (tablet)
lg:  1024-1280px (küçük desktop)
xl:  > 1280px   (büyük desktop)
```

### Erişilebilirlik Checklist
- [ ] WCAG 2.1 AA kontrast oranları (amber on dark: ✓)
- [ ] Tüm interaktif elementler klavye navigasyonuna uygun
- [ ] Focus states görünür (amber outline)
- [ ] ARIA label'ları — icon-only butonlar için
- [ ] `prefers-reduced-motion`: animasyonları devre dışı bırak
- [ ] Semantic HTML: `<nav>`, `<main>`, `<article>`, `<section>`
- [ ] Form label'ları — her input için visible label

---

## 8. Teknik Notlar & Entegrasyon

### Frontend Stack Önerileri (yeni mimari için)
- **Framework:** React + Next.js (App Router) — SSR/SSG avantajı
- **Styling:** Tailwind CSS + CSS Variables (custom tokens üstüne)
- **Animation:** Framer Motion (sayfa geçişleri + stagger)
- **Icons:** Lucide React
- **Fonts:** Google Fonts CDN veya `next/font` — Geist + Display font

### API Entegrasyonu Notları
- Etkinlik kartları skeleton-first render — API gelinceye kadar loading göster
- Optimistic UI — katılım durumu hemen güncelleniyor, sonra server'a yazıyor
- Image upload: client-side preview + lazy upload
- Search: debounced, URL'e sync (`?q=`) — share edilebilir link

### Dark Mode
- Platform default'u dark mode
- `prefers-color-scheme` detect et ama platform kimliği gereği dark'ta kal
- Light mode: `--color-bg-primary: #F5F5F0` ile CSS variable swap yeterli (opsiyonel, sonraya bırak)

---

## 9. Sayfa Akış Diyagramı (User Journey)

```
Landing Page
├── Keşfet → Explore Page
│   ├── Etkinlik Kartı → Event Detail
│   │   ├── Giriş yapmamış → Auth Modal → Devam
│   │   └── Giriş yapmış → Katılım Durumu Seç
│   └── Filter/Arama
├── Etkinlik Oluştur → Auth Check
│   └── Wizard (4 adım) → Preview → Yayınla
└── Giriş Yap / Kayıt Ol
    └── Profil Sayfası
        ├── Düzenlediğim Etkinlikler
        ├── Katıldığım Etkinlikler
        └── Ayarlar
```

---

## 10. Tasarımcıya / Geliştiriciye Notlar

**Ne YAPILMAYACAK:**
- ❌ Purple gradient on white — bu "AI slop" imzası
- ❌ Generic stock fotoğraflar
- ❌ Rounded-everything — keskinlik güç göstergesi
- ❌ Çok fazla renk kullanımı — 3 accent renk yeterli
- ❌ Animasyon yağmuru — az ama güçlü animasyon
- ❌ Modal her şey — inline expansion tercih et
- ❌ 14px'den küçük font size — erişilebilirlik

**Ne YAPILACAK:**
- ✅ Gece fotoğrafı hissi, amber glow — şehirli enerji
- ✅ Monospace font tarih/saat için — bilet estetiği
- ✅ Boş durumlar (empty states) için özenli tasarım
- ✅ Skeleton loading — her kart için
- ✅ Micro-copy — "248 etkinlik" gibi sayılar motivasyon yaratır
- ✅ Progressive disclosure — detaylar adım adım açılır


*

*Bu doküman, Unizone v2.0 tasarım sürecinin başlangıç referansıdır. Değişiklik ve güncellemeler için versiyon numarasını artırın.*