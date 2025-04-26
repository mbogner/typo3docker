#!/bin/sh
set -e

# Check if public/index.php exists
if [ ! -f "$TYPO3_HOME"/public/index.php ]; then
  echo "No TYPO3 installation found in volume, setting up..."
  composer create-project typo3/cms-base-distribution "$TYPO3_HOME" ^13 --no-dev --no-interaction
  chown -R www-data:www-data "$TYPO3_HOME"
  echo "Running TYPO3 setup..."
  vendor/bin/typo3 setup \
      --admin-user-password "$ADMIN_PASSWORD" \
      --password "$DB_PASSWORD"
  chown -R www-data:www-data "$TYPO3_HOME"

  echo "Installing extensions..."
  composer require typo3/cms-scheduler
  vendor/bin/typo3 extension:setup --no-interaction
fi

# Patch settings.php if it exists
if [ -f "$TYPO3_HOME"/config/system/settings.php ]; then
  echo "Patching $TYPO3_HOME/config/system/settings.php..."
  # shellcheck disable=SC2016
  php -r '
    $cfgFile = "/var/www/html/config/system/settings.php";
    $cfg = include $cfgFile;
    $cfg["SYS"]["trustedHostsPattern"] = getenv("TRUSTED_HOST_PATTERN");
    $cfg["SYS"]["displayErrors"] = getenv("TYPO3_DISPLAY_ERRORS");

    $cfg["BE"]["entryPoint"] = getenv("TYPO3_BACKEND_PATH");

    $cfg["MAIL"]["transport"] = getenv("TYPO3_MAIL_TRANSPORT");
    unset($cfg["MAIL"]["transport_sendmail_command"]);
    $cfg["MAIL"]["transport_smtp_server"] = getenv("TYPO3_MAIL_TRANSPORT_SMTP_SERVER");
    $cfg["MAIL"]["transport_smtp_username"] = getenv("TYPO3_MAIL_TRANSPORT_SMTP_USERNAME");
    $cfg["MAIL"]["transport_smtp_password"] = getenv("TYPO3_MAIL_TRANSPORT_SMTP_PASSWORD");
    $cfg["MAIL"]["transport_smtp_encrypt"] = getenv("TYPO3_MAIL_TRANSPORT_SMTP_ENCRYPT");
    $cfg["MAIL"]["defaultMailFromAddress"] = getenv("TYPO3_DEFAULT_MAIL_FROM_ADDRESS");

    file_put_contents($cfgFile, "<?php return " . var_export($cfg, true) . ";");
  '
fi

echo "Starting Cron..."
cat <<EOF | tee /etc/cron.d/typo3_scheduler

* * * * * www-data /usr/local/bin/php /var/www/html/vendor/bin/typo3 scheduler:run --no-interaction

EOF
chmod 0644 /etc/cron.d/typo3_scheduler
service cron start

echo "Clearing TYPO3 caches..."
rm -rf "$TYPO3_HOME"/var/cache/*

chown -R www-data:www-data "$TYPO3_HOME"
chmod 2775 "$TYPO3_HOME"
chmod 2775 "$TYPO3_HOME"/public

exec php-fpm