const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        cyan: {
          300: '#67E8F9',
          400: '#22D3EE',
          500: '#06B6D4',
        },
        blue: {
          400: '#60A5FA',
          500: '#3B82F6',
        },
        purple: {
          300: '#D8B4FE',
          400: '#C084FC',
          500: '#A855F7',
        },
        indigo: {
          900: '#1E1B4B',
        },
      },
      animation: {
        'float-multidirection': 'float-multidirection 10s ease-in-out infinite',
        'bling': 'bling 3s ease-in-out infinite',
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'hologram': 'hologram 3s ease-in-out infinite',
      },
      keyframes: {
        'float-multidirection': {
          '0%, 100%': { transform: 'translateY(0) translateX(0)' },
          '50%': { transform: 'translateY(-10px) translateX(10px)' },
        },
        'bling': {
          '0%, 100%': { opacity: 0.2, transform: 'scale(0.8)' },
          '50%': { opacity: 1, transform: 'scale(1.2)' },
        },
        'hologram': {
          '0%, 100%': { textShadow: '0 0 5px rgba(103, 232, 249, 0.5), 0 0 10px rgba(103, 232, 249, 0.3)' },
          '50%': { textShadow: '0 0 10px rgba(103, 232, 249, 0.8), 0 0 20px rgba(103, 232, 249, 0.5), 0 0 30px rgba(103, 232, 249, 0.3)' },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
} 