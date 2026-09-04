# MR-038 — Ein retirierender Eintrag nennt den Baseline-Stand, der seinen Trigger feuerte

- **Datum:** 2026-08-31
- **Wirksamkeits-Anlass:** slice-082 — Adaptions-Durchgang von welle-10, Achse 1, Posten
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) (§6 des
  Slice-Plans).
- **Geltungsbereich:** [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  — nur die **Form** der `Aufgehoben durch`-Zeile bei baseline-getriebenem Rückbau. Die
  Festlegung selbst (Option C: Kopf bleibt, Rumpf geht bei vollständiger Aufhebung) bleibt
  unverändert und bindet fort.
- **Ersetzt-Baseline-Regel:**
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md)
  §Freshness-Audit der vendored Baseline: *„Rückbau ist ein neuer Eintrag, kein Edit — eine
  aufgelöste `MR-<NNN>` wird nicht überschrieben, sondern bekommt einen Nachfolger, der sie
  auflöst und den Baseline-Stand nennt, der den Trigger gefeuert hat. Die alte Zeile ist die
  historisch korrekte Aussage über den damaligen Zustand."*
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Der Auflösungs-Trigger von
  [ADR-0014](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) ist eingetreten,
  und die Entscheidung ist neu begründet, nicht umgestoßen.** Die ADR benennt den Fall selbst:
  *„Wenn die Baseline die Disziplin-Regel aus dem Vorlagen-Kommentar in ein Prosa-Modul hebt …
  dann bindet sie unabhängig von ihrer Rezeption hier, und die Abweichung ist gegen den neuen
  Wortlaut neu zu begründen."* Genau das ist geschehen: die Disziplin-Regel des
  v3.5.2-Vorlagen-Kommentars (*„keine nachträglichen inhaltlichen Änderungen … nur neue
  Einträge oder explizite Aufhebungen"*, existiert am Zielstand nicht mehr als Kommentar
  — `grep -n 'nur neue Eintr\|explizite Aufhebung\|append-only' .harness/baseline/v5.12.0/templates/harness/conventions.template.md`
  ist leer) lebt jetzt als Prosa in
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  (*„Einträge werden nie überschrieben"*) und in modul-02 (Zitat oben, siehe auch
  [`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)).
- **Geprüft: widerspricht Option C (Kopf bleibt, Rumpf geht) dem neuen Wortlaut?** Nein.
  *„Nicht überschrieben"* und *„kein Edit"* richten sich gegen das **Verändern** einer
  bestehenden Aussage; Option C verändert nichts — sie entfernt den Rumpf per **eigenem,
  additionsfreien Commit**
  ([ADR-0014](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (c))
  und lässt Nummer, Überschrift wörtlich und `Datum` stehen: genau das, was *„ein Nachfolger,
  der sie auflöst"* voraussetzt — einen stabilen Anker, auf den er zeigt. *„Die alte Zeile ist
  die historisch korrekte Aussage über den damaligen Zustand"* begründet, den Wortlaut nicht zu
  **verändern** — sie sagt nicht, ihn ewig sichtbar zu halten. [MR-020](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)s eigene Begründung trifft
  denselben Punkt bereits: *„Nicht in `git` steht, was der Kopf hält … Was die
  append-only-Führung dagegen leisten soll — Nachvollziehbarkeit — leistet `git` vollständig
  und besser."* Der Rückschluss auf *„widerspricht"* trägt darum nicht; die Adaption bleibt
  gültig, keine Folge-ADR, keine Rückführung `in-progress → open`.
- **Was neu ist, und was der Nachfolger ergänzt.** Die neue Fassung verlangt zusätzlich: der
  Nachfolger *„nennt den Baseline-Stand, der den Trigger gefeuert hat"* — ein Element, das
  [MR-020](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)s eigener Regel-Text bisher nicht ausdrücklich forderte (seine `Aufgehoben
  durch`-Beispiele im Bestand betreffen bislang ausschließlich repo-interne Umbauten, keinen
  Baseline-Sprung — deshalb blieb die Lücke bisher unbemerkt). **Setzung:** Wo eine Aufhebung
  baseline-getrieben ist — dieser Durchgang produziert genau solche —, trägt die `Aufgehoben
  durch`-Zeile zusätzlich den Tag (Feld `Ausgelöst durch Baseline-Stand`, wie bei
  [`MR-030`](../conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) bereits
  gelebt). Wo eine Aufhebung repo-intern getrieben ist (kein Baseline-Sprung als Ursache),
  bleibt das Feld aus — es gäbe nichts zu nennen.
- **Ausgang:** teilweise überholt → engere Nachfolgerin. [MR-020](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) bekommt eine Kopf-Marke
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)); der
  Rumpf bleibt vollständig stehen (Teil-Ablösung, kein Widerspruch zu [ADR-0014](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)).
- **Achse 2 — eigener Bedarf.** [MR-020](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)s eigener Auflösungs-Trigger — *„an [ADR-0014](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) gebunden —
  fällt ihre Annahme … fällt diese Adaption mit ihr"* — ist nicht eingetreten: [ADR-0014](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) bleibt
  Accepted; ihr dritter Re-Evaluierungs-Trigger hat eine Neubegründung verlangt, keine
  Aufhebung, und die steht hiermit.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung — eine neu begründete Adaption
  wird nicht ein zweites Mal neu begründet. Fällig erst, wenn ein künftiger Baseline-Stand die
  Freshness-Audit-Eigenschaft erneut ändert.
