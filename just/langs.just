# just/langs.just — toolchains de lenguajes (Rust, Swift).

# Rust: instala rustup y fija stable. Idempotente. (macOS + Linux)
[group('langs')]
rust:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v rustup >/dev/null 2>&1; then
        echo "rustup ya instalado: $(rustup --version | head -n1)"
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | sh -s -- -y --default-toolchain stable
    fi
    source "$HOME/.cargo/env"
    rustup default stable
    rustc --version && cargo --version

# Nota: para desarrollo iOS necesitas ademas Xcode completo (App Store).
# macOS: Command Line Tools de Xcode (clang, git, swift de CLI).
[macos]
[group('langs')]
xcode-cli:
    #!/usr/bin/env bash
    set -euo pipefail
    if xcode-select -p >/dev/null 2>&1; then
        echo "Xcode CLT ya instaladas: $(xcode-select -p)"
    else
        xcode-select --install
        echo "Acepta el dialogo para instalar las Command Line Tools."
    fi


[group('langs')]
bun:
    curl -fsSL https://bun.sh/install | bash
