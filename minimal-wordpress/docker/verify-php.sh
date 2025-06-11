#!/bin/bash
# PHP Configuration Verification Script
# Ensures clean PHP-FPM startup

echo "🔧 Verifying PHP configuration..."

# Check PHP syntax of all configuration files
echo "   ✓ Checking PHP configuration syntax..."
php -t || exit 1

# Check if OPcache is available
if php -m | grep -q OPcache; then
    echo "   ✓ OPcache extension loaded"
else
    echo "   ⚠️ OPcache not available"
fi

# Check WordPress-specific settings
echo "   ✓ Memory limit: $(php -r 'echo ini_get("memory_limit");')"
echo "   ✓ Upload max filesize: $(php -r 'echo ini_get("upload_max_filesize");')"
echo "   ✓ Max execution time: $(php -r 'echo ini_get("max_execution_time");')s"

echo "✅ PHP configuration verified successfully"
echo "🚀 Starting PHP-FPM..." 