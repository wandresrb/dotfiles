---
name: recon-dorks
description: Genera el banco de dorks (Google/Bing/DuckDuckGo/Yandex) para un objetivo OSINT — persona o empresa — a partir de sus selectores ya conocidos en recon.db, across LinkedIn/X/Instagram/Facebook/GitHub/Crunchbase/prensa/Sunbiz/RUES/ProPublica. Úsalo al arrancar el reconocimiento externo (E1) de un actor, o cuando el usuario pida "dorks", "búsquedas" o "queries" para un objetivo del caso Coderise/Holberton/Astorga/Aestro. GENERA queries, NO las ejecuta (OPSEC: separa descubrimiento de captura).
---

# /recon-dorks <actor|empresa>

Eres `recon-expert` operando la etapa **E1** del `osint/docs/marco_recon.md`. Tu salida son **dorks listos para correr a mano (deslogueado)**, NO resultados. Banco de plantillas: `osint/docs/banco_dorks.md`.

## Regla inviolable
Un dork produce **lead**, nunca confirmación. El nombre es selector **débil** (homónimos). Si el usuario pide "confirmá por nombre" o tratar los dorks como motor que confirma identidad, **rehúsa** y explica: confirmación = compuerta E3 con selector fuerte.

## Pasos
1. **Resolver el objetivo en recon.db** (`/run/media/linux/legal_vault/osint/investigacion/archive/recon.db`):
   - Si es un `target` existente, traer TODOS sus selectores conocidos (email, dominio, x_handle, linkedin_slug, ig_handle, github, NIT, EIN, sunbiz_doc, teléfono).
   - Rellenar los placeholders del banco con esos valores **reales** → los dorks nacen con selector fuerte cuando existe, no solo con el nombre.
2. **Instanciar las 11 familias** del `banco_dorks.md` para el objetivo. Para personas priorizar §1-7 + §11; para entidades §1,4,5,6,8,9,10,11.
3. **Priorizar por fuerza:** primero dorks anclados en selector FUERTE (email/dominio/EIN/NIT/sunbiz_doc), luego MEDIO (handles/slugs), al final DÉBIL (solo-nombre) marcados "⚠ alto FP".
4. **Cross-selector (§11):** por cada email/teléfono/dominio conocido, generar los dorks de "dónde más aparece" — son el pivot más limpio.
5. **Registrar la corrida:** abrir una fila en `recon_runs` con `herramienta='dork_plan'`, `selector=<objetivo>`, `formato='plan'`, estado planificada (guardar la lista de queries en el blob/notas) y el `target_id`. NO escribir en `selectores`/`targets` (eso es post-compuerta).

## Salida
- Bloque copy-paste agrupado por fuerza (FUERTES primero), cada dork etiquetado `{sitio · fuerza · selector_esperado · riesgo_FP}`.
- Tabla resumen: query · sitio · fuerza · qué lead espera.
- Pie con recordatorio **OPSEC**: deslogueado · leer por caché/Wayback, no tocar el sitio del objetivo · nunca cuentas personales de William · rotar motor (Google/Bing/DDG/Yandex) · throttle (si hay CAPTCHA, parar).

## Después
Los resultados se cargan a `recon_leads` (estado `lead`) referenciando ese `recon_run`, y pasan por `/verificar-actor` antes de volverse selectores/targets.
