FROM php:7.2-fpm
# Change this as needed to match container
ARG ARG_PHP_VERSION=7.2
# Change this to update
ARG ARG_IONCUBE_VERSION=10.4.3
ENV TR_DEFAULT_TASK_EXECUTION=60
ENV TR_CONFIGPATH="/var/www/testrail/config/"
ENV TR_DEFAULT_LOG_DIR="/opt/testrail/logs/"
ENV TR_DEFAULT_AUDIT_DIR="/opt/testrail/audit/"
ENV TR_DEFAULT_REPORT_DIR="/opt/testrail/reports/"
ENV TR_DEFAULT_ATTACHMENT_DIR="/opt/testrail/attachments/"
ENV OPENSSL_CONF=/etc/ssl/

RUN apt-get update                                  \
      && apt-get -y install --no-install-recommends \
        curl                                        \
        iputils-ping                                \
        libcurl4-gnutls-dev                         \
        libfontconfig1                              \
        libldap2-dev                                \
        libonig5                                    \
        libonig-dev                                 \
        libxml2-dev                                 \
        libzip4                                     \
        libzip-dev                                  \
        mariadb-client                              \
        openssl                                     \
        unzip                                       \
        vim-nox                                     \
        wget                                        \
        zip                                         \
        zlib1g-dev                                  \
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

# This will download the latest release from GuRock. We might not want that.
# RUN wget --no-check-certificate -O /tmp/testrail.zip ${ARG_URL}                                            \
#       && mkdir -p /var/www/testrail                                                                        \
#       && mkdir -p /opt/testrail/attachments  \
#                    /opt/testrail/reports     \
#                    /opt/testrail/logs        \
#                    /opt/testrail/audit                                                                     \
#       && unzip /tmp/testrail.zip -d /var/www/                                                              \
#       && rm /tmp/testrail.zip                                                                              \
#       && chown -R www-data:www-data /var/www/testrail                                                      \
#       && chown -R www-data:www-data /opt/testrail
#
RUN mkdir -p /var/www/testrail                 \
      &&  mkdir -p /opt/testrail/attachments   \
                   /opt/testrail/reports       \
                   /opt/testrail/logs          \
                   /opt/testrail/audit

COPY php.ini /usr/local/etc/php/conf.d/php.ini

RUN wget  -O /tmp/ioncube.tar.gz                                                                              \
      http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_${ARG_IONCUBE_VERSION}.tar.gz  \
      && tar -xzf /tmp/ioncube.tar.gz -C /tmp                                                                 \
      && mv /tmp/ioncube /opt/ioncube                                                                         \
      && rm -f /tmp/ioncube.tar.gz                                                                            \
      && echo zend_extension=/opt/ioncube/ioncube_loader_lin_${ARG_PHP_VERSION}.so >> /usr/local/etc/php/conf.d/ioncube-php.ini

RUN addgroup --gid 10001 app
RUN adduser --gid 10001 --uid 10001 --home /app --shell /sbin/nologin --disabled-password --gecos we,dont,care,yeah app
RUN rm -rf /usr/local/etc/php-fpm*
RUN echo '{"name":"${REPO_NAME}","version":"${GIT_TAG}","source":"${REPO_URL}","commit":"${GIT_COMMIT}"}' > version.json
COPY version.json /app/
COPY entrypoint.sh /
RUN chmod 0755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /var/www/testrail
EXPOSE 9000
VOLUME /var/www/testrail
USER app
