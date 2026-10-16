# Slice slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log: Ein roter Grün-Vorlauf des Mutations-Treibers nennt seine Fehlschläge

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — reaktiv (ein Sensor hat gefeuert), keine Closure-Bedingung jenseits der DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Diagnose ist Teil der Reproduzierbarkeit), [`MR-090`](../../../../harness/conventions.md#mr-090), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** —.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein roter Grün-Vorlauf des Mutations-Treibers nennt im Log des Laufs die Zeilen, die ihn rot gemacht haben (jedes `not ok` samt Diagnose), statt nur die letzten zwölf Zeilen des Protokolls.

Anlass: Shard 2 des Laufs vom 2026-10-16: Grün-Vorlauf `make test-bats` in der Isolationskopie Exit 1, 63 von 66 Fällen ohne Ergebnis; das `not ok` steht nicht im CI-Log (nur `ok` 524 bis 533 als „letzte Zeilen“). Lokal am Stand des Laufs komplett grün (533 `ok`), die Ursache ist **nicht belegt**; Annahme Lastflake. Der Treiber gibt bei rotem Grün-Vorlauf die letzten zwölf Zeilen aus (`show_tail` in `harness/tools/mutate.sh`); bei TAP-Ausgabe liegt das `not ok` vor den späten `ok`.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Ursache des roten `make test-bats`.** Ungemessen; erst das vollständige Log macht sie messbar. Wird sie gefunden, ist sie ein eigener Slice (eigener Gegenstand und vermutlich eigene Schicht).
- **Ein Wiederholungslauf bei rotem Grün-Vorlauf.** Wäre eine Sensor-Lockerung ([`AGENTS.md`](../../../../AGENTS.md) §3.5, ADR-pflichtig); der Slice liefert Sicht, kein anderes Urteil.
- **Artefakt-Upload des vollen Logs im Workflow.** Eine zweite Schicht (`mutate.yml`); bleibt aus, solange die Ausgabe der Treiber-Meldung trägt. Trägt sie nicht, ist das der Grund für einen Folge-Slice.
- **Das Sterben des Workers.** Siehe `slice-span-sperre-haelt-den-test-unter-last` §1; der Slice macht den Grund sichtbar, die Treiber-Robustheit bleibt anderer Vorgang.

## 2. Definition of Done

- [ ] Bei rotem Grün-Vorlauf nennt die Meldung des Treibers jede fehlgeschlagene Zeile (`not ok`) samt ihren Diagnose-Zeilen, auch wenn spätere Zeilen `ok` sind; die Menge ist nicht auf zwölf Zeilen begrenzt, sondern auf die Fehlschläge.
- [ ] Rot gesehen: ein bats-Fall des Treibers lässt den Grün-Vorlauf mit einem frühen `not ok` und späteren `ok`-Zeilen fallen und erwartet das `not ok` in der Meldung; mit dem alten `tail -n 12` färbt er rot.
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
| `harness/tools/mutate.sh` | update | Ausgabe bei rotem Grün-Vorlauf: Fehlschlag-Zeilen statt nur `tail` |
| `test/` (bats-Fall des Treibers; Datei benennt der Implementer) | neu/update | Rot-Beleg nach [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) | update | die dort genannte Meldung des roten Grün-Vorlaufs |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner. Kein Vorgänger-Slice.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Ausgabe nur über eine zweite Schicht (Workflow, Artefakt) trägt.
- `in-progress` → `open` (blockiert): wenn die Treiber-Meldung eine Form verlangt, die `mutate.md` als Vertrag führt und ein ADR-pflichtiges Format wäre.

## 5. Closure-Trigger

DoD vollständig; Review ohne blockierenden Befund; Closure-Notiz geschrieben. Ob der nächste rote Grün-Vorlauf die Ursache nennt, ist Beobachtung der Folgezeit, kein Closure-Kriterium.

## 6. Risiken und offene Punkte

- Das `not ok` steht auch im vollen Protokoll nicht (Prozess hart beendet) — **Ausgang:** weiter offen → neue Beobachtung in der Closure; der Slice ändert an der Sichtbarkeit dann nichts.
- Die Ursache bleibt unbelegt (Lastflake nur vermutet) — **Ausgang:** weiter offen → Register-Eintrag zu roten Grün-Vorläufen unter Last, gemeinsam mit `slice-span-sperre-haelt-den-test-unter-last`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer: [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) (8, verkörpert: [`MR-090`](../../../../harness/conventions.md#mr-090) und [`MR-071`](../../../../harness/conventions.md#mr-071) tragen den Treiber-Teil) als Nähe über denselben Treiber; [`BEO-ALL/neue-isolation-entzahnt-bestehende-waechter`](../observations/BEO-ALL/neue-isolation-entzahnt-bestehende-waechter/observation.md) (1, offen). Kein Eintrag erreicht mit diesem Slice 3×.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
