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

# Patch trustedHostsPattern if settings.php exists
if [ -n "$TRUSTED_HOST_PATTERN" ] && [ -f /var/www/html/config/system/settings.php ]; then
  echo "Patching trustedHostsPattern to $TRUSTED_HOST_PATTERN..."
  # shellcheck disable=SC2016
  php -r '
    $cfgFile = "/var/www/html/config/system/settings.php";
    $cfg = include $cfgFile;
    $cfg["SYS"]["trustedHostsPattern"] = getenv("TRUSTED_HOST_PATTERN");
    file_put_contents($cfgFile, "<?php return " . var_export($cfg, true) . ";");
  '
fi

exec php-fpm