# kfxgen - Docker mod for Calibre

Adds [kfxgen](https://github.com/jloutsch/kfxgen) to the LinuxServer.io Calibre image for native KFX conversion,
without Wine or Kindle Previewer. Supports amd64/arm64 and s6 v3.

Set `DOCKER_MODS=ghcr.io/linuxserver/mods:calibre-kfxgen` in your existing Calibre container configuration.
Separate multiple mods with `|`. Recreate the container, then select **KFX** in Convert books.

**Disable KFX Output** if installed; it otherwise takes priority over kfxgen.

Back up `/config` first. At startup the mod installs its bundled plugin as `abc` into `/config/.config/calibre`,
preserving preferences and disabled plugins. No runtime downloads. To uninstall, remove the mod variable,
recreate the container, then remove kfxgen through Calibre's plugin preferences.

Formatting, Arabic/RTL fidelity, and CLI options differ from Previewer. Test representative books on your Kindle.
Secure the browser desktop according to LinuxServer's documentation.

The plugin version/checksum and matching source version/commit are pinned in `Dockerfile`; update both version
blocks together. Run `bash tests/smoke.sh` to test startup, permissions, conversion, and preference preservation.

GPLv3; see [LICENSE](LICENSE). The checksum-verified plugin, pinned source, and upstream license are bundled
in `/defaults/kfxgen/`.
