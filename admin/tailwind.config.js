export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        freelang: {
          50: '#f8fafc',
          100: '#f1f5f9',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1'
        }
      },
      animation: {
        'spin-slow': 'spin 3s linear infinite',
        'pulse-subtle': 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite'
      }
    }
  },
  plugins: []
}
