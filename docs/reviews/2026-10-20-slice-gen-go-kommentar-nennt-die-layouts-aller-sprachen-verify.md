# Verify slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen

Rolle Verifier, frischer Kontext. Stand HEAD e19b447d (Basis d71e8cdd, Code 7cc9f961). Gegen: Slice-Plan §2 (DoD), LH-QA-02,
ADR-0088/0094/0095/0096, AGENTS.md §3.6/§3.7. Docker 29.9.1 (colima), Host darwin; MR-089: die Release-Bauten liefen im
gepinnten Dockerfile-`build`-Stage mit `--no-cache-filter build` (kalte Stage, warmer Rest), die Mutations-Fälle mit
`SMOKE_ARTIFACT_TARGET=artifact-host`.

## Verdikte je DoD-Punkt

- **L1 — bestätigt.** Gelesen: `git diff d71e8cdd..HEAD -- internal` (nur `internal/gen/gen.go`, 11+/15-, Makefile-Diff leer) und
  `sed -n '/^func langArchs/,/^}/p'`. Tabelle: go {flat, hexslice, hexagonal}; cpp, kotlin, java, python, csharp {flat, hexslice}.
  Kommentar `STAND`: „go traegt flat + hexslice + hexagonal; cpp, kotlin, java, python und csharp tragen flat + hexslice" — gleich.
  Der Satz „Heute tragen go … und cpp …" ist entfallen; der Block steht im Indikativ; im geänderten Block keine Slice-Nummer als
  Erzählung (`slice-045a`, `slice-053`, `slice-058`, „INFO-1" sind entfernt; Zeile 75 „Mutation 63" liegt außerhalb des Blocks, Bestand,
  nach §1 bewusst stehen gelassen). Herkunft nur als ADR-Felder (ADR-0088, ADR-0094 F4, ADR-0095 F5, ADR-0096 F5; die Festlegungs-Nummern
  stehen als `**4.**`/`**5.**` in den ADRs, ADR-0094 §Festlegung 4 gelesen). Zusagen gegen Code/Test/Sensor gelesen:
  `TestGenerateArch_LangSpecificArchRejected` (`internal/gen/hexagonal_test.go:257`) prüft cpp+hexagonal und `Available == flat,hexslice`
  — deckt die Zusage; `full-smoke` fährt `add-lang java --arch hexagonal` mit Exit-2-Prüfung (`harness/tools/full-smoke.sh` ~2930–2938) —
  deckt die Zusage wörtlich (nur java genannt; python/csharp fährt es ebenfalls, die Zusage ist enger als der Sensor, nicht breiter);
  „SupportedArchs() leitet den Union hieraus ab": `internal/gen/arch.go:163` gelesen, nicht gefahren (Stichprobe; der Review hat
  vollständig gelesen). Die Grenze „kein Sensor haelt diesen Kommentar gegen die Tabelle darunter" steht im Kommentar selbst.
- **L2 — bestätigt (Messung gefahren, Ergebnis: verschieden).**
  Gefahren: Worktrees `d71e8cdd` und `HEAD`, je `make release-artifacts DEST=<ordner> TRAEGER_VERSION=v0.10.0` (sechs Plattformen),
  danach `diff SHA256SUMS`; plus ein zweiter Bau am Stand HEAD (Determinismus-Kontrolle).
  - Stand d71e8cdd, Zeile `linux-amd64`: `ae168a04…f2db`; Stand HEAD: `24434a38…4539`. **Alle sechs Zeilen verschieden**
    (darwin-amd64 d4179853… → 01d0e034…, darwin-arm64 4d55f5a9… → d90ccc2f…, linux-arm64 75a28ac8… → 26a7b60e…,
    windows-amd64 637d6f54… → 3b21ad14…, windows-arm64 e795d0da… → 75b7415d…).
  - Kontrollbau HEAD gegen HEAD: `diff` leer — der Bau ist deterministisch; die Differenz stammt aus der Kommentar-Änderung, nicht aus
    Rauschen.
  - Zeilenzahl des Kommentars: `git diff --numstat` 11 hinzu, 15 weg, netto −4 Zeilen. Damit ist die im Plan offene Frage beantwortet:
    eine Kommentar-Änderung mit anderer Zeilenzahl ändert die Bytes (Zeilen-Tabelle/Zeilennummern im Binary), `-trimpath`/`-buildvcs=false`
    ändern daran nichts. Gemessen wurde die Kombination (Änderung mit −4 Zeilen); eine zeilenzahlgleiche Änderung wurde **nicht**
    gemessen — ob dann gleiche Digests entstehen, ist offen (der Plan-Ansatz „gleiche Zeilenzahl, wo es trägt" ist unbelegt).
  - Pin im Makefile unverändert: `git diff d71e8cdd..HEAD --stat -- Makefile` leer; `TRAEGER_TAG ?= v0.10.0` unverändert.
  - Zusatzbefund aus derselben Messung (gelesen, nicht weiter verfolgt): die Digests am **Vor**-Stand d71e8cdd sind auch nicht die des
    Pins (`TRAEGER_SHA256_LINUX_AMD64 = fd7738a0…` gegen `ae168a04…` bei d71e8cdd). Der Pin ist mit diesem Bau-Aufruf (Stand d71e8cdd,
    `TRAEGER_VERSION=v0.10.0`) nicht reproduzierbar, unabhängig vom Kommentar. Ob das am Quellstand (Tag-Commit ≠ d71e8cdd), an der
    Fassungs-Injektion oder am Release-Workflow liegt, ist nicht gemessen; ein Bau am Tag-Commit fehlt. Das ist das Gegenstück zum
    LOW des Reviews: §6 „nicht mehr reproduzierbar" trifft den Bezugsstand nicht. LH-QA-02 verlangt Reproduzierbarkeit der Digests
    eines Release-Stands; belegt ist hier nur Determinismus (gleicher Stand, gleiche Bytes), nicht Gleichheit mit dem veröffentlichten
    Asset. Für Planner/Architect: Folge-Beobachtung, kein Befund dieses Slice (Gegenstand liegt außerhalb §1).
- **§6-Risiko-Ausgang (Planner-Sache, Beleg geliefert):** die Digests sind verschieden → der Plan-Text sagt *eingetreten* mit
  Folge-Slice; die Nutzerentscheidung (§4.1: Kommentar behalten, kein Zurückführen, Pin bleibt) liegt vor, ein Folge-Slice
  bzw. die Einordnung als Beobachtung ist offen und gehört dem Planner. Verdikt hier nur: Messung vollständig, Ergebnis eindeutig.
- **`make gates` grün — siehe unten (Lauf nach diesem Commit).**
- Review-Report liegt vor (`docs/reviews/2026-10-20-slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen.md`), anderer Kontext: bestätigt.
- Closure-Notiz, Register, Risiko-Ausgang, Paarungen: Planner-Arbeit (AGENTS.md §3.10), hier nicht geprüft, keine Haken gesetzt.

## Rot-Beleg

- **Eigenschaft „Kommentar == Tabelle": kein Sensor, kein Rot-Beleg möglich.** Eine Sprache aus der Tabelle zu nehmen färbt keinen
  Test wegen des Kommentars; der Kommentar sagt das selbst („Grenze: kein Sensor …"), der Plan (§2 L1) ebenso. Die Bestätigung von L1
  ist eine Lesung (siehe oben), keine Messung.
- **Nachgetragen: die 13 Mutations-Fälle mit Anker `internal/gen/gen.go`** (`grep -l 'internal/gen/gen.go' test/mutations/*.sh`: 17, 444, 445,
  47, 54, 63, 678, 690, 705, 709, 729, 744, 748). Ihre `sed`-Anker liegen auf Code, nicht auf dem geänderten Kommentar; zu prüfen, ob die
  Kommentar-Änderung einen Anker verschoben hat. Gefahren (jeweils `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES='<Fall>'
  MUTATE_JOBS=1 make mutate` am Stand HEAD, Prüfgegenstand `afc02d4b…`):
  - `744-python-hexslice-nicht-in-langarchs` (verify: test-go) → `ok … TestGenerate_PythonHexsliceProfile_FileSet rot`, 1 ok, 0 Befunde.
  - `63-langarch-support` (test-go) → `ok … TestRun_AddLangUnknownArchRejected rot`, 1 ok, 0 Befunde.
  - `444-traeger-lehnt-getragene-kombination-mit-nicht-getragen-meldung-ab` (verify: full-smoke) → `ok … der Traeger lehnt die Kombination mit
    Exit 2 und 'unbekannte Architektur' ab rot`, 1 ok, 0 Befunde; Lauf 304 s Fall, 424 s Grün-Vorlauf.
  - Nicht gefahren: die übrigen zehn Fälle (17, 445, 47, 54, 678, 690, 705, 709, 729, 748) — die `mutate-greift`-Hälfte (Patch ändert die
    Datei) läuft in `make gates`; ob die zehn rot werden, deckt der CI-Branch.
  - Grenze: `mutate` fährt gegen die Kopie des Arbeitsbaums; die drei Fälle belegen, dass die Anker nach der Kommentar-Änderung noch greifen
    und ihre Wächter rot werden, nicht dass der Kommentar stimmt.
- **Mutations-CI-Branch:** `git fetch origin mutate/slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen-7cc9f961` gelingt, aber
  `git show FETCH_HEAD:mutate-ergebnis.txt` → *fatal: path 'mutate-ergebnis.txt' does not exist*. Die Datei fehlt zum Lesezeitpunkt
  (Lauf vermutlich noch nicht beendet; nach Vorgabe nicht gewartet). **Befund (offen):** kein CI-Ergebnis übernommen; der Branch wurde
  absichtlich **nicht** gelöscht, weil ein Löschen einen laufenden Lauf abbräche. Der Auftraggeber liefert das Ergebnis.

## Plan-vs-Code

- Plan → Code: L1 gebaut wie geplant; §3 nennt `dist/` (lokal, nicht committet) für L2 — tatsächlich lief L2 über `DEST` unter
  `.harness/state` (gitignoriert, danach entfernt); kein Abweichungs-Gewicht.
- Code → Plan: nichts Gebautes ohne Plan (Diff = `gen.go` + Slice + Review). Der Block schreibt zusätzlich „Grenze: kein Sensor …"
  und streicht „Geruestung-only … (slice-045a-Review INFO-1)" — vom Plan als Erzählungs-Entfernung gedeckt (§1 Ziel).
- Plan-Aussage, die der Code-Stand nicht trägt: §6 „macht die sechs Pins … zu einem Stand, der nicht mehr … reproduzierbar ist" — die Pins
  waren am Bezugsstand schon nicht reproduzierbar (siehe L2-Zusatzbefund). Entspricht dem LOW des Reviews.

## Offene Punkte

- Planner: §6-Ausgang festlegen (verschiedene Digests sind gemessen; Nutzerentscheidung: Kommentar bleibt, Pin bleibt) und die
  Formulierung „nicht mehr reproduzierbar" korrigieren.
- Planner/Architect: Beobachtung „Pin-Digests des veröffentlichten Releases sind aus dem Baum am Bezugsstand mit
  `make release-artifacts TRAEGER_VERSION=<tag>` nicht reproduzierbar (ae168a04… gegen Pin fd7738a0…, linux-amd64)" — Ursache
  ungemessen; ein Bau am Tag-Commit würde sie eingrenzen.
- Mutations-CI-Ergebnis steht aus (Datei fehlt am Branch).
- Zeilenzahlgleiche Kommentar-Änderung nicht gemessen (nur −4 Zeilen).
