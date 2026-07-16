VENV ?= .venv
PYTHON ?= $(VENV)/bin/python
CHECK_JSONSCHEMA ?= $(VENV)/bin/check-jsonschema

.PHONY: setup validate

setup:
	python3 -m venv $(VENV)
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
