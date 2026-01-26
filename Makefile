NAME = inception

DATA_PATH = $(HOME)/data

DOCKER_COMPOSE = docker compose -f src/docker-compose.yml

all: build up

build:
		@echo "Preparation des dossiers pour les volumes dans $(DATA_PATH)..."
		@mkdir -p $(DATA_PATH)/wordpress
		@mkdir -p $(DATA_PATH)/mariadb
		@echo "Construction des images Docker..."
		$(DOCKER_COMPOSE) build

up:
		@echo "Lancement de l'infrastructure..."
		$(DOCKER_COMPOSE) up -d

down:
		@echo "Arret des conteneurs..."
		$(DOCKER_COMPOSE) down

fclean:
		@echo "Nettoyage complet..."
		@$(DOCKER_COMPOSE) down -v --rmi all
		@sudo rm -rf $(DATA_PATH)
		@docker system prune -a -f
		
re: fclean all

.PHONY: all build up down fclean re
