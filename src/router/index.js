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
        { path: 'tasks', name: 'Tasks', component: () => import('../views/Tasks.vue') },
        { path: 'quotes', name: 'Quotes', component: () => import('../views/Quotes.vue') },
        { path: 'quotes/new', name: 'QuoteForm', component: () => import('../views/QuoteForm.vue') },
        { path: 'sales', name: 'Sales', component: () => import('../views/Sales.vue') },
        { path: 'settings', name: 'Settings', component: () => import('../views/Settings.vue') },
        { path: 'settings/users', name: 'SettingsUsers', component: () => import('../views/SettingsUsers.vue') },
        { path: 'activity', name: 'Activity', component: () => import('../views/Activity.vue') }
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

    if (to.meta.requiresAuth && !session) {
      return { name: 'Login', query: { redirect: to.fullPath } }
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

