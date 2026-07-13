---
description: Identifica blast radius cross-tree cuando un type/trait/symbol de una librería core cambia. Read-only. Output = lista path:line de consumers afectados. Trasversal a proyectos. Project-specific commands (ej. Midland /nld-cascade) pueden parametrizar paths de búsqueda; este es el genérico.
---

Cuando un cambio en una librería interna del workspace introduce, modifica, o renombra un item público, identificá todos los consumers cross-tree que podrían necesitar adaptarse.

**Uso**:
- `/quality-cascade <symbol>` — busca el symbol exacto (case-sensitive) en consumers del workspace. Ej: `/quality-cascade Mmap`, `/quality-cascade Arena`.
- `/quality-cascade <path>` — toma archivo modificado, infiere items `pub` que toca, busca cada uno.
- `/quality-cascade <symbol> --eje <N>` — filtra consumers por eje NLD en riesgo (1-5).
- `/quality-cascade <symbol> --roots "path1 path2 path3"` — limita búsqueda a roots dados (default: workspace top-level dirs excluyendo el de origen).

**Workflow**:

1. **Resolver symbol(s)**:
   - Symbol explícito: usar literal.
   - Path: extraer items `pub`/`export` con `grep -nE '^(pub|export)[[:space:]]+'`.

2. **Detectar workspace roots** (auto si no se da `--roots`):
   - Rust: leer `Cargo.toml` workspace.members o subdirs con `Cargo.toml` propio.
   - Go: `go.work` o subdirs con `go.mod`.
   - Multi-language: top-level dirs excluyendo `target/`, `vendor/`, `node_modules/`, `.git/`.
   - Excluir el crate/módulo de origen (no buscar en sí mismo).

3. **Buscar consumers cross-tree**:
   ```bash
   for symbol in <lista>; do
     for root in <roots>; do
       grep -rn "use .*::${symbol}\|::${symbol}\|${symbol}<\|${symbol}::" "$root" \
         --include='*.rs' --include='*.go' --include='*.zig' --include='*.c' --include='*.h'
     done
   done
   ```

4. **Por cada hit**, clasificar:
   - **import**: `use foo::Symbol`
   - **type-bound**: `<T: Symbol>` o `impl Symbol`
   - **function-call**: `Symbol::method()` o `symbol_fn()`
   - **pattern-match**: `match x { Symbol::Variant => ... }`
   - **derive**: `#[derive(..., Symbol, ...)]`

5. **Sugerir riesgo NLD por tipo de uso**:
   - Cambio lifetime → eje 2 (zero-copy) en riesgo
   - Cambio firma `&` → `&mut` o concurrencia → eje 1 (lock-free)
   - Cambio en hot-path API → eje 4 (HPC)
   - Symbol renombrado → import break (no NLD-eje, pero sí breaking)

**Output format**:

```markdown
## /quality-cascade — blast radius

**Symbol(s)**: `<lista>`
**Roots searched**: N
**Consumers cross-tree**: M hits en K files / L workspace members

### Hits por miembro

#### <root1>/
- `<root1>/path/file.ext:42` — import — sugerencia: revisar lifetime si cambia

### Sugerencias por eje en riesgo
- Eje 2: N consumers tocan lifetime/borrow
- Eje 1: K consumers en hot path
- Sin riesgo NLD: M consumers (uso pasivo)

### Verdict
- **Cambio aditivo** → low risk
- **Cambio en signature/lifetime** → REVIEW_REQUIRED en M consumers
- **Symbol removido** → BREAKING; consumers requieren migración
```

**Restricciones**: read-only. Solo Read + Grep + Bash. NO modifica nada.

**Cuándo correr**:
- Después de cambio en API pública de una librería core del workspace.
- Antes de mergear branch que toca `core/`/`shared/`/`common/` para anticipar impacto.
- Como input a `/quality-audit` corrido sobre los crates consumers identificados.

**Out of scope**:
- NO actualiza consumers automáticamente.
- NO toca paths excluidos (`target/`, `vendor/`, etc.).
