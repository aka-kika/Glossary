#!/usr/bin/env bash
#
# Build a SIGNED + NOTARIZED + STAPLED Glossary DMG for public distribution.
#
# Unlike scripts/build-app.sh (ad-hoc, local-only), this produces an artifact that
# opens with a normal double-click after being downloaded on any Mac — no Gatekeeper
# "damaged / unidentified developer" prompt.
#
# Prerequisites (one-time):
#   • A "Developer ID Application" certificate in your login keychain
#       security find-identity -v -p codesigning
#   • Notary credentials stored under a keychain profile:
#       xcrun notarytool store-credentials "glossary-notary" \
#         --apple-id "<your-apple-id>" --team-id "<TEAMID>" --password "<app-specific-pw>"
#     (Generate the app-specific password at https://appleid.apple.com → Sign-In & Security.)
#
# Usage:
#   SIGN_ID="Developer ID Application: Veronica Loren (P5RB3W3D58)" \
#   NOTARY_PROFILE="glossary-notary" \
#   scripts/release-dmg.sh
#
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="Glossary"
VERSION="0.1.0"
APP="${APP_NAME}.app"
DMG="${APP_NAME}-${VERSION}.dmg"

SIGN_ID="${SIGN_ID:-Developer ID Application: Veronica Loren (P5RB3W3D58)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-glossary-notary}"

# 1) Build the app (ad-hoc) via the normal build script.
echo "▸ Building ${APP}…"
scripts/build-app.sh >/dev/null
echo "  ✓ built"

# 2) Re-sign with Developer ID + Hardened Runtime + secure timestamp (inside-out).
echo "▸ Signing with Developer ID + hardened runtime…"
while IFS= read -r bundle; do
  codesign --force --options runtime --timestamp --sign "${SIGN_ID}" "${bundle}"
done < <(find "${APP}/Contents" -name "*.bundle" -maxdepth 2)
codesign --force --options runtime --timestamp --sign "${SIGN_ID}" "${APP}"
codesign --verify --strict --verbose=2 "${APP}"
echo "  ✓ signed"

# 3) Notarize the app, then staple the ticket.
echo "▸ Notarizing app…"
ZIP="${APP_NAME}-notarize.zip"
rm -f "${ZIP}"
/usr/bin/ditto -c -k --keepParent "${APP}" "${ZIP}"
xcrun notarytool submit "${ZIP}" --keychain-profile "${NOTARY_PROFILE}" --wait
rm -f "${ZIP}"
xcrun stapler staple "${APP}"
echo "  ✓ app notarized + stapled"

# 4) Build the DMG from the stapled app.
echo "▸ Building ${DMG}…"
STAGE="$(mktemp -d)/${APP_NAME}"
mkdir -p "${STAGE}"
cp -R "${APP}" "${STAGE}/"
ln -s /Applications "${STAGE}/Applications"
rm -f "${DMG}"
hdiutil create -volname "${APP_NAME}" -srcfolder "${STAGE}" -ov -format UDZO "${DMG}" >/dev/null

# 5) Sign, notarize, and staple the DMG itself.
echo "▸ Signing + notarizing ${DMG}…"
codesign --force --timestamp --sign "${SIGN_ID}" "${DMG}"
xcrun notarytool submit "${DMG}" --keychain-profile "${NOTARY_PROFILE}" --wait
xcrun stapler staple "${DMG}"

# 6) Verify the end result.
echo "▸ Verifying…"
xcrun stapler validate "${DMG}" >/dev/null && echo "  ✓ DMG staple valid"
spctl -a -vvv -t install "${DMG}" 2>&1 | grep -E "accepted|source" | sed 's/^/  /'

echo "✓ ${DMG} is signed, notarized, and stapled — ready to upload to the GitHub release."
