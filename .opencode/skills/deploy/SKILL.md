---
name: deploy
description: "Deploy the Godot web build to GitHub Pages: install missing export templates, export the Web preset, and publish build/ with gh-pages. Use when the user asks to deploy, publish, ship, or build the project."
---

# Deploy

Publish the Godot web build to GitHub Pages. Two stages: export the Web build, then push `build/` to the `gh-pages` branch with `gh-pages`.

## Environment (the gotchas)

- Godot binary is **not** on `PATH`: use `/Applications/Godot.app/Contents/MacOS/Godot`.
- The Web preset writes to `build/index.html` (gitignored). `build/` is all that deploys.
- Web export needs templates at `~/Library/Application Support/Godot/export_templates/<version>.stable/`. This is the step that breaks most often: if the export errors with `No export template found at the expected path`, install them (step 1).

## Steps

### 1. Install export templates (only if missing)

Trigger: the export in step 2 fails with `No export template found`. Do not preinstall every run.

Derive the version from the binary, then fetch and extract only the web templates:

```sh
GODOT=/Applications/Godot.app/Contents/MacOS/Godot
VER=$("$GODOT" --version | head -1 | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')   # e.g. 4.7.1
TPL="$HOME/Library/Application Support/Godot/export_templates/$VER.stable"
mkdir -p "$TPL"
curl -L -o /tmp/godot-tpz.tpz "https://github.com/godotengine/godot/releases/download/$VER-stable/Godot_v${VER}-stable_export_templates.tpz"
unzip -o /tmp/godot-tpz.tpz "templates/web_*.zip" "templates/version.txt" "templates/icudt_godot.dat" -d /tmp/godot-tpz
mv /tmp/godot-tpz/templates/* "$TPL/"
rm -rf /tmp/godot-tpz /tmp/godot-tpz.tpz
```

Completion: `$TPL/web_nothreads_release.zip` exists.

### 2. Export the Web build

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release "Web" build/index.html
```

Completion: `build/index.html` and `build/index.wasm` exist with a fresh timestamp, and the command exits without `ERROR`.

### 3. Install deps if missing

```sh
test -d node_modules || npm install
```

Completion: `node_modules/gh-pages` exists.

### 4. Publish

```sh
npm run deploy
```

Completion: `gh-pages` prints `Published`. The site is live at https://asarenski.github.io/godotCraps.
