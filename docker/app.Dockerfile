FROM php:8.3-fpm

# Set environment variables
ENV HOST_GID=1000 \
    HOST_UID=1000 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=0

# Add user
RUN groupmod -g $HOST_GID www-data && \
    usermod -u $HOST_UID www-data


# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    libonig-dev \
    libzip-dev \
    jpegoptim optipng pngquant gifsicle \
    ca-certificates \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath opcache
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/
RUN docker-php-ext-install gd

# Copy configuration files
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY --chown=www-data:www-data . /var/www/
RUN chown -R www-data:www-data /var/www

# Change user to www-data
USER www-data

# Install dependency
WORKDIR /var/www

# Run the entrypoint file
RUN chmod +x docker/entrypoint.sh
ENTRYPOINT [ "docker/entrypoint.sh" ]

# Expose port 9000
EXPOSE 9000