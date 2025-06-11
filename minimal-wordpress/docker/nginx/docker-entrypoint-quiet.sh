#!/bin/bash
# Quieter nginx entrypoint
# Reduces startup verbosity while maintaining functionality

set -e

# Run the original entrypoint scripts silently
export NGINX_ENTRYPOINT_QUIET_LOGS=1

# Process entrypoint.d scripts quietly
for f in /docker-entrypoint.d/*; do
    case "$f" in
        *.sh)
            if [ -x "$f" ]; then
                echo "Starting nginx configuration..."
                "$f" >/dev/null 2>&1
            fi
            ;;
    esac
done

echo "✅ Nginx configured and ready"

# Start nginx
exec nginx -g 'daemon off;' 