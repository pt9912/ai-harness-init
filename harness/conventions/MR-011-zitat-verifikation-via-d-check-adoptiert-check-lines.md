# MR-011 — Zitat-Verifikation via d-check adoptiert (check-lines)

- **Datum:** 2026-07-19
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`), `.d-check.yml`
  (`codepaths.check-lines`), `internal/emit/emit.go` (emittierter Default-Pin), §Baseline-Version;
  setzt [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)/[`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) fort.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
  Am adoptierten Stand `v5.12.0` kennt das Regelwerk weder das aktivierte Property noch das
  verworfene Modul (`grep -rl 'check-lines\|citations' .harness/baseline/v5.12.0/regelwerk/` ist
  leer, Exit 1); es regelt das Doku-Gate über das Startgerüst
  `.harness/baseline/v5.12.0/templates/.d-check.yml` und über die Regel, dass der Prüfumfang mit
  den Artefakten wächst — an keine von beiden tritt eine additive Härtung am schon aktiven
  `codepaths`. Auch der **Verzicht** auf `citations` ist keine Abweichung, sondern die Anwendung
  von
  [`modul-13-quality-gates.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-13-quality-gates.md#hard-rule-doku-disziplin)
  §Hard Rule (Doku-Disziplin): *„Vorhanden ≠ behauptet"* — ein Modul über leerem Direktiven-Korpus
  wäre ein behauptetes Gate ohne Deckung. Pin-Sprung und Trockenlauf folgen derselben Doktrin wie
  in [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile).
- **Adaption:** Das gepinnte d-check-Image springt **v0.46.0 → v0.50.0** (Digest in
  `d-check.mk`, **dreifach belegt**: lokaler RepoDigest · d-check-Closure-Notiz/Release-Run ·
  `imagetools`-Registry-Inspektion, [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Die seit v0.50.0 verfügbare
  **Zeilenreferenz-Prüfung** `codepaths.check-lines: true` wird aktiviert: sie verifiziert je
  Inline-Code-Pfad mit `datei:<von>-<bis>` die Existenz der Zieldatei sowie `bis ≤ Zeilenzahl`
  und `von ≤ bis`. Das ist ein **additives Property am bereits aktiven `codepaths`-Modul**
  (nicht-leerer Prüfbereich via `docs-check`) — **kein** eigenständiger Gate-Name in
  [`AGENTS.md`](../../AGENTS.md) §4 / [`harness/README.md`](../README.md) §Sensors
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Emitter-Pin gekoppelt (Tier-1-Drift).** Der d-check-Default-Pin des Bootstrap-Tools
  (`internal/emit`s `DefaultImage`/`DefaultDigest`) ist per go-test an `d-check.mk` gekoppelt
  und zieht mit; die *emittierte* Starter-Config bleibt `modules: [links, anchors]` (codepaths
  dort auskommentiert → **kein** `check-lines`) — Emitter ≠ Dogfood.
- **Löst slice-015 auf.** Der Slice wollte ursprünglich einen lokalen bash-Sensor
  `make cite-check` bauen; dieselbe Fähigkeit ist seit v0.50.0 (d-check-slice-079) nativ
  ausgeliefert. Der Eigenbau entfällt — eine zweite Implementierung derselben Prüfung wäre
  reine Wartungslast ([`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **Trockenlauf vor dem Pin (Pflicht, belegt — [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).** Beide Läufe netzlos
  (`--network none`): (a) v0.50.0 gegen unveränderte Config → **0 Befunde, Exit 0**
  (Pin-Sprung inert; die explizite `modules:`-Liste immunisiert gegen neue Default-Module);
  (b) v0.50.0 mit `check-lines: true` → **0 Befunde, Exit 0** über dem realen Korpus (die
  Zähne unabhängig belegt: `citation-out-of-range` feuert real auf eine Out-of-range-Referenz). Die einzige inhaltliche `--print-mk`-Fragment-Differenz zu v0.46.0: die fünf
  fokussierten advisory-Recipes gewinnen je `--disable citations` (18. Modul neu, opt-in) —
  verbatim vom Tool übernommen.
- **`citations`-Modul bewusst nicht aktiviert.** Das eigenständige verbatim-Modul feuert nur
  auf `d-check:cite`-Direktiven; davon trägt das Repo null → es zu aktivieren wäre ein nie
  feuerndes Gate ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Adoption erst mit einem realen Zitat-Direktiven-Korpus
  (eigener Slice, eigenes False-Positive-Risiko).
- **Kein Rückfall auf stilles Grün / keine spekulative Exemption.** Von den real vorhandenen
  Inline-Code-Zeilenreferenzen (alle in eingefrorenen `done/`-Slices) werden nach
  `codepaths.roots` zwei tatsächlich zeilen-geprüft und bestehen heute. Eine spekulative
  `done/**`-Exemption gegen künftige Frozen-Doc-Drift wäre die breite, unbelegte Liste, vor der
  [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) warnt; sie unterbleibt — der konkrete Fall wird bei Eintritt belegt behandelt.
- **Auflösungs-Trigger:** permanent; Re-Pin bei d-check-Release manuell (Trockenlauf
  wiederholen, [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger); die `citations`-Aktivierung ist ein eigener
  Slice, sobald der Direktiven-Korpus nicht-leer ist.
