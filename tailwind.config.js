/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      // ─── Tipografía ───────────────────────────────────────
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        '2xs': ['0.625rem', { lineHeight: '0.875rem' }],
      },

      // ─── Tokens de color ──────────────────────────────────
      colors: {
        // Acento único: Indigo
        primary: {
          50:  '#eef2ff',
          100: '#e0e7ff',
          200: '#c7d2fe',
          300: '#a5b4fc',
          400: '#818cf8',
          DEFAULT: '#6366f1', // indigo-500
          600: '#4f46e5',
          700: '#4338ca',
          variant: '#4338ca', // alias legible para hover
        },

        // Base neutra oscura: Slate
        surface: {
          DEFAULT:   '#0f172a', // slate-900  — fondo de página
          container: '#1e293b', // slate-800  — contenedores principales
          card:      '#334155', // slate-700  — tarjetas elevadas
          overlay:   '#475569', // slate-600  — capas sobre cards
        },

        // Texto sobre base oscura
        text: {
          main:      '#f1f5f9', // slate-100
          secondary: '#94a3b8', // slate-400
          muted:     '#64748b', // slate-500
        },

        // Bordes
        border: {
          DEFAULT: '#1e293b', // slate-800 — borde sutil sobre fondo
          strong:  '#334155', // slate-700 — borde destacado
        },

        // Feedback semántico
        danger: {
          DEFAULT: '#f87171', // red-400
          bg:      '#450a0a', // fondo oscuro para error
        },
        success: {
          DEFAULT: '#34d399', // emerald-400
          bg:      '#064e3b', // fondo oscuro para éxito
        },
        warning: {
          DEFAULT: '#fbbf24', // amber-400
          bg:      '#451a03', // fondo oscuro para warning
        },
      },

      // ─── Radio de borde único ─────────────────────────────
      borderRadius: {
        // Escala simplificada con un solo radio de referencia
        none:  '0px',
        sm:    '6px',
        DEFAULT:'10px',
        md:    '10px',  // → alias del DEFAULT
        lg:    '14px',
        xl:    '18px',
        '2xl': '24px',
        full:  '9999px',
      },

      // ─── Sombras coherentes con tema oscuro ───────────────
      boxShadow: {
        sm:  '0 1px 2px 0 rgba(0,0,0,0.3)',
        DEFAULT: '0 2px 8px -1px rgba(0,0,0,0.4)',
        md:  '0 4px 16px -2px rgba(0,0,0,0.5)',
        lg:  '0 8px 32px -4px rgba(0,0,0,0.6)',
        glow:'0 0 0 3px rgba(99,102,241,0.35)',   // foco/hover indigo
      },
    },
  },
  plugins: [],
}
