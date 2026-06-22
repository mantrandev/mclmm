#!/usr/bin/env bash
#
# release.sh — cut a new mclmm release and update the Homebrew tap in one step.
#
#   ./release.sh <version>      e.g. ./release.sh 1.1.0
#
# Does: bump VERSION in the script, commit + tag + push, compute the tarball
# sha256, then bump url/sha256 in mantrandev/homebrew-tap and push that too.
# After it finishes, users update with:  brew update && brew upgrade mclmm
set -euo pipefail

VERSION="${1:?Usage: ./release.sh <version>  (e.g. 1.1.0)}"
REPO="mantrandev/mclmm"
TAP_REPO="mantrandev/homebrew-tap"
FORMULA="Formula/mclmm.rb"
TAG="v$VERSION"

cd "$(dirname "$0")"

git rev-parse "$TAG" >/dev/null 2>&1 && { echo "Tag $TAG already exists."; exit 1; }

sed -i '' "s/^VERSION=.*/VERSION=\"$VERSION\"/" mclmm

git add mclmm
git commit -m "chore: release $TAG"
git tag "$TAG"
git push origin main
git push origin "$TAG"

URL="https://github.com/$REPO/archive/refs/tags/$TAG.tar.gz"
echo "Fetching tarball for sha256…"
SHA=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
  SHA=$(curl -fsSL "$URL" | shasum -a 256 | awk '{print $1}') && [[ -n $SHA ]] && break
  sleep 2
done
[[ -n $SHA ]] || { echo "Could not fetch $URL"; exit 1; }
echo "sha256: $SHA"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git clone "https://github.com/$TAP_REPO.git" "$TMP/tap"
sed -i '' \
  -e "s|url \".*\"|url \"$URL\"|" \
  -e "s|sha256 \".*\"|sha256 \"$SHA\"|" \
  "$TMP/tap/$FORMULA"
git -C "$TMP/tap" add "$FORMULA"
git -C "$TMP/tap" commit -m "mclmm $VERSION"
git -C "$TMP/tap" push origin main

echo "Released $TAG. Update anywhere with: brew update && brew upgrade mclmm"
