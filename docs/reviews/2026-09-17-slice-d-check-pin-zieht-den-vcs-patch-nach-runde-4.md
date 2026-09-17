# Review-Report: slice-d-check-pin-zieht-den-vcs-patch-nach, Runde 4 — 2026-09-17

**Review-Art:** Code, Nachprüfung. Geprüft wird nur, ob R3-1 aus Runde 3 behoben ist
(`docs/reviews/2026-09-17-slice-d-check-pin-zieht-den-vcs-patch-nach-runde-3.md`, Commit
`439731c5`). Neue Befunde stehen hier nur, wenn diese Änderung sie erzeugt hat.

**Gegenstand:** `git show 392c1d68` (Architect, lokal, nicht gepusht). Berührt ist nur `MR-065`.

**Skill:** `.harness/skills/reviewer.md` 2.0.0 · **Modell:** `claude-opus-5[1m]` · **Datum:** 2026-09-17

**Eingangs-Kontext:** R3-1; `MR-055`, `MR-065` (Setzung 1 und 2, Tabelle, §Grenze); die Stellen,
gegen die R3-1 stand: `harness/sensors/commit-msg-check.md` §Grenze (Punkt *„Geprüft hat …"*) und
der Kommentar am `commits`-Block der `.d-check.yml`; `AGENTS.md` §3.8.

Neu gemessen ist in dieser Runde nichts. Die Zahlen der neuen Tabellenzeilen sind als Werte zum
Laufzeitpunkt ausgewiesen.

---

## Status R3-1

| ID | Status | Beleg |
|---|---|---|
| R3-1 | **behoben** | Die zwei lebenden Stellen nennen drei geprüfte Formen: *umgepackt*, *per `--no-local` geklont*, *nur lose Objekte*. Jede davon steht jetzt als Zeile in der Tabelle von `MR-065`. Neu ist die Zeile *„Arbeitsklon nach `git repack -a -d`, Kopf `439731c5`"* (ein `pack-*`-Pack, keine Alternates, `count:` 100, beide Ziele geprüft); die übrigen zwei Formen standen schon da. Setzung 2 (*„Eine Lage außerhalb der Tabelle heißt ungemessen"*) und die zwei lebenden Stellen widersprechen sich damit nicht mehr. §Grenze nennt nicht mehr *die* Mischung ungemessen, sondern *„die Mischung im Allgemeinen"* und benennt die zwei gemessenen Mischungen. Die Einleitung der Tabelle nennt jetzt den Arbeitsklon neben den Kopien, eine abweichende Range je Zelle und `count:` als Laufzeitwert. Dass die lebenden Stellen für *umgepackt* kein `count:` nennen, ist kein Widerspruch: Setzung 1 bindet einen Lauf, der in eine Bilanz eingeht, und die Angabe steht jetzt in `MR-065`. |

## Durch die Änderung entstanden

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R4-1 | INFO | Die Arbeitsklon-Zeile sagt zu Recht, dass nicht erhoben ist, welche Objekte der Ranges lose liegen. Runde 3 hat das am selben Klon (Kopf vor `439731c5`, `count: 95`) für die `doc-commits`-Range erhoben: `c414119b`, `ebb76b3d` und `7c1f228a` lagen im Pack. Die Zeile misst damit vermutlich *Range-Objekte im Pack, andere Objekte lose*. Das ist eine Ergänzung aus einem Zeitdokument, kein Mangel des Eintrags. | `MR-055` | `MR-065`, Absatz unter der Tabelle | nein | — |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Zählung in §Grenze (fünf Lagen, drei Ranges, zwei Ziele) gegen die Tabelle | geprüft, ohne Befund |
| Einleitung: `history-range-guard` nur dort, wo `adr-immutable` läuft | geprüft, ohne Befund |
| `v0.76.0`: Die Tabelle misst dort nichts, der Zeiger geht auf `MR-064` | geprüft, ohne Befund |
| Setzung 2 unverändert; die drei geprüften Formen der lebenden Stellen liegen alle in der Tabelle | geprüft, ohne Befund |
| Index-Zeile `MR-065`: Titel, Geltungsbereich und Ersetzt-Baseline-Regel sind vom Diff nicht berührt | geprüft, ohne Befund |
| Commit-Zuschnitt (§3.8): `392c1d68` berührt nur `harness/conventions/`, die Rolle steht in der Message | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 1 |

R3-1 ist behoben.

**Finding-Klassen dieses Laufs:** keine

## Verdikt

**Bereit für Push und Closure.** R3-1 ist behoben, und die Änderung erzeugt keinen Befund, der
blockiert.

**Merge-blockierend:** nein.

**Übergabe:** R4-1 ist ein Hinweis für den Architect, ohne Handlungsbedarf.
