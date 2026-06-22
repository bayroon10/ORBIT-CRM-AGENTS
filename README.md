<div align="center">
  <img src="./img/1_dashboard.png" alt="Orbit CRM Dashboard" width="100%">
  
  <h1>Orbit CRM</h1>
  
  <p><strong>AI-Powered CRM for Sales Teams</strong></p>
  
  <p>
    Built for scale, speed, and intelligence. Orbit CRM integrates Google's Gemini 2.5 Flash and n8n to automate lead qualification, calculate deal risks, and empower sales teams with a real-time activity feed.
  </p>

  <div>
    <img src="https://img.shields.io/badge/Vue-3-success" alt="Vue 3">
    <img src="https://img.shields.io/badge/Supabase-Realtime-green" alt="Supabase Realtime">
    <img src="https://img.shields.io/badge/n8n-Workflow_Automations-red" alt="n8n">
    <img src="https://img.shields.io/badge/AI-Gemini_2.5_Flash-blue" alt="Gemini">
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  </div>
</div>

---

## 🌟 Key Features

### 🤖 Autonomous AI Agents (n8n + Gemini)
Orbit CRM goes beyond simple data tracking. Two native AI Agents constantly work in the background:
- **Lead Qualifier Agent:** Automatically scores incoming leads from 1-10, categorizes them as Hot/Warm/Cold, and suggests immediate next actions based on the lead's profile.
- **Deal Risk Agent:** Evaluates active deals every 6 hours to identify churn risks or stalled negotiations, updating the risk level autonomously.

### ⚡ Real-Time Activity Feed
Powered by Supabase `postgres_changes`, the Activity Center provides an instant, zero-polling timeline of all team interactions, deal changes, and AI insights. Important system alerts and "Hot Leads" pop up instantly via our custom Toast notification system.

### 🔐 Enterprise-Grade Security
- **Strict Role-Based Access Control (RBAC):** Admin and Seller isolation right at the database level using Supabase Row Level Security (RLS).
- **Service Isolation:** Sensitive operations and AI Prompts happen strictly inside the internal Dockerized n8n network using `service_role` keys. The frontend remains clean and completely isolated from backend secrets.
- **Data Multi-Tenancy:** Ready for scaling with built-in tenant isolation patterns.

### 🎨 Premium Design System
- **Stunning UI/UX:** Built with a custom glassmorphism-inspired dark mode design system in Tailwind CSS.
- **Fluid Animations:** Powered by GSAP 3, every interaction—from feed updates to modal transitions—feels alive, providing a completely responsive state-of-the-art experience.

---

## 📸 Platform Walkthrough

### 1. Unified Sales Dashboard
A high-level view of your pipeline, revenue, and active opportunities.
<img src="./img/1_dashboard.png" alt="Dashboard View">

### 2. Intelligent Lead Management
Leads are scored autonomously. Notice the AI badges defining priority levels.
<img src="./img/2_leads.png" alt="Leads View">

### 3. Deal Pipeline & Risk Assessment
Kanban-style tracking of deals with real-time risk evaluations dynamically injected by the Deal Risk Agent.
<img src="./img/3_deals.png" alt="Deals View">

### 4. Company & Account Tracking
Unified view of customer organizations, linked to their deals, tasks, and historical activities.
<img src="./img/4_companies.png" alt="Companies View">

### 5. Task Management
Never miss a follow-up. Organize daily tasks directly tied to leads and deals.
<img src="./img/5_tasks.png" alt="Tasks View">

### 6. Automation Center
Admin-only hub to monitor background AI agents, check their health, and review execution logs seamlessly.
<img src="./img/6_automations.png" alt="Automation Center View">

### 7. Settings & Configuration
Complete control over user profiles, webhooks, and AI provider configurations.
<img src="./img/7_settings.png" alt="Settings View">

---

## 🏗️ Technology Stack

| Layer | Technologies Used |
|-------|------------------|
| **Frontend** | Vue 3 (Composition API), Vite 5, Vue Router 4 |
| **Styling** | Tailwind CSS 3, Custom CSS Variables |
| **Animations** | GSAP 3 |
| **Backend / Database** | Supabase (PostgreSQL, Auth, Realtime) |
| **Automation / Orchestration**| n8n (Self-hosted Docker) |
| **AI Models** | Google Gemini 2.5 Flash |

---

## 🚀 Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/bayroon10/ORBIT-CRM-AGENTS.git
cd ORBIT-CRM-AGENTS
```

### 2. Install dependencies
```bash
npm install
```

### 3. Configure Environment Variables
```bash
cp .env.example .env
```
Fill out your `.env` with your Supabase credentials and n8n webhooks:
```env
VITE_SUPABASE_URL=https://<YOUR_PROJECT>.supabase.co
VITE_SUPABASE_ANON_KEY=<YOUR_ANON_KEY>
VITE_N8N_WEBHOOK_URL=http://localhost:5678/webhook/lead-qualifier
VITE_N8N_WEBHOOK_SECRET=your_secure_secret_here
```

### 4. Start the Application
Run the frontend server (runs on port `5173` by default):
```bash
npm run dev
```

### 5. Launch n8n Locally
To run the automation workflows locally:
```bash
docker-compose up -d
```

---

## 📚 Documentation
For deeper technical insights, please refer to our internal documentation:
- [Architecture & Data Model](./ARCHITECTURE.md)
- [Security Model & Threat Mitigation](./SECURITY.md)
- [Agent Specifications](./AGENTS.md)
- [Changelog](./CHANGELOG.md)
- [Contributing Guidelines](./CONTRIBUTING.md)

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
