VENV ?= .venv
PYTHON ?= $(VENV)/bin/python
CHECK_JSONSCHEMA ?= $(VENV)/bin/check-jsonschema

# The validators need Python 3.10+: check_local_markdown.py uses `str | None`, and the pinned
# check-jsonschema does not install below it. macOS still ships 3.9 as `python3` and Apple is not
# going to change that, so detect a suitable interpreter rather than assuming the default one is
# suitable. Override with `make setup BOOTSTRAP_PYTHON=/path/to/python3`.
BOOTSTRAP_PYTHON ?= $(shell 	for c in python3.14 python3.13 python3.12 python3.11 python3.10 python3; do 	  command -v $$c >/dev/null 2>&1 && 	  $$c -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null && 	  { echo $$c; break; }; 	done)

.PHONY: setup validate

setup:
	@test -n "$(BOOTSTRAP_PYTHON)" || { 	  echo "ERROR: need Python 3.10+ to run the validators; none found."; 	  echo "       Try 'brew install python@3.13', or"; 	  echo "       'make setup BOOTSTRAP_PYTHON=/path/to/python3'."; 	  exit 1; }
	@echo "Using $(BOOTSTRAP_PYTHON) ($$($(BOOTSTRAP_PYTHON) --version 2>&1))"
	$(BOOTSTRAP_PYTHON) -m venv $(VENV)
	$(VENV)/bin/python -m pip install --quiet --upgrade pip
	$(VENV)/bin/python -m pip install -r requirements-dev.txt

validate:
	$(PYTHON) scripts/check_decision_ids.py
	$(PYTHON) scripts/check_local_markdown.py
	$(PYTHON) -m json.tool schemas/delivery.schema.json >/dev/null
	$(PYTHON) -m json.tool schemas/tools.schema.json >/dev/null
	$(CHECK_JSONSCHEMA) --check-metaschema schemas/delivery.schema.json
	$(CHECK_JSONSCHEMA) --check-metaschema schemas/tools.schema.json
	$(CHECK_JSONSCHEMA) --schemafile schemas/delivery.schema.json templates/delivery/delivery-template.yml
	$(CHECK_JSONSCHEMA) --schemafile schemas/tools.schema.json templates/project/tooling/tools.yml
