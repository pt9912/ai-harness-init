# MR-082 — d-check-Pin v0.83.0 (`targets.authority-disjoint` verfügbar, aktiv nur im emittierten Ziel)

- **Datum:** 2026-10-07
- **Wirksamkeits-Anlass:** slice-sprung-auf-v6170-wird-vollzogen;
  [`ADR-0082`](../../docs/plan/adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) Festlegung 2.
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin); setzt
  [`MR-080`](../conventions.md#mr-080--d-check-pin-v0820-targetsauthority-nimmt-eine-liste) fort.
  **Nicht** der Schalter im emittierten Ziel — den trägt
  [`ADR-0082`](../../docs/plan/adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) Festlegung 2 —
  und **nicht** die Methode der Gegenmessung
  ([`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie
  [`MR-080`](../conventions.md#mr-080--d-check-pin-v0820-targetsauthority-nimmt-eine-liste):
  ein Pin-Sprung tritt an keine Baseline-Stelle.
- **Adaption.** Der Pin springt **v0.82.0 → v0.83.0**, Digest
  `sha256:cdc88b0483c6ce8ebfa7266ac830db4a80f3cdaff1385dcc8176dfe74060a1c3`
  (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.83.0`). Der lebende Pin steht in
  `d-check.mk`
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
  `--print-mk` unterscheidet sich zwischen den Digests in einem Hunk (`DCHECK_IMAGE`); das
  Fragment weicht von `--print-mk` in sechs Hunks ab (Kommando im Kopfkommentar von `d-check.mk`),
  die fünf Handgriffe aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)
  sind unverändert. **Verfügbar** wird allein `targets.authority-disjoint: true` (Befund
  `gate-declared-twice`, nur mit `authority` als Liste); ohne Schalter ist die Ausgabe
  byte-identisch. Das Dogfood schaltet ihn nicht (eine Autoritäts-Datei,
  [`ADR-0082`](../../docs/plan/adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) Festlegung 3).
- **Strenge-Bilanz — keine Senkung, keine Verschärfung der aktiven Module.** Gegenmessung nach
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  Setzung 2, netzlos, je Digest ein Lauf über derselben `git archive`-Kopie von `9d89397c` (Angabe
  nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1: kein Objektspeicher); Lauf `make -s -C "$K" docs-check DCHECK_DIGEST=<OLD|NEW>`,
  Befundzeilen `awk -F'\t' 'NF>=3' | sort`, dann `diff` und `cut -f3 | sort | uniq -c`. Ziel:
  `git init` + `.harness/state/bin/ai-harness-init --lang go --name rv` (Träger aus
  `make host-bin`), Sonden wie in `MR-080`, neu geschnitten, zusätzlich eine `targets`-Sonde.

  **Prüf-Bedingung vor dem Lauf**
  ([`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1): in der Kopie sind die Symlinks Symlinks (`git ls-tree 9d89397c .claude/rules/ | grep -c '^120000'`
  → 10, `find .claude/rules -type f` leer); in Stufe 3 hat jedes aktive Modul eine Basis
  (`grep -m1 '^modules:' .d-check.yml` in Dogfood und Ziel).

  | Stufe | `v0.82.0` | `v0.83.0` | `diff` |
  |---|---|---|---|
  | Dogfood unverändert | 2363 Dateien, 0 Befunde | gleich | leer |
  | Marker entwertet | 83 Befunde (46 `codepath-missing`, 37 `id-unlinked`) | gleich | leer |
  | zusätzlich Sonden | 95 Befunde, 13 Grund-Codes, alle neun Module mit Basis | gleich | leer |
  | Ziel `--lang go` unverändert | 21 Dateien, 0 Befunde | gleich | leer |
  | Ziel mit Sonden | 23 Dateien, 11 Befunde, 10 Grund-Codes, alle sieben Module mit Basis | gleich | leer |

  **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2); gemessen an `9d89397c`, einem Stand ohne diesen Eintrag und ohne den Schalter. Die
  Sonden-Skripte bleiben unversioniert — dasselbe akzeptierte Negativ wie in `MR-080`.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5):** die aktiven Module zeigen gleiche
  Befundmengen. Der Schalter im emittierten Ziel ist eine Verschärfung, getragen von
  [`ADR-0082`](../../docs/plan/adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) Festlegung 2.
- **Grenze.** Die Gegenmessung fährt den VCS-Port nicht (`git archive`-Kopie) und lief ohne den
  Schalter; dessen rotes Gegenbeispiel gehört zur Fitness Function der ADR, nicht hierher. Kein
  Sensor hält den Digest gegen den Tag (`BEO-ALL/pin-digest-ohne-waechter`). Die Adaptions-Liste
  in Zeile 2 von `d-check.mk` nennt diesen Eintrag nicht — dasselbe akzeptierte Negativ wie in
  `MR-080`. Datierte Momentaufnahme (`MR-053`).
- **Begründung.** Der Digest ist die Reproduzierbarkeits-Zusage
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); der Sprung liefert die
  Disjunktheits-Prüfung, die die adoptierte Baseline `v6.17.0` mit der Vereinigung der Index-Teile
  einzuschalten verlangt. Keine Aussage eines früheren Eintrags wird abgelöst
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 4); `MR-080` trägt keine Kopf-Marke.
- **Auflösungs-Trigger:** permanent, wie `MR-080`.
