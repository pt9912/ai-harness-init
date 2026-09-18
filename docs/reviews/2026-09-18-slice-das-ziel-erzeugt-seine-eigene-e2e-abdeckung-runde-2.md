# Review-Report: `slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung` — 2026-09-18 (Runde 2)

**Review-Art:** Code — geprüft wird der Diff gegen **Plan, ADRs und Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** gegen die DoD: das ist Verifier-Arbeit
(Modul 11).

**Gegenstand:** `e94d2d4c..fc611ea3` — ein Commit, sieben Dateien. Vorlauf: Runde 1
(1 HIGH, 2 MEDIUM, 2 LOW, 2 INFO), abgearbeitet als F-1 bis F-5.

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

**Eingangs-Kontext:** die Findings der Runde 1 zu diesem Slice · der Slice-Plan §1
bis §3 · `LH-FA-12` (tragend), `LH-FA-11`, `LH-FA-02`, `LH-QA-01`, `LH-QA-03` ·
`ADR-0007` Festlegung 3 · `AGENTS.md` §3.2, §3.6, §3.7 · Baseline `v6.9.0` ·
`regelwerk/modul-13-quality-gates.md` §Die dritte Lage und §Ein Gate ohne seine Grenze.

---

## Findings

### Eigene Läufe — Grundlage der Findings

Träger ist ein über `make host-bin` **neu gebautes** Binär über `fc611ea3`; gemessen
wurde in einem frisch gebootstrappten, sprachlosen Ziel im Scratchpad. Der Arbeitsbaum
dieses Repos blieb unberührt — `git status --porcelain` leer.

| Lauf | Ergebnis |
|---|---|
| `make help` im frischen Ziel | führt **beide** Einträge: `e2e-abdeckung` und `selbstpruefung` |
| `make help` in diesem Repo | führt `e2e-abdeckung` |
| Ziel-Überschrift `### RQ-2 — Zitat »Wert«`, Deklaration auf `RQ-2` | Exit 0, **Code-Span**, Hinweis nennt den abgeleiteten Slug im Klartext, `1 ohne Verweis` |
| Ziel-Überschrift `### RQ-1 — [Zitat](../README.md) im Titel`, Deklaration auf `RQ-1` | Exit 0, **Verweis geschrieben** `#rq-1--zitatreadmemd-im-titel`, Meldung `0 ohne Verweis` |
| danach `make docs-check` im Ziel | **EXIT 2** — `anchor-missing` auf `docs/user/e2e-abdeckung.md:21` |
| Gegenprobe `### RQ-3 — Titel <b>fett</b> hier` | Verweis `#rq-3--titel-bfettb-hier`, `make docs-check` **EXIT 0** — HTML im Titel ist **kein** Treffer, d-check leitet dort gleich ab |
| Spiegel-Lauf des Erzeugers dieses Repos, **zwei** Argumente, in einem Scratch-Baum gleicher Tiefe | byte-gleich mit der committeten Sicht — der Default-Pfad ist durch das dritte Argument nicht bewegt |
| `grep -cE 'make .*\)" \|\| true'` in `harness/tools/full-smoke.sh` | **1** — der neue `make help`-Aufruf ist der einzige seiner Art |
| Kopf der emittierten Vorlage auf `slug_sicher` durchsucht | kein Treffer — der Kopf kennt den Wächter nicht |

### Finding-Tabelle

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R2-1 | HIGH | **F-1 ist verengt, nicht behoben — verschoben von der Zeichen- in die Struktur-Richtung.** `slug_sicher` prüft den Bestand des Slugs und fängt damit jedes Zeichen, das die Ableitung nicht kennt (gemessen: Guillemet → Code-Span). Die Ableitung liest aber die **Rohzeile** der Überschrift, während der Anker aus dem **gerenderten** Text entsteht: eine Überschrift mit Markdown-Link ergibt `rq-1--zitatreadmemd-im-titel` — ausschließlich erlaubte Zeichen, `slug_sicher` winkt durch, Exit 0, Meldung `0 ohne Verweis` — und das `docs-check` des Ziels fällt mit `anchor-missing`. Die Gegenprobe grenzt die offene Klasse ein: HTML im Titel trifft nicht, Markdown-Inline-Syntax (Link, Bild) trifft. | `AGENTS.md` §3.7 („die Zusage auf das einschränken, was der Code hält") und §3.6 · `LH-FA-12` §Benannte Grenze deckt nur *Kennung löst nicht auf* | `internal/emit/templates/enforce/e2e-abdeckung.sh:147-161` (`slug_sicher`), `:124-145` (`slug_fuer` liest die Rohzeile), `:298` (Zweig mit zwei Gründen) · dieselbe Lage in `harness/tools/e2e-abdeckung.sh:143-161` | ja — reproduziert: Ziel-Spec um `### RQ-1 — [Zitat](../README.md) im Titel` ergänzt, `make e2e-abdeckung` EXIT 0, danach `make docs-check` EXIT 2 | abgeleiteter Anker wird geschrieben, ohne gegen die Zieldatei geprüft zu sein |
| R2-2 | MEDIUM | **Die zwei Fassungen beschreiben denselben Code verschieden.** Unser Kopf trägt den neuen Wächter samt Grund; der Kopf der emittierten Vorlage nennt ihn nicht und behauptet unverändert, der Code-Span sei die Antwort auf *„Loest eine Kennung dort nicht auf — oder liegt die Spec-Datei gar nicht"*. Der Zweig hat seit diesem Commit **zwei** Gründe, und der zweite steht im Kopf nicht; die uneingeschränkte Zusage darunter („Das ist die Wahl gegen einen Verweis, der ins Leere zeigt") bleibt stehen. Der erweiterte Kopplungs-Fall hält die Prosa ausdrücklich nicht. | `AGENTS.md` §3.7 (ein Kommentar beschreibt, was da ist) | `internal/emit/templates/enforce/e2e-abdeckung.sh:33-44` gegen `:298`; Vergleichsstelle `harness/tools/e2e-abdeckung.sh:42-49` | nein — kein Gate liest Kommentar-Prosa | zwei Fassungen desselben Codes tragen verschiedene Kopf-Zusagen |
| R2-3 | LOW | Die Begründung des zweiten Eintrags in der neuen Index-Prüfung trägt nicht: *„damit ein leerer Index nicht als Treffer durchgeht"* — ein leerer Index fällt schon am ersten Eintrag der Schleife. Was `selbstpruefung` dort wirklich leistet, ist die Gegenprobe, dass der Index überhaupt entsteht und die Verengung gerade den Namen **mit Ziffer** trifft. | `AGENTS.md` §3.7 (Zusage-Klasse: der Kommentar nennt eine Wirkung, die die Zeile nicht hat) | `harness/tools/full-smoke.sh:2923-2935` | nein | Kommentar nennt eine Wirkung, die die Zeile nicht hat |
| R2-4 | LOW | Der neue `make help`-Aufruf ins Ziel endet auf `\|\| true` und ist damit der **einzige** `make`-Aufruf der Datei außerhalb der Abschnitts-Menge `\|\| [a-z_0-9]+=$?`, über der die Abdeckungs-Zusage des Kopfes gilt; der bats-Wächter `abschnitte()` sieht ihn nicht. Die Zusage bleibt über ihrer definierten Menge wahr, aber die Menge deckt seit diesem Commit nicht mehr jeden Aufruf — der nächste, der so geschrieben wird, entzieht sich der Einordnung still. | `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Ein Gate ohne seine Grenze | `harness/tools/full-smoke.sh:2929` gegen `:34-44` und `test/full-smoke-ausgang.bats:188` | ja — ein erweiterter Ausdruck in `abschnitte()` würde es zeigen | make-Aufruf außerhalb der Menge, über der die Abdeckungs-Zusage gilt |
| R2-5 | LOW | Die Vorbedingung des neuen Test-Seams steht nicht: das dritte Argument wird für das **Nachschlagen** gegen das aktuelle Verzeichnis aufgelöst und für den **Link** gegen den Ort der Sicht (über `rel_prefix`). Beides fällt nur zusammen, wenn der Aufruf aus der Repo-Wurzel kommt und die Sicht die erwartete Tiefe hat; der Kommentar sagt *„Der Pfad gilt dann fuer BEIDES"*, nicht, gegen welche Basis. Ein absoluter Pfad als drittes Argument findet die Überschrift und schreibt trotzdem einen unbrauchbaren Verweis. | Maintainability | `harness/tools/e2e-abdeckung.sh:86-102` | nein — im Repo fängt es `make docs-check`, außerhalb niemand | Test-Seam ohne benannte Vorbedingung |
| R2-6 | INFO | Aus Runde 1 unverändert offen und in dieser Runde nicht adressiert (beide waren INFO): die §3-Tabelle des Plans nennt `test/full-smoke-ausgang.bats` und `internal/emit/baumaussage_test.go` nicht — jetzt zusätzlich `Makefile` und `internal/emit/makefile.go` —, und die Zusage des Ziels über seine Abdeckungs-Sicht hat nur einen Träger, den nichts von selbst ruft. | `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice · `LH-FA-12` §Abgrenzung | Plan §3 gegen `git diff --stat e94d2d4c..fc611ea3` | nein | Plan-Tabelle nennt nicht jede berührte Datei |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| F-2 aus Runde 1 (Index des Ziels) | **erledigt** — gemessen im frischen Ziel: `make help` führt `e2e-abdeckung` und `selbstpruefung`; die Ursache (das Muster `^[a-z-]+:` trifft keine Ziffer) ist in der emittierten Fassung **und** in unserem `Makefile` behoben, und Stufe 18 liest die **Ausgabe** des Ziels statt des Rezepts |
| Ort der Index-Prüfung (Frage 2) | geprüft, ohne Befund — `make help` ist die richtige Wahl: die emittierte `harness/README.md` ist ein Skelett mit `<make-target>`-Platzhaltern und gehört dem Adopter, der Aggregator mit dem `help`-Rezept ist konvergent. Ein leerer Index wird aufgehalten: beide `grep` schlagen dann fehl |
| F-3 aus Runde 1 (Kopplung der Ableitung) | **erledigt für den Code** — der Kopplungs-Fall hält `TYPOGRAFIE`, `ANFUEHRUNGEN`, `SATZZEICHEN` als Zeichenketten, `slug_sicher` byte-gleich und `slug_fuer` bis auf die **eine gezählte** `spec_da`-Zeile, jeweils mit einer Mindest-Zeilenzahl gegen den leeren Vergleich. Nicht gehalten bleibt die Kopf-Prosa (siehe R2-2) |
| F-4 aus Runde 1 (Ausschluss-Token) | **erledigt** — das Token trägt jetzt Leerzeichen, und alle vier Aufruf-Stellen des Bestands tragen die Form; es ist eine Leerzeichen-Grenze, keine Wortgrenze, was für die vorhandenen Stellen trägt |
| F-5 aus Runde 1 (dreizeilige Form) | **erledigt** — Kopf und Null-Stufen-Meldung zeigen die Funktionsdefinition mit ihrem Grund; die gezeigte Zeile wird vom Aufruf-Muster nicht als Deklaration gelesen (`^[[:space:]]*e2e_abdeckung ` trifft `e2e_abdeckung() {` nicht) |
| Test-Seam, Hauptsache (Frage 3) | geprüft, ohne Befund — das dritte Argument gilt für Nachschlagen **und** Link (`spec` und `LASTENHEFT_REL` bekommen denselben Wert), und ohne das Argument ändert sich nichts: der Spiegel-Lauf mit zwei Argumenten ist byte-gleich mit der committeten Sicht. Die unbenannte Basis-Frage ist R2-5 |
| `slug_sicher` in der Zeichen-Richtung | geprüft, ohne Befund — gemessen: Guillemet blockiert, die Meldung nennt den abgeleiteten Slug im Klartext, die Zeile entsteht trotzdem als Code-Span, und der Zähler `1 ohne Verweis` macht den Fall nicht still |
| Die zwei Fassungen an der Trennlinie | geprüft, ohne Befund — über derselben Lage: emittiert Code-Span bei Exit 0, unsere Fassung Abbruch mit `Link ohne Ziel`; der bats-Fall hält beide nebeneinander und belegt seine Ausgangslage vorher |
| `AGENTS.md` §3.2 | geprüft, ohne Befund — keine Suppression im Diff |
| `AGENTS.md` §3.4/§3.5/§3.8/§3.10/§3.11 | geprüft, ohne Befund — keine ADR, keine Gate-Lockerung, keine Norm-Artefakte, kein Abschluss, keine wandernde Adresse |
| `LH-QA-01` / `kein Gate` | geprüft, ohne Befund — die neue Prüfung hängt in Stufe 18 von `make full-smoke`, nicht an einer Gate-Kette des Ziels; die `gates`-Kette des Ziels nennt `e2e-abdeckung` weiterhin nicht |
| Committete Sicht dieses Repos | geprüft, ohne Befund — der Spiegel-Lauf über `fc611ea3` ist byte-gleich; die Datei ist nicht stale geworden |
| Emittierte Ablage und Klassen | geprüft, ohne Befund — unverändert konvergent, Marker-Liste unberührt, keine neue Abhängigkeit |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 3 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** abgeleiteter Anker wird geschrieben, ohne gegen die
Zieldatei geprüft zu sein · zwei Fassungen desselben Codes tragen verschiedene
Kopf-Zusagen · Kommentar nennt eine Wirkung, die die Zeile nicht hat · make-Aufruf
außerhalb der Menge, über der die Abdeckungs-Zusage gilt · Test-Seam ohne benannte
Vorbedingung · Plan-Tabelle nennt nicht jede berührte Datei

*Die erste Klasse ist in diesem Slice jetzt **zweimal** aufgetreten (Runde 1 und
Runde 2) — dieselbe Klasse, verschobene Ursache. Ein Vorgang zählt einmal; das ist eine
Sache der Closure, nicht dieses Reports.*

## Verdikt

**Merge-blockierend:** ja — R2-1 (HIGH) und R2-2.

Vier der fünf Befunde aus Runde 1 sind erledigt, und zwar gemessen statt behauptet:
Index, Kopplung der Ableitung, Ausschluss-Token und die dreizeilige Form. Der HIGH ist
es nicht: `slug_sicher` schließt die Richtung, die der Befund der Runde 1 **zeigte**
(ein Zeichen, das die Aufzählung nicht kennt), und nicht die, die er **meinte** (ein
Anker, den niemand gegen die Zieldatei geprüft hat). Der Unterschied ist an der Bauart
ablesbar: die Ableitung liest Rohtext, der Anker entsteht aus gerendertem Text, und
zwischen beiden liegt Markdown-Syntax, die kein Zeichen-Kriterium erreicht. Die
Gegenprobe mit HTML zeigt, dass die offene Klasse klein ist — sie ist aber nicht leer,
und der Ausgang ist derselbe wie in Runde 1: ein rotes `docs-check` im Ziel auf einer
Datei, die das Werkzeug selbst geschrieben hat, nach einem Lauf, der Exit 0 und
`0 ohne Verweis` meldet.

**Übergabe:** Findings gehen an den Implementer (Rückkante Review → Plan bei
Plan-Defekt); die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von
dort in den Zähler. Dieser Report selbst ist ein **Lauf-Beleg** (Audit: dieser Diff,
dieser Skill, dieses Modell, dieses Verdikt) — er wird über Läufe hinweg nicht wieder
gelesen, und muss es nicht. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität
prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
