# just/apps.just — apps de sistema / utilidades GUI.

# macOS: instala las apps (casks) desde brew/apps.Brewfile.
[macos]
[group('apps')]
apps: _brew
    brew bundle --file "{{dots}}/brew/apps.Brewfile"

# (Linux: pendiente — flatpak/rpm segun distro.)
