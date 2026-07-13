---
name: verificar-actor
description: Aplica la compuerta de verificación E3 (lead → confirmado) a un candidato — selector, lead o actor — de recon.db, antes de tratarlo como del objetivo, marcarlo 'confirmado' o citarlo en el dossier. Exige fuente fuerte/débil, corroboración de 2ª fuente independiente, descarte de homónimo, custodia (SHA-256/WACZ) y registro del motivo. Úsalo en el caso Coderise/Holberton/Astorga/Aestro siempre que haya que decidir si un hallazgo es real, o cuando el usuario pida "verificar", "confirmar" o "está chequeado" un actor/cuenta/selector. Es la única puerta que asciende algo de recon.db a evidencia.db.
---

# /verificar-actor <candidato> [--tipo persona|entidad|infra]

Eres `investigador-judicial` (líder de E3; co-líder `osint-usa` para la pata gringa) operando la **compuerta E3** del `osint/docs/marco_recon.md`. Checklist completa: `osint/docs/checklists/verificacion_selector.md`. **Si dudás, NO pasa.**

## Pasos
1. **Resolver** el candidato en recon.db (`/run/media/linux/legal_vault/osint/investigacion/archive/recon.db`): traer `valor`, `valor_norm`, `origen`, `recon_run`, estado actual y documentos FTS asociados.
2. **Reunir fuentes** vinculadas; clasificar cada una **FUERTE** (registro oficial primario — RUES/SIC/Sunbiz/IRS/Rama, escritura, pagaré, doc del expediente, captura con custodia) o **DÉBIL** (SOCMINT, prensa secundaria, caché, dorking, inferencia de infra).
3. **Umbral de corroboración:** 1 FUERTE sin señal de homónimo → puede pasar. Solo DÉBILES → **≥2 fuentes independientes**. Afirmación de rol/clasificación ("controla", "fachada") → nunca solo débil.
4. **Descarte de homónimo (obligatorio si persona):** buscar identificador discriminante (cédula/NIT, fecha nac., email, teléfono, radicado, dirección). Sin discriminante → tope en "posible coincidencia", NO se confirma identidad. Delegar a `osint-colombia`/`osint-usa` para 2ª fuente registral si hace falta.
5. **Independencia/frescura:** confirmar que las fuentes no derivan de la misma raíz; registrar fecha de consulta.
6. **Veredicto:** CONFIRMADO / LEAD (insuficiente) / DESCARTADO.
7. **Si CONFIRMADO:** delegar a `forense-digital` la **custodia** (WACZ + SHA-256), crear/enlazar el registro en **evidencia.db** (única puerta de escritura a custodia), y marcar el selector apto para la vista `semillas` (realimentación a E1).
8. **Escribir el motivo y auditoría** en recon.db SIEMPRE: `estado`, `fuente_fuerte` (sí/no), `n_fuentes`, `homonimo_descartado` (sí/no/N-A), `motivo`, `verificado_por`, `fecha`.

## No hace
- No escribe en el dossier (eso es `/perfil-actor`).
- No borra leads descartados (conserva la traza).
- No usa cuentas personales de William (OPSEC).
- No confirma identidad por nombre solo.
