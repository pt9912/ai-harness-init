# Review slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten

- **Rolle:** Reviewer (frischer Kontext) · **Diff:** `3ea59b26..70f89b6b` (aef65e6a L1, a0bd3370 L2, 94a84e40 L3, 70f89b6b Lint-Nachzug)
- **Plan:** `docs/plan/planning/in-progress/slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten.md` (wellenlos)
- **Bezug:** `LH-QA-02`, ADR-0058, ADR-0059, ADR-0064, ADR-0066, Architect-Verdikt V-1 (`2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt`), `AGENTS.md` §3.1/3.2/3.5/3.6/3.7/3.9
- **Summary:** 0 HIGH · 1 MEDIUM · 0 LOW · 2 INFO

## Findings

### F-1 MEDIUM — `.PHONY` verliert zwei Targets durch fehlendes Leerzeichen
- `kategorie`: MEDIUM · `quelle`: Maintainability / `LH-QA-01` · `pfad`: `Makefile:55`
- `befund`: Die Zeile lautet jetzt `… traeger-pins-check tap-checktap-nachzug vendor-baseline`; im Basisstand (`3ea59b26`) standen `tap-check` und `tap-nachzug` getrennt. `tap-check` und `tap-nachzug` sind damit nicht mehr als `.PHONY` deklariert, und ein Phantom-Target `tap-checktap-nachzug` entsteht. Failure-Szenario: liegt im Wurzelverzeichnis eine Datei `tap-check`, meldet `make tap-check` „up to date" und prüft nichts.
- Beleg: `sed -n 55p Makefile | tr ' ' '\n' | grep -n tap` → `49:tap-checktap-nachzug`; Basis: `git show 3ea59b26:Makefile | sed -n 55p | tr ' ' '\n' | grep -n tap` → `48:tap-check`, `49:tap-nachzug`.
- `verifizierbar`: ja (Zeilenvergleich; kein Gate fängt es) · `klasse`: „Teilersetzung in Listenzeile verschmilzt zwei Einträge"

### F-2 INFO — Test bindet die Exaktheit der Namens-Paarung nicht (Teilzeichenkette überlebt)
- `quelle`: `AGENTS.md` §3.6 · `pfad`: `test/traeger-pins-check.bats` (Fixture), `harness/tools/traeger-pins-check.sh:123`
- `befund`: Mutation `awk '$2 == a'` → `awk '$2 ~ a'` lässt alle 14 Fälle grün (gefahren, in-place, zurückgesetzt). Die Fixture führt keinen fremden Eintrag, der den Asset-Namen enthält (etwa `…-linux-amd64.sig`); die Zusage „Paarung nach Name" ist gegen Position gebunden, nicht gegen Teilzeichenkette. Folge im Fehlerfall wäre ein fail-closed Exit 2 („mehrfach"), kein stilles Grün — darum INFO.
- `verifizierbar`: ja · `klasse`: „Zugehörigkeit per Teilzeichenkette statt per Grenze, Fixture ohne Fremdwert"

### F-3 INFO — Gegenprobe zu Fall 774 „nur der benannte Test" nicht gefahren
- `befund`: Der Kopf von Fall 774 behauptet keine Exklusivität, die Gegenprobe (`skip` ausschließlich im Test „paarung nach name: gleiche Pins …") wurde nicht gefahren; es ist nicht belegt, ob weitere Tests dieselbe Stelle binden. Kein Befund über LOW, da keine Exklusivität behauptet ist.
- `klasse`: „Mutations-Fall nennt einen Test, Mitfärbung ungeprüft"

## Gefahrene Proben (alle in-place, per `git checkout --` zurückgesetzt; `git status --short` leer)

| Probe | Ergebnis |
|---|---|
| `make traeger-pins-check TAG=v0.10.0` (real, Netz) | Exit 0, Zeile `traeger-pins-check: gleich — alle 6 Pins halten gegen die SHA256SUMS von v0.10.0.` |
| selber Lauf, `TRAEGER_SHA256_WINDOWS_ARM64=000…0` als Make-Kommandozeilen-Override (Nicht-Host-Plattform; Makefile unberührt) | Prozess-Exit 2, stderr: nur `TRAEGER_SHA256_WINDOWS_ARM64 weicht ab — Pin 000…, SHA256SUMS von v0.10.0 fuehrt f87b07b4… fuer ai-harness-init-windows-arm64.exe`, `Unterschied bei 1 von 6 Plattformen`, `traeger-pins-check: Exit 1`, danach `make: *** … Error 1` — die Doku-Aussage „über make Exit 2, Klasse des Skripts in der Zeile, vorletzte Zeile der Ausgabe" trifft |
| Override `TRAEGER_SHA256_LINUX_ARM64=` (leer) | Exit 2, `… ist nicht gesetzt`, `Exit 2` |
| `MUTATE_CASES=774-traeger-pins-paarung-nach-position make mutate` | `ok … -> paarung nach name rot` (Fall-ID ist der volle Dateiname; `MUTATE_CASES=774` bricht mit „unbekannter Fall" ab — Auftragsformulierung, kein Befund) |
| `make mutate-greift` | `760 Fall/Faelle, 760 greifen, 0 Befund(e)` |
| M-A: Schleife bricht nach erstem Unterschied ab (`; break`) | rot: Fälle 2 und 8 |
| M-B: Vergleich nur für `LINUX_AMD64` | rot: Fälle 2, 3, 4, 5 |
| M-C: Exit-Zeile doppelt (`melde …; exit`) | rot: Fall 1 (`!= *"Exit "*`) und Fall 5 (Zählung genau einmal) |
| M-D: `==` → `~` | **grün (F-2)** |
| Fall-Nummer 774 | einzige Datei mit Präfix `774`; keine Datei ohne Nummern-Präfix in `test/mutations/` |

## Schwerpunkte, geprüft ohne Befund

1. **Skript, Exit-Klassen, Docker-only:** Paarung per `awk -v a=… '$2 == a'`, Treffer 0/>1 → Exit 2, alle sechs vor dem Urteil verglichen (M-A rot). Jede Doku-Zeile (Skriptkopf, Makefile-Kommentar, `sensors/traeger-pins-check.md`, `releasing.md`) nennt den Aufruf, an dem gemessen ist, und trennt Skript-Exit von make-Exit; die make-Ausgabe wurde real gelesen (siehe Tabelle). Das Bild wird aus der Zeile in `traeger-fetch.sh` gelesen (kein zweiter Pin, Bats-Fall „Bild … Pin von traeger-fetch"), `curl` läuft nur im digest-gepinnten Bild; Vergleich mit `bash/awk/tr/grep` auf dem Host ist keine Toolchain im Sinn von §3.9 (Paketmanager/Sprach-Toolchains) und liegt im Rahmen der übrigen `harness/tools/*.sh`. Gelesen, nicht gefahren: ein `set -e`-Abbruch mit Status 1 durch einen unvorhergesehenen Befehlsfehler würde als „Exit 1" statt als Klasse 2 gemeldet (`beende` lässt 1 durch); ein auslösender Pfad wurde nicht gefunden.
2. **bats (14 Fälle):** messen Eigenschaften (Paarung bei vertauschter Zeilenfolge, jede der sechs Plattformen einzeln rot, Meldung nennt nur die verfälschte Plattform, Exit-Zeile genau einmal letzte Zeile, leere Menge/Fehlend/Doppelt/Tag/Pin/Bild); der Test „jede der sechs Plattformen" ist mit M-B belegt rot. Fixture-Grenze (nachgebaute `SHA256SUMS`, docker-Stub, erfundene Pins, realer Pin ungehalten) steht im Kopf der Datei, im Skriptkopf, in der Sensor-Seite und in `releasing.md`.
3. **Fall 774:** `sed`-Anker trifft (`mutate-greift` grün, Fall rot gesehen mit `paarung nach name`); `\x24`-Schreibweise für `$` hält shell-lint (Commit 70f89b6b).
4. **`.d-check.yml`:** Deklaration, keine Lockerung: das Target steht mit Tabellenzeile und `kein Gate` im Werkzeuge-Teil von `harness/README.md`, derselben Klasse wie `traeger-fetch`/`tap-check`; die Kommentar-Liste (a) nennt es neben den übrigen Prosa-genannten Zielen. Der Gate-Lauf (`test/targets-modul-wiring.bats`) steht unten.
5. **`releasing.md`:** Die Schritt-8-Ergänzung (Exit 0 von `traeger-pins-check` vor der Meldung) ist der „Bindepunkt … vor dem Bericht" des Plans und V-1 („Bindepunkt: nach Schritt 5, vor dem Bericht"); zulässig, keine Überdehnung. Der Schritt-2-Satz („für die Plattform des Aufrufers") stimmt mit `traeger-fetch.sh` (Plattform des Hosts) überein.
6. **Realer Makefile-Digest ohne Wächter im Gate:** am Ort benannt (Skriptkopf „nicht den realen Pin", Sensor-Seite §Grenze/Wächter-Lage, `releasing.md`, bats-Kopf); der Lauf an v0.10.0 (grün, und mit verfälschter Nicht-Host-Plattform rot mit genauem Plattformnamen) ist hiermit am realen Release gesehen. §7 des Plans trägt die Läufe des Implementers; das ist Planner-Arbeit und hier nicht geprüft.
7. **Prozessfehler (Fall 774 im Arbeitsbaum):** `git diff --stat 3ea59b26 HEAD` führt genau die neun erwarteten Dateien; kein Rest. Die Plan-Änderung beschränkt sich auf das Entfernen der `d-check:ignore`-Marker (Pfade existieren jetzt); DoD-Häkchen unberührt.

Nicht geprüft: Mutations-CI-Probe auf einem Branch (liegt noch nicht vor, liefert der Auftraggeber).
