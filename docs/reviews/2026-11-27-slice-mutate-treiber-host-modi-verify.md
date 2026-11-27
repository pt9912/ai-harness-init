# Verifikation — slice-mutate-treiber-host-modi (Verify, HEAD 3f29742d)

**Verifier:** pt9912 (frischer Kontext) · **Datum:** 2026-11-27
**Geprüft:** die Kette `ffe3c1eb..3f29742d` gegen den Slice-Plan
`docs/plan/planning/in-progress/slice-mutate-treiber-host-modi.md` (§2 DoD, §5
Closure-Trigger, §6 Risiken) und die Sensor-Doku
`harness/sensors/mutate.md`. Review-Report
`docs/reviews/2026-11-27-slice-mutate-treiber-host-modi.md` (7dfb36e3, F-1 LOW) und
Behebung 3f29742d im Zug. Betriebsform: Docker aus, kein push, kein Netz.

## Urteile je DoD-Punkt (§2)

- **Liefer-Punkt 1 (host-native Vorlauf und Fall-Sensor-Läufe):** **mit Grenze erfüllt.**
  Code-Pfad: `harness/tools/mutate.sh` — die Umgebungs-Vorbedingung ruft das
  host-Rezept `make environment-check` (Zeile 1755), der Go-Vorlauf ruft
  `green_prerun test-go` über `make test-go` am Host, `run_case` läuft über
  `make <modus>` in der Isolationskopie; kein Docker-Zug im Pfad der erreichten
  Modi. Reale Form (§5): `make mutate MUTATE_CASES='10-ci-workflow-syntax'`
  docker-los **grün bis zum Bericht** — `mutate: 1 ok, 0 Befund(e)`,
  `TEILLAUF 1 von 800 — kein Beleg`, make-Exit 0. Der **volle Lauf
  (`MUTATE_FORCE=1`) bis zum Bericht läuft an diesem Bestand nicht durch** —
  er bricht am Grün-Vorlauf `make test-go` an den zwei Vorbestand-Klassen
  (unten). Die Grenze ist der Vorbestand-Trennungsträger: der Treiber bricht
  fail-closed **vor** der Fall-Führung und benennt die Ursache
  (`mutate: ABBRUCH — Worker 1: der Gruen-Vorlauf 'make shell-lint' ist in
  SEINER Kopie ohne Mutation rot`); am Claim `ffe3c1eb` ist die
  docs-check-Befundmenge byte-identisch (unten), die übrigen Klassen sind
  Code-stabil älter als der Claim (gemessen an beiden Läufern, nicht am Bericht).
- **Liefer-Punkt 2 (Umgebungs-Vorbedingung):** **erfüllt.** Negativ-Lauf:
  Inventar-Zeile `go|…|abgeleitet:1.27.4` → `99.99.0`, dann
  `make mutate MUTATE_CASES='10-ci-workflow-syntax'` → `mutate: ABBRUCH —
  Umgebungs-Befund: …; kein Fall laeuft.` mit der Diagnose-Zeile aus dem
  echten Check (`umgebung: go · Soll: 99.99.0 · Ist: 1.27.4`); make-Meldung
  `Fehler 4`; **keine** Isolationskopie, kein Lock-Rest, Beleg-Slot
  (`.harness/state/mutate-passed.key`) existierte nicht und existiert danach
  nicht. Vorordnung im Code: `exit 4` an den Zeilen 1760 und 1949, beide
  **vor** Beleg-Lesung (`report_key`), Entwertung und Isolationskopie.
- **Liefer-Punkt 3 (Wächter trägt Happy und Negative):** **erfüllt.** Die
  drei neuen Wächter in `test/mutate-driver.bats` („Umgebungs-Vorbedingung
  (host-Rezepte)"-Block) sind je einmal rot gesehen — Zug unten; die
  Anlagen 814/815/816 folgen der Anlagen-Form (MR-071/MR-090: Anker an den
  Real-Bytes, `# expect:` byte-gleich zum Testnamen).
- **`make gates` grün:** **nicht erfüllt — offen bleibenender Posten.**
  `make gates` → Exit 2, und zwar an der Stufe `docs-check-host`: 114 Befunde
  über 3084 Dateien (Klassen `id-unlinked`, `target-missing`,
  `span-unclosed`, `section-cell-oversized`); der Lauf endet dort (Fast-Pfad:
  TEILDRIFT fuhr genau die 9 gedrifteten Checks, erster roter war
  docs-check-host). Bestand, nicht Diff — siehe Messungen unten.
- **Review** (`docs/reviews/2026-11-27-slice-mutate-treiber-host-modi.md`):
  **erfüllt** (committed, 7dfb36e3; kein Self-Review).
- **Doku-Update** (`harness/sensors/mutate.md`, f68b15c4): **erfüllt mit
  Grenze** — Exit-Tabellen-Zeile 4, `§Umgebungs-Vorbedingung`,
  Daemon-Vorbedingung, Spur-Grenze; die Text-Zusagen hielt der Review gegen
  Code und Wächter. Rest des Doku-Nachzugs bei der Welle (nachgelagerter
  Doku-Slice, offener Posten).
- **Closure-Notiz, Register, Risiko-Ausgänge aus §6, drei Paarungen:**
  **offen** — §7 trägt den Vorlagen-Rumpf; das ist Planner-Closure nach
  diesem Bericht (AGENTS.md §3.10).

## Verifikations-Belege (je Lauf / je Rot-Zug)

**Reale Läufe (§5-Form):**

| # | Kommando | Ausgang |
|---|---|---|
| 1 | `make mutate MUTATE_CASES='10-ci-workflow-syntax'` | `1 ok, 0 Befund(e)`; `TEILLAUF 1 von 800`; Pruefgegenstand `a9222524…`; make-Exit **0** (`Fehler`-frei) |
| 2 | `make mutate MUTATE_CASES='10-ci-workflow-syntax 778-bats-lint-ohne-exclude-sc2016'` | `BEFUND worker-1 — der Gruen-Vorlauf 'make shell-lint' ist in SEINER Kopie ohne Mutation rot` (SC2016/SC2254 an `test/mutations/797–801`, Vorbestand); `0 ok, 4 Befund(e)`; make-Meldung `Fehler 1`, make-Exit 2 — **Grenze: der Fall 778 ist an diesem Bestand nicht grün erreichbar** |
| 3 | Inventar `abgeleitet:99.99.0` + `make mutate MUTATE_CASES='10-ci-workflow-syntax'` | `umgebung: go · Soll: 99.99.0 · Ist: 1.27.4`; ABBRUCH-Umgebungs-Befund; make-Meldung `Fehler 4`; Beleg-Slot/Isolationskopie/Lock unberührt; danach `git checkout -- harness/tools/environment-inventory.txt`, Baum clean |
| 4 | `make test-bats` / `make test-go` am Bestand | 651/652 bats ok, `not ok 273` (ignore-refs-Restbreite, deklariert 10 gegen 11 aufgelöste Links); test-go FAIL in `internal/gen` (`ARG GO_VERSION: generiert "1.27.3" != Repo-Dockerfile "1.27.4"`, gen_test.go:291) und `internal/emit` (`TestStopHook_CommitBindung/dogfood`, alle Unterfälle) |
| 5 | `make shell-lint` am Bestand | Error 1: SC2254/SC2016 an `test/mutations/797–801` |
| 6 | `make gates` | Exit 2 an `docs-check-host`, 114 Befunde |

**Rot-Züge der Fall-Anlagen an der realen Quelle (je einmal, danach
`git checkout --` und byte-gleich bestätigt):**

| Anlage | Mutation (Quelle) | Benannter Wächter | Ausgang |
|---|---|---|---|
| 784 (`sed '/# gedeckt$/s@…'` → `harness/tools/gates-fast.sh:60`) | Anwendung + `bats test/gates-fastpfad.bats --filter 'fehlender Key'` | `fastpfad: fehlender Key (leer) -> voller Lauf (fail-closed)` | **rot** (`[ "$status" -eq 1 ] failed`) |
| 785 (`s@[ ..force. = .1. ]@[ ..force. = ..0. ]@` → gates-fast.sh:71 und :118) | `bats test/gates-fastpfad.bats --filter 'GATES_FORCE=1 ueber gedecktem'` | `fastpfad: GATES_FORCE=1 ueber gedecktem Satz -> voller Lauf` | **rot** |
| 785 — Grenze (F-1) | dieselbe Mutation, `--filter 'GATES_FORCE=0 sagt nichts'` | `fastpfad: GATES_FORCE=0 sagt nichts` | **grün** — konsistent zur berichtigten rot-Grund-Zeile (3f29742d) und zum Review-Report; der Rand bleibt über den Bestands-Test gebunden |
| 814 (`environment-check` → `ci-lint`, mutate.sh:1755) | `bats test/mutate-driver.bats --filter 'die Umgebungs-Vorbedingung faehrt VOR'` | make-Protokoll-Assertion | **rot** (erster make-Zug `ci-lint` statt `environment-check`) |
| 815 (`s@exit 4@exit 1@`, Zeilen 1760 + 1949) | `bats test/mutate-driver.bats --filter 'ein Umgebungs-Befund bricht vor'` | Status-Assertion | **rot** (`[ "$status" -eq 4 ] failed`) |
| 816 (`smoke | full-smoke) daemons=` → Zeile 1934) | `bats test/mutate-driver.bats --filter 'fehlt der Daemon fuer einen Daemon-Modus'` | Status- + Meldungs-Assertion | **rot** (`[ "$status" -eq 4 ] failed`) |

Restore-Kontrolle: `git show HEAD:<datei> | sha256sum` vor/nach identisch
(mutate.sh `e313b3d9ceca…`, gates-fast.sh sha256 `f45fdc03…`), `git status`
clean. Anker-Positionen am Bestand bestätigt: `# gedeckt$` exactly gates-fast.sh:60;
`[ "$force" = "1" ]` genau :71 und :118; 814/815/816-Anker an mutate.sh:1755/1760+1949/1934.

## Gate-Spanne (beide Messungen bestätigt)

- `./.harness/state/bin/d-check .` am **HEAD** (3f29742d): 3084 Dateien,
  **114 Befunde**, Exit 1.
- d-check in einem Worktree des **Claims** `ffe3c1eb`: 3083 Dateien,
  **114 Befunde** — die Befundmengen sind **byte-identisch** (einziger
  diff-Zeile die Datei-Zahl 3083→3084); der neue Review-Report trägt 0 neue
  Befunde.
- Diff-Träger: die 9 im Claim↔HEAD geänderten Pfade tragen **0** der 114
  Findings (je Pfad `grep -c 0`; die 3 `docs/reviews/2026*`-Treffer gehören
  zwei älteren Reports und stehen auch so im Claim-Bestand).
- `make gates` endet wie behauptet exakt an `docs-check-host` (`Fehler 1`,
  make Exit 2).

## Exit-Vertrag je Treiber-Stufe (Sensor-Doku `harness/sensors/mutate.md`)

- **0** — Lauf 1 (Teillauf grün), make-Exit 0.
- **1** — Lauf 2 (Befund-Summe 4), make-Meldung `Error 1`; make-Prozess Exit 2.
- **4** — Lauf 3 (Umgebungs-Befund), make-Meldung `Error 4`; Diagnose nennt
  Werkzeug · Soll · Ist; kein Fall, keine Isolationskopie, Beleg-Slot unberührt.
- **2** — make-Prozess-Exit beobachtet an den Läufen 2 und 3 (Klasse wie in
  der Doku benannt: die Klasse des Rezept-Aufrufs lese an der Meldung
  `Error <n>`, der make-Prozess endet mit 2).
- **130** — nicht gemessen (kein Signal-Zug in dieser Betriebsform; Grenze
  benannt, kein DoD-Punkt).

## mutate-auswahl (lesend, am HEAD 3f29742d)

Die Auswahl-Form wählt jeden Fall, dessen `# files:` eine im
`ffe3c1eb..HEAD` geänderte Datei trifft, **plus jeden geänderten/neuen Fall
selbst**. Gemessen (grep über `# files:`): 40 Fälle treffen
`harness/tools/mutate.sh`, 4 treffen `harness/tools/gates-fast.sh`, dazu
kommen die 5 geänderten/neuen Fall-Dateien (784, 785, 814, 815, 816) und
`test/mutate-driver.bats`-Treffer — **weit über SCHWELLE 8**: der Lauf am
`3f29742d`-Tip ist damit der CI-Weg (Exit 10, Push auf
`mutate/slice-mutate-treiber-host-modi-<sha8 von 3f29742d>`). Der Push ist
CI-Posten des Implementers (kein Netz/push in dieser Betriebsform) und der
`mutate-ergebnis.txt`-Lesung des Verifiers, wenn er vorliegt; Branch-Lesung
und -Räumung bleiben offen, bis der Lauf existiert.

## Plan-vs-Code (beide Richtungen)

- **Plan §3 umgesetzt:** `harness/tools/mutate.sh` (Vorbedingung + host-Rezepte),
  `test/mutate-driver.bats` (Happy + Negative + Daemon-Grenze),
  `test/mutations/814/815/816` neu.
- **Gebaut, ohne eigene Zeile in Plan §1/§3:** die **Daemon-Vorbedingung** für
  `smoke`/`full-smoke` (mutate.sh:1934–1952) und die **Spur-Grenze** der
  Seriell-Klassifikation. Beide sind an den Treiber-Vertrag gekoppelt
  (Umgebungs-Befund-Klasse) und im Sensor-Text benannt; der Plan §1 deckt sie
  über „komplett ohne Docker-Daemon" nicht wörtlich — der Widerruf
  („die Liste entfällt mit slice-smoke-und-full-smoke-ohne-docker") steht am
  Ort. Keine still übernommene Plan-Aussage gefunden, die der Code
  nicht hält; die Aussage „voller Lauf bis zum Bericht" (Plan §1/LP1) hält der
  Code nicht am heutigen Vorbestand — oben mit Grenze benannt.

## Vorbestand-Klassen (5, gemessen, keiner vom Diff vertieft)

1. **docs-check-host:** 114 Befunde — byte-identisch am Claim; 0 im Diff.
2. **bats:** Test 273 (`test/ignore-refs-restbreite.bats`, deklariert 10 vs
   11 aufgelöste Links) — einzige rote von 652.
3. **test-go:** zwei Klassen — `internal/gen` GO_VERSION-Drift (1.27.3
   generiert ≠ 1.27.4 im Dockerfile) und `internal/emit`
   `TestStopHook_CommitBindung/dogfood`.
4. **shell-lint:** SC2254 + SC2016 an `test/mutations/797–801` (identisch im
   Isolat, darum fällt der Vorlauf des Modus).
5. **smoke/full-smoke:** Daemon-Vorbedingung (Exit 4) — Folge-Slice
   `slice-smoke-und-full-smoke-ohne-docker`; 63 + 1 Fälle dadurch an diesem
   Bestand ungrün-fähig, aber mit benannter Ursache, nicht an einem Fall-Ausgang.

## Offene Posten für die Closure (Planner)

1. **CI-Branch-Lauf** am `3f29742d`-Tip (`mutate-auswahl` → CI-Weg,
   siehe oben) — Implementer/Dienst; danach liest der Verifier einmal
   `mutate-ergebnis.txt` vom Branch und räumt die Refs des Slice.
2. **`make gates grün`** — über den nachgelagerten Doku-Nachzug
   (`slice-doku-nachzug-ohne-docker`) oder einen dokumentierten Carveout;
   DoD-Punkt bleibt offen bis dahin.
3. **Die Vorbestand-Klassen** (bats 273, test-go-Drift + StopHook-Gruppe,
   shell-lint 797–801) — nicht dieses Slices Arbeit, aber sie blockieren
   267 der 316 Fälle am Fall-Vorlauf; ein Treiber-Schnitt für die
   Spur-/Modus-Klassifikation über die host-Rezept-Pläne (Sensor-Doku
   „Spur-Grenze") ist benannt und nicht geplant.
4. **`smoke`/`full-smoke`-Entkoppelung** — Risiko §6, Ausgang liegt beim
   Folge-Slice; der Exit-4-Zug ist gebaut und benannt.
5. **Risiko-Ausgänge §6** (2 Risiken) + §7 Closure-Notiz + Register
   fortgeschrieben + drei Paarungen — Planner-Closure.

**Fazit:** LP2 und LP3 sind belegt (realer Negativ-Lauf + je ein Rot-Zug an
der realen Quelle); LP1 ist in der erreichbaren Form belegt und an die
Vorbestand-Grenze gebunden (exakt benannt); `make gates grün` ist der
einzige nicht erreichte DoD-Punkt, offen an der d-check-Bestandsmenge, die
am Claim byte-identisch ist.
