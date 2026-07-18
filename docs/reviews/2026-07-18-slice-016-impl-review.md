# Review-Report: slice-016 Implementierung (d-check-Pin-Sprung + Codepath-Ventile) — 2026-07-18

**Review-Art:** Code — unabhängiger Reviewer (kein Selbst-Review). Geprüft gegen Plan
(slice-016 DoD + §6-Risiken), `LH-QA-01`/`LH-QA-02`, Hard Rules `AGENTS.md` §3, MR-001/
MR-007/MR-008, d-check-Schema (`--print-config`). Sekundär: `.claude/commands/implement-slice.md`
gegen Regelwerk `modul-09`.

**Gegenstand:** uncommitteter Working-Tree-Diff (11 Dateien): `harness.mk`, `.d-check.yml`,
`harness/conventions.md`, `docs/plan/planning/open/slice-016-…md`, 6× `docs/reviews/*.md`,
`.claude/commands/implement-slice.md`.

**Skill:** `.harness/skills/reviewer.md` @ 1.1.0 ·
**Modell:** claude-opus-4-8[1m] (unabhängiger Reviewer-Agent) · **Datum:** 2026-07-18

**Eingangs-Kontext (nach reviewer.md v1.1.0 — sechs Elemente):**
1. **Diff/Range:** `git diff` (Working Tree, uncommitted), oben aufgelistet.
2. **Betroffene LH:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
   (keine halluzinierten Gates), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
   (Reproduzierbarkeit/Digest-Pin).
3. **Referenzierte ADRs:** keine (slice-016 `**Bezug:**` nennt nur `LH-QA-01/02` + `MR-001`).
   Die ADR-Abwesenheit ist geprüft (Negativ N-5, §3.5-Klärung).
4. **Hard Rules:** `AGENTS.md` §3.1 (halluzinierte Gates), §3.2 (Lint-Suppression), §3.3
   (git mv + Inhalt = zwei Commits), §3.4 (ADRs immutable), §3.5 (Gate-Lockerung nur per ADR).
5. **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-07-17-slices-011-014-plan-review.md`
   (Zeitdokument-/Lifecycle-Marker), `docs/reviews/2026-07-17-slice-013-impl-review.md`
   (Template-Löschung, MR-008, „null Adaptionen").
6. **Slice-Plan:** `docs/plan/planning/open/slice-016-dcheck-pin-sprung.md` (Diff gegen Plan geprüft;
   DoD-Abhakung NICHT bewertet — Verifier-Rolle).

**Ausgeführte Verifikationsmittel (Belege):**
- `make gates` → **Exit 0** (baseline-verify + docs-check + 47 bats + shellcheck).
- `make docs-check` → **„40 Datei(en) geprüft, 0 Befund(e)"**, Exit 0.
- `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.46.0` →
  `Digest: sha256:9c317bf116a614a00f417871da4ca6057bdbabf0ca53af24c6d8e8b776de36a1`
  == der in `harness.mk` gepinnte Digest (Tag→Digest-Bindung bestätigt, `LH-QA-02`).
- `docker run … --print-config` → autoritatives Schema: `codepaths.exempt-paths` („datei-weit,
  wie ids"), `codepaths.ignore-refs` („referenz-weit; Tombstones entfernter Artefakte") — die
  verwendeten Keys sind exakt korrekt; die aktive `modules:`-Liste ist `[links, anchors, ids,
  matrix, codepaths, spans]` (keine der neuen opt-in-Module `planning`/`commits`/`tracked`/`targets`).
- `git log --diff-filter=D` → die fünf in slice-013 (`1b2428d`) gelöschten Templates sind
  **byte-genau** die fünf `ignore-refs`-Einträge.

---

## Findings

### F-1 — `README.md` trägt weiterhin „d-check v0.10.0" (Canonical-Source-Drift)

- `kategorie`: LOW
- `quelle`: Maintainability (Doku-Drift) / Source Precedence (`AGENTS.md` §2, README = Rang 5)
- `pfad`: `README.md:16`
- `befund`: `README.md:16` beschreibt `make docs-check` als „(Doku-Referenz-Gate, d-check
  **v0.10.0**)". Nach dem Pin-Sprung nennen `harness.mk` und `harness/conventions.md:14`
  (§Baseline) v0.46.0; die README widerspricht ihnen jetzt. Die slice-016-DoD skopte die
  Versions-Nachführung ausdrücklich nur auf „`harness/conventions.md` §Baseline-Zeile" und
  übersah die zweite, gleichrangige Versions-Aussage in einer kanonischen Quelle.
- `verifizierbar`: **ja** — `grep -n 'd-check v0' README.md` liefert die Zeile;
  gegen `grep 'd-check:' harness/conventions.md` (v0.46.0) und den `harness.mk`-Digest.
  Kein Gate fängt es (d-check prüft keine Prosa-Versionsnummern; `codepaths` prüft nur Pfad-Existenz).

### F-2 — `exempt-paths: docs/reviews/**` hebt Codepath-Prüfung für den ganzen Review-Baum auf (deklarierte Won't-Fix-Lücke)

- `kategorie`: INFO
- `quelle`: `LH-QA-01`-Nachbarschaft / Maintainability (Abdeckung)
- `pfad`: `.d-check.yml:48` (`codepaths.exempt-paths`)
- `befund`: Die Ausnahme nimmt `docs/reviews/**` **datei-weit** und **per Default** aus der
  `codepaths`-Existenz-Prüfung — inklusive dieses Reports und aller künftigen. Eine *neue*,
  real falsche `datei:zeile`-Zitierung auf eine **lebende** Datei in einem Review bliebe damit
  grün, bis der (blockierte) slice-015-Zitat-Sensor sie deckt. Beobachtung liegt im Gate-Pfad,
  ist aber **kein** stilles Grün: sie ist in MR-009 und slice-016 §6 („Kein Rückfall auf stilles
  Grün") ausdrücklich begründet, hat Präzedenz in `ids.exempt-paths: docs/reviews/**` (MR-001,
  ohne ADR adoptiert) und ersetzt lediglich die zuvor pro-Zeile gesetzten `` `d-check:ignore` ``-
  Marker (Mechanik-Refactor, kein neu geöffnetes Loch für bestehende Inhalte).
- `verifizierbar`: **ja** — eine künstlich in ein `docs/reviews/*.md` eingefügte tote
  `datei:zeile`-Referenz auf eine lebende Datei ⇒ `make docs-check` bleibt grün (belegt die Lücke);
  gegen den Zustand vor MR-009, wo dieselbe Referenz einen Codepath-Befund erzeugt hätte.

### F-3 (Sekundär) — Sachfremder v3.1.0-Konformitäts-Patch reitet im slice-016-Working-Tree mit

- `kategorie`: INFO
- `quelle`: Maintainability (`AGENTS.md` §3.3-Nachbarschaft — Commit-Trennung/Provenienz)
- `pfad`: `.claude/commands/implement-slice.md` (gesamter Diff)
- `befund`: Der Patch (Plan-vor-Code-Schritt, Rücksprungkanten 12→10/13→10, Close-out mit
  „Move und content-rewrite separate Commits") ist ein **eigenständiges** Anliegen — nicht Teil
  der slice-016-DoD noch der Plan-Tabelle (§3), die nur `harness.mk`/`.d-check.yml`/`docs/reviews/**`/
  `harness/conventions.md` listet. Inhaltlich ist er **treu zu `modul-09`** (Kernidee „Plan → Diff →
  Code ist nicht optional"; die Rücksprungkanten spiegeln `modul-09:46-55` „nicht zurück zu Schritt 1
  = Kontext-Defekt"; git-mv-Trennung = §3.3). Risiko liegt allein in der Provenienz: wird er in den
  slice-016-Commit gefaltet, trägt die History eine sachfremde Änderung ohne eigenen Anlass-Vermerk.
- `verifizierbar`: nur bedingt — kein Gate prüft Commit-Kohäsion; manuell durch Abgleich des Diffs
  gegen slice-016 §2/§3 (die den Command nicht nennen).

## Negativbefunde (geprüft, ohne Befund — mit ausgeführten Belegen)

- **N-1 · Digest-Pin echt & reproduzierbar (`LH-QA-02`):** `harness.mk` pinnt
  `sha256:9c317bf1…`; `docker buildx imagetools inspect …:v0.46.0` löst **exakt** auf denselben
  Digest auf → die Tag→Digest-Bindung ist real, v0.46.0 belegt, kein floating main. Alter Digest
  `ca49d33f…` repo-weit **0×** verblieben. `--version`-Flag existiert im Image nicht — die
  imagetools-Bindung ist der belastbare Beleg.
- **N-2 · Kein halluziniertes Gate (`LH-QA-01`, §3.1):** aktive `modules:`-Liste unverändert
  `[links, anchors, ids, matrix, codepaths, spans]`; die in v0.46.0 neu verfügbaren Module
  (`planning`, `commits`, `tracked`, `targets`, `versions`, `pins`, `immutable`, `vcs`,
  `hostpaths`, `diagrams`, `external`) sind laut `--print-config` **strikt opt-in / NICHT in
  modules** und hier **nicht** aktiviert. `make gates` grün (Exit 0) — kein neu feuerndes Gate.
- **N-3 · d-check-Schema korrekt:** `--print-config` bestätigt `codepaths.exempt-paths`
  (datei-weit) und `codepaths.ignore-refs` (referenz-weit, „Tombstones entfernter Artefakte") —
  die `.d-check.yml`-Keys sind exakt; das Schema-Beispiel nennt selbst `docs/reviews/**`. Kein
  Raten der Keys.
- **N-4 · `ignore-refs` = genau die entfernten Tombstones (HIGH-Anker geprüft):** `git log
  --diff-filter=D` zeigt, dass `1b2428d` (slice-013) exakt die fünf gelisteten Templates löschte
  (`slice.template.md`, `welle.template.md`, `NNNN-titel.template.md`, `carveout.template.md`,
  `review-report.template.md`). Jeder Eintrag ist ein **bewusst entfernter** Pfad (kein *geplanter*
  — die slice-015-§6-Abgrenzung gilt), keine breite/leere Liste. `roadmap.template.md` (separat als
  Singleton in `1d360e1` entfernt) ist korrekt **nicht** in den fünf.
- **N-5 · §3.5 „Gate-Lockerung ohne ADR" — geprüft, kein Verstoß:** Die Ventil-Adoption reduziert
  Codepath-Umfang, verlangt aber hier **keinen** ADR: (a) direkte Präzedenz `ids.exempt-paths:
  docs/reviews/**` aus MR-001 (`c615da7`), dort explizit „Gate-Anheben → Steering-Loop, kein ADR
  nötig", ohne ADR akzeptiert; (b) §3.5 zielt auf **Modul-(De)Aktivierung/Strenge** — die
  `codepaths`-Aktivierung bleibt unverändert, es wird kein Modul deaktiviert; (c) die Exemptions
  zentralisieren nur die zuvor pro-Zeile via `` `d-check:ignore` `` gesetzten Ausnahmen (Netto-
  Abdeckung auf lebende Inhalte unverändert). Die „keine ADRs"-Setzung im Slice ist damit korrekt.
  Die verbleibende marginale Neu-Lücke ist als F-2 (INFO) festgehalten.
- **N-6 · Marker-Entfernung substanz-treu (§3.3-Nachbarschaft):** `git diff --word-diff` an den
  Review-Dateien zeigt ausschließlich getilgte `` <!-- d-check:ignore … --> ``-Kommentare (16 Stück,
  = Closure-Note-Zahl); kein Zeilen-/Separator-/Textverlust. **0** HTML-Kommentar-Marker verbleiben
  in `docs/reviews/**`. Die 15 repo-weit verbliebenen `d-check:ignore`-Vorkommen sind Prosa-
  Erwähnungen (slice-015/016) bzw. korrekt **unangetastete** ADR-Supersede-Lineage-Marker in
  `docs/plan/adr/0002-…`/`0003-…` (andere Ausnahmeklasse, nicht von `exempt-paths`/`ignore-refs`
  gedeckt, außerhalb slice-016-Scope).
- **N-7 · MR-008 Glob→konkrete Pfade konsistent:** MR-008-Geltungsbereich nennt jetzt die fünf
  vollen Pfade statt der früheren `*.template.md`-Globs; jeder ist durch `ignore-refs` gedeckt, in
  normativer Doku (conventions.md) real referenziert und real gelöscht — `make docs-check` grün
  belegt, dass keine dieser Referenzen einen Codepath-Befund erzeugt. Die Präzisierung **verengt**
  korrekt (droppt den Singleton `roadmap.template.md`), löst keine LH-FA-02-Emissions-Anforderung auf.
- **N-8 · MR-009 Anker & Links auflösend:** `anchors`+`links` sind aktive Module und `make
  docs-check` ist grün → der Anker `#mr-009--d-check-pin-sprung-und-codepath-ventile` (aus MR-008,
  slice-016 §7) und der relative Link `[docs/reviews/](../docs/reviews/)` in MR-009 lösen auf.
- **N-9 · §Baseline-Konsistenz:** `harness/conventions.md:14` §Baseline sagt jetzt „Image v0.46.0";
  die weiteren v0.10.0-Nennungen (Z. 350/362) beschreiben korrekt den Sprung **von** v0.10.0.
- **N-10 · Sekundär modul-09-Treue:** `implement-slice.md`-Schritt-Mapping auf `modul-09`
  Schritte 1–3/4/5–6/7–8 stimmt; Kernidee, Rücksprungkanten und git-mv-Trennung sind treu
  gespiegelt (Inhalt sauber; Provenienz-Vorbehalt siehe F-3).
- **N-11 · Übrige Hard Rules:** §3.2 (keine Lint-Suppression im Diff berührt), §3.4 (keine
  Accepted-ADR verändert — der Diff berührt kein `docs/plan/adr/000*.md`).

## Nicht abschließend verifiziert (netzlos, nicht merge-tragend)

- „29 real veröffentlichte Minors (0.11–0.46, ohne 0.13–0.16/0.20/0.21)" (MR-009/Closure §7) —
  die Nicht-Existenz einzelner Upstream-Tags ist ohne Netz/Release-Liste nicht gegengeprüft; die
  Zahl stützt eine Risiko-Erzählung, nicht die Gate-Korrektheit. Der Trockenlauf-Beleg selbst ist
  über `make docs-check` (40/0) unabhängig reproduziert.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 (F-1, README-Versionsdrift) |
| INFO | 2 (F-2 deklarierte Codepath-Lücke; F-3 sekundär, Commit-Provenienz) |

## Verdikt

**Merge-blockierend:** **nein.** Kein HIGH, kein MEDIUM. Der Pin ist echt (v0.46.0, Digest
imagetools-belegt), die zwei Ventil-Achsen nutzen das autoritative Schema, `ignore-refs` deckt
byte-genau die fünf entfernten Tombstones, die 16 Marker-Entfernungen sind substanz-treu, und
kein neues Modul feuert (`LH-QA-01` gehalten). Die zentrale Risiko-Frage — Gate-Lockerung ohne
ADR (§3.5) — ist geprüft und **entkräftet** (Präzedenz MR-001, Modul bleibt aktiv, Mechanik-
Refactor). `make gates` **Exit 0** unabhängig reproduziert.

Das eine LOW (F-1) ist ein übersehener zweiter Versions-String in einer kanonischen Quelle
(`README.md`) — kein Gate fängt ihn, deshalb hier gemeldet; behebbar mit einer Zeile, nicht
blockierend. Die zwei INFO dokumentieren eine bewusst deklarierte Abdeckungs-Lücke (F-2, bis
slice-015 landet) und einen Provenienz-Vorbehalt zum mitreisenden sekundären Command-Patch (F-3).

**Steering-Loop-Bezug:** F-1 ist ein neuer Fall der schon in slice-014 (F-1) gesehenen Klasse
„Nachführung nur an *einer* Stelle statt an allen Vorkommen einer Aussage". Lehre analog: bei
Versions-/Pin-Nachführung `grep` nach *allen* Vorkommen der Alt-Version in lebenden Quellen, nicht
nur an der DoD-genannten Zeile. Kandidat für die geschärfte DoD-Formulierung „§Baseline **und alle
weiteren Versions-Nennungen** nachziehen".
