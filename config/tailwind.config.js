//const defaultTheme = require('tailwindcss/defaultTheme')

// For npm/yarn
// const { getUltimateTurboModalPath } = require('ultimate_turbo_modal/gemPath');

// If using Importmaps, use the following instead:
const { execSync } = require('child_process');

function getUltimateTurboModalPath() {
 const path = execSync('bundle show ultimate_turbo_modal').toString().trim();
 return `${path}/**/*.{erb,html,rb}`;
}
module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './vendor/javascript/tailwindcss-stimulus-components.js',
    getUltimateTurboModalPath()
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Carolineale', 'Helvetica', 'san-serif'],
        serif: ['gelica','Arial', 'san-serif'],
      },
      screens: {
        sm: '480px',
        md: '768px',
        lg: '976px',
        xl: '1440px',
      },
      colors: {
        'white': {
          100: '#ffffff',
          200: '#e4eaee',
        },
        'electric-blue': '#8AF3FF',
        'ultra-violet': '#565687',
        'gray': '#80838a',
        'jet': '#484349',
        'persian-green': '#18A999',
        'celeste': '#b9e8e2',
        'silver': '#cfcbcb',
        'snow': '#F7F0F0',

        'red': '#ed3431',
        'dark-red': '#790000',

        // DD colors
        'dd-gray': '#767676',
        'dd-ph': '#A5A5A5',
        'dd-gray-white': '#DDE7E6',
        'dd-white-low': '#FFFFFFCC',
        'dd-gray-low': '#F6F8F8',
        'dd-black': '#313131',
        'dd-persian-green-mid': '#4F807B',
        'dd-persian-green-light': '#8BF3FF',
        'dd-persian-green-darkest': '#4F807B0D',
        'dd-red': '#EA2B2B',
        'dd-sky-blue': '#3D8BD3',

      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
