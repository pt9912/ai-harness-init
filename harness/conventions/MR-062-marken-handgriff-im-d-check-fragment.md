# MR-062 — Ein Fragment-Ziel ohne eigenen Config-Block trägt eine Marke — der fünfte Handgriff

- **Datum:** 2026-09-17
- **Wirksamkeits-Anlass:** slice-217 (der Handgriff); deklariert mit
  slice-d-check-pin-bringt-die-stilllegungs-bedingung.
- **Geltungsbereich:** `d-check.mk`, und dort jedes `docs?-*`-Ziel, dessen `--enable`-Modul in
  der [`.d-check.yml`](../../.d-check.yml) keinen eigenen Top-Level-Block hat. An `0fbefa46` sind
  das `doc-tracked` und `doc-structure`
  (`git show 0fbefa46:d-check.mk | grep -cE '^doc-[a-z-]+:.*keinen eigenen Block'` → **2**; kein
  Erwartungswert, die Menge leitet der Wächter unten ab). **Nicht** die emittierte Ebene:
  `AdaptMK` setzt die Marke nicht (`git grep -n 'keinen eigenen Block' -- internal` → kein
  Treffer, Exit 1), und die *„vier Handgriffe"* im Auflösungs-Trigger von
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) meinen `AdaptMK` und gelten fort. **Nicht** die Frage, was ein solches Ziel
  prüft: Die beantworten [`harness/sensors/doc-tracked.md`](../sensors/doc-tracked.md) und
  [`harness/sensors/doc-structure.md`](../sensors/doc-structure.md).
- **Löst auf:** [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1, zwei Stellen: die Zahl *„vier kleine, dokumentierte
  Handgriffe"* und der Satz *„Die advisory-Targets bleiben sonst **verbatim**"*. Die
  Namens-Adaption selbst, Setzung 2 und der Auflösungs-Trigger jenes Eintrags gelten fort.
- **Ausgelöst durch Baseline-Stand:** keiner. Ausgelöst hat die Ablösung eine Änderung dieses
  Repos am Fragment, kein Baseline-Stand; die Vorlage kennt zu `Löst auf` nur den Baseline-Stand
  als Auslöser, und dieselbe Lage führt
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  für einen Werkzeug-Pin aus. Gemessen ist die Abweichung am adoptierten Stand `v6.9.0` (nächstes
  Feld).
- **Ersetzt-Baseline-Regel:**
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk` (Schritt 2) — *„Das Tool pflegt die Recipe-Form (`--network none`,
  Target-Set)"*
  (`grep -c 'Das Tool pflegt die Recipe-Form' .harness/baseline/v6.9.0/regelwerk/modul-02-harness-bootstrap.md`
  → **1**). Die Marke ändert an jedem Ziel der Menge den Hilfetext und hängt eine Rezept-Zeile an;
  beides ist Recipe-Form, die sonst das Werkzeug pflegt. Derselbe Abschnitt verlangt für eine
  Recipe-Form, die nicht mehr das Werkzeug pflegt, die Deklaration: *„die Abweichung gehört als
  `MR-<NNN>` deklariert"*. Dieser Eintrag ist sie für den Teil, der von Hand ist.
- **Adaption:** Bei jeder Neu-Erzeugung des Fragments sind es **fünf** Handgriffe: die vier aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 und die Marke. Die Marke steht an jedem Ziel der Menge zweimal: als
  Anhang des `##`-Hilfetexts und als letzte Rezept-Zeile, ein `@echo` mit dem Text
  `.d-check.yml fuehrt fuer dieses Modul keinen eigenen Block, …` und dem Verweis auf die zwei
  Sensor-Seiten. Sonst bleiben die advisory-Ziele wörtlich, wie das Werkzeug sie erzeugt.
- **Die Messung: vier der acht Hunks sind dieser Handgriff, unter beiden Digests.**

  ```sh
  diff <(docker run --rm --network none ghcr.io/pt9912/d-check@<digest> --print-mk) \
       <(git show <commit>:d-check.mk) > h.diff
  grep -c '^[0-9]' h.diff
  awk '/^[0-9]/{h=$0} /^> [^#].*fuehrt fuer dieses Modul keinen eigenen Block/{print h}' h.diff | sort -u
  ```

  Mit dem `v0.76.0`-Digest und `0fbefa46`: **8** Hunks, davon `59c118`, `60a120`, `67c127`,
  `68a129`. Mit dem `v0.74.1`-Digest und `0fbefa46^`: **8** Hunks, davon `59c110`,
  `60a112`, `67c119`, `68a121`. Die Werte sind fest, denn beide Seiten sind an Digest und
  Commit gebunden. Je Ziel entstehen ein `c`-Hunk (Hilfetext) und ein `a`-Hunk (Rezept-Zeile),
  weil die unveränderte `docker run`-Zeile beide trennt. Die übrigen vier Hunks sind die
  Handgriffe aus [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1. Das Muster schließt Kommentarzeilen aus: Der
  Adopter-Kopf zitiert den Markentext, und ohne `[^#]` erschiene sein Hunk als fünfter Treffer.
- **Ein Wächter hält den Handgriff:**
  [`test/doc-block-marke-wiring.bats`](../../test/doc-block-marke-wiring.bats), in `make test`.
  Er leitet die Menge aus `d-check.mk` und `.d-check.yml` ab und hält sie gegen die Ziele mit
  Hilfetext-Marke und gegen die Ziele, deren letzte Rezept-Zeile die Marke ausgibt. **Rot gesehen**
  in einer Kopie des Baums (`git archive 0fbefa46`), aus deren `d-check.mk` beide Formen der
  Marke entfernt sind: Fall 1 fällt an `diff <(echo "$c") <(echo "$hilfetext")` — erwartet
  `doc-structure` und `doc-tracked`, gefunden nichts. Unverändert ist dieselbe Kopie grün. Eine
  Neu-Erzeugung, die den fünften Handgriff vergisst, färbt damit `make test` rot.
- **Grenze:** Der Wächter prüft die Textform des Rezepts, nicht jeden realen Lauf. Meldet
  `docker run` einen Befund, bricht `make` vor dem `@echo` ab, und die Marke bleibt in diesem
  Lauf aus; [`harness/sensors/doc-structure.md`](../sensors/doc-structure.md) nennt das.
- **Begründung:** Ein Ziel, das `0 Befund(e)` meldet, ohne dass die `.d-check.yml` seinem Modul
  einen Prüfbereich gibt, liest sich wie ein geprüftes
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); die
  Marke nennt die ableitbare Tatsache am Ziel selbst. Sie ist eine Hand-Änderung an einer
  tool-gepflegten Form und braucht deshalb eine Deklaration. Ohne sie zählen die Einträge dieses
  Blocks vier Handgriffe und der Kopf von `d-check.mk` an `0fbefa46` fünf, und wer nach
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) neu erzeugt, verliert die Marke, bis der Wächter anschlägt. **Die Kopf-Marke
  an [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)** ist nach
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1 und 3 gesetzt, denn dieser Eintrag löst zwei Aussagen namentlich ab. Die Ausnahme aus
  Setzung 4 für die Pin-Kette greift nicht: [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) ist kein Pin-Eintrag, und dieser
  Eintrag datiert keinen Sprung. Die Datei jenes Eintrags bleibt nach
  [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)
  in [`conventions/`](../conventions/), weil seine übrigen Setzungen fortgelten.
- **Auflösungs-Trigger:** Der Handgriff entfällt in zwei Fällen:
  - Die Menge aus dem Geltungsbereich wird leer: Die `.d-check.yml` führt dann für jedes
    `--enable`-Modul des Fragments einen eigenen Block. Diesen Zustand meldet Fall 2 des Wächters
    (`ok 2 die C-Menge ist nicht leer …`).
  - `d-check --print-mk` erzeugt einen solchen Hinweis selbst.

  In beiden Fällen ist gegen den dann gepinnten Stand zu messen und das Ergebnis als neuer Eintrag
  zu führen.
