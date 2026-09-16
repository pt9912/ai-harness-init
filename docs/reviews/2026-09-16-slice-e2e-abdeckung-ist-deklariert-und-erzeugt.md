# Review `slice-e2e-abdeckung-ist-deklariert-und-erzeugt` — 0 HIGH · 1 MEDIUM · 1 LOW · 1 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-16 · **Geprüfter Stand:** `54184620` (Umsetzung
`ce74fa41` + `54184620`, Basis `c7fb4fb6`, 9 Dateien) · **Review-Art:** Code-Review gegen Plan
+ Konventionen + Hard Rules (§10 Modul 10) · **Nicht Gegenstand:** die DoD-Abhakung (das ist
die Verifikation, Modul 11).

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` · **Modell:** `deepseek-v4.1-flash:cloud[1m]`

**Eingangs-Kontext:** Slice-Plan
`slice-e2e-abdeckung-ist-deklariert-und-erzeugt` (§1 Ziel und Abgrenzung, §2 DoD, §3 Plan,
§6 Risiken) · `LH-QA-01`, `LH-FA-01`, `MR-025` (die drei Bezüge der Commit-Messages) ·
`AGENTS.md` §3, namentlich §3.6 (Zusage ohne rot gesehenes Gegenbeispiel), §3.7 (was ein
Kommentar trägt), §3.9 (Docker-only) · **keine ADR** — die Commit-Range nennt keine, und die
berührten Flächen (`.d-check.yml` `exempt-targets`, `Makefile`, `harness/tools/`) tragen keine
ADR-Bindung.

> **Zitier-Form.** Kennung statt Adresse für alles, was der Prozess bewegt; ortsfeste
> Code-Pfade als Inline-Code (ein `Datei:Zeile`-Paar hält den Stand des Laufs fest).
> Baseline-Stellen als Tag + Pfad (`v6.8.0` · `regelwerk/<datei>.md` §<Abschnitt>).

**Offengelegt — was dieser Lauf am Baum getan hat.** Vier Messungen sind an `/tmp`-Kopien
gefahren (`/tmp/rev-mut.sh`, `/tmp/rev-a.sh`, `/tmp/rev-e2e.md`, `/tmp/rev-a.md`); der
Erzeuger lief dabei über einen `/tmp`-**Quell**- und Ziel-Pfad. Am Repo wurde nichts
angefasst: `git status --porcelain` war vor und nach jeder Messung leer. `make gates`,
`make mutate`, `make full-smoke` und `make docs-check` hat dieser Lauf **nicht** gefahren
(Gründe unten). Der Gates-Stempel `.harness/state/gates-passed.diffsha` war zum Messzeitpunkt
deckungsgleich mit `harness/tools/working-tree-hash.sh` — das ist ein gelesener Beleg, kein
selbst gefahrener Lauf.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die committete Tabelle wird von keinem Sensor und keinem Test gegen ihren Erzeuger gehalten: der bats-Fall erzeugt in ein tmp-Ziel und liest `docs/user/e2e-abdeckung.md` nie, ein Lauf des Erzeugers steht in keiner Gates-/CI-Kette. Wird eine Deklaration geändert (Kennungen oder Kurzbeschreibung) oder eine Zeile oberhalb einer Stufe eingefügt, ohne `make e2e-abdeckung` zu fahren, nennt die committete Tabelle eine Zuordnung oder einen Ort, die das Skript widerlegt, während `make test` und `make docs-check` grün bleiben. | Maintainability · Plan §1/§2(2) · `LH-QA-01` | `docs/user/e2e-abdeckung.md:19` · `test/e2e-abdeckung.bats:39` | nein — kein laufendes Gate bestätigt sie; genau das ist der Befund | erzeugtes Artefakt ohne Halter gegen seine Quelle |
| F-2 | LOW | Die Laufzeit-Hälfte der Deklaration, die Funktion `e2e_abdeckung` in `harness/tools/full-smoke.sh`, ist von keinem Test fahrbar: ihre Region kommt aus `BASH_LINENO[0]` und damit aus der Zeile *dieses* Skripts, während alle vier bats-Fälle und der Mutationsfall den **Erzeuger** fahren. Der rot gesehene Beleg für „gebrochener Anker endet laut" liegt damit allein an der Schwester-Implementierung im Erzeuger. | `AGENTS.md` §3.6 | `harness/tools/full-smoke.sh:88` · `test/e2e-abdeckung.bats:69` | nein — kein Gate; ein Nachweis bräuchte einen vollen E2E-Lauf mit gebrochenem Anker | Zusage mit Gegenbeispiel nur an der Schwester-Implementierung |
| F-3 | INFO | Plan-Text gegen sich selbst: §1 schließt aus, „keinen Exit-Code des Skripts" zu ändern, während §2(1) verlangt, dass der Aufruf **im E2E** abbricht — der Diff erfüllt §2(1) und fügt dem Skript damit einen neuen Abbruchpfad hinzu. Wer §1 als Grenze liest, hält genau diesen Pfad für ausgeschlossen. | Plan §1 · Plan §2(1) | `harness/tools/full-smoke.sh:88` | nein — Plan-Text, kein Sensor | Plan-Grenze und DoD-Punkt nennen denselben Gegenstand entgegengesetzt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `harness/tools/full-smoke.sh` — Additivität | geprüft, ohne Befund. `git diff --numstat c7fb4fb6 -- harness/tools/full-smoke.sh` → `75 0`: keine bestehende Zeile geändert, keine entfernt; kein neues Stufen-Kopfband, kein veränderter Exit-Code und keine geänderte Erwartung einer Stufe. Fällt die Stufen-Zahl gegen §1/§2 (dort 15, im Baum 16), ist das die vom Plan selbst zugelassene Verschiebung („keine Erwartungswerte"). |
| Anker-Mechanismus (Frage 2) | geprüft, ohne Befund. Alle 16 Anker lösen laut `Ort`-Spalte auf eine **Fehler- oder Kommentarzeile der eigenen Stufe** auf (14 `FEHLER`-Meldungen, 2 Kommentare) — nicht auf die Deklarationszeile, die die Suche ausnimmt. Die Region kommt über `BASH_LINENO[0]`; die Deklarations-Zeilen sind per `RUF_TEIL` ausgenommen, sonst fände jeder Anker sich selbst im dritten Argument. |
| Beide Lücken-Richtungen (Frage 2/5) | geprüft, **rot gesehen** — an Kopien nachgefahren. Richtung „Stufe ohne Deklaration": der Fall `362` entfernt die Deklaration der Stufe 3 (16 → 15 Aufrufe), der Erzeuger endet Exit 1 mit „Stufe ohne Deklaration", Stufe 3, Region und `Nachweis`-Kommando. Richtung „Deklaration ohne auf­lösenden Anker": die Ankerzeile umgeschrieben (genau 1 Vorkommen bleibt, das im Aufruf), Exit 1 mit „Deklaration ohne Stufe", Anker im Klartext, Region, Nachweis. |
| Verdrahtung des Mutationsfalls `362` (Frage 5) | geprüft, ohne Befund. `# files: harness/tools/full-smoke.sh` löst auf genau eine Datei auf; der Wächter `test/e2e-abdeckung.bats:39` fährt den Erzeuger über **genau diese** Datei (`$REPO/harness/tools/full-smoke.sh`) und verlangt `status -eq 0` — die Mutation färbt ihn rot. `make mutate` selbst ist **nicht** gefahren (s. unten). |
| Die vier bats-Fälle (Frage 5) | geprüft, ohne Befund. Sie fahren den Erzeuger über seine dokumentierte Schnittstelle (Quelle und Ziel als Argumente) und mutieren **Kopien**: Happy Path über dem geprüften Baum (dieser Fall ist zugleich der Wächter der Richtung „Stufe ohne Deklaration" *innerhalb* `make gates`), Boundary über einer Kopie, zwei Negativ-Fälle. Jeder Fall belegt seine eigene Mutation vor dem Lauf. |
| `make e2e-abdeckung` als Nicht-Gate (Frage 4) | geprüft, ohne Befund — alle drei Stellen stimmen überein. Nicht in der Gates-Kette (`record-gates: baseline-verify docs-check lint build test shell-lint ci-lint comment-claims host-bin span-check`, `gates: record-gates`); `kein Gate` **in der Zeile selbst** (`harness/README.md:73`); Eintrag in `targets.exempt-targets` (`.d-check.yml:104`). Das Ziel trägt ein Rezept und einen `## `-Hilfetext mit „NICHT in gates" (`Makefile:124`). |
| Erzeuger liest Text, nicht einen Lauf (Frage 3) | geprüft, ohne Befund — nachgefahren. `bash harness/tools/e2e-abdeckung.sh harness/tools/full-smoke.sh /tmp/rev-e2e.md` lief **ohne Docker** und erzeugte 16 Zeilen; die Datei ist byte-identisch mit der committeten `docs/user/e2e-abdeckung.md` (`diff` leer), die committete Tabelle ist also der aktuelle Erzeuger-Ausgang. Kein `docker`, kein Aufruf der Quelle, nur `grep`/`awk`/`sed`/`wc`/`cmp`. |
| `.d-check.yml` — die zwei nachgezogenen Zahlen | geprüft, ohne Befund. „14 von 18" nachgemessen: genau 14 der 18 namentlich aufgezählten Gruppe-(a)-Rezepte tragen `NICHT in gates` im `## `-Hilfetext, die vier genannten (span-clean, doc-immutable, doc-commits, record-gates) nicht. |
| Kommentar-Klassen der neuen Kommentare (`AGENTS.md` §3.7) | geprüft, ohne Befund. Kein Kommentar beschreibt die verworfene Alternative, abwesenden Text oder bricht ab; die Sensor-Nennungen (bats, Mutationsfall) sind Zusage und nicht Lauf-Protokoll, und die Orts-/Grenz-Aussagen stehen im Indikativ. |
| Konsumenten der full-smoke-Ausgabe | geprüft, ohne Befund. Die neue Erfolgszeile geht nach **stdout** (wie jede Stufen-Kopfzeile des Skripts); kein Konsument parst die Ausgabe — die CI ruft `make full-smoke` bar auf (`.github/workflows/ci.yml:82`), und die bats-Fälle, die `full-smoke` nennen, arbeiten über eingefangene Ausgaben einzelner Schritte beziehungsweise über Pfade. |
| `docs/user/` — Index-Pflicht | geprüft, ohne Befund. Es gibt keine Datei unter `docs/user/`, die die Dateien des Verzeichnisses aufzählt; der Einstieg verweist auf das Benutzerhandbuch, nicht auf eine Liste. Kein Index-Nachzug offen. |
| Duplikation des Stufen-Musters | geprüft, ohne Befund. Dasselbe Muster steht in `harness/tools/full-smoke.sh`, `harness/tools/e2e-abdeckung.sh` und (als Zähl-Helfer) in `test/e2e-abdeckung.bats`; die Prosa nennt zwei Stellen. Die Divergenz ist trotzdem gebunden: Erzeuger und Laufzeit-Funktion zählen ihre Stufen gegen dieselbe Datei, und die Schluss-Invariante („`stufen_gesamt` Stufen, aber `deklarationen` Deklarationen") färbt jede Mengen-Divergenz rot — sie läuft über den bats-Fall in `make test` und damit in `make gates`. |

## Nicht geprüft

| Bereich | Grund |
|---|---|
| `make gates`, `make docs-check`, `make mutate`, `make full-smoke`, `make smoke` | nicht gefahren — Budget des Auftrags, und der Gates-Stempel deckt den Baum (s. Kopf). `make mutate` fährt ein kuratiertes Set über alle Fälle; gefahren wurde nur die **eine** Mutation des neuen Falls, an einer Kopie. |
| Laufzeit-Hälfte des Ankers im echten E2E | bräuchte einen vollen `make full-smoke` (Docker, Bootstrap, Gate-Läufe) — deshalb ist F-2 genau der Punkt, an dem dieser Lauf nichts gesehen hat. |
| DoD-Abhakung (§2, jeder Liefer-Punkt) | Verifier-Auftrag (Modul 11), nicht Reviewer-Auftrag. |
| Ob `codepaths.check-lines` die Form `file:NNN` prüft (§6 Risiko 2) | nicht gemessen; die Prosa von `harness/sensors/docs-check.md` sagt dazu nichts. Die Zusage des Erzeugers, dass `make docs-check` halte, „was er schreibt" (`harness/tools/e2e-abdeckung.sh:15`), ist damit für die `Ort`-Spalte ungeprüft — der Plan führt sie als offenes Risiko mit Ausgang bei der Closure. |
| Inhaltliche Zuordnung **jeder** Deklaration zu ihrer Stufe | nur gesichtet (Stufen 1-5, 15, 16 gegen den Region-Inhalt, inklusive der Frage, ob die Kennungen zur Stufe passen) — die Zuordnung bleibt ein Urteil und ist als §6 Risiko 3 benannt. |
| §6 Risiko-Ausgänge, §7 Closure, Register | Planner-Arbeit bei der Closure (`AGENTS.md` §3.10). |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** erzeugtes Artefakt ohne Halter gegen seine Quelle ·
Zusage mit Gegenbeispiel nur an der Schwester-Implementierung · Plan-Grenze und DoD-Punkt
nennen denselben Gegenstand entgegengesetzt

## Verdikt

**Merge-blockierend:** ja — F-1 ist vor dem Merge zu klären. Die Klärung kann auch eine
Entscheidung sein, die die Lücke *benennt* (der Plan führt die Nachbarschaft als §6 Risiko 2
und 3); welche der beiden Formen sie nimmt, entscheidet nicht dieser Lauf.

**Was den Diff trägt.** Die tragende Entscheidung des Slice, der Anker als **bestehender
Zeilenausschnitt** statt als neue Marke, hält: beide Lücken-Richtungen sind rot gesehen, die
Stufen-Menge ist ein Kriterium und keine Aufzählung, und die Zähl-Invariante des Erzeugers
bindet auch die dritte Kopie des Musters in `make gates`. Die Nicht-Gate-Einordnung ist an
allen drei Stellen deckungsgleich, und die committete Tabelle ist der aktuelle Ausgang ihres
Erzeugers.

**Übergabe:** Findings gehen an den Implementer (Rückkante Review → Plan bei Plan-Defekt, hier
F-3); die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den
Zähler des Beobachtungs-Registers. Dieser Report ist ein **Lauf-Beleg** — er wird über Läufe
hinweg nicht wieder gelesen und ersetzt keine Verifikation (Modul 11; anderes Prüf-Artefakt,
anderer Eingabe-Kontext).
