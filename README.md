# Zip Sub-Folders

**Zip every subfolder inside a folder into its own archive — cleanly.**

`zipSubFolders.sh` takes a target folder and creates a separate `.zip` for each subfolder inside it, writing the archives to a destination of your choice. It strips `.DS_Store` and `desktop.ini` clutter before zipping, avoids filename collisions, and can optionally delete the source folders after a successful compression. A single self-contained Bash script.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Alias Setup — Run From Anywhere](#alias-setup--run-from-anywhere)
6. [Usage & Examples](#usage--examples)
7. [Troubleshooting](#troubleshooting)
8. [License / Copyright](#license--copyright)

---

## Overview

Great for archiving a media library or batching folders for upload: point it at a parent folder and each child folder becomes its own tidy zip, with junk files removed first.

---

## Features

- **One zip per subfolder** — each child folder archived individually.
- **Cleans junk first** — removes `.DS_Store` and `desktop.ini` before zipping.
- **Collision-safe** — if a target zip exists, appends `-2`, `-3`, … and shows the renamed file.
- **Optional source removal** — `-r` deletes source folders after successful compression.
- **Flexible destination** — second argument sets the output folder (defaults to the current directory).
- **CB9-styled** — dynamic-width header/footer, colors, copyright.

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| **macOS** (or Linux) | Uses `bash` and `zip`. Shebang targets Homebrew bash (`/opt/homebrew/bin/bash`). |
| **`zip`** | Standard on macOS; `apt install zip` on Debian/Ubuntu if missing. |

---

## Installation

```bash
git clone <REPOSITORY_URL> ZipSubFolders
cd ZipSubFolders
chmod +x zipSubFolders.sh
./zipSubFolders.sh -h
```

---

## Alias Setup — Run From Anywhere

Launch from any directory by typing `zipsub`.

### macOS / Linux (zsh or bash)

Make it executable, then add to `~/.zshrc` or `~/.bashrc`:

```bash
chmod +x ~/path/to/ZipSubFolders/zipSubFolders.sh
alias zipsub='~/path/to/ZipSubFolders/zipSubFolders.sh'
```

Reload and run:

```bash
source ~/.zshrc
zipsub ~/path/to/parentFolder
```

**Alternative — symlink onto your `PATH`:**

```bash
ln -s ~/path/to/ZipSubFolders/zipSubFolders.sh /usr/local/bin/zipsub
```

> **Windows:** run under **WSL** or **Git Bash** with `bash zipSubFolders.sh`.

---

## Usage & Examples

```
zipSubFolders.sh [OPTIONS] <targetFolder> [zipDestination]
```

| Argument / Option | Meaning |
|-------------------|---------|
| `targetFolder` | Folder whose subfolders will be zipped (required). |
| `zipDestination` | Where the zips are written (defaults to the current directory). |
| `-r` | Remove each source folder after it's successfully zipped. |
| `-h` | Show help and usage. |

**Examples:**

```bash
zipSubFolders.sh ~/Media/ToArchive                          # zips into the current directory
zipSubFolders.sh ~/Media/ToArchive /Volumes/Backup/Zips     # zips into a destination folder
zipSubFolders.sh -r ~/Media/ToArchive /Volumes/Backup/Zips  # ...and delete sources after zipping
```

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `bad interpreter: /opt/homebrew/bin/bash` | Install Homebrew bash (`brew install bash`) or run via `bash zipSubFolders.sh`. |
| `zip: command not found` | Install `zip` (`apt install zip` on Debian/Ubuntu). |
| A zip got a `-2` suffix | Expected — a same-named archive already existed; the collision-safe rename kicked in. |
| Sources still present after `-r` | Folders are only removed after a *successful* zip; check for zip errors above. |

---

## License / Copyright

---
**Version:** 2.02
**Author:** Cloud Box 9 Inc.
**Maintainer / Owner:** Cloud Box 9 Inc.
**Last Updated:** Jul 5, 2026

Copyright © 2026 Cloud Box 9 Inc. All rights reserved.
