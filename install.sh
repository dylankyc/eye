#!/bin/sh
# Installs eye (https://github.com/dylankyc/eye) for macOS (Apple Silicon) and Linux.
#
#   curl -fsSL https://raw.githubusercontent.com/dylankyc/eye/main/install.sh | sh
#
# Environment:
#   EYE_VERSION      release tag to install (default: latest), e.g. v0.1.0
#   EYE_INSTALL_DIR  where to put the binary (default: ~/.local/bin)
#   EYE_DOWNLOAD_BASE  download from this URL instead of GitHub releases (mirrors, testing)
set -eu

REPO="dylankyc/eye"
VERSION="${EYE_VERSION:-latest}"
INSTALL_DIR="${EYE_INSTALL_DIR:-$HOME/.local/bin}"

fail() {
  echo "eye install: $*" >&2
  exit 1
}

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) target="aarch64-apple-darwin" ;;
  Linux-x86_64 | Linux-amd64) target="x86_64-unknown-linux-musl" ;;
  Linux-aarch64 | Linux-arm64) target="aarch64-unknown-linux-musl" ;;
  Darwin-x86_64) fail "Intel Macs are not supported yet (Apple Silicon only)" ;;
  *) fail "unsupported platform $(uname -s) $(uname -m); see https://github.com/$REPO/releases" ;;
esac

if [ -n "${EYE_DOWNLOAD_BASE:-}" ]; then
  base="$EYE_DOWNLOAD_BASE"
elif [ "$VERSION" = "latest" ]; then
  base="https://github.com/$REPO/releases/latest/download"
else
  base="https://github.com/$REPO/releases/download/$VERSION"
fi

if command -v sha256sum >/dev/null 2>&1; then
  sha256() { sha256sum "$1" | cut -d' ' -f1; }
elif command -v shasum >/dev/null 2>&1; then
  sha256() { shasum -a 256 "$1" | cut -d' ' -f1; }
else
  fail "need sha256sum or shasum to verify the download"
fi

asset="eye-$target.tar.gz"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $asset ($VERSION)…"
curl -fsSL "$base/$asset" -o "$tmp/$asset" || fail "download failed: $base/$asset"
curl -fsSL "$base/SHA256SUMS" -o "$tmp/SHA256SUMS" || fail "download failed: $base/SHA256SUMS"

expected="$(grep " $asset\$" "$tmp/SHA256SUMS" | cut -d' ' -f1)"
[ -n "$expected" ] || fail "no checksum for $asset"
[ "$(sha256 "$tmp/$asset")" = "$expected" ] || fail "checksum mismatch for $asset"

tar -xzf "$tmp/$asset" -C "$tmp"
mkdir -p "$INSTALL_DIR"
cp "$tmp/eye-$target/eye" "$INSTALL_DIR/eye"
chmod 755 "$INSTALL_DIR/eye"

echo "Installed $("$INSTALL_DIR/eye" --version) to $INSTALL_DIR/eye"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "Add $INSTALL_DIR to your PATH, e.g.: export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
esac
echo "Try it: cd into a project you used Claude Code in and run 'eye'"
