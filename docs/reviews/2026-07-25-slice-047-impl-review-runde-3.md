# Review-Report: slice-047 — Impl-Review Runde 3 (eng begrenzt) — 2026-07-25

**Review-Art:** Code — geprüft gegen Plan (slice-047 DoD 2/3), `AGENTS.md`
Hard Rule 3.6 („keine Zusage ohne rot gesehenes Gegenbeispiel") und die
Findings-Auflösungen der Runden 1/2.

**Gegenstand:** `b42cf28` (Vor-Stand `8c3e095`) — **nur zwei Flächen**:

1. der neue ABBRUCH-Pfad in `harness/tools/mutate.sh` (`run_case`, `:294-303`);
2. der neue bats-Wächter `test/mutate-driver.bats:160-180` **und** der
   zugehörige Mutations-Fall `test/mutations/76-mutate-mittenpruefung.sh`.

Isolation als solche, Doku-Sätze, die übrigen Wächter und die Fälle 72–75 waren
**nicht** Auftrag; was dort auffiel, steht als INFO mit einem Satz in den
Negativbefunden.

**Skill:** `.harness/skills/reviewer.md` @ b42cf28 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-25

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- `docs/plan/planning/in-progress/slice-047-mutate-host-isolation.md` (DoD 2, DoD 3)
- `docs/reviews/2026-07-25-slice-047-impl-review.md`, `…-runde-2.md`
- `docs/reviews/2026-07-25-slice-047-verification.md`, `…-runde-2.md` (R2-2 wörtlich)
- `AGENTS.md` (Hard Rules, insb. 3.6)

**Mess-Grundlage dieses Laufs** (READ-ONLY, kein `make`, keine Host-Toolchain):

| Frage | Messung |
|---|---|
| Aufrufkontext von `run_case` | `grep -rn run_case` → einziger Aufruf `mutate.sh:437`, plain in `for`-Schleife; `main "$@"` `:458` plain; `Makefile:mutate` = `@bash harness/tools/mutate.sh` (keine Pipe); `ci.yml:72` = `run: make mutate` (keine Pipe) |
| `exit` aus Funktion + EXIT-Trap | hermetische Sonde: `exit 1` aus verschachtelter Funktion beendet das ganze Skript, Trap läuft, Status bleibt `1` |
| Subshell-Kontexte | hermetische Sonde: in Pipeline / `$( )` / `( )` beendet `exit` **nur** die Subshell (ohne `set -e` läuft die Pipeline-Variante mit rc=0 weiter) |
| `return` vs. `exit 1` als Endstatus | `bash -c 'f(){ echo msg; return; }; f'` → Status **0**; mit `exit 1` → Status **1** |
| bats-Container-Inventar | `bats/bats@sha256:e8f18e0a…`: `make` **FEHLT**; `sed -i`, `tar`, `sha256sum`, `sort -z`, `xargs -0`, `mktemp` vorhanden (direkt gemessen) |
| Anker-Eindeutigkeit Fall 76 | `case_now` erscheint in `mutate.sh` nur `:292/:293/:294`; `case_now" != "` genau einmal (`:294`) |
| Meldungs-Eindeutigkeit | `Isolation gebrochen` im Code genau einmal (`:295`), im Test einmal (`:179`) |

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

<!-- Kein Fließtext, kein Lösungsvorschlag im Befund. -->

### F-1 — der ABBRUCH selbst ist unbewacht: `exit 1` → `return` bleibt grün

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` Hard Rule 3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel)
- `pfad`: `harness/tools/mutate.sh:302` · `test/mutate-driver.bats:175-179` · `test/mutations/76-mutate-mittenpruefung.sh:15`
- `befund`: Der Abbruch ist die **neue Verhaltens-Zusage dieses Commits** (Runde-2-F-4, im Kopf als Bedingung 5 „-> Befund und ABBRUCH" `:49-51` zugesagt), hat aber kein Gegenbeispiel. Der bats-Wächter prüft ausschließlich `[[ "$output" == *"Isolation gebrochen"* ]]` und **nicht** `$status`; Fall 76 trifft die Vergleichszeile `:294`, nicht die Abbruch-Zeile `:302`. Ersetzt jemand `exit 1` durch `return`, bleiben Meldungstext und Test unverändert grün, während die Schleife `:436-438` weiterläuft und die Folgefälle wieder gegen den Host mutieren — genau der Zustand, den F-4 beseitigt hat. Gemessen: `bash -c 'f(){ echo msg; return; }; f'` liefert Status 0, mit `exit 1` Status 1 — die Unterscheidung ist am `run`-Status **beobachtbar**, wird aber nicht beobachtet.
- `verifizierbar`: ja — `make mutate` mit einem Fall, der `:302` auf `return` dreht (eindeutig ankerbar über die Adresse `/Betroffen: /,+2`, da `Betroffen` `:300` einmalig ist, während `^    exit 1$` auf `:302/:377/:395/:402` viermal steht); heute bliebe `make test` dabei grün.

### F-2 — die zugesagte Reihenfolge („vor dem Sensor", „vor Bedingung 2") ist von der Fixture nicht gemessen

- `kategorie`: LOW
- `quelle`: Maintainability / Hard Rule 3.6 (Zusage vs. Abdeckung)
- `pfad`: `test/mutate-driver.bats:167` (Testname) · `harness/tools/mutate.sh:289-291` (Kommentar) · `test/mutate-driver.bats:175-179` (Fixture)
- `befund`: Der Testname trägt „**bevor er den Sensor faehrt**" und der Code-Kommentar `:289-291` erklärt die Position als tragend („Steht VOR Bedingung 2 … sonst feuerte zuerst ‚Mutation hat nicht gegriffen'"). Die Fixture setzt `WORK` und `REPO` auf **dasselbe** Verzeichnis; die Fall-Mutation ändert damit Host **und** Kopie, Bedingung 2 (`:313-323`) wäre also ohnehin erfüllt. Verschöbe jemand die Mitten-Prüfung hinter Bedingung 2, bliebe der Test **grün**. Die Rückfall-Gestalt, für die der Kommentar die Reihenfolge begründet (Sed trifft `$REPO`, die Kopie bleibt unverändert), ist in der Fixture nicht darstellbar, weil Host und Kopie zusammenfallen. Nur die Sensor-Hälfte der Zusage ist gedeckt, und das beiläufig (im Container fehlt `make`, die verschobene Prüfung würde vom `falscher Grund`-Zweig `:344-349` überholt).
- `verifizierbar`: ja — eine zweite Fixture mit getrenntem `WORK`/`REPO`, deren Fall nur die `REPO`-Datei sedet: heute meldet `run_case` „Isolation gebrochen", nach einer Verschiebung hinter Bedingung 2 „Mutation hat nicht gegriffen".

### F-3 — Abbruch und normaler Befund-Fehlschlag sind am Exit-Code nicht unterscheidbar

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `harness/tools/mutate.sh:302` vs. `:453`
- `befund`: Der Abbruch endet mit `exit 1`, der reguläre Fehlschlag über `[ "$fail_count" -eq 0 ]` ebenfalls mit 1. Ein Konsument (`ci.yml:72`, `Makefile`) kann „ein Wächter hat Zähne verloren" nicht von „der Host-Baum ist möglicherweise beschädigt, brich ab und sieh nach" trennen; im Abbruch-Fall entfällt zudem die Summenzeile `:452`, sodass die Unterscheidung nur an der stderr-Formulierung hängt. Die übrigen Abbruch-Wege des Treibers (`:377/:395/:402/:424/:431`) nutzen denselben Code — die Gleichbehandlung ist konsistent, aber nirgends als Entscheidung notiert.
- `verifizierbar`: ja — Code-Lesen; kein Gate misst Exit-Codes jenseits von 0/≠0.

### F-4 — die Reichweite des Abbruchs hängt am Aufrufkontext, ohne dass eine Schranke oder ein Kommentar das hält

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `harness/tools/mutate.sh:302` · `:436-438`
- `befund`: `exit` beendet den Treiber nur, weil `run_case` plain in der `for`-Schleife steht. Hermetisch gemessen: in einer Pipeline, in `$( )` oder `( )` beendet dasselbe `exit` nur die Subshell (ohne `set -e` lief die Pipeline-Variante mit rc=0 weiter). Der Ist-Stand ist sauber (`:437` plain, `Makefile` ohne Pipe, `ci.yml` ohne Pipe, `set -o pipefail` `:65` als zweites Netz), aber die Kern-Wirkung „Folgefälle laufen nicht weiter" trägt an dieser Stelle keinen Kommentar — anders als die vergleichbare Stelle `:156-160`, wo genau diese Klasse („eine Zusage, die nur durch Reihenfolge gilt, ist keine") ausformuliert ist.
- `verifizierbar`: ja — Code-Lesen plus die Sonde oben.

## Negativbefunde

<!--
Eine Zeile pro betrachtetem Bereich. Ohne diesen Block ist "keine
Findings" nicht von "nicht geprüft" unterscheidbar (Modul 10
§Reviewer berichtet auch, was er nicht gefunden hat).
-->

### Abbruch-Pfad (`mutate.sh:294-303`)

- geprüft, ohne Befund: **`exit 1` verlässt wirklich den ganzen Treiber.** `run_case` wird nur an einer Stelle gerufen (`:437`), plain in der `for`-Schleife, nicht in Pipeline/`$( )`/`( )`; `main "$@"` `:458` ebenfalls plain; `Makefile` fährt `@bash harness/tools/mutate.sh` ohne Pipe, `ci.yml:72` `run: make mutate` ohne Pipe. Hermetische Sonde bestätigt: `exit` aus einer verschachtelten Funktion beendet das Skript. Der befürchtete „nur die Subshell stirbt, der Lauf geht weiter"-Fall liegt **nicht** vor (Rest-Risiko → F-4).
- geprüft, ohne Befund: **der EXIT-Trap läuft und räumt vollständig.** Sonde: der Trap feuert beim `exit 1` aus der Funktion, und der Status bleibt `1` (die Trap-Funktion ruft selbst kein `exit`). Reihenfolge stimmt: der Zweig ruft `restore` `:301` (untar in `$WORK`, `rm -rf "$BACKUP"`, `BACKUP=""`), danach `cleanup` `:169-176` → `restore` als No-op (`[ -n "$BACKUP" ] || return 0`) → `rm -rf "$ISO_ROOT"` → `rmdir "$LOCK"`. Es bleibt **kein** Lock, **kein** `$BACKUP`, **kein** Temp-Verzeichnis liegen; `cleanup` endet auf `return 0`, die `&&`-Kurzschlüsse können unter `set -e` also keinen Abbruch der Aufräumung auslösen.
- geprüft, ohne Befund: **`restore` vor `exit 1` ist nicht irreführend, sondern doppelt nützlich.** Die zwei Zeilen darüber `:296-298` sagen wörtlich, dass es für den Host **kein** Restore gibt („das Backup liegt in der Kopie"), der Code redet die Lage also nicht schön. Der Aufruf leistet zweierlei: er entfernt `$BACKUP` (sonst Temp-Leck), und im Total-Kollaps `WORK == REPO` — der Gestalt, die diesen Zweig überhaupt auslöst — spielt er die Datei dieses Falls in genau den beschädigten Baum zurück. In der Nicht-Kollaps-Gestalt schreibt er in eine Kopie, die `cleanup` gleich darauf wegwirft: wirkungslos, nicht falsch.
- geprüft, ohne Befund: **R2-2 aus Runde 2 ist geschlossen.** Die Fall-Meldung `:295` spiegelt jetzt die Formulierung der fünften Bedingung `:449` („Isolation gebrochen, **oder parallel editiert**"), und die Prüfung ist fall-lokal (`case_before` `:262` / `case_now` `:293`) — ein paralleler Edit an einer *fremden* Zieldatei bricht den Lauf nicht mehr ab.

### bats-Wächter + Fall 76

- geprüft, ohne Befund: **die Fixture `WORK == REPO` ist eine faire Nachbildung**, kein Kunstzustand. Sie modelliert exakt das Vor-Isolations-Verhalten, das `:280-282` als Rückfall beschreibt (Sed und Restore laufen beide gegen `$REPO`); genau dann fallen Host und Kopie zusammen. Dass `require_isolated` `:406` diesen Zustand in `main` vorher abfinge, entwertet den Test nicht — `run_case` ruft die Schranke selbst nicht, der Test prüft also dessen eigene Verteidigung. (Zur *anderen* Rückfall-Gestalt siehe F-2.)
- geprüft, ohne Befund: **das Szenario erreicht den geprüften Zweig wirklich** — die dreimal aufgetretene Klasse (`pipefail`, leerlaufendes Glob, vorgelagerte Nicht-Leer-Assertion) liegt hier nicht vor. Der geprüfte String `Isolation gebrochen` existiert im Treiber genau einmal (`:295`) und ist nur über diesen Zweig erreichbar; alle vorgelagerten Schranken sind in der Fixture erfüllt (kein Doppelkopf, `# files:`+`# expect:` gesetzt, `verify` defaultet auf `test`, `failure_form test` liefert ein Muster, `tar`/`sha256sum` greifen, `sed -i` wirkt — im Container direkt gemessen). Schlüge eine davon fehl, verschwände der String und der Test wäre **rot**, nicht falsch grün.
- geprüft, ohne Befund: **die Textkopplung `*"Isolation gebrochen"*` fällt in die sichere Richtung.** Formuliert jemand `:295` um, wird der Test rot (falscher Alarm), nicht still grün. Zusätzlich ist der Testname zugleich das `# expect:` von Fall 76, sodass eine Umbenennung ihrerseits über Bedingung 4 auffällt.
- geprüft, ohne Befund: **das fehlende `make` im Container verfälscht das Ergebnis nicht.** Im Soll-Zustand kehrt `run_case` vor jedem `make`-Aufruf zurück, der Test ist also von `make` unabhängig. Unter Fall 76 läuft er weiter bis `:328`; `make` fehlt (gemessen) und im Fixture-Verzeichnis gibt es ohnehin keinen `Makefile`, also rc≠0 → Bedingung 4 greift nicht → Meldung „falscher Grund" **ohne** den geprüften String → Test rot **aus dem beabsichtigten Grund**, ohne Hänger und ohne Rekursion.
- geprüft, ohne Befund: **Fall 76 bricht Verhalten, nicht das Kompilat.** `sed -i 's/case_now" != "/case_now" = "/'` dreht eine Bedingung, das Skript bleibt syntaktisch und shellcheck-seitig intakt (kein `$` im Muster → kein SC2016), und `make test` (bats + Go-Tests) prüft ohnehin nicht die Shell-Syntax. Genau ein Test wird rot; `# expect: run_case meldet einen HOST-Treffer` ist Präfix des bats-Testnamens und trifft damit die `not ok [0-9]+`-Fehlschlagform.
- geprüft, ohne Befund: **der Anker ist heute eindeutig und bleibt es bei einer zweiten Vergleichszeile ausreichend spezifisch.** `case_now` ist `local` (`:292`) und erscheint nur `:292-294`; `case_now" != "` genau einmal. Eine zweite `!=`-Zeile mit demselben fall-lokalen Namen würde mitmutiert — das bliebe eine Verhaltens-Mutation am selben Wächter, nicht die slice-037-Unspezifik (dort wurde ein *generischer* Anker durch ein gleichlautendes Konstrukt breit).
- geprüft, ohne Befund: **die Fixture hinterlässt nichts.** `rm -rf "$iso"` `:178` steht vor der Assertion; `$BACKUP` räumt `restore` vor dem `exit`; im gesourcten `bash -c` sind `ISO_ROOT` und `HAVE_LOCK` leer, `cleanup` fasst also weder ein Temp-Verzeichnis noch den Lock des echten Repos an. Der Repo-Mount ist in `make test` ohnehin `:ro`.

### Außerhalb des Auftrags aufgefallen (je ein Satz, nicht bewertet)

- INFO: `require_isolated` ist `:156` als „Schranke VOR jedem Zugriff auf `$WORK`" beschrieben, wird aber nur einmal in `main` `:406` gerufen — nicht in `run_case`, das mehrfach auf `$WORK` zugreift.
- INFO: Fall 72 ankert auf `s/^      return 1$/      return 0/`, also auf Einrückungstiefe statt auf einen benannten Kontext — heute eindeutig, aber von derselben Klasse wie die re-verankerten Fälle 17/76.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 2 |

## Verdikt

**NICHT KONFORM** — bezogen auf die beiden geprüften Flächen.

**Merge-blockierend:** ja — wegen F-1 (MEDIUM). Der Abbruch ist die neue
Zusage dieses Commits und trägt kein rot gesehenes Gegenbeispiel; das ist
dieselbe Lücke, die Runde 2 für die Mitten-Prüfung selbst als F-1 aufmachte
(„der einzige unbewachte Wächter des Slice"), nur eine Zeile tiefer. Sie ist
mit einer Assertion (`$status`) und einem Fall (Anker `/Betroffen: /,+2`)
schließbar; die Begründung „nicht darstellbar" trägt hier so wenig wie in
Runde 2, weil die Unterscheidung `exit 1` / `return` am `run`-Status
gemessen wurde.

F-2 (LOW) blockiert nicht, gehört aber in denselben Fix: der Testname sagt
mehr, als die Fixture misst.

**Der ABBRUCH-Pfad selbst ist mechanisch in Ordnung** — `exit` greift, der
Trap räumt vollständig, es bleibt kein Residuum, und `restore` vor `exit`
ist weder irreführend noch schädlich. Der Befund betrifft die **Abdeckung**,
nicht die Konstruktion.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
