# Set defaults
ARG BASE_IMAGE="php:7.2-alpine"
ARG PACKAGIST_NAME="smartbeetles/phpqa"
ARG PHPQA_NAME="phpqa"
ARG VERSION="0.0.1"

# Base image with alias
FROM ${BASE_IMAGE} as prepare

ARG COMPOSER_IMAGE
ARG PACKAGIST_NAME
ARG VERSION
ARG PHPQA_NAME
ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG IMAGE_NAME

# Install addition packages
RUN apk update \
    && apk add \
    libxslt-dev \
    bash
RUN docker-php-ext-install simplexml xsl

# Install Tini - https://github.com/krallin/tini
RUN apk add --no-cache tini

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
                    magento/magento-coding-standard \
                    belvg/phpqa-phpcbf:1.0.3

FROM prepare

# Add Magento 2 standards to PHP CodeSniffer
RUN phpcs --config-set installed_paths /composer/vendor/magento/magento-coding-standard/Magento2

# Main config file changed
COPY ./.phpqa.yml /composer/vendor/edgedesign/phpqa/

# Add image labels
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="phpqa" \
      org.label-schema.name="${PHPQA_NAME}" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.url="https://github.com/smartbeetles/${PHPQA_NAME}" \
      org.label-schema.usage="https://github.com/smartbeetles/${PHPQA_NAME}/README.md" \
      org.label-schema.vcs-url="https://github.com/smartbeetles/${PHPQA_NAME}.git" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.docker.cmd="docker run --rm --volume \${PWD}:/app --workdir /app ${IMAGE_NAME}"

VOLUME ["/app"]
WORKDIR /app
