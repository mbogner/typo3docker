#!/bin/bash
mkdir -p "$TYPO3_HOME"/var/transient
touch "$TYPO3_HOME"/var/transient/ENABLE_INSTALL_TOOL
chown www-data:www-data "$TYPO3_HOME"/var/transient/ENABLE_INSTALL_TOOL