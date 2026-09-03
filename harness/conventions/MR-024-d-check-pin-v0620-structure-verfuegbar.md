# MR-024 — d-check-Pin v0.62.0 (structure verfügbar)

- **Datum:** 2026-08-22
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin), `Makefile` (das Tag-Beispiel im Kommentar
  über `DCHECK_TAG`), §Baseline-Version; setzt [`MR-012`](../conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar) fort.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  aus demselben Grund wie [`MR-012`](../conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar): ein Pin-Sprung,
  der ein Modul **verfügbar** macht, ohne es zu aktivieren, tritt an keine Stelle. Er ist der
  bewusste Digest-Commit aus
  [`modul-14-docker-harness.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  und die Neu-Erzeugung aus
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk`. Das Modul selbst kommt am adoptierten Stand `v5.12.0` im Regelwerk
  nicht vor (`grep -rl 'structure' .harness/baseline/v5.12.0/regelwerk/` ist leer, Exit 1), und es
  nicht zu aktivieren hält
  [`modul-13-quality-gates.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-13-quality-gates.md#hard-rule-doku-disziplin)
  §Hard Rule (Doku-Disziplin) ein. Auch die Strenge-Bilanz ersetzt nichts: sie beantwortet die
  §3.5-Frage von [`AGENTS.md`](../../AGENTS.md) an der Quelle.
- **Adaption:** Das gepinnte d-check-Image springt **v0.51.1 → v0.62.0** — **elf** Minor-Releases
  (v0.52.0 vom 2026-08-09 bis v0.62.0 vom 2026-08-21, die bislang größte Spanne dieser Linie).
  Digest `sha256:3996a593b9cb71aa3bcb4f3ddf8f637e7409db31b3a2dac7eedc28d65814cacf`, **dreifach
  belegt**: lokaler RepoDigest (`docker inspect`) · `docker buildx imagetools inspect` ·
  Release-Body v0.62.0 ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der **lebende** Pin steht in `d-check.mk`
  und, daran gekoppelt, in `internal/emit/emit.go`; hier steht, wogegen er belegt ist.
- **Zweck: `structure` wird verfügbar, nicht aktiviert.** Das opt-in-Modul `structure` — das 20.,
  Struktur-Invarianten **innerhalb** eines Dokuments, mit dem advisory-Target `doc-structure` —
  liegt mit diesem Pin im Repo, wie `sources` es mit
  [`MR-012`](../conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar) wurde. **Aktiviert ist es nicht**
  (`grep -c structure .d-check.yml` → **0**); leer aktiviert wäre es ein Phantom-Gate
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), und ob dieses Repo eine Struktur-Prüfung will, ist eine Frage an
  Prüfbereich und Strenge — ein eigener Schnitt mit eigenem False-Positive-Risiko. Ausgeliefert
  ist das Modul samt Target seit **v0.57.0** (2026-08-15), gemessen am lokalen d-check-Klon
  (`git ls-tree v0.57.0` führt die Regel-Datei des Moduls, `v0.56.0` nicht; der CHANGELOG-Eintrag
  „das 20. Regelmodul" steht unter `[0.57.0]`); v0.62.0 ist der Stand, mit dem es **hier** ankommt.
- **Trockenlauf vor dem Pin (Pflicht, belegt — [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).** v0.62.0 per Digest gegen den
  unveränderten Baum mit unveränderter `.d-check.yml`, netzlos (`--network none`):
  `d-check: 333 Datei(en) geprüft, 0 Befund(e)`, Exit 0 — **byte-gleich** mit dem v0.51.1-Lauf über
  denselben Baum (333/0, Exit 0; der `diff` beider Ausgaben ist leer): **0-Befund-Differenz über
  elf Minors**. Einzige inhaltliche `--print-mk`-Fragment-Differenz zu v0.51.1: das neue Target
  `doc-structure` (elf → zwölf Targets, [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  §Setzung 2) und je ein zusätzliches `--disable structure` in den bestehenden fokussierten
  advisory-Recipes — verbatim vom Tool, wie damals `--disable sources`; die vier Handgriffe der
  Re-Adaption stehen in [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert).
- **Was dieser Lauf trägt — und was nicht.** Er trägt **eine** Richtung: über diesem Korpus
  entsteht kein neuer Befund. In der **Gegenrichtung** ist er über einer 0-Befund-Basis
  informationsleer — eine weggefallene Befundklasse erzeugt dieselbe Ausgabe wie eine unveränderte,
  `333/0` bleibt `333/0`. „Der Sprung senkt keine Strenge" folgt also **nicht** aus dem
  Trockenlauf; das ist eine Aussage über die Regelmodule und wird an ihnen belegt.
- **Strenge-Bilanz der elf Minors, an den aktiven Modulen gemessen.** Aktiv sind sechs
  (`.d-check.yml`: `modules: [links, anchors, ids, matrix, codepaths, spans]`); `sources` läuft
  daneben allein im Maintenance-Target `regelwerk-check`, ausdrücklich **nicht** in `gates`. Gegen
  den lokalen d-check-Klon über `v0.51.1..v0.62.0` gemessen berühren **zwei** der elf Minors ein
  aktives Modul, **beide in Richtung mehr Strenge**: (a) **v0.53.0** gibt `spans` die dritte
  Befundklasse `fence-unclosed` (Fence-Öffnung ohne Schluss bis zum Dateiende) — der Diff der
  Regeldatei dieses Moduls ist rein additiv, `git diff v0.51.1..v0.62.0` zählt dort **null**
  entfernte Zeilen; Anlass war ein ausgelieferter stiller Grün-Pfad, hinter dem Gates grün
  meldeten, ohne geprüft zu haben, und dieses Repo stand auf v0.51.1. Dass die Klasse über diesem
  Baum nicht feuert, sagt der Trockenlauf, nicht die `modules:`-Liste — genau die Grenze, die
  [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) zieht. (b) **v0.60.0** gibt `links`
  den opt-in-Schlüssel `resolve-from` für wandernde Quellorte; hier **nicht** gesetzt, und ohne ihn
  prüft er über einer leeren Gruppenliste — seine Adoption ist eine eigene Entscheidung. Die
  Regeldateien von `ids`, `codepaths` und `matrix` sind über die Spanne **unverändert**
  (`git diff --numstat v0.51.1..v0.62.0` → keine Zeile je Datei); `anchors` ist umgebaut, aber
  nicht in seiner Antwort: Slug- und Anker-Erkennung sind in geteilte Funktionen gezogen, damit
  `versions`, `pins` und `citations` **ihr** folgen (CHANGELOG `[0.58.0]`).
- **Die ausgewiesenen Lockerungen liegen sämtlich in Modulen, die dieses Repo nicht fährt.** Der
  d-check-CHANGELOG benennt Lockerungen wörtlich; über `[0.52.0]`…`[0.62.0]` sind es zweimal
  `closure-note-boilerplate` („findet weniger", „es ist eine **Lockerung**", `[0.56.0]`) und zwei
  weggefallene Falsch-Rot in `planning` (`[0.58.0]`) — beides `planning`/`planning.closure`, hier
  nicht aktiviert — sowie in `[0.58.0]` je ein „findet weniger" bei `citations`, `pins` und
  `versions`, ebenfalls nicht aktiviert. Der einzige Fall an einer **geteilten** Lexik („die
  Fence-Lexik trimmt an allen fünf Konsumenten identisch … Wer hier Befunde verliert, verliert
  Fehlmessungen", `[0.53.0]`) ist am Klon nachgezählt: bewegt hat sich der Trimmer allein im Modul
  `planning` (unicode-weites `TrimSpace` → Space und Tab); die übrigen vier Konsumenten — darunter
  die Vorverarbeitung, aus der **alle** hier aktiven Module lesen — trimmten schon vor v0.53.0
  Space und Tab. `sources` bekam in `[0.52.0]` eine Herkunfts-Korrektur an seiner Befund-Meldung;
  sie greift nur unter `--config`, und `--config` fährt dieses Repo nicht.
- **Welches der zwei Beine die Bilanz trägt.** Die CHANGELOG-Aufzählung ist **bestätigend, nicht
  tragend**: upstream weist sie selbst als unvollständig aus — *„**Diese Aufzählung ist offen** —
  sie nennt die gemessenen Fälle, nicht alle möglichen; in drei Review-Runden ist sie dreimal
  unvollständig gewesen."* (`[0.58.0]`, am lokalen d-check-Klon:
  `awk '/^## \[0\.58\.0\]/,/^## \[0\.57\.0\]/' CHANGELOG.md`). Eine Liste, die ihre eigene
  Vollständigkeit bestreitet, kann die §3.5-Frage nicht beantworten. **Tragend ist das andere
  Bein:** die Quell-Differenz über die Regeldateien der aktiven Module
  (`git diff --numstat v0.51.1..v0.62.0 -- <Regeldatei>`, Bullet oben) — sie ist geschlossen, weil
  sie den Bestand misst statt eine Aufzählung zu lesen. Wer die Bilanz auf die schnellere Hälfte
  verkürzt — CHANGELOG nach „findet weniger" durchsuchen, Modul zuordnen, fertig —, bekommt über
  einer Spanne mit **nicht ausgewiesener** Lockerung an einem aktiven Modul ein grünes Ergebnis
  ohne Deckung.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** §3.5 verlangt einen ADR für **Senkungen**.
  Gemessen senkt der Sprung an keinem aktiven Modul und hebt an einem (`spans`) — „Anheben →
  Steering-Loop, kein ADR nötig" hält
  [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) fest. Diese Bilanz hängt
  an der **Versions-Differenz der Regelmodule**, nicht am Trockenlauf; sie ist gegen einen lokalen
  d-check-Klon aus CHANGELOG und `git diff` reproduzierbar, nicht gegen ein Gate — kein Modul
  dieses Repos vergleicht Befund**klassen** zweier d-check-Versionen.
- **Emitter-Pin gekoppelt (Tier-1-Drift).** `internal/emit`s `DefaultImage`/`DefaultDigest` zieht
  per go-test mit (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` lesen
  `d-check.mk`); die emittierte Starter-Config bleibt `modules: [links, anchors]`
  ([`MR-017`](../conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)) — dort ist `structure` so wenig aktiviert wie `sources` oder `citations`.
  Das Gate-Fragment des Ziels entsteht zur Bootstrap-Zeit live per `--print-mk` aus dem gepinnten
  Image; `make full-smoke` ist der Lauf, der das emittierte Gate mit ihm fährt.
- **Auflösungs-Trigger:** permanent; bei d-check-Release `d-check --print-mk` neu erzeugen + Digest
  neu pinnen ([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger) und
  die Strenge-Bilanz über die neue Spanne neu ziehen — **an der Quell-Differenz der Regeldateien**,
  nicht an der CHANGELOG-Aufzählung; der Trockenlauf allein beantwortet die §3.5-Frage nicht.
