.PHONY: help tests prepare clean version name install_poetry
help:
	@echo "Help"
	@echo "----"
	@echo
	@echo "  tests - run all tests"
	@echo "  pytest - run just pytest"
	@echo "  clean - clean directory from created files"
	@echo "  version - print package version"
	@echo "  name - print package name"
	@echo "  install_hooks - install pre-commit hook"
	@echo "  infra_init - init terraform"
	@echo "  infra_apply - deploy infra"
	@echo "  update_requirements - save non-dev requirements from poetry to requirements.txt"

tests:
	docker compose run --rm app ./docker/ci.sh && docker compose down -v || (docker compose down -v; exit 1)

clean:
	find . -name \*.pyc -delete

version:
	@sed -n 's/^version = "\(.*\)".*/\1/p' pyproject.toml

name:
	@sed -n 's/^name = "\(.*\)".*/\1/p' pyproject.toml

install_hooks:
	poetry run pre-commit install --install-hooks

infra_init:
	@cd infra && terraform init

infra_apply:
	@cd infra && terraform apply

update_requirements:
	@poetry export --only=main --without-hashes > requirements.txt

pytest:
	docker compose build app && docker compose run --rm app poetry run pytest && docker compose down -v || (docker compose down -v; exit 1)

diagrams:
	@FILES=$$(find ./docs/diagrams -type f -name "*.mmd"); \
	if [ -z "$$FILES" ]; then \
		echo "No diagrams to generate"; \
	else \
		bash generate_diagrams.sh $$FILES && echo "No new diagrams" || echo "Diagrams generated"; \
	fi
