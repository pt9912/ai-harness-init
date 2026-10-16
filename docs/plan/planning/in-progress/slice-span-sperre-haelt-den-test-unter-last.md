# Slice slice-span-sperre-haelt-den-test-unter-last: Der Sperr-Test des Span-Emitters hält unter Last

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — reaktiv (ein Sensor hat gefeuert), keine Closure-Bedingung jenseits der DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Bezug:** [`LH-FA-16`](../../../../spec/lastenheft.md#lh-fa-16--betrieb-und-bestand-der-erfassung), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (derselbe Lauf liefert dasselbe Ergebnis); [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** `SPEC-063` (liegengebliebenes Lock-Verzeichnis) und `SPEC-060` (Nebenläufigkeit der Nummernvergabe) — beide nennen kein Sperr-Budget; gemessen: `grep -n -iE 'lockTries|Sperr-Budget|lockWait' spec/spezifikation.md` → keine Zeile.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** `TestConcurrentEmittersGetDistinctSeq` ist unter der Last eines ausgelasteten CI-Runners nicht mehr rot, ohne dass die Eigenschaft, die er bindet (Nummernvergabe und Anhängen unter **einer** Sperre), schwächer wird.

Anlass: Shard 7 des Laufs `mutate` ist flaky (2026-10-14 rot, 10-15 grün, 10-16 rot). Der Grün-Vorlauf `make test-go` in der Isolationskopie fällt an `span_test.go` mit „Sperre nicht erhalten“ und „5 Zeilen, erwartet 8“. `internal/span/emit.go` hat `lockTries = 200`, `lockWait = 2ms` (~400 ms je Sperre); der Test startet 8 Goroutinen, vier parallele Worker teilen den Runner. Ein roter Grün-Vorlauf lässt den Worker sterben, 32 von 65 Fällen des Laufs bleiben ohne Ergebnis.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein Wiederholungslauf des Grün-Vorlaufs.** Er wäre eine Sensor-Lockerung ([`AGENTS.md`](../../../../AGENTS.md) §3.5, ADR-pflichtig) und verdeckte, dass der Test auf einem ausgelasteten Runner nicht trägt.
- **`MUTATE_JOBS` senken** als Ersatz für den Fix. Laut `harness/sensors/mutate.md` und `Makefile` eine Zeit-, keine Verdikt-Stellschraube; sie verschiebt die Last, behebt nicht den Test. Zulässig bleibt sie als Ergänzung, wenn die Messung zeigt, dass die Test-Last nicht der Grund ist — dann Rückführung nach `open`.
- **Das Sterben des Workers und die Folgen für die übrigen Fälle.** Anderer Vorgang (Treiber-Robustheit): bleibt benannt in §6; der Slice `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log` macht den Grund sichtbar, repariert aber den Abbruch nicht.
- **Spec-/ADR-Text zur Sperre.** Entschieden (A2, Architect-Bericht, ohne ADR): eine Konstanten- oder Test-Änderung genügt, kein Spec-/ADR-Satz; `make hook-overhead` ist kein Gate (`harness/README.md` §Werkzeuge), eine Budget-Änderung senkt keine Schwelle nach `AGENTS.md` §3.5.

## 2. Definition of Done

- [x] Ursache benannt — als Herleitung, nicht gemessen (Planner-Entscheidung zur Closure, Anlass: Verifikation F-1; die Ursache ließ sich lokal nicht herstellen, die CI-Last ist nur in CI erzeugbar): Budget zu knapp **oder** Test-Gleichzeitigkeit höher als die reale Nutzung (der Hook ruft einen Prozess je Tool-Call); §7 nennt, was gemessen ist und was nicht. Wird das Budget erhöht, ist der Beleg die Worst-Case-Rechnung `lockTries` × `lockWait` gegen den Hook-`timeout` von 5 s in `.claude/settings.json` (Budget deutlich darunter, damit fail-open vor dem Kill greift) — **nicht** `make hook-overhead`, das unbeanspruchte Aufrufe misst; die Zahl und ihre Grenze stehen als Kommentar der Klasse *Grenze* (`AGENTS.md` §3.7) an den Konstanten, nicht in der Spec.
- [x] Die gewählte Änderung (Budget in `internal/span/emit.go` oder Test-Gleichzeitigkeit in `internal/span/span_test.go`) lässt `TestConcurrentEmittersGetDistinctSeq` unter erzeugter Last (mehr Goroutinen/`-cpu`-Druck als der Runner) wiederholt grün, ohne den Test schwächer zu machen; `n` im Test bleibt 8 oder steigt. **Keine Wirkungs-Aussage** (Planner-Entscheidung zur Closure, Anlass: Verifikation F-2): der Test unterscheidet 200 von 750 nicht, die Wirkung am CI-Anlass (Shard 7) ist erst durch einen CI-Lauf auf einem Commit ab `33ebb12c` belegbar und bleibt Beobachtung, nicht Teil dieses Punktes. Trägt nur die Test-Gleichzeitigkeit die Last, ändert sich das Budget nicht (die Messung entscheidet).
- [x] Rot gesehen: das Sperr-Budget testweise auf einen Versuch gesenkt färbt **denselben** Test rot mit „Sperre nicht erhalten“ — die Eigenschaft ist gebunden, nicht nur der heutige Wert.
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
| `internal/span/emit.go` | update (falls Budget) | `lockTries`/`lockWait`, ein Konstanten-Wert |
| `internal/span/span_test.go` | update (falls Test) | Gleichzeitigkeit `n` des Tests, nach [`LH-FA-16`](../../../../spec/lastenheft.md#lh-fa-16--betrieb-und-bestand-der-erfassung) |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner; Reihenfolge nach `slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung` und `slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke` (WIP-Limit 1). A2 ist entschieden (§1). **Erfüllter Zustand:** beide Vorgänger liegen in `done/` (Beleg: `ls docs/plan/planning/done/slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung.md docs/plan/planning/done/slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke.md`), `in-progress/` trägt danach nur `roadmap.md` (`ls docs/plan/planning/in-progress/`), WIP-Limit frei.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Messung eine zweite Ursache zeigt (z. B. `tryLockExclusive` selbst).
- `in-progress` → `open` (blockiert): wenn die Worst-Case-Rechnung kein Budget unter dem Hook-`timeout` zulässt — dann ist der Architect erneut zu fragen.

## 5. Closure-Trigger

DoD vollständig; der Test in zehn aufeinanderfolgenden Läufen unter erzeugter Last grün (Aufruf in §7 genannt); Review ohne blockierenden Befund; Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Der Fix verschiebt die Last-Schwelle nur — **Ausgang:** weiter offen → [`BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`](../observations/BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last/observation.md) (neue Beobachtung, 1 Beleg). Nicht an `neue-isolation-entzahnt-bestehende-waechter`: der Grün-Vorlauf fällt an Last, keine Isolation und keine vorgelagerte Hürde macht einen Zahn stumm.
- Ein sterbender Worker lässt die übrigen Fälle ohne Ergebnis (32 von 65) — **Ausgang:** weiter offen → dieselbe Beobachtung (Symptom der Klasse); kein Slice, solange das Sterben nicht ohne roten Grün-Vorlauf eintritt.
- Docker-Aussetzer des Hosts (Tag-Kollision der Worker, colima `Unavailable`) verfälschen die Messung — **Ausgang:** entfallen — die Messung ist ein Go-Test (`make test-go`, gezielte Einzelläufe von `TestConcurrentEmittersGetDistinctSeq`), kein `make mutate`-Mehrfachlauf; ein Docker-Fehler im Lauf ist ein Wiederholungsgrund, kein Messwert (der Abbruch des Verifiers bei `--cpus 0.25` ist nicht als Messwert geführt).
- Budget-Erhöhung verlängert den Worst-Case des Hooks — **Ausgang:** entfallen — als Überschreitung nicht eingetreten, der Preis ist gerechnet: `750 × 2 ms = 1,5 s` nominal gegen 5 s Hook-`timeout` (30 %); der fail-open greift vor dem Kill, solange die Schlafzeit sich um weniger als das 3,3-fache dehnt (5 s / 1,5 s). Gemessen ist nur die Dehnung 1,4× im CI-Fall; darüber liegt keine Messung, und der Kommentar an den Konstanten nennt es als Grenze.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).
**Rolle:** Planner · **Datum:** 2026-10-16

- **Was hat funktioniert:** Gebaut ist der Budget-Zweig: `lockTries` 200 → 750 in `internal/span/emit.go`, `span_test.go` unberührt (`n = 8`). Review: 0 HIGH, 2 MEDIUM, 2 LOW, 1 INFO; MEDIUM-1 und beide LOW im Implementer-Commit `33ebb12c` behoben (Kommentar nennt Preis, fail-open-Ort und Grenze des Tests), MEDIUM-2 betraf den DoD-Wortlaut. **Gemessen** (Verifikation `…-verify`, HEAD `33ebb12c`): Rot gesehen — `lockTries = 1` färbt denselben Test 10 von 10 rot, 68× `Sperre nicht erhalten`; der Test bindet die Eigenschaft, nicht den Wert. Test mit 750 unter erzeugter Last grün (`-count=10`, Container `--cpus 1`, 16 Busy-Loops: `ok 2.111s`; `-count=15`, 40 Loops: `ok 3.002s`); Worst-Case `750 × 2 ms = 1,5 s` = 30 % des 5-s-Hook-`timeout` (`grep -n timeout .claude/settings.json`). `make gates` Exit 0, Stempel == HEAD, `make docs-check` 0 Befunde.
- **Was ging anders als geplant:** Zwei DoD-Punkte trugen mehr, als die Beleglage hergibt. **(1) „Ursache gemessen" ist nicht erfüllt:** die Ursache ließ sich lokal nicht herstellen, `lockTries = 200` war unter derselben Last grün; die CI-Zeile (0,57 s Wanduhr für nominal 0,4 s Budget, Dehnung ≈ 1,4×, vier Worker im selben Vorlauf) stützt die Herleitung *Last verlängert die Schlafzeit*, misst aber kein Budget-Defizit. **(2) Keine Vorher/Nachher-Aussage:** der Test unterscheidet 200 von 750 nicht. Der Planner hat den Wortlaut von D1 und D2 deshalb im eigenen Commit `e0af9497` auf das Belegte gezogen (Ursache *benannt*, nicht gemessen; keine Wirkungs-Aussage) und die Häkchen erst danach gesetzt — kein Punkt ist als gemessen abgehakt, der es nicht ist. **Nicht belegt und so geführt:** die Wirkung am CI-Anlass (Shard 7 grün auf einem Commit ab `33ebb12c`); alle geplanten `mutate`-Läufe seit 2026-10-11 sind `failure`, kein Lauf liegt auf einem Commit mit 750; der CI-Branch (`make mutate-auswahl` → Exit 10) ist nicht gepusht, die Mutations-Fälle auf `emit.go` unter 750 sind damit unbelegt. **Rückführung nach `open` geprüft und verworfen:** §4 nennt sie nur für den Fall, dass das Budget unter dem Hook-`timeout` nicht zulässig ist; es ist zulässig. Der fehlende CI-Beleg hängt an einem Push, der nicht freigegeben ist; ein Slice, der darauf wartete, hielte das WIP-Slot für eine Wirkung, die nur die Folgezeit zeigt — sie steht als Beobachtung mit Auflösungs-Prüfung im Register.
- **Steering-Loop-Eintrag:** **benannte Spec-Lücke** — `SPEC-060` und `SPEC-063` nennen kein Sperr-Budget, sodass die Zusage *Sperre wird erhalten* ohne Zahl und ohne Grenze dasteht (§Berührte Spec-Stellen); Architect-Verdikt A2 entschied bewusst ohne Spec-Satz, die Zahl und ihre Grenze stehen als Kommentar an den Konstanten. Die Lücke bleibt benannt, nicht geschlossen. Zweiter Lerneintrag, **geschärfte Regel nur als Beobachtung**: ein DoD-Punkt „Ursache gemessen" verlangt eine Messstelle, die der Lauf erreicht; ist sie nur in CI erreichbar, nennt der Plan vorab, was lokal belegbar ist (Eigenschaft gebunden, Rechnung) und was nicht (Wirkung) — hier hat erst die Verifikation den Unterschied sichtbar gemacht. Wird auf Beobachtung geführt, nicht verkörpert (kein Zielort-Feld).
- **Beobachtungs-Register (`../observations/`):**
  - Neu: [`BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`](../observations/BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last/observation.md) — 1 Beleg (`evidence/slice-span-sperre-haelt-den-test-unter-last.md`), `offen`. Auflösungs-Prüfung: der nächste geplante `mutate`-Lauf auf einem Commit ab `33ebb12c`; Shard 7 grün belegt die Wirkung, rot am Span-Test führt die Annahme *Budget* zurück.
  - **Kein Beleg:** `BEO-ALL/neue-isolation-entzahnt-bestehende-waechter` (bleibt 2×) — §8 nannte ihn als Treffer; ein lastabhängiger Grün-Vorlauf ist weder eine Isolation noch eine vorgelagerte Prüfstufe, die den Zahn eines Falls stumm macht. Die Grenze, die der Vorgänger-Beleg schon dehnte, wird nicht ein zweites Mal gedehnt.
  - **Kein Beleg:** `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers` — das CI-Symptom war `Sperre nicht erhalten`, nicht `No such image`; nicht aufgetreten.
  - `make register-ausgang`: kein Eintrag mit ≥ 3 Belegen berührt.
- **Folge-Slices:** keiner. Der Folge-Beleg (CI-Lauf) ist Beobachtung, kein Slice; sichtbar macht einen roten Grün-Vorlauf als Nächstes `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log`.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR-Re-Evaluierungs-Trigger: keiner berührt. Hard Rules: keine mit eingetretenem Auflösungs-Trigger.
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice` ist nicht gebaut).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer: [`BEO-ALL/neue-isolation-entzahnt-bestehende-waechter`](../observations/BEO-ALL/neue-isolation-entzahnt-bestehende-waechter/observation.md) (1 Beleg, offen) — Isolationsform macht einen Wächter stumm bzw. rot; hier fällt der Grün-Vorlauf in der Isolationskopie unter Last. Der Slice hebt den Zähler nicht selbst; ob das Last-Flake ein zweiter Beleg ist, ordnet die Closure zu. Sonst keine Treffer.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
