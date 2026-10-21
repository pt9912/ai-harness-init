# Slice slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext: Der Extraktor des Tool-Call-Wächters meldet Parse-Zweifel bei zwei Strings ohne Trenner und bei Resttext hinter einem String

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — keine Closure-Bedingung über die DoD hinaus.

**Bezug:** [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (Guard: *fail-closed bei Parse-Zweifel*), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (bash + awk, kein Zusatz-Dep), [`ADR-0004`](../../../../docs/plan/adr/0004-durchsetzungs-emission.md) (Festlegung 2: Extraktor fail-closed).

**Berührte Spec-Stellen:** —

**Verantwortlich:** dburkard.

**Autor:** Planner. **Datum:** 2026-10-21.

---

## 1. Ziel und Abgrenzung

**Auslöser:** Auftrag des Auftraggebers; Quelle ist der Change Request `2026-10-21-cr-ai-harness-init-guard-extraktor-parse-zweifel` (Absender d-check, Adopter; eine Datei im d-check-Repo, Stand dort *offen — nicht gesendet*). Er benennt zwei Eingaben, bei denen `extract-command.awk` Exit 0 liefert statt Parse-Zweifel.

**Gemessen im Planner-Lauf (2026-10-21):** beide Eingaben, `awk -f harness/tools/extract-command.awk < <datei>`:

| Eingabe | Ausgabe | macOS-Host-awk (BWK 20200816, kein Normbeleg, §3.9) | busybox 1.36.1 im `BATS_IMAGE` (Norm-Beleg) |
|---|---|---|---|
| `{"tool_input":{"command":"pip x""make gates"}}` | `make gates` | Exit 0 | Exit 0 |
| `{"tool_input":{"command":"a" garbage }}` | `a` | Exit 0 | Exit 0 |
| wohlgeformt mit `\n`, `é`, `\"`, Folgefeld (Regressionsprobe) | `ok⏎x é "q"` | Exit 0 | Exit 0 |

Die Ursache liegt im Scanner: nach einem String-Ende prüft er nicht, welches Zeichen folgen darf; ein zweites `"` öffnet still einen neuen String (`cmdval` wird überschrieben), und Buchstaben außerhalb eines Strings werden ignoriert. Kein Aufrufer erreicht das mit wohlgeformtem JSON; verletzt ist die Zusage aus dem Kopfkommentar von `.claude/hooks/pretooluse-command-guard.sh` (*„bei Parse-Zweifel (malformed, abgeschnitten, \u-Escape im Befehl) -> fail-closed (block)"*) und [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) Akzeptanzkriterium *Guard*.

**Ziel:** Der Extraktor beider Fassungen (`harness/tools/extract-command.awk`, `internal/emit/templates/enforce/extract-command.awk`) beendet beide Eingaben mit Exit 3, und die Probenmenge hält es für beide Fassungen.

**Hinweis zur Auslieferung:** Die emittierte Fassung reist im Produkt-Binär; Zielrepos sehen sie erst mit dem nächsten Release, `v0.10.0` bleibt unverändert.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Interpreter-Sperre, Sub-Shell-Rekursion, `\u`-Escape, Exit-Riegel, leeres `PATH` — der Change Request nimmt sie selbst aus (gemessen gleich oder Entscheidung des Generators); andere Vorgänge.
- Ein Vergleichs-Sensor für die zwei Fassungen — `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor` (Datei in `open/`) trägt ihn; die Fassungen weichen heute in Kommentarzeilen ab (Umlaute, ADR-/LH-Verweise), hier gilt nur die Gleichheit der Code-Zeilen, einmal gemessen.
- Resttext hinter dem Wurzelobjekt (`{…} x`) und Syntaxfehler außerhalb von Strings ohne vorangehenden String (z. B. `{"a":1 2}`) — der Change Request nennt nur Resttext hinter einem String; Bestand bleibt stehen, der Guard ist ein Stolperdraht ([`ADR-0004`](../../../../docs/plan/adr/0004-durchsetzungs-emission.md)), und jede Verschärfung erhöht das Falsch-Positiv-Risiko. Misst der Implementer dort ein Fail-open mit Bezug zum Feld `command`, ist das eine neue Beobachtung, kein Mitnehmen.
- Messung unter gawk/mawk — kein gepinntes Image führt sie (§3.9); die Lücke steht in §6.

## 2. Definition of Done

- [ ] **Extraktor:** beide Fassungen beenden die zwei Eingaben aus §1 mit Exit 3 (Prüfung: zwei Zeichen-Zustände nach String-Ende — `"` sofort danach, oder ein Zeichen außerhalb von `: , } ]` und Leerraum). Die Nicht-Kommentarzeilen beider Fassungen sind gleich (`diff <(grep -v '^#' a) <(grep -v '^#' b)` leer; einmalige Messung, kein Sensor).
- [ ] **Probenmenge:** `test/guard.bats` führt je Fassung (Schleife über beide Pfade) die zwei Eingaben als Exit ≠ 0 und die Regressionsproben (Zeilenumbruch zwischen Tokens, `\n`/`\"`-Escapes, Unicode, Literale `1`/`true`/`null`, Folgefelder, bestehende Extraktor-Proben) als unverändert grün; ein Guard-Fall zeigt `block` für die erste Eingabe. Rot-Beleg an der **realen** Quelle: je Fassung ein Fall in `test/mutations/` (nimmt die Prüfung aus dem Extraktor heraus, erwartet den neuen Bats-Fall rot), dazu die Vorher-Messung (Exit 0 beider Eingaben, §1) und die Nachher-Messung (Exit 3) im Abschlussbericht, gemessen im `BATS_IMAGE`.
- [ ] **Nachzug:** der Kopfkommentar von `.claude/hooks/pretooluse-command-guard.sh` und der emittierten `pretooluse-command-guard.sh` sowie der Kopf beider Extraktoren nennen die zwei neuen Parse-Zweifel-Klassen; `git grep -n 'extract-command' docs/user` auf eine Aussage geprüft, die die Klassen aufzählt.
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
| `harness/tools/extract-command.awk`, `internal/emit/templates/enforce/extract-command.awk` | update | Zustand „nach String-Ende" im Scanner: ein weiteres `"` oder ein Zeichen außerhalb von `: , } ]` und Leerraum → `exit 3`; Zustand bei `:` `,` `}` `]` zurücksetzen. Code-Zeilen gleich, Kommentare je Fassung. |
| `test/guard.bats` | update | zwei Eingaben je Fassung rot→grün, Regressionsproben grün, ein Guard-Fall `block`. Die Probe auf den Template-Pfad ist die reale Quelle der emittierten Fassung. |
| `test/mutations/<nächste Nummer>-…` (zwei Fälle) | neu | je Fassung die Prüfung entfernen; erwartet der neue Bats-Fall rot (`make mutate-greift` belegt, dass der Patch greift). |
| beide `pretooluse-command-guard.sh` (Kopfkommentar) | update | Zusage nennt die zwei Klassen. |

## 4. Trigger

**Start** (`next` → `in-progress`): Auftraggeber priorisiert (Empfehlung des Hauptkontexts: vor `slice-113-co-001-ist-faellig`, weil der Wächter in jedem emittierten Ziel mitläuft; `in-progress/` ist leer, WIP 1).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Falsch-Positiv-Regression verlangt mehr als zwei Zeichen-Zustände, oder die Fassungen lassen sich nicht auf gleiche Code-Zeilen bringen.
- `in-progress` → `open` (blockiert — Carveout?): die Regressionsprobe (wohlgeformtes JSON) fällt rot und die Ursache liegt in einem Dialekt-Unterschied zwischen busybox und BWK-awk.

## 5. Closure-Trigger

DoD vollständig, Review konform, Verifikation bestätigt, Closure-Notiz mit Lerneintrag geschrieben; die zwei Eingaben liefern im `BATS_IMAGE` Exit 3, die Regressionsproben bleiben grün.

## 6. Risiken und offene Punkte

- Falsch-Positiv: wohlgeformtes JSON (Leerraum, Zeilenumbruch, Unicode, Escapes, Literale, Folgefelder) wird geblockt — **Ausgang:** entfallen: die Regressionsproben der DoD laufen je Fassung und färben bei einem Falsch-Positiv rot; die bestehende Probenmenge bleibt unverändert grün.
- Die Fassungen driften weiter, weil nur die Code-Zeilen einmal gemessen werden — **Ausgang:** eingetreten: `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor`.
- Im Ziel läuft der awk des Hosts; belegt sind BWK 20200816 (Host des Planners, kein Normbeleg) und busybox 1.36.1 (`BATS_IMAGE`), gawk und mawk sind es nicht — **Ausgang:** weiter offen: → [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) im Register.

## 7. Closure-Notiz

*(bei der Closure zu füllen: Was hat funktioniert · Was ging anders · Steering-Loop-Eintrag · Beobachtungs-Register · Folge-Slices · Risiken aus §6 · Drei Paarungen)*

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `harness/tools/` (`TOOLS`, Pfad und Konventions-Härte) und das gesamte Repo (`ALL`, die emittierte Fassung unter `internal/emit/templates/`); beide erfüllen mindestens zwei der drei Achsen, keine ist zu grob.

**Vorgelagert — offene Beobachtungen sichten:** Register `docs/plan/planning/observations/` am Stand 2026-10-21 durchgegangen, Zähler = Dateien unter `evidence/`. Treffer in `BEO-ALL/`: `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` (5, `geplant`, Folge-Slice in `open/`; dieser Slice berührt ein weiteres Paar, bringt aber keinen Vergleichs-Sensor); `neuer-waechter-ohne-mutations-fall` (20, `geplant`; dieser Slice liefert die zwei Mutations-Fälle mit); `waechter-misst-die-fixture-statt-der-realen-quelle` (11, `verkörpert`; die Probe läuft über den Template-Pfad); `waechter-satz-stelle-ohne-mutationsfall-und-ohne-byte-gleichheit` (1, `offen`; ein zweiter Beleg wäre möglich, falls ein Satz des Kopfkommentars ohne Fall und ohne Byte-Gleichheit bleibt — erreicht 2×, nicht 3×). Keiner erreicht mit diesem Slice 3× neu.

**Modus:** alle berührten Sub-Areas GF.
