const defaultTheme = require("tailwindcss/defaultTheme")

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
    "./app/assets/stylesheets/**/*.css",
  ],
  theme: {
    extend: {
      fontFamily: {
        display: ["Syne", ...defaultTheme.fontFamily.sans],
        body: ["Bricolage Grotesque", ...defaultTheme.fontFamily.sans],
        mono: ["JetBrains Mono", ...defaultTheme.fontFamily.mono],
        sans: ["Bricolage Grotesque", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        citron: "#d7ff39",
        electric: "#e8ff47",
        coral: "#ff4d3d",
        ember: "#ff6b35",
        bluebolt: "#2f6bff",
        blueglow: "#5da8ff",
        grape: "#b06eff",
        mint: "#3fffa8",
        ice: "#c8e6ff",
        void: "#08080a",
        ink: "#0f0f12",
        surface: "#18181c",
        page: "#f7f2e8",
      },
      animation: {
        rise: "rise 0.7s cubic-bezier(0.16,1,0.3,1) both",
        "drift-1": "drift1 25s ease-in-out infinite",
        "drift-2": "drift2 32s ease-in-out infinite",
        "drift-3": "drift3 28s ease-in-out infinite",
        shimmer: "shimmer 1.8s infinite linear",
        "float-badge": "floatBadge 3s ease-in-out infinite",
        "glow-pulse": "glowPulse 4s ease-in-out infinite",
      },
      keyframes: {
        rise: {
          from: { opacity: "0", transform: "translateY(24px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
        drift1: {
          "0%,100%": { transform: "translate(0,0) scale(1)" },
          "33%": { transform: "translate(60px,-40px) scale(1.1)" },
          "66%": { transform: "translate(-30px,50px) scale(0.9)" },
        },
        drift2: {
          "0%,100%": { transform: "translate(0,0) scale(1)" },
          "40%": { transform: "translate(-80px,30px) scale(1.15)" },
          "70%": { transform: "translate(50px,-60px) scale(0.85)" },
        },
        drift3: {
          "0%,100%": { transform: "translate(0,0) scale(1)" },
          "50%": { transform: "translate(40px,70px) scale(1.05)" },
        },
        shimmer: {
          "0%": { backgroundPosition: "-200% 0" },
          "100%": { backgroundPosition: "200% 0" },
        },
        floatBadge: {
          "0%,100%": { transform: "translateY(0)" },
          "50%": { transform: "translateY(-4px)" },
        },
        glowPulse: {
          "0%,100%": { opacity: "0.6" },
          "50%": { opacity: "1" },
        },
      },
      boxShadow: {
        citron: "8px 8px 0 #d7ff39",
        "citron-lg": "12px 12px 0 #d7ff39",
        card: "0 1px 3px rgba(0,0,0,0.05), 0 8px 24px rgba(0,0,0,0.07)",
        "card-hover": "0 20px 60px rgba(0,0,0,0.12), 0 4px 16px rgba(0,0,0,0.06)",
      },
    },
  },
  safelist: [
    { pattern: /^bg-(stone|fuchsia|lime|cyan|indigo|orange|teal|pink|rose|violet|blue|emerald)-/ },
    { pattern: /^text-(stone|fuchsia|lime|cyan|indigo|orange|teal|pink|rose|violet|blue|emerald)-/ },
    { pattern: /^ring-(stone|amber|emerald|rose|zinc|blue)-/ },
    "bg-[#1a3a6b]",
    "text-[#c8e6ff]",
    "bg-[#3d1060]",
    "text-[#b06eff]",
    "bg-[#2b174d]",
    "text-[#d8c0ff]",
  ],
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
  ],
}
