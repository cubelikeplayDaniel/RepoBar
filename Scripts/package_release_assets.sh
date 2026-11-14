#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/version.env"

VERSION_TAG="${RELEASE_VERSION:-v${MARKETING_VERSION}-zh-Hans}"
APP_SOURCE="${ROOT_DIR}/.build/release/RepoBar.app"
DIST_DIR="${ROOT_DIR}/dist"

if [ ! -d "${APP_SOURCE}" ]; then
  echo "==> Building release app bundle first..."
  "${ROOT_DIR}/Scripts/package_app.sh" release
fi

echo "==> Configuring Info.plist for standalone Chinese edition (file token store + disable upstream overwrite)"
/usr/libexec/PlistBuddy -c "Delete :RepoBarTokenStore" "${APP_SOURCE}/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :RepoBarTokenStore string file" "${APP_SOURCE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :SUEnableAutomaticChecks false" "${APP_SOURCE}/Contents/Info.plist"

codesign --force --deep --sign - "${APP_SOURCE}"

rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

build_arch_packages() {
  local arch_label="$1"
  local lipo_arch="${2:-}"
  local stage_dir="${WORK_DIR}/stage-${arch_label}"
  local dmg_dir="${WORK_DIR}/dmg-${arch_label}"
  mkdir -p "${stage_dir}" "${dmg_dir}"

  cp -R "${APP_SOURCE}" "${stage_dir}/RepoBar.app"

  if [ -n "${lipo_arch}" ]; then
    echo "==> Thinning binaries for ${arch_label} (${lipo_arch})"
    lipo -thin "${lipo_arch}" "${APP_SOURCE}/Contents/MacOS/RepoBar" -output "${stage_dir}/RepoBar.app/Contents/MacOS/RepoBar"
    lipo -thin "${lipo_arch}" "${APP_SOURCE}/Contents/MacOS/repobarcli" -output "${stage_dir}/RepoBar.app/Contents/MacOS/repobarcli"
  fi

  codesign --force --deep --sign - "${stage_dir}/RepoBar.app"

  local zip_name="RepoBar-${VERSION_TAG}-macOS-${arch_label}.zip"
  echo "==> Creating ${zip_name}"
  /usr/bin/ditto -c -k --keepParent "${stage_dir}/RepoBar.app" "${DIST_DIR}/${zip_name}"

  local dmg_name="RepoBar-${VERSION_TAG}-macOS-${arch_label}.dmg"
  echo "==> Creating ${dmg_name}"
  cp -R "${stage_dir}/RepoBar.app" "${dmg_dir}/RepoBar.app"
  ln -s /Applications "${dmg_dir}/Applications"
  hdiutil create -volname "RepoBar (${arch_label})" \
    -srcfolder "${dmg_dir}" \
    -ov -format UDZO \
    "${DIST_DIR}/${dmg_name}" >/dev/null

  local cli_dir="${WORK_DIR}/cli-${arch_label}"
  mkdir -p "${cli_dir}"
  cp "${stage_dir}/RepoBar.app/Contents/MacOS/repobarcli" "${cli_dir}/repobar"
  chmod +x "${cli_dir}/repobar"
  codesign --force --sign - "${cli_dir}/repobar"
  local cli_tar="repobarcli-${VERSION_TAG}-macOS-${arch_label}.tar.gz"
  echo "==> Creating ${cli_tar}"
  tar -czf "${DIST_DIR}/${cli_tar}" -C "${cli_dir}" repobar
}

build_arch_packages "universal" ""
build_arch_packages "arm64" "arm64"
build_arch_packages "x86_64" "x86_64"

if [ -f "${ROOT_DIR}/RepoBar-${MARKETING_VERSION}.dSYM.zip" ]; then
  cp "${ROOT_DIR}/RepoBar-${MARKETING_VERSION}.dSYM.zip" "${DIST_DIR}/RepoBar-${VERSION_TAG}.dSYM.zip"
fi

echo "==> Generating SHA256SUMS.txt"
(
  cd "${DIST_DIR}"
  shasum -a 256 -- *.dmg *.zip *.tar.gz > SHA256SUMS.txt
)

echo "==> Packaged release assets in ${DIST_DIR}:"
ls -lh "${DIST_DIR}"
