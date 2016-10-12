FROM php:5.6-fpm

WORKDIR /app
COPY . /app

RUN apt-get update && apt-get -y install --no-install-recommends curl php5-ldap

# download ioncube, extract to /opt/ioncube
RUN curl -sS http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz > /tmp/ioncube.tar.gz && \
    mkdir -p /opt/ioncube/ && \
    tar xzf /tmp/ioncube.tar.gz -C /opt/ioncube --strip-components=1

# mysql extension (deprecated) required for testrail
RUN docker-php-ext-install mysql

# enables ioncube
COPY php.ini /usr/local/etc/php/conf.d/php.ini

EXPOSE 9000

# CMD is inherited from php:5.6fpm - it is php-fpm
