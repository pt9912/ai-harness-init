# Review-Report: `slice-spec-straten-zeigen-nicht-nach-aussen` — 2026-09-18, Runde 2

**Review-Art:** Code — geprüft wird der Diff gegen Plan, aktive ADRs, die Hard Rules und die
Findings der Runde 1. **Nicht** gegen die DoD: die prüft der Verifier (Modul 11).

**Gegenstand:** `bfd05e97..55621868`, zwei Implementer-Commits
(`89f17f54` emittierte Ebene · `55621868` Dogfood), dazu das Architect-Verdikt Runde 2
(`749b0b9d`), das F-1 der Runde 1 entschieden hat.

**Skill:** `.harness/skills/reviewer.md` v2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-18

> **Zitier-Form** *(Norm, kein Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert,
> bewegt sich weiter. Deshalb **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine Baseline-Stelle
> als Tag + Pfad in Inline-Code (`v6.9.0` · `regelwerk/<datei>.md` §<Abschnitt>) statt als Link.
> Ortsfeste Ablagen stehen als Pfad (`AGENTS.md` §3.11). Der Report der Runde 1 wird **nicht**
> nachgebessert; dieser tritt daneben.

**Eingangs-Kontext:**

- der Slice-Plan `slice-spec-straten-zeigen-nicht-nach-aussen`
- die Architect-Verdikte Runde 1 und Runde 2 zu demselben Slice
- der eigene Report der Runde 1 (F-1 bis F-9)
- `MR-017`, `MR-054`, `MR-055`, `MR-001`, `MR-025`
- `LH-FA-03`, `LH-QA-01`
- `AGENTS.md` §3.5 · §3.6 · §3.7
- `v6.9.0` · `regelwerk/modul-11-verification.md` §Fitness Function ohne Standard-Tool
  (Break-Test **und** der unveränderte Bestand, auf dem der Sensor schweigt)

**Eigene Messungen dieses Laufs.** Die Gate-Sonden liefen in Wegwerf-Kopien im Scratchpad gegen
den gepinnten Stand `ghcr.io/pt9912/d-check@sha256:2f2f2460…` (`v0.76.3`), netzlos; die
Zusicherungs-Sonden in einem Klon des Repos im Scratchpad über `make test-go`. Der Arbeitsbaum
wurde nicht verändert. Keine Zahl ist ein Erwartungswert (`MR-025` Setzung 2).

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Die Korrektur zu F-5 der Runde 1 hat eine ganze Zeile entfernt statt der falschen Zahl. Der Kopf des Zahn-Blocks lautet jetzt *„ZAEHNE zu den drei … Modulen ids/matrix/spans — Feldlisten-Zahn oben: Verletzung einschmuggeln …"*: Der Satz bricht am Gedankenstrich ab, weil *„nach derselben Form wie der"* mitgegangen ist. Mitgegangen sind außerdem die Gesamtzahl und der normative Anker — zehn Zeilen tiefer steht weiter *„Die ZWEITE Richtung gehoert bei allen **sechs** dazu"* und zeigt auf eine Zahl, die der Block nicht mehr nennt, und `AGENTS.md` §3.6 stand nur in der gelöschten Zeile. | `AGENTS.md` §3.7 (Kommentar bricht mitten im Satz ab, weil eine Teilersetzung den Rest stehen ließ) | `harness/tools/full-smoke.sh:803` (gegen `:809`) | nein — kein Gate liest Kommentar-Text; `make shell-lint` und `make comment-claims` sehen den Bruch nicht | Korrektur eines Kommentars entfernt mehr als den Fehler |
| F-2 | MEDIUM | Von den vier neuen Zusicherungen in `internal/emit/emit_test.go` haben zwei keinen Fall in `test/mutations/`: die positive (`exempt-paths` trägt genau zwei Pfade, `:80`) und die negative (kein Welle-Pfad, `:83`). `372` und `373` decken die Klasse `aussen` und das `token:`; `372` trifft dabei **zwei** Zusicherungen zugleich (Vorhandensein und Position), isoliert also die Positions-Zusicherung nicht. Beide ungelisteten Zusicherungen sind in diesem Lauf von Hand rot gesehen — was `AGENTS.md` §3.6 verlangt —, aber ihre **Haltbarkeit** hält `make mutate` nicht: *„wer keinen Fall in `test/mutations/` hat, ist unbewacht"*. Das betrifft genau die Zeile, um die F-1 der Runde 1 ging. Teilweise Auflösung von F-2 der Runde 1, keine neue Klasse. | `AGENTS.md` §3.6 | `internal/emit/emit_test.go:80` und `:83`; fehlend in `test/mutations/` | ja — eine der zwei Zusicherungen abschwächen; `make mutate` meldet nichts, `make gates` bleibt grün | neuer-waechter-ohne-mutations-fall |
| F-3 | LOW | Die Schleife, die `letzteKlasse` füllt, läuft über **die ganze** eingebettete YAML und nicht über den `classes:`-Block. Heute trägt nur dieser Block Zeilen mit `- {name: ` (gemessen: 6, alle in `classes:`); eine solche Zeile in einem späteren Block verschöbe die Messung still auf eine andere Stelle, und die Positions-Zusicherung prüfte dann etwas anderes, als ihr Kommentar sagt. | Maintainability | `internal/emit/emit_test.go:31` und `:37` | ja — eine `- {name: …}`-Zeile hinter `classes:` einfügen; die Zusicherung misst sie | Struktur-Zusicherung ohne Block-Grenze |
| F-4 | INFO | Die Angleichung zu F-4 der Runde 1 ist in die **laschere** der zwei Richtungen gelaufen: `matrix.exempt-paths` steht jetzt auf `docs/reviews/**` statt `docs/reviews/*.md`, statt die Geschwister-Module auf die engere Form zu ziehen. Heute kostet das nichts — gemessen: `docs/reviews/` ist flach und trägt ausschließlich `.md`, die zwei Globs decken dieselbe Menge. Ab einem Unterverzeichnis oder einer Nicht-`.md`-Datei decken sie verschiedene, und dann ist die gewählte Form die weitere. | `AGENTS.md` §3.5 (nur der Richtung nach, keine Senkung heute) | `.d-check.yml:365` | ja — eine Nicht-`.md`-Datei unter `docs/reviews/` anlegen und beide Formen fahren | Angleichung zweier Globs läuft zur weiteren Form |
| F-5 | INFO | In der emittierten Konfiguration steht **eine** Regel ohne jedes Gegenbeispiel: `{from: spec-straten, to: slice, allow: false}` hat keinen Zahn in `make full-smoke`, keine Zusicherung in `internal/emit/emit_test.go` und keinen Fall in `test/mutations/`. Sie ist **Bestand** und von diesem Diff nicht berührt; die Frage nach *Regel ohne Gegenbeispiel* wird damit beantwortet, nicht diesem Slice angelastet. Eine Klasse **ohne** Regel gibt es nicht — alle sechs sind Quelle oder Ziel mindestens einer Regel. | `AGENTS.md` §3.6 | `internal/emit/templates/d-check.yml:70` | ja — die Regel entfernen; `make gates` und `make full-smoke` bleiben grün | Bestandsregel ohne Gegenbeispiel, beim Anbau der Nachbarregel sichtbar geworden |
| F-6 | INFO | Die vom Verdikt verlangte Benennung der Ebenen-Asymmetrie steht **nur** in der emittierten Datei (dort vollständig, mit Grund und mit dem Hinweis auf die eigene Kopie des Adopters). Der Kommentar des Dogfood spricht weiter von *„drei Pfaden"*, ohne zu erwähnen, dass die emittierte Fassung bewusst zwei führt. Die gefährliche Richtung des Glattziehens ist gedeckt — `emit_test.go:83` färbt rot, sobald der Welle-Pfad in der emittierten Datei wieder auftaucht (in diesem Lauf gemessen); die Gegenrichtung trägt kein Wächter, wäre aber eine Verschärfung. | `MR-054` Setzung 3 · Architect-Verdikt Runde 2 §Entscheidung | `.d-check.yml:357` | teilweise — `make test` in der gefährlichen Richtung; in der anderen nicht | Asymmetrie nur an einer ihrer beiden Stellen benannt |

### Belege

**Zu Prüf-Auftrag 1 — trägt die Sonde an der Emissions-Ebene?** Drei Stände, dieselbe
Kandidaten-Menge, gegen die **emittierten** Klassen gefahren (`matrix:`-Block aus
`bfd05e97~3` bzw. `55621868`, dazu ein dritter Stand mit der gestrichenen Ausnahme wieder darin):

| Datei (nennt eine `Superseded`-ADR) | emittiert *vorher* | emittiert *jetzt* | *jetzt* + Welle-Ausnahme |
|---|---|---|---|
| `docs/plan/planning/done/welle-01-x.md` | `matrix-inactive` | `matrix-inactive` | **frei** |
| `docs/plan/planning/done/slice-a.md` | `matrix-inactive` | `matrix-inactive` | `matrix-inactive` |
| `docs/plan/adr/README.md` | frei | frei | frei |
| `docs/reviews/<report>.md` | frei | frei | frei |

Die erste Zeile ist die Auflösung von F-1 der Runde 1: Die Status-Deckung der Klasse `welle`
bleibt erhalten, und die dritte Spalte zeigt, was die gestrichene Zeile gekostet hätte. Die zwei
letzten Zeilen sind die **Gegenrichtung**: die verbliebenen zwei Ausnahmen nehmen auf dieser Ebene
nichts — in keinem der Stände entsteht dort ein Befund. Und sie werden dadurch **nicht** zu
erlaubten Zielen: aus einem Spec-Stratum heraus melden beide weiter
`matrix-forbidden  Referenz spec-straten → aussen ist nicht erlaubt`.

**Zu Prüf-Auftrag 2 — halten die vier Zusicherungen nur Text?** Nein; je Zusicherung eine
Mutation, die sie meint, plus der unveränderte Bestand, auf dem der Wächter schweigen muss:

| Mutation im Klon | Ausgang `make test-go` |
|---|---|
| `aussen` bleibt, wandert aber vor `adaptionsblock` | `--- FAIL` mit **genau einer** Zeile: `emit_test.go:66: aussen ist nicht die letzte Klasse in classes: (letzte ist "- {name: adaptionsblock, …")` — die Positions-Zusicherung fällt **isoliert**, die Vorhandensein-Zusicherung bleibt still |
| Welle-Pfad wieder in `exempt-paths` | `emit_test.go:80` **und** `:83` |
| ADR-Index aus `exempt-paths` entfernt | `emit_test.go:80` |
| unverändert | `ok  …/internal/emit` |

Damit ist auch die Sorge des Implementers beantwortet, ein Wurf könne **dauerhaft** rot oder
dauerhaft grün stehen: Alle vier sind fail-closed — bei leerem `letzteKlasse` schlägt
`HasPrefix` fehl, und keine der drei `Contains`-Nadeln ist so gewählt, dass sie unabhängig vom
Prüfgegenstand trifft. Dauerhaft rot fiele beim ersten `make gates` auf; dauerhaft grün ist durch
die vier Zeilen oben ausgeschlossen.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| F-1 der Runde 1 (Senkung in der emittierten Fassung) | **aufgelöst** — Zwei-Stand-Sonde an der Emissions-Ebene selbst gefahren, Tabelle oben; die Klasse `welle` behält ihre Status-Deckung |
| Abwesenheit als begründeter Kommentar (Verdikt Runde 2, Auftrag 3) | geprüft, ohne Befund — beide verlangten Sätze stehen: *warum* keine Ausnahme, und *dass* der Adopter sie in seiner eigenen, skip-if-present geschriebenen Kopie setzen kann |
| F-2 der Runde 1 (emittierte Positionen unbewacht in `make gates`) | **aufgelöst** — vier Zusicherungen in `internal/emit/emit_test.go`, alle gemessen; Restpunkt ist allein die Mutations-Listung zweier davon (F-2 dieses Laufs) |
| F-3 der Runde 1 (gebrochene Einrückung) | **aufgelöst** — Zeile 174 wieder auf drei, Zeilen 253/254 wieder auf zwei Leerzeichen, deckungsgleich mit ihrem Umfeld |
| F-4 der Runde 1 (zwei Glob-Formen) | **aufgelöst** — beide Stellen tragen jetzt `docs/reviews/**`; die Richtung ist F-4 dieses Laufs |
| F-5 der Runde 1 (Kommentar-Zählung) | **sachlich aufgelöst** — vier `matrix`-Zähne, einer `ids`, einer `spans`, nachgezählt an den Zahn-Blöcken (1), (2), (2a), (3), (3a), (4); die Form ist F-1 dieses Laufs |
| F-6 der Runde 1 („nur eine klassifizierte Quelle") | **aufgelöst** — beide Stellen nennen jetzt die Regel als das Begrenzende; außerhalb der Zeitdokumente trägt die Formulierung keine Datei mehr |
| Klasse ohne Regel in der emittierten Fassung | geprüft, ohne Befund — alle sechs Klassen sind Quelle oder Ziel mindestens einer der sechs Regeln |
| Regel ohne Gegenbeispiel in der emittierten Fassung | geprüft, **ein** Fund, und er ist Bestand: F-5 dieses Laufs. Die zwei **neuen** Regeln tragen je Zahn, Zusicherung und Mutation |
| `token:` der Klasse `adaptionsblock`, Wirkung und Grenze | geprüft, ohne Befund — blanke `MR-001` im Spec-Stratum → `matrix-forbidden`; zwei blanke Kennungen in `harness/conventions.md` bleiben still (gemessen) |
| Dogfood-`exempt-paths` und enge `slice`-Klasse | geprüft, ohne Befund — von Runde 2 nicht berührt, in Runde 1 mit der Sonde bestätigt; das Verdikt bestätigt sie unverändert |
| Nachbar-Repo-Spuren im Diff (Pfade, fremde Kennungen) | geprüft, ohne Befund — keine |
| `make docs-check` über dem Arbeitsbaum | geprüft, ohne Befund — EXIT 0 |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:** Korrektur eines Kommentars entfernt mehr als den Fehler ·
neuer-waechter-ohne-mutations-fall · Struktur-Zusicherung ohne Block-Grenze · Angleichung zweier
Globs läuft zur weiteren Form · Bestandsregel ohne Gegenbeispiel, beim Anbau der Nachbarregel
sichtbar geworden · Asymmetrie nur an einer ihrer beiden Stellen benannt

## Verdikt

**Merge-blockierend: ja** — ein HIGH und ein MEDIUM. **Der Weg zu Verifikation und Closure ist
nicht frei**, aber er ist kurz: Beide Befunde liegen neben dem Gegenstand, keiner davon im
Gate-Verhalten.

Die **Sache** ist entschieden und gemessen: Die Senkung aus Runde 1 ist zurückgenommen, die
Gegenrichtung ist geprüft, und die vier Zusicherungen halten nicht Text, sondern fallen je unter
eine Mutation, die sie meint — einschließlich der Positions-Zusicherung, die isoliert fällt.

F-1 ist eine Zeile: Die Korrektur zu F-5 der Runde 1 hat den Satz, die Gesamtzahl und den
`AGENTS.md`-§3.6-Anker mit der falschen Zahl zusammen entfernt. Die Einstufung ist nicht mein
Ermessen — der Reviewer-Skill führt *„bricht mitten im Satz ab, weil eine Teilersetzung den Rest
stehen ließ"* in der HIGH-Liste, und ich habe in Runde 1 unter derselben Quelle zweimal LOW
vergeben, weil dort **Zählungen** falsch waren und keine Sätze gebrochen. Kein Gate fängt es; das
ist der Grund, warum die Liste ihn führt.

F-2 blockiert als MEDIUM, ist aber der kleinere Rest einer bereits weitgehend aufgelösten Klasse:
Die emittierten Positionen sind jetzt in `make gates`; ungelistet ist die **Haltbarkeit** zweier
Zusicherungen unter `make mutate`, und die Positions-Zusicherung teilt sich ihre Mutation mit der
Vorhandensein-Zusicherung.

Die INFO-Befunde blockieren nicht. F-5 ist ausdrücklich **kein** Befund gegen diesen Slice: Er
beantwortet die gestellte Frage nach einer Regel ohne Gegenbeispiel und benennt einen Bestand, der
erst sichtbar wurde, weil die Nachbarregeln jetzt eine Deckung haben, die er nicht hat.

**Übergabe:** Findings an den Implementer. Ein Rollen-Konflikt liegt nicht vor; ein Gang zum
Architect ist nicht nötig — F-1 und F-2 berühren keine Entscheidung, sondern die Ausführung. Die
**Finding-Klassen** gehen in die Slice-Closure §7 und von dort in den Zähler; `neuer-waechter-ohne-mutations-fall`
ist derselbe Vorgang wie in Runde 1 und zählt einmal
(`v6.9.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register). Dieser Report ist ein
**Lauf-Beleg** und ersetzt keine Verifikation — DoD- und Spec-Konformität prüft der Verifier
separat.
