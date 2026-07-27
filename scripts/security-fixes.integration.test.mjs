/**
 * scripts/security-fixes.integration.test.mjs
 *
 * Test de integración para validar la resolución de vulnerabilidades de seguridad:
 * - SEC-VULN-01: Eliminación de la política permiisiva de UPDATE en `automations` para vendedores.
 * - SEC-VULN-02: Presencia de `is_admin_or_higher()` en WITH CHECK para `leads` y `deals`.
 * - SEC-VULN-03: Confirmación de que `ventas` es una tabla legacy sin políticas ni referencias frontend.
 * - SEC-VULN-04: Verificación de columna `n8n_webhook_url` en `workspace_settings` y lectura dinámica en `invoke_n8n_webhook()`.
 *
 * Ejecutar con: node --test scripts/security-fixes.integration.test.mjs
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import pg from 'pg';
import { assertLocalConnection } from './lib/local-guard.mjs';

const LOCAL_POSTGRES_URL = process.env.SUPABASE_DB_URL || 'postgresql://postgres:postgres@127.0.0.1:54322/postgres';

async function getPgClient() {
  assertLocalConnection(LOCAL_POSTGRES_URL);
  const client = new pg.Client({ connectionString: LOCAL_POSTGRES_URL });
  await client.connect();
  return client;
}

test('SEC-VULN-01: automations no permite UPDATE a usuarios no-admin', async () => {
  const client = await getPgClient();
  try {
    const res = await client.query(`
      SELECT policyname, cmd, qual, with_check
      FROM pg_policies
      WHERE tablename = 'automations';
    `);
    const policies = res.rows;

    // Confirmar que 'Allow authenticated update automations' ya NO existe
    const updatePolicy = policies.find((p) => p.policyname === 'Allow authenticated update automations');
    assert.equal(updatePolicy, undefined, 'La política permisa de UPDATE "Allow authenticated update automations" fue eliminada');

    // Confirmar que la única política para admin existe
    const adminPolicy = policies.find((p) => p.policyname === 'Automations admin only');
    assert.ok(adminPolicy, 'Existe la política "Automations admin only" para gestionar automations');
  } finally {
    await client.end();
  }
});

test('SEC-VULN-02: leads y deals incluyen is_admin_or_higher() en WITH CHECK', async () => {
  const client = await getPgClient();
  try {
    const leadsRes = await client.query(`
      SELECT policyname, with_check
      FROM pg_policies
      WHERE tablename = 'leads' AND policyname = 'User can manage own leads';
    `);
    assert.equal(leadsRes.rows.length, 1, 'Debe existir la política User can manage own leads');
    const leadsWithCheck = leadsRes.rows[0].with_check || '';
    assert.ok(leadsWithCheck.includes('is_admin_or_higher'), 'leads WITH CHECK incluye is_admin_or_higher()');

    const dealsRes = await client.query(`
      SELECT policyname, with_check
      FROM pg_policies
      WHERE tablename = 'deals' AND policyname = 'User can manage own deals';
    `);
    assert.equal(dealsRes.rows.length, 1, 'Debe existir la política User can manage own deals');
    const dealsWithCheck = dealsRes.rows[0].with_check || '';
    assert.ok(dealsWithCheck.includes('is_admin_or_higher'), 'deals WITH CHECK incluye is_admin_or_higher()');
  } finally {
    await client.end();
  }
});

test('SEC-VULN-03: confirmación de tabla legacy ventas', async () => {
  const client = await getPgClient();
  try {
    const res = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = 'ventas';
    `);
    assert.equal(res.rows.length, 1, 'La tabla legacy ventas existe en la base de datos');

    const policiesRes = await client.query(`
      SELECT policyname
      FROM pg_policies
      WHERE tablename = 'ventas';
    `);
    assert.equal(policiesRes.rows.length, 0, 'La tabla legacy ventas no tiene políticas RLS expuestas');
  } finally {
    await client.end();
  }
});

test('SEC-VULN-04: workspace_settings contiene n8n_webhook_url y invoke_n8n_webhook() la consulta dinámicamente', async () => {
  const client = await getPgClient();
  try {
    const colRes = await client.query(`
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = 'workspace_settings' AND column_name = 'n8n_webhook_url';
    `);
    assert.equal(colRes.rows.length, 1, 'La tabla workspace_settings tiene la columna n8n_webhook_url');

    const funcRes = await client.query(`
      SELECT prosrc
      FROM pg_proc
      WHERE proname = 'invoke_n8n_webhook';
    `);
    assert.equal(funcRes.rows.length, 1, 'La función invoke_n8n_webhook existe');
    const src = funcRes.rows[0].prosrc || '';
    assert.ok(src.includes('workspace_settings'), 'invoke_n8n_webhook() lee dinámicamente de workspace_settings');
  } finally {
    await client.end();
  }
});
