package gen

import "strings"

// DefaultCppVersion ist der gepinnte Default des C++-Skeletts — der **ubuntu-Base-Tag**
// (nicht eine Compiler-Version): er bestimmt die apt-Toolchain (g++, cmake, clang-tidy).
// „Version" heisst je Sprache etwas anderes (go: Go-Version; cpp: ubuntu-Tag); das Profil
// interpretiert sie, der Aufrufer faedelt sie generisch (SKEL_CPP_VERSION). TAG-gepinnt,
// kein floating (LH-QA-02), aber bewusst OHNE Digest, damit der Knopf wirkt.
const DefaultCppVersion = "26.04"

// cppProfile ist das C++-SKELETT fuer die gegebene ubuntu-Version (ADR-0003 Docker-only):
// die Gates sind Dockerfile-Stages (build/test/lint); dazu ein CMake-Projekt, ein baubares
// src/main.cpp, ein NETZLOSER assert-freier Test (kein externes Framework — LH-QA-03) und
// eine .clang-tidy. An realen Harness-C++-Repos (cmake-xray, b-cad) geeicht. Das
// Code-Gate-Fragment (harness/mk/<modul>.mk) kommt wie bei go aus gen.CodeGateFragment;
// das Skelett selbst ist ortsunabhaengig. Statisch/deterministisch (LH-QA-02): gleiche
// version -> byte-identische Ausgabe.
func cppProfile(version string) map[string]string {
	return map[string]string{
		"CMakeLists.txt":       cppCMakeLists,
		"src/main.cpp":         cppMain,
		"tests/CMakeLists.txt": cppTestCMakeLists,
		"tests/test_main.cpp":  cppTest,
		".clang-tidy":          cppClangTidy,
		"Dockerfile":           renderCpp(cppDockerfileTmpl, version),
	}
}

// cppFragment liefert das C++-Code-Gate-Fragment (harness/mk/<modul>.mk-Inhalt): am Root
// (context ".") die UNSCOPED Fassung (Targets test/lint/build, `docker build .`), im Subdir
// die MODUL-SCOPED Fassung (test-<modul> …, `docker build <context>`, kollisionsfrei im
// Mono-Repo). Jedes `docker build --target <stage>` referenziert eine gleichnamige
// Dockerfile-Stage (test/lint/build) — kein halluziniertes Gate (LH-QA-01),
// TestCodeGateFragment_TargetsMatchStages haelt die Kopplung fest.
func cppFragment(modul, context, version string) string {
	if context == "." {
		return renderCpp(cppMkFragmentTmpl, version)
	}
	return renderCppScoped(cppScopedMkFragmentTmpl, modul, context, version)
}

// renderCpp setzt die ubuntu-Version in ein cpp-Template ein ({{CXX_VERSION}}). Eigener
// Renderer, weil cpp nur EINEN Versions-Platzhalter hat (kein golangci-Pin wie go).
func renderCpp(tmpl, version string) string {
	return strings.ReplaceAll(tmpl, "{{CXX_VERSION}}", version)
}

// renderCppScoped setzt Modul-Name, Build-Kontext + Version in das modul-scoped Fragment ein.
func renderCppScoped(tmpl, modul, context, version string) string {
	return strings.NewReplacer(
		"{{MODULE}}", modul,
		"{{CONTEXT}}", context,
		"{{CXX_VERSION}}", version,
	).Replace(tmpl)
}

const cppMain = `// Command app — vom ai-harness-init generiertes C++-Skelett.
#include <iostream>

int main() {
    std::cout << "Hallo vom generierten ai-harness-init-Skelett." << '\n';
    return 0;
}
`

// cppTest — minimaler NETZLOSER Test (kein doctest/FetchContent, LH-QA-03): eine explizite
// Pruefung + Exit-Code (kein assert, damit er auch unter NDEBUG greift). Er belegt, dass die
// Toolchain baut und CTest den Test faehrt.
const cppTest = `// Minimaler netzloser Test (kein externes Framework) — belegt Build + CTest-Lauf.
#include <cstdlib>

namespace {
int add(int a, int b) { return a + b; }
}  // namespace

int main() {
    if (add(2, 3) != 5) {
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
`

const cppCMakeLists = `cmake_minimum_required(VERSION 3.20)
project(app CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
add_compile_options(-Wall -Wextra -Wpedantic)

add_executable(app src/main.cpp)

enable_testing()
add_subdirectory(tests)
`

const cppTestCMakeLists = `add_executable(app_test test_main.cpp)
add_test(NAME app_test COMMAND app_test)
`

// cppClangTidy — konservativer Start-Satz (bugprone + clang-analyzer + eine Komplexitaets-
// Schranke), an cmake-xray/b-cad geeicht. Der lint-Gate ist rot/gruen (Modul 13): die
// lint-Stage laeuft clang-tidy mit --warnings-as-errors='*', jeder aktivierte Check wird
// sofort ein harter Fehler. Am trivialen Skelett feuert keiner (out-of-the-box gruen).
const cppClangTidy = `# .clang-tidy — generiert von ai-harness-init. Der lint-Gate ist rot/gruen (Modul 13):
# die lint-Stage laeuft clang-tidy mit --warnings-as-errors='*', jeder aktivierte Check
# ist ein harter Fehler. Konservativer Start-Satz; erweiterbar, wenn das Projekt waechst.
Checks: >
  -*,
  bugprone-*,
  clang-analyzer-*,
  readability-function-cognitive-complexity
WarningsAsErrors: ''
HeaderFilterRegex: '^src/'
FormatStyle: none
CheckOptions:
  - key: readability-function-cognitive-complexity.Threshold
    value: '25'
`

const cppDockerfileTmpl = `# syntax=docker/dockerfile:1.7
# Dockerfile — generiert von ai-harness-init (C++-Skelett). Jede Gate ist eine Stage
# (docker build --target <stage>); das Basis-Image ist TAG-gepinnt (LH-QA-02, kein
# floating). Digest bewusst weggelassen, damit CXX_VERSION (ubuntu-Tag) ein echter Knopf
# bleibt. Die Toolchain (build-essential/cmake/clang-tidy) kommt per apt im Bild-Build —
# das ist kein Host-Toolchain-Aufruf (der Guard blockt sie nur auf dem Host).
ARG CXX_VERSION={{CXX_VERSION}}

FROM ubuntu:${CXX_VERSION} AS toolchain
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /src
RUN apt-get update \
    && apt-get install --yes --no-install-recommends build-essential cmake clang-tidy \
    && rm -rf /var/lib/apt/lists/*

FROM toolchain AS build
COPY . .
RUN cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build --parallel

FROM build AS test
RUN ctest --test-dir build --output-on-failure

FROM build AS lint
RUN clang-tidy --warnings-as-errors='*' -p build src/main.cpp
`

// cppMkFragmentTmpl — das C++-Code-Gate-Fragment (harness/mk/cpp.mk): lint/build/test als
// Dockerfile-Stages, an GATE_CHECKS gehaengt. Recipe-Zeilen sind TAB-eingerueckt.
const cppMkFragmentTmpl = `# harness/mk/cpp.mk — C++-Code-Gate-Fragment, generiert von ai-harness-init. Die
# Gates sind Dockerfile-Stages (Docker-only, ADR-0003); dieses Fragment haengt
# lint/build/test an GATE_CHECKS, der Root-Aggregator faehrt sie via make gates.
CXX_VERSION ?= {{CXX_VERSION}}
IMAGE ?= app

.PHONY: test lint build

test: ## C++-Tests (ctest, Dockerfile test-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target test -t $(IMAGE):test .

lint: ## C++-Lint (clang-tidy, Dockerfile lint-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target lint -t $(IMAGE):lint .

build: ## C++-Binary bauen (Dockerfile build-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target build -t $(IMAGE):build .

GATE_CHECKS += lint build test
`

// cppScopedMkFragmentTmpl — die MODUL-SCOPED Fassung fuer ein Mono-Repo-Submodul unter
// {{CONTEXT}}: modul-scoped Targets (kollisionsfrei), Build-Kontext {{CONTEXT}}, Image-Tag
// inline der Modul-Name. Recipe-Zeilen sind TAB-eingerueckt.
const cppScopedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — C++-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only, ADR-0003); modul-scoped
# Targets (kollisionsfrei im Mono-Repo), Build-Kontext {{CONTEXT}}. Haengt an GATE_CHECKS,
# der Root-Aggregator faehrt sie via make gates.
CXX_VERSION ?= {{CXX_VERSION}}

.PHONY: test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## C++-Tests Modul {{MODULE}} (test-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## C++-Lint Modul {{MODULE}} (clang-tidy, lint-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## C++-Binary Modul {{MODULE}} bauen (build-Stage) — Docker-only
	docker build --build-arg CXX_VERSION=$(CXX_VERSION) --target build -t {{MODULE}}:build {{CONTEXT}}

GATE_CHECKS += lint-{{MODULE}} build-{{MODULE}} test-{{MODULE}}
`
