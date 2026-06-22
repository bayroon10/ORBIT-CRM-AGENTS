# Contributing to Orbit CRM

This is a portfolio project, not a collaborative product.
The expected flow is: fork → customize → deploy.

Bug reports and security issues are welcome via GitHub Issues.
Feature requests: open an issue to discuss before submitting a PR.

## Development Setup

1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/orbit-crm.git
   cd orbit-crm
   ```
2. Install dependencies:
   ```sh
   npm install
   ```
3. Set up environment variables:
   ```sh
   cp .env.example .env
   # Edit .env with your Supabase and n8n credentials
   ```
4. Start n8n automation via Docker:
   ```sh
   docker-compose up -d
   ```
5. Run the Vite development server:
   ```sh
   npm run dev
   ```

## Code Conventions

- **Vue 3 `script setup`**: All components must use the Composition API with `<script setup>`.
- **View State Pattern**: Every view implements a `loading → error → empty → data` pattern.
- **Modals**: Use the `OrbitModal` component, which utilizes `v-model`, `Teleport`, and `Transition` for rendering modal dialogs.
- **Styling**: Stick to the semantic Tailwind colors (`primary`, `surface`, `text`, `danger`, `success`, `border`, `warning`) defined in `tailwind.config.js`.
- **Animations**: Use GSAP for DOM transitions. Note: Always await `nextTick()` before running GSAP animations after a DOM update.
