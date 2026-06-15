-- ==============================================================================
-- PROYECTO: MVP Portfolio - Análisis de Ventas (Estilo Bosch Rexroth)
-- DESCRIPCIÓN: Esquema PostgreSQL mínimo y profesional para análisis en Power BI
-- ==============================================================================

-- 1. TIPOS ENUMERADOS (ENUMS)
-- Mantienen la integridad de los datos evitando errores de tipeo en estados clave
CREATE TYPE estado_oportunidad AS ENUM (
    'lead',
    'contactado',
    'cotizado',
    'negociacion',
    'ganado',
    'perdido'
);

CREATE TYPE estado_cotizacion AS ENUM (
    'borrador',
    'enviada',
    'aceptada',
    'rechazada',
    'expirada'
);

CREATE TYPE prioridad_oportunidad AS ENUM (
    'baja',
    'media',
    'alta'
);


-- 2. TABLAS DIMENSIONALES (Catálogos)

CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255) NOT NULL,
    industria VARCHAR(100),
    region VARCHAR(100),
    tamano_empresa VARCHAR(50),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vendedores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    zona VARCHAR(100),
    fecha_ingreso DATE NOT NULL,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- 3. TABLAS DE HECHOS (Transaccionales)

CREATE TABLE oportunidades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    vendedor_id UUID NOT NULL REFERENCES vendedores(id) ON DELETE RESTRICT,
    nombre_oportunidad VARCHAR(255) NOT NULL,
    estado estado_oportunidad NOT NULL DEFAULT 'lead',
    monto_estimado DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    probabilidad_cierre INTEGER CHECK (probabilidad_cierre >= 0 AND probabilidad_cierre <= 100),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre_estimada DATE,
    fecha_cierre_real DATE,
    dias_sin_actividad INTEGER DEFAULT 0, -- NOTA: Idealmente esto es un campo calculado en una vista, pero se deja materializado por requerimiento.
    prioridad prioridad_oportunidad DEFAULT 'media'
);

CREATE TABLE cotizaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    oportunidad_id UUID NOT NULL REFERENCES oportunidades(id) ON DELETE CASCADE,
    numero_cotizacion VARCHAR(50) UNIQUE NOT NULL,
    monto_cotizado DECIMAL(12, 2) NOT NULL,
    fecha_emision DATE NOT NULL,
    fecha_validez DATE,
    estado_cotizacion estado_cotizacion DEFAULT 'borrador',
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    oportunidad_id UUID NOT NULL REFERENCES oportunidades(id) ON DELETE RESTRICT,
    cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE RESTRICT,
    vendedor_id UUID NOT NULL REFERENCES vendedores(id) ON DELETE RESTRICT,
    monto_venta DECIMAL(12, 2) NOT NULL,
    fecha_venta DATE NOT NULL,
    canal_venta VARCHAR(100),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE actividades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    oportunidad_id UUID NOT NULL REFERENCES oportunidades(id) ON DELETE CASCADE,
    tipo_actividad VARCHAR(50) NOT NULL, 
    descripcion TEXT,
    fecha_actividad TIMESTAMP WITH TIME ZONE NOT NULL,
    resultado TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- 4. ÍNDICES (Optimizando consultas para Power BI / Analítica)
-- Aceleran los JOINs y filtrados sobre campos clave.

CREATE INDEX idx_oportunidades_cliente_id ON oportunidades(cliente_id);
CREATE INDEX idx_oportunidades_vendedor_id ON oportunidades(vendedor_id);
CREATE INDEX idx_oportunidades_estado ON oportunidades(estado);

CREATE INDEX idx_cotizaciones_oportunidad_id ON cotizaciones(oportunidad_id);

CREATE INDEX idx_ventas_oportunidad_id ON ventas(oportunidad_id);
CREATE INDEX idx_ventas_cliente_id ON ventas(cliente_id);
CREATE INDEX idx_ventas_vendedor_id ON ventas(vendedor_id);
CREATE INDEX idx_ventas_fecha_venta ON ventas(fecha_venta); -- Muy útil para análisis temporal (Year-over-Year, MTD, YTD)

CREATE INDEX idx_actividades_oportunidad_id ON actividades(oportunidad_id);
CREATE INDEX idx_actividades_fecha_actividad ON actividades(fecha_actividad);
