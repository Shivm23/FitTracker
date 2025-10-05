/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        instagram: {
          pink: '#E1306C',
          purple: '#C13584',
          orange: '#F77737',
          yellow: '#FCAF45',
        },
        primary: {
          DEFAULT: '#E1306C',
          light: '#F05292',
          dark: '#B8245A',
        },
        secondary: {
          DEFAULT: '#F77737',
          light: '#FA9A62',
          dark: '#D5612C',
        },
        tertiary: {
          DEFAULT: '#C13584',
          light: '#D45FA4',
          dark: '#9A2A6A',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
