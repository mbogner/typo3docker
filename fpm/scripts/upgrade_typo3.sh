#!/bin/bash
set -e
composer update typo3/cms-core --with-all-dependencies
typo3 cache:flush --no-interaction
typo3 upgrade:run --no-interaction
echo "Now run Maintenance > Analyze Database Structure"
echo "URL: ${TYPO3_SETUP_CREATE_SITE}${TYPO3_BACKEND_PATH:-/typo3}/module/tools/maintenance"