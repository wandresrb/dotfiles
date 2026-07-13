# justfile — dotfiles: Claude Code config + entorno Swift para Linux (Fedora)
# Uso: `just` lista las recetas; `just <receta>` ejecuta una.
# Requiere: just, curl, y para los demos: cargo (Rust) + clang/gcc.

set shell := ["bash", "-uc"]

# Directorios canonicos de swiftly
swiftly_home := env_var_or_default("SWIFTLY_HOME_DIR", env_var("HOME") + "/.local/share/swiftly")
swiftly_bin  := swiftly_home / "bin"

# Receta por defecto: muestra la lista de recetas
default:
    @just --list

# --- Instalacion ---------------------------------------------------------

# Instala swiftly (gestor oficial de toolchains, tipo rustup). Idempotente.
install-swiftly:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -x "{{swiftly_bin}}/swiftly" ]; then
        echo "swiftly ya instalado: $({{swiftly_bin}}/swiftly --version)"
        exit 0
    fi
    echo "Descargando e instalando swiftly..."
    curl -fsSL https://swiftlang.github.io/swiftly/swiftly-install.sh | bash -s -- -y
    echo "Listo. Reinicia la shell o ejecuta: source {{swiftly_home}}/env.sh"

# Instala el ultimo toolchain estable (full). Embedded ya viene incluido como
# modo de compilacion; el SDK static/musl se agrega aparte con `add-musl-sdk`.
install-swift: install-swiftly
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{swiftly_home}}/env.sh"
    swiftly install latest --use
    hash -r
    swift --version

# Agrega el Static Linux SDK (musl) para compilar binarios estaticos.
# Uso posterior: swift build --swift-sdk x86_64-swift-linux-musl
add-musl-sdk:
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{swiftly_home}}/env.sh"
    VERSION="$(swift --version | grep -oP 'Swift version \K[0-9.]+')"
    echo "Instalando Static Linux SDK para Swift ${VERSION}..."
    swift sdk install \
      "https://download.swift.org/swift-${VERSION}-release/static-sdk/swift-${VERSION}-RELEASE/swift-${VERSION}-RELEASE_static-linux-0.0.1.artifactbundle.tar.gz"
    swift sdk list

# --- Entorno -------------------------------------------------------------

# Imprime el snippet para activar Swift en tu shell (anadir a ~/.bashrc).
env:
    @echo 'source "{{swiftly_home}}/env.sh"'

# Anade el source de swiftly a ~/.bashrc si no esta presente.
setup-shell:
    #!/usr/bin/env bash
    set -euo pipefail
    LINE='source "{{swiftly_home}}/env.sh"'
    if grep -qF "$LINE" "$HOME/.bashrc" 2>/dev/null; then
        echo "~/.bashrc ya tiene el source de swiftly."
    else
        echo "$LINE" >> "$HOME/.bashrc"
        echo "Anadido a ~/.bashrc. Abre una shell nueva."
    fi

# --- Claude Code -----------------------------------------------------------

dots := justfile_directory()
claude_dir := env_var("HOME") + "/.claude"

# Instala (o reconcilia) la config de Claude desde dotfiles via symlinks.
claude-install:
    #!/usr/bin/env bash
    set -euo pipefail
    DOTS="{{dots}}/claude"
    CLAUDE="{{claude_dir}}"

    _link() {
        local src="$1" dst="$2"
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            echo "  ok  $dst"
            return
        fi
        [ -e "$dst" ] && mv "$dst" "$dst.bak" && echo "  bak $dst.bak"
        ln -s "$src" "$dst"
        echo "  -> $dst"
    }

    echo "=== settings y keybindings ==="
    _link "$DOTS/settings.json"    "$CLAUDE/settings.json"
    _link "$DOTS/keybindings.json" "$CLAUDE/keybindings.json"

    echo "=== agents ==="
    mkdir -p "$CLAUDE/agents"
    for f in "$DOTS"/agents/*.md; do
        _link "$f" "$CLAUDE/agents/$(basename "$f")"
    done

    echo "=== skills ==="
    mkdir -p "$CLAUDE/skills"
    for d in "$DOTS"/skills/*/; do
        _link "$d" "$CLAUDE/skills/$(basename "$d")"
    done

    echo "=== commands ==="
    mkdir -p "$CLAUDE/commands"
    for f in "$DOTS"/commands/*.md; do
        _link "$f" "$CLAUDE/commands/$(basename "$f")"
    done

    echo "Listo."

# Muestra el estado actual de los symlinks de Claude.
claude-status:
    #!/usr/bin/env bash
    DOTS="{{dots}}/claude"
    CLAUDE="{{claude_dir}}"
    echo "=== settings.json ==="
    ls -la "$CLAUDE/settings.json"
    echo "=== keybindings.json ==="
    ls -la "$CLAUDE/keybindings.json"
    echo "=== agents (dotfiles) ==="
    ls -la "$CLAUDE/agents/" | grep "$(basename "$DOTS")"
    echo "=== skills (dotfiles) ==="
    ls -la "$CLAUDE/skills/" | grep "$(basename "$DOTS")"
    echo "=== commands ==="
    ls -la "$CLAUDE/commands/"

# Muestra version y ubicacion del toolchain activo.
info:
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{swiftly_home}}/env.sh"
    swift --version
    echo "swift: $(which swift)"
    swiftly list
