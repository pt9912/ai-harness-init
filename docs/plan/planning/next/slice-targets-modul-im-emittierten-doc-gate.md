# Slice slice-targets-modul-im-emittierten-doc-gate: Das emittierte Doc-Gate führt das Modul targets

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-054`](../../../../harness/conventions.md#mr-054), [`MR-055`](../../../../harness/conventions.md#mr-055), [`MR-063`](../../../../harness/conventions.md#mr-063).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung


**Ziel:** Das emittierte `.d-check.yml` führt `targets` (Target ↔ Tabellenzeile in `harness/README.md`, beide Richtungen, Autorität `harness/README.md`) in der Stufe 1 `makefiles: [Makefile]` mit den zwei `exempt-targets` `help` und `record-gates`, mit grünem Start am frischen `--lang go`-Ziel und je einem roten Gegenbeispiel pro Richtung in `make full-smoke`; die Stufe 2 steht als Kopfkommentar der Vorlage.

**Lage** (Messung des Auftraggebers am emittierten Ziel v0.2.7): das Wurzel-`Makefile` definiert nur `help`, `gates`, `record-gates`; alle übrigen Targets kommen aus `harness/mk/*.mk` (11 Dateien) und `d-check.mk` (26). `gates` hat eine README-Zeile, also bleiben zwei Ausnahmen. **Stufe 2** — `makefiles: [Makefile, "harness/mk/*.mk", d-check.mk]` plus die dann nötigen `exempt-targets` — ist erst ab dem gepinnten d-check `v0.81.0` gültig, der Globs in `makefiles` annimmt; ihre Ausnahme-Zahl wird am frisch emittierten Ziel neu gemessen (`… | awk -F'\t' '{print $2}' | sort -u | wc -l` über den `gate-undocumented`-Befunden), nicht aus der Messung unter `v0.79.0` übernommen (dort 27, davon vier echte Gates).

**Die Sorge „23 Ausnahmen = Gate-Senkung“ ist entschärft:** Stufe 1 trägt zwei Ausnahmen, und beide sind Werkzeug-Ziele ohne Gate-Anspruch; ein Ausnahme-Block in der Größe der Target-Menge entsteht erst in Stufe 2, und die ist Angebot im Kommentar, nicht Default.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Stufe 2 als Default — Bestand bleibt: ihr Ausnahme-Block wäre wieder so groß wie die Target-Menge; sie steht als Kommentar mit ihrer Bedingung (Pin `v0.81.0`).
- Die Varianten `--lang cpp` und `--arch hexslice`/`hexagonal` — nicht gemessen; der Slice misst jede Variante, die er abdeckt, oder benennt die Grenze statt sie zu behaupten ([`MR-055`](../../../../harness/conventions.md#mr-055)).
- Der Ordner `harness/sensors/` im Ziel — Folge-Slice `slice-sensors-ordner-entsteht-im-ziel`; `targets` prüft Makefile gegen README-Tabelle und braucht ihn nicht.
- Nachzug in bestehende Ziele — `.d-check.yml` wird nur an freiem Pfad geschrieben; der Nachzug ist Handarbeit nach der Positionsliste im Kopfkommentar, ein anderer Vorgang.
- Die `.d-check.yml` dieses Repos — führt `targets` bereits; Ebene ist das Emittierte (Dogfood-vs-emittiert).

## 2. Definition of Done


- [ ] Der Emitter schreibt `targets` in `modules` und den Block der Stufe 1 (`makefiles: [Makefile]`, `doc-tables`, `authority`, `exempt-targets: [help, record-gates]`); der Kopfkommentar „Herkunft der Positionen“ nennt die Position (die Baseline-Vorlage führt `targets` nur auskommentiert); eine entfernte `exempt-targets`-Zeile färbt den Gate-Lauf im Ziel rot (Gegenbeispiel gesehen, AGENTS.md §3.6).
- [ ] `make full-smoke` misst im Ziel grünen Start der Stufe 1 und ihre Gegenbeispiele mit Grund-Code: ein Target im `Makefile` ohne Zeile ⇒ `gate-undocumented`, eine Zeile ohne Target ⇒ `gate-phantom`; für Stufe 2 einmal von Hand rot gesehen und im Bericht belegt: dieselben zwei Befunde über ein Target in `harness/mk/*.mk` und ein Glob ohne Treffer ⇒ Exit 2. Die Stufe steht mit ihrer Grenze (nur gemessene Varianten) in der E2E-Abdeckungs-Sicht ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] Die Grenzen stehen am Ort der Emission (Kopfkommentar der Vorlage `d-check.yml`): Stufe 1 sieht kein Target aus `harness/mk/*.mk` und `d-check.mk` und damit kein per `add-lang` hinzugekommenes Fragment; Stufe 2 mit ihrer Bedingung (gepinnter d-check ab `v0.81.0`), ihrer gemessenen Ausnahme-Zahl samt Kommando und ihren zwei Abbrüchen (Glob ohne Treffer, vom Muster getroffener Symlink — je Exit 2, Symlink wörtlich eintragen).
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
| `harness/tools/full-smoke.sh` | update | Stufe grün plus zwei rote Gegenbeispiele; `docs/user/e2e-abdeckung.md` per `make e2e-abdeckung` neu erzeugt |

## 4. Trigger


**Start** (`next` → `in-progress`): Auftrag des Auftraggebers **und** `slice-d-check-pin-macht-den-range-leerfall-laut` liegt in `done/` — erst dann pinnt das emittierte Ziel `v0.81.0`, und der Kommentar zu Stufe 2 beschreibt etwas, das dort gilt.

**Start-Bedingung erfüllt (2026-10-06):** Auftrag liegt vor; `slice-d-check-pin-macht-den-range-leerfall-laut` liegt in `done/` (`ls docs/plan/planning/done/slice-d-check-pin-macht-den-range-leerfall-laut.md`), der emittierte Default-Pin steht auf `v0.81.0` (`grep -n v0.81.0 internal/emit/emit.go`).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Messung einer zweiten Variante (cpp, `--arch`) wird nötig — dann je Variante ein Slice.
- `in-progress` → `open` (blockiert): das frisch emittierte Wurzel-`Makefile` definiert mehr als `help`, `gates`, `record-gates` — dann ist die Lage aus §1 nicht mehr die gemessene, und der Schnitt wird neu gemacht.

## 5. Closure-Trigger


DoD vollständig, `make gates` und `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte


- Stufe 1 sieht die Targets der Fragmente nicht; ein neues Fragment-Target ohne README-Zeile bleibt grün (Grenze in der dritten DoD-Zeile) — **Ausgang:** weiter offen: → BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht
- Der Lauf kostet im Ziel Zeit, ungemessen — **Ausgang:** weiter offen: → BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen

## 7. Closure-Notiz


Wird bei der Closure vom Planner geschrieben (AGENTS.md §3.10), nicht im Plan.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (`ALL`), Schwelle erfüllt; alle berührten Sub-Areas GF.

**Vorgelagert — offene Beobachtungen sichten:** gelesen am gemergten Stand 2026-10-06, Zähler je `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`: `waechter-abdeckung-haengt-an-uninstruierter-konvention` → 2 (die Vorlage-Konvention „neues Target ⇒ README-Zeile“ führt nicht jeder Anweisungssatz; der Slice macht sie zu einem Wächter im Ziel), `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` → 5 (bereits über der Schwelle; die Grenzen stehen am Ort der Emission), `kosten-einer-emittierten-pruefung-im-ziel-ungemessen` → 1, `emittierter-stand-laeuft-dem-dogfood-voraus` → 2.

