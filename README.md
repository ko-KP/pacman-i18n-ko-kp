# pacman-i18n-ko-kp

Korean (ko_KP) translations for [pacman](https://archlinux.org/pacman/).

## Translation Progress

Translation progress is reported automatically on every push via GitHub Actions.
Check the [Actions tab](../../actions) for the latest status.

## Update from upstream

```bash
# Sync with upstream pacman (expects ../pacman to exist)
./scripts/update-translations.sh

# Or specify a custom path
./scripts/update-translations.sh --upstream-dir /path/to/pacman
```

## Build & Install

```bash
meson setup build --prefix=/usr
meson compile -C build
sudo meson install -C build
```
