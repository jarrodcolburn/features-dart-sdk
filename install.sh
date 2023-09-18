#!/bin/sh
set -eux

BASEURL="https://storage.googleapis.com/dart-archive/channels"

# attempt to get channel from version
CHANNEL="$(echo ${VERSION} | grep -Eo "beta|dev" )"
CHANNEL="${CHANNEL:-stable}"

RELEASE_URL="${$BASEURL/$CHANNEL/release}"

# check for version's short names for latest 'stable', 'beta' or 'dev'
# ('latest' is alias for 'stable')
if echo ${VERSION/latest/stable} | grep -Eo "^(dev|beta|stable)$" ; then
    curl "$RELEASE_URL/latest/VERSION" -osL latest.json 
    LATEST_VER="$( grep -Po '(?<="version":\W")[0-9]+\.[0-9]+\.[0-9]+.*(?=")' latest.json )"
fi
DART_VER="${LATEST_VER:-$VERSION}"
SDK="dartsdk-linux-${SDK_ARCH}-release.zip"
URL="$RELEASE_URL/${DART_VER}/sdk/$SDK"

# Check that zip does exist before installing deps
curl -ILO "$URL" 

export DEBIAN_FRONTEND="noninteractive"
apt update
apt install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    xz-utils \
    zip \
    file

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
amd64)
    SDK_ARCH="x64"
    ;;
armhf)
    SDK_ARCH="arm"
    ;;
arm64)
    SDK_ARCH="arm64"
    ;;
esac

curl -fLO "$URL"
curl -Ls "$URL.sha256sum" | sha256sum --check --status --strict -
unzip "$SDK"
mv dart-sdk "$DART_ROOT"
rm "$SDK"
chmod 755 "$DART_ROOT"
chmod 755 "$DART_ROOT/bin"
