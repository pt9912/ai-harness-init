# `make doc-structure` — fährt die `structure`-Regeln der `.d-check.yml` allein

## Vertrag

Advisory-Ziel (nicht in `make gates`), fährt d-check mit `--enable structure` über den ganzen
Baum und schaltet alle übrigen Module ab. Geprüft wird, was der `structure`-Block in
[`.d-check.yml`](../../.d-check.yml) deklariert. `make docs-check` fährt dieselben Regeln in
`make gates` mit; was sie halten und wo sie enden, steht in [`docs-check.md`](docs-check.md)
§Modul `structure`. Ohne `structure`-Block ist das Modul laut `d-check --print-config` **inert**
(„Leere Liste ⇒ Modul inert").

## Grenze — was das Grün nicht abdeckt

*Ohne Block — inert.* Die Gegenprobe läuft an einer bewusst kaputten Section-Überschrift
(`## 7. Closure-Notiz` → `## 7. Sonstiges` in einer `done/`-Slice-Datei), gegen eine Kopie
außerhalb des Repos, netzlos, Mount `:ro` (kein `.git` nötig — das Modul ist hermetisch). Die Kopie
verliert zuerst den `structure`-Block der `.d-check.yml`, dann bekommt sie einen groben Sonden-Block:

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
FLAGS=$(grep -A1 '^doc-structure:' d-check.mk | tail -1 | sed -E 's/.*\$\(DCHECK_REF\) //')
git archive HEAD | tar -x -C <kopie>
sed -i '/^structure:$/,/^# targets (hermetisch/{/^# targets/!d}' <kopie>/.d-check.yml
sed -i 's/^## 7\. Closure-Notiz$/## 7. Sonstiges/' \
  <kopie>/docs/plan/planning/done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" \
  $FLAGS --config /repo/.d-check.yml
# ohne structure:-Block:  1601 Datei(en) geprüft, 0 Befund(e)
printf '\nstructure:\n  - files: "docs/plan/planning/done/slice-*.md"\n    section: "## 7. Closure-Notiz"\n    non-empty: true\n' \
  >> <kopie>/.d-check.yml
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" \
  $FLAGS --config /repo/.d-check.yml
# mit dem Sonden-Block:  1601 Datei(en) geprüft, 100 Befund(e), darunter
#   docs/plan/planning/done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md:1 …
#     … ## 7. Closure-Notiz    section-missing    kein Abschnitt passt auf den Selektor
```

Gemessen gegen d-check `v0.76.1` (der Digest in [`d-check.mk`](../../d-check.mk)). Beide Zahlen
sind **kein Erwartungswert** — sie wandern mit dem Bestand. Ohne Block bleibt der eingesetzte
Defekt unsichtbar, genau die Inertheit, die `d-check --print-config` selbst ankündigt. Die **100**
Befunde (nicht nur der eine eingesetzte) kommen aus dem groben Sonden-Block: `section: "## 7.
Closure-Notiz"` verlangt diese Überschrift *wörtlich* in jeder von `docs/plan/planning/done/
slice-*.md` erfassten Datei und trifft damit auch Pläne, deren §7-Überschrift einen Zusatz trägt.
Über die Regeln des echten Blocks sagt die Sonde nichts.

*Mit Block.* Über dem Arbeitsbaum meldet `make doc-structure` `0 Befund(e)`, dieselbe Zahl, die
`make docs-check` für das Modul liefert. Welche Lagen die Regel rot färbt und welche sie
durchlässt, misst [`docs-check.md`](docs-check.md) §Modul `structure`.

**Das Ziel trägt keine Block-Marke.** Die Marke aus
[`MR-062`](../conventions.md#mr-062) steht an jedem `docs?-*`-Ziel, dessen `--enable`-Modul in der
`.d-check.yml` keinen eigenen Block hat, und `structure` hat einen. Die Menge leitet
[`test/doc-block-marke-wiring.bats`](../../test/doc-block-marke-wiring.bats) aus beiden Dateien ab;
über dem Arbeitsbaum ist sie `doc-tracked`. Der Markentext zeigt weiter auf diese Datei, denn die
zwei folgenden Absätze erklären, was die Marke sagt.

**Die Marke behauptet kein Prüfergebnis.** Sie steht im `##`-Hilfetext (`make doc-help`) und als
letzte Rezept-Zeile ihres Ziels. Sie nennt nur die ableitbare Tatsache, dass `.d-check.yml` für
dieses Modul keinen eigenen Block führt, und zeigt hierher. Ob das im Einzelfall Inertheit
bedeutet, sagt die Sensor-Datei des Ziels, nicht die Marke. Eine Marke, die *„nichts geprüft"*
behauptete, wäre für `doc-tracked` schlicht falsch.

**Die Ausgabe-Hälfte gilt nur für einen Lauf ohne Befund.** Das Rezept reicht `docker run` vor dem
`@echo` durch, ohne `-` davorzustellen. Meldet der Lauf einen Befund, endet er mit einem Exit-Code
ungleich null, und `make` bricht das Rezept an dieser Stelle ab — die Marke wird dann **nicht**
ausgegeben. Für [`doc-tracked`](doc-tracked.md), das laut dortiger Gegenprobe *nicht* inert ist,
ist das ein erreichbarer Zustand: ein echter `target-untracked`-Fund unterdrückt die Marke in genau
dem Lauf, der sie am nötigsten hätte. [`test/doc-block-marke-wiring.bats`](../../test/doc-block-marke-wiring.bats)
prüft die **Textform** des Rezepts — die letzte Rezept-Zeile ist ein `@echo`, das die Marke
ausgibt, kein No-op und kein Kommentar auf einer anderen Zeile — und damit, ob sie *erscheinen
würde*, nicht, ob sie in jedem realen Lauf tatsächlich erscheint; Letzteres bräuchte einen
laufenden Docker-Aufruf und ist kein hermetischer, netzloser Test.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | kein Befund im Prüfbereich des Moduls |
| 1 | mindestens ein Befund; je Befund eine Zeile *Datei:Zeile · Ziel · Befund-Art · Grund* |
| 2 | Nutzungs- oder Umgebungsfehler, gemeldet als `d-check: error: …`; kein Befund ist erhoben |

Die Vollständigkeits-Zeile `N Datei(en) geprüft, M Befund(e)` erscheint bei 0 und 1 und spricht
über den Prüfbereich (§Grenze), nicht über das Repo. `make` meldet den Exit als `Fehler <n>` und
endet selbst mit 2. Trägt eine Regel einen `hint`, steht er in der vierten Spalte statt des
Modul-Textes.

## Sperren

- `d-check: error: …` — die `.d-check.yml` ist ungültig; jeder Konfigurationsfehler bricht vor dem
  Scan ab, ohne Vollständigkeits-Zeile, mit Exit 2 → die Konfiguration berichtigen.

## Bindung

Kuratiert in `exempt-targets` (`.d-check.yml` `targets:`-Block) — kein Gate-Versprechen. Die
Regeln, die das Ziel fährt, laufen über `make docs-check` in `make gates`. Eine weitere Regel ist
Gegenstand von
[slice-213](../../docs/plan/planning/open/slice-213-review-report-laeuft-in-der-tabellen-form.md).
Siehe auch [`make doc-tracked`](doc-tracked.md) für die geteilte Vier-Klassen-Methodik.
