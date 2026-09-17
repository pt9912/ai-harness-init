# Review-Report: `slice-mv-zieht-praefixlose-geschwister-verweise-nach`, Runde 2 — 2026-09-17

**Review-Art:** Code, Nachprüfung. Geprüft werden allein die Befunde F-1 und F-3 aus Runde 1
sowie neue Befunde, die die Nacharbeit selbst erzeugt.

**Gegenstand:** `git diff 915d1032..7348e55c` (ein Commit, 3 Dateien, +13/−11), gegen den Report
der Runde 1 zu `slice-mv-zieht-praefixlose-geschwister-verweise-nach` vom selben Tag.

**Skill:** `.harness/skills/reviewer.md` @ `1b643a87` (Version 2.0.0) ·
**Modell:** `claude-opus-5` · **Datum:** 2026-09-17

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Ein `pfad`-Feld auf den
> **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den Stand des
> Laufs und darf ihn festhalten.

**Eingangs-Kontext:**

- Report der Runde 1 (F-1 bis F-5)
- `AGENTS.md` §3.6, §3.7
- `ADR-0042`

Nicht Gegenstand dieser Runde sind F-2, F-4 und F-5. Sie liegen laut Auftrag bei Planner
(Closure) bzw. Verifier und bleiben, wie Runde 1 sie übergeben hat.

---

## Eigene Messung

| Prüfung | Ergebnis |
|---|---|
| Zeilen außerhalb von Kommentaren im Diff (`git diff … \| grep -E '^[-+]' \| grep -vE '^[-+]#'`, ohne die Kopfzeilen) | keine; die Nacharbeit ändert nur Kommentarzeilen |
| Anker der Mutation 363 (`esc_base([)#])`) | je Fassung genau 1 Treffer, im `sed` von `rewrite_incoming_bare_in_file`; der Befehl in `test/mutations/363-…sh:20` ist unverändert |
| Anker der Mutation 346 (erstes `base#g` in `internal/emit/templates/enforce/slice-mv.sh`) | Zeile 117, im Rumpf von `rewrite_incoming_in_file` (Definition Zeile 114); Kopf- und Befehlszeilen des Falls unverändert, geändert ist allein Kommentarzeile 13 |
| Stand-Feld `8737ca7` im BELEG-Absatz | löst auf (`git cat-file -t` → `commit`) |
| Zeiger „GRENZEN unten" | trifft den Abschnitt `# GRENZEN (gemessen, nicht vermutet — vier Stück):`, Zeile 80 |

Die Mutationen sind in dieser Runde nicht erneut gefahren: Keine Zeile außerhalb eines Kommentars
hat sich geändert, und beide Anker stehen an ihrem Ort. Den Rumpf-Vergleich betrifft der
Kommentar über `rewrite_incoming_bare_in_file` nicht, denn der Leser des Vergleichs beginnt an
der Definitionszeile. Die neue Fassung des Kommentars ist zudem in beiden Dateien wortgleich.

## Status der Befunde aus Runde 1

| ID | Status | Beleg |
|---|---|---|
| F-1 | **behoben** | `harness/tools/slice-mv.sh:58-62`: Der Satz, der früheres und heutiges Verhalten gegenüberstellte, ist entfallen. An seiner Stelle steht im Indikativ die Grenze der Messung (*„belegt die Zwei-Commit-Sequenz, nicht die Menge der Verweis-Formen"*) und ein Rang-Zeiger auf die GRENZEN und auf `harness/sensors/slice-mv.md` §Kanten. Der Stand der Messung steht als auflösbares Feld. Der Zeiger *„(Grenze 3 unten)"* in Zeile 53 verweist auf die Stelle, die diese Form heute beschreibt. `test/mutations/346-…sh:13` sagt im Indikativ *„unter dieser Mutation faerbt kein Fall-Satz rot"*. Das deckt sich mit dem Lauf der Runde 1: Rot wurde dort nur der Kopplungs-Fall, dazu der Aufbau-Fall 188 der Kopie. `slice-mv.sh:104` ist jetzt ebenfalls ein Rang-Zeiger. |
| F-3 | **behoben** | `harness/tools/slice-mv.sh:182-184` und `internal/emit/templates/enforce/slice-mv.sh:127-129`, wortgleich: *„Die Regel liest kein Markdown: steht die Link-Syntax selbst mit genau diesem Namen in einem Code-Span oder Code-Block, wird sie mitersetzt"*. Der Bezug ist eindeutig, und die Aussage deckt sich mit dem Mini-Repo-Lauf der Runde 1 (Code-Span `[3]` ersetzt). |

## Findings

Keine. Die Nacharbeit erzeugt keinen neuen Befund.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | — |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `AGENTS.md` §3.7, neue und geänderte Kommentarzeilen in den drei Dateien | geprüft, ohne Befund |
| `AGENTS.md` §3.6, Mutations-Anker 363 und 346 | geprüft (`grep`), ohne Befund |
| Kopplung der zwei Fassungen (Kommentar über `rewrite_incoming_bare_in_file` wortgleich, Rümpfe unberührt) | geprüft, ohne Befund |
| Code außerhalb von Kommentaren | geprüft, unverändert |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** keine neuen. Aus Runde 1 bleiben die Klassen jenes Reports für
die Closure §7 bestehen.

## Verdikt

**Merge-blockierend:** nein. F-1 (HIGH) und F-3 (LOW) sind behoben, neue Befunde gibt es nicht.
**Bereit für Verifier und Closure.** Offen bleiben die übergebenen Punkte aus Runde 1: F-2 (Ausgang
von Risiko 4) beim Planner, F-4 (Folge-Slice `slice-mv-kanten-nach-done-sind-bewacht`) beim
Planner, F-5 (DoD 3, `make mutate`) beim Verifier.

**Übergabe:** an den Verifier. Dieser Report ist ein Lauf-Beleg und ersetzt keine Verifikation.
