#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/version.env"

VERSION_TAG="${RELEASE_VERSION:-v${MARKETING_VERSION}-zh-Hans}"
DIST_DIR="${ROOT_DIR}/dist"
SPARKLE_PUBLIC_KEY="f5fic5IojIONW243GshTw1leInxU0Pag0FLFuzrONSA="
FEED_URL="https://raw.githubusercontent.com/cubelikeplayDaniel/RepoBar/main/appcast.xml"

find_app_bundle() {
  if [ -d "${ROOT_DIR}/.build/apple/Products/Release/RepoBar.app" ]; then
    echo "${ROOT_DIR}/.build/apple/Products/Release/RepoBar.app"
  elif [ -d "${ROOT_DIR}/.build/release/RepoBar.app" ]; then
    echo "${ROOT_DIR}/.build/release/RepoBar.app"
  else
    echo ""
  fi
}

APP_SOURCE="$(find_app_bundle)"
if [ -z "${APP_SOURCE}" ]; then
  echo "==> Building release app bundle first..."
  "${ROOT_DIR}/Scripts/package_app.sh" release
  APP_SOURCE="$(find_app_bundle)"
fi

if [ -z "${APP_SOURCE}" ] || [ ! -d "${APP_SOURCE}" ]; then
  echo "ERROR: Could not locate built RepoBar.app bundle" >&2
  exit 1
fi

echo "==> Using app bundle at: ${APP_SOURCE}"
echo "==> Configuring Info.plist (Sparkle feed bound to cubelikeplayDaniel/RepoBar + file token store)"
/usr/libexec/PlistBuddy -c "Delete :RepoBarTokenStore" "${APP_SOURCE}/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :RepoBarTokenStore string file" "${APP_SOURCE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :SUFeedURL ${FEED_URL}" "${APP_SOURCE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :SUPublicEDKey ${SPARKLE_PUBLIC_KEY}" "${APP_SOURCE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :SUEnableAutomaticChecks true" "${APP_SOURCE}/Contents/Info.plist"

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

UNIVERSAL_ZIP="${DIST_DIR}/RepoBar-${VERSION_TAG}-macOS-universal.zip"
ZIP_LENGTH="$(stat -f%z "${UNIVERSAL_ZIP}")"
PUB_DATE="$(LC_ALL=C date -u +"%a, %d %b %Y %H:%M:%S +0000")"
ED_SIG=""

SIGN_UPDATE_BIN="$(find "${ROOT_DIR}/.build" -name "sign_update" -type f -perm +111 2>/dev/null | head -n 1 || true)"
if [ -n "${SPARKLE_PRIVATE_KEY:-}" ] && [ -n "${SIGN_UPDATE_BIN}" ]; then
  echo "==> Signing universal archive for Sparkle appcast..."
  ED_SIG="$(printf '%s' "${SPARKLE_PRIVATE_KEY}" | "${SIGN_UPDATE_BIN}" --ed-key-file - -p "${UNIVERSAL_ZIP}")"
fi

if [ -n "${ED_SIG}" ]; then
  echo "==> Updating appcast.xml with signed entry for ${VERSION_TAG} (build ${BUILD_NUMBER})"
  cat > "${ROOT_DIR}/appcast.xml" <<APPCAST
<?xml version='1.0' encoding='utf-8'?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
    <channel>
        <title>RepoBar (Simplified Chinese Edition)</title>
        <item>
            <title>${MARKETING_VERSION}</title>
            <pubDate>${PUB_DATE}</pubDate>
            <link>${FEED_URL}</link>
            <sparkle:version>${BUILD_NUMBER}</sparkle:version>
            <sparkle:shortVersionString>${MARKETING_VERSION}</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>15.0</sparkle:minimumSystemVersion>
            <description>&lt;html&gt;&lt;body&gt;&lt;pre&gt;RepoBar ${VERSION_TAG} 简体中文完整汉化版
- 全界面 100% 简体中文本地化支持
- 原生支持 macOS 系统设置单应用语言切换
- 免钥匙串重复授权弹窗优化&lt;/pre&gt;&lt;/body&gt;&lt;/html&gt;</description>
            <enclosure url="https://github.com/cubelikeplayDaniel/RepoBar/releases/download/${VERSION_TAG}/RepoBar-${VERSION_TAG}-macOS-universal.zip" length="${ZIP_LENGTH}" type="application/octet-stream" sparkle:edSignature="${ED_SIG}" />
        </item>
    </channel>
</rss>
APPCAST
  cp "${ROOT_DIR}/appcast.xml" "${DIST_DIR}/appcast.xml"
fi

echo "==> Generating SHA256SUMS.txt"
(
  cd "${DIST_DIR}"
  shasum -a 256 -- *.dmg *.zip *.tar.gz > SHA256SUMS.txt
)

echo "==> Packaged release assets in ${DIST_DIR}:"
ls -lh "${DIST_DIR}"
