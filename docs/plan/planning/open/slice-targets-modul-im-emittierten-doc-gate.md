# Slice slice-targets-modul-im-emittierten-doc-gate: Das emittierte Doc-Gate führt das Modul targets

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-054`](../../../../harness/conventions.md#mr-054), [`MR-055`](../../../../harness/conventions.md#mr-055), [`MR-063`](../../../../harness/conventions.md#mr-063).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung


**Ziel:** Das emittierte `.d-check.yml` führt `targets` (Target ↔ Tabellenzeile, beide Richtungen) über **alle** Makefiles des Ziels, und der Gate-Index ist zweigeteilt: ein **werkzeug-eigener Teil** (`harness/mk/ai-harness-init.md` im Ziel <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->, neben den Fragmenten, die er beschreibt, vom Bootstrap bei jedem Lauf kanonisch neu geschrieben) führt die emittierten Targets, `harness/README.md` §Sensors die des Adopters; beide sind `authority`. Grüner Start am frischen `--lang go`-Ziel, je ein rotes Gegenbeispiel pro Richtung in `make full-smoke`.

**Planner-Entscheidung — die Abnahme ist geändert (2026-10-06, Auftraggeber):** Die Stufe 1 (`makefiles: [Makefile]`, `exempt-targets: [help, record-gates]`) ist als Ziel gestrichen; sie ist am frisch emittierten Ziel (Pin d-check `v0.81.0`) widerlegt (§4). An ihre Stelle tritt die Indirektion über den werkzeug-eigenen Teil des Gate-Index; §1, §2 und §3 tragen diese Fassung. Sie setzt zwei Antworten voraus, die nicht in diesem Repo entstehen (Start-Bedingung §4).

**Lage** (Implementer-Messung am frisch emittierten Ziel, Pin `v0.81.0`): `makefiles: [Makefile]` meldet `gate-phantom` für die README-Zeile `make docs-check` (Regel in `d-check.mk`), und `exempt-targets` wirkt nicht auf `gate-phantom`. Variante A `makefiles: [Makefile, d-check.mk]` braucht 14 Ausnahmen, Variante B (Glob über `harness/mk/*.mk`) 27, darunter vier echte Gates — ein Ausnahme-Block in der Größe der Target-Menge. Die Indirektion braucht am Regelwerk eine Erlaubnis für einen zweiteiligen Gate-Index (heute [`modul-13-quality-gates.md`](../../../../.harness/baseline/v6.16.0/regelwerk/modul-13-quality-gates.md#hard-rule-doku-disziplin) §Hard Rule: *„es gibt genau eine"* Autoritäts-Doku; `grundlagen-harness-dateien.md`: *„Der Gate-Index steht einmal"*) und am Werkzeug `targets.authority` als Liste (heute ein einzelner String; `gate-undocumented` misst nur gegen `authority`). Beide Antworten liegen vor:

- **Kurs:** der werkzeug-eigene Teil des Gate-Index heißt `harness/mk/<werkzeug>.md` — hier `harness/mk/ai-harness-init.md` <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) --> — und liegt neben den Fragmenten, die er beschreibt; die Eigentumsgrenze ist das Verzeichnis `harness/mk/`. Eine eigene Vorlage gibt es nicht: die Form ist die von `harness/README.md` §Sensors, das Werkzeug erzeugt die Datei. Die Regel steht noch in keiner Kurs-Release.
- **d-check:** `targets.authority` nimmt ab `v0.82.0` eine Liste — Vereinigung der Dateien; eine Doppelnennung ist kein Befund; eine fehlende Datei oder ein leerer Eintrag endet mit Exit 2; eine leere Liste lässt die Prüfung entfallen; mit einer Datei ist das Ergebnis byte-identisch zum String. Der Glob in `makefiles` steht ab `v0.81.0`. Die Konfiguration im Ziel ist damit `authority: [harness/README.md, harness/mk/ai-harness-init.md]`, `makefiles: [Makefile, "harness/mk/*.mk", d-check.mk]`; Ausnahmen voraussichtlich keine — am Ziel zu messen, nicht anzunehmen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Die Stufe 1 und Variante A/B als Default — gemessen widerlegt bzw. ein Ausnahme-Block in der Größe der Target-Menge (Lage oben).
- Die Change Requests selbst — anderer Vorgang in fremden Repos; der Slice wartet auf ihre Antwort (§4).
- Die Varianten `--lang cpp` und `--arch hexslice`/`hexagonal` — nicht gemessen; der Slice misst jede Variante, die er abdeckt, oder benennt die Grenze statt sie zu behaupten ([`MR-055`](../../../../harness/conventions.md#mr-055)).
- Der Ordner `harness/sensors/` im Ziel — Folge-Slice `slice-sensors-ordner-entsteht-im-ziel`; `targets` prüft Makefile gegen Index-Tabellen und braucht ihn nicht.
- Nachzug in bestehende Ziele — `.d-check.yml` wird nur an freiem Pfad geschrieben; der Nachzug ist Handarbeit nach der Positionsliste im Kopfkommentar, ein anderer Vorgang.
- Die `.d-check.yml` dieses Repos — führt `targets` bereits; Ebene ist das Emittierte (Dogfood-vs-emittiert).

## 2. Definition of Done


- [ ] Der Bootstrap schreibt den werkzeug-eigenen Index-Teil kanonisch neu (eine Zeile je emittiertem Target, `kein Gate` wo zutreffend), und das emittierte `.d-check.yml` führt `targets` mit beiden Index-Teilen als `authority` über alle Makefiles des Ziels, ohne Ausnahme-Block in der Größe der Target-Menge; der Kopfkommentar „Herkunft der Positionen“ nennt die Position.
- [ ] `make full-smoke` misst im Ziel grünen Start und die Gegenbeispiele mit Grund-Code: ein Target ohne Zeile ⇒ `gate-undocumented`, eine Zeile ohne Target ⇒ `gate-phantom`; die Stufe steht mit ihrer Grenze (nur gemessene Varianten) in der E2E-Abdeckungs-Sicht ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
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
| `internal/emit/templates/d-check.yml` | update | `targets` + Block + Kopfkommentar; Aktivierung nach [`MR-054`](../../../../harness/conventions.md#mr-054) (Erprobung, grüner Start, rotes Gegenbeispiel) |
| `internal/emit/` (werkzeug-eigener Index-Teil) | neu | kanonisch neu geschrieben je Bootstrap-Lauf |
| `harness/tools/full-smoke.sh` | update | Stufe grün plus zwei rote Gegenbeispiele; `docs/user/e2e-abdeckung.md` per `make e2e-abdeckung` neu erzeugt. **Kopplung (Implementer-Messung):** hängt `targets` an die Modul-Liste, bricht der `sed` der Zellenlänge-Gegenprobe (`grep -nF 's/, structure' harness/tools/full-smoke.sh`) |
| `test/mutations/` (Fälle 295, 514), `internal/emit/emit_test.go` (`TestDCheckConfig_EntschiedeneModulListe`) | update | binden die exakte Modul-Liste `[links, anchors, ids, matrix, spans, structure]` |

## 4. Trigger


**Start** (`next` → `in-progress`): Auftrag des Auftraggebers **und** zwei Bedingungen — die Kurs-Release, die den werkzeug-eigenen Index-Teil `harness/mk/<werkzeug>.md` regelt, ist per Baseline-Sprung adoptiert (`.harness/baseline/<tag>/`), **und** der d-check-Pin steht auf `v0.82.0` oder später, im Dogfood und im emittierten Default-Pin (`grep -n DCHECK internal/emit/emit.go d-check.mk`).

**Rückführung `in-progress` → `open` vollzogen (2026-10-06, Blocker):** Die Implementer-Messung am frisch emittierten Ziel (Pin d-check `v0.81.0`) widerlegte die Stufe 1: `makefiles: [Makefile]` meldet `gate-phantom` für die README-Zeile `make docs-check`, `exempt-targets` wirkt nicht auf `gate-phantom`; Variante A braucht 14, Variante B 27 Ausnahmen (§1 Lage). Der Auftraggeber wählt die Indirektion über einen werkzeug-eigenen Index-Teil, die zwei Change Requests voraussetzt; die Abnahme ist darum geändert (§1 Planner-Entscheidung).

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

**Vorgelagert — offene Beobachtungen sichten:** gelesen am gemergten Stand 2026-10-06, Zähler je `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`: `waechter-abdeckung-haengt-an-uninstruierter-konvention` → 2 (die Vorlage-Konvention „neues Target ⇒ README-Zeile“ führt nicht jeder Anweisungssatz; der Slice macht sie zu einem Wächter im Ziel), `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` → 5 (bereits über der Schwelle; die Grenzen stehen am Ort der Emission), `kosten-einer-emittierten-pruefung-im-ziel-ungemessen` → 1, `emittierter-stand-laeuft-dem-dogfood-voraus` → 2.

