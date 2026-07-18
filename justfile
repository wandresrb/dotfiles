# justfile — dotfiles: entorno de desarrollo (macOS + Linux).
# `just` (sin args) lista las recetas agrupadas por categoria.
# Config por symlinks + toolchains + apps. Requiere: just, curl.
#
# Arranque tipico en macOS:
#   just apps            # Homebrew + todas las apps del Brewfile
#   just nvim-config     # symlink de Neovim
#   just ghostty-config  # symlink de Ghostty
#   just claude          # symlink de la config de Claude Code

set shell := ["bash", "-uc"]

# --- Modulos por categoria ---------------------------------------------
import 'just/_helpers.just'
import 'just/langs.just'
import 'just/ide.just'
import 'just/cli-tools.just'
import 'just/apps.just'

# --- Rutas compartidas -------------------------------------------------
dots         := justfile_directory()
home         := env_var("HOME")
claude_dir   := home / ".claude"
nvim_dir     := home / ".config" / "nvim"
ghostty_dir  := home / ".config" / "ghostty"
neovim_src   := env_var_or_default("NEOVIM_SRC_DIR", home / ".local" / "src" / "neovim")
swiftly_home := env_var_or_default("SWIFTLY_HOME_DIR", home / ".local" / "share" / "swiftly")
swiftly_bin  := swiftly_home / "bin"

# Receta por defecto: lista agrupada de recetas.
default:
    @just --list

# --- Swift en la shell -------------------------------------------------

# Imprime el snippet para activar Swift (swiftly) en tu shell.
[group('shell')]
env:
    @echo 'source "{{swiftly_home}}/env.sh"'

# macOS: anade el source de swiftly a ~/.zshrc si falta.
[macos]
[group('shell')]
setup-shell:
    #!/usr/bin/env bash
    set -euo pipefail
    LINE='source "{{swiftly_home}}/env.sh"'
    if grep -qF "$LINE" "$HOME/.zshrc" 2>/dev/null; then
        echo "~/.zshrc ya tiene el source de swiftly."
    else
        echo "$LINE" >> "$HOME/.zshrc"
        echo "Anadido a ~/.zshrc. Abre una shell nueva."
    fi

# Linux: anade el source de swiftly a ~/.bashrc si falta.
[linux]
[group('shell')]
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

# --- Estado ------------------------------------------------------------

# Version y ubicacion del toolchain de Swift activo.
[group('status')]
info:
    #!/usr/bin/env bash
    set -euo pipefail
    source "{{swiftly_home}}/env.sh"
    swift --version
    echo "swift: $(which swift)"
    swiftly list

# Estado de los symlinks de config (nvim, ghostty, claude).
[group('status')]
status:
    #!/usr/bin/env bash
    for t in "{{nvim_dir}}" "{{ghostty_dir}}" "{{claude_dir}}/settings.json"; do
        echo "=== $t ==="
        ls -la "$t" 2>/dev/null || echo "  no existe"
    done
