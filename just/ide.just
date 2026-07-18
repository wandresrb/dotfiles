# just/ide.just — editores y sus configuraciones (symlinks a ~/.config).

# --- Instalacion de editores -------------------------------------------

# Linux: compila Neovim desde source (rama stable).
[linux]
[group('ide')]
editors:
    #!/usr/bin/env bash
    set -euo pipefail
    just _pkg ninja-build cmake gcc gcc-c++ make unzip gettext curl glibc-gconv-extra
    SRC="{{neovim_src}}"
    if [ -d "$SRC/.git" ]; then
        git -C "$SRC" fetch --tags origin
    else
        mkdir -p "$(dirname "$SRC")"
        git clone https://github.com/neovim/neovim "$SRC"
    fi
    git -C "$SRC" checkout stable
    git -C "$SRC" pull --ff-only origin stable
    make -C "$SRC" CMAKE_BUILD_TYPE=RelWithDebInfo -j"$(nproc)"
    sudo make -C "$SRC" install
    hash -r
    nvim --version | head -n1

# macOS: instala editores (neovim, ghostty, vscode, claude-code) del Brewfile.
[macos]
[group('ide')]
editors: _brew
    brew bundle --file "{{dots}}/brew/ide.Brewfile"

# --- Configuraciones (symlinks, iguales en macOS y Linux) --------------

# Symlink de la config de Neovim: dotfiles/nvim -> ~/.config/nvim.
[group('ide')]
nvim-config:
    @just _link "{{dots}}/nvim" "{{nvim_dir}}"

# Symlink de la config de Ghostty: dotfiles/ghostty -> ~/.config/ghostty.
[group('ide')]
ghostty-config:
    @just _link "{{dots}}/ghostty" "{{ghostty_dir}}"

# Reconcilia la config de Claude (settings, keybindings, agents, skills, commands).
[group('ide')]
claude:
    #!/usr/bin/env bash
    set -euo pipefail
    DOTS="{{dots}}/claude"; CLAUDE="{{claude_dir}}"
    just _link "$DOTS/settings.json"    "$CLAUDE/settings.json"
    just _link "$DOTS/keybindings.json" "$CLAUDE/keybindings.json"
    mkdir -p "$CLAUDE/agents" "$CLAUDE/skills" "$CLAUDE/commands"
    for f in "$DOTS"/agents/*.md;  do just _link "$f" "$CLAUDE/agents/$(basename "$f")";  done
    for d in "$DOTS"/skills/*/;    do just _link "$d" "$CLAUDE/skills/$(basename "$d")";   done
    for f in "$DOTS"/commands/*.md; do just _link "$f" "$CLAUDE/commands/$(basename "$f")"; done
    echo "Listo."

# Aplica todas las configuraciones de editores de una vez.
[group('ide')]
configs: nvim-config ghostty-config claude
