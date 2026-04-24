#!/usr/bin/env bash
set -euo pipefail

# Run the `updpkgsums` GitHub Action (.github/actions/aur) locally against a
# package directory, mirroring how GitHub Actions invokes it.
#
# Usage: scripts/updpkgsums-local.sh <package-dir>
# Example: scripts/updpkgsums-local.sh hale-studio-bin

usage() {
    cat >&2 <<EOF
Usage: $(basename "$0") <package-dir>

Builds the .github/actions/aur Docker image and runs its entrypoint against
<package-dir> (e.g. hale-studio-bin, hale-cli-bin), mirroring the
updpkgsums workflow.

Updated PKGBUILD / .SRCINFO will be written back into the worktree.
EOF
    exit "${1:-1}"
}

if [[ $# -ne 1 ]]; then
    usage 1
fi

case "$1" in
    -h | --help) usage 0 ;;
esac

PKGDIR="$1"

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if [[ ! -d "$REPO_ROOT/$PKGDIR" ]]; then
    echo "error: '$PKGDIR' is not a directory under $REPO_ROOT" >&2
    exit 1
fi

if [[ ! -f "$REPO_ROOT/$PKGDIR/PKGBUILD" ]]; then
    echo "error: $REPO_ROOT/$PKGDIR has no PKGBUILD" >&2
    exit 1
fi

IMAGE="aur-updpkgsums-local"

echo ">>> Building $IMAGE from .github/actions/aur/Dockerfile"
docker build -t "$IMAGE" .github/actions/aur

echo ">>> Running entrypoint for pkgname=$PKGDIR"
# No -t: a TTY makes the entrypoint's `git diff` calls invoke git's default
# pager (less), which is not installed in archlinux:base-devel. CI runs
# without a TTY, so matching that keeps behavior identical.
docker run --rm \
    -v "$REPO_ROOT":/github/workspace \
    -e GITHUB_WORKSPACE=/github/workspace \
    -e INPUT_PKGNAME="$PKGDIR" \
    --entrypoint /entrypoint.sh \
    "$IMAGE"

cat <<EOF

>>> Done. Updated files (if any) are in $PKGDIR/.
    The entrypoint writes back via 'sudo cp' inside the container, so the
    updated PKGBUILD / .SRCINFO may be root-owned on the host. If so:

        sudo chown -R $(id -u):$(id -g) "$PKGDIR"
EOF
