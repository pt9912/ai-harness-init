package gen

import "strings"

// DefaultPythonVersion ist der gepinnte Default des Python-Skeletts — der **Tag des
// python-Images** (`python:<ver>-slim`): er bestimmt den Interpreter der Gate-Stages.
// Die Versionen der drei Direkt-Werkzeuge stehen exakt in requirements-dev.txt. TAG-gepinnt,
// ohne Digest, damit der Knopf SKEL_PYTHON_VERSION wirkt; die Konstante ist von den Pins der
// anderen Sprachen entkoppelt (ADR-0095 Festlegung 2, LH-QA-02).
const DefaultPythonVersion = "3.14.8-slim"

// pythonProfile ist das Python-SKELETT fuer den gegebenen python-Tag (ADR-0095): ein
// Einzelprojekt im src-Layout ohne Build-Backend, die Gates sind Dockerfile-Stages
// (build/test/lint), Test ist pytest, Lint ruff plus mypy. Das Code-Gate-Fragment kommt aus
// gen.CodeGateFragment; das Skelett selbst ist ortsunabhaengig. Statisch/deterministisch
// (LH-QA-02).
func pythonProfile(version, arch string) map[string]string {
	return composeSkeleton(pythonScaffolding, pythonRole, version, arch)
}

// pythonScaffolding — die arch-INVARIANTE Python-Geruestung (ADR-0095 Festlegung 1):
// pyproject.toml nur mit Werkzeug-Konfiguration, requirements-dev.txt mit den drei exakt
// gepinnten Direkt-Werkzeugen, das Paket-Marker-File und das Dockerfile.
func pythonScaffolding(version string) map[string]string {
	return map[string]string{
		"pyproject.toml":       pythonPyproject,
		"requirements-dev.txt": pythonRequirements,
		"src/app/__init__.py":  "",
		"Dockerfile":           renderPython(pythonDockerfileTmpl, version),
	}
}

// pythonRole rendert eine Code-Rolle als Python-Datei. Getragen sind die Layouts flat
// (Entry-Point unter src/app, Test unter tests) und hexslice (python_hexslice.go); jede andere
// Rolle (hexagonal) -> nil.
func pythonRole(r codeRole) map[string]string {
	switch r {
	case roleEntrypoint:
		return map[string]string{"src/app/main.py": pythonMain}
	case roleTest:
		return map[string]string{"tests/test_main.py": pythonTest}
	}
	return pythonHexslice(r)
}

// pythonFragment liefert das Python-Code-Gate-Fragment: am Root (context ".") die UNSCOPED
// Fassung, im Subdir die MODUL-SCOPED. Jedes `docker build --target <stage>` referenziert eine
// gleichnamige Dockerfile-Stage — TestPythonCodeGateFragment_TargetsMatchStages haelt die
// Kopplung (LH-QA-01).
func pythonFragment(modul, context, version string) string {
	if context == "." {
		return renderPython(pythonMkFragmentTmpl, version)
	}
	return renderPythonScoped(pythonScopedMkFragmentTmpl, modul, context, version)
}

// pythonFragmentMixed liefert die gemischte Root-Fassung: modul-scoped Targets plus
// Praezedenz-Erweiterung der unscoped Ziele ohne eigenes Rezept.
func pythonFragmentMixed(modul, context, version string) string {
	return renderPythonScoped(pythonMixedMkFragmentTmpl, modul, context, version)
}

// renderPython setzt den python-Tag in ein Python-Template ein ({{PYTHON_TAG}}).
func renderPython(tmpl, version string) string {
	return strings.ReplaceAll(tmpl, "{{PYTHON_TAG}}", version)
}

// renderPythonScoped setzt Modul-Name, Build-Kontext und python-Tag ein.
func renderPythonScoped(tmpl, modul, context, version string) string {
	return strings.NewReplacer(
		"{{MODULE}}", modul,
		"{{CONTEXT}}", context,
		"{{PYTHON_TAG}}", version,
	).Replace(tmpl)
}

// pythonRequirements — die drei Direkt-Werkzeuge, je exakt gepinnt (ADR-0095 Festlegung 1).
// Transitive Abhaengigkeiten sind nicht gepinnt: ein statisch erzeugtes Skelett traegt keinen
// Lock-File.
const pythonRequirements = `pytest==9.1.1
ruff==0.17.1
mypy==2.4.0
`

// pythonPyproject — nur Werkzeug-Konfiguration, kein [project] und kein Build-Backend
// (ADR-0095 Festlegung 1). Gebunden ist die Lint-Config (Festlegung 3): F (F401, unbenutzter
// Import) und TID mit ban-relative-imports = "all" (TID252, relativer Import) stehen in
// select; mypy laeuft strict.
const pythonPyproject = `# pyproject.toml — generiert von ai-harness-init. Nur Werkzeug-Konfiguration: kein
# [project], kein Build-Backend. Die Datei ist DEINE: sie wird beim Re-Bootstrap nicht
# ueberschrieben und waechst nur, wenn du sie pflegst.

[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]

[tool.ruff]
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "I", "B", "TID"]

[tool.ruff.lint.flake8-tidy-imports]
ban-relative-imports = "all"

[tool.mypy]
strict = true
mypy_path = "src"
files = ["src", "tests"]
`

const pythonMain = `"""Command app — vom ai-harness-init generiertes Python-Skelett."""


def greeting(name: str) -> str:
    return "Hallo, " + name


def main() -> None:
    print(greeting("Welt"))


if __name__ == "__main__":
    main()
`

const pythonTest = `"""Minimaler Test ueber pytest — belegt Build und Testlauf."""

from app.main import greeting


def test_greeting_nennt_den_namen() -> None:
    assert greeting("Welt") == "Hallo, Welt"
`

const pythonDockerfileTmpl = `# syntax=docker/dockerfile:1.7
# Dockerfile — generiert von ai-harness-init (Python-Skelett). Jede Gate ist eine Stage
# (docker build --target <stage>); das python-Image ist TAG-gepinnt (kein floating), der
# Digest bewusst weggelassen, damit PYTHON_TAG ein echter Knopf bleibt. pytest, ruff und
# mypy kommen per pip aus requirements-dev.txt im Bild-Build — das ist kein
# Host-Toolchain-Aufruf (der Guard blockt sie nur auf dem Host).
ARG PYTHON_TAG={{PYTHON_TAG}}

FROM python:${PYTHON_TAG} AS toolchain
ENV PIP_DISABLE_PIP_VERSION_CHECK=1 PIP_NO_CACHE_DIR=1 PYTHONDONTWRITEBYTECODE=1
WORKDIR /src
COPY requirements-dev.txt .
RUN pip install -r requirements-dev.txt
COPY . .

FROM toolchain AS build
RUN python -m compileall -q src

FROM toolchain AS test
RUN python -m pytest

FROM toolchain AS lint
RUN ruff check . && ruff format --check . && mypy
`

// pythonMkFragmentTmpl — das Python-Code-Gate-Fragment (harness/mk/python.mk): lint/build/test
// als Dockerfile-Stages, an GATE_CHECKS gehaengt. Die Make-Variable heisst PYTHON_TAG und
// kollidiert mit keinem Namen der Fragmente der anderen Sprachen. Recipe-Zeilen sind
// TAB-eingerueckt.
const pythonMkFragmentTmpl = `# harness/mk/python.mk — Python-Code-Gate-Fragment, generiert von ai-harness-init. Die
# Gates sind Dockerfile-Stages (Docker-only); dieses Fragment haengt
# lint/build/test an GATE_CHECKS, der Root-Aggregator faehrt sie via make gates.
PYTHON_TAG ?= {{PYTHON_TAG}}
IMAGE ?= app

.PHONY: test lint build

test: ## Python-Tests (pytest, Dockerfile test-Stage) — Docker-only
	docker build --build-arg PYTHON_TAG=$(PYTHON_TAG) --target test -t $(IMAGE):test .

lint: ## Python-Lint (ruff, mypy, Dockerfile lint-Stage) — Docker-only
	docker build --build-arg PYTHON_TAG=$(PYTHON_TAG) --target lint -t $(IMAGE):lint .

build: ## Python-Syntaxpruefung (compileall, Dockerfile build-Stage) — Docker-only
	docker build --build-arg PYTHON_TAG=$(PYTHON_TAG) --target build -t $(IMAGE):build .

GATE_CHECKS += lint build test
`

// pythonMixedMkFragmentTmpl — die Python-Fassung fuer den GEMISCHTEN Root: modul-scoped
// Targets, und die unscoped Ziele test/lint/build NUR als Praezedenz-Erweiterung ohne eigenes
// Rezept. GATE_CHECKS haengt die UNSCOPED Namen an (record-gates dedupliziert); die scoped
// Namen stehen nicht daneben, sonst liefe der Python-Kontext in gates doppelt.
const pythonMixedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — Python-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only); modul-scoped
# Targets, Build-Kontext {{CONTEXT}} — ein zweites Sprach-Fragment liegt am Root, darum
# traegt dieses Fragment die unscoped Ziele test/lint/build nur als Praezedenz-Erweiterung
# ohne eigenes Rezept: make haengt Praezedenz-Listen mehrerer Regeln zusammen. Welches
# Fragment das eigene Rezept traegt, haengt vom Verlauf der add-lang-Aufrufe ab.
PYTHON_TAG ?= {{PYTHON_TAG}}

.PHONY: test lint build test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## Python-Tests Modul {{MODULE}} (pytest, test-Stage) — Docker-only
	docker build --build-arg PYTHON_TAG=$(PYTHON_TAG) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## Python-Lint Modul {{MODULE}} (ruff, mypy, lint-Stage) — Docker-only
	docker build --build-arg PYTHON_TAG=$(PYTHON_TAG) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## Python-Syntaxpruefung Modul {{MODULE}} (build-Stage) — Docker-only
	docker build --build-arg PYTHON_TAG=$(PYTHON_TAG) --target build -t {{MODULE}}:build {{CONTEXT}}

test: test-{{MODULE}}
lint: lint-{{MODULE}}
build: build-{{MODULE}}

GATE_CHECKS += test lint build
`

// pythonScopedMkFragmentTmpl — die MODUL-SCOPED Fassung fuer ein Mono-Repo-Submodul unter
// {{CONTEXT}}: modul-scoped Targets (kollisionsfrei), Image-Tag inline der Modul-Name.
const pythonScopedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — Python-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only); modul-scoped
# Targets (kollisionsfrei im Mono-Repo), Build-Kontext {{CONTEXT}}. Haengt an GATE_CHECKS,
# der Root-Aggregator faehrt sie via make gates.
PYTHON_TAG ?= {{PYTHON_TAG}}

.PHONY: test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## Python-Tests Modul {{MODULE}} (pytest, test-Stage) — Docker-only
	docker build --build-arg PYTHON_TAG=$(PYTHON_TAG) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## Python-Lint Modul {{MODULE}} (ruff, mypy, lint-Stage) — Docker-only
	docker build --build-arg PYTHON_TAG=$(PYTHON_TAG) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## Python-Syntaxpruefung Modul {{MODULE}} (build-Stage) — Docker-only
	docker build --build-arg PYTHON_TAG=$(PYTHON_TAG) --target build -t {{MODULE}}:build {{CONTEXT}}

GATE_CHECKS += lint-{{MODULE}} build-{{MODULE}} test-{{MODULE}}
`
