#!/bin/bash

set -e

mkdir -p artifacts

tar -czf "artifacts/${APP_NAME}-${VERSION}.tar.gz" .

sha256sum "artifacts/${APP_NAME}-${VERSION}.tar.gz" \
    > "artifacts/${APP_NAME}-${VERSION}.sha256"

cat > "artifacts/artifact-manifest.json" <<EOF
{
  "application": "${APP_NAME}",
  "version": "${VERSION}",
  "build_number": "${BUILD_NUMBER}",
  "artifact": "${APP_NAME}-${VERSION}.tar.gz"
}
EOF
