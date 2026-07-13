---
name: rust-ergonomic-review
description: Review desde la lente de ergonomía Rust idiomática. Activa este skill cuando edites APIs públicas en proyectos Rust (cualquier dominio, no solo no_std). Verifica: lifetimes que no contagian ruido, conversiones via From/Into/AsRef, builders cuando aportan, iteradores legibles, RAII en Drop, no C-with-Rust-syntax. Complemento de code-quality-bar (que cubre performance/concurrencia); este skill cubre la cara human-facing del API.
---

# rust-ergonomic-review — APIs Rust nativas, no C con sintaxis distinta

Estás editando una API pública en Rust. Este skill audita ergonomía idiomática — lo que diferencia un API que "se siente Rust" de un port mecánico de C/C++ o un ABI con sintaxis Rust.

## Anti-patterns y respuestas idiomáticas

### Lifetimes que contagian ruido

**Anti-pattern**: `pub fn parse<'a, 'b: 'a, 'c: 'b>(input: &'a [u8], cfg: &'b Config<'c>) -> Result<Parsed<'a>, Error>` — ruido lifetime que el caller tiene que entender.

**NLD**: simplificar via lifetime elision, `'static` cuando aplica, o `impl Trait` que oculta detalles. Si la API requiere bounds complejos, considerar si el design subyacente está mal.

### Free functions tipo C

**Anti-pattern**: `pub fn open_file(path: &str, flags: u32) -> Result<i32, i32>` — fd como entero, flags como bits, error code como entero.

**NLD**: type protagonista (`File`), associated functions (`File::open`), methods (`.read`, `.write`), trait impls (`Read`, `Write`, `AsRawFd`), RAII en `Drop`, error tipo dedicado (`io::Error` o newtype).

### Conversiones explícitas innecesarias

**Anti-pattern**: `pub fn process(s: &str)` que requiere `.as_str()` desde `String`. `pub fn handle(addr: &SocketAddr)` que requiere `&socket_addr` desde owned.

**NLD**: `impl AsRef<str>`, `impl Into<X>`, `impl From<Y> for X`. El caller pasa lo natural, la API convierte.

### Builders inflexibles o builders innecesarios

**Anti-pattern A**: API simple con builder de 3 campos opcionales — overhead innecesario.
**Anti-pattern B**: API con 12 parámetros posicionales boolean.

**NLD**: builder cuando hay >4 campos opcionales, configuración con dependencias entre campos, o construcción multi-fase. Si son 2-3 fields todos requeridos, struct literal o constructor directo.

### Iteradores que devuelven `Vec`

**Anti-pattern**: `pub fn entries(&self) -> Vec<Entry>` — fuerza allocation, materialización completa.

**NLD**: `impl Iterator<Item = Entry>` o `impl IntoIterator`. Caller decide si colectar.

### Errors opacos o errors mega-enum

**Anti-pattern A**: `pub fn op() -> Result<T, Box<dyn Error>>` — caller no puede match.
**Anti-pattern B**: enum error con 47 variantes que cubren operaciones distintas — no es modular.

**NLD**: error type dedicado al módulo, variantes enumeradas con contexto, `impl Error + Display + Debug`. Para libraries: `thiserror` (o equivalente no_std) si simplifica; manual si pulls innecesarias.

### Clone como default

Solapa con eje 2 de `code-quality-bar` pero acá específico ergonomía:
**Anti-pattern**: API toma `String` por valor cuando solo lee.
**NLD**: `&str` o `impl AsRef<str>`. El caller decide ownership.

### `unsafe` sin documentar invariantes

**Anti-pattern**: `pub unsafe fn from_raw(ptr: *mut T) -> Self { ... }` sin doc-comment.

**NLD**: `# Safety` section obligatoria explicando invariantes que el caller debe garantizar. Sin esa sección, `unsafe` público es contrato roto.

## Checklist al proponer API pública

1. ¿Hay type protagonista, o son free functions? (Free functions OK para utilities; type protagonista para resources/handles.)
2. ¿Lifetimes mínimos? ¿Se puede usar elision? ¿`'static` aplica?
3. ¿Trait impls naturales? (`Default`, `Debug`, `Clone` cuando aplica, `Display`, `From`/`Into`.)
4. ¿RAII en `Drop` para resources? Cleanup automático.
5. ¿Iteradores en lugar de `Vec` cuando el caller probablemente itera?
6. ¿Builder solo cuando aporta?
7. ¿Error type dedicado, no `Box<dyn Error>` en API pública?
8. ¿`unsafe` con `# Safety` documentando invariantes?
9. ¿`From`/`AsRef` para conversiones esperables, evitando `.as_str()`/`.to_string()` boilerplate en callers?

## Compatibilidad con `code-quality-bar`

Este skill **complementa** `code-quality-bar`. NLD bar cubre eje técnico (performance, concurrencia, primitivas); este skill cubre eje human-facing del API. Una API debería pasar **ambos**.

- Si solo importa performance → `code-quality-bar` es suficiente
- Si solo importa human-facing (CLI, web API) → `rust-ergonomic-review` es suficiente
- Systems programming en Rust → ambos

## Referencias

- `~/.claude/CLAUDE.md` §"Áreas técnicas que me importan" → "Ergonomía de Rust"
- Para no_std/freestanding: combinar con `code-quality-bar`
