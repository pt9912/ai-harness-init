# Verify: welle-15 (Re-Baseline v6.0.0) — Closure-Trigger §3

**Rolle:** Verifier (Modul 8, Schritt 1 der Wellen-Closure-Prozedur — Modul 6
§Wellen-Closure-Prozedur). Prüfgrundlage: `docs/plan/planning/welle-15-re-baseline.md` §3
(Closure-Trigger, vier repo-weite Bedingungen; die fünfte — Closure-Notiz — ist nicht Gegenstand
dieser Prüfung, die schreibt der Planner danach).

**Nicht geprüft:** DoD-/ADR-Konformität der einzelnen acht Slices — das ist bereits Gegenstand von
Review und Slice-Closure gewesen. Geprüft wird ausschließlich das *Mehr*, das über die einzelnen
Slice-DoDs hinausgeht.

Alle vier Kommandos unabhängig gefahren, frischer Kontext, kein Ergebnis übernommen.

## Bedingung 1 — Alle acht Mitglieder liegen in `done/`

Quelle: §4-Tabelle der Welle-Datei, gezählt via
`sed -n '/^| Slice | Titel | Bezug |/,/^$/p' docs/plan/planning/welle-15-re-baseline.md | grep -c '^| \[slice-'`
→ **8** Zeilen (176, 177, 178, 179, 182, 184, 185, 186).

Für jede der acht Nummern `find docs/plan/planning/done -iname "slice-<NNN>-*.md"` gefahren:

| Slice | Treffer in `done/` |
|---|---|
| 176 | `docs/plan/planning/done/slice-176-inventur-vor-dem-schnitt-v600.md` |
| 177 | `docs/plan/planning/done/slice-177-beobachtungs-register-verzeichnis-form.md` |
| 178 | `docs/plan/planning/done/slice-178-regierende-fassung-des-sprungs-v600.md` |
| 179 | `docs/plan/planning/done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md` |
| 182 | `docs/plan/planning/done/slice-182-baum-tausch-v600-pins-ziehen.md` |
| 184 | `docs/plan/planning/done/slice-184-register-form-im-bestand-nachziehen.md` |
| 185 | `docs/plan/planning/done/slice-185-adaptions-durchgang-gegen-v600.md` |
| 186 | `docs/plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md` |

**Verdikt: erfüllt.** Alle acht, genau ein Treffer je Nummer, keine Datei fehlt und keine liegt
noch in `open/`, `next/` oder `in-progress/`.

## Bedingung 2 — `make gates` grün

Gefahren als `make gates > gates2.log 2>&1; echo $?` (eigener Kontext, kein `tee`-Exit-Code
verwechselt). Ergebnis: `REAL_EXIT=0`.

Kernzahlen aus dem Log:

- `baseline-verify: v6.0.0 OK — 53 Dateien (Integritaet + Vollstaendigkeit, netzlos)`
- `d-check: 818 Datei(en) geprüft, 0 Befund(e)`
- `golangci-lint run ./...` → `0 issues.`
- bats: `1..218`, alle 218 Zeilen `ok` (`grep -c '^ok '` → 218, `grep -ci 'not ok\|--- FAIL'` → 0)
- Go-Tests (`go test -count=1 ./...`): alle acht Pakete `ok` (cmd/ai-harness-init, internal/archive,
  internal/emit, internal/fetch, internal/gen, internal/report, internal/span, internal/wire)
- `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)`
- `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`

**Verdikt: erfüllt.**

## Bedingung 3 — `make full-smoke` grün

Gefahren als `make full-smoke > full-smoke.log 2>&1; echo $?` → `FULL_SMOKE_EXIT=0`.

`grep -c 'full-smoke: OK'` → **16** Szenario-Zeilen, alle mit `OK` abgeschlossen (u. a. Bootstrap
frisch, sprachloser Init, Gate-Nachweis-Kreis, Command-Guard, Guard-Boden, Mono-Repo-Koexistenz
(Go×2, C++), drei Arch-Layouts inkl. beider hexagonal-Zähne, Idempotenz, Rollen-Typen, Feldliste).

Ein Rohtreffer auf `FAIL|not OK` (9 Zeilen) wurde einzeln gelesen (Rot-heißt-Meldung-lesen-Disziplin,
s. Memory): sie stammen aus `ctest --output-on-failure` (Flag-Name, keine Fehlermeldung), aus dem
absichtlichen negativen Fixture „absichtlicher Schicht-Fehler“ (C++-Statische-Assertion, Teil des
Szenarios `add-lang cpp`) und aus den beiden dokumentierten `fail-fast Exit 2`-Erwartungen
(cpp+hexslice, cpp+hexagonal — Sprache×Arch-Support-Matrix). Keiner davon ist ein rotes
Gate-Ergebnis; der Gesamt-Exit-Code ist 0 und jede der 16 Szenario-Zeilen endet mit `OK`.

**Verdikt: erfüllt.**

## Bedingung 4 — Pin vollzogen (`make baseline-verify` + `harness/conventions.md` §Baseline)

`make baseline-verify` einzeln gefahren:

```
baseline-verify: v6.0.0 OK — 53 Dateien (Integritaet + Vollstaendigkeit, netzlos)
```
Exit 0, enthält `v6.0.0 OK` wie gefordert.

`harness/conventions.md` §Baseline gelesen (Zeilen 8–40):

- **Stand:** `` `v6.0.0` `` (Zeile 11)
- **Datum der Adoption** — letzter Eintrag der Kette (Zeile 27): **„auf `v6.0.0`: 2026-09-04,
  Delta-Nachweis in slice-176“**

Beide Zeilen nennen denselben Tag `v6.0.0`. Die `Stand:`-Zeile trägt keinen Datumswert (das ist
laut Zeilenform in ADR-0031 Festlegung 2 auch nicht ihre Aufgabe — sie nennt den Ziel-Tag); das
Datum steht in der Adoptions-Kette, deren letzter Eintrag exakt `v6.0.0` referenziert, mit
Datum 2026-09-04 und dem Delta-Nachweis-Slice `slice-176`.

**Verdikt: erfüllt.**

## Gesamtergebnis

Alle vier vom Verifier zu prüfenden Closure-Trigger-Bedingungen aus §3 der Welle-Datei sind
**erfüllt**, unabhängig mit frischen Kommando-Läufen belegt (Log-Auszüge oben). Die fünfte
Bedingung (Closure-Notiz) ist wie im Auftrag angegeben nicht Gegenstand dieser Prüfung.

**Nicht geprüft (außerhalb des Auftrags):** ob der Repo-Zustand seit dem letzten Push
(`main...origin/main [voraus 15]`, `git status -sb` zum Zeitpunkt dieses Laufs) irgendetwas an den
obigen Befunden ändert — die Läufe fanden auf dem lokalen Arbeitsbaum statt, der zum Zeitpunkt der
Prüfung sauber war (`git status` clean, keine uncommitteten Änderungen).

Übergabe: Verifier → Planner, gemäß Modul 8 §Rollen-Sequenz für eine Welle, Schritt 1
(„repo-weiter Verifikations-Beleg").
