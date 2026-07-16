# Project Starter Contract

These files bootstrap the human/agent operating contract of a new Apple project. They
do not generate an Xcode project, signing identities, environments, or production
credentials.

Preferred installation from the playbook root:

~~~bash
./scripts/bootstrap_project.sh /path/to/new-app-repository
~~~

The helper refuses to overwrite existing files. After installation:

1. replace every `<PLACEHOLDER>`;
2. define deterministic project commands in `AGENTS.md` and the project Makefile;
3. select and resolve skills in `tooling/skills.yml`;
4. create project ADRs instead of editing the company standard locally;
5. commit `.apple-playbook-version` so upgrades are deliberate;
6. create the first Delivery Packet only after project ownership and environments are
   ready.
