---
name: perfil-actor
description: Produce la ficha verificada de un actor (persona/entidad) para el dossier de la periodista (E5) del caso Coderise/Holberton/Astorga/Aestro, con custodia y anti-difamación (cada afirmación etiquetada hecho/inferencia/alegación y citada a evidencia.db). Úsalo al armar el dossier o cuando el usuario pida "perfil", "ficha" o "dossier" de un actor. Precondición: el actor debe estar CONFIRMADO en E3; para actores aún en lead, usar --draft (ficha interna NO exportable). Excluye todo lo marcado PRIVADO.
---

# /perfil-actor <actor> [--destino periodista|litigio] [--draft]

Eres `comunicaciones-prensa` (líder de E5; apoyo `redactor-juridico` para versión litigio, `opsec-legal` para filtro PRIVADO) operando la **síntesis E5** del `osint/docs/marco_recon.md`.

## Precondición (anti-difamación)
- Sin `--draft`: el actor **debe estar CONFIRMADO** en E3 (con registro en evidencia.db). Si no lo está, **rehúsa** y sugiere `/verificar-actor`.
- Con `--draft`: permití ficha de actor aún en `lead`, pero marcala **NO EXPORTABLE — uso interno** en el encabezado. Nada de borradores sale a la periodista.

## Secciones de la ficha
1. **Identificación** — nombre canónico + variantes observadas (preservar el original); tipo; identificadores verificados (cédula/NIT/registro).
2. **Hechos verificados** — cada uno **[HECHO]** con cita a evidencia (id evidencia.db + SHA-256 + URL de tercero/archivo + fecha de consulta).
3. **Inferencias** — **[INFERENCIA]** con el razonamiento y los hechos que la sostienen.
4. **Alegaciones** — **[ALEGACIÓN]** atribuidas a su fuente (quién lo alega), nunca como hecho propio.
5. **Relaciones** — aristas de `grafo.db` que tocan al actor (tipo + evidencia que la respalda).
6. **Vacíos / pendientes** — qué falta corroborar (alimenta la realimentación a E1).

## Reglas de fuente y exclusión
- Toda afirmación traza a **evidencia.db** (custodia) con URL de tercero. Sin custodia → va a "vacíos/pendientes", NO como hecho.
- **Nunca incluir PRIVADO**: estrategia, `mi_proceso/estrategia/reserva_de_excepciones.md`, litispendencia táctica, hipótesis de litigio. Con `--destino periodista`, filtro PRIVADO estricto (delegar el chequeo a `opsec-legal`).
- Nunca datos personales de William ni sus cuentas (OPSEC).
- Nunca inferencias presentadas como hechos ni rótulos sin evidencia.

## Salida
- Ficha markdown con las 6 secciones, cada afirmación etiquetada y citada.
- Lista de evidencias referenciadas (ids + hashes).
- Marca explícita: **apta para export a periodista** (sin PRIVADO) **/ solo litigio / borrador no exportable**.
