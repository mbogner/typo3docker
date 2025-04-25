#!/bin/sh
set -e

# Check if public/index.php exists
if [ ! -f /var/www/html/public/index.php ]; then
  echo "No TYPO3 installation found in volume, setting up..."
  composer create-project typo3/cms-base-distribution /var/www/html ^13 --no-dev --no-interaction
  chown -R www-data:www-data /var/www/html
  echo "Running TYPO3 setup..."
  vendor/bin/typo3 setup \
      --admin-user-password "$ADMIN_PASSWORD" \
      --password "$DB_PASSWORD"
  chown -R www-data:www-data /var/www/html
fi

# Patch settings.php if it exists
if [ -f /var/www/html/config/system/settings.php ]; then
  echo "Patching /var/www/html/config/system/settings.php..."
  # shellcheck disable=SC2016
  php -r '
    $cfgFile = "/var/www/html/config/system/settings.php";
    $cfg = include $cfgFile;
    $cfg["SYS"]["trustedHostsPattern"] = getenv("TRUSTED_HOST_PATTERN");
    $cfg["SYS"]["displayErrors"] = getenv("TYPO3_DISPLAY_ERRORS");
    $cfg["BE"]["entryPoint"] = getenv("TYPO3_BACKEND_PATH");
    file_put_contents($cfgFile, "<?php return " . var_export($cfg, true) . ";");
  '

  # Clear TYPO3 caches after patch
  echo "Clearing TYPO3 caches..."
  rm -rf /var/www/html/var/cache/*
fi

exec php-fpm