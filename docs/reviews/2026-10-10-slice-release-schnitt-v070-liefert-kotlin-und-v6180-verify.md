# Verifikation: slice-release-schnitt-v070-liefert-kotlin-und-v6180

Rolle Verifier. Tag-Baum HEAD `6f7a392e` (Kern `5d7e7453`, Handbuch-Datum `6f7a392e`; Review `5dc28b16`: 0 HIGH/0 MEDIUM, LOW-1 behoben). Gegenstand: DoD L1 und L2. L3 (Schritt P) ist nicht Gegenstand; kein Tag angelegt, nichts gepusht. Bezug: LH-QA-02, ADR-0058.

## Verdikte je DoD-Punkt

- **L1 Tag-Baum vorbereitet: bestätigt.**
  - `make release-artifacts DEST=<scratchpad>/dist-verify TRAEGER_VERSION=v0.7.0` → `OK — 6 Binaries + SHA256SUMS` (52 s).
  - Die sechs Digests in `SHA256SUMS` sind mengen- und plattformweise gleich den sechs `TRAEGER_SHA256_*` im `Makefile` (per Skript je Plattform verglichen: sechsmal `ok`; `diff` der sortierten Digest-Mengen leer). Der Bau reproduziert damit die Digests des Implementers. `sha256sum` des linux-amd64-Assets stichprobenweise gleich `91fe2ba5…`.
  - `TRAEGER_TAG ?= v0.7.0` in `Makefile:45` und `internal/emit/templates/enforce/traeger.mk:25`; der Tag-Wert in `test/traeger-fetch.bats` Fall 1 ist `v0.7.0`.
  - `bash harness/tools/release-sums.sh verify <dist-verify>` → alle sechs `OK`, Exit 0.
  - `make gates` auf sauberem Baum (`git status --short` leer) → `GATES_EXIT=0`, `d-check: 2686 Datei(en) geprüft, 0 Befund(e)`.
  - **Rot-Beleg 1 (Asset-Byte):** ein Byte an eine Kopie von `ai-harness-init-linux-arm64` angehängt → `ai-harness-init-linux-arm64: GESCHEITERT`, Exit 1, die übrigen fünf `OK`. Die Meldung nennt die Datei.
  - **Rot-Beleg 2 (Tag trennen):** `TRAEGER_TAG` der Vorlage auf `v0.6.9` gesetzt, `make test-bats BATS_TARGET=test/traeger-fetch.bats` → `not ok 1 pin-kopplung …`, Ursache `[ "$(pin_wert "$FRAG" 'TRAEGER_TAG')" = "v0.7.0" ] failed`; die übrigen neun Fälle grün. Der Rot-Grund ist die behauptete Kopplung. Datei danach per `git checkout` wiederhergestellt.
  - **Rot-Beleg 3 (realer Digest, benannte Lücke):** `TRAEGER_SHA256_LINUX_AMD64` im realen `Makefile` auf `00000000…` verfälscht, `traeger-fetch.bats` → alle zehn Fälle `ok`, kein Fall färbt. Fall 1 prüft für die Digests nur Vorhandensein und Länge 64 (`[ "${#mk}" -eq 64 ]`), die Fälle 4 und 6 laufen mit Fixture-Digest. **Die Lücke („realer `Makefile`-Digest ungebunden") ist damit bestätigt und gilt als Grenze:** den Pin gegen das Asset hält erst `make traeger-fetch` nach der Publikation. Sie ist in Slice-§6 Risiko 5 benannt. `Makefile` danach wiederhergestellt.
- **L2 Handbuch im Ist-Zustand: bestätigt, mit einer benannten Grenze.**
  - Stand/Version: `v0.7.0` an beiden Stellen (Zeilen 3 und 81), Stand-Datum 2026-10-10.
  - Frische Emission mit dem gebauten Programm (`--lang kotlin`, flach): die Dateimenge über dem sprachlosen Ziel ist genau die des Handbuch-Baums `<!-- baum: kotlin -->` (acht Pfade: `build.gradle.kts`, `detekt.yml`, `Dockerfile`, `harness/mk/kotlin.mk`, `settings.gradle.kts`, `Main.kt`, `MainTest.kt`, `tools/harness/blocked/kotlin`). hexslice-Emission: `GreetTest.kt`, Pakete `hexagon/{domain,application}` und `adapters/{driving,driven}`, `a-check.mk` und `.a-check.yml` vorhanden, wie im Handbuch beschrieben.
  - `--lang kotlin --arch hexagonal` → Exit 2, `unbekannte Architektur "hexagonal"; verfuegbar: flat, hexslice`. `--lang rust` → `verfuegbar: cpp, go, kotlin`. Beides deckt die Handbuch-Aussagen.
  - `KENNUNG`: in einem Ziel mit einem Slice, der `Welle: altbestand` trägt, endet `archive-welle altbestand` ohne `--kennung` mit Exit 2 und `… braucht eine Kennung … nichts wurde bewegt`, es entstehen keine Commits. Mit `--kennung K1` Exit 0, die Commit-Betreffs tragen `K1`. Das deckt die Handbuch-Zeile.
  - Alte Ziele: `DC-FA-TGT-001` steht in der `.d-check.yml`-Vorlage von `v0.6.0` (Zeile 113) und von `v0.5.0` (Zeile 82), in der Vorlage am HEAD nicht mehr. `LH-QA-01` steht in `v0.5.0` (Zeile 4), in `v0.6.0` nicht. Die Handbuch-Staffelung (bis `v0.6.0` die DC-Kennung, bis `v0.5.0` zusätzlich die Qualitäts-Kennung, Pin `v0.84.0` → `v0.86.1`) stimmt mit den Vorlagen überein.
  - Ist-Zustand-Regel: keine Prognose gefunden. Der Absatz „Ein Repository, das mit einem älteren Programm aufgesetzt wurde" nennt Versionen, beschreibt aber den heutigen Zustand liegender Ziele, nicht den Verlauf des Programms. Ich werte ihn als Ist-Zustand.
  - `make docs-check` ist Teil des grünen `make gates`.
  - **Grenze (kein Befund gegen den Slice):** die `full-smoke`-Stufe `Handbuch-Baum` misst nur `dokument-only`, `go` und `cpp` (Ausgabe: „sprachlos, --lang go, --lang cpp"; `grep 'baum: ' harness/tools/full-smoke.sh` nennt keine Kotlin-Variante). Der Kotlin-Baum im Handbuch ist damit von keinem Sensor gehalten. Hier ist er per Stichprobe an einer frischen Emission belegt, ein Wächter besteht nicht. Gehört als Beobachtung ins Register oder in einen Folge-Slice (Planner).

## Sensor-Prüfungen

- **Sensor gelaufen?** `make gates` ja, `release-artifacts` ja, `release-sums verify` ja, `traeger-fetch.bats` ja (grün, plus zwei rote Gegenproben). `make full-smoke` lief, endet aber rot an der Träger-Fetch-Stufe (siehe unten); seine Stufen danach (u. a. Kotlin-`add-lang`, Ruhe-Marker) sind **nicht gelaufen**. Das ist kein Befund am Baum, sondern die Folge des unveröffentlichten Pins.
- **Deckt der Sensor die Zusage?** Die Kopplung Tag Vorlage ↔ Makefile ist gedeckt und rot gesehen (Rot-Beleg 2). Die Kopplung Digest ↔ Asset ist ungedeckt (Rot-Beleg 3), die Zusage „Pin zeigt auf den geschnittenen Stand" ist hier durch den Neubau und Vergleich belegt, aber nur als einmalige Messung durch mich; kein Gate hält sie.
- **Plan vs. Code:** die Diffs `5f15ddc6..HEAD` bestehen aus `Makefile` (Tag und sechs Digests), `traeger.mk`, `test/traeger-fetch.bats`, `benutzerhandbuch.md`, `README.md` und dem Slice-Plan. Der Plan §3 nennt den `README.md`-Eintrag nicht ausdrücklich. Die Änderung (Sprachliste um `kotlin`, „Was heute noch fehlt") ist Gebautes ohne Plan-Zeile, sie ist aber sachlich richtig (`SupportedLangs` führt drei Sprachen) und von L2 (Zeile „weitere Versions-Pins … README.md") gedeckt. Kein Programm- oder Vorlagen-Inhalt über den Tag hinaus geändert.

## `make full-smoke` bei unveröffentlichtem Pin

- Befund: `make full-smoke` endet mit Exit 2 an der Stufe „make traeger-fetch im frischen Klon (golang)": `curl: (22) The requested URL returned error: 404`, danach `full-smoke: FEHLER — AUSGANG LEITUNG … Der Lauf bleibt rot.` (`full-smoke-ausgang.sh`, Muster 5 „Release-Asset nicht abrufbar").
- Es gibt keine 404-Sonderbehandlung, die den Lauf grün ließe. Die Klassifikation benennt den Weg (nicht mit 2xx beantwortet), nicht die Ursache; ihre eigene Grenze (Kopf von `full-smoke-ausgang.sh`) trennt ein noch nicht veröffentlichtes Release nicht von einem falschen Pin. Rot bleibt der Lauf in jedem Fall.
- Alle Stufen vor dieser Stelle waren grün (u. a. Handbuch-Baum, siehe oben).

## `make release-warten` und CI

- `release-warten.sh` urteilt nicht (Exit 0 auch nach der Grenze, Default 900 s, höchstens 7 s darüber) und fragt `SHA256SUMS` und das linux-amd64-Asset des Tags `TRAEGER_TAG` ab. Ich habe es nicht gefahren, weil es bis zur Grenze nur wartet und das Verhalten im Skriptkopf und im CI-Lauf unten sichtbar ist.
- CI-Lauf auf `main` zu `6f7a392e` (Run `38059784584`), abgefragt während meiner Arbeit: `adr-immutable` success, `smoke` success, `gates` success (am Ende der Abfrage noch laufend), **`full-smoke` steht im Schritt „Run make release-warten"**. Es wartet damit auf ein Release `v0.7.0`, das es nicht gibt (`gh release list` führt `v0.6.0` als neuestes; `git ls-remote --tags origin v0.7.0` leer).
- Folge: wird `main` mit dem Pin `v0.7.0` ohne Tag gepusht, wartet der Job `full-smoke` 15 Minuten und fällt danach an der Träger-Fetch-Stufe mit `AUSGANG LEITUNG` (404), der Lauf `ci` auf `main` wird rot. Das ist bereits eingetreten, soweit der Push von `main` erfolgt ist (die Vorgänger-Läufe `5f15ddc6` und früher tragen noch den Pin `v0.6.0` und sind grün). Zwischen dem Push von `main` und der Veröffentlichung ist `ci` auf `main` also rot oder wartend, nicht grün. Das ist der im Plan benannte Zustand (Risiko 3, `ci-rennt-gegen-die-publikation-des-gepinnten-releases`), mit dem Unterschied, dass hier zwischen Push von `main` und Tag-Push ein längeres Fenster liegt als die 15 Minuten des Warte-Fensters, wenn der Tag nicht unmittelbar folgt. Behebung: Tag-Push, Publikation, danach `gh run rerun --failed` auf dem `full-smoke`-Job (Plan L3).

## Findings

- **F1 (bedingt, Planner/Auftraggeber):** `main` mit Pin `v0.7.0` ist vor der Veröffentlichung rot in `ci`/`full-smoke`. Reihenfolge Schritt P: `main` und Tag in einem Zug oder Tag unmittelbar nach `main`, damit das 15-Minuten-Fenster von `release-warten` trägt; andernfalls Re-Run nach Publikation.
- **F2 (Grenze, kein Blocker):** Handbuch-Baum `kotlin` hat keinen Sensor in `full-smoke` (nur `dokument-only`, `go`, `cpp`). Stichprobe von mir bestätigt den Inhalt. Beobachtung/Folge-Slice-Kandidat.
- **F3 (Grenze, bekannt):** realer `Makefile`-Digest ist ungebunden (Rot-Beleg 3), Risiko 5 des Slice. Bindung erst durch `make traeger-fetch` nach der Publikation (L3).
- Negativbefunde: kein Pin-/Digest-Unterschied zwischen Bau und `Makefile`; keine Prognose und keine Chronik im Handbuch gefunden; kein Plan-vs-Code-Unterschied außer dem README-Eintrag (F-frei).

## Bereitschaft für Schritt P

Der Tag-Baum ist für L1 und L2 bereit: Bau reproduziert die Pins, `release-sums verify` Exit 0, `make gates` grün auf sauberem Baum, Handbuch deckt die Emission. Offen bleiben nur Dinge, die erst nach dem Tag lösbar sind (L3: Fetch gegen das Asset, `full-smoke` komplett, `ci`, Tap). Voraussetzung: dieser Bericht als Report-Commit ändert den Baum nach dem Stempel, daher vor dem Push `make gates` auf dem dann finalen Commit erneut fahren (Plan §3 Punkt 4).
