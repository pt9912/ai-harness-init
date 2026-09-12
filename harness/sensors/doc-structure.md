# `make doc-structure` — sagt, ob eine erwartete Section-Überschrift fehlt

## Vertrag

Advisory-Ziel (nicht in `make gates`), fährt d-check mit `--enable structure` über den ganzen
Baum. Prüft gegen eine konfigurierte Section-Erwartung; ohne eigenen `structure:`-Block in
[`.d-check.yml`](../../.d-check.yml) ist das Modul laut `d-check --print-config` **inert**
(„Leere Liste ⇒ Modul inert") — anders als bei `doc-tracked`, dessen Kernfrage keinen
Konfigurations-Block braucht.

## Grenze — was das Grün nicht abdeckt

*`doc-structure` — inert.* Dieselbe Methode an einer bewusst kaputten Section-Überschrift
(`## 7. Closure-Notiz` → `## 7. Sonstiges` in einer `done/`-Slice-Datei), gegen eine Kopie
außerhalb des Repos, netzlos, Mount `:ro` (kein `.git` nötig — das Modul ist hermetisch):

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
git archive HEAD | tar -x -C <kopie>
sed -i 's/^## 7\. Closure-Notiz$/## 7. Sonstiges/' \
  <kopie>/docs/plan/planning/done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" \
  --enable structure --disable links --disable anchors --disable ids --disable matrix \
  --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams \
  --disable versions --disable pins --disable immutable --disable vcs --disable commits \
  --disable planning --disable tracked --disable targets --disable citations --disable sources \
  --disable workflows --disable reviews
# ohne structure:-Block:  1163 Datei(en) geprüft, 0 Befund(e)
cat >> <kopie>/.d-check.yml <<'YAML'

structure:
  - files: "docs/plan/planning/done/slice-*.md"
    section: "## 7. Closure-Notiz"
    non-empty: true
YAML
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" \
  --enable structure --disable links --disable anchors --disable ids --disable matrix \
  --disable external --disable codepaths --disable spans --disable hostpaths --disable diagrams \
  --disable versions --disable pins --disable immutable --disable vcs --disable commits \
  --disable planning --disable tracked --disable targets --disable citations --disable sources \
  --disable workflows --disable reviews --config /repo/.d-check.yml
# mit obigem structure:-Block:  1163 Datei(en) geprüft, 100 Befund(e), je Zeile z. B.
#   docs/plan/planning/done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md:1 …
#     … ## 7. Closure-Notiz    section-missing    kein Abschnitt passt auf den Selektor
```

Beide Datei-Zahlen sind **kein Erwartungswert** — sie wandern mit dem `done/`-Bestand. Ohne
Block bleibt der eingesetzte Defekt unsichtbar — genau die Inertheit, die `d-check --print-config`
selbst ankündigt (*„Leere Liste ⇒ Modul inert"*). Die **100** Befunde (nicht nur der eine
eingesetzte) sind ein Artefakt des zu Sondierungszwecken groben Test-Blocks: `section: "## 7.
Closure-Notiz"` verlangt diese Überschrift *wörtlich* in jeder von `docs/plan/planning/done/
slice-*.md` erfassten Datei und trifft damit auch reale Abweichungen in der Section-Nummerierung
anderer `done/`-Dateien — keine Aussage über den produktiv gewählten Block, den entwirft
[slice-213](../../docs/plan/planning/open/slice-213-review-report-laeuft-in-der-tabellen-form.md).

**Die Marke, die beide Ziele seit diesem Slice tragen** — im `##`-Hilfetext (`make doc-help`) und
als letzte Rezept-Zeile ihres Ziels — **behauptet keines dieser beiden Ergebnisse.** Sie nennt nur
die ableitbare Tatsache (`.d-check.yml` führt für dieses Modul keinen eigenen Block) und zeigt
hierher; ob das im Einzelfall Inertheit bedeutet, steht in diesem Absatz, nicht in der Marke — eine
Marke, die *„nichts geprüft"* behauptete, wäre für `doc-tracked` schlicht falsch.

**Die Ausgabe-Hälfte gilt nur für einen Lauf ohne Befund.** Beide Rezepte reichen `docker run`
vor dem `@echo` durch, ohne `-` davorzustellen; meldet der Lauf einen Befund, endet er mit einem
Exit-Code ungleich null, und `make` bricht das Rezept an dieser Stelle ab — die Marke wird dann
**nicht** ausgegeben. Für [`doc-tracked`](doc-tracked.md), das laut dortiger Gegenprobe *nicht*
inert ist, ist das ein erreichbarer Zustand: ein echter `target-untracked`-Fund unterdrückt die
Marke in genau dem Lauf, der sie am nötigsten hätte. Der Wächter aus DoD (3) prüft die
**Textform** des Rezepts (die Marke steht als letzte Rezept-Zeile) und damit, ob sie *erscheinen
würde* — nicht, ob sie in jedem realen Lauf tatsächlich erscheint; Letzteres bräuchte einen
laufenden Docker-Aufruf und ist kein hermetischer, netzloser Test.

## Bindung

Kuratiert in `exempt-targets` (`.d-check.yml` `targets:`-Block) — kein Gate-Versprechen. Ein
produktiver `structure:`-Block ist Gegenstand von
[slice-213](../../docs/plan/planning/open/slice-213-review-report-laeuft-in-der-tabellen-form.md),
nicht dieses Sensors. Siehe auch [`make doc-tracked`](doc-tracked.md) für die geteilte
Vier-Klassen-Methodik.
