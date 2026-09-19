# MR-069 — Ein Job, der bewusst nicht auscheckt, trägt seine Prüfung inline

- **Datum:** 2026-09-19
- **Wirksamkeits-Anlass:** die zweite und dritte Review-Runde zum `publish`-Job der
  Release-Workflow (Befund N-3, dann die Weg-Frage). Der Inline-Prüfblock stand in keinem MR
  benannt — die zwei Runden haben ihn gemessen und gewogen, und die Abweichung von
  [`MR-014`](../conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1 galt sonst
  als still. Benannt, nicht verlinkt ([`MR-028`](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)).
- **Geltungsbereich:** `.github/workflows/release.yml` — der `publish`-Job und sein
  Inline-Prüfblock. **Teil-Ablösung** des Nachtrags 2026-07-25 zu Setzung 1 von
  [`MR-014`](../conventions.md#mr-014--ci-auf-frischem-klon-github-actions), dort des Verbotssatzes
  *„Ein Inline-Prüfblock in der YAML bleibt verboten — unabhängig davon, auf welchem Runner er
  liefe"*, **soweit der Job bewusst ohne Checkout läuft**. **Nicht** die Regelform der Setzung —
  eine Quelle je Check, ein versioniertes, von `shell-lint` gedecktes Artefakt, das der
  Workflow-Step ruft — sie bindet fort und gilt für jeden Job, der auscheckt. **Nicht**
  `ci.yml`/`upstream-drift.yml`: beide checken aus und rufen nur `make`-Targets und versionierte
  Skripte. **Nicht** die übrige Mechanik des `publish`-Jobs (`GH_REPO`, die Upload-Bedingungen):
  sie steht in der Datei, die sie führt.
- **Ersetzt-Baseline-Regel:** keine — der Eintrag schneidet eine Setzung eines eigenen MR-Eintrags
  und tritt an keine Stelle des Regelwerks; nach dem Wortlaut der Eintrags-Vorlage damit kein Fork.
  Das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld.
- **Adaption:**
  - **Der Befund, gemessen.** Der `publish`-Job checkt bewusst nicht aus — es gibt keinen
    `actions/checkout`-Schritt in ihm:

    ```sh
    sed -n '/^  publish:/,$p' .github/workflows/release.yml | grep -c 'actions/checkout'   # 0
    ```

    Die Prüfung liegt als Inline-Block unter dem Step
    `SHA256SUMS gegen die Artefakte halten`
    (`grep -n 'SHA256SUMS gegen die Artefakte halten' .github/workflows/release.yml` → `:132`) und
    trägt drei Haltungs-Zeilen (`sed -n '135,137p' .github/workflows/release.yml | grep -c .` →
    **3**): die **Form** je Manifest-Zeile, die **Menge** in beide Richtungen (ein Asset ohne Zeile
    und eine Zeile ohne Asset gingen sonst mit `dist/*` ans Release), und den **Inhalt** am
    Ruheort der `SHA256SUMS` (`cd dist && sha256sum -c` — die Manifest-Zeilen tragen die blossen
    Dateinamen). **Keine Erwartungswerte**
    ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
    Setzung 2) — die Zeilennummern wandern mit der Datei.
  - **Warum die Regelform hier nicht greift (gemessen, nicht angenommen).** Die Prüfung liegt als
    versioniertes Skript vor — `harness/tools/traeger-fetch.sh`, von `shell-lint` gedeckt —, aber
    einem Job ohne Checkout **liegt sie nicht vor**: er liest nur das Verzeichnis, das der
    Artifact-Download gelegt hat, und ein Aufruf des Skripts bräche an der fehlenden Datei, bevor
    irgendetwas geprüft wäre. Dasselbe Muster wie der Plattform-Start-Smoke im Nachtrag zu
    Setzung 1 von [`MR-014`](../conventions.md#mr-014--ci-auf-frischem-klon-github-actions) —
    dort fehlte `make` auf den Runnern, hier fehlt der Checkout im Job.
  - **Die Alternative.** Ein Checkout im Job holte den Baum nur, um die Skript-Datei zu lesen —
    der Job braucht sonst keinen Tree, nur `dist/`. Die Prüfung in einen checkout-führenden
    Vorgänger-Job zu verschieben trennte die fail-closed-Haltung vom Punkt vor dem Upload — genau
    die Haltung, die der Block trägt
    ([`ADR-0059`](../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
    Festlegung 1). Beide Wege kosten die Reihenfolge oder die Mechanik; keiner spart die
    Inline-Form ein.
  - **Die Ausnahme, in einem Satz.** Ein Job, der **bewusst nicht auscheckt**, trägt seine
    Prüfung als Inline-Block, solange die Prüfung nur das Verzeichnis liest, das der vorherige
    Step gelegt hat — der `verify`-Modus des versionierten Helfers steht als der Ort bereit, an
    den der Block wandert, sobald die Setzung einen Checkout verlangt.
  - **Teil-Ablösung, Form nach
    [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger).**
    Der ablösende Eintrag setzt die Kopf-Marke an
    [`MR-014`](../conventions.md#mr-014--ci-auf-frischem-klon-github-actions) in derselben Änderung
    (Setzung 3); die Marke nennt den Verbotssatz und seine Reichweite (no-checkout-Jobs) und die
    Fortgeltung (die Regelform). Die zwei Instrumente bleiben getrennt: **Teil-Ablösung** → Rumpf
    bleibt, Kopf-Marke; der Eintrag von
    [`MR-014`](../conventions.md#mr-014--ci-auf-frischem-klon-github-actions) bleibt in
    `conventions/` aktiv — die Verzeichnis-Position trägt die Teil-Ablösung nicht
    ([`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
- **Grenze.**
  - **Die Inline-Form ist nicht shell-lint-gedeckt.** Das Rezept liest `.sh`-Dateien
    (`grep -n -A2 '^shell-lint:' Makefile`), und ein YAML-`run:`-Block liegt in keinem
    gedeckten Pfad; `actionlint` (Setzung 3 von
    [`MR-014`](../conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) hält die Syntax des
    Blocks, nicht seinen Inhalt. Genau das ist der Preis der Ausnahme und der Grund, warum die
    Regelform die deckte Form bleibt — benannt, nicht bewacht
    ([`AGENTS.md`](../../AGENTS.md) §3.6).
  - **Die Ausnahme gilt nur für den bewussten Verzicht.** Ein Job, der auscheckt, fährt die
    Regelform; die Formel *„unabhängig davon, auf welchem Runner er liefe"* gilt im Übrigen
    unverändert — die Ausnahme hängt am **Verzicht auf den Checkout**, nicht am Runner.
- **Begründung:**
  - Der Gewinn der Inline-Form ist die Haltung am Punkt: die `SHA256SUMS` wird fail-closed gegen
    die Artefakte gehalten, **bevor** etwas hochgeladen wird — dieselbe Kette, die
    [`ADR-0059`](../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
    Festlegung 1 und ihre Folgepflicht 1 verlangen.
  - Der Preis ist die fehlende Lint-Deckung. Er wiegt weniger als die zwei Alternativen: der
    Checkout holt eine Datei, die der Job sonst nicht braucht, und die Verschiebung bricht die
    Kette, die die Prüfung trägt. Der Block trägt seinen Grund am Ort — der Kopf-Kommentar
    über ihm sagt dieselbe Abwägung in der YAML, weil die Datei der Ort ist, an dem der Job
    geändert wird.
- **Auflösungs-Trigger:**
  - **Ein Checkout wandert in den `publish`-Job** — etwa weil ein späterer Schritt die
    Mechanik braucht. Dann liegt das versionierte Skript im Job vor, die Regelform greift
    wieder, und der Inline-Block wandert in das versionierte Artefakt; die Ausnahme ist
    gegenstandslos, und die Kopf-Marke an
    [`MR-014`](../conventions.md#mr-014--ci-auf-frischem-klon-github-actions) mit ihr.
  - **Die Rohmechanik wächst über die eine Prüfung hinaus** — ein zweiter Check kommt in den
    Job. Der Block trägt heute genau eine Prüfung mit drei Haltungs-Zeilen; eine zweite ist die
    Stelle, an der die Inline-Form gegen die Regelform neu zu wägen ist.
  - **Die Prüfung wird ohne Checkout aus dem versionierten Artefakt aufrufbar** — etwa, wenn sie
    mit dem Artifact reist oder der Job das Skript auf anderem Weg erhält. Dann ist die
    versionierte Form der Regelfall, und der Inline-Block wandert.