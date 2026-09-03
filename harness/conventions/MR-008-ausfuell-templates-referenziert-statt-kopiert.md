# MR-008 — Ausfüll-Templates referenziert statt kopiert

> **ÜBERHOLT: die Adaption — das Repo hält keine eigenen Kopien der Ausfüll-Templates → [`MR-041`](../conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline).** Die Abgrenzung gegen [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) und ihr Nachzug vom 2026-07-21 binden für die **emittierte** Ebene fort.

- **Datum:** 2026-07-17
- **Geltungsbereich:** die fünf in slice-013 gelöschten Repo-Template-Kopien
  `docs/plan/planning/slice.template.md`, `docs/plan/planning/welle.template.md`,
  `docs/plan/adr/NNNN-titel.template.md`, `docs/plan/carveouts/carveout.template.md`,
  `docs/reviews/review-report.template.md` — seit slice-016 als Tombstones referenz-weit
  über `codepaths.ignore-refs` deklariert ([`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)), sodass hier die klaren
  vollen Pfade statt der früheren Glob-Workarounds stehen; ergänzt [`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache).
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und der Grund ist ein anderer als bei den übrigen: **die Baseline schreibt diese Setzung
  inzwischen selbst.**
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#greenfield-bootstrap-schritt-sequenz-modul-2)
  §Anmerkung zum Instanziierungs-Zeitpunkt (Schritt 2) nennt am adoptierten Stand `v5.12.0`
  dieselbe Liste wie der Geltungsbereich oben — *„die **wiederkehrenden Artefakte** — `slice`,
  `welle`, weitere ADRs (`NNNN-*`), `carveout`, `review-report` — werden **nicht** beim Bootstrap
  vorab kopiert, sondern **pro Instanz** aus der vendored Baseline"* — und schließt mit
  *„Die vendored Baseline ist deren **einzige** Referenz-Form — **keine Blank-Kopie im Repo
  vorhalten.**"* Der Abweichungs-Absatz unten misst gegen den abgelösten Stand; heute steht dieser
  Eintrag nicht an der Stelle einer Regel, sondern deckt sich mit ihr. **Welcher der fünf Ausgänge
  daraus folgt**, entscheidet der Adaptions-Durchgang und nicht dieses Feld: nach
  §Freshness-Audit der vendored Baseline ist das ein Nachfolge-Eintrag, kein Edit hier.
- **Adaption:** Das Repo hält **keine eigenen Kopien** der Ausfüll-Templates mehr.
  Einzige Quelle ist die committet vendored Baseline
  `.harness/baseline/<tag>/templates/…` ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)). Ein neues Artefakt
  (Slice, ADR, Welle, Carveout, Review-Report) entsteht per **`cp` aus dem vendored
  Baum** und wird dann ausgefüllt — z. B.
  `cp .harness/baseline/$(BASELINE_TAG)/templates/docs/plan/planning/slice.template.md docs/plan/planning/open/slice-NNN-….md`.
- **Abweichung von der Baseline (Modul 2):** Modul 2 beschreibt die Templates in
  **zwei** Rollen — *vendored als Referenz-Form* **und** *kopiert-und-ausgefüllt als
  eigene Artefakte*. [MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) behält die zweite Rolle (Artefakte entstehen weiter durch
  Kopieren-und-Ausfüllen), streicht aber die **dauerhaft im Repo gehaltene
  Blank-Kopie**: die Vorlage wird pro Artefakt frisch aus dem vendored Baum kopiert,
  nicht als `docs/…/*.template.md`-Dublette gepflegt.
- **Abgrenzung gegen [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (emittierte Struktur) — kein Widerspruch.**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (rank-1) verlangt für die vom Go-Tool **emittierte**
  Zielstruktur weiterhin co-located `.template.md` für wiederkehrende Artefakte (ADR ·
  slice · welle · carveout · review-report) — dieselbe Liste, die [MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) hier löscht.
  Das ist **keine** Kollision: [MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) gilt **nur** für die eigenen Planungs-Artefakte
  *dieses* Repos, das die **volle** Baseline vendored ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) und deshalb
  referenzieren *kann*. Ein emittiertes Fremdrepo erhält nicht notwendig den ganzen
  vendored Baum → dort **braucht** es die co-located Kopien, und
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) bleibt
  bindend. **[MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) generalisiert ausdrücklich nicht** auf die Emissions-Logik
  (slice-003): wer sie umsetzt, folgt
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), nicht [MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert).
- **Nachzug 2026-07-21 ([`ADR-0005`](../../docs/plan/adr/0005-ziel-repo-distribution.md)):** die obige
  Abgrenzung trägt nicht mehr. Ihre Prämisse — „ein emittiertes Fremdrepo erhält nicht notwendig den
  vollen vendored Baum" — ist durch die ADR aufgehoben: das Zielrepo fetcht seither die **volle**
  Baseline (Regelwerk **+ Templates**, [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren))
  und *kann* referenzieren wie der Dogfood. Die Emissions-Logik folgt daher jetzt dem **referenzierten**
  Modell — kein Co-Location der wiederkehrenden Vorlagen mehr;
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ist auf 0.8.0 nachgezogen.
  Die Reconciliation wurde beim 0.7.0-CR übersehen; slice-024s Voll-Smoke deckte sie auf.
- **Begründung (empirisch, 2026-07-17 gemessen):** Die fünf bisher kopierten
  Blank-Templates waren **verbatim/nachhinkend** (null Repo-Adaptionen — jeder Diff
  gegen den vendored Baum war reines Upstream-Lag), **von nichts Stabilem
  referenziert** (kein Makefile/Hook/Test/README, nur die Slices, die sie gerade
  bearbeiteten) und ohnehin **d-check-exempt** (`**/*.template.md` in `scan.ignore`).
  Das Kopier-Modell lieferte hier also **reine Wartungskosten** (jeder Baseline-Bump
  erzwingt eine Reconciliation — slice-013 *war* diese Kosten) bei **null Nutzen**.
  Referenzieren beseitigt die Drift-Klasse dauerhaft.
- **Tag im Referenzpfad:** Verweise auf `.harness/baseline/<tag>/templates/…` tragen
  den Tag; beim Bump repinnt er mit `BASELINE_TAG` (dieselbe Mechanik wie überall). Ein
  tag-stabiler Zeiger (Symlink) ist bewusst **nicht** gebaut (YAGNI — aktuell verweist
  **nichts** dauerhaft auf die Templates; [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **Nebeneffekt (benigne):** `carveout.template.md` war die einzige Datei unter
  `docs/plan/carveouts/*`; mit ihrer Löschung verschwindet das (leere) Verzeichnis (git
  trackt keine leeren Verzeichnisse). Kein aktives Artefakt braucht es — es kehrt
  zurück, sobald der erste Carveout entsteht (`cp` aus dem vendored Baum + `mkdir -p`,
  Modul 7). Konsistent damit, dass `open/`/`next/`/`done/` nur existieren, wenn sie
  Inhalt tragen.
- **Auflösungs-Trigger:** gilt, **solange das Repo seine Templates nicht adaptiert.**
  Wird an *einem* Template eine echte Repo-Adaption nötig, wird **genau dieses** wieder
  als Repo-Kopie geführt — mit MR-Eintrag, der die Adaption begründet — die übrigen
  bleiben referenziert. Der Nutzen-Beleg (verbatim/unreferenziert) ist dann für dieses
  eine Template neu zu prüfen.
