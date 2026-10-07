# Slice slice-sprung-auf-v6170-wird-vollzogen: Jeder Träger des Tags steht auf `v6.17.0`, d-check auf `v0.83.0`, und das emittierte Ziel prüft die Disjunktheit seines Gate-Index

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
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(Grenz-Zeile nennt die Bedingung, kein Gate über leerer Menge),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (Pins und Vorlagen
wandern ins Ziel),
[`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) (regierende Fassung,
Festlegungen 1–4, §Fitness Function),
[`ADR-0079`](../../adr/0079-tote-adresse-in-den-vendored-baum-aus-zwei-accepted-adrs.md)
(`ignore-refs`-Paare),
[`MR-007`](../../../../harness/conventions.md#mr-007) (Vendoring),
[`MR-054`](../../../../harness/conventions.md#mr-054) (drei Kriterien für den Schalter),
[`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung),
[`MR-080`](../../../../harness/conventions.md#mr-080) (Muster des Pin-Eintrags),
[`MR-025`](../../../../harness/conventions.md#mr-025).

**Berührte Spec-Stellen:** — (Adressen in den vendored Baum in einem Spec-Stratum zählen die
Kommandos in §1 mit; ihr Nachzug ist Adresse, keine Spec-Änderung).

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Sprung `v6.16.0` → `v6.17.0` ist nach
[`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) vollzogen: vendored Baum,
fünf gekoppelte Pins, Mess-Tag, Symlinks und jede lebende Adresse stehen auf `v6.17.0`; d-check
steht im Dogfood und als emittierter Default auf `v0.83.0`; das emittierte Doku-Gate fährt
`targets.authority-disjoint: true`, und die Grenz-Zeile des Werkzeug-Teils nennt statisch die
Bedingung, unter der die Disjunktheit geprüft wird (Festlegung 2).

**Delta** (aus [`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) §Kontext,
feste Zahlen): 4 Dateien `+11 −6`, Welle 160; `modul-02-harness-bootstrap.md` unverändert.

**Träger, gemessen über dem Arbeitsbaum dieses Plans** (keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 2):

```sh
grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile                        # Zeilen 25, 34 (kanonisch)
grep -n 'lab-regelwerk' -A 1 .d-check.yml                             # Zeilen 538, 539
grep -nE 'Default(Tag|BaselineSHA256) =' internal/fetch/baseline.go   # Zeilen 48, 54
grep -n 'const InventurMessTag' internal/emit/baumaussage.go          # Zeile 36 — emittierter Mess-Tag
readlink .claude/rules/*.md | grep -c 'baseline/v6\.16\.0'            # 7
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.16\.0[^)]*\)' -- "${PS[@]}" | wc -l   # 141 Markdown-Links
git grep -oE '`[^`]*\.harness/baseline/v6\.16\.0[^`]*`'     -- "${PS[@]}" | wc -l   # 116 Inline-Code-Pfade
git grep -l 'baseline/v6.16.0' -- ':!*.md' ':!.harness/baseline'      # internal/emit/templates.go
git grep -lE '\]\([^)]*\.harness/baseline/v6\.16\.0' -- docs/plan/adr | wc -l   # 1 ADR-Datei mit Link
grep -n 'v0\.82\.0' d-check.mk internal/emit/emit.go internal/emit/werkzeugindex.go   # Pin, Default, Grenz-Zeile
```

Die Pins halten `test/sources-pin.bats`, `TestDefaultTag_MatchesBaseline`,
`TestDefaultBaselineSHA256_MatchesMakefile` und `TestInventurMessTag_IstDerGefetchteStand`
fail-closed zusammen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Schalter im Dogfood.** *Bestand bleibt stehen:* eine Autoritäts-Datei, kein Objekt
  ([`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) Festlegung 3).
- **a-check-Pin `v0.22.0`.** *Anderer Vorgang:* eigener Slice mit Bezug
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), keine Bedingung für
  `v0.4.0` (Festlegung 5); eine Plan-Datei legt der Auftrag des Auftraggebers an.
- **Erkennung des Schalters im liegenden Ziel-YAML.** *Anderer Vorgang:* verworfen
  (Alternativen H, I); die Zeile ist statisch.
- **Eingefrorene Adressen.** *Bestand bleibt stehen:* `docs/reviews/**`, `done/**`,
  `docs/plan/carveouts/done/**`, Register und `Accepted`-ADRs ([`AGENTS.md`](../../../../AGENTS.md)
  §3.4, §3.11). Trägt eine `Accepted`-ADR einen Link in `v6.16.0/`, wird ihre Deckung
  (`ignore-refs`-Paar per ADR, Linie [`ADR-0079`](../../adr/0079-tote-adresse-in-den-vendored-baum-aus-zwei-accepted-adrs.md))
  **vor** dem Tausch beim Architect angefragt — das Paar ist eine Senkung (§3.5), nicht Teil
  dieses Slice.
- **Norm-Texte.** *Schicht-Abgrenzung:* die Übergaben unten schreibt der Architect.

**Übergaben an den Architect nach dem Vollzug** (keine Liefer-Punkte; je eigener Commit,
[`AGENTS.md`](../../../../AGENTS.md) §3.8):

1. `MR`-Eintrag d-check-Pin `v0.83.0` nach dem Muster von
   [`MR-080`](../../../../harness/conventions.md#mr-080) — Digest, Strenge-Bilanz, Gegenmessung
   nach [`MR-063`](../../../../harness/conventions.md#mr-063) (Messwerte liefert Liefer-Punkt 2).
2. Buchung §Baseline in [`harness/conventions.md`](../../../../harness/conventions.md) mit Zeiger
   auf [`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md); Sprung-Zeile in
   [`harness/migration.md`](../../../../harness/migration.md) §1.
3. Freshness-Durchgang über die neun Kandidaten (Festlegung 1):
   [`MR-001`](../../../../harness/conventions.md#mr-001),
   [`MR-009`](../../../../harness/conventions.md#mr-009),
   [`MR-010`](../../../../harness/conventions.md#mr-010),
   [`MR-011`](../../../../harness/conventions.md#mr-011),
   [`MR-014`](../../../../harness/conventions.md#mr-014),
   [`MR-024`](../../../../harness/conventions.md#mr-024),
   [`MR-054`](../../../../harness/conventions.md#mr-054),
   [`MR-065`](../../../../harness/conventions.md#mr-065),
   [`MR-080`](../../../../harness/conventions.md#mr-080) — die drei geänderten Dateien als
   Volltext am Tag `v6.17.0`; das Übergabe-Artefakt (Tag, Datum, sha256) liefert Liefer-Punkt 1.
4. Folge-Eintrag zu [`MR-081`](../../../../harness/conventions.md#mr-081) mit Kopf-Marke
   ([`MR-032`](../../../../harness/conventions.md#mr-032)): der Satz *„zweiter Auflösungs-Trigger
   in der Sache eingetreten"* trifft [`MR-076`](../../../../harness/conventions.md#mr-076) nicht
   (Review `2026-10-07-mr-081-review` F-2, LOW; ob LOW das trägt, entscheidet der Architect).

**Übergabe an die Planner-Closure dieses Slice:** Register-Eintrag zur Klasse
*Entfernungs-Commit nicht additionsfrei* (Review `2026-10-07-mr-081-review` F-1, MEDIUM; Beleg
der Review-Vorgang), unter einer Kennung, die das Register vorher nach einer passenden Klasse
abgesucht hat.

**Release `v0.4.0`** wird erst nach der Closure dieses Slice geschnitten: Pin und Schalter reisen
im selben Release ([`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md)
§Folge-Arbeit, Release-Bedingung); die Release-Notiz nennt die Verhaltensänderung für frische und
bestehende Ziele (§Konsequenzen).

## 2. Definition of Done

Drei slice-eigene Punkte, einer je Achse (Baseline · d-check-Pin · Disjunktheit im Ziel).

- [ ] **1 — Jeder Träger des Tags steht auf `v6.17.0`, und keine lebende Adresse bleibt auf
      `v6.16.0`.**
      1. Baum über [`make vendor-baseline`](../../../../harness/sensors/vendor-baseline.md) aus dem
         verifizierten Release-Asset (einmal Netz, [`MR-007`](../../../../harness/conventions.md#mr-007)),
         `v6.16.0/` entfernt; `make baseline-verify` meldet `v6.17.0 OK`.
      2. Fünf Pins gesetzt, sha256 am Release-Asset gemessen, Kommando im Tausch-Commit; die
         Pin-Wächter grün in `make gates`; `make regelwerk-check` → `0 Befund(e)`, EXIT 0.
      3. Mess-Tag und Symlinks auf `v6.17.0`; die `templates.go`-Stellen je geurteilt.
      4. Das Link-Kommando aus §1 liefert **0** außerhalb von `ignore-refs`-Paaren, `make docs-check`
         ohne Befund; Inline-Pfade: null Adressen, Rest datierte Mess-Aussage
         ([`MR-033`](../../../../harness/conventions.md#mr-033)). Tausch- und Nachzugs-Commit in
         einem Push; Nachzug je Eigentümer ein Commit mit Rolle (§3.8,
         [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).

      **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): ein echter Pin-Wert bleibt einmal
      auf `v6.16.0`, ein Pin-Wächter wird mit einer Meldung über genau diese Stelle rot.
- [ ] **2 — d-check `v0.83.0` im Dogfood (`d-check.mk`, Image und Digest) und als emittierter
      Default (`internal/emit/emit.go`).** Gegenmessung nach
      [`MR-063`](../../../../harness/conventions.md#mr-063): jedes aktive Modul mit Nicht-Null-Basis
      vor und nach dem Pin, Befund-Zahlen im Umsetzungs-Commit samt Kommando; das ist das
      Mess-Material für die Architect-Übergabe 1.
- [ ] **3 — Das emittierte Ziel prüft die Disjunktheit, und der Werkzeug-Teil nennt die
      Bedingung** ([`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md)
      Festlegung 2, §Fitness Function).
      1. `internal/emit/templates/d-check.yml` trägt `authority-disjoint: true`; die Grenz-Zeile
         in `internal/emit/werkzeugindex.go` nennt statt des Pin-Grunds den statischen Satz (drei
         Bedingungen, die *sonst*-Hälfte, die Grenze des Sensors).
      2. `make full-smoke`: Stufe `targets_im_ziel` erweitert — frisches Ziel grün, eine
         Doppelzeile in `harness/README.md` §Sensors färbt das Ziel-Gate rot mit
         `gate-declared-twice`; neue Stufe — vorab gelegte `.d-check.yml` in `v0.2.x`-Form
         (`targets` nicht in `modules`) mit gesetztem Schalter bleibt unverändert und mit derselben
         Doppelzeile grün. Beide mit `e2e_abdeckung`-Deklaration; `make e2e-abdeckung` nachgezogen.
      3. Go-Test hält den Bedingungssatz im geschriebenen Werkzeug-Teil; ein Fall in
         `test/mutations/` streicht den Satz bzw. setzt die alte Pin-Zeile ein und färbt ihn rot
         (`MUTATE_CASES`, Meldung gelesen). Handbuch (`docs/user/`) im Ist-Zustand nachgezogen.
- [ ] `make gates` grün über dem Liefer-Stand; `make full-smoke` endet EXIT 0.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: die Architect-Übergaben 1–3 aus §1 liegen als eigene Commits vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap, die Datei existiert nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, einschließlich der F-1-Übergabe
      aus §1, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure — das Repo fährt Wellen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v6.17.0/` · `.harness/baseline/v6.16.0/` | neu · entfernt | Liefer-Punkt 1.1 |
| `Makefile`, `.d-check.yml`, `internal/fetch/baseline.go` | update | fünf Pins (1.2) |
| `internal/emit/baumaussage.go`, `internal/emit/templates.go`, `.claude/rules/*.md` | update | 1.3 |
| lebende Markdown-Artefakte mit Adresse | update | 1.4 — je Eigentümer ein Commit |
| `d-check.mk`, `internal/emit/emit.go` | update | Pin `v0.83.0` (2) |
| `internal/emit/templates/d-check.yml`, `internal/emit/werkzeugindex.go` | update | Schalter, Grenz-Zeile (3.1) |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | zwei Stufen (3.2) |
| `internal/emit/*_test.go`, `test/mutations/` | update · neu | Bedingungssatz, Mutationsfall (3.3) |
| `docs/user/` (Handbuch) | update | Ist-Zustand (3.3) |
| `test/sources-pin.bats`, `internal/fetch/*_test.go` | unverändert | Wächter für 1.2 |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei;
[`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) ist `Accepted` (eingetreten
2026-10-07); einmal Netz für `make vendor-baseline` und `make regelwerk-check`;
`make baseline-freshness` meldet keinen neueren Tag als `v6.17.0` — sonst greift
Re-Evaluierungs-Trigger 1. Der Zug nach `in-progress/` landet auf dem Hauptzweig.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: Liefer-Punkt 3 übersteigt eine Review-Sitzung — dann wird er
  abgeschnitten, mit der Release-Bedingung *kein Tag zwischen den Vorgängen*.
- `in-progress` → `open`, jede Bedingung für sich hinreichend: **(a)** der grüne Start im Ziel
  scheitert, der Emitter schreibt eine Doppelung (Re-Evaluierungs-Trigger 3); **(b)** die
  `v0.2.x`-Stufe wird rot, d-check prüft dort doch — der Satz ist neu zu fassen (Architect);
  **(c)** der am Asset gemessene sha256 weicht ab, oder `make vendor-baseline` bricht an seiner
  Sperre ab; **(d)** eine `Accepted`-ADR trägt einen Link in `v6.16.0/`, und ihre Deckung ist vor
  dem Tausch nicht entschieden.

## 5. Closure-Trigger

1. `make baseline-verify` meldet `v6.17.0 OK`; `make gates` grün; das Link-Kommando aus §1 und
   `readlink .claude/rules/*.md | grep '\.harness/baseline/' | grep -vc 'baseline/v6\.17\.0/'`
   liefern **0**; `make full-smoke` EXIT 0 mit beiden Stufen aus 3.2.
2. `grep -rn 'v0\.82\.0' d-check.mk internal/emit/emit.go internal/emit/werkzeugindex.go` → kein
   Treffer; die Architect-Übergaben 1–3 liegen als Commits vor.

**Lerneintrag** in einer der drei Formen, §7. Die Closure schreibt der Planner in frischem Kontext
und eigenem Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Tag-tragende Adresse überlebt den Tausch nicht** — Register bei 3 Belegen, Ausgang beim
  Lese-Schritt; Liefer-Punkt 1.4 fängt es. — **Ausgang:** <…>
- **Eingefrorener Link in den vendored Baum** — eine ADR-Datei trägt einen; ohne vorab
  entschiedene Deckung bricht `docs-check` mit dem Tausch (§4 (d)). — **Ausgang:** <…>
- **Grenz-Zeile verspricht mehr als der Pin prüft** — die zwei Stufen messen je eine Seite, nicht
  die Menge der Formen ([`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md)
  §Fitness Function, Lücke). — **Ausgang:** <…>
- **Release-Tag zwischen Pin und Schalter** (§1, Release `v0.4.0`). — **Ausgang:** <…>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) — Tag und Pin stehen in
`Makefile`, `.d-check.yml`, `d-check.mk`, `internal/`, `.claude/rules/`, `harness/`, `docs/`.
`TOOLS` ist über `harness/tools/full-smoke.sh` berührt (zwei Stufen), ohne neue Mechanik der
Sub-Area; `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet, alle
Einträge führen `*`, gesichtet nach Gegenstand. Zähler:
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine Erwartungswerte.

| Eintrag | Zähler | Berührung |
|---|---|---|
| `tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` | 3 (offen) | Liefer-Punkt 1.4; Ausgang beim Lese-Schritt der nächsten Welle-Closure |
| `baseline-sprungweite-treibt-kosten` | 3 (offen) | kein Auftreten erwartet — ein Release Abstand |
| `re-baseline-ohne-inventur-slice` | 2 | kein Auftreten — die Inventur steht in [`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) §Kontext |
| `emittierter-stand-laeuft-dem-dogfood-voraus` | 2 | Liefer-Punkt 3 — Schalter nur im Ziel, begründet (Festlegung 3) |
| `delta-durchgang-uebersieht-deckung` | 1 | Architect-Übergabe 3 liest Volltext |
| `vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin` | 1 | Liefer-Punkt 1.1 aus dem Asset |
| `pin-digest-ohne-waechter` | 3 (offen) | Liefer-Punkt 2 setzt einen Digest |
| `strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` | 1 | Liefer-Punkt 2 verlangt sie im Commit |
| `pin-sprung-feuert-adr-trigger-ohne-nennung` | 1 | Pin `v0.83.0` feuert [`ADR-0082`](../../adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) Re-Evaluierungs-Trigger 4 nicht, solange die Wirkbedingungen gleich bleiben — der Umsetzungs-Commit nennt es |
| `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` | 4 (geplant) | die Grenz-Zeile ist eine solche Aussage; Stufe 3.2 misst sie |

Kein Eintrag erreicht mit diesem Slice erstmals 3×.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
