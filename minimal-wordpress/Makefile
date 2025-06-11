# WordPress Docker DevOps Makefile
# Author: DevKraken (soman@devkraken.com)
# Version: 1.0

.PHONY: help setup start stop restart status logs monitor health backup restore clean security-audit

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED    := \033[31m
GREEN  := \033[32m
YELLOW := \033[33m
BLUE   := \033[34m
RESET  := \033[0m

# Configuration
COMPOSE_FILE := docker-compose.yml
ENV_FILE := .env
BACKUP_DIR := backups
LOG_DIR := logs

help: ## Show this help message
	@echo "$(BLUE)WordPress Docker DevOps Management$(RESET)"
	@echo "$(BLUE)=================================$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'

setup: ## Initial setup - copy env, create volumes, make scripts executable
	@echo "$(YELLOW)Setting up WordPress Docker environment...$(RESET)"
	@if [ ! -f $(ENV_FILE) ]; then \
		cp env.example $(ENV_FILE); \
		echo "$(GREEN)✓ Created .env file from template$(RESET)"; \
	else \
		echo "$(YELLOW)! .env file already exists$(RESET)"; \
	fi
	@mkdir -p $(LOG_DIR)/{nginx,mysql,wordpress} $(BACKUP_DIR)
	@chmod +x create-volumes.sh monitor.sh docker/healthcheck.sh || true
	@echo "$(GREEN)✓ Created directories and made scripts executable$(RESET)"
	@./create-volumes.sh
	@echo "$(GREEN)✓ Setup complete! Review your .env file and run 'make start'$(RESET)"



start: ## Start all services
	@echo "$(YELLOW)Starting WordPress services...$(RESET)"
	@docker compose up -d
	@echo "$(GREEN)✓ Services started successfully$(RESET)"
	@make status

start-prod: ## Start services in production mode (no MySQL external port)
	@echo "$(YELLOW)Starting WordPress services in PRODUCTION mode...$(RESET)"
	@docker compose -f docker-compose.yml -f docker-compose.production.yml up -d
	@echo "$(GREEN)✓ Production services started successfully$(RESET)"
	@echo "$(BLUE)ℹ MySQL external port disabled for security$(RESET)"
	@make status

stop: ## Stop all services
	@echo "$(YELLOW)Stopping WordPress services...$(RESET)"
	@docker compose down
	@echo "$(GREEN)✓ Services stopped$(RESET)"

restart: ## Restart all services
	@echo "$(YELLOW)Restarting WordPress services...$(RESET)"
	@docker compose restart
	@echo "$(GREEN)✓ Services restarted$(RESET)"

status: ## Show service status
	@echo "$(BLUE)Service Status:$(RESET)"
	@docker compose ps
	@echo ""
	@echo "$(BLUE)Resource Usage:$(RESET)"
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" || true

logs: ## Show logs for all services
	@docker compose logs -f

logs-wp: ## Show WordPress logs only
	@docker compose logs -f wordpress

logs-mysql: ## Show MySQL logs only
	@docker compose logs -f mysql

logs-nginx: ## Show Nginx logs only
	@docker compose logs -f nginx

monitor: ## Run monitoring script once
	@./monitor.sh

monitor-continuous: ## Run continuous monitoring
	@./monitor.sh -c

health: ## Run health check
	@echo "$(YELLOW)Running health checks...$(RESET)"
	@./docker/healthcheck.sh || echo "$(RED)Health check script not available$(RESET)"
	@echo ""
	@echo "$(BLUE)Docker Compose Health:$(RESET)"
	@docker compose ps

backup: ## Create backup of database and files
	@echo "$(YELLOW)Creating backup...$(RESET)"
	@mkdir -p $(BACKUP_DIR)
	@TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	if [ -f $(ENV_FILE) ]; then \
		source $(ENV_FILE); \
		MYSQL_CONTAINER=$${MYSQL_CONTAINER_NAME:-wp_mysql}; \
		MYSQL_DB=$${MYSQL_DATABASE:-wordpress}; \
		MYSQL_USER=$${MYSQL_USER:-wordpress}; \
		MYSQL_PASS=$${MYSQL_PASSWORD:-password}; \
		echo "$(BLUE)Backing up database...$(RESET)"; \
		docker compose exec -T mysql mysqldump -u$$MYSQL_USER -p$$MYSQL_PASS $$MYSQL_DB > $(BACKUP_DIR)/database_$$TIMESTAMP.sql; \
		echo "$(BLUE)Backing up wp-content...$(RESET)"; \
		tar -czf $(BACKUP_DIR)/wp-content_$$TIMESTAMP.tar.gz wp-content/ || true; \
		echo "$(BLUE)Backing up uploads...$(RESET)"; \
		tar -czf $(BACKUP_DIR)/uploads_$$TIMESTAMP.tar.gz uploads/ || true; \
		echo "$(GREEN)✓ Backup created: $(BACKUP_DIR)/*_$$TIMESTAMP.*$(RESET)"; \
	else \
		echo "$(RED)No .env file found$(RESET)"; \
	fi

restore: ## Restore from backup (requires BACKUP_DATE=YYYYMMDD_HHMMSS)
	@if [ -z "$(BACKUP_DATE)" ]; then \
		echo "$(RED)Error: Please specify BACKUP_DATE=YYYYMMDD_HHMMSS$(RESET)"; \
		echo "$(YELLOW)Available backups:$(RESET)"; \
		ls -la $(BACKUP_DIR)/ 2>/dev/null || echo "No backups found"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Restoring from backup $(BACKUP_DATE)...$(RESET)"
	@if [ -f $(BACKUP_DIR)/database_$(BACKUP_DATE).sql ]; then \
		source $(ENV_FILE); \
		MYSQL_CONTAINER=$${MYSQL_CONTAINER_NAME:-wp_mysql}; \
		MYSQL_DB=$${MYSQL_DATABASE:-wordpress}; \
		MYSQL_USER=$${MYSQL_USER:-wordpress}; \
		MYSQL_PASS=$${MYSQL_PASSWORD:-password}; \
		echo "$(BLUE)Restoring database...$(RESET)"; \
		docker compose exec -T mysql mysql -u$$MYSQL_USER -p$$MYSQL_PASS $$MYSQL_DB < $(BACKUP_DIR)/database_$(BACKUP_DATE).sql; \
		echo "$(GREEN)✓ Database restored$(RESET)"; \
	fi
	@if [ -f $(BACKUP_DIR)/wp-content_$(BACKUP_DATE).tar.gz ]; then \
		echo "$(BLUE)Restoring wp-content...$(RESET)"; \
		tar -xzf $(BACKUP_DIR)/wp-content_$(BACKUP_DATE).tar.gz; \
		echo "$(GREEN)✓ wp-content restored$(RESET)"; \
	fi
	@if [ -f $(BACKUP_DIR)/uploads_$(BACKUP_DATE).tar.gz ]; then \
		echo "$(BLUE)Restoring uploads...$(RESET)"; \
		tar -xzf $(BACKUP_DIR)/uploads_$(BACKUP_DATE).tar.gz; \
		echo "$(GREEN)✓ uploads restored$(RESET)"; \
	fi

clean: ## Clean up stopped containers, unused images, and logs
	@echo "$(YELLOW)Cleaning up Docker resources...$(RESET)"
	@docker compose down --remove-orphans
	@docker system prune -f
	@echo "$(BLUE)Cleaning old logs...$(RESET)"
	@find $(LOG_DIR) -name "*.log" -mtime +7 -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(RESET)"

clean-all: ## Clean everything including volumes (WARNING: destroys data)
	@echo "$(RED)WARNING: This will delete all data including databases!$(RESET)"
	@echo "$(RED)Press Ctrl+C to cancel, or wait 10 seconds to continue...$(RESET)"
	@sleep 10
	@docker compose down -v --remove-orphans
	@docker system prune -af
	@rm -rf $(LOG_DIR)/* $(BACKUP_DIR)/*
	@echo "$(GREEN)✓ Complete cleanup finished$(RESET)"

security-audit: ## Run security audit checks
	@echo "$(YELLOW)Running security audit...$(RESET)"
	@echo "$(BLUE)Checking for exposed ports...$(RESET)"
	@docker compose ps | grep -E ':80->' && echo "$(GREEN)✓ Nginx port 80 exposed (expected)$(RESET)" || echo "$(YELLOW)⚠ Nginx port not exposed$(RESET)"
	@docker compose ps | grep -E ':3306->' && echo "$(RED)⚠ MySQL port 3306 is exposed - consider production mode$(RESET)" || echo "$(GREEN)✓ MySQL port not exposed$(RESET)"
	@echo "$(BLUE)Checking container users...$(RESET)"
	@docker compose ps -q | xargs -I {} docker inspect {} --format '{{.Config.User}}' | grep -v '^$$' | sort -u || echo "$(GREEN)✓ Container users configured$(RESET)"
	@echo "$(BLUE)Checking for .env file permissions...$(RESET)"
	@ls -la $(ENV_FILE) 2>/dev/null | grep '^-rw-------' && echo "$(GREEN)✓ .env file has secure permissions$(RESET)" || echo "$(YELLOW)⚠ Consider: chmod 600 .env$(RESET)"
	@echo "$(BLUE)Checking for hardcoded secrets...$(RESET)"
	@grep -r "password\|secret\|key" docker-compose.yml || echo "$(GREEN)✓ No hardcoded secrets in compose file$(RESET)"
	@echo "$(BLUE)Production deployment recommendation:$(RESET)"
	@echo "$(YELLOW)For production, use: make start-prod$(RESET)"

update: ## Update container images
	@echo "$(YELLOW)Updating container images...$(RESET)"
	@docker compose pull
	@echo "$(GREEN)✓ Images updated. Run 'make restart' to apply changes$(RESET)"

dev: ## Start in development mode with live logs
	@echo "$(YELLOW)Starting in development mode...$(RESET)"
	@docker compose up --build

shell-wp: ## Open shell in WordPress container
	@docker compose exec wordpress sh

shell-mysql: ## Open MySQL shell
	@docker compose exec mysql mysql -u root -p

shell-nginx: ## Open shell in Nginx container
	@docker compose exec nginx sh

config: ## Validate and show docker compose configuration
	@docker compose config

# Development helpers
.env: env.example
	@cp env.example .env
	@echo "$(GREEN)✓ Created .env from template$(RESET)"

# Validation targets
validate-env: ## Validate environment configuration
	@echo "$(YELLOW)Validating environment configuration...$(RESET)"
	@test -f $(ENV_FILE) || (echo "$(RED)Error: .env file not found$(RESET)" && exit 1)
	@source $(ENV_FILE) && \
	test -n "$$MYSQL_ROOT_PASSWORD" || (echo "$(RED)Error: MYSQL_ROOT_PASSWORD not set$(RESET)" && exit 1) && \
	test -n "$$MYSQL_DATABASE" || (echo "$(RED)Error: MYSQL_DATABASE not set$(RESET)" && exit 1) && \
	test -n "$$MYSQL_USER" || (echo "$(RED)Error: MYSQL_USER not set$(RESET)" && exit 1) && \
	test -n "$$MYSQL_PASSWORD" || (echo "$(RED)Error: MYSQL_PASSWORD not set$(RESET)" && exit 1) && \
	echo "$(GREEN)✓ Environment configuration is valid$(RESET)"

# Quick commands
up: start ## Alias for start
down: stop ## Alias for stop
ps: status ## Alias for status 