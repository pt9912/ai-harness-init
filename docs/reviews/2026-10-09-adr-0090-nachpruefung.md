# Review-Report: ADR-0090 (Nachprüfung vor Accept) — 2026-10-09

**Review-Art:** Design — Nachprüfung nach `ADR-0040` Festlegung 2.

**Gegenstand:** `ADR-0090` (Proposed), Commit `c6d5d419` gegen die Befunde F-1 bis F-6 aus
`docs/reviews/2026-10-09-adr-0090-review.md` (`d357f942`)

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 ·
**Modell:** claude-opus-5-5 · **Datum:** 2026-10-09

**Eingangs-Kontext:**

- `git diff d357f942 c6d5d419 -- docs/plan/adr/0090-*`
- `ADR-0041`, `ADR-0053` Festlegung 4, `ADR-0065` Festlegung 4, `ADR-0033`, `AGENTS.md` §3.5
- Ist-Stand an `HEAD`: `internal/archive/anwenden.go`, `cmd/ai-harness-init/archive_welle.go`,
  `cmd/ai-harness-init/kennungen_test.go`, `harness/tools/full-smoke.sh`,
  `harness/sensors/archive-welle.md`, beide emittierten Commit-Hook-Vorlagen

---

## Stand der Vorbefunde

| ID | Stand | Beleg |
|---|---|---|
| F-1 | behoben | Folgepflicht nennt jetzt beide `full-smoke`-Aufrufe (Vollzug mit Saat-Kennung, flacher Klon ohne Kennung mit Erwartung `[flacher-klon]`), `harness/README.md` §Traceability und den Kopf von `hooks-install.mk`; die Reihenfolge Sperre vor Pflicht legt Festlegung 3(a) fest. |
| F-2 | behoben | Fitness-Zeile 2 aktiviert den Träger nur um den Altbestand-Lauf. Sonde mit den emittierten Vorlagen `commit-msg-hook.sh` + `commit-msg-traceability.sh` in einem Scratch-Repo, `core.hooksPath=.githooks`: Message `archive-welle: altbestand  Zeitdokumente nach docs/plan/planning/done/altbestand/ (reiner Move)` → rc=1; dieselbe mit `, LH-FA-01` → rc=0; die `welle-1`-Message → rc=1; nach `git config --unset core.hooksPath` → rc=0. Der Go-Träger committet mit `git commit -q -m` ohne `--no-verify` (`archive_welle.go:234`), der Hook läuft also; `full-smoke` wertet `alt_rc` aus (`full-smoke.sh:1845–1851`). Damit wird die Zeile unter `kennungSuffix → ""` rot, und das Entfernen nach dem Lauf ist für die folgenden Welle-Läufe nötig. Die Saat des Ziels trägt `LH-FA-01` (Baseline-Lastenheft-Vorlage), das `patterns=` trifft. |
| F-3 | behoben | Contra B stützt sich nur noch auf das Werkzeug-Wort-Argument; §3.5 entfällt. |
| F-4 | behoben | Option 0 (nichts tun) steht in der Tabelle. |
| F-5 | behoben | Negativ 1 nennt Zielverzeichnis und gestagte Renames ohne Rückweg vor Commit 1, mit Verweis auf `ADR-0053` Festlegung 4. |
| F-6 | behoben | Festlegung 3(b) `--vorschau` frei, 3(c) leer = fehlend; Leerzeichen-Wert als akzeptiertes Negativ benannt. |

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | LOW | Die Folgepflicht-Liste lässt zwei Stellen aus, die an der Konstante hängen: die Ausnahme `"internal/archive/anwenden.go": {", ADR-0041"}` in `traegerAusnahmen` — fällt die Konstante, meldet `TestTraegerMeldungenTragenKeineKennung` „die Ausnahme … emittiert keine Variante" (rot in `make test`, also nicht still) —, und `harness/sensors/archive-welle.md` Punkt 7 („Die Commit-Nachrichten dieses Schlüssels nennen ADR-0041, weil …"), die nach der Umsetzung das Verhalten des Trägers falsch beschreibt; die fängt kein Gate. | `AGENTS.md` §3.6 | `cmd/ai-harness-init/kennungen_test.go:222`; `harness/sensors/archive-welle.md:110–114` | ja — `make test` nach Umsetzung; Sensor-Doku nur durch Lesen | Folgepflicht-Liste deckt die Aufrufer nicht |
| N-2 | INFO | Fitness-Zeile 2 nennt keine Vorbedingungs-Prüfung, dass `core.hooksPath` während des Laufs tatsächlich gesetzt ist; ohne sie bliebe die Zeile bei vergessener Aktivierung unter der Mutation grün. Getragen ist das allein durch den einmaligen Rot-Beleg des Implementers, den die ADR verlangt; kein `test/mutations/`-Fall ist genannt. | `AGENTS.md` §3.6 | `ADR-0090` §Fitness Function, Zeile 2 | ja — Mutation `kennungSuffix → ""`, `make full-smoke` | Wirksamkeit der Aktivierung unbelegt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `ADR-0041` | geprüft, ohne Befund — Festlegung 2 (Dogfood-Voreinstellung `ADR-0041`) bleibt im Repo, der Schlüssel und seine Sperren sind unberührt. |
| `ADR-0053` Festlegung 4 | geprüft, ohne Befund — Negativ 1 übernimmt deren Fehlerpfad, statt ihn neu zu fassen; C hält Werkzeug-Commits im Gegenstand der Zusage. |
| `ADR-0065` Festlegung 4 | geprüft, ohne Befund — das Werkzeug prüft nicht gegen `patterns=`; das Negativ zur Welle-Kennung stimmt am Ist (Sonde: `welle-1`-Message rc=1). |
| `ADR-0033` | geprüft, ohne Befund — Träger bleibt das Produkt-Binär; kein Re-Evaluierungs-Trigger berührt. |
| `AGENTS.md` §3.5 | geprüft, ohne Befund — keine Senkung; die neue Contra B behauptet keine. |
| Festlegung 3 gegen Folgepflicht und Fitness | geprüft, ohne Befund — flacher Klon ohne Kennung erwartet `[flacher-klon]`, konsistent mit 3(a); Go-Test-Zeile deckt `""` und die Sperren-Reihenfolge. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Folgepflicht-Liste deckt die Aufrufer nicht · Wirksamkeit der Aktivierung unbelegt

## Verdikt

**Merge-blockierend:** nein — F-1 bis F-6 behoben, kein neuer Widerspruch zu den Nachbar-ADRs.
`ADR-0090` ist annahmereif; N-1 nimmt der Implementer in `slice-ziel-traegt-keine-kennung-dieses-repos`
mit, N-2 ist ein Hinweis an denselben Lauf.
