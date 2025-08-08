
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
        'not-quite-black': '#0A0A0A',
        'bright-off-white': '#F5F5F5',
        'softer-off-white': '#A3A3A3',
        'electric-blue': '#3B82F6',
      },
      fontFamily: {
        space: ['"Space Grotesk"', 'sans-serif'],
        jakarta: ['"Plus Jakarta Sans"', 'sans-serif'],
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
