# Ak existuje .env, načítaj COMPOSE_PROJECT_NAME. Ak nie, použi názov priečinka.
COMPOSE_PROJECT_NAME := $(shell [ -f .env ] && grep -E '^COMPOSE_PROJECT_NAME=' .env | cut -d '=' -f2 || basename $(PWD))

# Kontajnery budú pomenované na základe COMPOSE_PROJECT_NAME
PROJECT_NAME=dpb-laravel-base
CONTAINER_PHP=$(COMPOSE_PROJECT_NAME)_web
CONTAINER_NODE=$(COMPOSE_PROJECT_NAME)_node
CONTAINER_DB=$(COMPOSE_PROJECT_NAME)_db
CONTAINER_REDIS=$(COMPOSE_PROJECT_NAME)_redis

# Prevent running Makefile inside Docker
ifneq ($(shell test -f /.dockerenv && echo "true"),)
$(warning Makefile should not be run inside a Docker container. Exiting...)
$(shell exit 1)
endif

.PHONY: install build fix-perm docker-setup start stop restart rebuild code terminal vite set-env

install:
	@if [ ! -d "vendor" ]; then \
		echo "🟢 Spúšťam inštaláciu Laravel projektu..."; \
		make set-env; \
		make build; \
		make fix-perm; \
		make docker-setup; \
		make show-ports; \
	else \
		echo "⚠️ DPB Laravel base už existuje, inštalácia preskočená."; \
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
	@echo "⏳ Čakám na MySQL databázu..."
	@until docker exec -it $(CONTAINER_DB) mysqladmin ping -h"127.0.0.1" --silent; do \
		echo "❌ MySQL ešte nie je pripravený, čakám..."; \
		sleep 2; \
	done
	docker exec -it $(CONTAINER_PHP) php artisan migrate --force
	docker exec -it $(CONTAINER_PHP) php artisan config:clear
	docker exec  $(CONTAINER_PHP) bash -c "[ -L public/storage ] && rm public/storage || true"
	docker exec -it $(CONTAINER_PHP) php artisan storage:link
	docker exec -it $(CONTAINER_NODE) sh -c "cd /var/www/html && npm install";

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
	docker logs -f $(CONTAINER_NODE)

reset-docker:
	docker stop $(docker ps -aq)
	docker rm -f $(docker ps -aq)
	docker rmi -f $(docker images -q)
	docker network prune -f
	docker volume prune -f
	docker system prune -af --volumes

SHELL := /bin/bash

set-env:
	@echo "🔍 Kontrola dostupných portov..."
	@if [ ! -f ".env" ]; then \
		echo "📝 Vytváram .env súbor z .env.example..."; \
		cp .env.example .env; \
	fi
	@if ! grep -q "COMPOSE_PROJECT_NAME=" .env; then \
		echo "COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME)" >> .env; \
	fi
	@WEB_PORT=$$(for p in $$(seq 8000 8100); do ss -tln | grep -q ":$$p " || { echo $$p; break; }; done); \
	VITE_PORT=$$(for p in $$(seq 5100 5200); do ss -tln | grep -q ":$$p " || { echo $$p; break; }; done); \
	MYSQL_PORT=$$(for p in $$(seq 3306 3400); do ss -tln | grep -q ":$$p " || { echo $$p; break; }; done); \
	grep -q "^WEB_PORT=" .env && sed -i "s/^WEB_PORT=.*/WEB_PORT=$$WEB_PORT/" .env || echo "WEB_PORT=$$WEB_PORT" >> .env; \
	grep -q "^VITE_PORT=" .env && sed -i "s/^VITE_PORT=.*/VITE_PORT=$$VITE_PORT/" .env || echo "VITE_PORT=$$VITE_PORT" >> .env; \
	grep -q "^MYSQL_PORT=" .env && sed -i "s/^MYSQL_PORT=.*/MYSQL_PORT=$$MYSQL_PORT/" .env || echo "MYSQL_PORT=$$MYSQL_PORT" >> .env; \
	echo "✅ Aktualizované v .env: COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME), WEB_PORT=$$WEB_PORT, VITE_PORT=$$VITE_PORT, MYSQL_PORT=$$MYSQL_PORT";

show-ports:
	@echo ""; \
	@echo "🚀 **Projekt úspešne nainštalovaný!**"; \
	@echo "----------------------------------"; \
	@echo "🌐 Web aplikácia beží na: http://localhost:$$(grep '^WEB_PORT=' .env | cut -d '=' -f2)"; \
	@echo "⚡ Vite beží na: http://localhost:$$(grep '^VITE_PORT=' .env | cut -d '=' -f2)"; \
	@echo "🛢️  MySQL beží na porte: $$(grep '^MYSQL_PORT=' .env | cut -d '=' -f2)"; \
	@echo "----------------------------------"; \

test:
	@echo "🔵 Použité porty:"
	@cat .env | grep -E 'WEB_PORT|VITE_PORT|MYSQL_PORT'
