FROM php:7.2-fpm
EXPOSE 9000
ARG ARG_PHP_VERSION=7.2
ARG ARG_IONCUBE_VERSION=10.3.2
ARG ARG_URL=https://secure.gurock.com/downloads/testrail/testrail-latest-ion71.zip
ENV TR_DEFAULT_TASK_EXECUTION=60
ENV TR_CONFIGPATH="/var/www/testrail/config/"
ENV TR_DEFAULT_LOG_DIR="/opt/testrail/logs/"
ENV TR_DEFAULT_AUDIT_DIR="/opt/testrail/audit/"
ENV TR_DEFAULT_REPORT_DIR="/opt/testrail/reports/"
ENV TR_DEFAULT_ATTACHMENT_DIR="/opt/testrail/attachments/"
ENV OPENSSL_CONF=/etc/ssl/
RUN apt-get update \
      && apt-get -y install --no-install-recommends \
        curl                 \
        iputils-ping         \
        libcurl4-gnutls-dev  \
        libfontconfig1       \
        libldap2-dev         \
        libxml2-dev          \
        mariadb-client       \
        openssl              \
        unzip                \
        wget                 \
        zip                  \
        zlib1g-dev           \
      && apt-get clean                              \
      && rm -rf /var/lib/apt/lists/* 

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu

RUN docker-php-ext-install curl            \ 
      && docker-php-ext-install json       \
      && docker-php-ext-install ldap       \
      && docker-php-ext-install mbstring   \
      && docker-php-ext-install mysqli     \
      && docker-php-ext-install pdo        \
      && docker-php-ext-install pdo_mysql  \
      && docker-php-ext-install xmlrpc     \
      && docker-php-ext-install zip        

RUN wget --no-check-certificate -O /tmp/testrail.zip ${ARG_URL}                                            \
      && mkdir -p /var/www/testrail                                                                        \
      &&  mkdir -p /opt/testrail/attachments /opt/testrail/reports /opt/testrail/logs /opt/testrail/audit  \
      && unzip /tmp/testrail.zip -d /var/www/                                                              \
      && rm /tmp/testrail.zip                                                                              \
      && chown -R www-data:www-data /var/www/testrail                                                      \
      && chown -R www-data:www-data /opt/testrail

COPY php.ini /usr/local/etc/php/conf.d/php.ini

# download ioncube, extract to /opt/ioncube
RUN wget  -O /tmp/ioncube.tar.gz http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_${ARG_IONCUBE_VERSION}.tar.gz  \
      && tar -xzf /tmp/ioncube.tar.gz -C /tmp                                                                                            \
      && mv /tmp/ioncube /opt/ioncube                                                                                                    \
      && echo zend_extension=/opt/ioncube/ioncube_loader_lin_${ARG_PHP_VERSION}.so >> /usr/local/etc/php/php.ini                         \
      && rm -f /tmp/ioncube.tar.gz


