# MR-009 — d-check-Pin-Sprung und Codepath-Ventile

- **Datum:** 2026-07-18
- **Geltungsbereich:** `harness.mk` (`D_CHECK_IMAGE`), `.d-check.yml`
  (`codepaths.exempt-paths`, `codepaths.ignore-refs`), [`docs/reviews/`](../../docs/reviews/)
  (entfernte Zeilen-Marker), diese Datei (§Baseline-Version + [MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Geltungsbereich);
  ergänzt [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids).
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
  Der Pin-Sprung tritt an keine Stelle: er **ist** der bewusste Digest-Commit, den
  [`modul-14-docker-harness.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  verlangt (*„Update = bewusster Commit, der nur die Digest-Zeile anhebt"*), und die Neu-Erzeugung
  bei jedem Bump steht in
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk`. Die zwei Ventil-Achsen ebenso wenig: das vendored Startgerüst
  `.harness/baseline/v5.12.0/templates/.d-check.yml` kennt weder `codepaths.exempt-paths` noch
  `codepaths.ignore-refs`, und die Klasse, die `exempt-paths` ausnimmt, führt
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md#jedes-artefakt-hat-einen-konsumenten)
  §Jedes Artefakt hat einen Konsumenten als **Lauf-Beleg** — *„über Läufe hinweg werden sie nicht
  wieder gelesen und müssen es nicht"* —, ohne eine Aussage über den Prüfumfang eines Gates. Die
  Einordnung *„beide sind Scoping, keine Gate-Lockerung"* steht in
  [`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  auf dem geltenden Stand. Gemessen am adoptierten Stand `v5.12.0`.
- **Adaption:** Das gepinnte d-check-Image springt von **v0.10.0** auf **v0.46.0**
  (Digest in `harness.mk`, gegen den Release belegt,
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Zwei seit d-check 0.34.0
  verfügbare `codepaths`-Ventil-Achsen werden adoptiert:
  **`exempt-paths`** nimmt `docs/reviews/**` **datei-weit** aus der Codepath-Prüfung (die
  Zeitdokumente frieren den Stand ihres Review-Laufs ein; die Lifecycle-Pfade
  `next/`→`in-progress/`→`done/` darin veralten per Definition). **`ignore-refs`** deklariert
  die fünf in slice-013 gelöschten Ausfüll-Templates
  ([`MR-008`](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)) **referenz-weit** als
  Tombstones, sodass normative Doku ihre klaren vollen Pfade nennen darf statt der bisherigen
  Glob-Workarounds.
- **Belegter Bedarf (kein spekulativer).** Über den Regelwerk-Zug slice-011…014 musste
  `` `d-check:ignore` `` **wiederholt von Hand** gesetzt werden, weil v0.10.0s `codepaths`
  nur `scope`/`roots` kannte: fünf Lifecycle-Wanderungen in Review-Reports, mehrere
  Template-Tombstones. Die beiden Ventil-Achsen ersetzen die verstreute Handarbeit durch
  zwei zentrale, begründete Config-Zeilen — im Geist von
  [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) („Gate-*Anheben* →
  Steering-Loop, kein ADR nötig").
- **Trockenlauf vor dem Pin (Pflicht, belegt).** v0.46.0 gegen den unveränderten Baum mit
  unveränderter Config: **40 Dateien, 0 Befunde, Exit 0** — trotz **29 real veröffentlichter
  Minors** (0.11–0.46, ohne die nie existierten 0.13–0.16/0.20/0.21) kein Schema-Bruch und
  kein neu feuerndes Pflicht-Modul (die `modules:`-Liste ist explizit). Die in dieser
  d-check-Generation hinzugekommenen Module (`planning`, `commits`, `tracked`, `targets`, …)
  bleiben **opt-in** und werden hier **nicht** aktiviert — kein existierendes Target/Bedarf
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), kein
  halluziniertes Gate).
- **Kein Rückfall auf stilles Grün.** Jede Ventil-Zeile nennt, *was* sie ausnimmt und
  *warum*: `exempt-paths` nur `docs/reviews/**` (Zeitdokumente), `ignore-refs` nur die fünf
  konkret gelöschten Template-Pfade (bewusst **entfernt**, nicht *geplant* — die Abgrenzung
  aus slice-015 §6 gilt; ein geplanter Pfad bleibt Doc-führt-Code-folgt und kein Tombstone).
  Keine breite oder leere Liste.
- **Auflösungs-Trigger:** permanent; Re-Pin bei d-check-Release manuell (Trockenlauf
  wiederholen — seit [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) via `DCHECK_DIGEST`,
  früher `D_CHECK_IMAGE`), `ignore-refs` wächst nur mit weiteren **bewusst entfernten** Artefakten.
