import { test, expect } from '@playwright/test'
import { loginAs } from './fixtures/login.js'

test.describe('Lead detail AI score zero', () => {
  test('renderiza Sales Intelligence cuando ai_score es 0', async ({ page }) => {
    const email = process.env.E2E_SELLER_EMAIL
    const password = process.env.E2E_SELLER_PASSWORD
    const leadId = 'lead-ai-score-zero'

    await loginAs(page, { email, password })

    await page.route(`**/rest/v1/profiles*`, async (route) => {
      if (route.request().method() !== 'GET') return route.continue()
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ role: 'seller' }),
      })
    })

    await page.route(`**/rest/v1/leads*`, async (route) => {
      if (route.request().method() !== 'GET') return route.continue()
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: leadId,
          full_name: 'Lead Score Cero',
          email: 'scorecero@example.com',
          phone: '+56 9 1111 2222',
          status: 'nuevo',
          source: 'Web',
          created_at: '2026-07-29T12:00:00Z',
          company_id: 'company-1',
          ai_score: 0,
          ai_category: 'Cold',
          ai_summary: 'Lead con score cero para validar rendering.',
          ai_next_step: 'Hacer seguimiento manual.',
          ai_analyzed_at: '2026-07-29T12:05:00Z',
          companies: { name: 'Acme Spa' },
        }),
      })
    })

    await page.route(`**/rest/v1/activities*`, async (route) => {
      if (route.request().method() !== 'GET') return route.continue()
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      })
    })

    await page.route(`**/rest/v1/deals*`, async (route) => {
      if (route.request().method() !== 'GET') return route.continue()
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      })
    })

    await page.goto(`/leads/${leadId}`)

    await expect(page.getByText('Sales Intelligence')).toBeVisible()
    await expect(page.getByText('Perfil del Prospecto')).toBeVisible()
    await expect(page.getByText('Lead con score cero para validar rendering.')).toBeVisible()
    await expect(page.getByText('Sin análisis disponible')).toHaveCount(0)
  })
})
