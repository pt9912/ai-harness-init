# Review-Report: `slice-das-ziel-prueft-seine-durchsetzung-selbst` — 2026-09-18 (Runde 3)

**Review-Art:** Code — geprüft wird der Diff gegen **Plan, ADRs und Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** gegen die DoD: das ist Verifier-Arbeit
(Modul 11).

**Gegenstand:** `2d973c6f..18aa8b99` — ein Commit, fünf Dateien neben dem
Runde-2-Report. Vorlauf: Runde 1 (2 HIGH, 4 MEDIUM, 3 LOW, 2 INFO), Runde 2
(1 MEDIUM, 4 LOW, 2 INFO).

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
`ADR-0007` Festlegung 3 · `LH-FA-11`, `LH-FA-02`, `LH-QA-01` ·
`AGENTS.md` §3.6, §3.7 · Baseline `v6.9.0` ·
`regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin) ·
die Findings der Runden 1 und 2 zu diesem Slice.

---

## Findings

### Eigene Läufe — Grundlage der Findings

Alle Messungen liefen in einem gebootstrappten Ziel im Scratchpad, Träger ist das
Binär aus `make host-bin` über `18aa8b99`; der Arbeitsbaum blieb unberührt.

| Lauf | Ergebnis |
|---|---|
| frisches Ziel: `ls harness/mk/` | `archivierung · baseline · doc-gate · enforce · erfassung · hooks-install · selbstpruefung · slice-mv` |
| `harness/mk/vorgaben.mk` mit `SELBSTPRUEFUNG_GATE = make baseline-verify`, dann Lauf | EXIT 0, `Gate=[make baseline-verify]`, Spur `Integritaet + Vollstaendigkeit` da, `Datei(en) geprüft` **fehlt** → die Vorgabe **wirkt** |
| zweiter Bootstrap über dasselbe Ziel | Datei **und** Inhalt stehen unverändert, `git status` sauber |
| Lauf danach | EXIT 0, `Gate=[make baseline-verify]` — die Vorgabe **wirkt weiter** |
| `make gates` im Ziel mit dem fremden Fragment | **EXIT 0** — der empfohlene Ort bricht die Gate-Kette des Ziels nicht |
| Vorlage mutiert: Gate-Schritt **übersprungen**, Marker gesetzt | `Integritaet + Vollstaendigkeit` **fehlt** → die positive Zusicherung fängt genau diesen Fall |
| Vorlage mutiert: wieder nur die **letzte Zeile** der Gate-Ausgabe gedruckt | alle **drei** Zusicherungen bleiben grün — siehe R3-2 |
| Default-Lauf: ROT-/GRUEN-Zeilen | nennen die gesetzten Messages (`die Message [Selbstpruefung ohne Kennung] faellt …`) |
| `enforceFiles()` gegen die acht Fragmente im Ziel | `baseline.mk` und `doc-gate.mk` stehen nicht darin; geschrieben werden sie in `internal/emit/baseline.go:53` bzw. `internal/emit/emit.go:190` |

### Finding-Tabelle

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R3-1 | MEDIUM | Die Grenz-Aussage des neuen Zahns nennt *„die Mengen, die dieses Paket kennt"* und zählt vier auf (Durchsetzungsschicht, Commands, Rollen-Typen, Aggregator); als Lücke benennt sie allein die Code-Gate-Fragmente des Sprach-Skeletts. Gemessen schreibt ein Lauf unter `harness/mk/` auch `baseline.mk`, `doc-gate.mk` und `arch-<modul>.mk` — keines davon steht in einer der vier Mengen. Der Abgleich deckt damit einen von vier Wegen nicht, über die ein künftiger Lauf den genannten Vorgabe-Ort belegen könnte, und die Grenze sagt es nicht. | `AGENTS.md` §3.6 | `internal/emit/selbstpruefung_test.go:225-247` | ja — den Ort testweise auf `harness/mk/baseline.mk` setzen: der Zahn bleibt grün | Grenz-Aussage eines Wächters nennt eine von mehreren Lücken |
| R3-2 | LOW | Der Kommentar der Stufe trägt die Eigenschaft *„Die Vorlage druckt die AUSGABE des Gate-Schritts, nicht nur ihre eigene Ankuendigung"*; keine Zusicherung hält sie. Gemessen: eine Vorlage, die wieder nur die letzte Zeile druckt, passiert alle drei Zusicherungen — heute ohne Zahnverlust, weil beide Spuren zufällig auf der letzten Zeile ihres Kommandos stehen. | `AGENTS.md` §3.6 | `harness/tools/full-smoke.sh:2804-2817` · `internal/emit/templates/enforce/selbstpruefung.sh:206` | ja — Druck auf `tail -n 1` zurücknehmen und die Stufe fahren | benannte Eigenschaft ohne Zusicherung, die sie hält |
| R3-3 | LOW | §3 des Plans führt weiter *„eine neue Stufe … einmal durch"* und *„Die drei Marker"*; umgesetzt sind drei Läufe in einem eigenen Ziel, fünf Marker und ein benannter Vorgabe-Ort. Unverändert offen aus Runde 1 (F-8) und Runde 2 (R2-5); Adressat ist der Planner, nicht dieser Diff. | Slice-Plan §3 | `harness/tools/full-smoke.sh:2737-2865` · `internal/emit/selbstpruefung.go:26-35` | nein | Plan-Tabelle nach bewusster Abweichung nicht nachgezogen |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Runde-2-R2-1 (Setz-Ort überlebt den Lauf nicht) | **behoben, gemessen** — die Vorgabe in `harness/mk/vorgaben.mk` steht nach dem zweiten Bootstrap unverändert da, lenkt den Gate-Schritt vorher wie nachher, und das Ziel bleibt mit ihr `make gates`-grün |
| beide Richtungen des neuen Zahns | geprüft, ohne Befund — er verlangt den Ort in **beiden** Köpfen und seine Abwesenheit in den gelesenen Mengen, und er sichert die Nicht-Leere der Menge ab; die Lücke der Mengen selbst steht als R3-1 |
| Runde-2-R2-2 (`record-gates` ohne Zähne) | **behoben** — die Zusicherung ist gestrichen, und der Kommentar sagt, warum sie nie rot werden konnte |
| Runde-2-R2-3 (Reichweite der positiven Spur) | **behoben, gemessen** — die Beschreibung trifft zu: der übersprungene Gate-Schritt wird von ihr gefangen, und `Datei(en) geprüft` ist die eine unterscheidende Zusicherung |
| Runde-2-R2-4 (Bedingung „vor dem `include`") | behoben — gestrichen und durch die `=`-Regel ersetzt, die in Runde 2 nachgemessen ist |
| Runde-2-R2-6 (Zeile beschreibt die Belegung) | **behoben, gemessen** — ROT- und GRUEN-Zeile nennen die gesetzte Message |
| Runde-2-R2-7 (Wortlaut fremder Ausgaben) | **behoben als benannte Grenze** — der Kommentar sagt, dass kein Sensor prüft, ob die zwei Zeichenketten noch entstehen |
| Zusicherungen des Default-Laufs | geprüft, ohne Befund — die zwei Commit-Ausgänge werden über den neuen Präfix gegriffen, beide entstehen aus `git`, keine durch Interpolation |
| Träger-Marker, Message-Marker, `--local`-Lesung | geprüft, ohne Befund — unverändert aus Runde 2, kein Rückschritt im Diff |
| `ADR-0054`-Grenze und Klasse der zwei Dateien | geprüft, ohne Befund — Träger weiter skip-if-present, beide neuen Dateien konvergent, der empfohlene Vorgabe-Ort gehört keiner der zwei Klassen an |
| `LH-QA-01` (kein behauptetes Gate) | geprüft, ohne Befund — `selbstpruefung` steht unverändert in keiner `gates`-Kette des Ziels |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Grenz-Aussage eines Wächters nennt eine von
mehreren Lücken · benannte Eigenschaft ohne Zusicherung, die sie hält ·
Plan-Tabelle nach bewusster Abweichung nicht nachgezogen

## Verdikt

**Merge-blockierend:** ja — ein MEDIUM (R3-1). Das **Verhalten** des Gegenstands
ist in dieser Runde vollständig belegt: der benannte Vorgabe-Ort trägt und wirkt
über zwei Bootstraps hinweg, die zwei verbliebenen Zusicherungen sind ehrlich
beschrieben und ihre Reichweiten je einzeln nachgemessen, und die Befunde der
Runden 1 und 2 sind erledigt. R3-1 sitzt nicht im emittierten Artefakt, sondern
in der Grenz-Aussage des Zahns, der es bewacht — sie nennt eine Lücke, während
gemessen drei weitere Pfad-Familien unter `harness/mk/` an ihr vorbeigehen.

**Weg zu Verifikation und Closure:** Die **Verifikation** kann laufen — sie prüft
DoD, Plan und Spec und hängt an keinem der drei Findings. Die **Closure** ist es
nicht: R3-1 blockiert nach der Regel dieses Skills, und R3-3 ist ein
Planner-Posten, der vor dem Abschluss ohnehin über den Tisch geht.

**Übergabe:** R3-1 und R3-2 an den Implementer, R3-3 an den Planner; die
**Finding-Klassen** zusätzlich in die Slice-Closure §7 und von dort in den
Zähler. Dieser Report ist ein **Lauf-Beleg** und wird über Läufe hinweg nicht
wieder gelesen. Er ersetzt keine Verifikation (Modul 11).
