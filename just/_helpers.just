# just/_helpers.just — recetas internas compartidas (uso interno, prefijo _).

# Crea un symlink src -> dst, respaldando dst si ya existia.
_link src dst:
    #!/usr/bin/env bash
    set -euo pipefail
    src="{{src}}"; dst="{{dst}}"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  ok  $dst"; exit 0
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "$dst.bak"; echo "  bak $dst.bak"
    fi
    ln -s "$src" "$dst"
    echo "  -> $dst"

# macOS: instala Homebrew si no esta (pedira tu contrasena). Idempotente.
# Es el "gestor de paquetes" de macOS; las recetas [macos] dependen de el.
[macos]
_brew:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v brew >/dev/null 2>&1; then
        echo "brew ya instalado: $(brew --version | head -n1)"; exit 0
    fi
    echo "Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    grep -qF 'brew shellenv' "$HOME/.zprofile" 2>/dev/null \
        || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    brew --version | head -n1

# Linux: detecta el gestor de paquetes (dnf/apt/pacman/zypper) e instala.
# Los nombres se pasan en estilo dnf; se traducen los que difieren.
[linux]
_pkg *packages:
    #!/usr/bin/env bash
    set -euo pipefail
    translate() {
        local mgr="$1" p="$2"
        case "$mgr" in
            apt) case "$p" in
                    gcc-c++)           echo "g++" ;;
                    fd-find)           echo "fd-find" ;;
                    glibc-gconv-extra) echo "" ;;
                    *)                 echo "$p" ;;
                 esac ;;
            pacman) case "$p" in
                    ninja-build)       echo "ninja" ;;
                    gcc-c++)           echo "gcc" ;;
                    fd-find)           echo "fd" ;;
                    glibc-gconv-extra) echo "" ;;
                    *)                 echo "$p" ;;
                 esac ;;
            zypper) case "$p" in
                    ninja-build)       echo "ninja" ;;
                    glibc-gconv-extra) echo "" ;;
                    *)                 echo "$p" ;;
                 esac ;;
            *) echo "$p" ;;
        esac
    }
    if   command -v dnf     >/dev/null 2>&1; then MGR=dnf
    elif command -v apt-get >/dev/null 2>&1; then MGR=apt
    elif command -v pacman  >/dev/null 2>&1; then MGR=pacman
    elif command -v zypper  >/dev/null 2>&1; then MGR=zypper
    else echo "No hay gestor soportado (dnf/apt/pacman/zypper)." >&2; exit 1; fi
    PKGS=()
    for p in {{packages}}; do t="$(translate "$MGR" "$p")"; [ -n "$t" ] && PKGS+=("$t"); done
    echo "=== $MGR: instalando ${PKGS[*]} ==="
    case "$MGR" in
        dnf)    sudo dnf -y install "${PKGS[@]}" ;;
        apt)    sudo apt-get update && sudo apt-get -y install "${PKGS[@]}" ;;
        pacman) sudo pacman -Sy --needed --noconfirm "${PKGS[@]}" ;;
        zypper) sudo zypper -n install "${PKGS[@]}" ;;
    esac
