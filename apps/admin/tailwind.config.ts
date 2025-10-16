import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#105640',
          light: '#F0F9F6',
          dark: '#0a3a2a',
        },
        secondary: {
          DEFAULT: '#2D7D5C',
        },
        accent: {
          DEFAULT: '#F59E0B',
          light: '#fef3c7',
        },
      },
    },
  },
  plugins: [],
}
export default config
