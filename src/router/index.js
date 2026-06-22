import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '../lib/supabase'
import AppLayout from '../layouts/AppLayout.vue'
import AuthLayout from '../layouts/AuthLayout.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      component: AuthLayout,
      children: [{ path: '', name: 'Login', component: () => import('../views/Login.vue') }]
    },
    {
      path: '/',
      component: AppLayout,
      meta: { requiresAuth: true },
      children: [
        { path: '', name: 'Dashboard', component: () => import('../views/Dashboard.vue') },
        { path: 'leads', name: 'Leads', component: () => import('../views/Leads.vue') },
        { path: 'leads/:id', name: 'LeadDetail', component: () => import('../views/LeadDetail.vue') },
        { path: 'deals', name: 'Deals', component: () => import('../views/Deals.vue') },
        { path: 'deals/:id', name: 'DealDetail', component: () => import('../views/DealDetail.vue') },
        { path: 'companies', name: 'Companies', component: () => import('../views/Companies.vue') },
        { path: 'companies/:id', name: 'CompanyDetail', component: () => import('../views/CompanyDetail.vue') },
        { path: 'tasks', name: 'Tasks', component: () => import('../views/Tasks.vue') },
        { path: 'quotes', name: 'Quotes', component: () => import('../views/Quotes.vue') },
        { path: 'quotes/:id', name: 'QuoteDetail', component: () => import('../views/QuoteDetail.vue') },
        { path: 'sales', name: 'Sales', component: () => import('../views/Sales.vue') },
        { path: 'settings', name: 'Settings', meta: { requiresAdmin: true }, component: () => import('../views/Settings.vue') },
        { path: 'settings/users', name: 'SettingsUsers', meta: { requiresAdmin: true }, component: () => import('../views/SettingsUsers.vue') },
        { path: 'settings/providers', name: 'ProviderSettings', meta: { requiresAdmin: true }, component: () => import('../views/ProviderSettingsView.vue') },
        { path: 'activity', name: 'Activity', component: () => import('../views/Activity.vue') },
        { path: 'automation-center', name: 'AutomationCenter', meta: { requiresAdmin: true }, component: () => import('../views/AutomationCenterView.vue') }
      ]
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
      redirect: { name: 'Dashboard' }
    }
  ]
})

router.beforeEach(async (to) => {
  try {
    const { data, error } = await supabase.auth.getSession()
    if (error) throw error

    const session = data?.session ?? null
    const role = session?.user?.user_metadata?.role || 'seller'

    if (to.meta.requiresAuth && !session) {
      return { name: 'Login', query: { redirect: to.fullPath } }
    }
    
    // RBAC: Block non-admins from accessing requiresAdmin routes
    if (to.meta.requiresAdmin && role !== 'admin' && role !== 'superadmin') {
      return { name: 'Dashboard' }
    }

    if (to.name === 'Login' && session) {
      return { name: 'Dashboard' }
    }
  } catch (error) {
    console.error('[Router Auth Error]:', error)
    if (to.meta.requiresAuth) {
      return { name: 'Login', query: { redirect: to.fullPath } }
    }
  }
})

export default router

