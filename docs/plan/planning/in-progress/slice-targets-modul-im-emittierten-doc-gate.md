# Slice slice-targets-modul-im-emittierten-doc-gate: Das emittierte Doc-Gate führt das Modul targets

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-054`](../../../../harness/conventions.md#mr-054), [`MR-055`](../../../../harness/conventions.md#mr-055), [`MR-063`](../../../../harness/conventions.md#mr-063), [`MR-080`](../../../../harness/conventions.md#mr-080), [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 3 (Welle 159), [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Festlegung 5.

**Berührte Spec-Stellen:** —

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung


**Ziel:** Das emittierte `.d-check.yml` führt `targets` (Target ↔ Tabellenzeile, beide Richtungen) über **alle** Makefiles des Ziels gegen einen Gate-Index mit zwei Eigentümern: der **werkzeug-eigene Teil** `harness/mk/ai-harness-init.md` <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) --> (neben den Fragmenten, vom Bootstrap bei jedem Lauf kanonisch neu geschrieben, aus `harness/README.md` §Sensors verlinkt) führt die emittierten Targets, `harness/README.md` §Sensors die des Repos — auch die aus `repo.mk`. Grüner Start am frischen `--lang go`-Ziel, je ein rotes Gegenbeispiel pro Richtung in `make full-smoke`.

**Lage.** Die Stufe 1 (`makefiles: [Makefile]`) ist am frisch emittierten Ziel widerlegt (§4): `gate-phantom` für die README-Zeile `make docs-check`, `exempt-targets` wirkt nicht darauf; Variante A braucht 14, Variante B 27 Ausnahmen. Die zwei Voraussetzungen der Indirektion sind erfüllt:

- **Kurs `v6.16.0`, adoptiert** ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 3: Welle 159 trägt dieser Vorgang): [`grundlagen-harness-dateien.md`](../../../../.harness/baseline/v6.16.0/regelwerk/grundlagen-harness-dateien.md) §Ein Index, mehrere Eigentümer — `harness/mk/<werkzeug>.md`, werkzeug-eigen und je Lauf neu geschrieben, nur die eigenen Targets in den Tabellen-Formen von §Sensors (`kein Gate` in der Bindung, wo zutreffend), disjunkt, von einer Zeile unter den Tabellen in §Sensors verlinkt, und der Deklarations-Sensor misst gegen die **Vereinigung**; dieselbe Regel in [`modul-13-quality-gates.md`](../../../../.harness/baseline/v6.16.0/regelwerk/modul-13-quality-gates.md#hard-rule-doku-disziplin) §Hard Rule. Die Disjunktheit prüft der Sensor nicht.
- **d-check `v0.82.0`, gepinnt** ([`MR-080`](../../../../harness/conventions.md#mr-080), Dogfood und emittierter Default-Pin): `targets.authority` als Liste (Vereinigung; fehlende Datei ⇒ Exit 2), Glob in `makefiles` ab `v0.81.0`.

Konfiguration im Ziel: `authority: [harness/README.md, harness/mk/ai-harness-init.md]`, `makefiles: [Makefile, "harness/mk/*.mk", "*.mk"]` — der Wurzel-Glob liest `d-check.mk`, `a-check.mk` und `repo.mk` und übersteht eine fehlende `repo.mk` ([ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Festlegung 3, Fitness 2; Festlegung 5 trägt ihn, Architect-Verdikt `2026-10-07-targets-architect-verdikt.md`); eine fremde `.mk` an der Wurzel wird mitgelesen, eine im Unterordner nicht. Ausnahmen werden am Ziel gemessen, nicht angenommen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Die Stufe 1 und Variante A/B als Default — gemessen widerlegt bzw. ein Ausnahme-Block in der Größe der Target-Menge (Lage oben).
- `repo.mk` selbst (Aggregator-Zeile, Startinhalt, Vorgabe-Ort, Fitness 1–2 aus [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md)) — Vorgänger `slice-anwender-targets-leben-in-repo-mk`; dieser Slice misst nur Fitness 3.
- Ein Sensor für die Disjunktheit der beiden Index-Teile — der gepinnte d-check prüft sie nicht; Grenze am Ort der Emission benannt (§2), kein eigener Sensor-Bau.
- Die Varianten `--lang cpp` und `--arch hexslice`/`hexagonal` — nicht gemessen; der Slice misst jede Variante, die er abdeckt, oder benennt die Grenze statt sie zu behaupten ([`MR-055`](../../../../harness/conventions.md#mr-055)).
- Der Ordner `harness/sensors/` im Ziel — Folge-Slice `slice-sensors-ordner-entsteht-im-ziel`; `targets` prüft Makefile gegen Index-Tabellen und braucht ihn nicht.
- Nachzug in bestehende Ziele — `.d-check.yml` wird nur an freiem Pfad geschrieben; der Nachzug ist Handarbeit nach der Positionsliste im Kopfkommentar, ein anderer Vorgang.
- Die `.d-check.yml` dieses Repos — führt `targets` bereits; Ebene ist das Emittierte (Dogfood-vs-emittiert).

## 2. Definition of Done


- [ ] Der Bootstrap schreibt den werkzeug-eigenen Index-Teil kanonisch neu (eine Zeile je emittiertem Target, `kein Gate` wo zutreffend), das emittierte `harness/README.md` verlinkt ihn unter den Tabellen von §Sensors, und das emittierte `.d-check.yml` führt `targets` mit beiden Index-Teilen als `authority` über `Makefile`, `harness/mk/*.mk`, `d-check.mk` und `repo.mk`, ohne Ausnahme-Block in der Größe der Target-Menge; der Kopfkommentar „Herkunft der Positionen“ nennt die Position. Aufnahme nach den drei Kriterien von [`MR-054`](../../../../harness/conventions.md#mr-054), je Kriterium belegt: **Erprobung** (das Modul läuft im Doku-Gate dieses Repos, `grep -n '^modules:' .d-check.yml`), **grüner Start** am frisch emittierten `--lang go`-Ziel und **rotes Gegenbeispiel** je Richtung (nächster Punkt).
- [ ] `make full-smoke` misst im Ziel grünen Start und die Gegenbeispiele mit Grund-Code: ein Target in `repo.mk` ohne Zeile ⇒ `gate-undocumented` (Rot-Probe: `"*.mk"` aus `makefiles:` gestrichen ⇒ bleibt grün, [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Fitness 3), eine Zeile ohne Target ⇒ `gate-phantom`; die Stufe steht mit ihrer Grenze (nur gemessene Varianten) in der E2E-Abdeckungs-Sicht ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] Die Grenzen stehen am Ort der Emission (Kopfkommentar der Vorlage `d-check.yml` und Kopf des werkzeug-eigenen Index-Teils): wer ihn von Hand ändert, verliert die Änderung beim nächsten Bootstrap-Lauf; was die adoptierte Kurs-Fassung und der gepinnte d-check dazu sagen, steht mit Tag.
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
| `internal/emit/templates/d-check.yml` | update | `targets` + Block (`authority: [harness/README.md, harness/mk/ai-harness-init.md]`, `makefiles: [Makefile, "harness/mk/*.mk", "*.mk"]` — `repo.mk` über den Wurzel-Glob, [ADR-0080](../../adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) Festlegung 5) + Kopfkommentar; Aktivierung nach [`MR-054`](../../../../harness/conventions.md#mr-054) (Erprobung, grüner Start, rotes Gegenbeispiel) |
| `internal/emit/` (werkzeug-eigener Index-Teil) | neu | kanonisch neu geschrieben je Bootstrap-Lauf, konvergent wie `d-check.mk`; kein Eintrag in der Klassentabelle `internal/emit/enforce.go` (keine Zusage liest dort den Pfad) |
| emittiertes `harness/README.md` (Vorlagen-Kopie, skip-if-present) | prüfen / update | die Link-Zeile auf den Werkzeug-Teil; die Vorlage `v6.16.0` trägt die Regel (`grep -n 'harness/mk' .harness/baseline/v6.16.0/templates/harness/README.template.md`), ob sie die Zeile auf `ai-harness-init.md` trägt, misst der Lauf; ein bestehendes Ziel bekommt sie nicht (Nachzug ausgeschlossen) |
| `docs/user/benutzerhandbuch.md` | update | Klassentabelle (kanonisch) nennt den Werkzeug-Teil; die Pflicht „eigenes Target ⇒ Zeile in `harness/README.md`" steht als gemessene Zusage |
| `harness/tools/full-smoke.sh` | update | Stufe grün plus zwei rote Gegenbeispiele; `docs/user/e2e-abdeckung.md` per `make e2e-abdeckung` neu erzeugt. **Kopplung (Implementer-Messung):** hängt `targets` an die Modul-Liste, bricht der `sed` der Zellenlänge-Gegenprobe (`grep -nF 's/, structure' harness/tools/full-smoke.sh`) |
| `test/mutations/` (Fälle 295, 514), `internal/emit/emit_test.go` (`TestDCheckConfig_EntschiedeneModulListe`) | update | binden die exakte Modul-Liste `[links, anchors, ids, matrix, spans, structure]` |

## 4. Trigger


**Start** (`next` → `in-progress`): Auftrag des Auftraggebers **und** `slice-anwender-targets-leben-in-repo-mk` liegt in `done/` (`ls docs/plan/planning/done/slice-anwender-targets-leben-in-repo-mk*`). Erfüllt und nur vermerkt: Kurs `v6.16.0` adoptiert (`ls .harness/baseline/`), d-check-Pin `v0.82.0` im Dogfood und im emittierten Default-Pin (`grep -n 'v0.82.0' internal/emit/emit.go d-check.mk`).

**Rückführung `in-progress` → `open` vollzogen (2026-10-06, Blocker):** Die Implementer-Messung am frisch emittierten Ziel (Pin d-check `v0.81.0`) widerlegte die Stufe 1: `makefiles: [Makefile]` meldet `gate-phantom` für die README-Zeile `make docs-check`, `exempt-targets` wirkt nicht auf `gate-phantom`; Variante A braucht 14, Variante B 27 Ausnahmen (§1 Lage). Der Auftraggeber wählt die Indirektion über einen werkzeug-eigenen Index-Teil, die zwei Change Requests voraussetzt; die Abnahme ist darum geändert (§1 Lage).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Messung einer zweiten Variante (cpp, `--arch`) wird nötig — dann je Variante ein Slice.
- `in-progress` → `open` (blockiert): die adoptierte Kurs-Release oder der gepinnte d-check trägt eine der beiden Antworten (§1 Lage) anders als zugesagt, oder die Messung am Ziel verlangt doch einen Ausnahme-Block — dann wird der Schnitt neu gemacht.

## 5. Closure-Trigger


DoD vollständig, `make gates` und `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte


- Ein per `add-lang` hinzugekommenes Fragment-Target fehlt im werkzeug-eigenen Index-Teil, bis der Bootstrap ihn neu schreibt — **Ausgang:** weiter offen: → BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht
- Der Lauf kostet im Ziel Zeit, ungemessen — **Ausgang:** weiter offen: → BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen

## 7. Closure-Notiz


Wird bei der Closure vom Planner geschrieben (AGENTS.md §3.10), nicht im Plan.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (`ALL`), Schwelle erfüllt; alle berührten Sub-Areas GF.

**Vorgelagert — offene Beobachtungen sichten:** gelesen am gemergten Stand 2026-10-07, Zähler je `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`: `waechter-abdeckung-haengt-an-uninstruierter-konvention` → 2 (die Vorlage-Konvention „neues Target ⇒ README-Zeile“ führt nicht jeder Anweisungssatz; der Slice macht sie zu einem Wächter im Ziel), `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` → 6 (verkörpert; die Grenzen stehen am Ort der Emission), `kosten-einer-emittierten-pruefung-im-ziel-ungemessen` → 1, `emittierter-stand-laeuft-dem-dogfood-voraus` → 2.

