# MR-042 — Der Anlass einer Lastenheft-Änderung steht nicht in der Historie, sondern in der Closure-Notiz

- **Datum:** 2026-09-02
- **Wirksamkeits-Anlass:** slice-150 — Korrektur eines Achse-1-Ausgangs aus slice-082 §9.
- **Geltungsbereich:** [`MR-015`](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzung 3, beide Hälften — **und** die Aussage von
  [`MR-036`](../conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
  §Achse 2, die Setzung 3 als eigenen, nicht eingetretenen Bedarf führt. **Nicht** der Cutoff-Absatz
  von [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) (er bindet fort, siehe dessen Kopf-Marke) und **nicht** dessen Setzungen 1 und 2 (die
  hat [MR-036](../conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline) bereits erledigt).
- **Löst auf:** [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 3 und [MR-036](../conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline) §Achse 2. **Eine zweite Kopf-Marke an [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) entsteht
  dabei nicht:** dessen Marke sagt bereits *„ÜBERHOLT: dieser Eintrag, mit einer Ausnahme"* und
  nimmt allein den Cutoff-Absatz aus — Setzung 3 liegt in ihrer Reichweite. Die Marke bekommt
  [MR-036](../conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline).
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Ersetzt-Baseline-Regel:**
  [`modul-03-spec.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-03-spec.md)
  §Ziel-Form: Akzeptanzkriterium — der Absatz über die Historie des Lastenhefts.
- **Zwei Hälften, zwei Ausgänge — und die zweite ist nicht die, die der Delta-Durchgang erwartete.**
  Setzung 3 sagt zweierlei: *(a)* die **Verweis-Spalte** nennt die annehmende Instanz statt eines
  Tickets, *(b)* der **Anlass** — ein ADR, ein Slice-Befund — bleibt in der **Änderungs-Spalte**.
  - *(a)* ist **gegenstandslos**: `grundlagen-source-precedence.md` §Spec-Stratifizierung sagt
    wörtlich *„die Verweis-Spalte nennt diesen Vorgang statt eines Tickets"*
    (`grep -c 'die Verweis-Spalte nennt diesen Vorgang statt eines' .harness/baseline/v5.12.0/regelwerk/grundlagen-source-precedence.md`
    → **1**), und *„dieser Vorgang"* ist genau der commit-getragene annehmende Akt, den Setzung 1/2
    beschreiben.
  - *(b)* **widerspricht**. `modul-03-spec.md` zieht die Straten-Decke ausdrücklich durch die
    Historie — *„Das gilt in jedem Abschnitt, auch in der Historie … wer den auslösenden Slice in
    der Historie nennt, tut dasselbe eine Zeile später"*
    (`grep -c 'auslösenden Slice in der Historie nennt' .harness/baseline/v5.12.0/regelwerk/modul-03-spec.md`
    → **1**) — und weist dem Anlass ein anderes Ende zu: *„Der Anlass geht damit nicht verloren, er
    liegt nur am richtigen Ende. Beim Lastenheft ist es der **externe CR** in der Verweis-Spalte;
    wer im Repo bemerkt hat, dass er nötig wird, hält es auf seiner Seite fest (Closure-Notiz des
    Slice)."* Die Änderungs-Spalte, in der Setzung 3 den Anlass halten will, ist kein Ausweg: der
    Absatz bindet die Zeile, nicht eine Spalte.
- **Ausgang: (a) gegenstandslos, (b) widerspricht → übernehmen.** Beide führen zum Rückbau
  derselben Setzung, aus verschiedenen Gründen — bei *(a)* hat die Baseline dem Repo recht gegeben,
  bei *(b)* gibt das Repo der Baseline recht. **Warum übernehmen und nicht den Widerspruch
  benennen:** Die Baseline führt ein Argument, das [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) nie gewogen hat — die **Unreparierbarkeit**
  der Historie-Zeile (*„Eine Historie-Zeile ist ein Protokoll und wird nicht rückwirkend geändert;
  ein dort genannter ADR-Verweis zeigt nach einer Supersedure dauerhaft auf eine Entscheidung, die
  nicht mehr gilt"*). Und sie nimmt nichts weg: [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) wollte den Anlass **erhalten**, die Baseline
  gibt ihm einen Ort, an dem er reparierbar ist. **Was ab hier gilt:** eine künftige Historie-Zeile
  des Lastenhefts nennt im Verweis den annehmenden Akt und trägt weder ADR noch Slice als Anlass;
  der Anlass steht in der Closure-Notiz des Slice, der ihn bemerkt hat.
- **Die bestehenden Zeilen werden NICHT umgeschrieben** — [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)s Cutoff-Absatz bindet fort und
  deckt genau diesen Fall; er ist der eine Teil jenes Eintrags, den [MR-036](../conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline) ausdrücklich stehen
  ließ. Ein Slice, der zur Adoption dieser Regel `spec/lastenheft.md` anfasst, widerlegte sie im
  Vollzug.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` liest, was in
  einer Historie-Zelle steht; `matrix` prüft die Referenz-Richtung und nimmt `Historie` per
  `exclude-sections` gerade **aus**
  ([`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)) — die Ausnahme, die
  `grundlagen-referenz-richtung.md` selbst als *„die schlechteste Stelle"* für rottende Verweise
  benennt. Träger ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung. Der frühere Trigger von Setzung 3
  — *„fällt, sobald ein externer Auftraggeber existiert"* — geht nicht mit über: Er hing daran, dass
  die Verweis-Form ein **Ersatz** für den fehlenden externen Beleg war; unter dem adoptierten Stand
  ist sie die Regel selbst, und ein externer CR fügt sich in dieselbe Spalte.
