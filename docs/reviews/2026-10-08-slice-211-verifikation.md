# Verifikation: slice-211-codepaths-im-emittierten-doc-gate — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Gegenstand:** `242afb56..964a5d3f` gegen Plan §1–§3 (inkl.
Planner-Zusatz `e6d8cd9c`), DoD §2, [`MR-054`](../../harness/conventions.md#mr-054),
[`MR-087`](../../harness/conventions.md#mr-087) · **Eingang:** Review-Report und Architect-Verdikt
vom selben Tag, Commit-Messages der Implementer-Commits (DoD-Häkchen stehen noch leer).

**Messort:** zwei frisch gebootstrappte Ziele im Scratch (`ai-harness-init --lang go` und sprachlos,
Träger aus `make host-bin` am Stand `964a5d3f`), `make -C <ziel> docs-check`, Pin
`ghcr.io/pt9912/d-check:v0.84.0@sha256:e82ef2d2…` (gleich dem Dogfood-`d-check.mk`), `--network none`.

## Verdikte je DoD-Punkt

- **(1) Kriterium 3 — `codepaths`-Zahn in `make full-smoke`: bestätigt.**
  - Code: `harness/tools/full-smoke.sh` Zahn (5), erwartet `docs/zahn-nicht-vorhanden.md.*codepath-missing`,
    danach `modul_zahn_alte_module_gruen`, Datei zurückgesetzt.
  - Nachgefahren am `--lang go`-Ziel mit genau der Zahn-Zeile: aktuelle Liste →
    `spec/lastenheft.md:136	docs/zahn-nicht-vorhanden.md	codepath-missing …`, `1 Befund(e)`;
    Liste ohne `codepaths` → `0 Befund(e)`; `modules: [links, anchors]` → `0 Befund(e)`.
  - Rot-Beleg des Zahns: `make mutate MUTATE_CASES='573… 574… 575… 576… 577… 578…'` →
    `574-codepaths-zahn-im-ziel-ohne-modul -> FEHLER — codepaths-Zahn rot`; `6 ok, 0 Befund(e)`, EXIT 0.
  - Die rote Ausgabe in CI (`ci` Lauf `37724435931`, `e6d8cd9c`): `full-smoke: codepaths-Zahn belegt …`
    plus die `codepath-missing`-Zeile oben. Die Benennung in §7 liegt beim Planner.
- **(2) Kriterium 2 — grüner Start in beiden Bootstrap-Formen: bestätigt (selbst gemessen).**
  - `make -C <go-ziel> docs-check` → `d-check: 21 Datei(en) geprüft, 0 Befund(e)`, rc 0.
  - `make -C <sprachlos-ziel> docs-check` → `d-check: 21 Datei(en) geprüft, 0 Befund(e)`, rc 0.
  - Offen für §7: Zahl und Kommando stehen bisher nur in der Commit-Message `dcab9550`, ohne Kommando.
- **(3) Entscheidung in der emittierten Datei: bestätigt.**
  - `internal/emit/templates/d-check.yml`: `modules: [links, anchors, ids, matrix, codepaths, spans, planning, structure, targets]`,
    Block `codepaths:` mit `roots: [spec, docs, harness]` und `exempt-paths: ["docs/reviews/**"]`.
  - `TestDCheckConfig_EntschiedeneModulListe` bindet Liste, roots und `exempt-paths`; Rot über 573/575/576
    (`-> TestDCheckConfig_EntschiedeneModulListe rot`, je einmal).
  - `exempt-paths` belegt im Ziel: Report `docs/reviews/…` mit fehlendem `docs/p9-fehlt.md` → still;
    dieselbe Datei nach Entfernen der Zeile → `codepath-missing`, `1 Befund(e)`; zurück → `0 Befund(e)`.
- **Gates: bedingt.** `ci` auf `964a5d3f` (`37725377425`): `gates` success, `smoke` success,
  `full-smoke` lief beim Schreiben noch. Lokaler Grün-Vorlauf `full-smoke` im mutate-Lauf am selben
  Stand grün (154,64 s). `make mutate`: nur Teillauf der sechs neuen Fälle grün; die nachgezogenen
  sed-Anker 295/514/569/572 nicht nachgefahren (der Review prüfte sie auf No-op).
- **Review: bestätigt** — Report liegt vor, F-1 durch [`MR-087`](../../harness/conventions.md#mr-087)
  aufgelöst, F-2/F-3 durch den Handbuch-Absatz, F-4 durch die Fälle 577/578.
- **Closure-Punkte (Notiz, Register, Risiko-Ausgänge, Paarungen):** nicht Gegenstand — Planner.

## Handbuch- und Kommentar-Zusagen am Ziel (Pin v0.84.0)

Eine Probe in `spec/lastenheft.md` des sprachlosen Ziels, `3 Befund(e)`:

- `docs/p1-fehlt.md` → `codepath-missing` ✓ · `./docs/p2-fehlt.md` → `codepath-missing` (relativ
  zu `spec/`) ✓ · `./lastenheft.md` → still (vorhanden) ✓ · `../../p4-ausserhalb.md` → `repo-escape` ✓.
- Still, wie zugesagt: Glob `docs/**/…`, `src/…`, `/docs/…`, Marker `d-check:ignore` mit Grund,
  Pfad im umzäunten Code-Block (auch in Backticks dort).
- `implement-slice.md` „Kennungen prüft das Gate dort wie überall": Report mit unverlinktem
  `ADR-0042` → `id-unlinked` ✓; `docs/reviews/**` steht im Ziel genau in `codepaths` und `matrix`.

## Rot-Beleg der Kommentar-Zusage in `templates.go` (577/578)

- mutate: `577/578 -> make gates im emittierten Repo ist NICHT Exit 0 rot`. Der `expect:` bindet
  das Rot, nicht die Ursache.
- Ursache nachgetragen am `--lang go`-Ziel, beide Stellen auf den Text ohne Neutralisierung gesetzt:
  `docs/plan/planning/README.md:42 docs/plan/carveouts/done/ codepath-missing` und
  `harness/conventions.md:146 harness/conventions/MR-NNN-titel.template.md codepath-missing`,
  `2 Befund(e)`; zurückgesetzt → `0 Befund(e)`. Die zugesagte Ursache trägt.

## Plan-vs-Code

- Jede geänderte Implementer-Datei steht in §3 (inkl. `templates.go`, `implement-slice.md`,
  Handbuch); die vier geänderten Mutations-Fälle sind der nötige Anker-Nachzug zur Zeile
  `test/mutations/`.
- Ohne §3-Zeile: `docs/user/e2e-abdeckung.md` — erzeugte Sicht, nur Zeilen-Adressen verschoben;
  kein Befund.
- Dogfood-`.d-check.yml` unverändert (`git diff --quiet 242afb56..964a5d3f -- .d-check.yml`),
  wie §1/§3 zusagen.
- `exempt-paths` liegt im Umfang über den Planner-Zusatz `e6d8cd9c`, nicht still mitgenommen.

## Offene Punkte für den Planner

- §7: die Messung aus DoD (2) mit Kommando eintragen (oben) und die rote Zahn-Ausgabe benennen.
- `full-smoke` des CI-Laufs `37725377425` vor dem Haken an „`make full-smoke` grün" ablesen.
- Grenze, kein Befund: 577/578 halten das Rot, nicht seine Ursache; die Ursache ist hier einmal
  gelesen, ein späterer Lauf sieht sie nur in der mitgedruckten Ausgabe.
