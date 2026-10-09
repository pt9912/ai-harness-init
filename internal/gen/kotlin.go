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

// kotlinRole rendert eine Code-Rolle als Kotlin-Datei. Getragen sind flat und hexslice
// (langArchs); Paket == Verzeichnis (ADR-0088 Festlegung 4). hexslice rendert die Schichten
// unter src/main/kotlin/app/{hexagon/{domain,application},adapters/{driving,driven}}; der
// Composition Root src/main/kotlin/app/Main.kt traegt zusaetzlich den Test, weil der Test
// ueber alle Schichten verdrahtet. Eine nicht getragene Rolle -> nil.
func kotlinRole(r codeRole) map[string]string {
	const hex = "src/main/kotlin/app/hexagon/"
	const adapters = "src/main/kotlin/app/adapters/"
	switch r {
	case roleEntrypoint:
		return map[string]string{"src/main/kotlin/app/Main.kt": kotlinMain}
	case roleTest:
		return map[string]string{"src/test/kotlin/app/MainTest.kt": kotlinTest}
	case roleDomain:
		return map[string]string{hex + "domain/example/Greeting.kt": kotlinHexDomain}
	case rolePorts:
		return map[string]string{
			hex + "application/example/greet/ports/inbound/Greet.kt":          kotlinHexInboundPort,
			hex + "application/example/greet/ports/outbound/Notifier.kt":      kotlinHexSlicePort,
			hex + "application/example/ports/outbound/GreetingRepository.kt": kotlinHexAreaPort,
		}
	case roleAppSlice:
		return map[string]string{hex + "application/example/greet/Handler.kt": kotlinHexHandler}
	case roleAdapters:
		return map[string]string{
			adapters + "driving/cli/example/Cli.kt":                   kotlinHexDrivingCLI,
			adapters + "driven/memory/example/InMemoryRepository.kt": kotlinHexDrivenRepo,
			adapters + "driven/notify/StdoutNotifier.kt":             kotlinHexDrivenNotify,
		}
	case roleCompositionRoot:
		return map[string]string{
			"src/main/kotlin/app/Main.kt":     kotlinHexMain,
			"src/test/kotlin/app/GreetTest.kt": kotlinHexTest,
		}
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

// Das hexSlice-Layout fuer Kotlin (ADR-0088 Festlegung 4): die Schichten sind Pakete unter
// src/main/kotlin/app, Paket == Verzeichnis. Die Schicht-Dateien referenzieren einander
// ausschliesslich ueber vollqualifizierte `import app.…`-Zeilen; genau diese Form loest die
// a-check-Config (resolution kotlin, fixed-root mit package_base app) auf einen Pfad auf.
// Ein Paket ausserhalb seines Verzeichnisses entgeht der Aufloesung;
// TestKotlinHexslice_PaketGleichVerzeichnis haelt die Form am generierten Skelett.

const kotlinHexDomain = `// Domain-Schicht des generierten hexSlice-Skeletts: importiert nur sich selbst.
package app.hexagon.domain.example

class Greeting private constructor(val message: String) {
    companion object {
        // of liefert null fuer eine leere Nachricht — die Invariante der Domain.
        fun of(message: String): Greeting? = if (message.isBlank()) null else Greeting(message)
    }
}
`

const kotlinHexInboundPort = `// Port-Schicht (inbound, greet): der Vertrag, ueber den die Welt die Use-Case ruft.
// Er spricht schlichte Typen und importiert die Domain nicht.
package app.hexagon.application.example.greet.ports.inbound

interface Greet {
    fun greet(message: String): String?
}
`

const kotlinHexSlicePort = `// Port-Schicht (outbound, slice-lokal, greet): der Kanal, ueber den die Use-Case meldet.
package app.hexagon.application.example.greet.ports.outbound

interface Notifier {
    fun send(message: String)
}
`

const kotlinHexAreaPort = `// Port-Schicht (outbound, business-area-geteilt): importiert nur die Domain.
package app.hexagon.application.example.ports.outbound

import app.hexagon.domain.example.Greeting

interface GreetingRepository {
    fun save(greeting: Greeting)
}
`

const kotlinHexHandler = `// Application-Schicht (Use-Case-Slice greet): app -> domain, app -> ports, nie Adapter.
package app.hexagon.application.example.greet

import app.hexagon.application.example.greet.ports.inbound.Greet
import app.hexagon.application.example.greet.ports.outbound.Notifier
import app.hexagon.application.example.ports.outbound.GreetingRepository
import app.hexagon.domain.example.Greeting

class Handler(
    private val repository: GreetingRepository,
    private val notifier: Notifier,
) : Greet {
    override fun greet(message: String): String? {
        val greeting = Greeting.of(message) ?: return null
        repository.save(greeting)
        notifier.send(greeting.message)
        return greeting.message
    }
}
`

const kotlinHexDrivingCLI = `// Adapter-Schicht (driving, CLI): spricht die Use-Case nur ueber ihren inbound-Port.
package app.adapters.driving.cli.example

import app.hexagon.application.example.greet.ports.inbound.Greet

class Cli(private val greet: Greet) {
    fun run(message: String): Boolean = greet.greet(message) != null
}
`

const kotlinHexDrivenRepo = `// Adapter-Schicht (driven, In-Memory): erfuellt den Area-Port durch Vererbung und
// importiert ihn deshalb (die driven_adapters -> ports_outbound-Kante der Config).
package app.adapters.driven.memory.example

import app.hexagon.application.example.ports.outbound.GreetingRepository
import app.hexagon.domain.example.Greeting

class InMemoryRepository : GreetingRepository {
    private val stored = mutableListOf<Greeting>()

    val saved: List<Greeting>
        get() = stored.toList()

    override fun save(greeting: Greeting) {
        stored.add(greeting)
    }
}
`

const kotlinHexDrivenNotify = `// Adapter-Schicht (driven, Ausgabe): erfuellt den slice-lokalen Notifier-Port.
package app.adapters.driven.notify

import app.hexagon.application.example.greet.ports.outbound.Notifier

class StdoutNotifier(private val out: Appendable) : Notifier {
    override fun send(message: String) {
        out.appendLine(message)
    }
}
`

// kotlinHexMain — Composition Root: verdrahtet Adapter, Ports und Use-Case-Slice; die
// a-check-Config fuehrt ihn als composition_root.
const kotlinHexMain = `// Command app — vom ai-harness-init generiertes hexSlice-Skelett. Composition Root:
// verdrahtet Adapter, Ports und Use-Case-Slices (a-check-exempt).
package app

import app.adapters.driven.memory.example.InMemoryRepository
import app.adapters.driven.notify.StdoutNotifier
import app.adapters.driving.cli.example.Cli
import app.hexagon.application.example.greet.Handler
import kotlin.system.exitProcess

fun main() {
    val handler = Handler(InMemoryRepository(), StdoutNotifier(System.out))
    if (!Cli(handler).run("Hallo vom generierten hexSlice-Skelett.")) {
        exitProcess(1)
    }
}
`

// kotlinHexTest — Test ueber kotlin("test"): die Domain-Invariante und der Durchlauf der
// Use-Case ueber beide getriebenen Adapter.
const kotlinHexTest = `// Minimaler Test ueber kotlin("test") — Domain-Invariante und greet-Use-Case.
package app

import app.adapters.driven.memory.example.InMemoryRepository
import app.adapters.driven.notify.StdoutNotifier
import app.hexagon.application.example.greet.Handler
import app.hexagon.domain.example.Greeting
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class GreetTest {
    @Test
    fun leereNachrichtVerletztDieInvariante() {
        assertNull(Greeting.of(""))
    }

    @Test
    fun handlerSpeichertUndMeldet() {
        val repository = InMemoryRepository()
        val sink = StringBuilder()
        val handler = Handler(repository, StdoutNotifier(sink))
        assertEquals("hi", handler.greet("hi"))
        assertEquals(listOf("hi"), repository.saved.map { it.message })
        assertEquals("hi\n", sink.toString())
    }
}
`

// kotlinHexArchConfig — die .a-check.yml des hexSlice-Kotlin-Moduls (ADR-0088 Festlegung 4,
// LH-FA-07). MODUL-relativ (der Gate-Lauf mountet das Modul-Verzeichnis). Gegenueber der
// cpp-Fassung traegt sie den resolution-Block: ohne ihn loest kein `import app.…` auf eine
// Schicht auf, und das Gate bleibt ueber jedem Import gruen. Der Root endet im
// package_base-Verzeichnis, weil a-check `app.` vom Import abstreift, bevor es den Root
// voranstellt. Die driven_adapters -> ports_outbound-Kante folgt der Vererbungs-Erfuellung
// wie bei cpp.
const kotlinHexArchConfig = `# .a-check.yml — Architektur-Gate (HexSlice = hexagonal + vertical slice),
# emittiert von ai-harness-init. Bildet die Schichten des generierten hexSlice-
# Skeletts ab; a-check laeuft netzlos + read-only (make a-check).
#
# Streng dekodiert: ein unbekannter Schluessel ist Exit 2.
#
# Die Schichten sind Pakete, und Paket == Verzeichnis ist Pflicht: a-check loest
# einen Import (app.adapters.driven.notify.StdoutNotifier) ueber den PFAD auf —
# es streift package_base ("app.") ab, ersetzt die Punkte durch "/" und stellt
# den Root voran (src/main/kotlin/app/adapters/driven/notify/...). Ein Paket, das
# nicht in seinem Verzeichnis liegt, entgeht damit der Pruefung. Der Root endet
# darum im package_base-Verzeichnis; ein Root src/main/kotlin loest keinen Import
# auf, und a-check meldet dann "0 von N Import-Symbolen loesen auf".
#
# Die Slice-Globs (.../greet/**) und Port-Globs (.../ports/<richtung>/**) tragen
# bewusst literale Verzeichnis-Praefixe. Nur daran haengen die beiden Vertical-
# Slice-Regeln: lateral-slice (eine Slice importiert keine andere derselben
# Schicht) und port-locality (ein slice-lokaler Port bleibt in seiner Slice).
# Behalte jede Port-Glob-Endung auf ihrer Richtung.
#
# DIESE DATEI IST DEINE: sie wird beim Re-Bootstrap nicht ueberschrieben, also
# waechst sie nur, wenn du sie pflegst. Zwei Faelle:
#   - Area/Slice UMBENANNT  -> die Globs mitziehen.
#   - Slice HINZUGEFUEGT    -> je einen app-Glob (.../<neue-slice>/**) und, falls
#     sie Ports traegt, je einen ports-Glob (.../<neue-slice>/ports/<richtung>/**)
#     ERGAENZEN. Vergisst du es, faellt der neue Code unter keine Schicht: importiert
#     er eine (Domain/Ports), meldet a-check wrong-direction und faellt — importiert
#     er keine, bleibt er still gruen und ungeprueft.
version: 1

languages:
  kotlin: ["**/*.kt"]

layers:
  domain:
    globs: ["src/main/kotlin/app/hexagon/domain/**"]
    role: domain
  ports_inbound:
    globs:
      - "src/main/kotlin/app/hexagon/application/example/greet/ports/inbound/**"   # use-case-lokal
    role: port
    direction: inbound      # von der Use-Case angeboten; ein driving Adapter ruft ihn
  ports_outbound:
    globs:
      - "src/main/kotlin/app/hexagon/application/example/greet/ports/outbound/**"   # use-case-lokal
      - "src/main/kotlin/app/hexagon/application/example/ports/outbound/**"         # business-area-geteilt
    role: port
    direction: outbound     # von der Use-Case gebraucht; ein driven Adapter erfuellt ihn
  app:
    globs:
      - "src/main/kotlin/app/hexagon/application/example/greet/**"         # Slice: greet
    role: app
  driving_adapters:
    globs: ["src/main/kotlin/app/adapters/driving/**"]
    role: adapter
    direction: driving      # ruft den Anwendungskern
  driven_adapters:
    globs: ["src/main/kotlin/app/adapters/driven/**"]
    role: adapter
    direction: driven       # wird vom Anwendungskern gerufen

# Erlaubte gerichtete Abhaengigkeiten (nur nach innen). Ein Cross-Layer-Import
# ohne passende Kante ist ein Befund (wrong-direction).
edges:
  - {from: app,              to: domain}
  - {from: app,              to: ports_inbound}    # die Slice implementiert ihren inbound-Port
  - {from: app,              to: ports_outbound}   # die Slice ruft ihre outbound-Ports
  - {from: ports_outbound,   to: domain}
  - {from: driving_adapters, to: ports_inbound}    # der treibende Adapter spricht die inbound-Ports
  - {from: driven_adapters,  to: domain}           # Adapter bilden auf/von Domain-Objekten ab
  - {from: driven_adapters,  to: ports_outbound}   # der getriebene Adapter ERBT vom Port
                                                   # (Kotlin-Interface) und importiert ihn.

# Der Composition Root verdrahtet Adapter und Slices — von den Schichtregeln befreit.
composition_root: ["src/main/kotlin/app/Main.kt"]

# Tests gehoeren nicht zum Produktions-Abhaengigkeitsgraphen.
exclude:
  - "src/test/**"

# Paket -> Pfad: package_base wird vom Import abgestreift, der Root vorangestellt.
resolution:
  kotlin:
    mode: fixed-root
    roots: ["src/main/kotlin/app"]
    package_base: "app"
`
