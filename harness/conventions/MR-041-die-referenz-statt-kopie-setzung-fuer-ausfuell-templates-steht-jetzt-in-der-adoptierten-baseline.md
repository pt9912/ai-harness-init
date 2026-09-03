# MR-041 — Die Referenz-statt-Kopie-Setzung für Ausfüll-Templates steht jetzt in der adoptierten Baseline

- **Datum:** 2026-09-02
- **Wirksamkeits-Anlass:** slice-150 — Korrektur eines Achse-1-Ausgangs aus slice-082 §9.
- **Geltungsbereich:** [`MR-008`](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) — die
  **Adaption** (keine eigenen Blank-Kopien; einzige Quelle ist der vendored Baum; ein neues Artefakt
  entsteht per `cp` daraus) samt dem Absatz *Abweichung von der Baseline (Modul 2)*. **Nicht** die
  Abgrenzung gegen [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  und deren Nachzug vom 2026-07-21 — sie binden fort, siehe die Kopf-Marke an [MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert).
- **Löst auf:** die Adaption selbst.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Ersetzt-Baseline-Regel:**
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#greenfield-bootstrap-schritt-sequenz-modul-2)
  §Anmerkung zum Instanziierungs-Zeitpunkt (Schritt 2).
- **Gemessen, nicht vermutet — Punkt für Punkt, nicht nach Thema.** [MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) setzt dreierlei, und der
  adoptierte Stand sagt jedes davon selbst: *keine dauerhaft gehaltene Blank-Kopie* →
  *„Die vendored Baseline ist deren **einzige Referenz-Form** — **keine Blank-Kopie im Repo
  vorhalten.**"* (`grep -c 'keine Blank-Kopie im Repo' .harness/baseline/v5.12.0/regelwerk/modul-02-harness-bootstrap.md`
  → **1**); *dieselbe Fünfer-Liste* → *„die **wiederkehrenden Artefakte** — `slice`, `welle`, weitere
  ADRs (`NNNN-*`), `carveout`, `review-report`"*; *Entstehung pro Instanz aus dem vendored Baum* →
  *„werden **nicht** beim Bootstrap vorab kopiert, sondern **pro Instanz** aus der vendored Baseline
  (`.harness/baseline/<tag>/templates/…`), wenn der Workflow sie erreicht"*. Der Kurzschluss, den
  [`BEO-008`](../../docs/plan/planning/observations.md) führt — *„die Baseline behandelt jetzt dasselbe
  Thema"* —, ist damit gerade **nicht** die Grundlage: geprüft ist die Deckung jeder einzelnen
  Setzung, nicht die Themengleichheit.
- **Ausgang: gegenstandslos → Rückbau, als Teil-Ablösung.** Was fällt, ist die Aussage, dieses Repo
  **weiche** hier ab; die Praxis bleibt unverändert und wird jetzt von der Baseline getragen. Der
  Rumpf bleibt trotzdem stehen
  ([`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a):
  *„bei Teil-Aufhebung bleibt der Rumpf, weil sein Rest bindet"*), denn zwei Aussagen darin binden
  auf einer Ebene, über die der Baseline-Satz nichts sagt — der **emittierten**: die Abgrenzung gegen
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) und ihr Nachzug vom
  2026-07-21 sind in [`ADR-0020`](../../docs/plan/adr/0020-emittierte-modul-15-regeln.md) als Grund
  zitiert, warum die fünf wiederkehrenden Vorlagen **nicht emittiert** werden, und die
  Historie-Zeile `0.8.0` des Lastenhefts nennt sie ebenfalls. [MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) bekommt die Kopf-Marke
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)), keine
  Entfernung, kein zweiter Commit.
- **Achse 2 — eigener Bedarf.** [MR-008](../conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)s Auflösungs-Trigger — *„gilt, solange das Repo seine
  Templates nicht adaptiert"* — ist nicht eingetreten und wird durch diesen Eintrag auch nicht
  erledigt: Er beschreibt den Fall, dass **eine** Vorlage eine echte Repo-Adaption braucht und
  deshalb wieder als Kopie geführt wird. Das wäre dann eine neue Abweichung mit eigenem Eintrag —
  und keine Blank-Kopie, über die der Baseline-Satz spricht. Der Trigger wandert damit nicht hierher,
  sondern verliert mit der Adaption seinen Gegenstand.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung. Neu zu entscheiden erst, wenn ein
  künftiger Baseline-Stand diese Anmerkung ändert; dann gegen den dann geltenden Tag zu messen und
  als neuer Eintrag zu führen.
