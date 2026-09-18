# Review-Report: `slice-das-ziel-prueft-seine-durchsetzung-selbst` — 2026-09-18 (Runde 2)

**Review-Art:** Code — geprüft wird der Diff gegen **Plan, ADRs und Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** gegen die DoD: das ist Verifier-Arbeit
(Modul 11).

**Gegenstand:** `a40fe473..2d973c6f` — ein Commit, sieben Dateien. Vorlauf: Runde 1
zu `f6ff3954..a40fe473` (2 HIGH, 4 MEDIUM, 3 LOW, 2 INFO).

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

**Eingangs-Kontext:** der Slice-Plan §1 bis §6 · `ADR-0054` Festlegung 1 ·
`ADR-0007` Festlegung 3 · `LH-FA-11`, `LH-FA-02`, `LH-QA-01`, `LH-QA-03` ·
`AGENTS.md` §3.6, §3.7 · Baseline `v6.9.0` ·
`regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin) ·
die Findings der Runde 1 zu diesem Slice.

---

## Findings

### Eigene Läufe — Grundlage der Findings

Alle Messungen liefen in gebootstrappten Zielen im Scratchpad, Träger ist das
Binär aus `make host-bin` über `2d973c6f`; der Arbeitsbaum blieb unberührt.

| Lauf | Ergebnis |
|---|---|
| Default-Lauf im sprachlosen Ziel | EXIT 0; Gate-Ausgabe vollständig gedruckt (drei Zeilen) |
| Default-Lauf: Spuren einzeln | `Integritaet + Vollstaendigkeit` **vorhanden** · `Datei(en) geprüft` **vorhanden** · `record-gates` **fehlt** |
| Marker-Lauf `SELBSTPRUEFUNG_GATE='make baseline-verify'` | EXIT 0; positive Spur vorhanden, beide verbotenen Spuren fehlen |
| Vorlage mutiert (Gate-Schritt fest auf `make gates`), Marker gesetzt | `Datei(en) geprüft` **vorhanden** → die Stufe fiele; `Integritaet + Vollstaendigkeit` ebenfalls vorhanden |
| `SELBSTPRUEFUNG_TRAEGER=Makefile` | EXIT 2 mit *„[Makefile] ist nicht der Traeger, den der Aktivierungsschritt in Betrieb nimmt … git ruft daraus …/.githooks/Makefile"* |
| Ziel mit **eigenem** `.githooks/commit-msg` (verlangt `TICKET-<n>`), Default | EXIT 2, und die Meldung nennt `SELBSTPRUEFUNG_MSG_GRUEN` als Weg |
| dasselbe Ziel mit `SELBSTPRUEFUNG_MSG_ROT`/`_GRUEN` gesetzt | **EXIT 0** — ROT und GRUEN am fremden Träger, Gate grün |
| Ziel unter global gesetztem `core.hooksPath` | **EXIT 0** (Runde 1: EXIT 2) |
| Dauerhafte Vorgabe im `Makefile` des Ziels, **nach** dem `include` | wirkt — `Gate=[make baseline-verify]` |
| danach zweiter Bootstrap | Vorgabe **weg** (`grep -c` 1 → 0), und der Lauf sagt dazu nichts |

### Finding-Tabelle

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R2-1 | MEDIUM | Beide Köpfe nennen jetzt einen Ort für die **dauerhafte** Vorgabe — *„in das Makefile des Repos (dort, wo dieses Ziel eingebunden wird)"*. Gemessen: das emittierte `Makefile` ist ein generierter Aggregator, den der nächste Bootstrap wortlos neu schreibt; die dort gesetzte Vorgabe ist danach weg. Der neue Go-Zahn fängt das nicht — er prüft die Anwesenheit des Wortes *konvergent*, und sein Kommentar sagt selbst, dass ein Kopf, der die Klasse falsch erklärt, nicht fällt. | `AGENTS.md` §3.7 · `LH-FA-02` · `ADR-0007` Festlegung 3 | `internal/emit/templates/enforce/selbstpruefung.mk:9-18` · `internal/emit/templates/enforce/selbstpruefung.sh:30-36` | ja — Vorgabe ins `Makefile` des Ziels, zweiter Bootstrap, `grep` | benannter Setz-Ort überlebt den nächsten Lauf nicht |
| R2-2 | LOW | Die verbotene Spur `record-gates` kommt in der Ausgabe des Default-Laufs **nicht** vor (gemessen); die Zusicherung kann daher unter keiner Mutation rot werden, während ihre Meldung sie als *„Spur der Belegung"* führt. Die Unterscheidungskraft des Marker-Laufs trägt allein `Datei(en) geprüft`. | `AGENTS.md` §3.6 | `harness/tools/full-smoke.sh:2824-2831` | ja — Default-Lauf gegen beide verbotenen Zeichenketten halten | zahnloser Posten in einer sonst tragenden Zusicherung |
| R2-3 | LOW | Die positive Spur `Integritaet + Vollstaendigkeit` steht in **beiden** Läufen, weil `make gates` `baseline-verify` mitführt (gemessen, auch unter der Mutation). Ihre Meldung sagt *„das gesetzte Kommando lief dann nicht"* — treffen kann sie nur den Fall, dass gar nichts lief. | `AGENTS.md` §3.6 | `harness/tools/full-smoke.sh:2819-2823` | ja — dieselbe Spur im Default-Lauf suchen | positive Zusicherung ohne Unterscheidungskraft |
| R2-4 | LOW | Der Fragment-Kopf verlangt die dauerhafte Vorgabe *„vor dem `include`, damit die `?=` hier nicht mehr greifen"*. Gemessen: eine Zuweisung **nach** dem `include` wirkt ebenso — die genannte Bedingung ist keine. | Maintainability | `internal/emit/templates/enforce/selbstpruefung.mk:14-15` | ja — Zuweisung nach dem `include` und Marker-Zeile lesen | Anleitung nennt eine Bedingung, die der Lauf nicht kennt |
| R2-5 | LOW | §3 des Plans führt weiter *„eine neue Stufe … einmal durch"* und *„Die drei Marker"*; umgesetzt sind inzwischen **drei** Läufe in einem eigenen fünften Ziel und **fünf** Marker. Der Abstand zwischen Plan und Umsetzung ist mit dieser Runde gewachsen (Runde 1: F-8). | Slice-Plan §3 | `harness/tools/full-smoke.sh:2737-2857` · `internal/emit/selbstpruefung.go:46-52` | nein | Plan-Tabelle nach bewusster Abweichung nicht nachgezogen |
| R2-6 | INFO | Die ROT-/GRUEN-Zeilen der Vorlage sagen fest *„ein Commit OHNE/MIT Kennung"*. Gemessen im Ziel mit eigenem Träger: bei `SELBSTPRUEFUNG_MSG_ROT='ohne Ticket-Kennung'` meldet der Lauf weiter *„ROT — ein Commit OHNE Kennung faellt am Traeger"* — die Zeile beschreibt die Belegung, nicht den Lauf. | Maintainability | `internal/emit/templates/enforce/selbstpruefung.sh:169,180` | nein | Ergebnis-Zeile beschreibt die Belegung statt den gefahrenen Fall |
| R2-7 | INFO | Beide Spuren des Marker-Laufs hängen am Wortlaut fremder Ausgaben (`Datei(en) geprüft` aus dem gepinnten d-check-Bild, `Integritaet + Vollstaendigkeit` aus `make baseline-verify`). Ein Wortlaut-Wechsel im Bild färbt die Stufe rot oder nimmt ihr den Zahn — bewusste Folge der Spur-Messung, hier benannt statt verschwiegen. | `LH-QA-02` | `harness/tools/full-smoke.sh:2807-2831` | ja — Pin-Sprung des d-check-Bildes | Zusicherung an fremdem Ausgabe-Wortlaut |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Runde-1-F-1 (Marker-Lauf ohne Zähne) | **behoben, gemessen** — dieselbe Mutation, die in Runde 1 alle fünf Zusicherungen passierte, wird jetzt von `Datei(en) geprüft` gefangen |
| Runde-1-F-2 (Träger-Marker ohne Wirkung) | **behoben, gemessen** — `SELBSTPRUEFUNG_TRAEGER=Makefile` bricht ab, und zwar mit genau dem Grund, den die Stufe verlangt; der `-ef`-Abgleich liest den Hook, den git aus `core.hooksPath` ruft |
| Runde-1-F-3 (Scope der Config-Lesung) | **behoben, gemessen** — `--get --local` an beiden Stellen; unter global gesetztem `core.hooksPath` läuft die Prüfung jetzt Exit 0 |
| Runde-1-F-4 (Ziel mit eigenem Träger) | **behoben, gemessen** — mit den zwei Message-Markern erreicht ein Ziel mit fremdem, `TICKET`-forderndem Träger Exit 0; ohne sie nennt die Abbruch-Meldung den Weg |
| Runde-1-F-6 (Kommentar zur letzten Zeile) | behoben — die ganze Gate-Ausgabe wird gedruckt, der Kommentar beschreibt das |
| Runde-1-F-7 (`golang:` über sprachlosem Ziel) | behoben — 0 Treffer `golang:`, 13 Treffer `sprachlos:` in der Stufe |
| Runde-1-F-9 (`LH-QA-03` ohne Beobachtungspunkt) | behoben — die Kennung ist aus Deklaration und erzeugter Abdeckungs-Sicht entfallen |
| Runde-1-F-10 (Repo-Wurzel) | behoben — der Voraussetzungs-Absatz nennt die äußere Wurzel ausdrücklich |
| Geschlossener Marker-Test über fünf Marker | geprüft, ohne Befund — die Regex trägt jetzt mehrteilige Namen (`(?:_[A-Z]+)*`), und beide Richtungen der Mengengleichheit bleiben erhalten |
| Neuer Go-Zahn auf das Überschreiben | geprüft, ohne Befund als Messung — er fährt einen zweiten `Enforce` und vergleicht byteweise; seine schwächere zweite Hälfte ist im Kommentar benannt (und genau dort sitzt R2-1) |
| Mutations-Fall `test/mutations/371-…` | geprüft, ohne Befund — er trifft die Zeile, die den Marker benutzt, und sein `# expect:` (`traegt weiter die Spur`) steht wörtlich in der Meldung, die dann fällt |
| Dritter Lauf (c) der Stufe | geprüft, ohne Befund — er verlangt Abbruch **und** Grund; ein Abbruch aus anderer Ursache fiele auf |
| `selbstpruefung` in keiner `gates`-Kette | geprüft, ohne Befund — Vorbedingung (`record-gates.sh` in der Kette) und Abwesenheit stehen unverändert |
| Vorlage in der Lage „kein Repo" / „kein Commit" / lokal gesetzter `hooksPath` | geprüft, ohne Befund — unverändert aus Runde 1 |
| `ADR-0054`-Grenze | geprüft, ohne Befund — der Träger bleibt skip-if-present, die zwei neuen Dateien konvergent; die Message-Marker greifen den fremden Träger nicht an |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 4 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** benannter Setz-Ort überlebt den nächsten Lauf
nicht · zahnloser Posten in einer sonst tragenden Zusicherung · positive
Zusicherung ohne Unterscheidungskraft · Anleitung nennt eine Bedingung, die der
Lauf nicht kennt · Plan-Tabelle nach bewusster Abweichung nicht nachgezogen ·
Ergebnis-Zeile beschreibt die Belegung statt den gefahrenen Fall · Zusicherung an
fremdem Ausgabe-Wortlaut

## Verdikt

**Merge-blockierend:** ja — ein MEDIUM. Beide HIGH der Runde 1 sind behoben und
gegen dieselben Lagen nachgemessen, die sie aufgedeckt haben; die vier MEDIUM
ebenso. Offen bleibt die Klasse des Runde-1-Findings F-5 an neuer Adresse: die
Datei ist nicht mehr der falsche Setz-Ort, das `Makefile` des Ziels ist es jetzt
(R2-1). Die vier LOW sind Zähne, die neben tragenden stehen, und eine
Plan-Nachführung, die dem Planner gehört.

**Übergabe:** Findings gehen an den Implementer, R2-5 an den Planner; die
**Finding-Klassen** zusätzlich in die Slice-Closure §7 und von dort in den
Zähler. Dieser Report ist ein **Lauf-Beleg** und wird über Läufe hinweg nicht
wieder gelesen. Er ersetzt keine Verifikation (Modul 11).
