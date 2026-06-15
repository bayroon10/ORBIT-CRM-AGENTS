globalThis.WebSocket = class {}
import { createClient } from '@supabase/supabase-js'
const supabaseUrl = process.env.VITE_SUPABASE_URL || 'https://kgrfhfwtcanthrymmvkb.supabase.co'
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'YOUR_SUPABASE_SERVICE_ROLE_KEY'

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

async function runSeed() {
  console.log('--- INICIANDO SEMBRADO DE DATOS QA ---')

  const testEmails = [
    'superadmin@orbitcrm.test',
    'admin@orbitcrm.test',
    'seller1@orbitcrm.test',
    'seller2@orbitcrm.test'
  ]

  try {
    // 1. Limpieza de usuarios de prueba anteriores en auth.users
    console.log('1. Limpiando usuarios de prueba anteriores...')
    const { data: usersData, error: listError } = await supabase.auth.admin.listUsers()
    if (listError) throw listError

    for (const u of usersData.users) {
      if (testEmails.includes(u.email)) {
        console.log(`   Eliminando usuario: ${u.email}`)
        await supabase.auth.admin.deleteUser(u.id)
      }
    }

    // 2. Limpieza de datos transaccionales QA anteriores usando IDs exactos (evita fallos de ilike en UUIDs)
    console.log('2. Limpiando registros de prueba anteriores en la base de datos...')
    
    const activityIds = [
      '94000000-0000-0000-0000-000000000001',
      '94000000-0000-0000-0000-000000000002',
      '94000000-0000-0000-0000-000000000003'
    ]
    const taskIds = [
      '93000000-0000-0000-0000-000000000001',
      '93000000-0000-0000-0000-000000000002',
      '93000000-0000-0000-0000-000000000003'
    ]
    const dealIds = [
      '92000000-0000-0000-0000-000000000001',
      '92000000-0000-0000-0000-000000000002',
      '92000000-0000-0000-0000-000000000003',
      '92000000-0000-0000-0000-000000000004',
      '92000000-0000-0000-0000-000000000005'
    ]
    const leadIds = [
      '91000000-0000-0000-0000-000000000001',
      '91000000-0000-0000-0000-000000000002',
      '91000000-0000-0000-0000-000000000003',
      '91000000-0000-0000-0000-000000000004',
      '91000000-0000-0000-0000-000000000005'
    ]
    const companyIds = [
      '90000000-0000-0000-0000-000000000001',
      '90000000-0000-0000-0000-000000000002',
      '90000000-0000-0000-0000-000000000003'
    ]

    await supabase.from('activities').delete().in('id', activityIds)
    await supabase.from('tasks').delete().in('id', taskIds)
    await supabase.from('deals').delete().in('id', dealIds)
    await supabase.from('leads').delete().in('id', leadIds)
    await supabase.from('companies').delete().in('id', companyIds)

    // 3. Crear Usuarios de Prueba en Auth
    console.log('3. Creando usuarios de prueba en Auth...')
    const usersToCreate = [
      {
        email: 'superadmin@orbitcrm.test',
        password: 'QA_pass_2026!',
        full_name: 'Super Administrador',
        role: 'admin'
      },
      {
        email: 'admin@orbitcrm.test',
        password: 'QA_pass_2026!',
        full_name: 'Administrador General',
        role: 'admin'
      },
      {
        email: 'seller1@orbitcrm.test',
        password: 'QA_pass_2026!',
        full_name: 'Vendedor Estrella 1',
        role: 'seller'
      },
      {
        email: 'seller2@orbitcrm.test',
        password: 'QA_pass_2026!',
        full_name: 'Vendedor Estrella 2',
        role: 'seller'
      }
    ]

    for (const u of usersToCreate) {
      console.log(`   Creando usuario auth: ${u.email}`)
      const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
        email: u.email,
        password: u.password,
        email_confirm: true,
        user_metadata: {
          full_name: u.full_name,
          role: u.role
        }
      })
      if (createError) throw createError
      
      const userId = newUser.user.id
      console.log(`   Usuario creado con UUID: ${userId}. Registrando perfil...`)
      
      // Hacemos upsert en profiles de manera defensiva
      const { error: profileError } = await supabase
        .from('profiles')
        .upsert({ id: userId, role: u.role, full_name: u.full_name })
      
      if (profileError) throw profileError
      
      // Guardar UUIDs de sellers creados dinámicamente
      if (u.email === 'seller1@orbitcrm.test') {
        u.resolvedId = userId
      } else if (u.email === 'seller2@orbitcrm.test') {
        u.resolvedId = userId
      }
    }

    const seller1Id = usersToCreate.find(u => u.email === 'seller1@orbitcrm.test').resolvedId
    const seller2Id = usersToCreate.find(u => u.email === 'seller2@orbitcrm.test').resolvedId

    // 4. Insertar Empresas (Companies)
    console.log('4. Insertando empresas semilla...')
    const { error: compErr } = await supabase.from('companies').insert([
      { id: '90000000-0000-0000-0000-000000000001', name: 'QA Tech Solutions', industry: 'Tecnología', website: 'https://qa-tech.test', owner_id: seller1Id },
      { id: '90000000-0000-0000-0000-000000000002', name: 'QA Build & Construct', industry: 'Construcción', website: 'https://qa-build.test', owner_id: seller2Id },
      { id: '90000000-0000-0000-0000-000000000003', name: 'QA Food & Dairy', industry: 'Alimentos', website: 'https://qa-food.test', owner_id: null }
    ])
    if (compErr) throw compErr

    // 5. Insertar Leads (Prospectos)
    console.log('5. Insertando leads semilla...')
    const { error: leadsErr } = await supabase.from('leads').insert([
      {
        id: '91000000-0000-0000-0000-000000000001',
        full_name: 'Juan Pérez (S1)',
        email: 'jperez@qa-tech.test',
        phone: '+56 9 1111 2222',
        source: 'web',
        status: 'nuevo',
        owner_id: seller1Id,
        company_id: '90000000-0000-0000-0000-000000000001'
      },
      {
        id: '91000000-0000-0000-0000-000000000002',
        full_name: 'Ana María Latorre (S1)',
        email: 'amlatorre@qa-tech.test',
        phone: '+56 9 1111 3333',
        source: 'manual',
        status: 'calificado',
        owner_id: seller1Id,
        company_id: '90000000-0000-0000-0000-000000000001'
      },
      {
        id: '91000000-0000-0000-0000-000000000003',
        full_name: 'Carlos Gómez (S2)',
        email: 'cgomez@qa-build.test',
        phone: '+56 9 2222 4444',
        source: 'webhook',
        status: 'contactado',
        owner_id: seller2Id,
        company_id: '90000000-0000-0000-0000-000000000002'
      },
      {
        id: '91000000-0000-0000-0000-000000000004',
        full_name: 'Sofía Aravena (S2)',
        email: 'saravena@qa-build.test',
        phone: '+56 9 2222 5555',
        source: 'web',
        status: 'nuevo',
        owner_id: seller2Id,
        company_id: '90000000-0000-0000-0000-000000000002'
      },
      {
        id: '91000000-0000-0000-0000-000000000005',
        full_name: 'Prospecto Entrante',
        email: 'info@qa-food.test',
        phone: '+56 9 3333 6666',
        source: 'web',
        status: 'nuevo',
        owner_id: null,
        company_id: '90000000-0000-0000-0000-000000000003'
      }
    ])
    if (leadsErr) throw leadsErr

    // 6. Insertar Oportunidades (Deals)
    console.log('6. Insertando deals semilla...')
    const { error: dealsErr } = await supabase.from('deals').insert([
      {
        id: '92000000-0000-0000-0000-000000000001',
        title: 'Compra Servidores Cloud',
        value: 15000.00,
        stage: 'prospecto',
        lead_id: '91000000-0000-0000-0000-000000000001',
        owner_id: seller1Id
      },
      {
        id: '92000000-0000-0000-0000-000000000002',
        title: 'Licencias Orbit Pro',
        value: 5000.00,
        stage: 'cotizado',
        lead_id: '91000000-0000-0000-0000-000000000002',
        owner_id: seller1Id
      },
      {
        id: '92000000-0000-0000-0000-000000000003',
        title: 'Consultoría Especializada (Ganada)',
        value: 25000.00,
        stage: 'ganado',
        lead_id: '91000000-0000-0000-0000-000000000002',
        owner_id: seller1Id
      },
      {
        id: '92000000-0000-0000-0000-000000000004',
        title: 'Instalación Estructura Metálica',
        value: 350000.00,
        stage: 'negociando',
        lead_id: '91000000-0000-0000-0000-000000000003',
        owner_id: seller2Id
      },
      {
        id: '92000000-0000-0000-0000-000000000005',
        title: 'Reparación Andamios (Perdida)',
        value: 12000.00,
        stage: 'perdido',
        lead_id: '91000000-0000-0000-0000-000000000004',
        owner_id: seller2Id
      }
    ])
    if (dealsErr) throw dealsErr

    // 7. Insertar Tareas (Tasks)
    console.log('7. Insertando tareas semilla...')
    const { error: tasksErr } = await supabase.from('tasks').insert([
      {
        id: '93000000-0000-0000-0000-000000000001',
        title: 'Llamar a Juan Pérez',
        due_date: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        status: 'pendiente',
        lead_id: '91000000-0000-0000-0000-000000000001',
        deal_id: '92000000-0000-0000-0000-000000000001',
        assigned_to: seller1Id
      },
      {
        id: '93000000-0000-0000-0000-000000000002',
        title: 'Enviar cotización formal',
        due_date: new Date(Date.now() + 1 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        status: 'pendiente',
        lead_id: '91000000-0000-0000-0000-000000000002',
        deal_id: '92000000-0000-0000-0000-000000000002',
        assigned_to: seller1Id
      },
      {
        id: '93000000-0000-0000-0000-000000000003',
        title: 'Inspección en Terreno',
        due_date: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        status: 'pendiente',
        lead_id: '91000000-0000-0000-0000-000000000003',
        deal_id: '92000000-0000-0000-0000-000000000004',
        assigned_to: seller2Id
      }
    ])
    if (tasksErr) throw tasksErr

    // 8. Insertar Actividades (Activities)
    console.log('8. Insertando actividades semilla...')
    const { error: actsErr } = await supabase.from('activities').insert([
      {
        id: '94000000-0000-0000-0000-000000000001',
        type: 'webhook_recibido',
        description: 'Prospecto Juan Pérez ingresado de formulario web.',
        lead_id: '91000000-0000-0000-0000-000000000001',
        created_at: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString()
      },
      {
        id: '94000000-0000-0000-0000-000000000002',
        type: 'correo_enviado',
        description: 'Correo de seguimiento y presentación enviado a Ana María.',
        lead_id: '91000000-0000-0000-0000-000000000002',
        created_at: new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString()
      },
      {
        id: '94000000-0000-0000-0000-000000000003',
        type: 'llamada_realizada',
        description: 'Llamada comercial inicial para coordinar inspección con Carlos.',
        lead_id: '91000000-0000-0000-0000-000000000003',
        created_at: new Date(Date.now() - 30 * 60 * 1000).toISOString()
      }
    ])
    if (actsErr) throw actsErr

    console.log('--- ¡DATOS DE PRUEBA QA SEMBRADOS EXITOSAMENTE! ---')
  } catch (error) {
    console.error('ERROR CRÍTICO AL EJECUTAR EL SEED QA:', error)
  }
}

runSeed()
