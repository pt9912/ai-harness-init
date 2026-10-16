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

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein roter Grün-Vorlauf des Mutations-Treibers nennt im Log des Laufs die Zeilen, die ihn rot gemacht haben (jedes `not ok` samt Diagnose), statt nur die letzten zwölf Zeilen des Protokolls.

Anlass: Shard 2 des Laufs vom 2026-10-16: Grün-Vorlauf `make test-bats` in der Isolationskopie Exit 1, 63 von 66 Fällen ohne Ergebnis; das `not ok` steht nicht im CI-Log (nur `ok` 524 bis 533 als „letzte Zeilen“). Lokal am Stand des Laufs komplett grün (533 `ok`), die Ursache ist **nicht belegt**; Annahme Lastflake. Der Treiber gibt bei rotem Grün-Vorlauf die letzten zwölf Zeilen aus (`show_tail` in `harness/tools/mutate.sh`); bei TAP-Ausgabe liegt das `not ok` vor den späten `ok`.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Ursache des roten `make test-bats`.** Ungemessen; erst das vollständige Log macht sie messbar. Wird sie gefunden, ist sie ein eigener Slice (eigener Gegenstand und vermutlich eigene Schicht).
- **Ein Wiederholungslauf bei rotem Grün-Vorlauf.** Wäre eine Sensor-Lockerung ([`AGENTS.md`](../../../../AGENTS.md) §3.5, ADR-pflichtig); der Slice liefert Sicht, kein anderes Urteil.
- **Artefakt-Upload des vollen Logs im Workflow.** Eine zweite Schicht (`mutate.yml`); bleibt aus, solange die Ausgabe der Treiber-Meldung trägt. Trägt sie nicht, ist das der Grund für einen Folge-Slice.
- **Das Sterben des Workers.** Siehe `slice-span-sperre-haelt-den-test-unter-last` §1; der Slice macht den Grund sichtbar, die Treiber-Robustheit bleibt anderer Vorgang. Dazu gehört gemessen: ein sterbender Worker lässt die übrigen stehen (Status 3/1, 32 von 65 Fällen ohne Ergebnis) — Treiber-Robustheit, keine Sicht.
- **Die Docker-Tag-Kollision paralleler Worker** (`No such image: sha256:…` im Grün-Vorlauf). Eigene Ursache am gemeinsamen Image-Tag, nicht an der Meldung; Träger ist die Beobachtung `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers`. Der Slice zeigt ihre Zeile im Log, wenn sie auftritt, behebt sie nicht.
- **Die Fehlklassifikation eines Docker-/colima-Aussetzers in `make artifact-host` als „BEFUND … falscher Grund“.** Gemessen am lokalen Lauf; der Treiber unterscheidet einen Umgebungsfehler des Vorlaufs nicht von einem falschen Grund des Falls. Andere Meldung (Fehlerklasse statt Fehlschlag-Zeilen), ein eigener Vorgang; bleibt in §6 benannt.

## 2. Definition of Done

- [x] Bei rotem Grün-Vorlauf nennt die Meldung des Treibers jede fehlgeschlagene Zeile (`not ok`) samt ihren Diagnose-Zeilen, auch wenn spätere Zeilen `ok` sind; die Menge ist nicht auf zwölf Zeilen begrenzt, sondern auf die Fehlschläge. **Grenze:** erfüllt für die bats-Form; bei Go nennt die Meldung nur die `--- FAIL`-Zeile, nicht deren Ursache.
- [x] Rot gesehen: ein bats-Fall des Treibers lässt den Grün-Vorlauf mit einem frühen `not ok` und späteren `ok`-Zeilen fallen und erwartet das `not ok` in der Meldung; mit dem alten `tail -n 12` färbt er rot.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | Ausgabe bei rotem Grün-Vorlauf: Fehlschlag-Zeilen statt nur `tail` |
| `test/` (bats-Fall des Treibers; Datei benennt der Implementer) | neu/update | Rot-Beleg nach [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) | update | die dort genannte Meldung des roten Grün-Vorlaufs |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner; Reihenfolge nach `slice-span-sperre-haelt-den-test-unter-last` (WIP-Limit 1, deterministisch rote Fälle zuerst). Kein fachlicher Vorgänger; die Verdikte des Architect berühren diesen Slice nicht. **Erfüllter Zustand:** der Vorgänger liegt in `done/` (Beleg: `ls docs/plan/planning/done/slice-span-sperre-haelt-den-test-unter-last.md`), `in-progress/` trägt danach nur `roadmap.md` (`ls docs/plan/planning/in-progress/`), WIP-Limit frei; `Verantwortlich:` gesetzt.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Ausgabe nur über eine zweite Schicht (Workflow, Artefakt) trägt.
- `in-progress` → `open` (blockiert): wenn die Treiber-Meldung eine Form verlangt, die `mutate.md` als Vertrag führt und ein ADR-pflichtiges Format wäre.

## 5. Closure-Trigger

DoD vollständig; Review ohne blockierenden Befund; Closure-Notiz geschrieben. Ob der nächste rote Grün-Vorlauf die Ursache nennt, ist Beobachtung der Folgezeit, kein Closure-Kriterium.

## 6. Risiken und offene Punkte

- Das `not ok` steht auch im vollen Protokoll nicht (Prozess hart beendet) — **Ausgang:** weiter offen → [`BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`](../observations/BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last/observation.md) (kein neuer Eintrag: derselbe rote Grün-Vorlauf von Shard 2 steht dort als *benannt, nicht gezählt*; ein Lauf, der es zeigt, fehlt noch); der Slice ändert an der Sichtbarkeit dann nichts.
- Die Ursache bleibt unbelegt (Lastflake nur vermutet) — **Ausgang:** weiter offen → [`BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`](../observations/BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last/observation.md) (angelegt vom Vorgänger-Slice, 1 Beleg; ein Beleg dieses Slice nur bei einem Lauf, der den Grund des roten Vorlaufs benennt).
- Ein Docker-/colima-Aussetzer in `make artifact-host` wird als „BEFUND … falscher Grund“ gemeldet und verfälscht den Befund, den der Slice sichtbar machen soll — **Ausgang:** weiter offen → [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/observation.md) (neu, 1 Beleg); der Slice ändert die Klassifikation nicht.
- Beim Wiederholen des Lokal-Belegs (Einzel- statt Mehrfachlauf) tritt die Tag-Kollision paralleler Worker auf — **Ausgang:** entfallen: der Beleg läuft über den bats-Fall allein (`make test-bats BATS_TARGET=test/mutate-driver.bats`, ein Worker, kein `make mutate`-Mehrfachlauf); die Verifikation fuhr ihn so, ohne `No such image`.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).
**Rolle:** Planner · **Datum:** 2026-10-16

- **Was hat funktioniert:** Gebaut ist `show_failures` in `harness/tools/mutate.sh`: bei rotem Grün-Vorlauf nennt die Meldung jedes bats-`not ok` samt `#`-Diagnose und jede Go-Zeile `--- FAIL`, vor dem Tail; der Abbruch (`rc -ne 0`, `return 1`) ist unverändert, der Grün-Vorlauf bleibt hart. Review: 0 HIGH, 0 MEDIUM, 2 LOW, 2 INFO; beide LOW im Implementer-Commit `ef34622a` behoben (Go-Zweig bekam Fall 19, `mutate.md` und Kommentar nennen die Grenze). **Gemessen** (Verifikation `…-verify`, HEAD `ef34622a`): Rot selbst gefahren — ohne den `show_failures`-Aufruf fallen Fall 18 und 19, ohne den Go-Zweig allein Fall 19; `make gates` Exit 0, Stempel == HEAD; `make mutate-greift` 653/653; `test/mutations/` unberührt.
- **Was ging anders als geplant:** **(1) D1 trägt für bats, für Go nur zur Hälfte:** „samt Diagnose“ gilt für bats; bei Go zeigt die Meldung die `--- FAIL`-Zeile, nicht deren eingerückte Ursache, und ein Go-Build-Fehler bleibt beim Tail. Der Planner hat das Häkchen mit dieser Grenze im Wortlaut gesetzt. **(2) Vorher/Nachher ist am Stub gemessen:** am realen `green_prerun` beider Fassungen mit demselben `make`-Stub; der Stub ist kein echter CI-Lauf. Das echte Log (Run 38865723125, Job `mutate (2)`) trägt nur den Tail `ok 524`–`533`, kein `not ok`: ob das `not ok` oben im bats-Output stand oder der Prozess hart endete, ist **weder bestätigt noch widerlegt**. **(3) Kein Mutations-Fall:** `make mutate-auswahl` führt zum CI-Branch (Exit 10), nichts gepusht; der Slice legt keinen Fall an, [`MR-071`](../../../../harness/conventions.md#mr-071) greift nicht — die Zähne tragen allein die zwei bats-Fälle. **Nicht belegt und so geführt:** die Ursache des roten Grün-Vorlaufs; der Slice liefert Sicht für den nächsten roten Lauf (§5).
- **Steering-Loop-Eintrag:** **geschärfte Regel nur als Beobachtung**: eine Doku-Zusage, die einen Test als Halter nennt, sagt, welche Form er misst — hier nannte `mutate.md` die Go-Zeile mit dem bats-Fall als Halter, und das Löschen der Go-Zeile ließ die Datei grün (Review LOW-1). Auslöser: `BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst` (`2026-09-25-releasing-md-schritt-7-vorbehalte-f-1-bis-f-3-kurzrunde`, `slice-tap-check-liest-keine-version-ist-gebunden`, `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log` — 3×). Ausgang *geplant*, nicht verkörpert (kein Zielort-Feld): `slice-doku-zusage-nennt-den-test-nur-fuer-das-was-er-misst`.
- **Beobachtungs-Register (`../observations/`):**
  - Neu: [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/observation.md) — 1 Beleg (`evidence/slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke.md`, Review INFO-2), `offen`. Dieser Slice trägt keinen zweiten Beleg: sein Anlass ist derselbe lokale Lauf, ein Vorgang zählt einmal. Kein bestehender Eintrag deckt den Gegenstand (`paralleler-mutate-lauf-…` hat anderes Symptom).
  - Beleg ergänzt: `evidence/slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log.md` in `BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst/` — Zähler steht damit bei 3×; `state.md` trägt `geplant` mit der Kennung des Folge-Slice (`make register-ausgang`).
  - **Kein Beleg:** `BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last` (bleibt 1×) — kein Lauf nennt den Grund des roten Vorlaufs; `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers` (bleibt 1×) — nicht aufgetreten; `BEO-ALL/neue-isolation-entzahnt-bestehende-waechter` und `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` — Nähe über denselben Treiber, aber keine Isolation und kein entwaffneter Fall.
- **Folge-Slices:** `slice-doku-zusage-nennt-den-test-nur-fuer-das-was-er-misst` (Hard-Rule-Entscheidung zur Klasse) — ist eine Datei in `open/`. Der nächste rote Grün-Vorlauf ist Beobachtung der Folgezeit, kein Slice.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR-Re-Evaluierungs-Trigger: keiner berührt. Hard Rules: keine mit eingetretenem Auflösungs-Trigger.
- **Drei Paarungen:** Anker: kein Eintrag trägt `liegt in`, nichts zu paaren · Folge-Slice: `slice-doku-zusage-nennt-den-test-nur-fuer-das-was-er-misst` liegt in `open/` · Register: beide genannten Verzeichnisse existieren mit nicht leerem `evidence/`, `make register-ausgang` 0 Befunde.
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice` ist nicht gebaut).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer: [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) (8, verkörpert: [`MR-090`](../../../../harness/conventions.md#mr-090) und [`MR-071`](../../../../harness/conventions.md#mr-071) tragen den Treiber-Teil) als Nähe über denselben Treiber; [`BEO-ALL/neue-isolation-entzahnt-bestehende-waechter`](../observations/BEO-ALL/neue-isolation-entzahnt-bestehende-waechter/observation.md) (2, offen); [`BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`](../observations/BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last/observation.md) (1, offen) — der Gegenstand dieses Slice; [`BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers`](../observations/BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers/observation.md) (1, offen) als Nähe über denselben Treiber. Kein Eintrag erreicht mit diesem Slice 3×.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
