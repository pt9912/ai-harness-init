package gen

import "strings"

// DefaultJavaVersion ist der gepinnte Default des Java-Skeletts — der **Tag des gradle-Images**
// (`gradle:<ver>-jdk<NN>`): er bestimmt Gradle und JDK der Gate-Stages. Plugin- und
// Werkzeug-Versionen (checkstyle, JUnit) stehen per Version im Geruest (javaBuildGradle).
// TAG-gepinnt, ohne Digest, damit der Knopf SKEL_JAVA_VERSION wirkt; die Konstante ist von
// DefaultKotlinVersion entkoppelt (ADR-0094 Festlegung 2, LH-QA-02).
const DefaultJavaVersion = "9.8.1-jdk21"

// javaProfile ist das Java-SKELETT fuer den gegebenen gradle-Tag (ADR-0094): ein
// JVM-Gradle-Einzelmodul ohne Wrapper, die Gates sind Dockerfile-Stages (build/test/lint),
// Lint ist Checkstyle mit eigener Config im Geruest. Das Code-Gate-Fragment kommt aus
// gen.CodeGateFragment; das Skelett selbst ist ortsunabhaengig. Statisch/deterministisch
// (LH-QA-02).
func javaProfile(version, arch string) map[string]string {
	return composeSkeleton(javaScaffolding, javaRole, version, arch)
}

// javaScaffolding — die arch-INVARIANTE Java-Geruestung (ADR-0094 Festlegung 1):
// settings.gradle.kts ohne `include` (ein Modul, Schichten waeren Pakete), build.gradle.kts,
// die Checkstyle-Config unter dem Default-Pfad des Gradle-Plugins und das Dockerfile.
func javaScaffolding(version string) map[string]string {
	return map[string]string{
		"settings.gradle.kts":              javaSettingsGradle,
		"build.gradle.kts":                 javaBuildGradle,
		"config/checkstyle/checkstyle.xml": javaCheckstyleConfig,
		"Dockerfile":                       renderJava(javaDockerfileTmpl, version),
	}
}

// javaRole rendert eine Code-Rolle als Java-Datei. Getragen sind flat und hexslice
// (langArchs); Paket == Verzeichnis. hexslice rendert die Schichten unter
// src/main/java/app/{hexagon/{domain,application},adapters/{driving,driven}}; der
// Composition Root src/main/java/app/Main.java traegt zusaetzlich den Test, weil der Test
// ueber alle Schichten verdrahtet. Eine nicht getragene Rolle -> nil.
func javaRole(r codeRole) map[string]string {
	return jvmLayout{
		srcMain: "src/main/java/app/", srcTest: "src/test/java/app/", ext: ".java",
		flatMain: javaMain, flatTest: javaTest,
		domain: javaHexDomain, inboundPort: javaHexInboundPort, slicePort: javaHexSlicePort,
		areaPort: javaHexAreaPort, handler: javaHexHandler, cli: javaHexDrivingCLI,
		repo: javaHexDrivenRepo, notify: javaHexDrivenNotify, main: javaHexMain, test: javaHexTest,
	}.role(r)
}

// javaFragment liefert das Java-Code-Gate-Fragment: am Root (context ".") die UNSCOPED
// Fassung, im Subdir die MODUL-SCOPED. Jedes `docker build --target <stage>` referenziert eine
// gleichnamige Dockerfile-Stage — TestJavaCodeGateFragment_TargetsMatchStages haelt die
// Kopplung (LH-QA-01).
func javaFragment(modul, context, version string) string {
	if context == "." {
		return renderJava(javaMkFragmentTmpl, version)
	}
	return renderJavaScoped(javaScopedMkFragmentTmpl, modul, context, version)
}

// javaFragmentMixed liefert die gemischte Root-Fassung: modul-scoped Targets plus
// Praezedenz-Erweiterung der unscoped Ziele ohne eigenes Rezept.
func javaFragmentMixed(modul, context, version string) string {
	return renderJavaScoped(javaMixedMkFragmentTmpl, modul, context, version)
}

// renderJava setzt den gradle-Tag in ein Java-Template ein ({{GRADLE_TAG}}).
func renderJava(tmpl, version string) string {
	return strings.ReplaceAll(tmpl, "{{GRADLE_TAG}}", version)
}

// renderJavaScoped setzt Modul-Name, Build-Kontext und gradle-Tag ein.
func renderJavaScoped(tmpl, modul, context, version string) string {
	return strings.NewReplacer(
		"{{MODULE}}", modul,
		"{{CONTEXT}}", context,
		"{{GRADLE_TAG}}", version,
	).Replace(tmpl)
}

const javaSettingsGradle = `rootProject.name = "app"
`

// javaBuildGradle — ein JVM-Modul mit den Gradle-Kern-Plugins java, application und
// checkstyle; Checkstyle und JUnit stehen per Version im Geruest (ADR-0094 Festlegung 2).
// maxWarnings = 0 macht jede Warnung zum harten Fehler; die Config liegt am Default-Pfad
// config/checkstyle/checkstyle.xml, darum traegt checkstyle { } keine config-Zeile.
// junit-platform-launcher steht zur Laufzeit, weil Gradle 9 ihn verlangt. Kompiliert wird mit
// dem JDK des gradle-Images, das der Knopf SKEL_JAVA_VERSION waehlt; das Geruest traegt darum
// keine toolchain-Zeile.
const javaBuildGradle = `plugins {
    java
    application
    checkstyle
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(platform("org.junit:junit-bom:6.1.3"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

application {
    mainClass.set("app.Main")
}

checkstyle {
    toolVersion = "14.3.0"
    maxWarnings = 0
}

tasks.test {
    useJUnitPlatform()
}
`

// javaCheckstyleConfig — der lint-Gate ist rot/gruen (Modul 13): Severity error und
// maxWarnings 0 in build.gradle.kts machen jeden Befund zum harten Fehler. Gebunden ist
// UnusedImports (ADR-0094 Festlegung 3); der uebrige Modul-Satz ist Geruest-Inhalt.
const javaCheckstyleConfig = `<?xml version="1.0"?>
<!DOCTYPE module PUBLIC "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
    "https://checkstyle.org/dtds/configuration_1_3.dtd">
<!--
  checkstyle.xml — generiert von ai-harness-init. Der lint-Gate ist rot/gruen (Modul 13):
  Severity error, dazu maxWarnings 0 in build.gradle.kts. Die Datei ist DEINE: sie wird beim
  Re-Bootstrap nicht ueberschrieben und waechst nur, wenn du sie pflegst.
-->
<module name="Checker">
  <property name="severity" value="error"/>
  <property name="fileExtensions" value="java"/>
  <module name="TreeWalker">
    <module name="UnusedImports"/>
    <module name="RedundantImport"/>
    <module name="AvoidStarImport"/>
  </module>
</module>
`

const javaMain = `// Command app — vom ai-harness-init generiertes Java-Skelett.
package app;

public final class Main {
    private Main() {
    }

    static String greeting(String name) {
        return "Hallo, " + name;
    }

    public static void main(String[] args) {
        System.out.println(greeting("Welt"));
    }
}
`

const javaTest = `// Minimaler Test ueber JUnit Jupiter — belegt Build und Testlauf.
package app;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class MainTest {
    @Test
    void greetingNenntDenNamen() {
        assertEquals("Hallo, Welt", Main.greeting("Welt"));
    }
}
`

const javaDockerfileTmpl = `# syntax=docker/dockerfile:1.7
# Dockerfile — generiert von ai-harness-init (Java-Skelett). Jede Gate ist eine Stage
# (docker build --target <stage>); das gradle-Image ist TAG-gepinnt (kein floating), der
# Digest bewusst weggelassen, damit GRADLE_TAG ein echter Knopf bleibt. Gradle, JDK und
# die Abhaengigkeiten (checkstyle, JUnit) kommen im Bild-Build — das ist kein
# Host-Toolchain-Aufruf (der Guard blockt sie nur auf dem Host).
ARG GRADLE_TAG={{GRADLE_TAG}}

FROM gradle:${GRADLE_TAG} AS toolchain
WORKDIR /src
COPY . .

FROM toolchain AS build
RUN gradle --no-daemon assemble

FROM build AS test
RUN gradle --no-daemon test

FROM toolchain AS lint
RUN gradle --no-daemon checkstyleMain checkstyleTest
`

// javaMkFragmentTmpl — das Java-Code-Gate-Fragment (harness/mk/java.mk): lint/build/test als
// Dockerfile-Stages, an GATE_CHECKS gehaengt. Die Make-Variable heisst JAVA_GRADLE_TAG, nicht
// GRADLE_TAG: ein Kotlin-Fragment im selben Ziel setzt GRADLE_TAG ebenfalls mit `?=`, und
// der erste gelesene Wert gaelte fuer beide Sprachen. Recipe-Zeilen sind TAB-eingerueckt.
const javaMkFragmentTmpl = `# harness/mk/java.mk — Java-Code-Gate-Fragment, generiert von ai-harness-init. Die
# Gates sind Dockerfile-Stages (Docker-only); dieses Fragment haengt
# lint/build/test an GATE_CHECKS, der Root-Aggregator faehrt sie via make gates.
JAVA_GRADLE_TAG ?= {{GRADLE_TAG}}
IMAGE ?= app

.PHONY: test lint build

test: ## Java-Tests (gradle test, Dockerfile test-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG) --target test -t $(IMAGE):test .

lint: ## Java-Lint (Checkstyle, Dockerfile lint-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG) --target lint -t $(IMAGE):lint .

build: ## Java-Artefakt bauen (gradle assemble, Dockerfile build-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG) --target build -t $(IMAGE):build .

GATE_CHECKS += lint build test
`

// javaMixedMkFragmentTmpl — die Java-Fassung fuer den GEMISCHTEN Root: modul-scoped Targets,
// und die unscoped Ziele test/lint/build NUR als Praezedenz-Erweiterung ohne eigenes Rezept.
// GATE_CHECKS haengt die UNSCOPED Namen an (record-gates dedupliziert); die scoped Namen
// stehen nicht daneben, sonst liefe der Java-Kontext in gates doppelt.
const javaMixedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — Java-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only); modul-scoped
# Targets, Build-Kontext {{CONTEXT}} — ein zweites Sprach-Fragment liegt am Root, darum
# traegt dieses Fragment die unscoped Ziele test/lint/build nur als Praezedenz-Erweiterung
# ohne eigenes Rezept: make haengt Praezedenz-Listen mehrerer Regeln zusammen. Welches
# Fragment das eigene Rezept traegt, haengt vom Verlauf der add-lang-Aufrufe ab.
JAVA_GRADLE_TAG ?= {{GRADLE_TAG}}

.PHONY: test lint build test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## Java-Tests Modul {{MODULE}} (gradle test, test-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## Java-Lint Modul {{MODULE}} (Checkstyle, lint-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## Java-Artefakt Modul {{MODULE}} bauen (build-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG) --target build -t {{MODULE}}:build {{CONTEXT}}

test: test-{{MODULE}}
lint: lint-{{MODULE}}
build: build-{{MODULE}}

GATE_CHECKS += test lint build
`

// javaScopedMkFragmentTmpl — die MODUL-SCOPED Fassung fuer ein Mono-Repo-Submodul unter
// {{CONTEXT}}: modul-scoped Targets (kollisionsfrei), Image-Tag inline der Modul-Name.
const javaScopedMkFragmentTmpl = `# harness/mk/{{MODULE}}.mk — Java-Code-Gate-Fragment (Modul {{MODULE}}), generiert von
# ai-harness-init. Gates als Dockerfile-Stages (Docker-only); modul-scoped
# Targets (kollisionsfrei im Mono-Repo), Build-Kontext {{CONTEXT}}. Haengt an GATE_CHECKS,
# der Root-Aggregator faehrt sie via make gates.
JAVA_GRADLE_TAG ?= {{GRADLE_TAG}}

.PHONY: test-{{MODULE}} lint-{{MODULE}} build-{{MODULE}}

test-{{MODULE}}: ## Java-Tests Modul {{MODULE}} (gradle test, test-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG) --target test -t {{MODULE}}:test {{CONTEXT}}

lint-{{MODULE}}: ## Java-Lint Modul {{MODULE}} (Checkstyle, lint-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG) --target lint -t {{MODULE}}:lint {{CONTEXT}}

build-{{MODULE}}: ## Java-Artefakt Modul {{MODULE}} bauen (build-Stage) — Docker-only
	docker build --build-arg GRADLE_TAG=$(JAVA_GRADLE_TAG) --target build -t {{MODULE}}:build {{CONTEXT}}

GATE_CHECKS += lint-{{MODULE}} build-{{MODULE}} test-{{MODULE}}
`
