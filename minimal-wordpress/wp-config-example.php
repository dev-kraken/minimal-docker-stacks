<?php
/**
 * WordPress Configuration File
 * 
 * This file reads configuration from environment variables
 * Compatible with Docker, Nginx, and GitLab CI/CD
 * 
 * @package WordPress
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

/**
 * Load environment variables from .env file if it exists
 * This is useful for local development
 */
if (file_exists(ABSPATH . '.env')) {
    $lines = file(ABSPATH . '.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        // Skip comments and empty lines
        if (strpos(trim($line), '#') === 0 || empty(trim($line))) {
            continue;
        }
        
        // Parse KEY=VALUE pairs
        if (strpos($line, '=') !== false) {
            list($name, $value) = explode('=', $line, 2);
            $name = trim($name);
            $value = trim($value, " \t\n\r\0\x0B\"'");
            
            // Only set if not already defined in environment
            if (!array_key_exists($name, $_SERVER) && !array_key_exists($name, $_ENV)) {
                putenv(sprintf('%s=%s', $name, $value));
                $_ENV[$name] = $value;
                $_SERVER[$name] = $value;
            }
        }
    }
}

/**
 * Helper function to get environment variables with fallback
 * 
 * @param string $key Environment variable key
 * @param mixed $default Default value if not found
 * @return mixed
 */
function env($key, $default = null) {
    $value = getenv($key);
    
    if ($value === false) {
        return $default;
    }
    
    // Handle boolean values
    switch (strtolower($value)) {
        case 'true':
        case '(true)':
            return true;
        case 'false':
        case '(false)':
            return false;
        case 'empty':
        case '(empty)':
            return '';
        case 'null':
        case '(null)':
            return null;
    }
    
    return $value;
}

// ==============================================
// DATABASE CONFIGURATION
// ==============================================
// WordPress Docker uses specific environment variable names
define('DB_NAME', env('WORDPRESS_DB_NAME', env('MYSQL_DATABASE', 'wordpress')));
define('DB_USER', env('WORDPRESS_DB_USER', env('MYSQL_USER', 'wordpress')));
define('DB_PASSWORD', env('WORDPRESS_DB_PASSWORD', env('MYSQL_PASSWORD', 'password')));
define('DB_HOST', env('WORDPRESS_DB_HOST', 'mysql:3306'));
define('DB_CHARSET', env('DB_CHARSET', 'utf8mb4'));
define('DB_COLLATE', env('DB_COLLATE', ''));

// Database table prefix
$table_prefix = env('WORDPRESS_TABLE_PREFIX', env('DB_PREFIX', 'wp_'));

// ==============================================
// WORDPRESS URLS
// ==============================================
define('WP_HOME', env('WP_HOME', 'http://localhost'));
define('WP_SITEURL', env('WP_SITEURL', env('WP_HOME', 'http://localhost')));

// ==============================================
// SSL & HTTPS CONFIGURATION
// ==============================================
if (env('FORCE_SSL_ADMIN', false)) {
    define('FORCE_SSL_ADMIN', true);
}

// Handle reverse proxy (Docker/Nginx setup)
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
}

if (isset($_SERVER['HTTP_X_FORWARDED_HOST'])) {
    $_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
}

if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_FORWARDED_FOR'];
}

// ==============================================
// WORDPRESS SECURITY KEYS & SALTS
// ==============================================
// Use Docker environment variable names first, fallback to generic names
define('AUTH_KEY',         env('WORDPRESS_AUTH_KEY', env('AUTH_KEY', 'put your unique phrase here')));
define('SECURE_AUTH_KEY',  env('WORDPRESS_SECURE_AUTH_KEY', env('SECURE_AUTH_KEY', 'put your unique phrase here')));
define('LOGGED_IN_KEY',    env('WORDPRESS_LOGGED_IN_KEY', env('LOGGED_IN_KEY', 'put your unique phrase here')));
define('NONCE_KEY',        env('WORDPRESS_NONCE_KEY', env('NONCE_KEY', 'put your unique phrase here')));
define('AUTH_SALT',        env('WORDPRESS_AUTH_SALT', env('AUTH_SALT', 'put your unique phrase here')));
define('SECURE_AUTH_SALT', env('WORDPRESS_SECURE_AUTH_SALT', env('SECURE_AUTH_SALT', 'put your unique phrase here')));
define('LOGGED_IN_SALT',   env('WORDPRESS_LOGGED_IN_SALT', env('LOGGED_IN_SALT', 'put your unique phrase here')));
define('NONCE_SALT',       env('WORDPRESS_NONCE_SALT', env('NONCE_SALT', 'put your unique phrase here')));

// ==============================================
// WORDPRESS DEBUG CONFIGURATION
// ==============================================
define('WP_DEBUG', env('WP_DEBUG', env('DEBUG_MODE', false)));
define('WP_DEBUG_LOG', env('WP_DEBUG_LOG', WP_DEBUG));
define('WP_DEBUG_DISPLAY', env('WP_DEBUG_DISPLAY', false));
define('SCRIPT_DEBUG', env('SCRIPT_DEBUG', WP_DEBUG));

// Custom debug log location for Docker
if (WP_DEBUG && WP_DEBUG_LOG) {
    ini_set('log_errors', 1);
    // Use Docker-friendly log path
    ini_set('error_log', '/var/www/html/wp-content/debug/debug.log');
}

// ==============================================
// WORDPRESS ENVIRONMENT
// ==============================================
define('WP_ENV', env('ENVIRONMENT', env('WP_ENV', 'production')));

// ==============================================
// WORDPRESS CONTENT DIRECTORY
// ==============================================
if (env('WP_CONTENT_DIR')) {
    define('WP_CONTENT_DIR', env('WP_CONTENT_DIR'));
}
if (env('WP_CONTENT_URL')) {
    define('WP_CONTENT_URL', env('WP_CONTENT_URL'));
}

// ==============================================
// WORDPRESS MEMORY & PERFORMANCE
// ==============================================
define('WP_MEMORY_LIMIT', env('WORDPRESS_MEMORY_LIMIT', env('WP_MEMORY_LIMIT', '512M')));
define('WP_MAX_MEMORY_LIMIT', env('WORDPRESS_MAX_MEMORY_LIMIT', env('WP_MAX_MEMORY_LIMIT', '1024M')));

// ==============================================
// WORDPRESS UPLOADS
// ==============================================
if (env('UPLOADS_DIR')) {
    define('UPLOADS', env('UPLOADS_DIR'));
}

// File upload limits (match Docker configuration)
@ini_set('upload_max_filesize', env('PHP_UPLOAD_MAX_FILESIZE', '64M'));
@ini_set('post_max_size', env('PHP_POST_MAX_SIZE', '64M'));

// ==============================================
// WORDPRESS SECURITY SETTINGS
// ==============================================
define('DISALLOW_FILE_EDIT', env('DISALLOW_FILE_EDIT', true));
define('DISALLOW_FILE_MODS', env('DISALLOW_FILE_MODS', true));
define('AUTOMATIC_UPDATER_DISABLED', env('AUTOMATIC_UPDATER_DISABLED', true));

// ==============================================
// WORDPRESS UPDATES
// ==============================================
define('WP_AUTO_UPDATE_CORE', env('WP_AUTO_UPDATE_CORE', false));

// ==============================================
// WORDPRESS CRON
// ==============================================
define('DISABLE_WP_CRON', env('DISABLE_WP_CRON', false));

// ==============================================
// WORDPRESS POST REVISIONS & TRASH
// ==============================================
define('WP_POST_REVISIONS', env('WP_POST_REVISIONS', 3));
define('MEDIA_TRASH', env('MEDIA_TRASH', true));
define('EMPTY_TRASH_DAYS', env('EMPTY_TRASH_DAYS', 30));

// ==============================================
// WORDPRESS COOKIE CONFIGURATION
// ==============================================
if (env('COOKIE_DOMAIN')) {
    define('COOKIE_DOMAIN', env('COOKIE_DOMAIN'));
}

// ==============================================
// WORDPRESS DATABASE REPAIR
// ==============================================
if (env('WP_ALLOW_REPAIR', false)) {
    define('WP_ALLOW_REPAIR', true);
}

// ==============================================
// PERFORMANCE OPTIMIZATIONS
// ==============================================
// Use Docker environment settings
define('COMPRESS_CSS', env('COMPRESS_CSS', true));
define('COMPRESS_SCRIPTS', env('COMPRESS_SCRIPTS', true));
define('CONCATENATE_SCRIPTS', env('CONCATENATE_SCRIPTS', false));
define('ENFORCE_GZIP', env('ENFORCE_GZIP', true));

// ==============================================
// WORDPRESS CACHING
// ==============================================
define('WP_CACHE', env('WP_CACHE', true));

// ==============================================
// CUSTOM ERROR HANDLING
// ==============================================
if (WP_DEBUG && WP_DEBUG_LOG) {
    // Custom error handler for Docker environments
    if (env('ERROR_LOG_PATH')) {
        ini_set('error_log', env('ERROR_LOG_PATH'));
    }
}

// ==============================================
// WORDPRESS LANGUAGE
// ==============================================
define('WPLANG', env('WPLANG', ''));

// ==============================================
// WORDPRESS TIMEZONE
// ==============================================
if (env('WP_TIMEZONE')) {
    date_default_timezone_set(env('WP_TIMEZONE'));
}

// ==============================================
// FILE PERMISSIONS (Docker optimized)
// ==============================================
@ini_set('default_fileperms', 0755);
@ini_set('default_dirperms', 0755);

// ==============================================
// WORDPRESS MEDIA HANDLING
// ==============================================
define('ALLOW_UNFILTERED_UPLOADS', env('ALLOW_UNFILTERED_UPLOADS', false));
define('IMAGE_EDIT_OVERWRITE', env('IMAGE_EDIT_OVERWRITE', true));

// ==============================================
// LOAD WORDPRESS
// ==============================================
require_once ABSPATH . 'wp-settings.php';