FROM php:5.6-apache

# install the PHP extensions we need
RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y \
		libjpeg-dev \
		libpng-dev \
		sendmail sendmail-bin mailutils \
		unzip \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli
# TODO consider removing the *-dev deps and only keeping the necessary lib* packages

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini


RUN { \
	echo 'sendmail_path = /usr/sbin/sendmail -t -i'; \
	echo 'SMTP = localhost'; \
	echo 'smtp_port = 25'; \
} > /usr/local/etc/php/conf.d/smtp.ini

RUN a2enmod rewrite expires

VOLUME /var/www/html

ENV WORDPRESS_VERSION 4.9.2

RUN set -ex; \
	curl -o w.zip -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.zip"; \
	echo "---------------"; \
	ls; \
	pwd; \
	echo "---------------"; \
	unzip w.zip; \
	rm -rf w.zip; \
	chown -R www-data:www-data /var/www/html;
 
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
