# Slice slice-targets-modul-im-emittierten-doc-gate: Das emittierte Doc-Gate führt das Modul targets

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-054`](../../../../harness/conventions.md#mr-054), [`MR-055`](../../../../harness/conventions.md#mr-055), [`MR-063`](../../../../harness/conventions.md#mr-063).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung


**Ziel:** Das emittierte `.d-check.yml` führt `targets` (Target ↔ Tabellenzeile in `harness/README.md`, beide Richtungen, Autorität `harness/README.md`), mit grünem Start am frischen `--lang go`-Ziel und je einem roten Gegenbeispiel pro Richtung in `make full-smoke`.

**Messung vor dem Schnitt** (Pin v0.79.0, `host-bin`-Binär, emittiertes Scratch-Ziel `--lang go`, `docker run --network none -v …:ro`): `makefiles` nimmt keinen Glob (`harness/mk/*.mk` ⇒ Config-Fehler, fail-closed), die elf `harness/mk/*.mk` stehen als Liste. Mit `Makefile`, `d-check.mk` und den elf sind 29 Targets sichtbar; die Vorlage-README deklariert zwei (`docs-check`, `gates`; die `<make-target>`-Platzhalter-Zeilen zählen nicht). Start rot mit 27 Befunden `gate-undocumented` (`docker run … | awk -F'\t' '{print $2}' | sort -u | wc -l` → 27); mit 27 `exempt-targets` grün (20 Dateien, 0 Befunde). Rot gesehen: ein Makefile-Target ohne Zeile ⇒ `gate-undocumented`, eine Zeile ohne Target ⇒ `gate-phantom`, ohne den Eintrag `test` fällt genau `harness/mk/go.mk:10 test`. **Preis:** 27 Einträge, davon vier echte Gates (`baseline-verify`, `lint`, `test`, `build`), die als README-Zeilen statt als Ausnahme stehen sollten (⇒ 23 `exempt-targets`); `--lang cpp` und `--arch`-Varianten sind nicht gemessen ([`MR-055`](../../../../harness/conventions.md#mr-055)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Die Varianten `--lang cpp` und `--arch hexslice`/`hexagonal` — nicht gemessen; der Slice misst jede Variante, die er abdeckt, oder benennt die Grenze statt sie zu behaupten ([`MR-055`](../../../../harness/conventions.md#mr-055)).
- Der Ordner `harness/sensors/` im Ziel — Folge-Slice `slice-sensors-ordner-entsteht-im-ziel`; `targets` prüft Makefile gegen README-Tabelle und braucht ihn nicht.
- Nachzug in bestehende Ziele — `.d-check.yml` wird nur an freiem Pfad geschrieben; der Nachzug ist Handarbeit nach der Positionsliste im Kopfkommentar, ein anderer Vorgang.
- Die `.d-check.yml` dieses Repos — führt `targets` bereits; Ebene ist das Emittierte (Dogfood-vs-emittiert).

## 2. Definition of Done


- [ ] Der Emitter schreibt `targets` in `modules` und den Block (`makefiles` als explizite Liste der tatsächlich emittierten mk-Dateien, `doc-tables`, `authority`, `exempt-targets`); die vier Gates stehen als README-Zeilen der Vorlage, die übrigen im Exempt-Block; der Kopfkommentar „Herkunft der Positionen“ nennt die Position (die Baseline-Vorlage führt `targets` nur auskommentiert); ein Test hält die Liste gleich der emittierten mk-Menge, und eine entfernte `exempt-targets`-Zeile färbt den Gate-Lauf im Ziel rot (Gegenbeispiel gesehen, AGENTS.md §3.6).
- [ ] `make full-smoke` misst im Ziel grünen Start und beide Gegenbeispiele mit ihrem Grund-Code (`gate-undocumented`, `gate-phantom`); die Stufe steht mit ihrer Grenze (nur gemessene Varianten) in der E2E-Abdeckungs-Sicht ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] Die Grenzen stehen am Ort der Emission (Kopfkommentar der Vorlage `d-check.yml`): `makefiles` ist eine Liste ohne Glob, eine später per `add-lang` oder vom Adopter angelegte mk-Datei bleibt ungelistet und damit blind; Kosten 23 Ausnahmen mit dem Kommando der Messung.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)


| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/d-check.yml` | update | `targets` + Block + Kopfkommentar; Aktivierung nach [`MR-054`](../../../../harness/conventions.md#mr-054) (Erprobung, grüner Start, rotes Gegenbeispiel) |
| `internal/emit` (README-Vorlage, mk-Liste, Test) | update | vier Gate-Zeilen; Liste = emittierte mk-Dateien — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| `harness/tools/full-smoke.sh` | update | Stufe grün plus zwei rote Gegenbeispiele; `docs/user/e2e-abdeckung.md` per `make e2e-abdeckung` neu erzeugt |

## 4. Trigger


**Start** (`next` → `in-progress`): Auftrag des Auftraggebers; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Messung einer zweiten Variante (cpp, `--arch`) wird nötig — dann je Variante ein Slice.
- `in-progress` → `open` (blockiert — Carveout?): das Exempt-Volumen im Ziel wird als Gate-Senkung gelesen — dann Architect-Frage nach AGENTS.md §3.5, nicht Slice-Arbeit.

## 5. Closure-Trigger


DoD vollständig, `make gates` und `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte


- Die Liste der mk-Dateien driftet gegen die emittierte Menge — **Ausgang:** entfallen: der Test aus der ersten DoD-Zeile hält sie gleich.
- Ein Adopter legt eigene mk-Dateien an, die `makefiles` nicht nennt (blind, Grenze in der dritten DoD-Zeile) — **Ausgang:** weiter offen: → BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht
- Der Lauf kostet im Ziel Zeit, ungemessen — **Ausgang:** weiter offen: → BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen

## 7. Closure-Notiz


Wird bei der Closure vom Planner geschrieben (AGENTS.md §3.10), nicht im Plan.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (`ALL`), Schwelle erfüllt; alle berührten Sub-Areas GF.

**Vorgelagert — offene Beobachtungen sichten:** gelesen am gemergten Stand 2026-10-06, Zähler je `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`: `waechter-abdeckung-haengt-an-uninstruierter-konvention` → 2 (die Vorlage-Konvention „neues Target ⇒ README-Zeile“ führt nicht jeder Anweisungssatz; der Slice macht sie zu einem Wächter im Ziel), `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` → 5 (bereits über der Schwelle; die Grenzen stehen am Ort der Emission), `kosten-einer-emittierten-pruefung-im-ziel-ungemessen` → 1, `emittierter-stand-laeuft-dem-dogfood-voraus` → 2.

