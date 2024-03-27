FROM php:7.4-fpm
# Change this as needed to match container
ARG ARG_PHP_VERSION=7.4
# Change this to update
# See https://www.ioncube.com/loaders.php for ioncube downloadable versions
# and release notes.
ARG ARG_IONCUBE_VERSION=10.4.5
ENV TR_DEFAULT_TASK_EXECUTION=60
ENV TR_CONFIGPATH="/var/www/testrail/config/"
ENV TR_DEFAULT_LOG_DIR="/opt/testrail/logs/"
ENV TR_DEFAULT_AUDIT_DIR="/opt/testrail/audit/"
ENV TR_DEFAULT_REPORT_DIR="/opt/testrail/reports/"
ENV TR_DEFAULT_ATTACHMENT_DIR="/opt/testrail/attachments/"
ENV OPENSSL_CONF=/etc/ssl/

RUN apt-get update                                  \
      && apt-get -y install --no-install-recommends \
        iputils-ping                                \
        libfreetype6-dev                            \
        libjpeg-dev                                 \
        libldap2-dev                                \
        libpng-dev                                  \
        libuv1                                      \
        libzip-dev                                  \
        mariadb-client                              \
        unzip                                       \
        vim                                         \
        wget                                        \
        zip                                         \
      && apt-get clean                              \
      && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
      && docker-php-ext-configure gd --with-jpeg --with-freetype

RUN docker-php-ext-install gd              \
      && docker-php-ext-install ldap       \
      && docker-php-ext-install mysqli     \
      && docker-php-ext-install pdo_mysql  \
      && docker-php-ext-install zip

RUN mkdir -p /var/www/testrail                 \
      &&  mkdir -p /opt/testrail/attachments   \
                   /opt/testrail/reports       \
                   /opt/testrail/logs          \
                   /opt/testrail/audit

COPY php.ini /usr/local/etc/php/conf.d/php.ini

RUN wget -O /tmp/ioncube.tar.gz                                                                         \
      https://testrail-mirror.s3.amazonaws.com/ioncube_loaders_lin_x86-64_${ARG_IONCUBE_VERSION}.tar.gz \
      && tar -xzf /tmp/ioncube.tar.gz -C /tmp                                                           \
      && mv /tmp/ioncube /opt/ioncube                                                                   \
      && rm -f /tmp/ioncube.tar.gz                                                                      \
      && echo zend_extension=/opt/ioncube/ioncube_loader_lin_${ARG_PHP_VERSION}.so >> /usr/local/etc/php/conf.d/ioncube-php.ini

RUN wget -O /tmp/multiarch-support.deb                                                      \
      https://testrail-mirror.s3.amazonaws.com/multiarch-support_2.27-3ubuntu1.6_amd64.deb  \
      && dpkg -i /tmp/multiarch-support.deb                                                 \
      && rm -fv /tmp/multiarch-support.deb

RUN wget -O /tmp/cassandra-cpp-driver.deb                                               \
      https://testrail-mirror.s3.amazonaws.com/cassandra-cpp-driver_2.16.0-1_amd64.deb  \
      && dpkg -i /tmp/cassandra-cpp-driver.deb                                          \
      && rm -fv /tmp/cassandra-cpp-driver.deb

RUN wget -O /tmp/cassandra.so                                                       \
      https://testrail-mirror.s3.amazonaws.com/php/${ARG_PHP_VERSION}/cassandra.so  \
      && mv /tmp/cassandra.so $(php -i | grep ^extension_dir | cut -d ' ' -f 3)     \
      && echo extension=cassandra.so > /usr/local/etc/php/conf.d/cassandra.ini

RUN addgroup --gid 10001 app                                                \
      && adduser --gid 10001 --uid 10001 --home /app --shell /sbin/nologin  \
         --disabled-password --gecos we,dont,care,yeah app

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
