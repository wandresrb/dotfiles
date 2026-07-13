---
description: Auditoría NLD ad-hoc trasversal a proyectos. Invoca el agent quality-reviewer (~/.claude/agents/) sobre el scope dado. Read-only. Para proyectos con agent propio (ej. Midland nld-reviewer), preferí el específico vía /nld-audit u homólogo.
---

Audita un crate / path / diff contra el bar NLD trasversal (5 ejes: lock-free, zero-copy, SIMD, HPC, primitiva correcta) y opcionalmente ergonomía idiomática.

**Uso**:
- `/quality-audit` — audita el package detectado en `pwd` (Rust crate, Go module, etc.). Scope: diff `main...HEAD`.
- `/quality-audit <crate-or-package-name>` — resolución por nombre.
- `/quality-audit <path>` — path explícito (file o directory).
- `/quality-audit ... --ergonomic` — agrega audit ergonómico Rust idiomático (de `~/.claude/skills/rust-ergonomic-review/SKILL.md`).
- `/quality-audit ... --full` — audita HEAD completo, no solo diff. Útil para snapshot de deuda inicial.

**Workflow**:

1. **Detectar si hay agent project-specific** que extiende `quality-reviewer`:
   - Si existe `<repo>/.claude/agents/<name>.md` cuya description menciona "extends quality-reviewer" o "extends code-quality-bar", informar al usuario y sugerir usar el específico.
   - Para Midland: `/nld-audit` es la versión Midland-específica. Para otros proyectos: ver listado de skills al iniciar sesión.

2. **Resolver scope**:
   - Sin args: detectar package desde `pwd` upward (Cargo.toml, go.mod, package.json, etc.).
   - Crate/package name: resolver a path filesystem.
   - Path: validar que esté bajo path de production (no `target/`, no `vendor/`, no `node_modules/`).

3. **Identificar archivos**:
   - Default: `git diff --name-only main...HEAD -- <path>`.
   - Si `--full`: `git ls-files <path>` filtrado a source code.

4. **Invocar agent**:
   ```
   Task(
     subagent_type="quality-reviewer",
     prompt="Auditar archivos: <lista>. Bar NLD 5 ejes (lock-free / zero-copy / SIMD / HPC / primitiva). [Si --ergonomic: + ergonomía idiomática Rust.] Project skill detection: <existing-skill-name | none>."
   )
   ```

5. **Reportar** output del agent + recomendación final basada en Summary verdict.

**Restricciones**: read-only. No commits, no modificaciones. Solo lectura + reporte.

**Cuándo correr**:
- Pre-merge sobre branch `claude/*` o feature branches.
- On-demand cuando dudás si un cambio cumple el bar.
- Después de un cambio en API público para validar antes de release.

**Cuándo NO correr**:
- Sobre `target/`, `vendor/`, `node_modules/`, `*.generated.*` — son outputs build, NLD no aplica.
- Sobre código explícitamente POC con plan de transición vigente — el POC tiene su propio gate (métrica + deadline).
