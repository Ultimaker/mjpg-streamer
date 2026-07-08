#!/usr/bin/env bash
# docker-build.sh – cross-compile mjpg-streamer for arm64, package as a .deb,
# and optionally deploy it to a printer via SSH.
#
# Usage:
#   ./docker-build.sh                       # build only, artifact in ./dist/
#   ./docker-build.sh --deploy 10.2.0.159  # build + deploy to printer IP
#   ./docker-build.sh --deploy 10.2.0.159 --password secret

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"

DEPLOY_HOST=""
PRINTER_PASSWORD="ultimaker"

# ── argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --deploy)    DEPLOY_HOST="$2";      shift 2 ;;
        --password)  PRINTER_PASSWORD="$2"; shift 2 ;;
        *)           echo "Unknown argument: $1"; exit 1 ;;
    esac
done

SSH_OPTS="-q -o StrictHostKeyChecking=no"
# SSH_OPTS is intentionally unquoted when passed to ssh/scp so it is treated
# as separate flags, not a single argument.  shellcheck disable=SC2086 below.

# ── build ─────────────────────────────────────────────────────────────────────
echo "==> Building mjpg-streamer .deb for arm64 via Docker..."
docker build \
    --target export \
    --output "type=local,dest=${DIST_DIR}" \
    "$SCRIPT_DIR"

BUILT_DEB="$(find "${DIST_DIR}" -maxdepth 1 -name 'mjpg-streamer_*.deb' | head -1)"

if [[ -z "$BUILT_DEB" ]]; then
    echo "ERROR: Build succeeded but no .deb found in ${DIST_DIR}." >&2
    exit 1
fi

echo "==> Built: ${BUILT_DEB}"
dpkg-deb --info "$BUILT_DEB"
echo ""
echo "Contents:"
dpkg-deb --contents "$BUILT_DEB"

# ── deploy ────────────────────────────────────────────────────────────────────
if [[ -z "$DEPLOY_HOST" ]]; then
    echo ""
    echo "No --deploy target specified. Done."
    echo "Upload to Cloudsmith with:"
    echo "  cloudsmith push deb ultimaker/packages-released/debian/bookworm ${BUILT_DEB}"
    exit 0
fi

echo ""
echo "==> Deploying to root@${DEPLOY_HOST}..."

# Verify connectivity and architecture
# shellcheck disable=SC2086  # SSH_OPTS must word-split into separate flags
sshpass -p "$PRINTER_PASSWORD" ssh $SSH_OPTS root@"$DEPLOY_HOST" "uname -m" \
    | grep -q aarch64 || { echo "ERROR: target is not aarch64"; exit 1; }

# Upload the .deb
DEB_BASENAME="$(basename "$BUILT_DEB")"
sshpass -p "$PRINTER_PASSWORD" scp -q -o StrictHostKeyChecking=no \
    "$BUILT_DEB" root@"${DEPLOY_HOST}:/tmp/${DEB_BASENAME}"

# Install with dpkg; postinst will restart mjpg-streamer@0.service automatically
echo "==> Installing ${DEB_BASENAME} on printer..."
# shellcheck disable=SC2086  # SSH_OPTS must word-split into separate flags
sshpass -p "$PRINTER_PASSWORD" ssh $SSH_OPTS root@"$DEPLOY_HOST" \
    "dpkg -i /tmp/${DEB_BASENAME} && rm /tmp/${DEB_BASENAME}"

echo "==> Done. Test with:"
echo "    curl -s http://${DEPLOY_HOST}:8080/?action=webpsnapshot --output /tmp/test.webp && file /tmp/test.webp"
