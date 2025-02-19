PROJECT_NAME=dpb-laravel-base
CONTAINER_PHP=laravel_base_web
CONTAINER_NODE=laravel_base_node

# Prevent running Makefile inside Docker
ifneq ($(shell test -f /.dockerenv && echo "true"),)
$(warning Makefile should not be run inside a Docker container. Exiting...)
$(shell exit 1)
endif

.PHONY: install setup start stop restart rebuild code terminal

install:
	@if [ ! -d "./app" ]; then \
		echo "Repozitár ešte neexistuje. Musíš ho najprv vytvoriť."; \
		exit 1; \
	else \
		echo "Laravel base už existuje, inštalácia preskočená."; \
	fi

setup:
	cd app && docker exec -it $(CONTAINER_PHP) composer install --no-dev --optimize-autoloader
	cd app && cp .env.example .env
	cd app && docker exec -it $(CONTAINER_PHP) php artisan key:generate
	cd app && docker exec -it $(CONTAINER_PHP) php artisan migrate --force
	cd app && docker exec -it $(CONTAINER_PHP) php artisan config:clear
	cd app && docker exec -it $(CONTAINER_PHP) chown -R www-data:www-data storage bootstrap/cache
	cd app && docker exec -it $(CONTAINER_PHP) chmod -R 775 storage bootstrap/cache
	cd app && docker exec -it $(CONTAINER_NODE) npm install
	cd app && docker exec -it $(CONTAINER_NODE) npm run dev

start:
	docker-compose up -d --build

stop:
	docker-compose down

restart: stop start

rebuild:
	docker-compose down --volumes --remove-orphans
	docker-compose up -d --build

code:
	code .

terminal:
	docker exec -u www-data -it $(CONTAINER_PHP) bash

vite:
	docker exec -it laravel_base_node sh -c "npm run dev"
