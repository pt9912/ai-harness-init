# MR-047 — Der Ort der ausführbaren Harness-Tools ist keine Abweichung mehr

- **Datum:** 2026-09-03
- **Wirksamkeits-Anlass:** slice-157 — der Adaptions-Durchgang gegen den adoptierten Stand.
- **Geltungsbereich:** [`MR-005`](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
  — die **Abweichungs-Aussage**: dass `harness/tools/` an die Stelle eines Baseline-Defaults
  `tools/harness/` tritt. **Nicht** die Layout-Setzung selbst, **nicht** die Ausnahme für den
  kompilierten Span-Emitter und **nicht** der Reconciliation-Punkt gegenüber
  [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und
  [`ADR-0004`](../../docs/plan/adr/0004-durchsetzungs-emission.md) — alle drei binden fort, siehe
  die Kopf-Marke an [MR-005](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption).
- **Löst auf:** die Abweichungs-Aussage. Der Ort, von dem sie abwich, existiert am adoptierten
  Stand nicht mehr.
- **Ausgelöst durch Baseline-Stand:** `v5.18.0`.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  der nach [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 hier steht und sein Verdikt im Feld trägt. Das ist hier nicht Einordnung, sondern
  Gegenstand: Die Regel, an deren Stelle
  [MR-005](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) trat, gibt
  es am adoptierten Stand nicht mehr, also kann dieser Eintrag keine ersetzen.
- **Der Ausgang ist *Bezug entfallen*, nicht *gegenstandslos* — und die zwei sind verschieden.**
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2)
  §Freshness-Audit der vendored Baseline trennt sie: *gegenstandslos* heißt *„die neue Fassung
  regelt das **jetzt neu** selbst"*, *Bezug entfallen* heißt *„die Baseline regelt das Thema gar
  nicht mehr — dann ist der Eintrag keine Adaption mehr; ein Nachfolge-Eintrag löst ihn auf und
  hält fest, dass die Baseline dazu seit `<tag>` schweigt"*. Hier gilt der zweite: Die Baseline
  hat dem Repo nicht recht gegeben, sie hat die Frage fallen lassen. Der Unterschied entscheidet,
  **wer** die Setzung danach trägt — bei *gegenstandslos* die Baseline, hier dieses Register.
- **Gemessen, nicht vermutet — an drei Stellen, nicht am Thema.** Der Kurzschluss, den
  [`BEO-008`](../../docs/plan/planning/observations/BEO-ALL/adaptions-achse-1-kurzschluss/observation.md) führt, ist damit gerade nicht die
  Grundlage:
  1. Der Pfad kommt im Zielstand **nirgends** vor:
     `grep -rc 'tools/harness' .harness/baseline/v5.18.0/regelwerk/ .harness/baseline/v5.18.0/templates/`
     gibt **keine Nicht-Null-Zeile**.
  2. Der Abschnitt, der ihn trug, nennt **keinen Ort** mehr:
     [`grundlagen-durchsetzungsschicht.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-durchsetzungsschicht.md#das-vollständige-artefakt-set)
     §Das vollständige Artefakt-Set führt an jener Zeile *„eine gemeinsame, **inhaltsbasierte
     Nachweis-Quelle** für Gate-Lauf *und* Handoff-Gate (eine Wahrheit, keine Logik-Dopplung)"*.
  3. Kein anderer Abschnitt springt ein:
     [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#verzeichniskonvention)
     §Verzeichniskonvention führt für **ausführbare** Harness-Tools keinen Ort — dort stehen
     `harness/README.md`, `harness/conventions.md`, `harness/conventions/` und `.harness/`.

  Am abgelösten Stand stand der Pfad genau einmal, und zwar in der Zeile, die
  [MR-005](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) zitiert —
  Tree-Operand nach
  [`MR-040`](../conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  Ausgang 2, weil der Satz über die Vor-Tausch-Seite spricht:

  ```sh
  git show db83415^:.harness/baseline/v5.12.0/regelwerk/grundlagen-durchsetzungsschicht.md \
    | grep -c 'tools/harness'   # 1
  ```
- **Wo die Setzung künftig lebt: hier.** Der Freshness-Audit überlässt den Ort dem Repo
  (*„wo die Setzung selbst künftig lebt, entscheidet das Repo"*). Die Layout-Setzung — die
  ausführbaren Harness-Tools liegen unter `harness/tools/`
  (`ls harness/tools/*.sh harness/tools/*.awk | wc -l` → **22**, **kein Erwartungswert** nach
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — bleibt in Kraft und wird ab hier als **repo-lokale Strukturregel ohne
  Baseline-Gegenstück** geführt, nicht als Abweichung. Dass sie in diesem Register steht und nicht
  daneben, folgt derselben Leserfrage, die
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 für den Fork entschieden hat — *weicht dieses Repo hier ab?* wird an **einem** Ort
  beantwortet, auch wenn die Antwort *nein* lautet; und
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher nennt als Inhalt ausdrücklich *„die
  **repo-lokalen Strukturregeln** und Adaptionen"*, also beides.
- **Ausgang: Bezug entfallen → Teil-Ablösung.** Was fällt, ist allein die Aussage, dieses Repo
  weiche an dieser Stelle ab. Der Rumpf von
  [MR-005](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) bleibt
  vollständig stehen
  ([`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a):
  *„bei Teil-Aufhebung bleibt der Rumpf, weil sein Rest bindet"*), und der Eintrag bleibt in
  [`conventions/`](../conventions/) — die Verzeichnis-Position trennt *aktiv* von *aufgelöst* und
  trägt die Teil-Ablösung nicht
  ([`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
  Er bekommt die Kopf-Marke nach
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1.
- **Achse 2 — eigener Bedarf.**
  [MR-005](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)s offener
  Reconciliation-Punkt — die **emittierte** Struktur nennt weiterhin `tools/harness/` — ist nicht
  eingetreten und wandert nicht hierher. Er hängt an
  [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (Rang 1) und
  [`ADR-0004`](../../docs/plan/adr/0004-durchsetzungs-emission.md) (ab *Accepted* immutabel), nicht
  an der Baseline; dass die Baseline schweigt, entscheidet ihn nicht. Ebenso bleibt die Ausnahme
  für den kompilierten Span-Emitter (`cmd/span-emit/`, `internal/span/`) dort gebunden: sie folgt
  dem Go-Modulbaum, nicht einem Baseline-Default.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) hält einen Eintrag dieses Registers gegen den vendored Baum
  (`grep -m1 '^modules:' .d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans` —
  `links` prüft Auflösbarkeit, nicht ob die Zielzeile noch trägt), und `make comment-claims` hat
  keine Markdown-Datei im Prüfbereich. Ob ein Bezug entfallen ist, bleibt ein **Urteil, kein
  Muster** ([`AGENTS.md`](../../AGENTS.md) §3.6). Träger ist der Adaptions-Durchgang der
  Re-Baseline.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung. Neu zu entscheiden erst, wenn ein
  künftiger Baseline-Stand wieder einen Ort für ausführbare Harness-Tools nennt; dann ist die
  Differenz gegen den dann geltenden Tag zu messen und als neuer Eintrag zu führen.
