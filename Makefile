.PHONY: all render register build run up compile reload netsims down
.PHONY: dev-setup dev-install dev-precommit dev-check dev-format dev-lint dev-type-check dev-clean

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

# Target to setup the complete development environment
dev-setup: dev-install dev-precommit
	@echo "--- ✅ Development environment setup complete! ---"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Restart VS Code to apply settings"
	@echo "  2. Start coding - GitHub Copilot will follow your standards"
	@echo "  3. Run 'make dev-check' before committing"

# Target to install all required Python development tools
dev-install:
	@echo "--- 📦 Installing Python development tools ---"
	pip install --upgrade pip
	pip install pre-commit black isort mypy pylint types-all
	@echo "--- ✅ Development tools installed ---"

# Target to initialize pre-commit hooks
dev-precommit:
	@echo "--- 🎣 Setting up pre-commit hooks ---"
	pre-commit install
	@echo "--- ✅ Pre-commit hooks installed ---"

# Target to run all code quality checks manually
dev-check: dev-format dev-lint dev-type-check
	@echo "--- ✅ All code quality checks passed! ---"

# Target to format code with Black and isort
dev-format:
	@echo "--- 🎨 Formatting code with Black ---"
	black python/ packages/ || true
	@echo "--- 📚 Sorting imports with isort ---"
	isort python/ packages/ || true
	@echo "--- ✅ Code formatting complete ---"

# Target to run linting checks
dev-lint:
	@echo "--- 🔍 Running pylint ---"
	find python packages -name "*.py" -type f | xargs pylint || true
	@echo "--- ✅ Linting complete ---"

# Target to run type checking with mypy
dev-type-check:
	@echo "--- 🔎 Running type checks with mypy ---"
	mypy python/ packages/ || true
	@echo "--- ✅ Type checking complete ---"

# Target to run pre-commit on all files
dev-precommit-all:
	@echo "--- 🔄 Running pre-commit on all files ---"
	pre-commit run --all-files
	@echo "--- ✅ Pre-commit checks complete ---"

# Target to clean Python cache and build artifacts
dev-clean:
	@echo "--- 🧹 Cleaning Python cache and artifacts ---"
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@echo "--- ✅ Cleanup complete ---"