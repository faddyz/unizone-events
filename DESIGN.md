# UNIZONE — Design System v3.0
### "Electric City" — Yeni Nesil Tasarım Manifestosu
> **Stack:** Ruby on Rails · Tailwind CSS · Turbo · Stimulus  
> **Durum:** Sıfırdan yeniden tasarım — mevcut backend korunuyor  
> **Tarih:** Nisan 2026

---

## 0. Neden Bu Tasarım?

Mevcut backend refactor'dan çıkan yeni mimari güçlü: `brand-mark`, `cinema-panel`, `poster-noise`, `hero-energy`, `lift-card` gibi sınıf isimleri zaten doğru bir sinematik kelime dağarcığı kuruyor. Sorun bunların görsel karşılığının bu dili yeterince taşımaması.

Yeni tasarım bu altyapının üstüne oturur. Rota yapısı, controller isimleri, partial yapısı değişmez. Yalnızca CSS token'ları, tipografi, animasyon katmanı ve sayfa içi kompozisyon değişir.

---

## 1. Kimlik ve Yön

### 1.1 Tek Cümle Vizyon
> *"Konser öncesi o his — şehrin bir yerinde bir şeyler başlamak üzere."*

### 1.2 Tasarım Referansları
| Referans | Ne alıyoruz |
|---|---|
| Resident Advisor | Editorial grid, küçük mono tarih tipografisi, sert kategori renkleri |
| Boiler Room | Hero video energisi → CSS animated background ile simüle |
| Pitch.com | Temiz form tasarımı, adım adım wizard estetiği |
| Letterboxd | Kart yoğunluğu, hover grace |
| Are.na | Boşluk bilinci, editorial yaklaşım |

### 1.3 Logo — Revize Değil, Evrim

Mevcut logo: SVG lightning bolt (M18.4 3.5 7.8 16.2h7.1l-1.4 12.3…) siyah kare içinde, **citron sarısı (#d7ff39) shadow** ile. Bu kimlik çok güçlü — dokunma.

**Yapılacak:**
- `shadow-[6px_6px_0_var(--citron)]` → `shadow-[8px_8px_0_var(--citron)]` — daha dramatik
- Kare `rounded-2xl` → `rounded-xl` — biraz daha keskin
- Hero'da logoyu büyük göster: `size-20` veya `size-24`
- Animasyon: Sayfa yüklenirken shadow 0→8px `ease-out` ile büyür (CSS `@keyframes`)
- Dark hero üzerinde: kare arka plan `#0a0a0b`, shadow `var(--citron)` — zaten mükemmel kontrast

---

## 2. Renk Sistemi

### 2.1 Palet — "Electric City"

```css
/* app/assets/stylesheets/application.css */
:root {
  /* ─── Zemin ─── */
  --color-void:      #08080a;   /* En derin siyah — hero bg */
  --color-ink:       #0f0f12;   /* Kart üzeri bg */
  --color-surface:   #18181c;   /* Kart yüzeyi */
  --color-lift:      #242429;   /* Hover elevated */
  --color-edge:      #2e2e35;   /* Border */
  --color-edge-lit:  #3d3d47;   /* Hover border */

  /* ─── Mevcut Accent'ler (koru) ─── */
  --citron:          #d7ff39;   /* Ana vurgu — mevcut, koru */
  --coral:           #ff4d3d;   /* CTA kırmızısı — mevcut, koru */

  /* ─── Yeni Accent'ler ─── */
  --electric:        #e8ff47;   /* Citron'un daha parlak versiyonu — hover state */
  --ember:           #ff6b35;   /* Coral'ın daha sıcak versiyonu — featured events */
  --ice:             #c8e6ff;   /* Soğuk mavi — teknoloji/networking */
  --grape:           #b06eff;   /* Mor — sanat/sergi */
  --mint:            #3fffa8;   /* Yeşil — ücretsiz/onay */

  /* ─── Metin ─── */
  --text-primary:    #f0f0ea;   /* Krem beyaz */
  --text-secondary:  #8a8a96;   /* Soluk */
  --text-muted:      #4a4a56;   /* Placeholder */

  /* ─── Açık tema (page-shell içi) ─── */
  --page-bg:         #fffaf1;   /* Mevcut, koru */
  --page-text:       #0f0f12;
}
```

### 2.2 Palet Mantığı

**Hero bölgesi** → `--color-void` üzerine citron shadow logo + animated glow  
**Event kartları** → açık tema (`#fffaf1` arkaplan) — "gündüz şehri" hissi  
**Featured section** → karanlık (`--color-ink`) — kontrast, "gece sahnesi"  
**CTA banner** → `--citron` dolgu — güneş enerjisi, dikkat çekici  
**Category badges** → her kategorinin kendi rengi (mevcut sisteme ek olarak mapping tablosu)

### 2.3 Kategori Renk Mapping

```ruby
# app/helpers/events_helper.rb
CATEGORY_COLORS = {
  "general"     => { bg: "bg-stone-900",  text: "text-white",        label: "Topluluk" },
  "technology"  => { bg: "bg-[#1a3a6b]",  text: "text-[#c8e6ff]",   label: "Teknoloji" },
  "music"       => { bg: "bg-fuchsia-700", text: "text-fuchsia-100", label: "Müzik" },
  "art"         => { bg: "bg-[#3d1060]",  text: "text-[#b06eff]",    label: "Sanat" },
  "sports"      => { bg: "bg-lime-500",   text: "text-stone-950",    label: "Spor" },
  "education"   => { bg: "bg-cyan-600",   text: "text-white",        label: "Öğrenme" },
  "concert"     => { bg: "bg-indigo-700", text: "text-indigo-100",   label: "Canlı Müzik" },
  "festival"    => { bg: "bg-orange-500", text: "text-white",        label: "Festival" },
  "workshop"    => { bg: "bg-teal-500",   text: "text-stone-950",    label: "Atölye" },
  "party"       => { bg: "bg-pink-600",   text: "text-white",        label: "Gece Hayatı" },
  "theater"     => { bg: "bg-rose-700",   text: "text-rose-100",     label: "Sahne" },
  "exhibition"  => { bg: "bg-violet-700", text: "text-violet-100",   label: "Sergi" },
  "conference"  => { bg: "bg-blue-700",   text: "text-blue-100",     label: "Konferans" },
  "networking"  => { bg: "bg-emerald-600",text: "text-white",        label: "Buluşma" },
}
```

---

## 3. Tipografi

### 3.1 Font Stack

```css
/* Google Fonts — application.html.erb <head> */
/* Syne: geometric, assertive display — siyah arka plan üzerinde inanılmaz duruyor */
/* Bricolage Grotesque: editorial, biraz tuhaf body — karakteri var */
/* JetBrains Mono: tarih, saat, bilet numaraları */

@import url('https://fonts.googleapis.com/css2?family=Syne:wght@700;800&family=Bricolage+Grotesque:opsz,wght@12..96,400;12..96,500;12..96,600;12..96,700&family=JetBrains+Mono:wght@400;500&display=swap');

:root {
  --font-display: 'Syne', sans-serif;        /* Headlines, hero */
  --font-body:    'Bricolage Grotesque', sans-serif; /* Body, card */
  --font-mono:    'JetBrains Mono', monospace; /* Tarih, meta */
}
```

### 3.2 Tailwind Font Config

```js
// tailwind.config.js
fontFamily: {
  display: ['Syne', 'sans-serif'],
  body:    ['Bricolage Grotesque', 'sans-serif'],
  mono:    ['JetBrains Mono', 'monospace'],
},
```

### 3.3 Tipografi Skalası

| Rol | Font | Size / Weight | Tailwind |
|---|---|---|---|
| Hero H1 | display | 64–96px / 800 | `font-display font-extrabold text-6xl lg:text-8xl leading-[0.9] tracking-tight` |
| Section H2 | display | 32–48px / 700 | `font-display font-bold text-3xl lg:text-5xl tracking-tight` |
| Card title | body | 18–20px / 700 | `font-body font-bold text-lg leading-snug` |
| Body | body | 15px / 400 | `font-body text-[15px] leading-relaxed` |
| Meta date | mono | 11–12px / 500 | `font-mono text-xs font-medium tracking-wide` |
| Badge | body | 10px / 700 | `font-body text-[10px] font-black tracking-widest uppercase` |
| Eyebrow | mono | 11px / 500 | `font-mono text-[11px] tracking-[0.15em] uppercase` |

**Önemli not:** Syne sadece 700 ve 800 weight'e sahip. Hero headline için 800 kullan.

---

## 4. Motion & Animasyon

### 4.1 Felsefe
Az ama güçlü. Her animasyonun bir sebebi var. Parallelism yok — stagger tercih edilir.

### 4.2 Tailwind Config Eklemeleri

```js
// tailwind.config.js
animation: {
  'rise':         'rise 0.7s cubic-bezier(0.16, 1, 0.3, 1) both',
  'rise-slow':    'rise 1s cubic-bezier(0.16, 1, 0.3, 1) both',
  'glow-pulse':   'glowPulse 4s ease-in-out infinite',
  'drift-1':      'drift1 25s ease-in-out infinite',
  'drift-2':      'drift2 32s ease-in-out infinite',
  'drift-3':      'drift3 28s ease-in-out infinite',
  'shimmer':      'shimmer 1.8s infinite linear',
  'float-badge':  'floatBadge 3s ease-in-out infinite',
},
keyframes: {
  rise: {
    from: { opacity: '0', transform: 'translateY(24px)' },
    to:   { opacity: '1', transform: 'translateY(0)' },
  },
  glowPulse: {
    '0%,100%': { opacity: '0.6' },
    '50%':     { opacity: '1' },
  },
  drift1: {
    '0%,100%': { transform: 'translate(0,0) scale(1)' },
    '33%':     { transform: 'translate(60px,-40px) scale(1.1)' },
    '66%':     { transform: 'translate(-30px,50px) scale(0.9)' },
  },
  drift2: {
    '0%,100%': { transform: 'translate(0,0) scale(1)' },
    '40%':     { transform: 'translate(-80px,30px) scale(1.15)' },
    '70%':     { transform: 'translate(50px,-60px) scale(0.85)' },
  },
  drift3: {
    '0%,100%': { transform: 'translate(0,0) scale(1)' },
    '50%':     { transform: 'translate(40px,70px) scale(1.05)' },
  },
  shimmer: {
    '0%':   { backgroundPosition: '-200% 0' },
    '100%': { backgroundPosition: '200% 0' },
  },
  floatBadge: {
    '0%,100%': { transform: 'translateY(0)' },
    '50%':     { transform: 'translateY(-4px)' },
  },
},
```

### 4.3 Stagger Card Reveal (ERB)

```erb
<%# _event_card.html.erb — index ile çağırılır %>
<article class="animate-rise opacity-0"
         style="animation-delay: <%= index * 80 %>ms; animation-fill-mode: forwards;">
```

### 4.4 GSAP — Sadece Hero İçin

Hero text reveal için GSAP CDN kullanılabilir. Importmap'e eklenir:

```json
// config/importmap.rb
pin "gsap", to: "https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"
```

```js
// app/javascript/controllers/hero_controller.js
import { Controller } from "@hotwired/stimulus"
import gsap from "gsap"

export default class extends Controller {
  static targets = ["line", "sub", "form", "logo"]

  connect() {
    // Sayfa ilk yüklendiğinde çalışır, Turbo Drive cache'den gelirse çalışmaz
    if (sessionStorage.getItem("hero-played")) return
    sessionStorage.setItem("hero-played", "1")

    gsap.set([this.lineTargets, this.subTarget, this.formTarget], {
      opacity: 0, y: 30
    })

    gsap.timeline({ defaults: { ease: "power3.out" } })
      .to(this.logoTarget, { scale: 1, opacity: 1, duration: 0.5, delay: 0.1 })
      .to(this.lineTargets, {
        opacity: 1, y: 0, duration: 0.8,
        stagger: 0.12
      }, "-=0.2")
      .to(this.subTarget,  { opacity: 1, y: 0, duration: 0.6 }, "-=0.4")
      .to(this.formTarget, { opacity: 1, y: 0, duration: 0.5 }, "-=0.3")
  }
}
```

### 4.5 Logo Shadow Animasyonu (CSS only)

```css
/* application.css */
.brand-mark {
  --shadow-size: 0px;
  box-shadow: var(--shadow-size) var(--shadow-size) 0 var(--citron);
  animation: brandReveal 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both;
}

@keyframes brandReveal {
  from { box-shadow: 0 0 0 var(--citron); }
  to   { box-shadow: 8px 8px 0 var(--citron); }
}

.brand-mark:hover {
  box-shadow: 10px 10px 0 var(--citron);
  transition: box-shadow 0.2s ease;
}
```

### 4.6 Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-delay: 0ms !important;
    transition-duration: 0.01ms !important;
  }
  .brand-mark { box-shadow: 8px 8px 0 var(--citron) !important; }
}
```

---

## 5. Hero Section — Tam Spesifikasyon

### 5.1 Konsept
Hero, navbar ile birleşik bir blok. Nav şeffaf başlar, scroll'da donup içindeki elementler küçülür. Hero arka planı nav'ın altından devam eder — "tek parça alan" hissi. Kartlar hero'nun altına, hafif negatif margin ile biner.

### 5.2 Arka Plan Katmanları (alttan üste)
1. **Zemin:** `bg-[#08080a]` solid
2. **Noise texture:** SVG noise filtresi veya CSS `background-image: url("data:image/svg+xml...")` — %12 opacity
3. **Glow orbs:** 3 adet `radial-gradient` div, `animate-drift-1/2/3` ile yavaş float
4. **Subtle grid:** `background-image: linear-gradient` 1px çizgiler — %8 opacity
5. **Gradient fade:** Alt kısım sayfa rengine (`#fffaf1`) `from-transparent to-[#fffaf1]`

### 5.3 Glow Orb Renkleri
- Orb 1: `radial-gradient(circle, rgba(215,255,57,0.12), transparent 65%)` — citron
- Orb 2: `radial-gradient(circle, rgba(255,77,61,0.09), transparent 65%)` — coral
- Orb 3: `radial-gradient(circle, rgba(176,110,255,0.08), transparent 65%)` — grape

### 5.4 ERB Yapısı

```erb
<%# app/views/layouts/_hero.html.erb veya home/index.html.erb %>

<section class="relative overflow-hidden bg-[#08080a] text-white"
         data-controller="hero"
         data-hero-target="">

  <%# Arka plan katmanları %>
  <div class="soft-grid absolute inset-0 opacity-[0.08]"></div>

  <div class="absolute inset-0 overflow-hidden">
    <div class="animate-drift-1 absolute -top-32 -left-32 h-[600px] w-[600px] rounded-full
                opacity-70"
         style="background: radial-gradient(circle, rgba(215,255,57,0.14), transparent 65%)">
    </div>
    <div class="animate-drift-2 absolute -bottom-20 right-0 h-[500px] w-[500px] rounded-full
                opacity-60"
         style="background: radial-gradient(circle, rgba(255,77,61,0.10), transparent 65%);
                animation-delay: -10s">
    </div>
    <div class="animate-drift-3 absolute top-1/3 left-1/2 h-[400px] w-[400px] rounded-full
                opacity-50"
         style="background: radial-gradient(circle, rgba(176,110,255,0.09), transparent 65%);
                animation-delay: -18s">
    </div>
  </div>

  <%# İçerik %>
  <div class="page-shell relative grid min-h-[36rem] content-end gap-10 pb-16 pt-24 lg:min-h-[44rem]">

    <div class="max-w-5xl" data-hero-target="content">

      <%# Logo — büyük versiyonu %>
      <div class="mb-8" data-hero-target="logo">
        <%= render "shared/brand_mark", size: "size-20 lg:size-24", text_size: "text-2xl lg:text-3xl" %>
      </div>

      <%# Eyebrow %>
      <p class="font-mono text-[11px] tracking-[0.18em] uppercase text-citron mb-5"
         data-hero-target="sub">
        Yakınındaki etkinlikler
      </p>

      <%# H1 — satır satır GSAP target %>
      <h1 class="font-display font-extrabold leading-[0.9] tracking-tight
                 text-6xl sm:text-7xl lg:text-[88px] text-white">
        <span class="block" data-hero-target="line">Bu gece</span>
        <span class="block text-citron" data-hero-target="line">nerede</span>
        <span class="block" data-hero-target="line">olacağını keşfet.</span>
      </h1>

      <p class="mt-6 max-w-xl font-body text-lg leading-relaxed text-white/65"
         data-hero-target="sub">
        Konserleri, atölyeleri, buluşmaları ve şehirde konuşulan geceleri
        tek yerden bul. RSVP ver, arkadaşlarını çağır, istersen kendi etkinliğini başlat.
      </p>
    </div>

    <%# Arama formu %>
    <form class="..." action="/explore" method="get" data-hero-target="form">
      <%# mevcut form yapısı korunur, yeni stil uygulanır %>
    </form>
  </div>

  <%# Hero → Sayfa geçiş fade %>
  <div class="absolute bottom-0 inset-x-0 h-32
              bg-gradient-to-t from-page to-transparent pointer-events-none">
  </div>

</section>
```

### 5.5 Arama Formu — Yeni Stil

```erb
<form class="grid gap-3 rounded-2xl border border-white/10
             bg-white/[0.06] p-3 backdrop-blur-md
             text-white shadow-2xl
             md:grid-cols-[1fr_220px_150px]"
      action="/explore" method="get">

  <input type="text" name="query"
    class="h-12 rounded-xl border border-white/15 bg-white/10 px-4
           text-sm font-medium text-white placeholder-white/40
           focus:border-citron/60 focus:outline-none focus:ring-1
           focus:ring-citron/30 transition-colors"
    placeholder="Konser, atölye, mekan ara...">

  <select name="category"
    class="h-12 rounded-xl border border-white/15 bg-white/10 px-4
           text-sm font-medium text-white
           focus:border-citron/60 focus:outline-none transition-colors
           [&>option]:bg-[#18181c] [&>option]:text-white">
    <%# seçenekler %>
  </select>

  <button type="submit"
    class="h-12 rounded-xl bg-coral px-5 text-sm font-black text-white
           hover:bg-ember active:scale-[0.97] transition-all">
    Keşfet
  </button>
</form>
```

---

## 6. Sayfa Bölümleri

### 6.1 Stats Strip (Cinema Panels)

Mevcut `cinema-panel` sınıfını güçlendir:

```css
/* application.css */
.cinema-panel {
  background: white;
  border: 1px solid rgba(15, 15, 18, 0.08);
  box-shadow: 0 1px 2px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.06);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.cinema-panel:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 24px rgba(0,0,0,0.1);
}
```

Stats sayıları: `font-display text-5xl font-extrabold` — daha büyük, daha dramatik.

### 6.2 Event Cards — Lift Card

```css
.lift-card {
  transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1),
              box-shadow 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}
.lift-card:hover {
  transform: translateY(-4px) scale(1.01);
  box-shadow: 0 16px 48px rgba(0,0,0,0.14), 0 4px 12px rgba(0,0,0,0.08);
}
```

**Kart içi değişiklikler:**
- Poster alanı: `aspect-[4/3]` → `aspect-video` (16:9) — daha sinematik
- Tarih badge: `rounded-xl` yerine `rounded-lg` — daha sert
- Tarih sayısı: `font-display` → `font-mono font-black` — bilet estetiği
- Katılım satırı: `"X kişi gidiyor"` → yeşil `mint` renkli nokta animasyonu
- Card title hover: `hover:text-blue-700` → `hover:text-coral`

### 6.3 Featured Dark Section

```erb
<section class="bg-ink py-16 text-white">
  <div class="page-shell">
    <div class="mb-3 font-mono text-[11px] tracking-[0.15em] uppercase text-citron">
      Öne çıkanlar
    </div>
    <h2 class="font-display font-bold text-4xl lg:text-5xl text-white mb-8">
      Yeni eklenen planlar
    </h2>
    <%# Büyük 3-col grid, kartlar dark yüzey üzerinde %>
  </div>
</section>
```

### 6.4 Category Pills (Sahneni Seç)

```erb
<section class="page-shell mt-14">
  <p class="font-mono text-[11px] tracking-[0.15em] uppercase text-blue-700 mb-2">
    Ruh haline göre
  </p>
  <h2 class="font-display text-3xl font-bold text-stone-950 mb-6">
    Sahneni seç
  </h2>
  <div class="flex flex-wrap gap-2">
    <%# Her pill hover'da -translate-y-1, citron focus ring %>
    <a class="category-pill ..." href="...">
      <span class="pill-dot">●</span> #Topluluk
    </a>
  </div>
</section>
```

```css
.category-pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border-radius: 9999px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}
.category-pill:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(0,0,0,0.15);
}
.category-pill:focus-visible {
  outline: 2px solid var(--citron);
  outline-offset: 3px;
}
.pill-dot {
  font-size: 8px;
  opacity: 0.7;
}
```

### 6.5 CTA Banner

```erb
<section class="page-shell mt-16">
  <div class="cta-banner relative overflow-hidden rounded-2xl
              bg-citron p-8 text-stone-950 md:p-10">
    <%# Decorative element — sağ tarafta büyük blur daire %>
    <div class="absolute -right-16 -top-16 h-64 w-64 rounded-full
                bg-white/20 blur-3xl pointer-events-none"></div>

    <div class="relative grid gap-6 md:grid-cols-[1fr_auto] md:items-center">
      <div>
        <p class="font-mono text-[11px] tracking-[0.15em] uppercase opacity-70">
          Bir şey başlat
        </p>
        <h2 class="font-display mt-2 text-3xl font-bold md:text-4xl">
          Fikrini yayına hazır bir etkinliğe dönüştür.
        </h2>
        <p class="mt-2 max-w-xl text-sm font-medium leading-6 text-stone-700">
          Taslak oluştur, detayları şekillendir ve hazır olduğunda incelemeye gönder.
        </p>
      </div>
      <a href="/organizer/events/new"
         class="inline-flex items-center gap-2 rounded-xl bg-stone-950 px-6 py-3
                text-sm font-black text-citron
                hover:-translate-y-0.5 hover:shadow-xl transition-all
                focus-ring">
        Etkinlik Oluştur
        <svg class="size-4" viewBox="0 0 16 16" fill="none">
          <path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
        </svg>
      </a>
    </div>
  </div>
</section>
```

---

## 7. Diğer Sayfalar

### 7.1 /explore

**Üst kısım değişimi:**
- Arama çubuğu: glassmorphism değil, solid `bg-stone-100 border-stone-200`
- Category filter row: horizontal scroll, momentum, snap — `scrollbar-none snap-x`
- Sort dropdown: custom styled, Stimulus ile controlled
- Turbo Frame wrap: `#events-grid` — filtre ve arama sonuçları

### 7.2 /organizer/events/new (Etkinlik Oluştur)

**Multi-step wizard:** Mevcut single-page form'u adımlara böl.

```
Progress bar üstte:
●━━━━━━━━○━━━━━━━━○━━━━━━━━○
Bilgiler     Zaman/Yer    Görsel     Önizleme

Stimulus wizard_controller.js ile step show/hide
```

Form inputs: daha büyük, daha belirgin — `h-14` input height, amber focus ring yerine citron

### 7.3 /dashboard (Planlarım)

**Tab layout:**
```
[Katılacaklarım] [Geçmiş] [Kayıtlı]
─────────────────────────────────────
Turbo Frame #dashboard-content
```

### 7.4 /account/profile

**Profil header:**
- Cover: kategoriye göre dinamik gradient (en çok gittiği)
- Stats row: `X etkinliğe katıldı`, `Y etkinlik düzenledi`
- Avatar: initials veya upload

### 7.5 /organizer/events (Etkinliklerim)

**Dashboard tarzı layout:**
- Tablo yerine kart grid — mini event kartları
- Durum badge'leri: `Taslak`, `İncelemede`, `Yayında`, `Sona Erdi`
- Hızlı aksiyon: `...` menüsü (Stimulus dropdown controller)

---

## 8. Navigation

### 8.1 Desktop Nav

```erb
<nav class="uz-nav sticky top-0 z-40 transition-all duration-300"
     data-controller="navbar"
     data-navbar-target="bar">

  <div class="page-shell flex items-center justify-between py-4 gap-4">
    <%# Logo %>
    <%= render "shared/brand_mark" %>

    <%# Links %>
    <div class="hidden lg:flex items-center gap-1 text-sm font-bold">
      <%= link_to "Keşfet", explore_path, class: "nav-link" %>
      <%= link_to "Etkinlik Oluştur", new_organizer_event_path, class: "nav-link" %>
      <%= link_to "Planlarım", dashboard_path, class: "nav-link" %>
    </div>

    <%# Auth %>
    <div class="flex items-center gap-2">
      <% if user_signed_in? %>
        <%= link_to current_user.display_name, account_profile_path, class: "nav-link text-sm" %>
        <%# Çıkış butonu %>
      <% else %>
        <%= link_to "Giriş", new_user_session_path, class: "nav-link" %>
        <%= link_to "Kayıt Ol", new_user_registration_path,
              class: "rounded-full bg-stone-950 px-4 py-2 text-sm font-black
                     text-citron hover:bg-stone-800 transition-colors" %>
      <% end %>
    </div>
  </div>
</nav>
```

```css
.uz-nav {
  background: rgba(255, 250, 241, 0.92);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(15,15,18,0.08);
}

/* Hero içindeyken nav şeffaf */
.uz-nav[data-scrolled="false"] {
  background: rgba(8,8,10,0.01);
  border-bottom-color: rgba(255,255,255,0.05);
}

.nav-link {
  border-radius: 9999px;
  padding: 8px 14px;
  color: inherit;
  transition: background-color 0.15s ease;
}
.nav-link:hover {
  background: rgba(15,15,18,0.07);
}
```

```js
// navbar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.onScroll = () => {
      this.element.dataset.scrolled = window.scrollY > 80 ? "true" : "false"
    }
    this.onScroll()
    window.addEventListener("scroll", this.onScroll, { passive: true })
  }
  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }
}
```

### 8.2 Mobile — Bottom Nav Bar

```erb
<div class="fixed bottom-0 inset-x-0 z-50 flex border-t border-stone-950/10
            bg-page/95 backdrop-blur-md
            pb-[env(safe-area-inset-bottom)] lg:hidden">

  <%= render "shared/bottom_nav_item",
        icon: "home", label: "Ana Sayfa", path: root_path %>
  <%= render "shared/bottom_nav_item",
        icon: "compass", label: "Keşfet", path: explore_path %>
  <%= render "shared/bottom_nav_item",
        icon: "plus", label: "Oluştur", path: new_organizer_event_path,
        accent: true %>
  <%= render "shared/bottom_nav_item",
        icon: "user", label: "Hesap", path: account_profile_path %>
</div>
```

---

## 9. Component CSS — application.css Tam Dosyası

Aşağıdaki dosyayı `application.css` referansı olarak kullan. Tailwind `@apply` yerine native CSS — daha okunabilir, daha performanslı.

```css
/* ═══════════════════════════════════════════════
   UNIZONE application.css — v3.0 "Electric City"
   ═══════════════════════════════════════════════ */

/* 1. Tokens */
:root {
  --citron:    #d7ff39;
  --electric:  #e8ff47;
  --coral:     #ff4d3d;
  --ember:     #ff6b35;
  --grape:     #b06eff;
  --mint:      #3fffa8;
  --ice:       #c8e6ff;

  --page-bg:   #fffaf1;
  --void:      #08080a;
  --ink:       #0f0f12;
  --surface:   #18181c;

  --text-1:    #f0f0ea;
  --text-2:    #8a8a96;
  --text-3:    #4a4a56;

  --radius-card: 1.6rem;
  --radius-btn:  9999px;
  --radius-form: 0.75rem;
}

/* 2. Focus ring — global */
:focus-visible {
  outline: 2px solid var(--citron);
  outline-offset: 2px;
  border-radius: 4px;
}

/* 3. Brand mark */
.brand-mark {
  box-shadow: 8px 8px 0 var(--citron);
  border-radius: 0.875rem; /* rounded-xl */
  animation: brandReveal 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both;
  transition: box-shadow 0.2s ease, transform 0.2s ease;
}
.brand-mark:hover {
  box-shadow: 10px 10px 0 var(--citron);
  transform: translate(-1px, -1px);
}
@keyframes brandReveal {
  from { box-shadow: 0 0 0 var(--citron); }
  to   { box-shadow: 8px 8px 0 var(--citron); }
}

/* 4. Soft grid (hero bg texture) */
.soft-grid {
  background-image:
    linear-gradient(rgba(255,255,255,0.04) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.04) 1px, transparent 1px);
  background-size: 60px 60px;
}

/* 5. Hero energy (ambient glow layer — mevcut class, güçlendirildi) */
.hero-energy {
  background:
    radial-gradient(ellipse 80% 50% at 20% -10%, rgba(215,255,57,0.08), transparent),
    radial-gradient(ellipse 60% 40% at 80% 110%, rgba(255,77,61,0.06), transparent);
}

/* 6. Poster noise */
.poster-noise {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='300' height='300'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.75' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='300' height='300' filter='url(%23n)' opacity='0.035'/%3E%3C/svg%3E");
  background-size: 300px 300px;
  mix-blend-mode: overlay;
}

/* 7. Cinema panel (stats) */
.cinema-panel {
  background: white;
  border: 1px solid rgba(15,15,18,0.08);
  box-shadow: 0 1px 2px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.06);
  transition: transform 0.2s cubic-bezier(0.16,1,0.3,1),
              box-shadow 0.2s cubic-bezier(0.16,1,0.3,1);
}
.cinema-panel:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 32px rgba(0,0,0,0.1);
}

/* 8. Lift card */
.lift-card {
  transition: transform 0.25s cubic-bezier(0.16,1,0.3,1),
              box-shadow 0.25s cubic-bezier(0.16,1,0.3,1);
}
.lift-card:hover {
  transform: translateY(-5px) scale(1.005);
  box-shadow: 0 20px 60px rgba(0,0,0,0.12), 0 4px 16px rgba(0,0,0,0.06);
}

/* 9. Page shell */
.page-shell {
  max-width: 1280px;
  margin-left: auto;
  margin-right: auto;
  padding-left: 1rem;
  padding-right: 1rem;
}
@media (min-width: 640px) {
  .page-shell { padding-left: 2rem; padding-right: 2rem; }
}
@media (min-width: 1024px) {
  .page-shell { padding-left: 3rem; padding-right: 3rem; }
}

/* 10. Animate rise */
@keyframes rise {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}
.animate-rise-in { animation: rise 0.7s cubic-bezier(0.16,1,0.3,1) both; }

/* 11. Skeleton shimmer */
@keyframes shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}
.skeleton {
  background: linear-gradient(
    90deg,
    rgba(15,15,18,0.06) 25%,
    rgba(15,15,18,0.1) 50%,
    rgba(15,15,18,0.06) 75%
  );
  background-size: 200% 100%;
  animation: shimmer 1.8s infinite linear;
}

/* 12. Scrollbar none (category pills) */
.scrollbar-none { scrollbar-width: none; }
.scrollbar-none::-webkit-scrollbar { display: none; }

/* 13. Reduced motion */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-delay: 0ms !important;
    transition-duration: 0.01ms !important;
  }
  .brand-mark { box-shadow: 8px 8px 0 var(--citron) !important; }
}
```

---

## 10. Tailwind Config — Tam

```js
// tailwind.config.js
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/assets/stylesheets/application.css',
  ],
  theme: {
    extend: {
      fontFamily: {
        display: ['Syne', ...defaultTheme.fontFamily.sans],
        body:    ['Bricolage Grotesque', ...defaultTheme.fontFamily.sans],
        mono:    ['JetBrains Mono', ...defaultTheme.fontFamily.mono],
      },
      colors: {
        citron:  '#d7ff39',
        electric:'#e8ff47',
        coral:   '#ff4d3d',
        ember:   '#ff6b35',
        grape:   '#b06eff',
        mint:    '#3fffa8',
        ice:     '#c8e6ff',
        void:    '#08080a',
        ink:     '#0f0f12',
      },
      animation: {
        'rise':        'rise 0.7s cubic-bezier(0.16,1,0.3,1) both',
        'drift-1':     'drift1 25s ease-in-out infinite',
        'drift-2':     'drift2 32s ease-in-out infinite',
        'drift-3':     'drift3 28s ease-in-out infinite',
        'shimmer':     'shimmer 1.8s infinite linear',
        'float-badge': 'floatBadge 3s ease-in-out infinite',
        'glow-pulse':  'glowPulse 4s ease-in-out infinite',
      },
      keyframes: {
        rise: {
          from: { opacity: '0', transform: 'translateY(20px)' },
          to:   { opacity: '1', transform: 'translateY(0)' },
        },
        drift1: {
          '0%,100%': { transform: 'translate(0,0) scale(1)' },
          '33%':     { transform: 'translate(60px,-40px) scale(1.1)' },
          '66%':     { transform: 'translate(-30px,50px) scale(0.9)' },
        },
        drift2: {
          '0%,100%': { transform: 'translate(0,0) scale(1)' },
          '40%':     { transform: 'translate(-80px,30px) scale(1.15)' },
          '70%':     { transform: 'translate(50px,-60px) scale(0.85)' },
        },
        drift3: {
          '0%,100%': { transform: 'translate(0,0) scale(1)' },
          '50%':     { transform: 'translate(40px,70px) scale(1.05)' },
        },
        shimmer: {
          '0%':   { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0' },
        },
        floatBadge: {
          '0%,100%': { transform: 'translateY(0)' },
          '50%':     { transform: 'translateY(-4px)' },
        },
        glowPulse: {
          '0%,100%': { opacity: '0.6' },
          '50%':     { opacity: '1' },
        },
      },
      boxShadow: {
        'citron':     '8px 8px 0 #d7ff39',
        'citron-lg':  '12px 12px 0 #d7ff39',
        'card':       '0 1px 3px rgba(0,0,0,0.05), 0 8px 24px rgba(0,0,0,0.07)',
        'card-hover': '0 20px 60px rgba(0,0,0,0.12), 0 4px 16px rgba(0,0,0,0.06)',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/line-clamp'),
    require('@tailwindcss/aspect-ratio'),
  ],
  safelist: [
    { pattern: /^bg-(stone|fuchsia|lime|cyan|indigo|orange|teal|pink|rose|violet|blue|emerald)-/ },
    { pattern: /^text-(fuchsia|lime|cyan|indigo|orange|teal|pink|rose|violet|blue|emerald)-/ },
    'bg-[#1a3a6b]', 'text-[#c8e6ff]', 'bg-[#3d1060]', 'text-[#b06eff]',
  ],
}
```

---

## 11. Dosya Yapısı — Önerilen Organizasyon

```
app/
├── assets/stylesheets/
│   └── application.css          ← Yeni v3.0 (bu dokümandaki CSS)
├── javascript/controllers/
│   ├── hero_controller.js       ← GSAP text reveal
│   ├── navbar_controller.js     ← scroll shrink / transparent toggle
│   ├── wizard_controller.js     ← event create multi-step
│   ├── search_controller.js     ← debounced search
│   ├── drawer_controller.js     ← mobile filter bottom sheet
│   ├── infinite_scroll_controller.js
│   ├── counter_controller.js    ← hero event count up
│   ├── accordion_controller.js  ← FAQ
│   └── attendance_controller.js ← RSVP (mevcut)
├── views/
│   ├── layouts/
│   │   ├── application.html.erb ← Google Fonts link, GSAP pin
│   │   └── _bottom_nav.html.erb ← mobile bottom bar (yeni)
│   ├── shared/
│   │   ├── _brand_mark.html.erb ← logo partial (size parametreli)
│   │   ├── _event_card.html.erb ← kart partial
│   │   ├── _event_card_skeleton.html.erb
│   │   └── _flash.html.erb
│   └── ... (mevcut view yapısı korunur)
```

---

## 12. Geliştirici Kuralları

**YAPMA:**
- ❌ `data-remote: true` — Turbo ile çakışır
- ❌ jQuery
- ❌ Alpine.js — Stimulus ile çakışır
- ❌ Dinamik Tailwind string: `"text-#{color}-500"` — purge eder
- ❌ Hero içinde fotoğraf/stock görsel
- ❌ `!important` — Tailwind sıralaması yeterli

**YAP:**
- ✅ GSAP sadece hero text animasyonu için — başka yerde CSS yeterli
- ✅ `sessionStorage.getItem("hero-played")` — hero animasyonunu Turbo Drive cache'de tekrarlama
- ✅ Her Turbo Frame'e anlamlı id: `"events-grid"`, `"dashboard-content"`
- ✅ Skeleton loading — her lazy Frame için
- ✅ `pin "gsap"` importmap'e ekle, CDN'den değil
- ✅ `safelist` — dinamik kategori renkleri için
- ✅ `prefers-reduced-motion` — application.css'de global

---

*UNIZONE Design System v3.0 — "Electric City"  
Rails + Tailwind + Turbo + Stimulus + GSAP (hero only)*