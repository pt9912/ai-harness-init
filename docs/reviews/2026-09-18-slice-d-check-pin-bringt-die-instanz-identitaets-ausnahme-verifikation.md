# Verifikations-Report: slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme — 2026-09-18

**Verifikation (Modul 11):** geprüft gegen den Slice-Plan (`docs/plan/planning/in-progress/slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme.md`) und die kanonischen Quellen, auf die er sich beruft. Nicht geprüft: der Review — der ist Runde 1 durch (`docs/reviews/2026-09-18-slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme-runde-1.md`, Verdikt nicht merge-blockierend).

**Gegenstand:** `cb3bc567` (Implementer: `d-check.mk`, `internal/emit/emit.go`) · `3aec7e7d` (Architect: MR-068) · `cf0d947d` (Reviewer) · `a1efbf79` (Architect: F-2 gezogen). Kopf des Baums `a1efbf79`, gepusht.

**Modell:** glm-5.3-flash (Claude Agent SDK) · **Datum:** 2026-09-18

**Eigenes Messwerk dieses Laufs** (Wegwerf-Kopien unter `/tmp/verify-pin-680/`, nicht der Arbeitsbaum; beide Digests `2f2f24…`/`3f8450…` lokal vorhanden, alle Läufe `--network none`):

```sh
rm -rf /tmp/verify-pin-680 && mkdir -p /tmp/verify-pin-680/plain && git archive cb3bc567 | tar -x -C /tmp/verify-pin-680/plain
docker run --rm --network none -v /tmp/verify-pin-680/plain:/repo:ro ghcr.io/pt9912/d-check@sha256:3f84502b09af65246fff38b1c3893130050e50581943a0434da95bf68091e337
```

---

## 1. DoD, Punkt für Punkt

| DoD-Punkt | Verdikt | Beleg |
|---|---|---|
| **L1** Pin `v0.77.0` + Digest + re-adaptiertes Fragment an der ersten Stelle | **erfüllt** | `d-check.mk:77-78` trägt Tag und Digest (gelesen); Digest lokal belegt: `docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.77.0` → derselbe Wert `sha256:3f84502b…`; die zwei Netzwege stehen im Umsetzungs-Commit und wurden nicht wiederholt. Kopfkommentar nennt `v0.77.0` (Zeilen 5, 78). Hunk-Zahl 6 / 5 Handgriffe getrennt — vom Reviewer mit dem kanonischen Kommando gemessen (Regelfall 6, Fragment mit ungleichem Tag 5), Mechanismus (`1,15c1,76`) gelesen. Beide `--disable`-Kopplungs-diffs im Makefile nachgefahren (Kommandos aus `d-check.mk:205` und `Makefile:246`): beide leer (Exit 0). |
| **L2** emittierter Pin + Kopplung | **erfüllt** | `internal/emit/emit.go:32-33` trägt dieselben Werte (gelesen); `emit_test.go` über die Range unverändert (`git diff --stat cb3bc567^ a1efbf79 -- internal/emit/emit_test.go` → leer). Rot-Bedingung einmal gefahren: Rotation real im Wegwerf-Klon durch den Reviewer — `make test` Exit 1 mit beiden Testnamen in der Fehlerklasse (Review-Report, Negativbefunde). Nicht von mir wiederholt; der Beleg trägt am Review-Report. |
| **L3** Strenge-Bilanz, keine Senkung, Fähigkeit ohne Gegenstand | **erfüllt** | Siehe §2 — die Bilanz wurde in diesem Lauf **nachgefahren**, nicht übernommen. Quell-Differenz am Klon `/Development/d-check` (nur lesend): `git -C "$D" diff --numstat v0.76.3 v0.77.0 -- internal/hexagon/core/rules/` → genau `matrix.go` 61/10 und `matrix_test.go` 71/0; `allow-if-same-id` außerhalb `rules/` in genau `configyaml.go` (+Test) — kein Regel-Code. Symlinks: `git ls-tree -r HEAD .claude/rules/ \| awk '$1=="120000"' \| wc -l` → 10, `find .claude/rules -type l \| wc -l` → 10, `find .claude/rules -type f \| wc -l` → 0. Fähigkeit ohne Gegenstand: `git grep -n 'allow-if-same-id'` ohne Plan/Review/Adaptions-Block → kein Treffer; `grep -c 'token' .d-check.yml` → 0; emittierte Vorlage: genau die drei Token-Klassen `slice`/`welle`/`adaptionsblock` (`grep -n 'token:' internal/emit/templates/d-check.yml`). |
| `make gates` grün mit `v0.77.0` an beiden Stellen | **erfüllt** | Beide Stellen gelesen (oben); Stufe 1 der Bilanz über die Wegwerf-Kopie: beide Digests 1695 Dateien, 0 Befunde, Exit 0. Der Gate-Lauf über `a1efbf79` ist Auftraggeber-Angabe (Briefing) und wurde nicht wiederholt. |
| Bilanz im Umsetzungs-Commit **und** im Adaptions-Eintrag, Eintrag hat Review | **erfüllt** | **Beide Orten:** die Message von `cb3bc567` trägt die volle Bilanz (Stufen 1–3, Verteilung je Grund-Code, Symlinks 10/10, Grenze `span-nested-link`); MR-068 §Gegenmessung trägt sie mit Prüf-Bedingung vor den Kommandos (MR-067) und der MR-065-Angabe („kein Objektspeicher, keine Packs, keine Alternates, keine losen Objekte"). Review: Report Runde 1 liegt vor, F-2 ist gezogen (`a1efbf79`). |
| Review durchgeführt, Report unter `docs/reviews/` | **erfüllt** | `cf0d947d`, Verdikt nicht merge-blockierend. |
| Doku-Update nur über L3 hinaus, solange Gate-Namen gleich bleiben | **erfüllt** | `harness/README.md` über die Range unverändert (`git diff --stat cb3bc567^ a1efbf79 -- harness/README.md` → leer); kein Target hinzugekommen, also keine Gate-Index-Pflicht. |
| Closure-Notiz mit Lerneintrag · Register-Fortschreibung · Risiko-Ausgänge · drei Paarungen | **offen — fällig bei Closure** | Der Slice liegt in `in-progress/`; diese Punkte sind die Bedingung für den `git mv` nach `done/` und Träger ist der Planner-Zug (AGENTS.md §3.10). Nicht fehlend — noch nicht fällig. |

## 2. Die Bilanz ist in diesem Lauf nachgefahren, nicht übernommen

Der Reviewer hatte sie ausdrücklich nicht neu gemessen. Gemessen an Wegwerf-Kopien von `cb3bc567` (`git archive`, kein Objektspeicher), beide Digests je Lauf, `--network none`:

| Oberfläche | `v0.76.3` | `v0.77.0` | diff |
|---|---|---|---|
| unverändert | 1695 Dateien, 0 Befunde, Exit 0 | 1695 Dateien, 0 Befunde, Exit 0 | identisch |
| Marker in regulären Dateien entwertet (`sed s/d-check:ignore/d-check:IGNORIERT/g`, Symlinks stehen: 10/10, 0 reguläre) | **59 Befunde, Exit 1** | **59 Befunde, Exit 1** | volle Ausgaben identisch |
| zusätzlich `scan.ignore` entfernt | 1749 Dateien, 219 Befunde, Exit 1 | 1749 Dateien, 219 Befunde, Exit 1 | sortiert identisch |
| Matrix-Sonden am **geänderten** Grundcode (Link-Form `spec-straten → adr`; Token-Formen `slice-999` und `MR-999` in `spec/architecture.md`, Konfiguration der emittierten Vorlage) | 137 × `matrix-forbidden`, alle drei Sonden gefärbt | 137 × `matrix-forbidden`, alle drei Sonden gefärbt | sortiert identisch |

Damit ist die Kernbehauptung — **keine Senkung an den neun aktiven Modulen, byte-identisches Verhalten ohne den Schlüssel** — an vier Oberflächen direkt belegt, inklusive der Token-Form, dem einzigen Code, den der Sprung ändert. Die Verteilung der 59 Befund-Zeilen über die Grund-Codes ist in meinen Läufen zeilenweise identisch.

**Zwei Zahlen-Anmerkungen an MR-068** (keine DoD-Verletzung, aber Zellen, deren Kommando sie nicht ausgibt):

- **V-1 (LOW):** Die Tabelle im Eintrag nennt **1702 Dateien** je Stufe. Die ausgeschriebene Prozedur (Kopie von `cb3bc567`, Marker entwertet) liefert **1695**. 1702 reproduziert nur unter der Lesart, dass die sieben Sonden-Dateien bereits ab Stufe 1 im Baum lagen (1695 + 7); das steht so im Eintrag nicht. Die Befundzahlen 0/59/78 und die Gleichheit reproduzieren.
- **V-2 (LOW):** Der Eintrag nennt **Exit 2** für die Stufen 2 und 3. Gemessen: **Exit 1** bei Befunden, Exit 0 bei 0 Befunden. Exit 2 ist laut §1 des Plans die Nummer des Config-Rands (`allow-if-same-id` ohne Capture-Gruppe) — sie passt nicht auf eine Befund-Stufe.

Beide Zellen sind Form-Fragen des Eintrags, nicht des Sprungs; die tragende Aussage (Gleichstand) trägt an beiden Stellen. Sie gehen als Hinweis an den Architect, nicht als Übergabe-Artefakt an den Planner.

## 3. Abgrenzung §1 — der Diff hält sie ein

| Ausschluss | Verdikt | Beleg |
|---|---|---|
| `allow-if-same-id` wird nicht gesetzt | **erfüllt** | `git grep -n 'allow-if-same-id'` ohne Plan/Review/Adaptions-Block → kein Treffer. |
| Kein Modul aktiviert, keine Regel der `.d-check.yml` geändert | **erfüllt** | `git diff --stat cb3bc567^ a1efbf79 -- .d-check.yml .github/workflows/ci.yml AGENTS.md harness/sensors/ Makefile internal/emit/testdata/raw-print-mk.txt` → leer. `modules:`-Zeile unverändert: 9 Module (`links, anchors, ids, matrix, codepaths, spans, planning, targets, structure`). |
| Keine ADR | **erfüllt** | `git show --stat cb3bc567 3aec7e7d a1efbf79`: nur `d-check.mk`, `internal/emit/emit.go`, `harness/conventions.md`, die Eintrags-Datei. Keine ADR-Datei. |
| `raw-print-mk.txt` bleibt | **erfüllt** | über die Range unverändert (leerer diff --stat, oben). |
| Objektspeicher des Arbeitsklons bleibt | **nicht widerlegt** | Die Gegenmessung lief laut Eintrag/MR-065-Angabe an der `git archive`-Kopie; der Arbeitsbaum trägt heute keine Spur einer Umstellung (`git status` clean). Eine nachträgliche Messung des Objektspeichers ist über den Stand nicht möglich — Beleg bleibt die MR-065-Angabe des Eintrags. |

**Der Umsetzungs-Commit bewegt genau die zwei geplanten Stellen** (`git show --stat cb3bc567`: `d-check.mk` 14 Zeilen, `internal/emit/emit.go` 4 Zeilen) — keine „kleine Verbesserung" ist mitgewandert.

**Keine dritte Pin-Stelle:** `git grep -ln 'v0\.77\.0\|3f84502b' -- ':!*.md'` → genau `d-check.mk` und `internal/emit/emit.go`.

## 4. Plan-vs-Code-Diff (beide Richtungen)

**Geplant und gebaut:** `d-check.mk` (update, L1) · `internal/emit/emit.go` (update, L2) · `emit_test.go` unverändert (L2) · `raw-print-mk.txt` unverändert (§1) · Makefile unverändert, geprüft (L1) · Adaptions-Eintrag MR-068 samt Index-Zeile und `d-check:`-Zeile (Architect, eigener Commit) · AGENTS.md/`.d-check.yml`/ci.yml/`harness/sensors/` unverändert (L3) · keine ADR. **Alles deckungsgleich.**

**Gebaut, aber nicht geplant:** nichts. Die zwei Zahlen-Anmerkungen V-1/V-2 aus §2 betreffen Zellen im Eintrag, nicht gebaute Artefakte.

**Geplant, aber offen:** die Closure-Punkte der DoD (Notiz, Register, Risiko-Ausgänge, Paarungen) — Träger ist der Planner-Zug vor dem `git mv`, nicht dieser Lauf.

## 5. F-1 (MEDIUM, `neuer-waechter-ohne-mutations-fall`) — die Einordnung „nicht blockierend" trägt

Prämissen bestätigt: `grep -rln 'DCHECK_DIGEST\|DCHECK_IMAGE\|DefaultDigest\|DefaultImage' test/mutations/` → kein Treffer; der bestehende Fall `01-baseline-pin-kopplung.sh` deckt die Baseline-Pins, nicht den d-check-Pin.

Die Einordnung trägt aus drei Gründen: (1) Die Zusage aus L2 ist die **Kopplung** durch `emit_test.go`, und ihre Zähne sind real rot gemessen — der Reviewer hat die Rotation im Wegwerf-Klon gefahren, beide Testnamen stehen in der Fehlerklasse; der Wächter trägt, auch ohne kuratierten Fall. (2) Der fehlende Fall ist ein Bestands-Defekt der Mutations-Kuratierung, kein Bruch dieses Slices — `make mutate` misst gelistete Wächter, und die Entstehung neuer Zähne ist Pflicht der Pre-completion-Checkliste, nicht des Mutations-Laufs (AGENTS.md §3.6). (3) Der Ausgang ist verdrahtet: der Reviewer hat den Register-Beleg für die Slice-Closure benannt.

**Klassenzuordnung:** ich führe den Befund als **dieselbe Klasse** — `BEO-ALL/neuer-waechter-ohne-mutations-fall` existiert bereits als Register-Verzeichnis; der Beleg geht bei Closure als weitere `evidence/`-Datei dorthin, kein neues Verzeichnis. Der Zähler folgt aus den Dateien.

## 6. Kopf-Marken-Entscheidung — vermerkt, nicht bewegt

Die Entscheidung „keine Kopf-Marken an MR-066/MR-064/MR-065" (MR-032 Setzung 4: Pin-Eintrag datiert einen Sprung, nichts wird abgelöst) ist vom Review-Runde 1 abgenommen. Ich vermerke sie hier als entschieden und prüfe sie nicht neu; in diesem Lauf ist kein Gegenbeispiel gegen sie aufgefallen.

## 7. Negativbefunde — geprüft und nicht beanstandet

- Makefile-`--disable`-Kopplung: beide Kopplungs-diffs leer (nachgefahren, Exit 0).
- Quell-Differenz am Werkzeug-Klon `/Development/d-check` (nur lesend): exakt die zwei Dateien der Behauptung; `configyaml.go` ist Config-Rand, kein Regel-Code.
- §1-Token-Behauptungen: Dogfood ohne `token` (grep Exit 1); emittierte Vorlage mit genau drei Token-Klassen und den im Plan genannten Pfad-Mengen.
- MR-068-Form: Mess-Stand-Datierung der Werkzeug-Aussagen (MR-053), Prüf-Bedingung vor den Kommandos (MR-067), MR-065-Angabe je history-lesendem Lauf, Messwerte an `cb3bc567` gebunden (MR-051) — gelesen, ohne Befund.
- F-2 (LOW, Sprung-Liste): behoben — die Zeile liest jetzt „… MR-064, MR-066 und MR-068" mit einem „und" vor dem letzten Glied (`sed -n '22p' harness/conventions.md`).
- MR-054: die emittierte Startkonfiguration ist nicht mit dem Pin bewegt (Templates über die Range unverändert; `cb3bc567` berührt nur die zwei Pin-Konstanten).
- Keine fremden Kennungen, keine Suppression-Zeile (§3.2) in den drei Commits; alle Mess-Kommandos dieses Laufs Docker-only (§3.9) an Wegwerf-Kopien.
- Keine neue Spec-Lücke gefunden; die Berührte-Spec-Stellen-Zelle des Plans (`—`) bleibt sachgerecht.

## 8. Ergebnis

**Der Slice ist DoD-konform; kein Übergabe-Artefekt an den Planner aus der DoD.** Die drei Liefer-Punkte sind erfüllt und — über die Review-Belege hinaus — die Strenge-Bilanz in diesem Lauf selbst nachgefahren. Offen sind ausschließlich die Closure-Punkte der DoD, deren Träger der Planner-Zug ist (§3.10). Die zwei Zahlen-Anmerkungen V-1/V-2 an MR-068 gehen an den Architect; sie sind nicht merge-blockierend und nicht DoD-tragend.