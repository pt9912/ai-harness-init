# Harness-Konventionen

## Purpose

Repo-lokale Strukturregeln gegenüber der adoptierten Baseline. Bei
Konflikt mit einer kanonischen Quelle gilt diese (Source Precedence).

## Baseline

- **Konvention:** AI-Harness-Kurs
- **Stand:** `v6.0.0`
- **Regelwerk + Templates:** committet vendored unter
  `.harness/baseline/v6.0.0/` ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)); Regelwerks-Stand laut
  `regelwerk/README.md`: **Kurs-Welle 116 · 2026-09-03**
  (`sed -n '3p' .harness/baseline/v6.0.0/regelwerk/README.md`).
- **d-check:** der lebende Pin steht in `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`) und, per
  go-Test daran gekoppelt, in `internal/emit/emit.go` — hier steht keine zweite Fassung davon
  ([`MR-027`](#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) §Kein Wächter).
  Die Sprünge dieser Linie führen [`MR-009`](#mr-009--d-check-pin-sprung-und-codepath-ventile),
  [`MR-010`](#mr-010--d-check-gate-fragment-tool-generiert), [`MR-011`](#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines), [`MR-012`](#mr-012--d-check-pin-v0511-sources-verfügbar), [`MR-024`](#mr-024--d-check-pin-v0620-structure-verfügbar) und [`MR-027`](#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt).
- **Datum der Adoption:** 2026-06-13 (Templates-Stand damals: `templates-v4`).
  **Re-Baseline auf `v3.1.0`:** 2026-07-17 (slice-011/012); **auf `v3.5.0`:** 2026-07-19 (slice-019);
  **auf `v3.5.1`:** 2026-07-24 (slice-043); **auf `v3.5.2`:** 2026-07-26 (slice-049,
  Normativ-Delta in [`MR-015`](#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) entschieden);
  **auf `v5.12.0`:** 2026-08-28 (slice-081, Normativ-Delta in slice-082 entschieden);
  **auf `v5.18.0`:** 2026-09-03, Delta-Nachweis in slice-155;
  **auf `v6.0.0`:** 2026-09-04, Delta-Nachweis in slice-176. Die Form dieser Zeile — Ziel-Tag,
  Datum, der Slice mit dem Delta-Nachweis, sonst nichts — und der Ort einer Zielstand-Setzung
  stehen in
  [`ADR-0031`](../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Festlegung 2. **Welche Fassung den Sprung auf `v6.0.0` regiert, ist offen:** Festlegung 1 jener
  ADR bindet allein den Sprung auf `v5.18.0`, und ihr erster Re-Evaluierungs-Trigger verlangt für
  jeden weiteren eine eigene Messung; sie ist in slice-176 gefahren, entschieden wird sie in
  slice-178. Die
  Prozedur des Sprungs auf `v5.12.0` steht in
  [`ADR-0018`](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md), der
  Verweis-Beschluss ist in
  [`ADR-0023`](../docs/plan/adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) gegen jenen
  Zielstand neu gehalten. **Wie viele Upstream-Releases dazwischenliegen, steht hier
  nicht:** die Zahl ist nur am lokalen Kurs-Klon zu messen, und kein Kommando dieses Repos gibt
  sie aus ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1).

**Was das Feld `Stand:` trägt.** Den adoptierten Stand als **Version**, nie als Datum — das Datum
steht in der eigenen Zeile `Datum der Adoption:`. Das Feld ist der Bezugspunkt, den ein
Versions-Sensor über den Anker dieses Abschnitts liest und gegen jeden Baseline-Pin im Repo hält;
ein Datum an dieser Stelle liefert ihm keine Version, und er bricht fail-closed ab. Ziel-Form:
[`conventions.template.md`](../.harness/baseline/v6.0.0/templates/harness/conventions.template.md)
§Baseline. **Ein solcher Sensor läuft in diesem Repo nicht** — die Modul-Liste der
[`.d-check.yml`](../.d-check.yml) führt kein `versions` (`grep -n '^modules:' .d-check.yml`); das
Feld steht als Ziel-Form, nicht als bewachte Zusage.

## Adoptierte Konventions-Quellen

- **Extern (Kurs, kanonisch):** <https://github.com/pt9912/ai-harness-course/tree/v6.0.0/kurs/de>
  — auf den Tag `v6.0.0` gepinnt, **nicht** `main`-floating
  ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Netzlos nachprüfbar ist der
  vendored Baum — `make baseline-verify` →
  `baseline-verify: v6.0.0 OK — 53 Dateien (Integritaet + Vollstaendigkeit, netzlos)`. **Die
  Dateizahl ist kein Erwartungswert** ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — sie wandert mit dem Stand; tragend ist das `OK`. Die URL ersetzt die frühere
  `raw…/main/…/agents-regelwerk.md`-Monolith-URL, die **404** liefert (der Monolith
  existiert upstream seit v2.0.0 nicht mehr — die Module leben unter `/kurs/de/`).
- **Die Provenienz-Kette ist zur Hälfte bewacht**, und die unbewachte Hälfte steht hier, weil sie
  sonst als belegt gälte ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Fünf
  Stellen pinnen `v6.0.0` samt dem sha256 seines Release-Assets: `BASELINE_TAG` und
  `BASELINE_ZIP_SHA256` (`grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile`), das `sources`-Paar in
  [`.d-check.yml`](../.d-check.yml) (`grep -n 'lab-regelwerk' -A 1 .d-check.yml`) und
  `DefaultTag`/`DefaultBaselineSHA256` in `internal/fetch/baseline.go`
  (`grep -nE 'Default(Tag|BaselineSHA256) =' internal/fetch/baseline.go`). Kanonisch ist das
  Makefile-Paar; die vier übrigen sind fail-closed daran gekoppelt und laufen in `make gates`
  (`test/sources-pin.bats`, `TestDefaultTag_MatchesBaseline`,
  `TestDefaultBaselineSHA256_MatchesMakefile`) — ein Sprung, der eine Stelle stehen lässt, färbt
  rot. **Pin → Asset** hält `make regelwerk-check` (Netz, **nicht** in `make gates`) →
  `0 Befund(e)`, EXIT 0. **Asset → vendored Baum** hält nichts: `regelwerk-check` hasht die
  Roh-Bytes des ZIP (`unpack: none`), `make baseline-verify` hält den Baum gegen `SHA256SUMS`, und
  `SHA256SUMS` ist selbst erzeugt — es trägt allein die lokale Integrität, nicht die Herkunft
  (`harness/tools/baseline-verify.sh` §Kopfkommentar). Ein drittes Ziel, das beide Seiten hielte,
  gibt es nicht: `make baseline-freshness` prüft die Tag-Achse, nicht den Inhalt
  (`grep -nE '^(baseline|regelwerk)[a-z-]*:' Makefile` nennt die drei). Diese Hälfte hängt am
  Vendoring-Vorgang, nicht an einem Sensor.
- **In-Repo (verkörperte Form):** die committet vendored Baseline
  `.harness/baseline/v6.0.0/{regelwerk,templates}/` ([`MR-007`](#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) — die
  präsente, netzlose Sicht auf die kanonische Quelle; bei Konflikt gilt der Kurs.

## Adaptions-Block

**Disziplin.** Ein Eintrag je Datei unter [`conventions/`](conventions/), chronologisch pro Repo
nummeriert, mit den Pflichtfeldern der Ziel-Form
([`MR-045`](#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)). An einem angenommenen
Eintrag wird nichts nachträglich inhaltlich geändert: eine Teil-Ablösung trägt eine Kopf-Marke
([`MR-032`](#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)), eine
vollständige Aufhebung Kopf und Zeiger
([`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)), ein nachgetragenes
Pflichtfeld tritt hinzu statt zu ersetzen
([`MR-039`](#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)).
Ist der Auflösungs-Trigger eines Eintrags eingetreten, wandert seine Datei per `git mv` nach
[`conventions/done/`](conventions/done/): der Zustand ist die Verzeichnis-Position, kein
Status-Feld. Die Position ist **binär** — sie trennt *aktiv* von *aufgelöst* und trägt die
Teil-Ablösung nicht, deren Eintrag aktiv bleibt
([`MR-046`](#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).

**Die Index-Tabellen sind derivativ** ([`ADR-0024`](../docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)):
was ein Eintrag setzt, setzt seine Datei. Die Spalten `Geltungsbereich` und
`Ersetzt-Baseline-Regel` der aktiven Tabelle tragen den **Anfang** des gleichnamigen
Pflichtfelds, und ein `…` sagt,
dass es in der Datei weitergeht; bei Abweichung gilt die Datei. Ein `—` steht, wo der Eintrag das
Feld nicht führt — nachgetragen wird es nur nach
[`MR-039`](#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines),
und ein retirierter Eintrag bekommt keines.

**Jede Zeile trägt zwei Anker.** Die kurze Kennung `mr-<NNN>` ist die Adresse, die die Ziel-Form
für neue Verweise vorsieht; der Überschriften-Slug `mr-<NNN>--<titel>` ist die Adresse, unter der
der Bestand des Repos diesen Block anspricht. Beide zeigen auf dieselbe Zeile, und die Zeile zeigt
auf die Datei — deshalb kostet der Umzug eines Rumpfs keinen Verweis-Nachzug.

### Aktive Adaptionen

Eine Zeile je Datei in [`conventions/`](conventions/).

| MR | Titel | Geltungsbereich | Ersetzt-Baseline-Regel |
|---|---|---|---|
| [MR-000](conventions/MR-000-baseline-aussage.md) <a id="mr-000"></a><a id="mr-000--baseline-aussage"></a> | Baseline-Aussage | gesamtes Repo | keine — und nach dem Wortlaut der Eintrags-Vorlage trotzdem **kein … |
| [MR-001](conventions/MR-001-doc-gate-schaerfung-matrix--link-pflicht--anker-ids.md) <a id="mr-001"></a><a id="mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids"></a> | Doc-Gate-Schärfung (matrix + Link-Pflicht + Anker-IDs) | `.d-check.yml` (Doc-Referenz-Gate) | [`grundlagen-referenz-richtung.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-referenz-richtung.md#referenz-richtung-sdp-wer-darf-wen-referenzieren) … |
| [MR-002](conventions/MR-002-gate-nachweis-mechanik-und-claude-hooks.md) <a id="mr-002"></a><a id="mr-002--gate-nachweis-mechanik-und-claude-hooks"></a> | Gate-Nachweis-Mechanik und Claude-Hooks | [`harness/tools/`](../harness/tools/), [`.claude/`](../.claude/), `make record-gates` | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-003](conventions/MR-003-haertung-inhaltsbasierter-nachweis-und-sub-shell-pruefung.md) <a id="mr-003"></a><a id="mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung"></a> | Härtung: inhaltsbasierter Nachweis und Sub-Shell-Prüfung | [`harness/tools/working-tree-hash.sh`](../harness/tools/working-tree-hash.sh), [`.claude/hooks/`](../.claude/hooks/) | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-004](conventions/MR-004-sessionstart-regelwerk-injektor.md) <a id="mr-004"></a><a id="mr-004--sessionstart-regelwerk-injektor"></a> | SessionStart-Regelwerk-Injektor | [`harness/tools/`](../harness/tools/), [`.claude/`](../.claude/), [`.codex/`](../.codex/), `.harness/cache/`, `CLAUDE.md`, `Makefile`, `.d-check.yml` | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**. … |
| [MR-005](conventions/MR-005-harness-tools-unter-harnesstools-layout-adaption.md) <a id="mr-005"></a><a id="mr-005--harness-tools-unter-harnesstools-layout-adaption"></a> | Harness-Tools unter harness/tools/ (Layout-Adaption) | [`harness/tools/`](../harness/tools/), [`.claude/`](../.claude/), [`.codex/`](../.codex/), `Makefile`, `.d-check.yml` | [`grundlagen-durchsetzungsschicht.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-durchsetzungsschicht.md#das-vollständige-artefakt-set) … |
| [MR-006](conventions/MR-006-regelwerk-cache-als-split-modul-verzeichnis.md) <a id="mr-006"></a><a id="mr-006--regelwerk-cache-als-split-modul-verzeichnis"></a> | Regelwerk-Cache als Split-Modul-Verzeichnis | `Makefile`, [`harness/tools/`](../harness/tools/), `.harness/cache/`, `CLAUDE.md`, `AGENTS.md`, [`test/`](../test/); ergänzt [`MR-004`](#mr-004--sessionstart-regelwerk-injektor). | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-007](conventions/MR-007-baseline-committet-vendored-statt-gefetchter-cache.md) <a id="mr-007"></a><a id="mr-007--baseline-committet-vendored-statt-gefetchter-cache"></a> | Baseline committet vendored statt gefetchter Cache | `.harness/baseline/`, `Makefile`, [`harness/tools/`](../harness/tools/), `.gitignore`, `.d-check.yml`, `AGENTS.md`, `CLAUDE.md`, [`harness/README.md`](README.md), [`test/`](../test/); löst den Cache-Teil von [`MR-004`](#mr-004--sessionstart-regelwerk-injektor)/[`MR-006`](#mr-006--regelwerk-cache-als-split-modul-verzeichnis) ab. | [`modul-02-harness-bootstrap.md`](../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2) … |
| [MR-008](conventions/MR-008-ausfuell-templates-referenziert-statt-kopiert.md) <a id="mr-008"></a><a id="mr-008--ausfüll-templates-referenziert-statt-kopiert"></a> | Ausfüll-Templates referenziert statt kopiert | die fünf in slice-013 gelöschten Repo-Template-Kopien … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-009](conventions/MR-009-d-check-pin-sprung-und-codepath-ventile.md) <a id="mr-009"></a><a id="mr-009--d-check-pin-sprung-und-codepath-ventile"></a> | d-check-Pin-Sprung und Codepath-Ventile | `harness.mk` (`D_CHECK_IMAGE`), `.d-check.yml` … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**. … |
| [MR-010](conventions/MR-010-d-check-gate-fragment-tool-generiert.md) <a id="mr-010"></a><a id="mr-010--d-check-gate-fragment-tool-generiert"></a> | d-check-Gate-Fragment tool-generiert | `d-check.mk` (aus `harness.mk` umbenannt), `Makefile` (`include`), §Baseline, … | [`modul-02-harness-bootstrap.md`](../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2) … |
| [MR-011](conventions/MR-011-zitat-verifikation-via-d-check-adoptiert-check-lines.md) <a id="mr-011"></a><a id="mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines"></a> | Zitat-Verifikation via d-check adoptiert (check-lines) | `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`), `.d-check.yml` … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**. … |
| [MR-012](conventions/MR-012-d-check-pin-v0511-sources-verfuegbar.md) <a id="mr-012"></a><a id="mr-012--d-check-pin-v0511-sources-verfügbar"></a> | d-check-Pin v0.51.1 (sources verfügbar) | `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`), `internal/emit/emit.go` … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-013](conventions/MR-013-regelwerk-check-auf-d-check-sources-tool-statt-skript.md) <a id="mr-013"></a><a id="mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript"></a> | regelwerk-check auf d-check `sources` (Tool statt Skript) | `Makefile` (`regelwerk-check`-Recipe), `.d-check.yml` (`sources:`-Block), … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-014](conventions/MR-014-ci-auf-frischem-klon-github-actions.md) <a id="mr-014"></a><a id="mr-014--ci-auf-frischem-klon-github-actions"></a> | CI auf frischem Klon (GitHub Actions) | `.github/workflows/ci.yml` (neu), `Makefile` (`ACTIONLINT_IMAGE`, … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-015](conventions/MR-015-change-request-bei-personalunion-von-auftraggeber-und-entwickler.md) <a id="mr-015"></a><a id="mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler"></a> | Change Request bei Personalunion von Auftraggeber und Entwickler | `spec/lastenheft.md` §7 Historie (**Form künftiger** Einträge, nicht die … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-017](conventions/MR-017-default-regel-fuer-emittierte-pruefbereiche-fail-closed.md) <a id="mr-017"></a><a id="mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed"></a> | Default-Regel für emittierte Prüfbereiche (fail-closed) | jede vom Tool **emittierte** Gate-Konfiguration, die ein Adopter … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-019](conventions/MR-019-technik-stratum-als-rang-2-der-source-precedence.md) <a id="mr-019"></a><a id="mr-019--technik-stratum-als-rang-2-der-source-precedence"></a> | Technik-Stratum als Rang 2 der Source Precedence | [`spec/spezifikation.md`](../spec/spezifikation.md), … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-020](conventions/MR-020-aufgehobener-eintrag-behaelt-kopf-und-zeiger-statt-rumpf.md) <a id="mr-020"></a><a id="mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf"></a> | Aufgehobener Eintrag behält Kopf und Zeiger statt Rumpf | dieser Adaptions-Block. **Nicht** `docs/plan/adr/` — dort gilt … | [`grundlagen-harness-dateien.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher) … |
| [MR-021](conventions/MR-021-das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben.md) <a id="mr-021"></a><a id="mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben"></a> | Das Span-Schema zieht ins Technik-Stratum, sein Eintrag wird aufgehoben | [`MR-018`](#mr-018--span-schema-der-telemetrie-erfassung) sowie die … | [`modul-15-observability.md`](../.harness/baseline/v6.0.0/regelwerk/modul-15-observability.md#span-audit-attribut-regeln) … |
| [MR-024](conventions/MR-024-d-check-pin-v0620-structure-verfuegbar.md) <a id="mr-024"></a><a id="mr-024--d-check-pin-v0620-structure-verfügbar"></a> | d-check-Pin v0.62.0 (structure verfügbar) | `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar), … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-025](conventions/MR-025-eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert.md) <a id="mr-025"></a><a id="mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert"></a> | Eine Zahl im Text steht neben dem Kommando, das sie liefert | die **lebenden**, repo-eigenen Markdown-Artefakte — gemessen … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-026](conventions/MR-026-die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung.md) <a id="mr-026"></a><a id="mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung"></a> | Die Hard-Rule-Nummer ist eine Adresse, keine Baseline-Entsprechung | der Hard-Rule-Block [`AGENTS.md`](../AGENTS.md) §3 gegenüber … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-027](conventions/MR-027-d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt.md) <a id="mr-027"></a><a id="mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt"></a> | d-check-Pin v0.65.0 (Ignore-Marker in zwei Achsen verengt) | `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar), … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-028](conventions/MR-028-der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt.md) <a id="mr-028"></a><a id="mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt"></a> | Der Wirksamkeits-Anlass steht im Eintrag, blank statt verlinkt | die **Form** eines Eintrags dieses Blocks. **Nicht** `docs/plan/adr/`, … | [`grundlagen-traceability.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-traceability.md#herkunfts-anker) … |
| [MR-029](conventions/MR-029-der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage.md) <a id="mr-029"></a><a id="mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage"></a> | Der `scan.ignore`-Zensus wandert, und sein dritter Grund ist keine Scoping-Aussage | `scan.ignore` in `.d-check.yml`, und **nur** dieser Posten von … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-030](conventions/MR-030-der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen.md) <a id="mr-030"></a><a id="mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen"></a> | Der Rollen-Name der Baseline und der Bezeichner fallen zusammen | Punkt 2 der Liste *„Was als Delta bleibt"* in … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, … |
| [MR-031](conventions/MR-031-die-kommentar-regel-steht-in-der-adoptierten-baseline.md) <a id="mr-031"></a><a id="mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline"></a> | Die Kommentar-Regel steht in der adoptierten Baseline | [`MR-022`](#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) … | keine. Dieser Eintrag setzt **keine** Abweichung, er baut zwei … |
| [MR-032](conventions/MR-032-ein-ueberholter-eintrag-traegt-eine-kopf-marke-auf-seinen-nachfolger.md) <a id="mr-032"></a><a id="mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger"></a> | Ein überholter Eintrag trägt eine Kopf-Marke auf seinen Nachfolger | die **Form** eines Eintrags dieses Blocks, dessen Aussage ein späterer … | [`grundlagen-harness-dateien.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher) … |
| [MR-033](conventions/MR-033-eine-aussage-ueber-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist.md) <a id="mr-033"></a><a id="mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist"></a> | Eine Aussage über die Baseline nennt den Tag, gegen den sie gemessen ist | die **lebenden**, repo-eigenen Markdown-Artefakte — derselbe Ausschnitt, … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**. … |
| [MR-034](conventions/MR-034-das-geteilte-referenz-ventil-traegt-am-gepinnten-stand.md) <a id="mr-034"></a><a id="mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand"></a> | Das geteilte Referenz-Ventil trägt am gepinnten Stand | die **Werkzeug-Aussage** über das Doku-Gate in zwei Einträgen dieses … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**. … |
| [MR-035](conventions/MR-035-der-automatische-claude-kontext-traegt-eine-benannte-geschlossene-modul-auswahl.md) <a id="mr-035"></a><a id="mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl"></a> | Der automatische Claude-Kontext trägt eine benannte, geschlossene Modul-Auswahl | `.claude/rules/` und der Zugriffs-Absatz in … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**. … |
| [MR-036](conventions/MR-036-die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline.md) <a id="mr-036"></a><a id="mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline"></a> | Die Change-Request-Regel bei Personalunion steht jetzt in der adoptierten Baseline | [`MR-015`](#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) … | [`grundlagen-source-precedence.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-source-precedence.md) … |
| [MR-037](conventions/MR-037-wellenlose-arbeit-ist-jetzt-baseline-default-ihr-ausloeser-test-ist-neu-gefasst.md) <a id="mr-037"></a><a id="mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst"></a> | Wellenlose Arbeit ist jetzt Baseline-Default, ihr Auslöser-Test ist neu gefasst | [`MR-016`](#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) … | [`modul-06-roadmap.md`](../.harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md) … |
| [MR-038](conventions/MR-038-ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte.md) <a id="mr-038"></a><a id="mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte"></a> | Ein retirierender Eintrag nennt den Baseline-Stand, der seinen Trigger feuerte | [`MR-020`](#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) … | [`modul-02-harness-bootstrap.md`](../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md) … |
| [MR-039](conventions/MR-039-ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines.md) <a id="mr-039"></a><a id="mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines"></a> | Ein fehlendes Pflichtfeld wird nachgetragen, ein retirierter Eintrag bekommt keines | die **Form** eines Eintrags dieses Blocks, wenn ein adoptierter … | [`grundlagen-harness-dateien.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher) … |
| [MR-040](conventions/MR-040-drei-ausgaenge-fuer-eine-praesens-aussage-ueber-den-vendored-baum.md) <a id="mr-040"></a><a id="mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum"></a> | Drei Ausgänge für eine Präsens-Aussage über den vendored Baum | die **lebenden**, repo-eigenen Markdown-Artefakte — derselbe Ausschnitt, den … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, der … |
| [MR-041](conventions/MR-041-die-referenz-statt-kopie-setzung-fuer-ausfuell-templates-steht-jetzt-in-der-adoptierten-baseline.md) <a id="mr-041"></a><a id="mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline"></a> | Die Referenz-statt-Kopie-Setzung für Ausfüll-Templates steht jetzt in der adoptierten Baseline | [`MR-008`](#mr-008--ausfüll-templates-referenziert-statt-kopiert) — die … | [`modul-02-harness-bootstrap.md`](../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md#greenfield-bootstrap-schritt-sequenz-modul-2) … |
| [MR-042](conventions/MR-042-der-anlass-einer-lastenheft-aenderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz.md) <a id="mr-042"></a><a id="mr-042--der-anlass-einer-lastenheft-änderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz"></a> | Der Anlass einer Lastenheft-Änderung steht nicht in der Historie, sondern in der Closure-Notiz | [`MR-015`](#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) … | [`modul-03-spec.md`](../.harness/baseline/v6.0.0/regelwerk/modul-03-spec.md) … |
| [MR-043](conventions/MR-043-ein-nachgetragenes-pflichtfeld-schlaegt-die-einordnung-im-rumpf.md) <a id="mr-043"></a><a id="mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf"></a> | Ein nachgetragenes Pflichtfeld schlägt die Einordnung im Rumpf | [`MR-028`](#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt) … | [`grundlagen-traceability.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-traceability.md#herkunfts-anker) … |
| [MR-044](conventions/MR-044-das-technik-stratum-traegt-die-id-spalte-der-ziel-form.md) <a id="mr-044"></a><a id="mr-044--das-technik-stratum-trägt-die-id-spalte-der-ziel-form"></a> | Das Technik-Stratum trägt die ID-Spalte der Ziel-Form | [`MR-021`](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) … | [`modul-15-observability.md`](../.harness/baseline/v6.0.0/regelwerk/modul-15-observability.md#span-audit-attribut-regeln) … |
| [MR-045](conventions/MR-045-der-adaptions-block-laeuft-in-der-verzeichnis-form.md) <a id="mr-045"></a><a id="mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form"></a> | Der Adaptions-Block läuft in der Verzeichnis-Form | dieser Block — [`harness/conventions.md`](conventions.md) als Index und … | [`grundlagen-harness-dateien.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher) … |
| [MR-046](conventions/MR-046-die-verzeichnis-position-ist-binaer-und-traegt-die-kopf-marke-nicht.md) <a id="mr-046"></a><a id="mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht"></a> | Die Verzeichnis-Position ist binär und trägt die Kopf-Marke nicht | die **Form** eines Eintrags dieses Blocks, dessen Aussage ein späterer Eintrag teilweise ablöst, … | [`grundlagen-harness-dateien.md`](../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher) … |
| [MR-047](conventions/MR-047-der-ort-der-ausfuehrbaren-harness-tools-ist-keine-abweichung-mehr.md) <a id="mr-047"></a><a id="mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr"></a> | Der Ort der ausführbaren Harness-Tools ist keine Abweichung mehr | [`MR-005`](#mr-005--harness-tools-unter-harnesstools-layout-adaption) — die **Abweichungs-Aussage**: dass `harness/tools/` an die Stelle eines … | keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, der nach … |
| [MR-048](conventions/MR-048-der-reproduzierbarkeits-anker-ist-die-rezept-form-die-skelette-pinnen-per-tag.md) <a id="mr-048"></a><a id="mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag"></a> | Der Reproduzierbarkeits-Anker ist die Rezept-Form, die emittierten Skelette pinnen per Tag | die **Anker-Frage** auf beiden Ebenen, getrennt beantwortet — `Dockerfile`, `Makefile` und `d-check.mk` (Dogfood) sowie die Skelett-Vorlagen in … | [`modul-14-docker-harness.md`](../.harness/baseline/v6.0.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14) §Multi-Stage-Build … |
| [MR-049](conventions/MR-049-drei-eigene-gate-rezepte-reichen-den-baum-read-only-herein.md) <a id="mr-049"></a><a id="mr-049--drei-eigene-gate-rezepte-reichen-den-baum-read-only-herein-statt-ihn-per-copy-ins-bild-zu-nehmen"></a> | Drei eigene Gate-Rezepte reichen den Baum read-only herein, statt ihn per COPY ins Bild zu nehmen | die drei Rezepte `test-bats`, `shell-lint` und `ci-lint` im `Makefile`. **Nicht** `docs-check` und die `doc-*`-Rezepte in `d-check.mk` … | [`modul-14-docker-harness.md`](../.harness/baseline/v6.0.0/regelwerk/modul-14-docker-harness.md#der-prüflauf-ist-hermetisch--kein-mount) §Der Prüflauf ist hermetisch … |
| [MR-050](conventions/MR-050-zwei-gate-ziele-fahren-ohne-no-cache-filter.md) <a id="mr-050"></a><a id="mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt"></a> | Zwei Gate-Ziele fahren ohne `--no-cache-filter`, weil ihr Cache-Schlüssel den Prüfgegenstand deckt | die Rezepte `build` und `host-bin` im `Makefile` (beide in `record-gates`) sowie `compile` (kein Gate) … | [`modul-14-docker-harness.md`](../.harness/baseline/v6.0.0/regelwerk/modul-14-docker-harness.md#der-prüflauf-ist-hermetisch--kein-mount) §Der Prüflauf ist hermetisch — kein Mount, Griff 1 … |

### Aufgelöste Adaptionen

Eine Zeile je Datei in [`conventions/done/`](conventions/done/) — Kennung und Auflösung, sonst
nichts: die Kette bleibt auffindbar, ohne gelesen zu werden. Der Anker zieht aus der Tabelle
darüber mit um, und **er** ist der Grund, warum ein Verweis auf eine aufgelöste Adaption nicht
bricht. Die zweite Spalte zeigt auf die **Index-Zeile** des ablösenden Eintrags, nicht auf seine
Datei: die wandert bei ihrer eigenen Auflösung weiter.

| MR | aufgelöst durch |
|---|---|
| [MR-016](conventions/done/MR-016-welle-oder-nicht-und-wo-wellenlose-arbeit-gefuehrt-wird.md) <a id="mr-016"></a><a id="mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird"></a> | [MR-037](#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst) |
| [MR-018](conventions/done/MR-018-span-schema-der-telemetrie-erfassung.md) <a id="mr-018"></a><a id="mr-018--span-schema-der-telemetrie-erfassung"></a> | [MR-021](#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) |
| [MR-022](conventions/done/MR-022-kommentar-regel-als-vorgriff-auf-eine-neuere-baseline.md) <a id="mr-022"></a><a id="mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline"></a> | [MR-031](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline) |
| [MR-023](conventions/done/MR-023-die-platzierung-der-kommentar-regel-ist-keine-abweichung.md) <a id="mr-023"></a><a id="mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung"></a> | [MR-031](#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline) |

## Modus-Deklaration pro Sub-Area

**Eine Kürzel-Spalte führt diese Tabelle nicht.** Die Ziel-Form verlangt sie nur dort, wo Kennungen
ein Bereichssegment tragen (`ADR-<KUERZEL>-NNNN`, `slice-<KUERZEL>-NNN`); wer ohne Segment zählt,
streicht sie (adoptierter Stand `v5.18.0`,
`.harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md`
§harness/conventions.md als Konventionsspeicher). Dieses Repo zählt ohne Segment: Das ID-Schema in
[`MR-000`](#mr-000--baseline-aussage) führt keines, und keine vergebene Kennung trägt eines.

```sh
git grep -ohE '\b(ADR|CO|MR)-[A-Z]{2,}-[0-9]+|\bslice-[A-Z]{2,}-[0-9]+' -- '*.md' ':!.harness/baseline' | sort -u | wc -l   # 0
```

**Kein Erwartungswert** ([`MR-025`](#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit dem Bestand; die Aussage hängt daran, dass sie null ist. Der
Zählraum wird erst mit dem zweiten Menschen am Repo zur Frage, und hier fallen Auftraggeber und
Entwickler zusammen
([`MR-015`](#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)). Ein
vergebenes Kürzel ist unveränderlich — es steht dann in Kennungen, in Commits und in Verweisen —,
deshalb entsteht die Spalte mit dem Segment und nicht auf Vorrat.

| Sub-Area | Modus | Begründung | Graduation |
|---|---|---|---|
| `*` (gesamtes Repo) | Greenfield | Neues Repo, Doc führt, Code folgt | n/a (GF) |
| `harness/tools/` | Greenfield | adoptierte Harness-Mechanik (Adaptions-Block) | n/a (GF) |
| `.codex/` | Greenfield | neue Pfad-Familie, adoptierte SessionStart-Hook-Mechanik | n/a (GF) |

**Wer der „Auswerter (slice-060)" aus [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) ist.**
Die ADR ist ab *Accepted* immutabel und nennt an drei Stellen die Slice-**ID** 060 als den
Auswertungs-Slice (Festlegung 1 Punkt 3 sowie die Re-Evaluierungs-Trigger 2 und 6). Der Schnitt
vom 2026-07-29 hat die Arbeit geteilt: **slice-060 ist die Rollen-Achse** (Erfassung),
**slice-066 ist die Auswertung**. Gemeint ist an allen drei Stellen der **auswertende** Slice,
also slice-066. Diese Umdeutung steht hier und nur hier — die ADR wird dafür nicht angefasst
([`AGENTS.md`](../AGENTS.md) §3.4).
