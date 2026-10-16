# Slice slice-mutate-doku-nennt-den-lokalen-weg-auf-macos: Die Treiber-Doku von `make mutate` nennt den lokalen Weg auf einem Nicht-Linux-Host

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — reaktiv (Register-Ausgang *geplant* bei 3×), keine Closure-Bedingung jenseits der DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (ein Beleg ist wiederholbar, wenn sein Aufruf dasteht), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** —.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) nennt den Aufruf, mit dem ein `# verify: full-smoke`-Fall auf einem Nicht-Linux-Host lokal läuft (`SMOKE_ARTIFACT_TARGET=artifact-host`), samt seiner Grenze; der Kopf von Fall 171 nennt den richtigen Halter der Feldlisten-Ablage.

Anlass: der Ausgang *geplant* von `BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host` (3×). Die Fälle 305 und 171 wurden lokal nur über diese Variable gemessen; sie steht in keiner Doku (`grep -rn SMOKE_ARTIFACT_TARGET docs harness/README.md harness/sensors Makefile` trifft allein `Makefile`). Der Kopf von Fall 171 nennt „die Fälle 614 und 615“ als Halter der Stufe für die Feldlisten-Ablage; 614 mutiert `docs/plan/carveouts` (`.gitkeep`), nur Fall 615 die Feldliste (`internal/emit/enforce.go`) — beide halten dieselbe Stufe, 614 nicht für diesen Pfad (Verifikation zu Slice 305/171, F-1; Beleg für `BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein eigenes Make-Ziel `mutate-host` oder eine Änderung an `harness/tools/mutate.sh`.** Anderer Vorgang (Werkzeug statt Doku) und eine Entscheidung über den Treiber; die Doku beschreibt den vorhandenen Durchreich-Weg.
- **Die Docker-Tag-Kollision paralleler Worker.** Anderer Gegenstand: `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers`.
- **Weitere Köpfe.** Bestand bleibt bewusst stehen; gefasst wird allein der Kopf von Fall 171, den die Verifikation benannt hat.

## 2. Definition of Done

- [ ] `harness/sensors/mutate.md` nennt den Aufruf `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=<voller Fallname> make mutate` für Fälle mit `# verify: full-smoke` auf einem Nicht-Linux-Host und seine Grenzen: nur Einzel-Fälle gemessen; `MUTATE_CASES` verlangt den vollen Fallnamen (mehrere Fälle durch Leerzeichen getrennt); der Grün-Vorlauf dauert je Fall Größenordnung 100–220 s (der Implementer belegt die Zahl am Aufruf); der Aufruf ist am Fall 305 einmal gefahren und sein Ausgang (`ok`) im Slice §7 genannt.
- [ ] Der Kopf von `test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh` nennt Fall 615 allein statt „614 und 615“ als Halter der Feldlisten-Ablage; `make mutate-greift` bleibt grün.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für `harness/sensors/mutate.md` (öffentlicher Vertrag des Treibers berührt).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert; der Stand von `BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host` trägt den Beleg dieses Slice als Verkörperung.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/sensors/mutate.md` | update | der lokale Weg für `# verify: full-smoke`-Fälle auf Nicht-Linux-Hosts |
| `test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh` | update | Kopf nennt 615 statt 614 |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner; WIP-Limit frei. Reihenfolge nach `slice-span-sperre-haelt-den-test-unter-last`. **Erfüllter Zustand:** der Vorgänger `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log` liegt in `done/` (Beleg: `ls docs/plan/planning/done/slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log.md`), `in-progress/` trägt danach nur `roadmap.md` (`ls docs/plan/planning/in-progress/`), WIP-Limit frei; `Verantwortlich:` gesetzt.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Doku zusätzlich ein Werkzeug (Make-Ziel) verlangt.
- `in-progress` → `open` (blockiert): wenn der Aufruf auf dem Host auch in Einzelläufen nicht trägt — dann benennt der Slice die Grenze und gibt die Beobachtung zurück.

## 5. Closure-Trigger

DoD vollständig; der in der Doku genannte Aufruf ist einmal gefahren; Review ohne blockierenden Befund; Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Der genannte Aufruf trägt nur für Einzel-Fälle, nicht für einen Mehrfach-Lauf — **Ausgang:** weiter offen → `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer: [`BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/observation.md) (3×, geplant — dieser Slice); [`BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle`](../observations/BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle/observation.md) (2×, offen — dieser Slice wäre der dritte Beleg und löste den Lese-Schritt aus).

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
