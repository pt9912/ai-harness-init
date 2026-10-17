# ADR-0094: Java-Skelett — Toolchain und Schicht-Auflösung

**Status:** Proposed

**Datum:** 2026-10-17

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0088](0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) (Vorbild),
[ADR-0008](0008-arch-achse-emittiertes-skelett.md), [ADR-0009](0009-hexslice-arch-realisierung.md),
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md); Gegenstand von
`slice-java-skelett` (Welle `welle-sprachprofile-java-python-csharp`)

**Schärft:** [`ARC-009`, `ARC-010`](../../../spec/architecture.md#1-komponenten-übersicht)
(Generator und Verdrahtung für die Sprache `java`).

**Verfeinert (nicht supersedet):** [ADR-0088](0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)
— dessen Mechanik (Einzelmodul, Image-Pin-Form, Stage-Fragment, Auflösung `fixed-root`) gilt
unverändert und wird hier nur auf Java angewandt; [ADR-0008](0008-arch-achse-emittiertes-skelett.md),
[ADR-0009](0009-hexslice-arch-realisierung.md) bleiben unberührt.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

[`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) führt `java` in der
Sprachliste; ein Change Request ist nicht nötig. Offen sind die Entscheidungen mit Folgen: Build-Werkzeug,
Image und JDK, Lint, Layout-Menge, Schicht-Auflösung. Die Bau-Gerüstung muss arch-invariant bleiben
([ADR-0008](0008-arch-achse-emittiertes-skelett.md), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)
AC *Arch-Achse*). Der gepinnte a-check (`grep -n 'DefaultArchImage  =' internal/emit/archgate.go` → `v0.23.2`)
nennt in seinem Gerüst `kotlin` als Beispiel für den `resolution`-Block; ob er `java` kennt, ist
unter Festlegung 4 gemessen.

## Entscheidung

Wir wählen **ein JVM-Gradle-Einzelmodul mit Paketen als Schichten, Checkstyle als Lint mit eigener
Config im Gerüst, JUnit Jupiter als Test, Layouts `flat` und `hexslice`**.

**1. Modul-Schnitt und Build-Werkzeug.** Gradle, ein Modul (`settings.gradle.kts` ohne `include`),
Schichten sind Pakete; Begründung, Wrapper-Verzicht und Netz beim `docker build` des Ziels stehen in
[ADR-0088](0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegungen 1 und 2 und gelten
für Java unverändert. Maven ist verworfen (Alternativen).

**2. Image, JDK, Pins.** Image `gradle:<ver>-jdk<NN>`, per **Tag** gepinnt (kein Digest im Gerüst,
damit der Knopf wirkt — dieselbe Form wie Kotlin), Knopf `SKEL_JAVA_VERSION` →
`gen.DefaultVersion("java")` mit eigener Konstante, nicht an die Kotlin-Konstante gekoppelt. JDK:
**21 (LTS)**. Der konkrete Tag ist ein Wert, der mit dem Pin wandert; gemessen ist, dass er existiert
und das Gerüst darauf grün läuft (Messung 1, 2). Plugin- und Werkzeug-Versionen stehen per Version im
Gerüst: `checkstyle` `toolVersion`, JUnit über `org.junit:junit-bom`. Die Plugin-Schlüssel sind
Gradle-Kern (`java`, `application`, `checkstyle`) — kein Fremd-Plugin, daher kein zweiter Pin-Pfad.

**3. Test und Lint.** `test`/`lint`/`build` sind Dockerfile-Stages (`gradle test`,
`gradle checkstyleMain checkstyleTest`, `gradle assemble`), gekoppelt an das Code-Gate-Fragment wie bei
go/cpp/kotlin. Test: JUnit Jupiter (`useJUnitPlatform()`, `junit-platform-launcher` zur Laufzeit —
Gradle 9 verlangt ihn). Lint: **Checkstyle** mit `maxWarnings = 0` und einer **eigenen, kompakten**
`config/checkstyle/checkstyle.xml` im Gerüst (Severity `error`, Default-Pfad des Gradle-Plugins, also
keine `config`-Zeile). Der gebündelte `google_checks.xml` per `fromArchiveEntry` ist **nicht**
tragfähig (Messung 3: Gradle bricht mit „Expected file collection to contain exactly one file" ab); ein
Gerüst, das ihn trüge, bräuchte einen Umweg über die Konfiguration. Der Modul-Satz der Config ist
Gerüst-Inhalt, kein Teil dieser Entscheidung, solange die Fitness Function trägt. Ein dritter Weg
(Spotless, PMD, SpotBugs, Error Prone) braucht eine Folge-ADR.

**4. Layouts und Schicht-Auflösung.** Diese ADR legt für `java` die Layouts `flat` und `hexslice`
fest; `hexagonal` legt sie nicht fest (Trigger 3). Ein Layout steht in `langArchs()` nur, wenn sein
Renderer es rendert; sonst gibt `add-lang java … --arch hexslice` Exit 2 statt eines stillen
Gerüst-only-Skeletts, und `flat` trägt kein Arch-Gate (kein Prüfbereich, [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Pfade nach [ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md):
`src/main/java/app/hexagon/{domain,application}/…`, `src/main/java/app/adapters/{driving,driven}/…`,
Composition Root `src/main/java/app/Main.java`, Tests unter `src/test/java/app/`. a-check-Auflösung:
`languages: java: ["**/*.java"]` und
`resolution: java: {mode: fixed-root, roots: ["src/main/java/app"], package_base: "app"}` — der Root
endet im `package_base`-Verzeichnis (Begründung: ADR-0088 Festlegung 4). **Paket == Verzeichnis** ist
Skelett-Pflicht. Der gepinnte a-check kennt `java` (Messung 4):

```text
$ # Domain importiert app.adapters.driven.Store; roots: ["src/main/java/app"]
src/main/java/app/hexagon/domain/Greeting.java:3: core-impurity: Kern importiert app.adapters.driven.Store
gesamt: 1 Befund(e)                                    → EXIT=1
$ # roots: ["src/main/java"]  bzw. kein resolution-Block
gesamt: 0 Befund(e)  Hinweis: … 0 von 1 Import-Symbolen lösen auf eine Schicht auf   → EXIT=0
$ # erlaubte Kante (driven → domain), roots: ["src/main/java/app"]
gesamt: 0 Befund(e)                                    → EXIT=0
```

Wildcard-Import (`import app.adapters.driven.*;`) und statischer Import werden als Verstoß erkannt
(beide EXIT=1, `core-impurity`). **Nicht erkannt:** ein voll qualifizierter Name im Code ohne
`import` (`app.adapters.driven.Store s;` → `0 Befund(e)`, EXIT=0) — Grenze von a-check am Pin, vom
Skelett nicht schließbar; ein Adopter kann sie nutzen.

**5. Guard.** `blockedByLang("java")` nimmt die Host-Toolchain auf: `gradle gradlew java javac jar
jshell checkstyle mvn mvnw`. `mvn`/`mvnw` stehen darin, obwohl das Gerüst kein Maven nutzt: sie sind
der naheliegende Host-Umweg an der verworfenen Alternative. Die Kopplung an `gen.SupportedLangs`
hält der bestehende Test; die Vereinigung mit dem Kotlin-Fragment (gemeinsame Namen) ist unschädlich,
weil der Guard die Menge als Union liest.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (Java bleibt ungerendert) | kein Aufwand | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nennt Java; die Welle hätte keinen Gegenstand |
| B — Maven (`maven:3.9-eclipse-temurin-21`) | verbreitet, deklarativ | anderes Image- und Fragment-Muster als Kotlin; Image existiert (Messung 1), ein Bau-/Lint-Lauf ist **nicht** gemessen |
| C — Gradle Multi-Modul je Schicht | Compiler erzwingt die Grenze | Gerüstung arch-abhängig → bricht [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) AC *Arch-Achse*, nur mit CR |
| D — Gradle-Einzelmodul, Checkstyle via gebündeltem `google_checks.xml` | keine Config-Datei im Gerüst | in dieser Form rot (Messung 3) |
| **E — Gradle-Einzelmodul, Checkstyle mit eigener Config, JUnit Jupiter, flat+hexslice, JDK 21** | gleiches Muster wie Kotlin; Gradle-Kern-Plugins ohne Fremd-Pin; Lint rot/grün gemessen; a-check löst Java auf | Config-Datei gehört dem Adopter und driftet; Checkstyle ist Stil-/Konventions-Check, keine Datenfluss-Analyse; Schicht-Grenze nur über a-check |
| F — Spotless/google-java-format oder SpotBugs/PMD als Lint | Formatierung bzw. Analyse | Fremd-Plugin mit eigener Version; nicht gemessen |
| G — zusätzlich `hexagonal`, JDK 25 | volle Achse; neuere LTS | `hexagonal` ohne benannten Bedarf; JDK 25 trägt das Gerüst ebenfalls (Messung 2), bringt aber keinen benannten Nutzen |

## Konsequenzen

- Positiv: Java dockt an die sprach-agnostischen Stellen an (Kompositions-Seam, Arch-Gate-Bedingung);
  keine Anforderung an a-check oder d-check.
- Negativ (akzeptiert): je Java-Stufe ein `docker build` mit Dependency-Auflösung verlängert
  `make full-smoke`; der Zuwachs wird je Slice gemessen.
- Negativ (akzeptiert): Paket ≠ Verzeichnis und ein voll qualifizierter Name ohne `import` entgehen
  dem Arch-Gate (Festlegung 4).
- Negativ (akzeptiert): der Pin ist ein Tag; der `@sha256` steht nur als Messung dieser ADR, nicht im
  Gerüst. Ob `make freshness-digest` den Java-Pin erfasst, entscheidet dessen Skriptkopf und ist nicht
  Gegenstand dieser ADR.
- Folgepflicht: `spec/architecture.md` (Layout je Sprache) für `hexslice` nachziehen.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| a-check (gepinnt) über dem Java-`hexslice`-Ziel | ein Import aus `app.hexagon.domain` nach `app.adapters` färbt a-check rot mit `core-impurity` (bei Rolle `app` `app-impurity`) oder `wrong-direction`; rot gesehen am Probe-Projekt (Messung 4), am gebootstrappten Ziel noch nicht | `make full-smoke` (kein Gate) |
| Code-Gate-Fragment ↔ Dockerfile | jedes Ziel `test`/`lint`/`build` des Java-Fragments hat seine Stage — Zusage eines eigenen Tests nach dem Muster `TestCppCodeGateFragment_TargetsMatchStages`; Zusage, nicht Beleg | `make test` |
| Lint und Test rot | unbenutzter Import färbt `lint` rot (`[UnusedImports]`), eine falsche Assertion `test`; rot gesehen am Probe-Projekt (Messung 3) | `make gates` im Ziel |
| Guard ↔ `gen.SupportedLangs` | ein Profil ohne `blockedByLang`-Eintrag färbt den bestehenden Kopplungs-Test rot; für `java` Zusage, Beleg entsteht mit dem Eintrag | `make test` |

Lücke: kein Sensor hält die Probe-Messung gegen das emittierte Skelett — bis das Skelett existiert,
tragen die Zeilen Zusage statt Beleg ([`AGENTS.md`](../../../AGENTS.md) §3.6). Lücke: [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
verlangt Reproduzierbarkeit gemessen als Vergleich zweier Bauten desselben Tags; kein Lauf vergleicht
sie (`BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`), das Java-Image erbt das.

## Messungen

Methode: Der Docker-Daemon sieht das Scratchpad nicht als Mount; die Probe läuft über
`docker create` + `docker cp` (a-check) bzw. `docker build` mit Kontext (Gradle).

```text
1. $ docker buildx imagetools inspect gradle:9.8.1-jdk21     → Digest sha256:5ec5f726f14851a11a1bac6e6a5720e41062c33357053e7717eb0d189a6f1db9
   $ docker buildx imagetools inspect gradle:9.8.1-jdk25     → Digest sha256:4a80c8083135754f689c3e31bb858a22282c66f5625cafb09ed217814b363ee5
   $ docker buildx imagetools inspect maven:3.9-eclipse-temurin-21 → Digest sha256:99e61abcff91a9b1333463bd8451fb18495d6eba9250ac66a338b518f8278320
2. $ docker build --target build|test|lint  (Gradle-Einzelmodul, Java, JUnit 6.1.3, checkstyle 14.3.0)
   jdk21: BUILD SUCCESSFUL (je Stage); jdk25: lint, test BUILD SUCCESSFUL
3. Checkstyle: google_checks.xml per fromArchiveEntry → BUILD FAILED, „Expected file collection to
   contain exactly one file"; eigene Config → grün; unbenutzter Import → BUILD FAILED, `Unused import -
   java.util.List. [UnusedImports]`; falsche Assertion → `MainTest > greetingNenntDenNamen() FAILED`
4. a-check ghcr.io/pt9912/a-check:v0.23.2 — Ausgaben und Exit-Codes wie unter Festlegung 4
```

Nicht gemessen: ein Maven-Lauf; eine Probe über dem vollständigen `hexslice`-Skelett (nur Zwei-Schichten-
Probe); die Laufzeit der Java-Stufe in `make full-smoke`.

## Offene Entscheidungen des Auftraggebers

- Lint-Werkzeug: Checkstyle mit eigener Config (Empfehlung, gemessen) oder Spotless/google-java-format
  (nicht gemessen, bräuchte Probe). Hängt ab: Festlegung 3.
- JDK: 21 (Empfehlung, gleicher Tag wie Kotlin, gemeinsamer Image-Cache) oder 25 (gemessen tragfähig).
  Hängt ab: Festlegung 2 und die JDK-Achse von `make freshness-kotlin`, die nur die Kotlin-Konstante liest.
- `mvn`/`mvnw` im Guard-Set: Empfehlung ja. Hängt ab: Festlegung 5.

## Re-Evaluierungs-Trigger

- Das Gegenbeispiel aus der Fitness Function färbt am `hexslice`-Ziel nicht rot → zuerst die Config
  gegen a-check prüfen: meldet der Lauf „0 von N Import-Symbolen lösen auf", ist es ein Config-Fehler
  (Festlegung 4). Erst wenn eine Config, die Importe auflöst, grün bleibt → Anforderung an a-check.
- Checkstyle läuft mit der gepinnten Gradle-/JDK-Kombination nicht grün, oder Gradle verlangt einen
  anderen Test-Laufzeit-Zuschnitt → Festlegung 2 und 3.
- Ein Adopter verlangt `hexagonal` → Folge-ADR mit Pfaden und Auflösung; Multi-Modul → mit CR an
  [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4); Maven → Folge-ADR.
- Der a-check-Pin hebt die Grenze „voll qualifizierter Name ohne `import`" auf oder verschärft sie →
  Festlegung 4.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-17 | Proposed | `slice-java-skelett` |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0094` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
