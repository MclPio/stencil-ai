/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        'not-quite-black': 'var(--not-quite-black)',
        'bright-off-white': 'var(--bright-off-white)',
        'softer-off-white': 'var(--softer-off-white)',
        'electric-blue': 'var(--electric-blue)',
      },
      fontFamily: {
        space: ['var(--font-space)', 'sans-serif'],
        jakarta: ['var(--font-jakarta)', 'sans-serif'],
      }
    },
  },
  plugins: [
    require('daisyui'),
  ],
  daisyui: {
    themes: [
      {
        mytheme: {
          "primary": "#3B82F6",
          "base-100": "#0A0A0A",
        },
      },
    ],
  },
}