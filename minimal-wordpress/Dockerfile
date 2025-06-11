# Multi-stage build for production WordPress
# Author: DevKraken (soman@devkraken.com)
# Optimized minimal WordPress container for small sites - PHP-FPM only
FROM wordpress:6.6-php8.3-fpm-alpine as production

# Metadata labels for professional container management
LABEL maintainer="DevKraken <soman@devkraken.com>" \
      version="1.0.0" \
      description="Production-ready WordPress PHP-FPM container" \
      org.opencontainers.image.title="Minimal WordPress PHP-FPM" \
      org.opencontainers.image.description="Enterprise WordPress PHP-FPM container" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="DevKraken" \
      org.opencontainers.image.licenses="MIT"

# Single RUN layer for better performance and smaller image
RUN apk update && apk upgrade && \
    # Install runtime dependencies (allow latest versions)
    apk add --no-cache --upgrade \
    curl \
    imagemagick \
    ghostscript \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    && \
    # Install build dependencies
    apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    && \
    # Configure and install PHP extensions
    docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mysqli \
    exif \
    gd \
    zip \
    && \
    # Install OPcache only if not already available
    (php -m | grep -q OPcache || docker-php-ext-install opcache) \
    && \
    # Cleanup
    apk del .build-deps \
    && rm -rf /var/cache/apk/* /tmp/*

# Set up directory structure with proper www-data ownership for WordPress functionality
RUN mkdir -p /var/www/html/wp-content/uploads && \
    mkdir -p /var/www/html/wp-content/cache && \
    mkdir -p /var/www/html/wp-content/themes && \
    mkdir -p /var/www/html/wp-content/plugins && \
    mkdir -p /tmp/sessions && \
    # Set proper ownership for WordPress to function (install plugins, themes, updates)
    chown -R www-data:www-data /var/www/html && \
    # Set permissions for WordPress functionality
    chmod -R 755 /var/www/html && \
    chmod -R 775 /var/www/html/wp-content && \
    chmod -R 755 /tmp/sessions

# Copy PHP configuration files
COPY docker/php.ini /usr/local/etc/php/conf.d/wordpress.ini
COPY docker/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker/healthcheck.sh /usr/local/bin/healthcheck.sh
COPY docker/verify-php.sh /usr/local/bin/verify-php.sh
COPY docker/docker-entrypoint.sh /usr/local/bin/custom-entrypoint.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/healthcheck.sh && \
    chmod +x /usr/local/bin/verify-php.sh && \
    chmod +x /usr/local/bin/custom-entrypoint.sh

# Health check for PHP-FPM
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh || exit 1

EXPOSE 9000

# Default: Standard WordPress entrypoint
CMD ["php-fpm"]

# Alternative: Custom entrypoint with verification (uncomment to use)
# ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
# CMD ["php-fpm"]