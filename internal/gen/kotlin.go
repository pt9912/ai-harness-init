package gen

import "strings"

// DefaultKotlinVersion ist der gepinnte Default des Kotlin-Skeletts — der **Tag des
// gradle-Images** (`gradle:<ver>-jdk<NN>`), nicht eine Kotlin-Version: er bestimmt Gradle und
// JDK der Gate-Stages. Kotlin-Plugin- und detekt-Version stehen per Version im Geruest
// (kotlinBuildGradle). TAG-gepinnt, ohne Digest, damit der Knopf SKEL_KOTLIN_VERSION wirkt
// (ADR-0088 Festlegung 2, LH-QA-02).
const DefaultKotlinVersion = "9.8.1-jdk21"

// kotlinProfile ist das Kotlin-SKELETT fuer den gegebenen gradle-Tag (ADR-0088): ein
// JVM-Gradle-Einzelmodul ohne Wrapper, die Gates sind Dockerfile-Stages (build/test/lint),
// Lint ist detekt. Das Code-Gate-Fragment kommt aus gen.CodeGateFragment; das Skelett selbst
// ist ortsunabhaengig. Statisch/deterministisch (LH-QA-02).
func kotlinProfile(version, arch string) map[string]string {
	return composeSkeleton(kotlinScaffolding, kotlinRole, version, arch)
}

// kotlinScaffolding — die arch-INVARIANTE Kotlin-Geruestung (ADR-0088 Festlegung 1):
// settings.gradle.kts ohne `include` (ein Modul, Schichten sind Pakete), build.gradle.kts,
// die detekt-Config und das Dockerfile.
func kotlinScaffolding(version string) map[string]string {
	return map[string]string{
		"settings.gradle.kts": kotlinSettingsGradle,
		"build.gradle.kts":    kotlinBuildGradle,
		"detekt.yml":          kotlinDetektConfig,
		"Dockerfile":          renderKotlin(kotlinDockerfileTmpl, version),
	}
}

// kotlinRole rendert eine Code-Rolle als Kotlin-Datei. Getragen ist das flache Layout
// (langArchs); Paket == Verzeichnis (ADR-0088 Festlegung 4). Eine nicht getragene
// Rolle -> nil.
func kotlinRole(r codeRole) map[string]string {
	switch r {
	case roleEntrypoint:
		return map[string]string{"src/main/kotlin/app/Main.kt": kotlinMain}
	case roleTest:
		return map[string]string{"src/test/kotlin/app/MainTest.kt": kotlinTest}
	}
	return nil
}

// kotlinFragment liefert das Kotlin-Code-Gate-Fragment: am Root (context ".") die UNSCOPED
// Fassung, im Subdir die MODUL-SCOPED. Jedes `docker build --target <stage>` referenziert eine
// gleichnamige Dockerfile-Stage — TestKotlinCodeGateFragment_TargetsMatchStages haelt die
// Kopplung (LH-QA-01).
func kotlinFragment(modul, context, version string) string {
	if context == "." {
		return renderKotlin(kotlinMkFragmentTmpl, version)
	}
	return renderKotlinScoped(kotlinScopedMkFragmentTmpl, modul, context, version)
}

// kotlinFragmentMixed liefert die gemischte Root-Fassung: modul-scoped Targets plus
// Praezedenz-Erweiterung der unscoped Ziele ohne eigenes Rezept.
func kotlinFragmentMixed(modul, context, version string) string {
	return renderKotlinScoped(kotlinMixedMkFragmentTmpl, modul, context, version)
}

// renderKotlin setzt den gradle-Tag in ein Kotlin-Template ein ({{GRADLE_TAG}}).
func renderKotlin(tmpl, version string) string {
	return strings.ReplaceAll(tmpl, "{{GRADLE_TAG}}", version)
}

// renderKotlinScoped setzt Modul-Name, Build-Kontext und gradle-Tag ein.
func renderKotlinScoped(tmpl, modul, context, version string) string {
	return strings.NewReplacer(
		"{{MODULE}}", modul,
		"{{CONTEXT}}", context,
		"{{GRADLE_TAG}}", version,
	).Replace(tmpl)
}

const kotlinSettingsGradle = `rootProject.name = "app"
`

// kotlinBuildGradle — ein JVM-Modul; Kotlin-Plugin und detekt per Version gepinnt
// (ADR-0088 Festlegung 2). Kompiliert wird mit dem JDK des gradle-Images, das der Knopf
// SKEL_KOTLIN_VERSION waehlt; das Geruest traegt darum keine jvmToolchain-Zeile.
const kotlinBuildGradle = `plugins {
    kotlin("jvm") version "2.4.21"
    application
    id("io.gitlab.arturbosch.detekt") version "1.23.8"
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
}

application {
    mainClass.set("app.MainKt")
}

detekt {
    buildUponDefaultConfig = true
    config.setFrom("detekt.yml")
}

tasks.test {
    useJUnitPlatform()
}
`

// kotlinDetektConfig — der lint-Gate ist rot/gruen (Modul 13): maxIssues 0 macht jeden
// Befund des Default-Satzes zum harten Fehler.
const kotlinDetektConfig = `# detekt.yml — generiert von ai-harness-init. Der lint-Gate ist rot/gruen (Modul 13):
# maxIssues 0 macht jeden Befund des Default-Regelsatzes (buildUponDefaultConfig) zum
# harten Fehler. Erweiterbar, wenn das Projekt waechst.
build:
  maxIssues: 0
`

const kotlinMain = `// Command app — vom ai-harness-init generiertes Kotlin-Skelett.
package app

fun greeting(name: String): String = "Hallo, $name"

fun main() {
    println(greeting("Welt"))
}
`

const kotlinTest = `// Minimaler Test ueber kotlin("test") — belegt Build und Testlauf.
package app

import kotlin.test.Test
import kotlin.test.assertEquals

class MainTest {
    @Test
    fun greetingNenntDenNamen() {
        assertEquals("Hallo, Welt", greeting("Welt"))
    }
}
`

const kotlinDockerfileTmpl = `# syntax=docker/dockerfile:1.7
# Dockerfile — generiert von ai-harness-init (Kotlin-Skelett). Jede Gate ist eine Stage
# (docker build --target <stage>); das gradle-Image ist TAG-gepinnt (kein floating), der
# Digest bewusst weggelassen, damit GRADLE_TAG ein echter Knopf bleibt. Gradle, JDK und
# die Abhaengigkeiten (Kotlin-Plugin, detekt, kotlin-test) kommen im Bild-Build — das ist
# kein Host-Toolchain-Aufruf (der Guard blockt sie nur auf dem Host).
ARG GRADLE_TAG={{GRADLE_TAG}}

FROM gradle:${GRADLE_TAG} AS toolchain
WORKDIR /src
COPY . .

FROM toolchain AS build
RUN gradle --no-daemon assemble

FROM build AS test
RUN gradle --no-daemon test

FROM toolchain AS lint
RUN gradle --no-daemon detekt
`

// kotlinMkFragmentTmpl — das Kotlin-Code-Gate-Fragment (harness/mk/kotlin.mk): lint/build/test
// als Dockerfile-Stages, an GATE_CHECKS gehaengt. Recipe-Zeilen sind TAB-eingerueckt.
const kotlinMkFragmentTmpl = `# harness/mk/kotlin.mk — Kotlin-Code-Gate-Fragment, generiert von ai-harness-init. Die
# Gates sind Dockerfile-Stages (Docker-only); dieses Fragment haengt
# lint/build/test an GATE_CHECKS, der Root-Aggregator faehrt sie via make gates.
GRADLE_TAG ?= {{GRADLE_TAG}}
IMAGE ?= app

.PHONY: test lint build

test: ## Kotlin-Tests (gradle test, Dockerfile test-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(GRADLE_TAG) --target test -t $(IMAGE):test .

lint: ## Kotlin-Lint (detekt, Dockerfile lint-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(GRADLE_TAG) --target lint -t $(IMAGE):lint .

build: ## Kotlin-Artefakt bauen (gradle assemble, Dockerfile build-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(GRADLE_TAG) --target build -t $(IMAGE):build .

GATE_CHECKS += lint build test
`

// kotlinMixedMkFragmentTmpl — die Kotlin-Fassung fuer den GEMISCHTEN Root: modul-scoped
// Targets, und die unscoped Ziele test/lint/build NUR als Praezedenz-Erweiterung ohne eigenes
// Rezept. GATE_CHECKS haengt die UNSCOPED Namen an (record-gates dedupliziert); die scoped
// Namen stehen nicht daneben, sonst liefe der Kotlin-Kontext in gates doppelt.
const kotlinMixedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — Kotlin-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only); modul-scoped
# Targets, Build-Kontext {{CONTEXT}} — ein zweites Sprach-Fragment liegt am Root, darum
# traegt dieses Fragment die unscoped Ziele test/lint/build nur als Praezedenz-Erweiterung
# ohne eigenes Rezept: make haengt Praezedenz-Listen mehrerer Regeln zusammen. Welches
# Fragment das eigene Rezept traegt, haengt vom Verlauf der add-lang-Aufrufe ab.
GRADLE_TAG ?= {{GRADLE_TAG}}

.PHONY: test lint build test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## Kotlin-Tests Modul {{MODULE}} (gradle test, test-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(GRADLE_TAG) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## Kotlin-Lint Modul {{MODULE}} (detekt, lint-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(GRADLE_TAG) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## Kotlin-Artefakt Modul {{MODULE}} bauen (build-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(GRADLE_TAG) --target build -t {{MODULE}}:build {{CONTEXT}}

test: test-{{MODULE}}
lint: lint-{{MODULE}}
build: build-{{MODULE}}

GATE_CHECKS += test lint build
`

// kotlinScopedMkFragmentTmpl — die MODUL-SCOPED Fassung fuer ein Mono-Repo-Submodul unter
// {{CONTEXT}}: modul-scoped Targets (kollisionsfrei), Image-Tag inline der Modul-Name.
const kotlinScopedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — Kotlin-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only); modul-scoped
# Targets (kollisionsfrei im Mono-Repo), Build-Kontext {{CONTEXT}}. Haengt an GATE_CHECKS,
# der Root-Aggregator faehrt sie via make gates.
GRADLE_TAG ?= {{GRADLE_TAG}}

.PHONY: test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## Kotlin-Tests Modul {{MODULE}} (gradle test, test-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(GRADLE_TAG) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## Kotlin-Lint Modul {{MODULE}} (detekt, lint-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(GRADLE_TAG) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## Kotlin-Artefakt Modul {{MODULE}} bauen (build-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(GRADLE_TAG) --target build -t {{MODULE}}:build {{CONTEXT}}

GATE_CHECKS += lint-{{MODULE}} build-{{MODULE}} test-{{MODULE}}
`
