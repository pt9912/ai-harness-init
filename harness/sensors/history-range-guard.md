# `make history-range-guard` — Vorlauf-Wächter für history-lesende d-check-Module

## Vertrag

`make history-range-guard RANGE=<base>..<head>` (oder `STAGED=1`) prüft **vor** einem
history-lesenden d-check-Modul-Lauf (`vcs`/`commits`, Targets `doc-immutable`/`doc-commits` in
`d-check.mk`), dass eine angeforderte Range git-seitig auflösbar **und** nicht leer ist. Kein
Gate, in keiner Prerequisite-Kette — er prüft eine Vorbedingung *für einen Job*, nicht den Zustand
des Repos ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Der Anlass:** `actions/checkout` klont per Default mit Tiefe 1; eine dabei *auflösbare, aber
leere* Range (z. B. `HEAD..HEAD`) meldet d-check ohne diesen Wächter `0 Befund(e)`, Exit 0 —
blind und grün, statt zu fallen
([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 3). Geprüft wird darum die **Range** (`git rev-list --count`), nicht die Klon-Tiefe.
`STAGED=1` prüft keine Range, sondern vergleicht den Index gegen `HEAD` (`git diff --cached`).

## Grenze — was das Grün nicht abdeckt

- **Eine *unauflösbare* Basis** (z. B. `HEAD~1` in einem Tiefe-1-Klon) deckt der Wächter **nicht
  zusätzlich** — d-check selbst bricht dafür schon mit Exit 2 ab, und ein Wächter, der nur das
  fängt, prüfte eine Eigenschaft, die das Werkzeug bereits hält.
- **`STAGED=1` prüft nicht den Inhalt.** Fehlt jede gestagte Änderung, meldet der Wächter das
  explizit statt schweigend mit Exit 0 zu enden; findet sich mindestens eine, bleibt die Ausgabe
  leer — den Inhalt der gestagten Änderung prüft dann das d-check-Modul selbst, nicht dieser
  Wächter.
- **`doc-commits` selbst ist heute unbedienbar**, unabhängig von der Range: der `commits:`-Block
  in [`.d-check.yml`](../../.d-check.yml) trägt eine nicht-leere `id-patterns`-Liste, und jeder
  `--range`-Lauf des `commits`-Moduls bricht darunter ab (Exit 2) — Einzelheiten im Sensor
  [`commit-msg-check`](commit-msg-check.md). Der Wächter selbst bleibt für `doc-immutable`
  unverändert wirksam; betroffen ist nur das zweite der beiden Ziele, die er vorschaltet.
- `.d-check.yml` aktiviert für `docs-check` selbst nur `links, anchors, ids, matrix, codepaths,
  spans, planning, targets` — keines davon liest Historie. Ein history-lesender Job braucht
  `fetch-depth: 0` an seinem Checkout **und** diesen Wächter davor.

Details und Beleg stehen im Kopf von `harness/tools/history-range-guard.sh`, Abschnitt BELEG.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | Range aufgelöst und nicht leer, oder `--staged` (unabhängig davon, ob etwas gestagt ist) |
| 1 | Range auflösbar, aber leer (0 Commits) |
| 2 | Range **nicht** auflösbar (Basis fehlt im Klon) |

## Bindung

Kein Gate-Versprechen; Vorlauf für `make adr-immutable`.
