# `make history-range-guard` — Vorlauf-Wächter für history-lesende d-check-Module

## Vertrag

`make history-range-guard RANGE=<base>..<head>` (oder `STAGED=1`) prüft **vor** einem
history-lesenden d-check-Modul-Lauf (`vcs`/`commits`), dass eine angeforderte Range
git-seitig auflösbar **und** nicht leer ist. Kein Gate, in keiner Prerequisite-Kette — die
Range variiert pro Aufruf und ist damit kein hermetischer Prüfbereich.

## Grenze — was das Grün nicht abdeckt

`make history-range-guard RANGE=<base>..<head>` (oder `STAGED=1`) ist der **Vorlauf-Wächter** vor einem history-lesenden d-check-Modul-Lauf (`vcs`/`commits`, Targets `doc-immutable`/`doc-commits` in `d-check.mk`) — **kein Gate, in keiner Prerequisite-Kette**: er prüft eine Vorbedingung *für einen Job*, nicht den Zustand des Repos ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). **`doc-commits` selbst ist heute unbedienbar**, unabhängig von der Range: der `commits:`-Block in [`.d-check.yml`](../../.d-check.yml) trägt eine nicht-leere `id-patterns`-Liste, und jeder `--range`-Lauf des `commits`-Moduls bricht darunter mit `Range-Basis-Vorfahren nicht lesbar: object not found` ab (Exit 2, gemessen mit `make doc-commits RANGE=HEAD~5..HEAD`; Einzelheiten im Sensor [`commit-msg-check`](commit-msg-check.md)). Der Wächter selbst bleibt für `doc-immutable` unverändert wirksam — betroffen ist nur das zweite der beiden Ziele, die er vorschaltet. **Der Anlass:** `actions/checkout` klont per Default mit Tiefe 1; eine dabei *auflösbare, aber leere* Range (z. B. `HEAD..HEAD`) meldet d-check ohne diesen Wächter `0 Befund(e)`, Exit 0 — blind und grün, statt zu fallen ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 3). Eine *unauflösbare* Basis (z. B. `HEAD~1` in einem Tiefe-1-Klon) deckt der Wächter **nicht zusätzlich** — d-check selbst bricht dafür schon mit Exit 2 ab, und ein Wächter, der nur das fängt, prüfte eine Eigenschaft, die das Werkzeug bereits hält. Geprüft wird darum die **Range** (`git rev-list --count`), nicht die Klon-Tiefe. **`STAGED=1` prüft keine Range**, sondern vergleicht den Index gegen `HEAD` (`git diff --cached`): fehlt jede gestagte Änderung, meldet der Wächter das explizit (`--staged ohne gestagte Aenderung — nichts zu pruefen.`) statt schweigend mit Exit 0 zu enden; findet sich mindestens eine, bleibt die Ausgabe leer und der Exit-Code in beiden Fällen 0 — den Inhalt der gestagten Änderung prüft dann das d-check-Modul selbst, nicht dieser Wächter. `.d-check.yml` aktiviert für `docs-check` selbst nur `links, anchors, ids, matrix, codepaths, spans, planning, targets`, keines davon liest Historie — ein history-lesender Job braucht `fetch-depth: 0` an seinem Checkout **und** diesen Wächter davor. Die Entscheidungslogik (`decide()`/`decide_staged()`) ist von ihren `git`-Aufrufen getrennt und über `--decide <range> <count>` bzw. `--decide-staged <0|1>` hermetisch mit Fixture-Werten testbar (`test/history-range-guard.bats`) — das gepinnte `BATS_IMAGE` führt kein `git` (wie bei `slice-mv`/`archive-welle`); der reale Beleg an einem echten flachen Klon bzw. am echten Index steht im Skriptkopf (`harness/tools/history-range-guard.sh`, Abschnitt BELEG).

Details, Beleg und die reine `decide()`-Testbarkeit stehen im Kopf von
`harness/tools/history-range-guard.sh`, Abschnitt BELEG.

## Bindung

Kein Gate-Versprechen; Vorlauf für `make adr-immutable`.
