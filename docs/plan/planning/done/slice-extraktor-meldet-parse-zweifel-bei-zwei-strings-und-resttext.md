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

- [x] **Extraktor:** beide Fassungen beenden die zwei Eingaben aus §1 mit Exit 3 (Prüfung: zwei Zeichen-Zustände nach String-Ende — `"` sofort danach, oder ein Zeichen außerhalb von `: , } ]` und Leerraum). Die Nicht-Kommentarzeilen beider Fassungen sind gleich (`diff <(grep -v '^#' a) <(grep -v '^#' b)` leer; einmalige Messung, kein Sensor).
- [x] **Probenmenge:** `test/guard.bats` führt je Fassung (Schleife über beide Pfade) die zwei Eingaben als Exit ≠ 0 und die Regressionsproben (Zeilenumbruch zwischen Tokens, `\n`/`\"`-Escapes, Unicode, Literale `1`/`true`/`null`, Folgefelder, bestehende Extraktor-Proben) als unverändert grün; ein Guard-Fall zeigt `block` für die erste Eingabe. Rot-Beleg an der **realen** Quelle: je Fassung ein Fall in `test/mutations/` (nimmt die Prüfung aus dem Extraktor heraus, erwartet den neuen Bats-Fall rot), dazu die Vorher-Messung (Exit 0 beider Eingaben, §1) und die Nachher-Messung (Exit 3) im Abschlussbericht, gemessen im `BATS_IMAGE`.
- [x] **Nachzug:** der Kopfkommentar von `.claude/hooks/pretooluse-command-guard.sh` und der emittierten `pretooluse-command-guard.sh` sowie der Kopf beider Extraktoren nennen die zwei neuen Parse-Zweifel-Klassen; `git grep -n 'extract-command' docs/user` auf eine Aussage geprüft, die die Klassen aufzählt.
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

**Gegenstand: geliefert.** Beide Fassungen des Extraktors beenden `…"command":"pip x""make gates"…` und
`…"command":"a" garbage …` mit Exit 3 und leerer Ausgabe; die Probenmenge hält es je Fassung.

**DoD-Verdikt** (Verifier-Report `2026-10-21-slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext-verify`,
[Report](../../../reviews/2026-10-21-slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext-verify.md)).
(1) Extraktor bestätigt — Vorher (`0181e351`, beide Fassungen, busybox-awk 1.36.1 im `BATS_IMAGE`): beide
Eingaben Exit 0 mit Ausgabe `make gates` bzw. `a`; HEAD: Exit 3 in beiden Fassungen, 10 wohlgeformte
Eigenproben Exit 0; Code-Zeilen beider Fassungen gleich (Einmalmessung, kein Sensor). (2) Probenmenge
bestätigt — `test/guard.bats` 32 Fälle grün, Schleife über `$EXTRACT` und `$EMIT_EXTRACT`; Fälle 780 bis 783
je rot gegen den benannten Test, `make mutate-greift` 769/769. (3) Nachzug bestätigt — beide Guard-Köpfe und
beide Extraktor-Köpfe nennen die zwei Klassen; `git grep -n 'extract-command' docs/user` trägt keine
Aufzählung der Klassen.

**Review** (`2026-10-21-slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext`,
[Report](../../../reviews/2026-10-21-slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext.md)):
0 HIGH, 0 MEDIUM, 1 LOW, 3 INFO. F1 (Grenze der emittierten Guard-Fassung am Ort) behoben; F3
(Falsch-Positiv-Richtung ohne Fall) behoben durch die Fälle 782/783; F2 (Rest hinter dem Wurzelobjekt bleibt
Exit 0) ist der Plan-Ausschluss aus §1; F4 INFO.

**Plan-vs-Code** (Abnahme bleibt wie geschrieben). Über §3 hinaus: die Fälle 782 und 783
(`test/mutations/`, Marke `afterstr` bleibt gesetzt) — §3 nennt zwei Fälle, gebaut sind vier; und die
Grenze der emittierten Guard-Fassung am Ort (Guard-Fall-Kommentar, Kopf des Vorlagen-Guards). Plan ohne
Code: nichts.

**Messung** ([`MR-089`](../../../../harness/conventions.md#mr-089)): keine neue Laufzeit- oder
Kosten-Aussage; die Exit-Messungen stehen im Verifier-Report mit Image (`BATS_IMAGE`, busybox 1.36.1,
`--network none`). **Normbeleg fehlt:** Implementer, Reviewer und Verifier liefen auf macOS
([`AGENTS.md`](../../../../AGENTS.md) §3.9); die CI auf frischem Klon nach dem Push des Closure-Stands
liegt bei Abschluss dieser Notiz nicht vor.

**Trigger-Audit.** [`ADR-0004`](../../adr/0004-durchsetzungs-emission.md) Festlegung 2 (Extraktor
fail-closed) berührt: nichts fällig, die Festlegung wird durch den Slice gehalten, nicht verschoben. Kein
Carveout berührt; kein bootstrap-aware Gate; keine Hard Rule mit Auflösungs-Trigger berührt.

**Steering-Loop-Eintrag (neuer Sensor + benannte Lücken).** Klasse *Wächter-Zusage fail-closed deckt nur
eine Auswahl der Parse-Zweifel-Eingaben*: die Zusage „bei Parse-Zweifel block" stand im Kopf, der Scanner
prüfte aber nicht, welches Zeichen nach einem String-Ende folgen darf; ein Adopter fand die Lücke, kein
Sensor des Repos. Neuer Sensor: die Schleifenfälle in `test/guard.bats` über beide Fassungen und die
Mutations-Fälle 780 bis 783 (`test/mutations/`). **Benannte Lücken:** (a) kein Lauf-Zahn im Ziel —
`full-smoke` hat keine Stufe, die einen realen emittierten Guard mit Parse-Zweifel-Eingabe fährt, die
emittierte Fassung ist nur über den Vorlagen-Extraktor gedeckt; (b) gawk und mawk ungemessen, der Kopf sagt
„POSIX-awk (busybox/gawk/BSD)", gemessen sind busybox 1.36.1 und BWK 20200816 (Host, kein Normbeleg);
(c) Rest hinter dem Wurzelobjekt und Syntaxfehler ohne vorangehenden String bleiben Exit 0
(Plan-Ausschluss, §1); (d) der Vergleichs-Sensor der zwei Fassungen liegt bei
[`slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor`](../open/slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor.md).
Nichts davon ist an einem Zielort mit Anker verkörpert; der Eintrag ist gezählt, nicht verkörpert.

**Beobachtungs-Register** (`../observations/`). Zwei Belege ergänzt:
`evidence/slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext.md` in
[`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
(Zähler damit 6×; die Fassungen waren nicht byte-gleich, die Gleichheit der Code-Zeilen hielt nur eine
Handmessung; Ausgang `geplant` bleibt, die Schwelle war überschritten) und in
[`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
(Ausgang des dritten Risikos aus §6 und die Lücke ohne Lauf-Zahn im Ziel; Ausgang `verkörpert` bleibt).
Kein Beleg: `BEO-ALL/neuer-waechter-ohne-mutations-fall` — der Slice liefert die Fälle mit;
`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` — die Proben laufen über die reale Datei der
Vorlage (go:embed), keine nachgebaute Eingabe; die Lücke ohne Lauf-Zahn im Ziel zählt unter
`emittierte-zusage-…`, ein Vorgang zählt einmal. `BEO-ALL/waechter-satz-stelle-ohne-mutationsfall-und-ohne-byte-gleichheit`
bleibt bei 2×, kein dritter Beleg. Lese-Schritt: die Überschreitungen der Schwelle stehen mit Ausgang in ihren `state.md`; kein Eintrag erreicht neu 3×.

**Offene Frage an den Auftraggeber (Architect-Entscheidung).** Das Repo kennt keine Eingangsform für
Change Requests von Adoptern; der Planner hat im Schnitt keine angelegt. Offen: ob eine Eingangsform
entsteht (Architect). Die Antwort an den Absender des Change Requests
`2026-10-21-cr-ai-harness-init-guard-extraktor-parse-zweifel` (Datei im Repo des Adopters) ist Sache des
Auftraggebers; in dieses Repo schrieb die Closure nichts, in das andere keine Zeile.

**Auslieferung.** Die emittierte Fassung reist im Produkt-Binär; Zielrepos sehen sie mit dem nächsten
Release, `v0.10.0` bleibt unverändert.

**Risiken aus §6:** Falsch-Positive — entfallen, gedeckt durch Test 10 der Schleife, die Fälle 782/783 und
die 10 Eigenproben des Verifiers. Drift der Fassungen — eingetreten →
[`slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor`](../open/slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor.md).
Host-awk-Varianten — weiter offen → Register `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (Beleg oben).

**Folge-Slices:** [`slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor`](../open/slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor.md)
— ist eine Datei in `open/`.

**Paarungen geprüft am 2026-10-21** (nach dem `git mv`): (a) Anker — das Feld des Eintrags steht in §7
nicht (Zählung über §7 → **0**), nichts zu paaren; (b) Folge-Slice — `ls
docs/plan/planning/open/slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor.md` findet
die Datei; (c) Register — beide genannten Verzeichnisse existieren, `ls …/evidence/*.md | wc -l` → **6**
(`zwei-fassungen-…`) und **17** (`emittierte-zusage-…`); `make register-ausgang` → `0 Befund(e)`.
**Register-Paarung (c), zweite Hälfte: 1 Verzeichnis ohne Beleg, namentlich
`BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; nicht als getragen behauptet** (Bestand,
nicht aus diesem Slice).

**Archivierung ([`MR-078`](../../../../harness/conventions.md#mr-078)):** nicht vollzogen. Die Vorschau
(`archive-welle --vorschau slice-extraktor-meldet-parse-zweifel-bei-zwei-strings-und-resttext`) nennt
`[untergrenze]` (235 wellenlose Slices flach in `done/`, kein `done/*/archiv.zip`), `[haenger]` (ein
Review-Report mit eingehenden Verweisen) und `[ergebnisnotiz]` (keine `-results.md`); der Altbestand ist
ein eigener Vorgang.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `harness/tools/` (`TOOLS`, Pfad und Konventions-Härte) und das gesamte Repo (`ALL`, die emittierte Fassung unter `internal/emit/templates/`); beide erfüllen mindestens zwei der drei Achsen, keine ist zu grob.

**Vorgelagert — offene Beobachtungen sichten:** Register `docs/plan/planning/observations/` am Stand 2026-10-21 durchgegangen, Zähler = Dateien unter `evidence/`. Treffer in `BEO-ALL/`: `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` (5, `geplant`, Folge-Slice in `open/`; dieser Slice berührt ein weiteres Paar, bringt aber keinen Vergleichs-Sensor); `neuer-waechter-ohne-mutations-fall` (20, `geplant`; dieser Slice liefert die zwei Mutations-Fälle mit); `waechter-misst-die-fixture-statt-der-realen-quelle` (11, `verkörpert`; die Probe läuft über den Template-Pfad); `waechter-satz-stelle-ohne-mutationsfall-und-ohne-byte-gleichheit` (1, `offen`; ein zweiter Beleg wäre möglich, falls ein Satz des Kopfkommentars ohne Fall und ohne Byte-Gleichheit bleibt — erreicht 2×, nicht 3×). Keiner erreicht mit diesem Slice 3× neu.

**Modus:** alle berührten Sub-Areas GF.
