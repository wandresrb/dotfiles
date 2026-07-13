---
name: code-quality-bar
description: Bar de calidad NLD (Nivel Dios) operacionalizado vía clippy lints + Cargo.toml [lints] + clippy.toml. Activa este skill cuando configures un proyecto Rust nuevo (lib o workspace) o cuando edites código en projects que requieren bar trasversal (no_std, kernel-bound, embedded, freestanding userspace, librerías core). Enseña cómo configurar lints como gate compile-time, NO cómo escribir tablas en docstring.
---

# code-quality-bar — bar NLD vía lints (gate compile-time)

El bar NLD se enforce con **lints en compile-time**, no con tablas performativas en docstring. El developer afirma "Lock-free: ✓" en docstring pero el código tiene `Mutex` — clippy `disallowed-types` impide que compile.

## Workflow al configurar proyecto Rust nuevo

### Paso 1 — Crear `clippy.toml` en root

`disallowed-types` y `disallowed-methods` son la pieza más expresiva. Cubren los ejes 1 (lock-free) y 5 (primitiva correcta) directamente.

```toml
# proyecto/clippy.toml

# === Eje 1: Lock-free concurrency ===
disallowed-types = [
    { path = "std::sync::Mutex", reason = "NLD eje 1: usar atomics, seqlock, o sync primitive lock-free fast-path." },
    { path = "std::sync::RwLock", reason = "NLD eje 1: usar seqlock o epoch-based reclamation." },
    { path = "parking_lot::Mutex", reason = "NLD eje 1: external blocking primitive." },
    { path = "parking_lot::RwLock", reason = "NLD eje 1: same." },
    { path = "spin::Mutex", reason = "NLD eje 1: spin lock degrades bajo contention." },
    { path = "spin::RwLock", reason = "NLD eje 1: same." },
]

# === Eje 5: Primitiva kernel correcta (Linux) ===
disallowed-methods = [
    { path = "libc::read", reason = "NLD eje 5: usar Read trait o io_uring." },
    { path = "libc::write", reason = "NLD eje 5: usar Write trait o io_uring." },
    { path = "libc::poll", reason = "NLD eje 5: usar io_uring multishot o epoll." },
    # ... pthread/sync raw también prohibidos cuando hay alternativas modernas
]
```

**Notas críticas**:
- `disallowed-types` matchea `Mutex<T>` con cualquier `T` (path FQN sin generics).
- NO matchea primitive types (issue clippy#8079) — ese caso requiere otro approach.
- `allow-invalid` campo solo en clippy nightly; no usar en stable.

### Paso 2 — Activar lints en root `Cargo.toml`

```toml
# proyecto/Cargo.toml (workspace root)

[workspace.lints.clippy]
# Activan que clippy.toml tenga efecto.
disallowed_types = "deny"
disallowed_methods = "deny"

# === Eje 2: Zero-copy ===
redundant_clone = "deny"           # o "warn" si hay legacy
needless_collect = "deny"
unnecessary_to_owned = "deny"
clone_on_ref_ptr = "deny"
inefficient_to_string = "deny"
str_to_string = "deny"
map_clone = "deny"
unnecessary_owned_empty_strings = "deny"
unnecessary_join = "deny"

# === Eje 4: HPC features (parcial) ===
large_stack_arrays = "warn"
large_stack_frames = "warn"
recursive_format_impl = "warn"

# === Calidad general ===
unwrap_used = "warn"
expect_used = "warn"
todo = "warn"
unimplemented = "warn"
panic = "warn"
indexing_slicing = "warn"
arithmetic_side_effects = "warn"
missing_safety_doc = "warn"
undocumented_unsafe_blocks = "warn"

[workspace.lints.rust]
unsafe_op_in_unsafe_fn = "deny"  # bajar a "warn" si auto-codegen lo viola
```

### Paso 3 — Heredar en member crates

```toml
# proyecto/crates/foo/Cargo.toml

[package]
name = "foo"
# ...

[lints]
workspace = true
```

**Limitación crítica**: NO se puede mezclar `workspace = true` con lints adicionales en mismo bloque. Para overrides finos, usar `#![deny(...)]` o `#![allow(...)]` en `lib.rs` o `mod.rs`.

### Paso 4 — Override per-módulo cuando es necesario

```rust
// crates/foo/src/codegen/mod.rs
//
// Build-codegen machinery — fuera del scope NLD.
#![allow(
    clippy::disallowed_types,
    clippy::disallowed_methods,
    reason = "build machinery, no production code"
)]
```

**Cada `#[allow]` debe tener `reason = "..."` justificando**. Si no hay justificación clara, el deny estaba bien.

### Paso 5 — Recipe en `Justfile` / `Makefile` para invocar lint

```makefile
lint-quality:
    cargo clippy --workspace --no-deps --lib
```

CI corre esto en cada PR. Falla si clippy emite errores.

## Estrategia de rollout en proyecto con deuda legacy

Si el proyecto **ya tiene código** que viola los nuevos lints:

1. **Primer pase: todo en `warn`**. Comprehensión del panorama de deuda.
2. `cargo clippy --workspace --lib 2>&1 | tail -5` — ver count.
3. **Caso por caso**:
   - Fix la violación si es razonable.
   - `#[allow(clippy::X, reason = "...")]` con justificación si la violación es legítima por contexto.
   - Bajar lint a `warn` permanente si el codegen genera la violación inevitablemente.
4. **Segundo pase: flippear a `deny`** lints específicos donde el cleanup terminó.

`disallowed_types` / `disallowed_methods` van `deny` desde día 1 porque vos controlás la lista.

## Coverage honesto del bar NLD por clippy

| Eje | Cobertura clippy | Gap |
|---|---|---|
| 1. Lock-free | Alto (`disallowed-types` Mutex/RwLock/etc.) | Mutex transitivo en deps no detectado si no se importa direct. |
| 2. Zero-copy | Alto (7+ lints estables) | Clones implícitos via `.into()` no siempre detectados. |
| 3. SIMD | Bajo (clippy no analiza vectorización) | Manual + bench-driven con `cargo asm`. |
| 4. HPC features | Bajo-medio | Arena/inline-small-T son convención, no lint. Project-specific tools si necesario. |
| 5. Primitiva | Alto (`disallowed-methods` configurable) | Lista a mantener manual; routine semanal audita libc::* aparecidos. |

## Cuándo NO usar este skill

- **Aplicaciones puras (no librería)** donde no hay API pública que protejas. clippy útil pero el bar NLD no aplica con la misma fuerza.
- **Código one-shot** (scripts, migrations). Innecesario.
- **POC explícito en transición** — el código POC tiene su propio gate (métrica + deadline), no el bar.

## Anti-patterns trasversales (los lints atrapan)

- `Mutex<HotState>` en path crítico → eje 1 deny via disallowed-types.
- `pub fn read(&self) -> Vec<u8>` (clone-out implícito) → eje 2 atrapa via `unnecessary_to_owned` cuando hay alternativa.
- Loop sobre buffer grande sin verificar vectorización → eje 3 NO atrapado por clippy; manual.
- Allocator default sobre patrón conocido → eje 4 NO atrapado; convención.
- `read(2)`/`write(2)` raw cuando hay io_uring → eje 5 deny via disallowed-methods.

## Skill complementario: `rust-ergonomic-review`

Para audit de **APIs human-facing** (lifetimes que no contagian ruido, builders, From/Into/AsRef, RAII), invocar `~/.claude/skills/rust-ergonomic-review/SKILL.md`. Cubre lo que clippy NO cubre directamente.

## Referencias

- `~/.claude/CLAUDE.md` §"Heurística NLD" — definición canónica abstracta
- [Clippy disallowed-types docs](https://doc.rust-lang.org/clippy/lint_configuration.html#disallowed-types)
- [Clippy disallowed-methods docs](https://doc.rust-lang.org/clippy/lint_configuration.html#disallowed-methods)
- [RFC 3389 — `[lints]` table](https://rust-lang.github.io/rfcs/3389-manifest-lint.html) — estable desde Rust 1.74
- Project skill (si existe): extiende este con reglas locales (paths exempt, replacements canónicos, etc.)
