# Review-Report: `slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung` — 2026-09-18 (Runde 1)

**Review-Art:** Code — geprüft wird der Diff gegen **Plan, ADRs und Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** gegen die DoD: das ist Verifier-Arbeit
(Modul 11).

**Gegenstand:** `8616eba0..4d2db9de` — vier Implementer-Commits
(`c7b5e90b`, `6d1f4b9a`, `0048110e`, `4d2db9de`), ein Planner-Commit (`76552faa`)
und ein Architect-Commit (`4c033b4e`, `LH-FA-12` als angenommener Change Request),
17 Dateien.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 ·
**Modell:** claude-opus-5 · **Datum:** 2026-09-18.

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Ein `pfad`-Feld auf den
> **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den Stand des
> Laufs und darf ihn festhalten.

**Eingangs-Kontext:** der Slice-Plan §1 bis §3 und §8 · `LH-FA-12` (tragend),
`LH-FA-11`, `LH-FA-10`, `LH-FA-02`, `LH-QA-01`, `LH-QA-03` ·
`ADR-0007` Festlegung 3 (konvergente Klasse) · `AGENTS.md` §3.2, §3.6, §3.7, §3.9 ·
Baseline `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin)
und §Die dritte Lage · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice ·
die Reports der Runden 1–3 zu `slice-das-ziel-prueft-seine-durchsetzung-selbst`
(Nachbar-Slice derselben Emissions-Familie).

---

## Findings

### Eigene Läufe — Grundlage der Findings

Alle Messungen liefen in gebootstrappten Zielen im Scratchpad, Träger ist das Binär
unter `.harness/state/bin/`, gebaut über dem Stand dieses Diffs (die drei emittierten
Dateien sind byte-gleich mit ihren Vorlagen). Der Arbeitsbaum dieses Repos blieb
unberührt — `git status --porcelain` am Ende leer.

| Lauf | Ergebnis |
|---|---|
| sprachloses Ziel, erster `make e2e-abdeckung` | EXIT 0, eine Zeile, Kennungs-Zelle `—`, Ort `tools/harness/selbstpruefung.sh:153` |
| zweiter Lauf, unveränderte Deklaration | EXIT 0, `unveraendert`, Datei nicht angefasst |
| Spec-Datei entfernt | EXIT 0, Hinweis nennt Datei **und** Marker, Sicht entsteht trotzdem |
| Kennung `LH-XX-99` (löst nicht auf) | EXIT 0, Zelle als Code-Span, kein Verweis, Hinweis nennt die Kennung |
| Kennung `LH-FA-01` (löst auf) | EXIT 0, Verweis `../../spec/lastenheft.md#lh-fa-01--titel-der-anforderung` |
| fremde Marker (`QUELLE`/`PRAEFIX`/`ZIEL`) auf ein eigenes E2E des Adopters | EXIT 0, Sicht entsteht am gesetzten Ort, die alte bleibt stehen |
| dasselbe eigene E2E mit einer Stufe **ohne** Deklaration | EXIT 2 über `make`, Meldung `Stufe ohne Deklaration` mit Region und Nachweis-Kommando |
| zwei Deklarationen in einer Stufen-Region | EXIT 1, `N Stufen, aber M Deklarationen` |
| `--lang go`-Ziel, `grep -rl e2e-abdeckung` | nur die zwei neuen Dateien und `tools/harness/selbstpruefung.sh` |
| `make help` im Ziel | listet `selbstpruefung`, `hooks-install`, `slice-mv`, `span-report` — **nicht** `e2e-abdeckung` |
| Ziel-Spec um `### RQ-8 — Zitat »Wert«` ergänzt, Deklaration auf `RQ-8`, dann `make e2e-abdeckung` | EXIT 0, Meldung `0 ohne Verweis`, geschriebener Verweis `#rq-8--zitat-»wert«` |
| danach `make docs-check` im Ziel | **EXIT 2** — `anchor-missing`, `1 Befund(e)` auf `docs/user/e2e-abdeckung.md:21` |
| Mutation `363` trocken auf eine Kopie | Deklarationen 1 → 0, Stufen-Kopfzeile bleibt 1 — der bats-Fall fiele aus dem behaupteten Grund |
| Erzeuger dieses Repos über `harness/tools/full-smoke.sh` in ein Scratch-Ziel | bis auf den tiefenabhängigen `../`-Präfix identisch mit der committeten Sicht |

### Finding-Tabelle

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der emittierte Erzeuger leitet den Anker selbst aus der Überschrift ab und prüft ihn nicht gegen die Zieldatei: eine Überschrift mit Zeichen außerhalb seiner Lösch-Menge (gemessen: `»«`) ergibt einen Verweis, der ins Leere zeigt, und das `docs-check` des Ziels fällt darauf mit `anchor-missing` — auf einer Datei, die das Werkzeug selbst geschrieben hat. Derselbe Lauf endet mit Exit 0 und meldet „0 ohne Verweis". Der Kopfkommentar der Vorlage sagt genau das Gegenteil zu: „Das ist die Wahl gegen einen Verweis, der ins Leere zeigt: ein toter Link faerbt ein Doku-Gate rot …". Die benannte Grenze von `LH-FA-12` deckt den Fall *Kennung löst nicht auf*, nicht den Fall *Kennung löst auf, abgeleiteter Anker ist falsch*. | `AGENTS.md` §3.7 („die Zusage auf das einschränken, was der Code hält") und §3.6 · `LH-FA-12` §Benannte Grenze · Kontext-Eskalation: die erzeugte Datei liegt im Prüfbereich des Ziel-Gates | `internal/emit/templates/enforce/e2e-abdeckung.sh:35-39` (Zusage im Kopf), `:119-140` (`slug_fuer`), `:279` (Link-Zweig) | ja — reproduziert: Ziel-Spec um eine Überschrift mit `»«` ergänzt, `make e2e-abdeckung` EXIT 0, danach `make docs-check` EXIT 2 mit `anchor-missing` | abgeleiteter Anker wird geschrieben, ohne gegen die Zieldatei geprüft zu sein |
| F-2 | MEDIUM | Das emittierte Kommando steht in keinem Index des Ziels: `make help` listet es nicht, weil das Ziel-Rezept `^[a-z-]+:.*##` greift und die Ziffer in `e2e-abdeckung` nicht trifft; `harness/README.md`, `AGENTS.md` und die Commands des Ziels nennen es ebenfalls nicht. Der `## `-Hilfetext im Fragment ist damit eine Deklaration, die kein Lauf einlöst — während das Schwester-Kommando `selbstpruefung` derselben Familie in `make help` erscheint. | `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Die dritte Lage: genannt, aber kein Gate · `LH-FA-12` Happy Path | `internal/emit/templates/enforce/e2e-abdeckung.mk:38` (der `## `-Text) gegen das `help`-Rezept des emittierten Aggregators | ja — `make help` im gebootstrappten Ziel, Ausgabe enthält `e2e-abdeckung` nicht | emittiertes Kommando ohne Eintrag in einem Index des Ziels |
| F-3 | MEDIUM | Die Kopplung der zwei Fassungen hält Tabellen-Kopfzeile, `RUF_MUSTER`, `RUF_TEIL` und die zwei Lücken-Schlüssel — **nicht** die Anker-Ableitung. `TYPOGRAFIE`, `ANFUEHRUNGEN`, `SATZZEICHEN` sind heute byte-gleich und `slug_fuer` unterscheidet sich nur um den `spec_da`-Wächter; kein Fall in `test/e2e-abdeckung.bats` und keiner in `internal/emit/e2eabdeckung_test.go` nennt eine der vier Stellen (je 0 Treffer). Eine einseitige Ergänzung hier — unser Lastenheft bekommt eine Überschrift mit einem neuen Zeichen — lässt die emittierte Fassung zurück, und der Befund fällt erst im fremden Repo an; §3 des Plans hält ausdrücklich fest, dass die zwei Fassungen ein Test zusammenhält und nicht die Absicht. | Maintainability · `LH-QA-02` · Plan §3 Ansatz-Satz | `test/e2e-abdeckung.bats:209-230` (Kopplungs-Fall) gegen `harness/tools/e2e-abdeckung.sh:71-78` und `internal/emit/templates/enforce/e2e-abdeckung.sh:85-91`, `:119-140` | ja — ein Kopplungs-Fall in derselben Form wie der bestehende würde es bestätigen | geteilte Ableitung zweier Fassungen bleibt ungehalten |
| F-4 | LOW | Der neue Ausschluss-Token in der (B)-Abgrenzung ist der bloße Substring `e2e-abdeckung`. Jede künftige Zeile, die das Wort trägt und trotzdem ein Bild anfordert, fällt still aus der Abdeckungs-Zusage des Kopfes — dieselbe Bauart wie die schon vorhandenen Token, jetzt um einen vierten erweitert. | Maintainability · `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Ein Gate ohne seine Grenze | `harness/tools/full-smoke.sh:42`, `test/full-smoke-ausgang.bats:183` und `:198` | nein — kein Gate prüft, ob ein Ausschluss-Token noch trifft, was er meinte | Ausschluss über Substring statt über die gemeinte Zeile |
| F-5 | LOW | Die Form, die die Fehlermeldung und der Kopfkommentar der Vorlage einem Adopter zeigen, besteht aus zwei Zeilen — Stufen-Kopfzeile und Aufruf. Die Funktions-Definition `e2e_abdeckung()` gehört ebenso dazu: wer die zwei Zeilen in sein eigenes E2E übernimmt, bekommt dort unter `set -euo pipefail` ein `command not found` und sein E2E bricht ab, obwohl der Erzeuger über demselben Text grün liest. | Maintainability · `LH-FA-02` (die adaptierbare Form ist das, was der Adopter nachbaut) | `internal/emit/templates/enforce/e2e-abdeckung.sh:145-149` (Meldung), `:12-17` (Kopf) | nein — der Erzeuger liest Text und sieht die Laufzeit des fremden E2E nie | mitgelieferte Form nennt nicht alles, was sie zum Laufen braucht |
| F-6 | INFO | Zwei geänderte Dateien stehen nicht in der Tabelle §3 des Plans: `test/full-smoke-ausgang.bats` (Ausschluss-Token und Kommentar drei → vier) und `internal/emit/baumaussage_test.go` (zwei Zeilen Träger-Inventur). Beide sind mechanische Folgen der geplanten Änderungen; der Plan ist trotzdem der Maßstab, an dem sich der gewachsene Slice messen lässt. | `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice | Plan §3 gegen `git diff --stat 8616eba0..4d2db9de` | nein | Plan-Tabelle nennt nicht jede berührte Datei |
| F-7 | INFO | Die vom Implementer selbst gemeldete Reichweiten-Differenz wiegt nicht schwerer, als er sie einordnet, aber ihr Grund liegt woanders als benannt: Nicht die Funktion trägt den Unterschied, sondern die Kette. Unsere Laufzeit-Funktion bricht den E2E bei gebrochenem Anker ab, und `make full-smoke` läuft in CI; im Ziel ist der Erzeuger kein Gate und in keiner Kette — eine verrottete Deklaration kann dort beliebig lange stehen. Das ist der von `LH-FA-12` ausdrücklich gewollte Zustand („Das Kommando hängt an keiner Gate-Kette des Ziels") und kein Defekt, aber es ist eine Annahme, die nirgends im Ziel geschrieben steht. | `LH-FA-12` §Abgrenzung · `LH-QA-01` | `internal/emit/templates/enforce/selbstpruefung.sh:117-119` gegen `harness/tools/full-smoke.sh:90-118` | nein | Zusage des Ziels hat nur einen Träger, und der wird nie von selbst gerufen |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Gedankenstrich in der Kennungs-Zelle der mitgelieferten Stufe (Schwerpunkt 4) | geprüft, ohne Befund — im Ziel gemessen: Zelle `—`, Hinweis nennt Stufe und Ort, die Stufe steht trotzdem in der Sicht; die Begründung steht in beiden Dateien im Indikativ und nennt keine Chronik |
| Trennlinie der zwei Fassungen, Zweig *Kennung löst nicht auf* (Schwerpunkt 2) | geprüft, ohne Befund — gemessen: Code-Span, Exit 0, Hinweis mit Marker; im Ziel färbt das kein Gate, und `test/e2e-abdeckung.bats` hält beide Verhalten nebeneinander. Der **andere** Zweig trägt nicht, siehe F-1 |
| Zweiter Lauf, Schreiben nur bei Abweichung (Schwerpunkt 1c) | geprüft, ohne Befund — `unveraendert`, Exit 0, Datei unangetastet; der bats-Fall misst den Zeitstempel und fährt eine Gegenprobe mit geänderter Deklaration |
| Die vier Marker (Schwerpunkt 1d) | geprüft, ohne Befund — `QUELLE`, `PRAEFIX`, `ZIEL` am Aufruf im Ziel gemessen, `SPEC` über den Fehlt-Fall und den bats-Marker-Fall; gemessen wird jeweils, was entsteht, nicht die Erwähnung in der Ausgabe |
| Beide Lücken-Richtungen (Schwerpunkt 1) | geprüft, ohne Befund — Stufe ohne Deklaration und null Stufen enden beide mit Exit ≠ 0 und nennen die Richtung; die Null-Stufen-Meldung führt den Adopter zur erwarteten Form |
| Zweites E2E-Skript des Adopters (Schwerpunkt 1e) | geprüft, ohne Befund — über die Marker fährt derselbe Erzeuger ein zweites Quell-Skript in eine zweite Sicht; die erste bleibt stehen |
| `kein Gate` im Ziel | geprüft, ohne Befund — das Fragment hängt an keiner Kette, die `gates`-Kette des Ziels nennt es nicht, und die neue `full-smoke`-Stufe prüft genau das aktiv |
| `AGENTS.md` §3.2 (Lint-Suppression) | geprüft, ohne Befund — keine `# shellcheck disable`- und keine `//nolint`-Zeile im Diff; die zwei shellcheck-Klippen (SC1112, SC2016) sind über Variablen statt über Suppression umgangen |
| `AGENTS.md` §3.7 (Kommentar-Klassen) | geprüft, ohne Befund — keine Befund-Kennung und keine Slice-Nummer in den neuen Kommentaren; die Kommentare tragen Zusage, Kopplung, Abgrenzung und Grenze im Indikativ |
| `AGENTS.md` §3.9 (Docker-only) | geprüft, ohne Befund — der Erzeuger fügt dem Ziel nichts hinzu: bash und coreutils, kein Container, kein Netz; im Ziel gemessen |
| `AGENTS.md` §3.4/§3.5/§3.8/§3.10/§3.11 | geprüft, ohne Befund — keine ADR berührt, keine Gate-Lockerung, keine Norm-Artefakte, kein Abschluss, keine wandernde Adresse in einem einfrierenden Artefakt |
| `LH-QA-01` (halluzinierte Gates) | geprüft, ohne Befund — die neue Zeile in `harness/README.md` steht in der Werkzeuge-Tabelle mit `kein Gate` in der Bindung-Zelle, und die Klassen der Zelle sind die deklarierten |
| Committete Sicht dieses Repos | geprüft, ohne Befund — die Datei ist die Ausgabe des Erzeugers und nicht von Hand gedreht; gegen einen frischen Lauf bis auf den tiefenabhängigen `../`-Präfix identisch |
| Mutations-Fall `363` und die Rot-Belege (Schwerpunkt 6) | geprüft, ohne Befund — die Mutation trifft, was sie behauptet (Deklaration weg, Stufe bleibt), und die bats-Fälle belegen ihre Mutation vor dem Lauf statt sie zu behaupten; der Zeitstempel statt des Inodes ist die tragfähige Messung |
| Plan-Treue §1 (Schwerpunkt 7) | geprüft, ohne Befund — die Lastenheft-Änderung liegt in einem eigenen Architect-Commit, keine zweite Kennungs-Menge reist mit, keine Sicht-Datei im Ziel-Baum, keine weitere Stufe im ziel-eigenen E2E |
| Plan-Treue Größenregel | geprüft, ohne Befund — drei Liefer-Punkte, zwei Schichten (Emitter-Vorlagen und eigenes Werkzeug), in einer Sitzung prüfbar |
| `ADR-0007` Festlegung 3 (konvergente Klasse) | geprüft, ohne Befund — beide neuen Dateien liegen konvergent, die Marker sind Variablen statt Suchen-und-Ersetzen-Platzhalter, und beide Kopfkommentare sagen es |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** abgeleiteter Anker wird geschrieben, ohne gegen die
Zieldatei geprüft zu sein · emittiertes Kommando ohne Eintrag in einem Index des Ziels ·
geteilte Ableitung zweier Fassungen bleibt ungehalten · Ausschluss über Substring statt
über die gemeinte Zeile · mitgelieferte Form nennt nicht alles, was sie zum Laufen
braucht · Plan-Tabelle nennt nicht jede berührte Datei · Zusage des Ziels hat nur einen
Träger, und der wird nie von selbst gerufen

## Verdikt

**Merge-blockierend:** ja — F-1 (HIGH) und die zwei MEDIUM.

F-1 ist der tragende Grund: Der Erzeuger schreibt Verweise in den Baum des Adopters,
prüft sie nicht und meldet dabei Vollständigkeit („0 ohne Verweis"); das Ergebnis ist ein
rotes `docs-check` im Ziel auf einer Datei, die kein Mensch dort geschrieben hat. Die
Zusage im Kopf der Vorlage nennt genau diesen Ausgang als den, den die Bauart vermeidet.
F-3 verschärft ihn in der Zeit: Die Ableitung, an der F-1 hängt, ist zwischen den zwei
Fassungen unbewacht.

Die Mechanik selbst trägt: beide Lücken-Richtungen, die vier Marker, der zweite Lauf, der
Gedankenstrich und die Spaltenfolge sind im gebootstrappten Ziel gemessen und tun, was
Plan und `LH-FA-12` sagen.

**Übergabe:** Findings gehen an den Implementer (Rückkante Review → Plan bei
Plan-Defekt); die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von
dort in den Zähler. Dieser Report selbst ist ein **Lauf-Beleg** (Audit: dieser Diff,
dieser Skill, dieses Modell, dieses Verdikt) — er wird über Läufe hinweg nicht wieder
gelesen, und muss es nicht. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität
prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
