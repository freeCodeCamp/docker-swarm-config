SHELL := /bin/bash

.PHONY: list config deploy help

help:
	@echo "Usage:"
	@echo "  make list                                        - List available stacks"
	@echo "  make config STACK=<stack-name>                   - Show stack configuration"
	@echo "  make deploy STACK=<stack-name> [NAME=<stack-id>] - Deploy stack (NAME defaults to stg-<stack-name>)"

list:
	@echo "Available stacks:"
	@ls -1 stacks/*/stack-*.yml | sed 's/.*stack-\(.*\)\.yml/\1/'

config:
	@bash -c '\
		if [ -z "$(STACK)" ]; then \
			echo "Please specify a stack name: make config STACK=<stack-name>"; \
			exit 1; \
		fi; \
		STACK_FILE=$$(find stacks -name "stack-$(STACK).yml"); \
		if [ -z "$$STACK_FILE" ]; then \
			echo "Stack configuration not found for: $(STACK)"; \
			exit 1; \
		fi; \
		STACK_DIR=$$(dirname "$$STACK_FILE"); \
		if [ -f "$$STACK_DIR/.env.sample" ] && [ ! -f "$$STACK_DIR/.env" ]; then \
			echo "Error: .env file is missing but required for this stack"; \
			echo "Please create $$STACK_DIR/.env using $$STACK_DIR/.env.sample as a template"; \
			exit 1; \
		fi; \
		echo "=== Stack Information ==="; \
		echo "Using stack file: $$STACK_FILE"; \
		if [ -f "$$STACK_DIR/.env" ]; then \
			echo "Loading environment from: $$STACK_DIR/.env"; \
			export $$(cat "$$STACK_DIR/.env" | xargs) > /dev/null 2>&1; \
		fi; \
		echo "=== Stack Configuration ==="; \
		docker stack config --compose-file "$$STACK_FILE"'

deploy:
	@bash -c '\
		if [ -z "$(STACK)" ]; then \
			echo "Please specify a stack name: make deploy STACK=<stack-name>"; \
			exit 1; \
		fi; \
		STACK_FILE=$$(find stacks -name "stack-$(STACK).yml"); \
		if [ -z "$$STACK_FILE" ]; then \
			echo "Stack configuration not found for: $(STACK)"; \
			exit 1; \
		fi; \
		STACK_DIR=$$(dirname "$$STACK_FILE"); \
		if [ -f "$$STACK_DIR/.env.sample" ] && [ ! -f "$$STACK_DIR/.env" ]; then \
			echo "Error: .env file is missing but required for this stack"; \
			echo "Please create $$STACK_DIR/.env using $$STACK_DIR/.env.sample as a template"; \
			exit 1; \
		fi; \
		echo "=== Stack Information ==="; \
		echo "Using stack file: $$STACK_FILE"; \
		if [ -f "$$STACK_DIR/.env" ]; then \
			echo "Loading environment from: $$STACK_DIR/.env"; \
			export $$(cat "$$STACK_DIR/.env" | xargs) > /dev/null 2>&1; \
		fi; \
		STACK_NAME=$${NAME:-stg-$(STACK)}; \
		echo "Deploying stack as: $$STACK_NAME"; \
		echo "=== Deployment Output ==="; \
		docker stack deploy -c "$$STACK_FILE" --prune --with-registry-auth --detach=false "$$STACK_NAME"'
