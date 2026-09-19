# MR-070 — Die §Baseline trägt den Pin nicht als Kopie — der Zustand steht am Ort des Gegenstands

- **Datum:** 2026-09-19
- **Wirksamkeits-Anlass:** Nachzieh-Setzung des Auftraggebers zur §Baseline-Glättung
  (2026-09-19): *„Das ist Rauschen, es gehört nicht dorthin; ebenso unnötiger Text ist
  Rauschen."* Die `d-check:`-Zeile doppelt zwei Aussagen, die anderswo stehen — wo der lebende
  Pin steht, tragen die **Geltungsbereiche der Pin-Einträge** und `d-check.mk` selbst; dass kein
  Eintrag die zweite Fassung ist, trägt
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  in seiner eigenen Datei. Die Kopie in der §Baseline war der dritte Ort für denselben Zustand.
- **Geltungsbereich:** `harness/conventions.md` — die Zeile `d-check:` der §Baseline fällt.
  Dieser Eintrag benennt die eingefrorenen Fundstellen und trägt ihre toten Adressen (unten).
  **Nicht** `d-check.mk` und `internal/emit/emit.go` — der Pin steht dort selbst, am Ort des
  Gegenstands. **Nicht** die MR-Dateien der Pin-Linie — ihre Rümpfe sind eingefroren, und keine
  ihrer Aussagen wird abgelöst. **Nicht** die Setzungen von
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen) —
  sie binden fort; fällt ist das **Zitat**, das seine Setzung 1 als Träger führt. **Nicht** der
  Rest der §Baseline (die zwei Bullets, `Datum der Adoption`, der [`ADR-0043`](../../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md)-Zeiger, die
  Upstream-Grenze, die Regelwerks-Stand-Zeile in Zeiger-Form).
- **Ersetzt-Baseline-Regel:** keine — der Eintrag zieht eine Kopie aus der Index-Section dieses
  Blocks und tritt an keine Stelle des Regelwerks; nach dem Wortlaut der Eintrags-Vorlage damit
  kein Fork. Das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld.
- **Adaption:**
  - **Die Zeile fällt.** Vorher wörtlich:

    ```text
    - **d-check:** der lebende Pin steht in `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`) und, per
      go-Test daran gekoppelt, in `internal/emit/emit.go`; dass kein Eintrag dieses Blocks eine
      zweite Fassung führt, setzt
      [`MR-053`](#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen).
    ```

    Nachher: entfallen. Die `d-check:`-Zeile ist die letzte Stelle, an der die §Baseline den Pin
    als Kopie führte; der Zustand steht nach diesem Eintrag nur noch am Ort des Gegenstands.
  - **Der Zustandsort.** Der lebende Pin steht in `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`),
    der emittierte Default-Pin in `internal/emit/emit.go` — gelesen am Gegenstand, nicht an der
    Kopie. Die No-Second-Version-Regel steht in
    [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
    Setzung 1 selbst; ihr Zeiger aus der §Baseline fällt mit der Zeile, ihre Regel nicht.
  - **Die Vorab-Messung, beide Adress-Formen** ([`AGENTS.md`](../../AGENTS.md) §3.11 — die
    Entscheidung vor dem Move, gemessen über Code-Span und Markdown-Link):
    - **Code-Span-Form** *„§Baseline (Zeile `d-check:`)"* — vier eingefrorene Geltungsbereiche:
      `grep -rn 'Zeile .d-check:' harness/conventions/MR-0*.md` nennt
      [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)
      (`:8`),
      [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
      (`:10`),
      [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
      (`:8`) und
      [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)
      (`:6`, dazu `:252` — *„§Baseline führt die Kette fort; die Zeile `d-check:` …"*), sowie die
      derivativen Index-Zellen derselben vier Einträge (die folgen den Dateien,
      [`ADR-0024`](../../docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
    - **Section-Form ohne Zeile** — die übrige Pin-Linie nennt die Section, nicht die Zeile:
      [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile),
      [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert),
      [`MR-011`](../conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines),
      [`MR-012`](../conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar),
      [`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar),
      [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt),
      [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte).
      Die Section bleibt; diese Adressen bleiben gültig.
    - **Link-Form** — ein Verweis löst nach `#baseline`:
      [`ADR-0050`](../../docs/plan/adr/0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md)
      (`:50`); die Section bleibt, der Link bleibt gültig.
    - **Die Stale-Fortgeltung** —
      [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
      endet in seiner Kopf-Marke mit *„Wo der lebende Pin steht, sagt §Baseline."*; der Satz fällt
      mit der Zeile (Marke unten).
  - **Die toten Adressen tragen als eingefrorener Text weiter — und dieser Eintrag ist ihr
    Träger.** Keine Aussage der vier Pin-Einträge ist abgelöst: ihre Geltungsbereich-Aussagen
    (wo der Pin steht; welchen Sprung der Eintrag datiert) bleiben wahr — nur die von ihnen
    adressierte Zeile fällt. Die Kopf-Marke ist nach
    [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
    Setzung 4 fällig bei der Ablösung einer Aussage, und ein Pin-Eintrag löst keine Aussage ab,
    er datiert einen Sprung — derselbe Grund, den
    [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)
    §Begründung für die Pin-Kette trägt. Der Zustandsort der toten Adressen ist dieser Eintrag;
    wer auf *„§Baseline (Zeile `d-check:`)"* landet, findet hier, dass die Zeile entfallen ist und
    der Pin am Ort des Gegenstands steht.
  - **Zwei Kopf-Marken, gesetzt in derselben Änderung**
    ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
    Setzung 3): an
    [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen) —
    seine Setzung 1 **zitiert** die Zeile wörtlich als ihren Träger, das Zitat fällt mit ihr —
    und an
    [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand) —
    seine Fortgeltung endet in derselben Aussage. Beide Marken nennen Reichweite und Fortgeltung;
    die übrigen Setzungen beider Einträge binden fort.
- **Grenze.**
  - **Die toten Adressen sind eingefroren und bleiben stehen.** Keine der vier Geltungsbereiche
    wird umgeschrieben; wer ihnen folgt, findet den Zustand in diesem Eintrag — die
    Kennung-nicht-Adresse-Form des
    [`AGENTS.md`](../../AGENTS.md) §3.11 gilt am Freeze-Moment, und dieser Move kommt nach dem
    Freeze.
  - **Die Index-Zellen der vier Pin-Einträge** tragen dieselbe Formulierung — sie sind derivativ
    ([`ADR-0024`](../../docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md))
    und folgen den Dateien; sie werden hier nicht angefasst.
- **Begründung:**
  - Der Gewinn: die §Baseline trägt den Pin nicht an einem dritten Ort. Zwei Orte sind
    zuständig und bleiben es — `d-check.mk` und `internal/emit/emit.go` für den Stand,
    [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
    für die Regel. Eine Kopie driftete bei jedem Vendoring mit.
  - Der Preis ist die tote Adresse in vier eingefrorenen Geltungsbereichen; ihr Träger ist
    dieser Eintrag, und die zwei Marken an
    [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
    und
    [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
    halten die zwei Stellen auflösbar, deren Text die Zeile führt.
- **Auflösungs-Trigger:**
  - **Eine Ziel-Form, die den Zustand der toten Adressen selbst trägt** — als Feld, als dritte
    Position oder in anderer Gestalt (dasselbe Muster wie der Auflösungs-Trigger von
    [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
    Dann verliert dieser Eintrag seinen Gegenstand als Träger.
  - **Die Pin-Kette zieht in eine andere Section** — dann tragen die eingefrorenen
    Geltungsbereiche einen neuen Ort, und die toten Adressen sind neu zu messen.
  - **Ein d-check-Sprung, der die Zeile wieder braucht** — etwa, weil ein neuer Pin-Ort
    dazukommt und die Geltungsbereiche allein ihn nicht tragen. Dann entscheidet ein eigener
    Eintrag über die Rückkehr, nicht dieser.