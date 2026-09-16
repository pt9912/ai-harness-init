# MR-060 — Ein neues Pflichtfeld gilt für neue Einträge, bestehende werden nicht nachgetragen

- **Datum:** 2026-09-16
- **Wirksamkeits-Anlass:** slice-sprung-auf-v690-wird-vollzogen — Adaptions-Durchgang des Sprungs
  auf `v6.9.0`.
- **Geltungsbereich:**
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 1 (ein neues Pflichtfeld wird in jeden Eintrag mit vollem Rumpf nachgetragen) und
  Setzung 2 (ein retirierter Eintrag bekommt es nicht), dazu die zwei Sätze in
  [`harness/conventions.md`](../conventions.md) §Adaptions-Block, die diese Setzungen wiedergeben.
  **Nicht** Setzung 3 desselben Eintrags (ein Fork bleibt in diesem Block und trägt sein Verdikt im
  Feld): Sie bindet fort. **Nicht** die Felder, die Setzung 1 im Bestand nachgetragen hat: Sie
  bleiben stehen, denn auch ihr Rückbau schriebe bestehende Einträge um. **Nicht**
  [`MR-043`](../conventions.md#mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf):
  Seine Setzung ordnet ein nachgetragenes Feld gegen die Einordnung im Rumpf und hat ihren
  Gegenstand in genau diesen Feldern des Bestands. **Nicht**
  [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)
  Verdikt 2: Es prüft die Setzungen gegen den Umzug in die Verzeichnis-Form, nicht gegen einen
  Baseline-Stand, der sie regelt. **Nicht** `docs/plan/adr/`, wo [`AGENTS.md`](../../AGENTS.md)
  §3.4 gilt; **nicht** die emittierte Ebene.
- **Löst auf:**
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 1 und 2.
- **Ausgelöst durch Baseline-Stand:** `v6.9.0`.
- **Ersetzt-Baseline-Regel:**
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2)
  §Freshness-Audit der vendored Baseline (Schritt 2), Punkt *„Der Review vergleicht auch die
  Form"*: *„Für **wiederkehrende** Templates (ADR, Slice, Welle, Carveout, Review-Report, `MR`)
  gilt die Append-only-Logik: Neue Instanzen folgen der neuen Form, bestehende werden nicht
  rückwirkend umgeschrieben."* Genannt ist die Regel, die diesen Eintrag trägt; eine Abweichung
  setzt er nicht.
- **Die Klasse `MR` steht erst im adoptierten Stand in dieser Aufzählung.** Zwei Kommandos, jedes
  über einem Tag, beide Zahlen fest:

  ```sh
  grep -c 'MR-NNN-titel.template.md`) gehören ebenfalls dazu' \
    .harness/baseline/v6.9.0/regelwerk/modul-02-harness-bootstrap.md                    # 1
  git show 63e0964e^:.harness/baseline/v6.8.0/regelwerk/modul-02-harness-bootstrap.md \
    | grep -c 'MR-NNN-titel.template.md`) gehören ebenfalls dazu'                        # 0, Exit 1
  ```

  `63e0964e` ist der Commit, der den Baum auf `v6.9.0` tauscht; sein Vorgänger trägt `v6.8.0`.
- **Ausgang: widerspricht → übernommen.** Setzung 1 setzt das Gegenteil des zitierten Satzes: Sie
  zieht einen bestehenden Eintrag auf die Form eines neuen Baseline-Stands nach, und genau das
  schließt der adoptierte Stand für die Klasse `MR` aus. Derselbe Punkt verlangt die Nacharbeit
  bei einem neuen **Pflicht**-Feld für **Singletons** und nicht für wiederkehrende Klassen; `MR`
  steht auf der zweiten Seite. Setzung 2 ist die Ausnahme zu Setzung 1 und verliert mit ihr den
  Gegenstand: Kein bestehender Eintrag bekommt ein neues Feld, ob retiriert oder nicht, und das
  sagt jetzt die Baseline selbst.
- **Adaption:** keine. Führt ein adoptierter Baseline-Stand ein neues Pflichtfeld für
  Adaptions-Einträge ein, trägt es jeder Eintrag, der danach entsteht; ein bestehender bekommt es
  nicht nachgetragen, weder mit vollem Rumpf noch retiriert.
- **Begründung — eine Entscheidung, kein Befund.** Bei *gegenstandslos* gäbe die Baseline dem Repo
  recht; hier gibt das Repo der Baseline recht. Getragen ist die Wahl von der Vorgabe des
  Auftraggebers für diesen Sprung, *„Der Durchgang übernimmt die Ziel-Fassung vollständig; eine
  Abweichung wird nicht gesetzt."*
  ([`ADR-0056`](../../docs/plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Konsequenzen).
  Das Argument von Setzung 1 bleibt als Preis stehen: Ein neues Pflichtfeld trifft nur die
  Einträge nach dem Sprung, der es einführt, und die Konformität des Blocks mit seiner Ziel-Form
  gilt nur für sie. Dafür behält jeder Eintrag auch in seiner Form die Aussage seines Zeitpunkts,
  wie ADR, Slice und Review-Report.
- **Folge im Block.**
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  bleibt aktiv und bekommt die Kopf-Marke nach
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger);
  seine vorhandene Marke bleibt wörtlich stehen (dort Setzung 1). Die zwei Sätze des Index zeigen
  hierher.
- **Kein Wächter.** Kein Modul der [`.d-check.yml`](../../.d-check.yml) hält einen Eintrag gegen
  die Pflichtgliederung (`grep -n '^modules:' .d-check.yml`), und ob ein Feld nachträglich in
  einen Eintrag kam, zeigt allein `git log -p` über seiner Datei. Träger ist der Form-Durchgang des
  nächsten Sprungs und der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung. Neu zu entscheiden, wenn ein
  künftiger Baseline-Stand die Klasse `MR` aus der Append-only-Aufzählung nimmt; dann gegen den
  dann geltenden Tag zu messen und als neuer Eintrag zu führen.
