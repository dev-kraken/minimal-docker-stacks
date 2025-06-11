# Custom Nginx for Dynamic Project
ARG NGINX_VERSION=1.24-alpine
FROM nginx:${NGINX_VERSION}

# Copy custom configurations
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY security-headers.conf /etc/nginx/security-headers.conf

# Copy optional quiet entrypoint (uncomment CMD below to use)
COPY docker-entrypoint-quiet.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-quiet.sh

# Create cache directory for FastCGI
RUN mkdir -p /var/cache/nginx/fastcgi && \
    chown -R nginx:nginx /var/cache/nginx/

# Labels for identification
ARG PROJECT_NAME=devkraken
LABEL maintainer="${PROJECT_NAME}"
LABEL description="Custom Nginx for WordPress"
LABEL version="1.0"
LABEL project="${PROJECT_NAME}"

EXPOSE 80

# Default: Standard nginx entrypoint (shows startup info)
CMD ["nginx", "-g", "daemon off;"]

# Alternative: Quiet entrypoint (minimal startup logs)
# CMD ["/usr/local/bin/docker-entrypoint-quiet.sh"] 