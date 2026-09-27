# Review-Report: slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen — 2026-09-27

**Review-Art:** Code — gegen Plan + Konventionen (Modul 10 §Drei Review-Arten).

**Gegenstand:** Commits `bdda8a7a` (Claim) · `12f30003` (L1 Pin) · `0c6ea92c` (L3
Sensor-Docs) des Slice `slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.3.0
**Modell:** claude-sonnet-5 · **Datum:** 2026-09-27

**Zitier-Form:** Kennungen statt Lifecycle-Pfaden (§3.11); Baseline-Stellen als
`v6.9.0` · `regelwerk/<datei>.md` §<Abschnitt>.

**Eingangs-Kontext:**

- Slice-Plan `slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen` (§1–§6 vollständig gelesen)
- `AGENTS.md` §3.5, §3.6, §3.7, §3.9
- `harness/conventions.md` samt Kette MR-052/MR-061/MR-063/MR-064/MR-066/MR-068
- `harness/conventions/MR-068-…md` (Vorgänger-Muster für den Pin-Sprung, Vorlage für die
  Strenge-Bilanz-Form)
- `harness/conventions/MR-063-gegenmessung-deckt-jedes-aktive-modul.md` (Sonden-Tabelle,
  9 aktive Module)
- ADR-0070 (referenziert von den zwei geänderten Sensor-Dateien, nicht angefasst)
- `docs/plan/adr/0028-…` (Skill gehört der ausführenden Rolle)

Die Diff-Range `bdda8a7a~1..0c6ea92c` enthält zusätzlich den Commit `e125a385`
(Reviewer-Skill 2.3.0). Der ist nicht Gegenstand dieses Slice — er trägt selbst eine
`Rolle Reviewer:`-Message aus einer vorherigen Review-Runde eines anderen Slice und liegt
nur wegen der linearen Historie im Bereich. Er wird hier nicht bewertet.

---

## Eigene Nachvollzüge (unabhängig vom Implementer-Bericht)

Alle Kommandos in einer `git archive HEAD`-Kopie im Scratchpad gefahren, nicht im
Arbeitsbaum. Digest-Prüfung per Docker-Host-Werkzeugen (AGENTS.md §3.9 erlaubt sie
ausdrücklich, verboten sind Host-Toolchains in Befehlsposition).

1. **Digest unabhängig verifiziert — drei Wege, alle einig:**
   `docker manifest inspect -v ghcr.io/pt9912/d-check:v0.79.0` → `sha256:b4b8756b40d3dcd2670a3f83526cb5e5d727d1a850571f73be31edba248abb40`;
   `docker pull ghcr.io/pt9912/d-check:v0.79.0` → dieselbe Digest-Zeile;
   `docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.79.0`
   → dieselbe. Deckt sich mit `d-check.mk`/`internal/emit/emit.go`.
2. **Fragment-Diff selbst gefahren:**
   `diff <(docker run --rm --network none ghcr.io/pt9912/d-check@sha256:b4b8756… --print-mk) d-check.mk`
   → **6** Hunks (`grep -c '^[0-9]'`), dieselbe Zahl wie beim Vorgänger-Pin (MR-068). Gelesen (nicht
   nur gezählt): Hunk 1 Adopter-Kopf, Hunk 2 `DCHECK_DIGEST` pinnen, Hunk 3
   `.PHONY`/Target-Zeile `doc-check`→`docs-check`, Hunk 4 `doc-help` (`^doc-`→`^docs?-`), Hunk 5+6 die
   Marke an `doc-tracked` (Hilfetext-Anhang + `@echo`-Zeile, MR-062). **Wichtiger Befund:** Die
   sechsfache Ergänzung `--disable file` an den Ein-Modul-Recipes (`doc-immutable`, `doc-commits`,
   `doc-planning`, `doc-tracked`, `doc-targets`, `doc-structure`) erzeugt **keinen zusätzlichen
   Diff-Hunk** — sie steht bereits in der rohen `--print-mk`-Ausgabe von v0.79.0 selbst (das Tool
   disabled für diese Recipes automatisch jedes ihm bekannte opt-in-Modul, das die `.d-check.yml`
   nicht aktiviert; `file` ist seit v0.78.0 ein solches). Die Implementer-Aussage „kein neuer
   Handgriff, nur Wachstum des tool-generierten Anteils" ist damit nicht nur plausibel, sondern am
   Diff **strukturell nachweisbar**: Es gibt keine Entscheidung „aktivieren oder deaktivieren" —
   das Tool liefert die Deaktivierung bereits mit, unverändert vom bestehenden Muster (fünf
   Recipes disablen alle opt-in-Module außer dem eigenen).
3. **Rot-Bedingung der Pin-Kopplungstests real gefahren, beide Richtungen:**
   Digest in `d-check.mk` verstellt (emit.go unverändert) → `make test-go` Exit **2**,
   `TestDefaultDigest_MatchesCanonical` mit `emit.DefaultDigest "sha256:b4b8…" != kanonische
   Pin-Quelle "sha256:000…" (Drift)`. Tag verstellt → Exit **2**,
   `TestDefaultImage_MatchesCanonical` mit `(Tag-Drift)`. Zurückgesetzt → `make test-go` grün (alle
   acht Pakete `ok`).
4. **L2 „0 neue Befunde" real geprüft:** `make docs-check` gegen die unveränderte Kopie
   → Exit **0**, `d-check: 2069 Datei(en) geprüft, 0 Befund(e)`.
5. **MR-063-Sonden für drei der sieben vom Implementer selbst als ungedeckt benannten Module
   nachgefahren** (links, anchors, structure — zusätzlich zu den vom Implementer belegten
   codepaths/ids): In einer frischen Kopie ein Report mit totem Link (`links`/`target-missing`),
   Repo-Escape-Link (`links`/`repo-escape`), Link mit fehlendem Anker auf `AGENTS.md`
   (`anchors`/`anchor-missing`) sowie eine `done/`-Slice-Probe ohne die Pflicht-Sektion
   (`structure`/`section-missing`) angelegt und gegen `sha256:b4b8756…` (v0.79.0) gefahren:
   `make docs-check` → Exit **2**, alle vier erwarteten Grund-Codes plus `closure-note-thin`
   erschienen. Ergebnis: **keine Senkung** an diesen drei zusätzlich geprüften Modulen — sie
   funktionieren unverändert unter v0.79.0. Damit sind jetzt **5 von 9** aktiven Modulen
   (codepaths, ids vom Implementer; links, anchors, structure von mir) mit einer dedizierten
   Fund-Probe gegen v0.79.0 belegt. **Nicht selbst nachgefahren:** matrix, spans, planning,
   targets (4 von 9) — budgetbedingt nicht gefahren, bleiben eine offene Lücke (s. Finding F-1).
6. **L3-Sonde selbst nachvollzogen, inklusive Gegenprobe gegen den alten Digest:** Report mit
   (a) Link, dessen Ziel hinter dem `](`-Zeilenumbruch steht, und (b) Referenz-Definition
   `[label]: <toter-pfad> "Titel"` angelegt. Gegen `v0.79.0` (`sha256:b4b8756…`): Exit **2**,
   **beide** Zeilen melden `target-missing` — die Zeile mit dem Zeilenumbruch-Ziel auf der
   Zielzeile, die Referenz-Definition auf ihrer eigenen Zeile. Zur Kontrolle **zusätzlich** gegen
   den **alten** Digest `sha256:3f84502b…` (v0.77.0) gefahren (über
   `make docs-check DCHECK_IMAGE=… DCHECK_DIGEST=…`, keine Datei geändert): Exit **0**, **0
   Befunde** — exakt das frühere „schweigt"-Verhalten, das die zwei Sensor-Dateien vor diesem
   Slice beschrieben. Diese Vorher/Nachher-Gegenprobe bestätigt die Kausalität des Sprungs
   unabhängig und über das vom Implementer Berichtete hinaus.
7. **Sensor-Doc-Text (§3.6/§3.7) gelesen:** Beide geänderten Absätze in
   `harness/sensors/slice-mv.md` und `harness/sensors/archive-welle.md` stehen im Indikativ
   („meldet es als `target-missing`", „färbt … mit `target-missing`"), tragen je einen
   „gefahren an …"-Beleg und benennen weiterhin explizit, was **nicht** gefahren wurde
   („für die Klammern hinter dem Segment nicht gefahren"). Keine Überbehauptung gegenüber dem
   selbst Gemessenen gefunden — die neuen Sätze sagen nicht mehr, als die eigene Sonde (Punkt 6)
   und die dort referenzierten Tests belegen.
8. **§3.8-Grenze bestätigt:** `git diff --stat bdda8a7a~1..0c6ea92c` führt `harness/conventions.md`
   und keine Datei unter `harness/conventions/` — der neue Adaptions-Eintrag (angekündigt als
   nächste freie Nummer in §6 der Planung) ist **nicht** Teil dieser Commits. Korrekt: das ist
   Architect-Arbeit (§3.8), die Übergabe steht explizit in §6 des Slice-Plans.
9. **Abschluss-Läufe auf dem realen Arbeitsbaum** (unverändert, kein Review-Commit zu diesem
   Zeitpunkt): `make docs-check` → Exit 0, `d-check: 2069 Datei(en) geprüft, 0 Befund(e)`.
   `make gates` → Exit 0.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die Strenge-Bilanz, die DoD-L2 und Closure-Trigger 2 der Planung für den Adaptions-Eintrag verlangen (Gegenmessung nach dem MR-063-Verfahren, Sonde je der neun aktiven Module, alte gegen neue Fragmente), steht in keinem der geprüften Commits — weder die vom Implementer berichtete Teilmessung (Marker-Entwertungs-Stufe, 2 von 9 Modulen, 73 Befunde) noch eine vollständige Messung ist in `12f30003` oder `0c6ea92c` dokumentiert. Der Vorgänger-Sprung (Commit `cb3bc567`, MR-068) trug diese Zahlen vollständig in der eigenen Commit-Message; dieses Muster ist hier nicht fortgesetzt. | `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln, Slice-Plan §2 (L2) und §5 (Closure-Trigger 2) | Slice-Plan §2/§5; Commits `12f30003`, `0c6ea92c` | ja — ein `git log`-Blick auf `12f30003`/`0c6ea92c` bzw. der fehlende Beleg im Adaptions-Eintrag | Strenge-Bilanz eines Pin-Sprungs fehlt im Umsetzungs-Commit trotz etabliertem Vorgänger-Muster |

Kein HIGH gefunden: keine Verletzung einer aktiven ADR/Hard Rule, keine Gate-Lockerung (die
zwei neuen `links`-Prüfungen sind eine Verschärfung, korrekt nach §3.6 ohne ADR begründet und
selbst nachgemessen), kein stilles Grün (die zwei betroffenen Sensor-Dateien wurden korrekt auf
den neuen, real gemessenen Ist-Zustand gezogen), kein halluziniertes Gate, keine Referenz auf
eine superseded ADR, keine Norm nur im Template-Kommentar, kein Kommentar ohne
Kommentar-Klasse, kein Zustandsfeld mit Chronik.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `d-check.mk` (Pin, Kopfkommentar, `--disable`-Listen) | geprüft, ohne Befund — Fragment-Diff, Digest und die sechsfache `--disable file`-Ergänzung selbst nachvollzogen (s. o.) |
| `internal/emit/emit.go` (`DefaultImage`/`DefaultDigest`) | geprüft, ohne Befund — deckungsgleich mit `d-check.mk`, Kopplungstest real rot/grün gefahren |
| `internal/emit/emit_test.go` (unverändert) | geprüft, ohne Befund — Rot-Bedingung real bestätigt, kein Diff nötig |
| `.d-check.yml` (unverändert) | geprüft, ohne Befund — `git diff --stat` führt die Datei nicht, `docs-check` grün über dem realen Bestand |
| `harness/sensors/slice-mv.md`, `harness/sensors/archive-welle.md` | geprüft, ohne Befund — Textänderungen im Indikativ, mit „gefahren an …"-Beleg, keine Überbehauptung gegenüber der eigenen Nachprobe |
| `docs/plan/planning/in-progress/roadmap.md` (Ruhe-Marker-Entfernung, Claim) | geprüft, ohne Befund — reiner Claim-Schritt, kein Inhalt dieses Slice |
| `harness/conventions.md` / `harness/conventions/` | geprüft, ohne Befund — unangetastet, korrekt an Architect übergeben (§3.8) |
| Kommandozeilen-Guard-Konformität (Host-Toolchains) | geprüft, ohne Befund — nur `docker`/`git`/`make` in Befehlsposition, wie AGENTS.md §3.9 verlangt |
| Commit-Messages (Traceability, Rollen-Präfix) | geprüft, ohne Befund — alle drei tragen `Rolle Implementer:`, `MR-052`, `AGENTS.md §3.5`, konkrete Rot-/Grün-Belege |
| Mutations-Deckung (`make mutate`) | nicht gefahren — kein neuer Wächter/Test in diesem Diff, Auftrag schließt vollen `make mutate`-Lauf ausdrücklich aus |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Strenge-Bilanz eines Pin-Sprungs fehlt im Umsetzungs-Commit
trotz etabliertem Vorgänger-Muster

## Verdikt

**Merge-blockierend:** nein — das MEDIUM-Finding (F-1) betrifft eine Nachweispflicht, die laut
Slice-Plan ohnehin erst zur Closure hin (Architect-Übergabe §6, Closure-Trigger 2) vollständig
erfüllt sein muss, nicht bereits im hier geprüften Zwischenstand. Es blockiert nicht den
Fortgang zu L2/Closure, muss aber vor der Closure nachgeliefert werden (in den Adaptions-Eintrag
und, den etablierten Vorgänger-Mustern folgend, idealerweise auch in einen Commit dieses Slice),
sonst kann Closure-Trigger 2 nicht erfüllt werden. Alle selbst gefahrenen Belege (Digest, drei
unabhängige Wege; Fragment-Diff, gelesen; beide Kopplungstest-Rot-Bedingungen; L2-Grünlauf;
fünf von neun Modulen mit dedizierter Fund-Probe inklusive Vorher/Nachher-Gegenprobe für die
L3-Sonde) decken sich mit dem Implementer-Bericht und widerlegen ihn an keiner Stelle.

**Übergabe:** Findings gehen an den Implementer. Die Finding-Klasse geht in die Slice-Closure
§7 und von dort in den Zähler. Dieser Report ist ein Lauf-Beleg und ersetzt keine Verifikation
gegen DoD/Spec (Modul 11, Verifier-Aufgabe).
