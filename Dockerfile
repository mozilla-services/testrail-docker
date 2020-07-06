FROM php:7.2-fpm

WORKDIR /app
COPY . /app

RUN apt-get update \
      && apt-get -y install --no-install-recommends curl zlib1g-dev libxml2-dev

# download ioncube, extract to /opt/ioncube
RUN curl -sS http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz > /tmp/ioncube.tar.gz && \
    mkdir -p /opt/ioncube/ && \
    tar xzf /tmp/ioncube.tar.gz -C /opt/ioncube --strip-components=1

# ldap extension for auth
# RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
# RUN docker-php-ext-install ldap

# for json
RUN docker-php-ext-install json

# for testrail background task
RUN docker-php-ext-install zip

# for bugzilla defect plugin
RUN docker-php-ext-install xmlrpc

# mysql extension (deprecated) required for testrail
RUN docker-php-ext-install pdo pdo_mysql mysqli

# enables ioncube
COPY php.ini /usr/local/etc/php/conf.d/php.ini

EXPOSE 9000

# CMD is inherited from base container- it is php-fpm
