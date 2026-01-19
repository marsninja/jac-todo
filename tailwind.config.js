/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./**/*.jac",
    "./**/*.cl.jac",
    "./.jac/client/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
