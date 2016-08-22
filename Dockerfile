FROM php:7.0.9-apache

ENV PHPREDIS_VERSION 3.0.0

RUN apt-get update
RUN apt-get install -qq apt-utils -y
RUN apt-get install -qq -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        curl \
        libcurl4-gnutls-dev \
        libz-dev \
        libpq-dev \
        mysql-client \
        supervisor \
        libpng12-dev \
        libxml2-dev \
        openssl \
        libssl-dev \
        libpq-dev \
        libmemcached-dev \
        git \
        gcc \
        sudo

RUN docker-php-ext-install -j$(nproc) mcrypt
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) pdo_pgsql
RUN docker-php-ext-install -j$(nproc) xml
RUN docker-php-ext-install -j$(nproc) soap
RUN docker-php-ext-install -j$(nproc) xmlrpc
RUN docker-php-ext-install -j$(nproc) curl
RUN docker-php-ext-install -j$(nproc) simplexml
RUN docker-php-ext-install -j$(nproc) zip

RUN docker-php-ext-configure gd --with-png-dir=/usr --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install bcmath opcache

# Install memcache
RUN pecl install redis \
    && docker-php-ext-enable redis

RUN { \
  echo 'extension=redis.so'; \
} > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini

RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* \

# get from https://github.com/docker-library/drupal/blob/master/8.1/apache/Dockerfile
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

ADD php.ini /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
