# ADR-0094: Java-Skelett — Toolchain und Schicht-Auflösung

**Status:** Accepted

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
keine `config`-Zeile). Der gebündelte `google_checks.xml` per `fromArchiveEntry` ist in der gemessenen
Aufruf-Form **nicht** tragfähig (Messung 3: Gradle bricht mit „Expected file collection to contain
exactly one file" ab); ein Umweg über die Konfiguration ist denkbar, aber nicht Gegenstand, und die
Entscheidung für eine eigene Config bleibt davon unberührt. Der Modul-Satz der Config ist Gerüst-Inhalt;
**gebunden** ist allein, dass `UnusedImports` darin steht und `maxWarnings = 0` gilt — das ist der Fall,
der die Lint-Zeile der Fitness Function rot färbt, und eine Config ohne dieses Modul lässt sie
ungeprüft, statt zu brechen. Ein dritter Weg (Spotless, PMD, SpotBugs, Error Prone) braucht eine
Folge-ADR.

**4. Layouts und Schicht-Auflösung.** Diese ADR legt für `java` die Layouts `flat` und `hexslice`
fest; `hexagonal` legt sie nicht fest (Trigger 3). Ein Layout steht in `langArchs()` nur, wenn sein
Renderer es rendert; sonst gibt `add-lang java … --arch hexslice` Exit 2 statt eines stillen
Gerüst-only-Skeletts, und `flat` trägt kein Arch-Gate (kein Prüfbereich, [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Pfade nach [ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md):
`src/main/java/app/hexagon/{domain,application}/…`, `src/main/java/app/adapters/{driving,driven}/…`,
Composition Root `src/main/java/app/Main.java`, Tests unter `src/test/java/app/`. Die Ports-Ordner und
die Kanten-Menge der `.a-check.yml` (ADR-0060 Festlegung 4: sprach-abhängig) entscheidet der
Layout-Slice nach dem Kotlin-Muster, einschließlich der Vererbungs-Kante `driven_adapters →
ports_outbound` (`implements` importiert den Port); sie ist am Java-Fall **nicht gemessen** — die
Messung 4 prüft nur die Kante `driven_adapters → domain`. a-check-Auflösung:
`languages: java: ["**/*.java"]` und
`resolution: java: {mode: fixed-root, roots: ["src/main/java/app"], package_base: "app"}` — der Root
endet im `package_base`-Verzeichnis (Begründung: ADR-0088 Festlegung 4). **Paket == Verzeichnis** ist
Skelett-Pflicht. Der gepinnte a-check kennt `java` (Messung 4, Fixture dort):

```text
Fall 1 (R = src/main/java/app):
src/main/java/app/hexagon/domain/Greeting.java:3: core-impurity: Kern importiert app.adapters.driven.Store
gesamt: 1 Befund(e)                                    → EXIT=1
Fall 2 (R = src/main/java, bzw. kein resolution-Block):
gesamt: 0 Befund(e)  Hinweis: … 0 von 1 Import-Symbolen lösen auf eine Schicht auf   → EXIT=0
Fall 3 (erlaubte Kante driven → domain, R = src/main/java/app):
gesamt: 0 Befund(e)                                    → EXIT=0
```

Wildcard-Import (`import app.adapters.driven.*;`) und statischer Import (`import static
app.adapters.driven.Store.X;`) werden als Verstoß erkannt (beide EXIT=1, `core-impurity`; Messung 4,
Fälle 4 und 5). **Nicht erkannt:** ein voll qualifizierter Name im Code ohne `import`
(`app.adapters.driven.Store s;` → `0 Befund(e)` mit Hinweis „0 von 1 Import-Symbolen", EXIT=0;
Messung 4, Fall 6) — Grenze von a-check am Pin, vom Skelett nicht schließbar; ein Adopter kann sie
nutzen.

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
| D — Gradle-Einzelmodul, Checkstyle via gebündeltem `google_checks.xml` | keine Config-Datei im Gerüst | in der gemessenen Aufruf-Form rot (Messung 3) |
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
  Gerüst. Kein Freshness-Lauf sieht den Java-Pin: `make freshness-digest` führt laut Skriptkopf
  (`harness/tools/digest-freshness.sh`, `bash harness/tools/digest-freshness.sh --pins`) keinen
  Skelett-Pin, und die JDK-Achse von `make freshness-kotlin` liest allein die Kotlin-Konstante. Ein
  Java-Freshness-Werkzeug ist nicht Gegenstand dieser ADR und hat keinen Nehmer: der Pin altert
  unbemerkt, bis ein Adopter oder ein Beobachtungs-Eintrag es zeigt (akzeptiertes Negativ).
- Folgepflicht: `spec/architecture.md` (Layout je Sprache) für `hexslice` nachziehen — Träger ist
  `slice-java-hexslice-layout` (DoD-Punkt dort); kein Sensor hält sie.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| a-check (gepinnt) über dem Java-`hexslice`-Ziel | ein Import aus `app.hexagon.domain` nach `app.adapters` färbt a-check rot mit `core-impurity`; rot gesehen für diese Klasse am Probe-Projekt (Messung 4), am gebootstrappten Ziel noch nicht. `app-impurity` und `wrong-direction` (Rolle `app`, nicht erlaubte Kante) sind Zusage, nicht gefahren | `make full-smoke` (kein Gate) |
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
3. Checkstyle: google_checks.xml per fromArchiveEntry(configurations.checkstyle, "google_checks.xml")
   → BUILD FAILED, „Expected file collection to contain exactly one file"; eigene Config → grün;
   unbenutzter Import → BUILD FAILED, `Unused import - java.util.List. [UnusedImports]`;
   falsche Assertion → `MainTest > greetingNenntDenNamen() FAILED`
```

Das Probe-Gerüst von 2 und 3 (Gradle-Einzelmodul, ein `Main`, ein JUnit-Test, `checkstyle`-Plugin mit
`maxWarnings = 0`) liegt nicht als Datei vor; die Ergebnisse sind am Pin nachbaubar, die Dateien
selbst sind nicht Beleg. Der Reviewer-Lauf zu dieser ADR hat 1 und 3 (Lint rot bei unbenutztem Import,
`fromArchiveEntry`-Abbruch) mit eigenem Gerüst gleich gemessen.

**4.** a-check `ghcr.io/pt9912/a-check:v0.23.2`, Aufbau und Ausgaben vollständig (gefahren über
`docker create` + `docker cp <fixture>/. <id>:/src` + `docker start -a`; die Fixture ist für alle Fälle
gleich, nur Root und Zeile 3 wechseln; beim Schreiben dieser Fassung neu gefahren):

```text
Fixture: src/main/java/app/adapters/driven/Store.java   = package app.adapters.driven; class Store { static final int X = 1; }
         src/main/java/app/hexagon/domain/Greeting.java = package app.hexagon.domain; <Zeile 3: Import>; class Greeting { <Körper> }
.a-check.yml: version: 1 · languages: java: ["**/*.java"]
  layers: domain          {globs: [src/main/java/app/hexagon/domain/**],  role: domain}
          driven_adapters {globs: [src/main/java/app/adapters/driven/**], role: adapter, direction: driven}
  edges: [{from: driven_adapters, to: domain}]
  resolution: java: {mode: fixed-root, roots: [<R>], package_base: "app"}
Fall  R                  Zeile 3 / Körper                             Ausgabe                            EXIT
1     src/main/java/app  import app.adapters.driven.Store;            core-impurity …Greeting.java:3      1
2     src/main/java      import app.adapters.driven.Store;            0 Befund(e) + „0 von 1 Import-…"    0
3     src/main/java/app  driven/Store importiert domain.Greeting      0 Befund(e)                         0
4     src/main/java/app  import app.adapters.driven.*;                core-impurity …driven.              1
5     src/main/java/app  import static app.adapters.driven.Store.X;   core-impurity …Store.X              1
6     src/main/java/app  Körper: app.adapters.driven.Store s;         0 Befund(e) + „0 von 1 …"           0
```

Nicht gemessen: ein Maven-Lauf; eine Probe über dem vollständigen `hexslice`-Skelett (nur Zwei-Schichten-
Probe); die Laufzeit der Java-Stufe in `make full-smoke`.

## Entscheidungen des Auftraggebers

Getroffen am 2026-10-17 und in Festlegung 2, 3 und 5 getragen: Lint = Checkstyle mit eigener Config
(Spotless/google-java-format nicht gemessen, verworfen); JDK 21 (`gradle:9.8.1-jdk21`, JDK 25 nicht
gewählt); `mvn`/`mvnw` im Guard-Set; `slice-java-skelett` liefert nur `flat`, `hexslice` folgt in
`slice-java-hexslice-layout`.

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
| 2026-10-17 | **Accepted** | Review `2026-10-17-adr-0094-review` (0 HIGH; M-1, M-2 und L-1 bis L-4 vor der Annahme eingearbeitet; M-3 ging als Übergabe-Artefakt an den Planner), Annahme durch den Auftraggeber am 2026-10-17 ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1). Diese Datei trägt **keinen** Acceptance-Trigger; der Review-Report ist Prüfung, kein Trigger-Beleg, und eine zweite Runde war mangels blockierendem Befund nicht verlangt ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0094` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
