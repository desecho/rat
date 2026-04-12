#!/bin/bash
set -euo pipefail

APP_NAME="Rat"
BUNDLE="${APP_NAME}.app"
DIST_DIR="dist"

rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

rm -rf "${BUNDLE}"
./build.sh
ditto -c -k --sequesterRsrc --keepParent "${BUNDLE}" "${DIST_DIR}/rat-arm.zip"

rm -rf "${BUNDLE}"
./build_intel.sh
ditto -c -k --sequesterRsrc --keepParent "${BUNDLE}" "${DIST_DIR}/rat-x86.zip"

echo "Built ${DIST_DIR}/rat-arm.zip and ${DIST_DIR}/rat-x86.zip successfully."
