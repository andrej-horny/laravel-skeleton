PROJECT_NAME=dpb-laravel-base
CONTAINER_PHP=laravel_base_web
CONTAINER_NODE=laravel_base_node

# Prevent running Makefile inside Docker
ifneq ($(shell test -f /.dockerenv && echo "true"),)
$(warning Makefile should not be run inside a Docker container. Exiting...)
$(shell exit 1)
endif

.PHONY: install build fix-perm docker-setup start stop restart rebuild code terminal vite

install:
	@if [ ! -d "vendor" ]; then \
		echo "🟢 Spúšťam inštaláciu Laravel projektu..."; \
		make build; \
		make fix-perm; \
		make docker-setup; \
	else \
		echo "⚠️ Laravel base už existuje, inštalácia preskočená."; \
	fi

build:
	docker compose up -d --build

fix-perm:
	docker exec -it $(CONTAINER_PHP) bash -c "sudo chown -R www-data:www-data /var/www/html"
	docker exec -it $(CONTAINER_PHP) bash -c "sudo chmod -R 775 /var/www/html"

docker-setup:
	@if [ ! -d "vendor" ]; then docker exec $(CONTAINER_PHP) composer install; fi
	@if [ ! -f ".env" ]; then docker exec -it $(CONTAINER_PHP) bash -c "sudo cp .env.example .env && sudo chown www-data:www-data /var/www/html/.env && sudo chmod 664 /var/www/html/.env"; fi
	docker exec -it $(CONTAINER_PHP) php artisan key:generate
	docker exec -it $(CONTAINER_PHP) php artisan migrate --force
	docker exec -it $(CONTAINER_PHP) php artisan config:clear
	docker exec  $(CONTAINER_PHP) bash -c "[ -L public/storage ] && rm public/storage || true"
	docker exec -it $(CONTAINER_PHP) php artisan storage:link
	docker exec -w /var/www/html -it $(CONTAINER_NODE) npm install

start:
	docker-compose up -d

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
	docker logs -f laravel_base_node
