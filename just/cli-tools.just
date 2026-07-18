# just/cli-tools.just — utilidades de terminal.

# Linux: instala el set de herramientas CLI con el gestor del sistema.
[linux]
[group('cli')]
cli:
    @just _pkg git ripgrep fd-find fzf bat eza zoxide gh

# macOS: instala el set de herramientas CLI desde brew/cli.Brewfile.
[macos]
[group('cli')]
cli: _brew
    brew bundle --file "{{dots}}/brew/cli.Brewfile"
