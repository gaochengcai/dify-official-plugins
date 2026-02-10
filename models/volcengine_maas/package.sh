#!/bin/bash

# Dify Volcengine MaaS Custom Plugin Packaging Script
# This script packages the volcengine_maas_custom plugin into a .difypkg file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Auto-increment patch version in manifest.yaml
OLD_VERSION=$(grep "^version:" manifest.yaml | awk '{print $2}')
IFS='.' read -r MAJOR MINOR PATCH <<< "$OLD_VERSION"
PATCH=$((PATCH + 1))
VERSION="${MAJOR}.${MINOR}.${PATCH}"
sed -i '' "s/^version: .*/version: ${VERSION}/" manifest.yaml
PACKAGE_NAME="volcengine_maas_custom.difypkg"

echo "📦 Packaging Volcengine MaaS Custom Plugin v${OLD_VERSION} → v${VERSION}..."

# Clean up old package
rm -f "$PACKAGE_NAME"

# Clean up Python cache files
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".DS_Store" -delete 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true

# Package the plugin
zip -rD "$PACKAGE_NAME" \
    manifest.yaml \
    main.py \
    pyproject.toml \
    requirements.txt \
    README.md \
    models \
    provider \
    legacy \
    _assets \
    -x "*.pyc" \
    -x "*/__pycache__/*" \
    -x ".venv/*" \
    -x "*.egg-info/*"

# Calculate SHA256 hash
SHA256=$(shasum -a 256 "$PACKAGE_NAME" | awk '{print $1}')

echo ""
echo "✅ Package created successfully!"
echo "📁 File: $SCRIPT_DIR/$PACKAGE_NAME"
echo "📊 Size: $(ls -lh "$PACKAGE_NAME" | awk '{print $5}')"
echo "🔑 SHA256: $SHA256"
echo ""
echo "To install:"
echo "1. Upload $PACKAGE_NAME to Dify"
echo "2. Check logs: docker compose exec plugin_daemon cat /tmp/volcengine_custom.log"
