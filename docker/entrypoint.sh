#!/bin/bash

if [ ! -f "vendor/autoload.php" ]; then
    composer install
fi

if [ ! -f ".env" ]; then
    echo "Creating env file for env $APP_ENV"
    cp .env.example .env
    php artisan key:generate
else
    echo "env file exists."
fi

php artisan migrate
php artisan optimize
php artisan view:cache
php artisan icons:cache