# Review-Report: slice-d-check-pin-bringt-die-stilllegungs-bedingung — 2026-09-17

**Review-Art:** Code — gegen den Slice-Plan, die referenzierten Adaptions-Einträge und die Hard
Rules (`AGENTS.md` §3). ADR- und MR-Änderungen sind auf Konsistenz geprüft (`v6.9.0` ·
`regelwerk/modul-08-agentenrollen.md` §Rollen-Regeln).

**Gegenstand:** `git diff d46a7123..9f6484a9`, sechs Commits:

| Commit | Rolle | Dateien (`git log --stat`) |
|---|---|---|
| `0fbefa46` | Implementer | `.d-check.yml`, `d-check.mk`, Slice-Plan §3, `harness/sensors/commit-msg-check.md`, `harness/sensors/docs-check.md`, `internal/emit/emit.go` |
| `966458a5` | Architect | `harness/conventions.md`, Eintrag `MR-061` |
| `675d1f03` | Implementer | `Makefile`, `d-check.mk` |
| `b6219b1c` | Implementer | `Makefile` |
| `87ef3941` | Architect | `harness/conventions.md`, Einträge `MR-010` (Kopf-Marke) und `MR-062` |
| `9f6484a9` | Implementer | `d-check.mk` |

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0
**Modell:** `claude-opus-5[1m]` · **Datum:** 2026-09-17

> **Zitier-Form.** Dieser Report friert ein. Der Slice und die Adaptions-Einträge stehen darum
> bei ihrer Kennung, eine Baseline-Stelle als Tag + Pfad in Inline-Code. Die `Pfad`-Spalte hält
> den Stand dieses Laufs (`HEAD` = `9f6484a9`).

**Eingangs-Kontext:**

- Slice-Plan `slice-d-check-pin-bringt-die-stilllegungs-bedingung` (Stand `9f6484a9`)
- `ADR-0042` (Re-Evaluierungs-Trigger 2)
- `LH-QA-01`, `LH-QA-02`
- `MR-010`, `MR-027`, `MR-032`, `MR-046`, `MR-052`, `MR-053`, `MR-060`, `MR-061`, `MR-062`
- `AGENTS.md` §3.1, §3.4, §3.5, §3.6, §3.7, §3.8, §3.9, §3.11
- vorheriger Lauf an derselben Linie: der Review-Report zu `slice-187` (Pin `v0.65.0` → `v0.74.1`)
- Fremdquelle, nur lesend: der lokale Klon des d-check-Repos

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Drei Kommentare, die dieser Diff schreibt oder ändert, tragen das Protokoll eines Laufs statt der Stelle. Neu geschrieben ist *„(seit v0.74.1, unter v0.76.0 auf einer Nicht-Null-Basis nachgemessen)"*. Geändert sind *„gemessen unter v0.74.1 an einer Sonde ueber einer Kopie, …, `1 Befund`"* und *„gemessen (v0.74.1, v0.76.0) bricht der gepinnte d-check … ab"*. Beim nächsten Pin-Sprung liest der nächste Lauf *„unter v0.76.0 nachgemessen"* als Beleg für einen Stand, der nicht mehr gepinnt ist. Genau diese Drift schließt die Quellen-Klausel aus. `MR-053` deckt die Form nicht, denn sein Geltungsbereich sind die Einträge des Adaptions-Blocks, nicht Kommentare. | `AGENTS.md` §3.7 (Quellen-Klausel ab 2026-08-30; gebunden ist jeder geschriebene oder geänderte Kommentar) | `d-check.mk:48-49` (neu), `d-check.mk:38-40` (geändert), `.d-check.yml:372` (geändert) | nein — §3.7 nennt selbst keinen Wächter | Lauf-Protokoll im Kommentar |
| F-2 | MEDIUM | Die Gegenmessung „auf Nicht-Null-Basis" deckt nur drei der acht aktiven Module: Die 379 Befunde tragen allein `target-missing` (`links`), `id-unlinked` (`ids`) und `codepath-missing` (`codepaths`). Für `anchors`, `matrix`, `spans`, `planning` und `targets` ist die Basis leer und die Wegfall-Richtung informationsleer. Alle 319 `target-missing` liegen unter `.claude/rules/`. Das sind zehn git-Symlinks (Modus `120000`), die das `sed -i` der Methode in reguläre Dateien mit gebrochenen relativen Links verwandelt. Die Basis von `links` ist also ein Nebeneffekt der Kopie, nicht der entwerteten Marker. Der Eintrag nennt beides nicht, schreibt die Methode als permanente Pflicht in seinen Auflösungs-Trigger und begründet „Kein ADR nötig" mit *„auf einer Basis, die einen Wegfall gezeigt hätte"*. Für fünf Module trägt diesen Schluss die leere Quell-Differenz, nicht die Messung. | `MR-027` §Auflösungs-Trigger · `AGENTS.md` §3.5 | `MR-061` §Gegenmessung auf Nicht-Null-Basis, §Kein ADR nötig, §Auflösungs-Trigger | ja — `cut -f3` über der Befundliste der Kopie, dazu `git ls-tree 0fbefa46 .claude/rules/` | Stellen-Messung als Eigenschaft ausgegeben |
| F-3 | LOW | `MR-061` spricht von *„Die vier Anker aus MR-010 §Auflösungs-Trigger"*, `MR-010` nennt dort fünf: `DCHECK_IMAGE ?=`, `.PHONY: doc-check`, `doc-check:`, die leere `DCHECK_DIGEST ?=`-Zeile und `'^doc-[a-z-]+:`. Welche vier gemessen sind, bleibt offen. Gemessen in diesem Lauf trifft jeder der fünf die `v0.76.0`-Ausgabe und die Fixture genau einmal, der Schluss *„die Fixture bleibt"* hält also. | `MR-010` §Auflösungs-Trigger | `MR-061` §Das Fragment | ja — je ein `grep -c` über der frischen `--print-mk`-Ausgabe | Zahl weicht von der zitierten Quelle ab |
| F-4 | LOW | Die Datei-Tabelle in §3 des Plans führt `Makefile` nicht, obwohl zwei Implementer-Commits die Datei ändern: `675d1f03` (`commit-msg-check` erhält `--disable mentions`) und `b6219b1c` (`regelwerk-check` erhält `--disable targets`, Kommentar neu). `0fbefa46` hat §3 für `.d-check.yml` und `commit-msg-check.md` nachgezogen, die späteren Commits nicht. Die Behebung der veralteten *„sieben"* in `regelwerk-check` ist damit Wachstum, das der Plan nicht zeigt. | `v6.9.0` · `regelwerk/modul-09-implementierung.md` (*„Der Plan lebt in §3 des Slice-Plans"*) | Slice-Plan §3; `Makefile:204`, `Makefile:234-242` | nein | Diff-Datei fehlt in der Plan-Tabelle |
| F-5 | INFO | Der Kommentar an `regelwerk-check` sagt, die `--disable`-Flags nennen *„genau die Module"*, und belegt das mit einem Paar aus Zählkommandos. Gleiche Zahlen sind keine gleichen Namen: Tauscht ein Wechsel ein Modul gegen ein anderes, bleiben beide Zahlen gleich. Heute sind die Namensmengen deckungsgleich (`comm -3` leer), und ein Sensor fährt das Paar nicht. | Maintainability | `Makefile:234-240` | nein | Zählgleichheit als Mengengleichheit ausgegeben |
| F-6 | INFO | Der Geltungsbereich von `MR-061` sagt *„ihre Zahl setzt MR-010 Setzung 1"*. Seit `MR-062`, im selben Slice, setzen `MR-010` Setzung 1 und `MR-062` die Zahl gemeinsam. Der Zeiger löst über die Kopf-Marke an `MR-010` auf, und `MR-032` Setzung 4 nimmt Pin-Einträge von der Marke aus. Ein Defekt ist das nicht, nur ein Zeiger über eine Station. Zuständig ist der Architect. | `MR-032` Setzung 4 | `MR-061` §Geltungsbereich | nein | Zeiger auf eine inzwischen abgelöste Setzung |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Digest `sha256:f0b55fde…945396` ↔ `v0.76.0` | geprüft, ohne Befund. `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.76.0` → `Digest:` derselbe Wert; lokaler `RepoDigests` derselbe; Label `org.opencontainers.image.version` = `0.76.0`; das Benutzerhandbuch im d-check-Klon nennt ihn (1 Zeile). |
| Pin-Kopplung `d-check.mk` ↔ `internal/emit/emit.go` | geprüft, ohne Befund. Tag und Digest sind gleich. Der `ci`-Workflow ist für `9f6484a9` `success` (`gh run list`); er fährt laut `harness/README.md` §Safety `make gates`, `make smoke` und `make full-smoke`. Das Rot der zwei `TestDefault*`-Tests aus DoD 1 ist nicht nachgefahren (Verifier). |
| Fragment gegen `--print-mk` | geprüft, ohne Befund. Beide Digests liefern 76 Zeilen. Alte gegen neue Ausgabe: 7 Hunks (`DCHECK_IMAGE`, sechsmal `--disable mentions`). Neue Ausgabe gegen `d-check.mk` an `HEAD`: 8 Hunks, ebenso `v0.74.1` gegen `0fbefa46^`. 13 Targets in beiden Ausgaben und im Fragment. Die Aufzählung 1–5 im Kopf deckt die 8 Hunks: `1,13c1,72`, `15c74`, `26,27c85,86`, `75,76c136,137` und die vier Marken-Hunks `59c118 60a120 67c127 68a129`. |
| Kopf von `d-check.mk`, Modul-Aussagen | geprüft, ohne Befund. Es sind sechs opt-in-Module, `mentions` ist das 23. (`--disable`-Namen 22 → 23). *„FUENF alle SECHS"* trifft zu (`doc-structure` schaltet fünf ab). `grep -c '^structure:' .d-check.yml` → 0. Befund zur Form: F-1. |
| Strenge-Bilanz, Quell-Differenz | geprüft, ohne Befund zum Schluss (zur Methode: F-2). `numstat` über die acht aktiven Regeldateien ist leer, und beide Tags führen die acht unter denselben Pfaden. Die geteilte Infrastruktur umfasst 13 Dateien. `rules/run.go` ist gelesen: reine Durchreichung von `notes`, kein aktives Modul verliert einen Pfad. `rules/vcs.go` liest bei `VCSAdded` den BASE-Stand und bricht bei Fehler ab, wie im Eintrag beschrieben. Die Grenze *„Den abbrechenden Fall misst dieser Eintrag nicht"* ist benannt. |
| Gegenmessung, nachgefahren | geprüft, reproduziert. Eigene Kopie `git archive 0fbefa46`, Marker außerhalb der Baseline entwertet (Rest 0). Beide Digests liefern `1575 Datei(en) geprüft, 379 Befund(e)`, Exit 1. Der `diff` der sortierten Zeilen ist leer, die Verteilung beidseitig 21/39/319, `NF` = 4. |
| `ADR-0042` Trigger 2 | geprüft, ohne Befund. Der `--print-config`-`diff` zählt 14 Zeilen. Weder `mentions` noch `open-tasks-require-marker` hält Status und Adress-Form zusammen, und `planning.go` ist unverändert. „Nicht eingetreten" ist nachvollziehbar. |
| `MR-061`: Datierung, Kopf-Marke, `vcs` | geprüft, ohne Befund (außer F-2, F-3, F-6). Jede Werkzeug-Aussage nennt `v0.74.1` oder `v0.76.0` (`MR-053`). „Ohne Kopf-Marke an `MR-052`" trägt, denn `MR-032` Setzung 4 nimmt die Pin-Kette aus. Stichproben: `make doc-commits RANGE=HEAD~3..HEAD` → `Range-Basis-Vorfahren nicht lesbar`, make-Exit 2; `make commit-msg-check` mit Kennung → make-Exit 0, ohne Kennung → `commit-untraceable`, make-Exit 2; `make adr-immutable RANGE=8ae647cc~1..8ae647cc` (fügt `ADR-0056` hinzu) → `0 Befund(e)`, make-Exit 0. |
| `MR-062`: echte Adaption, Kopf-Marke | geprüft, ohne Befund. Beide `modul-02`-Zitate stehen je einmal in `v6.9.0`. Die Marke ist Recipe-Form, die sonst das Werkzeug pflegt, also eine deklarationspflichtige Abweichung. Die Kopf-Marke an `MR-010` steht im selben Commit wie `MR-062` (`MR-032` Setzung 3) und in der Form `ÜBERHOLT: <Reichweite> → <Ziel>. <Fortgeltung>` (Setzung 1). Die Datei bleibt aktiv (`MR-046`). Nachgemessen: `grep -cE …keinen eigenen Block` an `0fbefa46` → 2; `internal` → 0 Treffer; die Hunk-Kennungen unter beiden Digests; `slice-217` liegt in `done/`. |
| bats-Wächter der Marke, rot | geprüft, Ursache richtig. In einer eigenen Kopie von `HEAD` sind beide Marken-Formen entfernt: `not ok 1` an `diff <(echo "$c") <(echo "$hilfetext")`, erwartet `doc-structure`/`doc-tracked`, gefunden leer; `ok 2` bleibt. Die unveränderte Kopie ist grün (`ok 1`, `ok 2`). |
| Commit-Zuschnitt (`AGENTS.md` §3.8) | geprüft, ohne Befund. `966458a5` und `87ef3941` berühren nur `harness/conventions.md` und `harness/conventions/*` und nennen die Rolle. Kein Implementer-Commit berührt den Konventionsspeicher. Jede der sechs Messages trägt eine Kennung. |
| Append-only der Einträge (`MR-060`, Disziplin des Blocks) | geprüft, ohne Befund. `git log` nennt für `MR-061` nur `966458a5` und für `MR-062` nur `87ef3941`. An `MR-010` treten nur die zwei Kopf-Zeilen hinzu. Der Index führt beide Zeilen mit Kurz- und Slug-Anker, §Baseline nennt `MR-061` in der Pin-Kette. |
| `regelwerk-check` | geprüft, ohne Befund (zur Form: F-5). Das Paar liefert 8 = 8, und die Namensmengen sind gleich. `make regelwerk-check` → nur `sources` aktiv, `0 Befund(e)`, Exit 0. |
| Sensor-Dateien | geprüft, ohne Befund. `docs-check.md` und `commit-msg-check.md` führen genau die fünf `##` aus `gate.template.md` (`v6.9.0`), eigener Stoff steht als `###`. Der Diff berührt keine Exit-Aussage. Der neue Text zu `open-tasks-require-marker` deckt sich mit `--print-config` und `structure.go` (Überschuss gegen `max-open-tasks`, Marken-Abschnitt, `files:`-Glob wählt `done/`). Der Messstand ist mit Tag und Digest genannt. Die Stilllegungs-Tabelle ist nicht nachgefahren; gedeckt ist sie durch die unveränderte `planning.go` und das gelesene `run.go`. |
| Alter Digest in lebenden Artefakten (DoD 3) | geprüft, ohne Befund. `grep -n 'e31a372b' harness/sensors/docs-check.md` → kein Treffer. Die übrigen Treffer liegen in offenen Plänen (§1 schließt sie aus) und in `MR-052` (datiert). `Makefile:39` nennt `v0.74.1` nur als Parse-Beispiel, nicht als Messstand. |
| `AGENTS.md` §3.1, §3.4, §3.5, §3.9 | geprüft, ohne Befund. Kein neues Target (13), keine ADR berührt, keine Modul-Liste geändert, alle Läufe dieses Reports über `docker`/`make`/`git`. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Lauf-Protokoll im Kommentar · Stellen-Messung als Eigenschaft
ausgegeben · Zahl weicht von der zitierten Quelle ab · Diff-Datei fehlt in der Plan-Tabelle ·
Zählgleichheit als Mengengleichheit ausgegeben · Zeiger auf eine inzwischen abgelöste Setzung

## Verdikt

**Merge-blockierend:** ja — Nacharbeit verlangt. Der Stand ist bereits gepusht; blockiert ist
darum die Closure, nicht der Merge.

- **F-1 (HIGH)** geht an den Implementer. Beruft er sich auf `MR-053`, liegt ein HIGH mit
  Rollen-Widerspruch vor, und es gilt der Konflikt-Pfad (`v6.9.0` ·
  `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz): Verdikt des
  Architect als Artefakt, kein Herabstufen.
- **F-2 (MEDIUM)** betrifft einen Eintrag des Adaptions-Blocks und geht als Übergabe-Artefakt an
  den Architect (`AGENTS.md` §3.8). **Nicht eskaliert**, obwohl die Bilanz den §3.5-Pfad
  berührt: Für diesen Sprung tragen die leere Quell-Differenz aller acht Regeldateien und das
  gelesene `run.go` den Schluss „keine Senkung" unabhängig von der Messung. Der Defekt betrifft
  die Methode, die der permanente Trigger für den nächsten Sprung vorschreibt.
- **F-3, F-6** gehen an den Architect, **F-4** an Implementer und Planner, **F-5** an den
  Implementer.

Die Finding-Klassen gehen in die Slice-Closure §7. Dieser Report ersetzt keine Verifikation;
DoD 1 (das Rot der zwei `TestDefault*`-Tests) und DoD 3 (die neu gefahrene Stilllegungs-Messung)
prüft der Verifier.
