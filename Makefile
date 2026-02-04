.PHONY: all render register build run up compile reload netsims down
.PHONY: dev-setup dev-install dev-check dev-format dev-lint dev-type-check dev-clean

# Makefile for building, creating and cleaning
# the NSO and CXTA containers for this development environment.

# Requirements:
# 1. Docker and Docker Compose installed and running.
# 2. BuildKit enabled (usually default in recent Docker versions, or set DOCKER_BUILDKIT=1).
# 3. A 'docker-compose.yml' file defining the services for NSO and CXTA, plus the runtime secrets.
# 4. A 'Dockerfile' for the NSO custom image, configured to use BuildKit's

# Default target: build and then up
all: up

# Target to render the templates in this repository (*j2 files) with the information from config.yaml
render:
	@echo "--- ✨ Rendering templates ---"
	./setup/render-templates.sh

# Target to mount a local Docker registry on localhost:5000 for your NSO container image,
# in case it comes from a clean `docker loads` and it is not hosted in a registry
register:
	@echo "--- 📤 Mounting local registry (if needed) ---"
	./setup/mount-registry-server.sh

# Target to build the Docker image with secrets
# The Dockerfile in the repository is used for this
# The Docker BuildKit is used for best security practices - The secrets are not recorded in the layers history
build:
	@echo "--- 🏗️ Building NSO custom image with BuildKit secrets ---"
	./setup/build-image.sh

# Target to run the docker compose services with healthcheck
# We don't know how long the NSO container is going to take to become healthy.
# as it depends on the artifacts and NEDs from the custom image.
# Therefore, we are using a script instead of a fixed timed.
run:
	@echo "--- 🚀 Starting Docker Compose services ---"
	./setup/run-services.sh

# Target to run the `packages reload` command in the CLI
# of the NSO container
compile:
	@echo "--- 🛠️ Compiling your services ---"
	./setup/compile-packages.sh

# Target to run the `packages reload` command in the CLI
# of the NSO container
reload:
	@echo "--- 🔀 Reloading the services ---"
	./setup/packages-reload.sh

# Target to create and onboard the netsim devices
# in the NSO container
netsims:
	@echo "--- ⬇️ Loading preconfiguration files ---"
	./setup/load-preconfigs.sh
	@echo "--- 🛸 Loading netsims ---"
	./setup/load-netsims.sh

# Target to start Docker Compose services
up: render register build run compile reload netsims

# Target to stop Docker Compose services
down:
	@echo "--- 🛑 Stopping Docker Compose services ---"
	docker compose down

# ==============================================================================
# Development Environment Setup Targets
# ==============================================================================

# Python virtual environment paths
VENV_DIR := .venv
VENV_PYTHON := $(VENV_DIR)/bin/python
VENV_PIP := $(VENV_DIR)/bin/pip
VENV_BLACK := $(VENV_DIR)/bin/black
VENV_ISORT := $(VENV_DIR)/bin/isort
VENV_MYPY := $(VENV_DIR)/bin/mypy
VENV_PYLINT := $(VENV_DIR)/bin/pylint

# Target to create Python virtual environment
dev-venv:
	@echo "--- 🐍 Creating Python virtual environment ---"
	@if [ ! -d "$(VENV_DIR)" ]; then \
		python3 -m venv $(VENV_DIR); \
		echo "--- ✅ Virtual environment created at $(VENV_DIR) ---"; \
	else \
		echo "--- ℹ️  Virtual environment already exists ---"; \
	fi

# Target to setup the complete development environment
dev-setup: dev-venv dev-install
	@echo "--- ✅ Development environment setup complete! ---"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Activate the virtual environment: source $(VENV_DIR)/bin/activate"
	@echo "  2. Restart VS Code to apply settings"
	@echo "  3. Start coding - GitHub Copilot will follow your standards"
	@echo "  4. Run 'make dev-check' before committing"

# Target to install all required Python development tools
dev-install: dev-venv
	@echo "--- 📦 Installing Python development tools in virtual environment ---"
	$(VENV_PIP) install --upgrade pip
	$(VENV_PIP) install black isort mypy pylint
	@echo "--- ✅ Development tools installed ---"

# Target to run all code quality checks manually
dev-check: dev-format dev-lint dev-type-check
	@echo "--- ✅ All code quality checks passed! ---"

# Target to format code with Black and isort
dev-format: dev-venv
	@echo "--- 🎨 Formatting code with Black ---"
	$(VENV_BLACK) python/ packages/ || true
	@echo "--- 📚 Sorting imports with isort ---"
	$(VENV_ISORT) python/ packages/ || true
	@echo "--- ✅ Code formatting complete ---"

# Target to run linting checks
dev-lint: dev-venv
	@echo "--- 🔍 Running pylint ---"
	find python packages -name "*.py" -type f | xargs $(VENV_PYLINT) || true
	@echo "--- ✅ Linting complete ---"

# Target to run type checking with mypy
dev-type-check: dev-venv
	@echo "--- 🔎 Running type checks with mypy ---"
	@DIRS=""; \
	if [ -d "python" ]; then DIRS="$$DIRS python"; fi; \
	if [ -d "packages" ]; then DIRS="$$DIRS packages"; fi; \
	if [ -n "$$DIRS" ]; then \
		$(VENV_MYPY) $$DIRS || true; \
	else \
		echo "--- ℹ️  No Python directories found to type check ---"; \
	fi
	@echo "--- ✅ Type checking complete ---"

# Target to clean Python cache and build artifacts
dev-clean:
	@echo "--- 🧹 Cleaning Python cache and artifacts ---"
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@echo "--- 🗑️  Removing virtual environment ---"
	rm -rf $(VENV_DIR)
	@echo "--- ✅ Cleanup complete ---"