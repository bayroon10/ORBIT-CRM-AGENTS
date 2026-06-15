# 🚀 Orbit CRM

> CRM operativo moderno para equipos de ventas B2B — construido con Vue 3 + Supabase

![Vue.js](https://img.shields.io/badge/Vue.js-3.x-4FC08D?style=flat-square&logo=vue.js&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-5.x-646CFF?style=flat-square&logo=vite&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.x-06B6D4?style=flat-square&logo=tailwindcss&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?style=flat-square&logo=supabase&logoColor=white)
![GSAP](https://img.shields.io/badge/GSAP-3.15-88CE02?style=flat-square&logo=greensock&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-ES2022-F7DF1E?style=flat-square&logo=javascript&logoColor=black)

![Dashboard Orbit CRM](./stitch-design-package/screens/panel_de_control.png)

## ¿Qué es Orbit CRM?

Sistema CRM operativo completo para equipos de ventas, con gestión de leads,
pipeline de negocios en kanban, cotizaciones, directorio de empresas, tareas
y registro de actividad. Construido sobre Vue 3 puro con Supabase como backend
completo (autenticación, PostgreSQL y RLS por roles). Diseñado para escalar hacia
automatización con n8n y agentes de IA en futuras versiones.

## Módulos

| Módulo | Descripción | Estado |
|--------|-------------|--------|
| 🎯 Dashboard | Métricas en tiempo real con animaciones GSAP | ✅ Producción |
| 👥 Leads | Gestión completa con modal de creación y vista detalle | ✅ Producción |
| 💼 Deals | Kanban de 5 columnas con drag visual y modal | ✅ Producción |
| 🏢 Companies | Directorio con panel lateral deslizante | ✅ Producción |
| ✅ Tasks | Lista con modal Nueva Tarea y badges de prioridad | ✅ Producción |
| 📄 Quotes | Pipeline de cotizaciones con estados | ✅ Producción |
| 📊 Sales | KPIs de ventas cerradas con métricas | ✅ Producción |
| ⚙️ Settings | Configuración general y gestión de usuarios | ✅ Producción |

## Stack tecnológico

| Tecnología | Uso | Versión |
|-----------|-----|---------|
| Vue 3 + Composition API | Framework reactivo con `<script setup>` | 3.x |
| Vue Router 4 | SPA routing con auth guards | 4.x |
| Vite | Build tool y dev server | 5.x |
| Tailwind CSS | Utility-first con design tokens custom | 3.x |
| Supabase | Auth + PostgreSQL + RLS + Realtime | Latest |
| GSAP | Animaciones de entrada y transiciones | 3.15 |
| Inter Font | Tipografía del sistema de diseño | — |

## Arquitectura

```
src/
├── lib/           # Cliente Supabase configurado
├── router/        # Rutas + auth guard global
├── layouts/       # AppLayout (sidebar+header) y AuthLayout
├── views/         # 14 vistas del CRM
├── components/    # Componentes Orbit* reutilizables
└── styles/        # Tailwind base + animaciones globales GSAP
```

### Componentes reutilizables

*   **OrbitModal** — Modal con Teleport, backdrop blur y transición
*   **OrbitMetricCard** — KPI card con ícono dinámico y efecto card-3d
*   **OrbitSidebar** — Navegación lateral con secciones y estado activo
*   **OrbitHeader** — Header con iniciales del usuario y breadcrumb
*   **OrbitEmptyState** — Estado vacío consistente entre vistas
