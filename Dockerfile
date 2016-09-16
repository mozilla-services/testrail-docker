FROM php:5.6-fpm

RUN apt-get update && apt-get -y install --no-install-recommends curl unzip

# download ioncube, extract to /opt/ioncube
RUN curl -sS http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz > /tmp/ioncube.tar.gz && \
    mkdir -p /opt/ioncube/ && \
    tar xzf /tmp/ioncube.tar.gz -C /opt/ioncube --strip-components=1

# download testrail
# RUN curl -L http://www.gurock.com/downloads/testrail/testrail-latest-ion53.zip > /tmp/testrail.zip && \
#     mkdir -p /testrail && \
#     # unzip to /testrail
#     unzip /tmp/testrail.zip -d / && \
#     chown -R www-data:www-data /testrail && \
#     chmod -R 755 /testrail

# mysql extension (deprecated) required for testrail
RUN docker-php-ext-install mysql

# enables ioncube
COPY php.ini /usr/local/etc/php/conf.d/php.ini

EXPOSE 9000
