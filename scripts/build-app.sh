#!/usr/bin/env bash
#
# Build Glossary.app — a distributable menu-bar agent — from the SwiftPM package.
# Produces ./Glossary.app at the repo root.
#
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="Glossary"
BUNDLE_ID="com.kika.glossary"
VERSION="0.1.0"
BUILD="1"
CONFIG="release"

APP="${APP_NAME}.app"
CONTENTS="${APP}/Contents"
MACOS="${CONTENTS}/MacOS"
RES="${CONTENTS}/Resources"

echo "▸ Compiling (${CONFIG})…"
swift build -c "${CONFIG}"

BIN_PATH="$(swift build -c "${CONFIG}" --show-bin-path)"
EXEC="${BIN_PATH}/${APP_NAME}"
[ -x "${EXEC}" ] || { echo "✗ Executable not found at ${EXEC}"; exit 1; }

echo "▸ Assembling ${APP}…"
rm -rf "${APP}"
mkdir -p "${MACOS}" "${RES}"

cp "${EXEC}" "${MACOS}/${APP_NAME}"

# App icon: build AppIcon.icns from Resources/AppIcon.png.
ICON_SRC="Resources/AppIcon.png"
HAS_ICON=0
if [ -f "${ICON_SRC}" ]; then
  ICONSET="$(mktemp -d)/AppIcon.iconset"
  mkdir -p "${ICONSET}"
  gen() { sips -z "$1" "$1" "${ICON_SRC}" --out "${ICONSET}/$2" >/dev/null; }
  gen 16   icon_16x16.png
  gen 32   icon_16x16@2x.png
  gen 32   icon_32x32.png
  gen 64   icon_32x32@2x.png
  gen 128  icon_128x128.png
  gen 256  icon_128x128@2x.png
  gen 256  icon_256x256.png
  gen 512  icon_256x256@2x.png
  gen 512  icon_512x512.png
  gen 1024 icon_512x512@2x.png
  if iconutil -c icns "${ICONSET}" -o "${RES}/AppIcon.icns" 2>/dev/null; then
    HAS_ICON=1
    echo "  • generated AppIcon.icns"
  fi
fi

# Copy the SwiftPM resource bundle so Bundle.module resolves inside the .app.
RES_BUNDLE="$(find "${BIN_PATH}" -maxdepth 1 -name '*.bundle' -print -quit || true)"
if [ -n "${RES_BUNDLE}" ]; then
  cp -R "${RES_BUNDLE}" "${RES}/"
  echo "  • bundled $(basename "${RES_BUNDLE}")"
else
  echo "✗ Resource bundle (glossary.json) not found — aborting."; exit 1
fi

ICON_KEY=""
[ "${HAS_ICON}" = "1" ] && ICON_KEY="    <key>CFBundleIconFile</key>      <string>AppIcon</string>"

cat > "${CONTENTS}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>     <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>      <string>${BUNDLE_ID}</string>
    <key>CFBundleExecutable</key>      <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>CFBundleShortVersionString</key> <string>${VERSION}</string>
    <key>CFBundleVersion</key>         <string>${BUILD}</string>
${ICON_KEY}
    <key>LSMinimumSystemVersion</key>  <string>14.0</string>
    <key>LSUIElement</key>             <true/>
    <key>NSHighResolutionCapable</key> <true/>
    <key>NSPrincipalClass</key>        <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "▸ Ad-hoc code-signing…"
codesign --force --deep --sign - "${APP}" >/dev/null 2>&1 || echo "  (codesign skipped/failed — app still runs locally)"

echo "✓ Built ${APP}"
echo "  Run:  open ${APP}    then press ⌥Space"
