# Migraciones de Base de Datos

Este directorio contiene scripts SQL para evolucionar la base de datos de forma controlada y versionada.

## Estructura

- `001_*.sql`: Primera migración. Añade la función `get_masked_credential`.

## Cómo aplicar una migración

1. Abre el **SQL Editor** en tu dashboard de Supabase.
2. Copia el contenido del archivo `.sql` que deseas aplicar.
3. Pégalo en el editor y haz clic en **Run**.

## Buenas Prácticas

- Cada cambio en la base de datos debe tener su propio archivo de migración.
- Nombra los archivos con un número secuencial (001, 002, ...) seguido de una descripción clara.
- Las migraciones deben ser **idempotentes** (pueden ejecutarse varias veces sin romper nada).
- Documenta cada migración con un comentario al inicio indicando qué hace.

## Ejemplo de nombre de archivo

`002_add_ai_summary_to_leads.sql`