#!/bin/bash
# Custom WordPress PHP-FPM Entrypoint
# Provides clean startup with configuration verification

set -e

echo "🐘 WordPress PHP-FPM Container Starting..."

# Run PHP verification
/usr/local/bin/verify-php.sh

# Run the original WordPress entrypoint
exec docker-entrypoint.sh "$@" 