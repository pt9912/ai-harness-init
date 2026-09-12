# `make doc-structure` — sagt, ob eine erwartete Section-Überschrift fehlt

## Vertrag

Advisory-Ziel (nicht in `make gates`), fährt d-check mit `--enable structure` über den ganzen
Baum. Prüft gegen eine konfigurierte Section-Erwartung; ohne eigenen `structure:`-Block in
[`.d-check.yml`](../../.d-check.yml) ist das Modul laut `d-check --print-config` **inert**
(„Leere Liste ⇒ Modul inert") — anders als bei `doc-tracked`, dessen Kernfrage keinen
Konfigurations-Block braucht.

## Grenze — was das Grün nicht abdeckt

*`doc-structure` — inert.* Dieselbe Methode an einer bewusst kaputten Section-Überschrift
(`## 7. Closure-Notiz` → `## 7. Sonstiges` in einer `done/`-Slice-Datei):

```sh
sed -i 's/^## 7\. Closure-Notiz$/## 7. Sonstiges/' docs/plan/planning/done/slice-201-*.md
docker run --rm --network none -v "$PWD":/repo:ro "$DCHECK_REF" --enable structure --disable …
# ohne structure:-Block:                 1144 Datei(en) geprüft, 0 Befund(e)
# mit einem structure:-Block, der
# "## 7. Closure-Notiz" verlangt:  …/slice-201-*.md:1 … section-missing …
#                                  1144 Datei(en) geprüft, 100 Befund(e)
```

Ohne Block bleibt der eingesetzte Defekt unsichtbar — genau die Inertheit, die
`d-check --print-config` selbst ankündigt (*„Leere Liste ⇒ Modul inert"*). Die **100** statt **1**
Befund(e) sind ein Artefakt des zu Sondierungszwecken groben Test-Blocks (er trifft auch reale
Abweichungen in der Section-Nummerierung anderer `done/`-Dateien) und keine Aussage über den
produktiv gewählten Block — den entwirft
[slice-213](../../docs/plan/planning/open/slice-213-review-report-laeuft-in-der-tabellen-form.md).

**Die Marke, die beide Ziele seit diesem Slice tragen** — im `##`-Hilfetext (`make doc-help`) und
als letzte Zeile ihrer eigenen Ausgabe — **behauptet keines dieser beiden Ergebnisse.** Sie nennt
nur die ableitbare Tatsache (`.d-check.yml` führt für dieses Modul keinen eigenen Block) und zeigt
hierher; ob das im Einzelfall Inertheit bedeutet, steht in diesem Absatz, nicht in der Marke — eine
Marke, die *„nichts geprüft"* behauptete, wäre für `doc-tracked` schlicht falsch.

## Bindung

Kuratiert in `exempt-targets` (`.d-check.yml` `targets:`-Block) — kein Gate-Versprechen. Ein
produktiver `structure:`-Block ist Gegenstand von
[slice-213](../../docs/plan/planning/open/slice-213-review-report-laeuft-in-der-tabellen-form.md),
nicht dieses Sensors. Siehe auch [`make doc-tracked`](doc-tracked.md) für die geteilte
Vier-Klassen-Methodik.
