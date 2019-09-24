####################################
# PHPDocker.io PHP  / CLI image #
####################################
FROM ubuntu:bionic

# Fixes some weird terminal issues such as broken clear / CTRL+L
ENV TERM=linux

# Ensure apt doesn't ask questions when installing stuff
ENV DEBIAN_FRONTEND=noninteractive

# Install Ondrej repos for Ubuntu Bionic, PHP, composer and selected extensions - better selection than
# the distro's packages
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        unzip \
        php-apcu \
        php-apcu-bc \
        php-cli \
        php-fpm \
        php-curl \
        php-json \
        php-mysql \
        php-gd \
        php-gmp \
        php-imap \
        php-mbstring \
        php-opcache \
        php-readline \
        php-mailparse \
        php-xml \
        php-zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require hirak/prestissimo \
    && composer clear-cache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer \
    && curl http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz > ioncube_loaders_lin_x86-64.tar.gz \
    && tar xzf ioncube_loaders_lin_x86-64.tar.gz -C /usr/local \
    && php -i | grep php.ini \
    && echo 'zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.2.so' >> /etc/php/7.2/cli/php.ini \
    && echo 'zend_extension = /usr/local/ioncube/ioncube_loader_lin_7.2.so' >> /etc/php/7.2/fpm/php.ini \
    && php -m \
    && ln -s /usr/sbin/php-fpm7.2 /usr/sbin/php-fpm
STOPSIGNAL SIGQUIT

# PHP-FPM packages need a nudge to make them docker-friendly
COPY overrides.conf /etc/php/7.2/fpm/pool.d/z-overrides.conf

CMD ["/usr/sbin/php-fpm", "-O" ]

# Open up fcgi port
EXPOSE 9000
