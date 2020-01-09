# Base image with alias
FROM php:7.2-alpine as prepare

# Install addition packages
RUN apk update \
    && apk add \
    libxslt-dev
RUN docker-php-ext-install simplexml xsl

# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Add global binary directory to PATH and make sure to re-export it
ENV PATH /composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Copy lastest composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Tools
RUN composer global require edgedesign/phpqa \
                    composer/xdebug-handler \
                    jakub-onderka/php-parallel-lint \
                    jakub-onderka/php-console-highlighter \
                    friendsofphp/php-cs-fixer:~2.2 \
                    sensiolabs/security-checker \
                    vimeo/psalm \
                    phpstan/phpstan \
                    nette/neon phpunit/phpunit \
                    magento/magento-coding-standard

FROM prepare

# Add Magento 2 standard to PHP CodeSniffer
RUN ln -s /composer/vendor/magento/magento-coding-standard/Magento2 /composer/vendor/squizlabs/php_codesniffer/src/Standards

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["phpqa"]
CMD ["--help"]