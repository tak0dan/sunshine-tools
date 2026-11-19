# sunshine-tools

The tools of [Sunshine OS](https://github.com/tak0dan/SunshineOS), laid out exactly as they are installed (`usr/local/bin/...`).
Every Sunshine OS system pulls them with `sunshine-toolsync`, which `sunshine-update` runs first: a repair tool fixed today works on
every installed system tomorrow, without a new ISO and without waiting for a package.

| Tool | What it does |
|------|--------------|
| `sunshine-update` | updates the system, AUR, Flatpak (and Nix on Sirius); ranks mirrors; first pulls the newest tools |
| `sunshine-doctor` | checks identity, package manager, boot, disk, services, snapshots; `--fix` repairs what is safe |
| `sunshine-rescue` | from the **live session**: finds the installed system (LUKS, btrfs `@`), mounts it and repairs package database, kernel, initramfs, GRUB, fstab; resets passwords; fsck; chroot |
| `sunshine-fix-pacman` | repairs pacman: locks, keyring, mirrors, databases, the AUR helper |
| `sunshine-boot-repair` | GRUB and initramfs repair on the running system |
| `sunshine-kernel` | several kernels side by side (linux, lts, zen, hardened, CachyOS ...), default entry, remove |
| `sunshine-performance` | one switch for zram, sysctl, I/O schedulers, earlyoom, ananicy, TRIM, journal; `bench` shows the numbers |
| `sunshine-gaming` | graphics stack for the detected GPU, Steam, Proton, Lutris, Gamemode, MangoHud, Gamescope, tuning |
| `sunshine-desktops` | install KDE, GNOME, Xfce, Cinnamon, MATE, Budgie, LXQt, COSMIC, i3, Sway, Hyprland, niri, Openbox, Qtile, bspwm, Awesome next to Plasma |
| `sunshine-snapshot` | btrfs restore points (snapper), bootable from GRUB |
| `sunshine-toolbox`, `sunshine-welcome`, `sunshine-apps` | the graphical entry points |

## How a release works

`tools/publish-tools.sh` in the Sunshine OS repository collects the files, writes `manifest.json` (version + SHA-256 and mode of every file),
signs the manifest and the archive with the Sunshine OS key and replaces the assets of the release `tools`.
`sunshine-toolsync update` downloads the manifest, verifies the signature against `/usr/share/pacman/keyrings/sunshine.gpg`, and installs a file
only if its SHA-256 matches the signed manifest **and** its path is one of the Sunshine paths. Changed files are backed up
(`/var/lib/sunshine/tools-backup`) so `sunshine-toolsync rollback` puts the previous ones back.

Convert any Arch system: add the `[sunshine]` repository from [sunshineos-repo](https://github.com/tak0dan/sunshineos-repo), install `sunshine-base`
(or run `sunshine-converge`), then `sunshine-update` keeps the tools current.
