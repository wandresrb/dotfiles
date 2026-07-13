# justfile — dotfiles: Claude Code config + Neovim + entorno Rust/Swift para Linux (Fedora)
# Uso: `just` lista las recetas; `just install` lista los programas instalables.
# Requiere: just, curl.

set shell := ["bash", "-uc"]

mod install

# Directorios canonicos de swiftly
swiftly_home := env_var_or_default("SWIFTLY_HOME_DIR", env_var("HOME") + "/.local/share/swiftly")
swiftly_bin  := swiftly_home / "bin"

# Directorios usados por las recetas de estado (dotfiles)
dots       := justfile_directory()
claude_dir := env_var("HOME") + "/.claude"
nvim_dir   := env_var("HOME") + "/.config/nvim"

# Receta por defecto: muestra la lista de recetas
default:
    @just --list

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

# --- Estado de dotfiles ----------------------------------------------------

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

# Muestra el estado actual del symlink de la config de Neovim.
nvim-status:
    #!/usr/bin/env bash
    DOTS="{{dots}}/nvim"
    TARGET="{{nvim_dir}}"
    echo "=== ~/.config/nvim ==="
    ls -la "$TARGET" 2>/dev/null || echo "  no existe"
    readlink -f "$TARGET" 2>/dev/null | grep -q "$DOTS" \
        && echo "  -> apunta a dotfiles ($DOTS)" \
        || echo "  -> NO apunta a dotfiles"

# Muestra version y ubicacion del toolchain de Swift activo.
info:
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{swiftly_home}}/env.sh"
    swift --version
    echo "swift: $(which swift)"
    swiftly list
