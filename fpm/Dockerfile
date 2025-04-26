FROM php:8.4-fpm

# Install dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libxml2-dev \
    libjpeg-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libfreetype6-dev \
    libxslt1-dev \
    libpq-dev \
    cron \
    procps \
    && docker-php-ext-install -j$(nproc) \
    pdo \
    pdo_pgsql \
    pgsql \
    zip \
    intl \
    gd \
    xsl \
    xml \
    opcache \
    bcmath \
    mysqli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html
VOLUME /var/www/html

# Create PHP settings for TYPO3
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/typo3.ini && \
    echo "max_execution_time=240" >> /usr/local/etc/php/conf.d/typo3.ini && \
    echo "max_input_vars=1500" >> /usr/local/etc/php/conf.d/typo3.ini && \
    echo "upload_max_filesize=50M" >> /usr/local/etc/php/conf.d/typo3.ini && \
    echo "post_max_size=50M" >> /usr/local/etc/php/conf.d/typo3.ini

COPY fpm_entrypoint.sh /entrypoint.sh
COPY scripts/* /usr/local/bin/
RUN chmod +x /entrypoint.sh /usr/local/bin/*.sh

ENTRYPOINT ["/entrypoint.sh"]

ENV TYPO3_HOME=/var/www/html
ENV PATH="${PATH}:${TYPO3_HOME}/vendor/bin"