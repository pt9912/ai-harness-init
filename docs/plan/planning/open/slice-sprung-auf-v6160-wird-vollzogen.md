# Slice slice-sprung-auf-v6160-wird-vollzogen: Jeder Träger des Tags steht auf `v6.16.0`, der Adaptions-Block ist gegen das Delta gelesen, und der Vorlagen-Bericht liegt vor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung beobachtet mehr als die DoD dieses Slice
(`make gates`, `make baseline-verify` und `make full-smoke` stehen in §2); Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Tag-Klammer),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (Pins und Vorlagen
wandern ins Ziel),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) (regierende Fassung,
Festlegungen 1–5),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegungen 2, 4),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Form der Buchung),
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md),
[`MR-007`](../../../../harness/conventions.md#mr-007) (Vendoring),
[`MR-033`](../../../../harness/conventions.md#mr-033),
[`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung),
[`MR-025`](../../../../harness/conventions.md#mr-025).

**Berührte Spec-Stellen:** — (trägt ein Spec-Stratum eine Adresse in den vendored Baum, zählen die
Kommandos in §1 sie mit; ihr Nachzug ist Adresse, keine Spec-Änderung).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---
## 1. Ziel und Abgrenzung

**Ziel:** Der Sprung `v6.13.0` → `v6.16.0` ist nach
[`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 1 vollzogen:
vendored Baum, fünf gekoppelte Pins, die tag-tragenden Symlinks in `.claude/rules/`, der emittierte
Mess-Tag und jede Adresse im lebenden Bestand stehen auf `v6.16.0`. Der Adaptions-Block ist nach dem
Freshness-Audit gelesen (Baseline-Regelwerk `modul-02-harness-bootstrap.md` §Freshness-Audit der
vendored Baseline (Schritt 2); der Abschnitt ist zwischen beiden Tags byte-gleich, [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)
§Stufe (a) und (b)), und der Vorlagen-Bericht zum Tag `v6.16.0` liegt unter `docs/migrations/`.

**Delta** (Tag-Vergleich im Kurs-Klon, feste Zahlen, aus [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) §Kontext): 22 Dateien
`+183 −43` (8 Regelwerk, 14 Vorlagen), keine neu, keine entfallen; Wellen 154–159 auf vier
Releases.

**Träger, gemessen über dem Arbeitsbaum dieses Plans** (keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 2):

```sh
grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile                        # Zeilen 25, 34 (kanonisch)
grep -n 'lab-regelwerk' -A 1 .d-check.yml                             # Zeilen 524, 525
grep -nE 'Default(Tag|BaselineSHA256) =' internal/fetch/baseline.go   # Zeilen 48, 54
grep -n 'const InventurMessTag' internal/emit/baumaussage.go          # Zeile 36 — sechster Träger, emittierte Ebene
readlink .claude/rules/*.md | grep -c 'baseline/v6\.13\.0'            # 7
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.13\.0[^)]*\)' -- "${PS[@]}" | wc -l   # 146 Markdown-Links
git grep -oE '`[^`]*\.harness/baseline/v6\.13\.0[^`]*`'     -- "${PS[@]}" | wc -l   # 113 Inline-Code-Pfade
git grep -l 'baseline/v6.13.0' -- ':!*.md' ':!.harness/baseline'      # internal/emit/templates.go (drei Kommentar-Stellen)
git grep -l 'baseline/v6.13.0' -- docs/plan/adr | wc -l                # 6 — in den Zahlen oben enthalten
```

Die Pins halten `test/sources-pin.bats`, `TestDefaultTag_MatchesBaseline` und
`TestDefaultBaselineSHA256_MatchesMakefile` fail-closed zusammen, den Mess-Tag
`TestInventurMessTag_IstDerGefetchteStand`. Die Markdown-Links sind gate-sichtbar und fallen, sobald
das `v6.13.0`-Verzeichnis fehlt; die Inline-Pfade sieht kein Gate
([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul `codepaths`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Welle 154 (Spezifikation und Erfassung von `SPEC-024`).** *Folge-Slice:*
  `slice-span-pflichtfeld-traegt-nicht-bekannt`. [`MR-076`](../../../../harness/conventions.md#mr-076)
  bleibt über das Vendoring hinweg aktiv; erst nach der Umstellung hebt ihn der Architect auf
  ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4 Punkt 2).
- **Wellen 155–156 (Reviewer-Skill).** *Folge-Slice:*
  `slice-reviewer-skill-zieht-die-findings-form-nach`. In `.harness/skills/reviewer.md` zieht
  dieser Slice nur Adressen nach, im Commit der Reviewer-Rolle
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- **Welle 157.** *Bestand bleibt stehen:* akzeptiertes Negativ nach [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 3 — die Pläne
  mit `BEO-<NNN>`-Zeile zieht nach, wer sie anfasst.
- **Welle 158.** *Folge-Slice:* `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation`.
- **Welle 159.** *Folge-Slice:* `slice-targets-modul-im-emittierten-doc-gate` (vorhanden).
- **Kein Werkzeug-Satz der emittierten Ebene außer dem Mess-Tag.** *Schicht-Abgrenzung:* Die zwölf
  geänderten Vorlagen reisen mit dem Pin ins Ziel ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) §Emittierte Ebene); der d-check-Pin ist
  eine andere Version und bleibt unberührt.
- **Keine eingefrorene Adresse.** *Bestand bleibt stehen:* `docs/reviews/**`, `done/**`,
  `docs/plan/carveouts/done/**`, Register und `Accepted`-ADRs ([`AGENTS.md`](../../../../AGENTS.md)
  §3.4, §3.11; [ADR-0039](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)). Die sechs ADR-Dateien oben werden je Datei geurteilt.
- **Keine Sichtung offener Pläne gegen den neuen Stand.** *Folge-Slice:*
  `slice-offene-plaene-gegen-den-neuen-stand`.

## 2. Definition of Done

Drei slice-eigene Punkte, einer je Achse (Adresse · Adaptions-Eintrag · Vorlage).

- [ ] **1 — Jeder Träger des Tags steht auf `v6.16.0`, und keine lebende Adresse bleibt auf
      `v6.13.0`.**
      1. Baum über [`make vendor-baseline`](../../../../harness/sensors/vendor-baseline.md) aus dem
         verifizierten Release-Asset (einmal Netz, [`MR-007`](../../../../harness/conventions.md#mr-007)),
         `v6.13.0/` entfernt; `make baseline-verify` meldet `v6.16.0 OK` (die Dateizahl ist kein
         Erwartungswert).
      2. Fünf Pins gesetzt; der sha256 ist am Release-Asset gemessen und steht mit seinem Kommando im
         Tausch-Commit; die drei Pin-Wächter grün in `make gates`; `make regelwerk-check` →
         `0 Befund(e)`, EXIT 0.
      3. `readlink .claude/rules/*.md | grep '\.harness/baseline/' | grep -vc 'baseline/v6\.16\.0/'` → **0**.
      4. Das Link-Kommando aus §1 liefert **0**; Tausch- und Nachzugs-Commit landen in einem Push.
      5. Inline-Pfade: **null Adressen**, nicht null Treffer — je Treffer Adresse oder datierte
         Mess-Aussage ([`MR-033`](../../../../harness/conventions.md#mr-033)); der Rest steht im
         Umsetzungs-Lauf benannt und abgezählt.
      6. `InventurMessTag` auf `v6.16.0`, sein Wächter grün; die drei `templates.go`-Stellen je
         geurteilt.

      **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): ein echter Pin-Wert (nicht eine
      Fixture) bleibt einmal auf `v6.13.0`, und mindestens einer der drei Pin-Wächter wird mit einer
      Meldung über genau diese Stelle rot. Der Nachzug läuft je Eigentümer in einem eigenen Commit,
      der die Rolle nennt (§3.8): `AGENTS.md`, `harness/conventions*`, `harness/migration.md` —
      Architect; `.harness/skills/reviewer.md` — Reviewer; `.claude/commands/` — die ausführende
      Rolle ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- [ ] **2 — Die Freshness-Review ist über alle aktiven Einträge gefahren**
      (`ls harness/conventions/*.md | wc -l` → **77**, kein Erwartungswert): die acht geänderten
      Regelwerk-Dateien als Volltext am Tag `v6.16.0`, geordnet `v6.14.0` → `v6.14.1` → `v6.15.0` →
      `v6.16.0` ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 2), die Kandidaten aus Festlegung 3 zuerst; jeder betroffene
      Eintrag trägt einen der fünf Ausgänge. Der Lauf liefert das Übergabe-Artefakt an den Architect
      (Delta-Inventur je Release, abgearbeitete Liste, Stichprobe, Tag/Datum/sha256 für die Buchung
      nach [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
      Festlegung 2); die Ausgänge schreibt der Architect.
- [ ] **3 — Der Vorlagen-Bericht `docs/migrations/v6.16.0.md` liegt vor**, in der Form von <!-- d-check:ignore (die Datei entsteht mit Liefer-Punkt 3) -->
      [`harness/migration.md`](../../../../harness/migration.md) §5: je Vorlage eine Zeile
      (`find .harness/baseline/v6.16.0/templates -name '*.template.md' | wc -l`), das Delta zwischen
      den zwei vendorten Bäumen am Tausch-Commit gemessen, die bestehenden Instanzen als Ist-Maßstab
      ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2).
- [ ] `make gates` grün über dem Liefer-Stand; `make full-smoke` endet EXIT 0.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update (Architect-Commit): §Baseline und §Adoptierte Konventions-Quellen in
      [`harness/conventions.md`](../../../../harness/conventions.md) mit Zeiger auf [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md);
      Sprung-Zeile in [`harness/migration.md`](../../../../harness/migration.md) §1.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap, die Datei existiert nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure — das Repo fährt Wellen
      (`ls docs/plan/planning/welle-*.md | wc -l` → **2**).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v6.16.0/` · `.harness/baseline/v6.13.0/` | neu · entfernt | Liefer-Punkt 1.1 |
| `Makefile`, `.d-check.yml`, `internal/fetch/baseline.go` | update | fünf Pins (1.2) |
| `internal/emit/baumaussage.go`, `internal/emit/templates.go` | update | Mess-Tag, drei Kommentar-Stellen (1.6) |
| `.claude/rules/*.md` | update (Symlink) | 1.3 |
| lebende Markdown-Artefakte mit Adresse | update | 1.4, 1.5 — je Eigentümer ein Commit |
| `docs/migrations/v6.16.0.md` <!-- d-check:ignore (die Datei entsteht mit Liefer-Punkt 3) --> | neu | Liefer-Punkt 3 |
| Übergabe-Artefakt der Freshness-Review | neu | Liefer-Punkt 2, an den Architect |
| `test/sources-pin.bats`, `internal/fetch/*_test.go`, `internal/emit/*_test.go` | unverändert | Wächter für 1.2 und 1.6 |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei; [`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)
ist `Accepted` (eingetreten 2026-10-06); einmal Netz für `make vendor-baseline` und
`make regelwerk-check`; `make baseline-freshness` meldet keinen neueren Tag als `v6.16.0` — sonst
greift [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Re-Evaluierungs-Trigger 2. Der Zug nach `in-progress/` landet auf dem Hauptzweig
und nimmt den Ruhe-Marker der Roadmap zurück.

**Bedingung über diesen Slice hinaus — kein Release dazwischen** ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 5): Zwischen
dem Tausch-Commit dieses Slice und dem Abschluss von `slice-targets-modul-im-emittierten-doc-gate`
wird kein Release-Tag geschnitten. Kein Sensor hält das; Träger ist der Release-Schnitt, der diese
Zeile und [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) liest. Ein Tag davor bricht Festlegung 5 (Re-Evaluierungs-Trigger 5).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Die Inline-Urteile aus 1.5 übersteigen eine Review-Sitzung — dann wird der
  Nachzug je Eigentümer geschnitten.
- `in-progress` → `open`, jede Bedingung für sich hinreichend: **(a)** die Freshness-Review trifft
  *widerspricht*, und der Rückbau zieht mehr nach als den Eintrag (Übergabe an den Architect);
  **(b)** eine Instanz-Gruppe aus Liefer-Punkt 3 ist weder *schon erfüllt* noch *keine Instanz*
  und reicht über Einzel-Instanzen hinaus; **(c)** der am Asset gemessene sha256 weicht ab, oder
  `make vendor-baseline` bricht an seiner Sperre ab; **(d)** der Mess-Tag-Wächter bleibt rot,
  obwohl beide Seiten gesetzt sind; **(e)** der Durchgang findet einen Kandidaten, den [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)
  Festlegung 3 nicht nennt und dessen Folge-Arbeit über einen Ausgang hinausreicht
  (Re-Evaluierungs-Trigger 3) — der Planner schneidet sie.

## 5. Closure-Trigger

1. `make baseline-verify` meldet `v6.16.0 OK`; Pin- und Mess-Tag-Wächter grün in `make gates`; das
   Link-Kommando aus §1 und das Symlink-Kommando aus 1.3 liefern **0**; `make full-smoke` EXIT 0.
2. Der Vorlagen-Bericht trägt je Vorlage eine Zeile und den Instanz-Abschnitt; das Übergabe-Artefakt
   der Freshness-Review liegt beim Architect, und §Baseline trägt die Buchung.

**Lerneintrag** in einer der drei Formen, §7. Die Closure schreibt der Planner in frischem Kontext
und eigenem Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Sprungweite treibt die Kosten** — vier Releases; `baseline-sprungweite-treibt-kosten` steht bei
  2 Belegen. Ein dritter macht ihn zur Lücke mit eigenem
  Folge-Slice. — **Ausgang:** offen bis zur Closure.
- **Tag-tragende Adresse überlebt den Tausch nicht** — `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht`
  bei 2 Belegen; Liefer-Punkt 1.4/1.5
  fängt es. — **Ausgang:** offen bis zur Closure.
- **sha256 aus Klon oder Notiz statt am Asset** — Liefer-Punkt 1.2, zweites Netz ist die Sperre von
  `make vendor-baseline`. — **Ausgang:** offen bis zur Closure.
- **[`MR-076`](../../../../harness/conventions.md#mr-076) wird im Durchgang vorzeitig aufgehoben** —
  gegen [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4. — **Ausgang:** entfallen, wenn er bei der Closure aktiv ist.
- **Release-Tag vor dem `targets`-Vorgang** (§4). — **Ausgang:** weiter offen über die Closure
  hinaus, bis `slice-targets-modul-im-emittierten-doc-gate` in `done/` liegt.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) — der Tag steht in
`Makefile`, `.d-check.yml`, `internal/`, `.claude/rules/`, `harness/`, `docs/`. `TOOLS` und `CODEX`
sind nicht berührt (`git grep -l 'v6\.13\.0' -- harness/tools .codex | wc -l` → **0**).

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet, alle Einträge
führen `*`, gesichtet nach Gegenstand. Zähler:
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine Erwartungswerte.

| Eintrag | Zähler | Berührung |
|---|---|---|
| `baseline-sprungweite-treibt-kosten` | 2 | §6 — vier Releases |
| `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` | 2 | Liefer-Punkt 1.4/1.5 |
| `re-baseline-ohne-inventur-slice` | 2 | kein Auftreten — dieser Plan ist der Inventur-Slice |
| `vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin` | 1 | kein Auftreten bei 1.1 |
| `delta-durchgang-uebersieht-deckung` | 1 | Liefer-Punkt 2 liest den Volltext |
| `delta-messung-trifft-den-quelltext-statt-den-vendorten-baum` | 1 | Liefer-Punkt 3 misst vendored |
| `emittierter-stand-laeuft-dem-dogfood-voraus` | 2 | Mess-Tag gekoppelt; die Vorlagen reisen mit dem Pin |
| `stand-feld-ausserhalb-des-konventionsspeichers-bleibt-beim-sprung-stehen` | 1 | Kopf von `.harness/skills/reviewer.md` — Gegenstand des Reviewer-Slice |
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 7 (geplant) | §1, `slice-offene-plaene-gegen-den-neuen-stand` |
| `gate-modul-erreicht-den-vendored-baum-nicht` | 3 (geplant) | die Inline-Pfade aus §1 |

Erreicht ein Eintrag mit diesem Slice 3×, ist er eine Lücke mit eigenem Folge-Slice (§7).

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

