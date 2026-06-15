/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      colors: {
        primary: {
          DEFAULT: '#085ac0', // Action blue
          fixed: '#d8e2ff',
          variant: '#004395',
        },
        surface: {
          DEFAULT: '#fcf8fa', // Warm off-white
          container: '#f0edef',
          card: '#ffffff',
        },
        text: {
          main: '#1b1b1b',
          secondary: '#45464d',
        },
        danger: {
          DEFAULT: '#ba1a1a',
          bg: '#ffdad6',
        },
        success: {
          DEFAULT: '#019668',
          bg: '#84f9c3',
        },
        border: {
          DEFAULT: '#c6c6cd',
        }
      }
    },
  },
  plugins: [],
}
