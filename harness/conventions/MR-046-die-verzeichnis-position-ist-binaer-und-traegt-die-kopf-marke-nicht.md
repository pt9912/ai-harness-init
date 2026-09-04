# MR-046 — Die Verzeichnis-Position ist binär und trägt die Kopf-Marke nicht

- **Datum:** 2026-09-03
- **Wirksamkeits-Anlass:** slice-167 — die zweite Hälfte der Verzeichnis-Form; dieser Eintrag
  entsteht in derselben Änderung, die `conventions/done/` anlegt.
- **Geltungsbereich:** die **Form** eines Eintrags dieses Blocks, dessen Aussage ein späterer
  Eintrag teilweise ablöst, und die drei Auflösungs-Trigger, die
  [`MR-045`](../conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
  §Auflösungs-Trigger als eingetreten benennt. **Nicht** der Inhalt eines angenommenen Rumpfs —
  kein Satz darin wird geändert, gestrichen oder umformuliert. **Nicht** `docs/plan/adr/`, wo
  [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert gilt; **nicht** die emittierte Ebene.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher — *„Der Zustand ist die Verzeichnis-Position,
  kein Status-Feld."* Dieselbe Zelle trägt
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger);
  dieser Eintrag hält jene Ausnahme über den Umzug hinweg, statt sie zu ersetzen.
- **Löst auf:** die Prämisse von
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 2 (*„eine Position gibt es nicht"*) samt seiner drei Zensus-Kommandos über die
  Index-Datei, und die Deckungs-Messung von
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines).
  Nicht die Setzungen der beiden Einträge: sie binden fort.
- **Ausgelöst durch Baseline-Stand:** `v5.18.0`.
- **Adaption:** Die Verzeichnis-Position trennt *aktiv* (`conventions/`) von *aufgelöst*
  (`conventions/done/`) und kennt keinen dritten Wert. Der Zustand **teilweise abgelöst** hat
  darum weiterhin keinen Träger in der Position und behält seinen Träger im Text — die Kopf-Marke.
- **Begründung (gemessen, nicht postuliert).** Ein teilweise abgelöster Eintrag bleibt aktiv: sein
  Rumpf bindet fort, also liegt seine Datei in `conventions/`, und diese Position sagt *aktiv* —
  wahr, und über die abgelöste Aussage in ihm schweigend. Der Bestand zeigt es geschlossen: jeder
  Eintrag mit Kopf-Marke steht auf *aktiv*, keiner in `done/`.

  ```sh
  grep -l '^> \*\*ÜBERHOLT\|^> \*\*HISTORIE' harness/conventions/MR-*.md      | wc -l   # 13 aktiv
  grep -l '^> \*\*ÜBERHOLT\|^> \*\*HISTORIE' harness/conventions/done/MR-*.md | wc -l   #  0 aufgelöst
  ```

  Keine Erwartungswerte
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — beide Zahlen wandern mit dem Block; tragend ist, dass die zweite null ist. Fiele
  die Marke mit dem Umzug, verlören 13 Einträge ihren Zustands-Träger, ohne einen zu bekommen.
- **Verdikt 1 —
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  bindet fort.** Sein Trigger sagt: *„Dann trägt die Verzeichnis-Position den Zustand, und die
  Marke wird gegenstandslos."* Eingetreten ist der Vordersatz nur für die **vollständige**
  Aufhebung — und die war nie sein Fall, sondern der von
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  (§Zwei Instrumente, *„Ein Eintrag trägt genau eines von beiden"*). Für die Teil-Ablösung, die
  sein Instrument trägt, ist er **nicht** eingetreten. Was fällt, ist die Begründung in Setzung 2
  — dass es keine Position gibt — und die drei Kommandos, die die Marken über
  `harness/conventions.md` zählen; die Einträge liegen seit dem Umzug daneben, und die Kommandos
  geben null aus. Die Setzung selbst und Setzung 1, 3 und 4 binden unverändert fort. Der Eintrag
  bleibt in `conventions/` und bekommt die Kopf-Marke nach seiner eigenen Setzung 3.
- **Verdikt 2 —
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  bindet fort, alle drei Setzungen.** Sein Trigger sagt Setzung 2 den Verlust ihres Gegenstands
  voraus und stellt Setzung 1 und 3 zur Neuprüfung. Geprüft, einzeln:
  **Setzung 1** (ein neues Pflichtfeld wird in jedem Eintrag mit vollem Rumpf nachgetragen) hängt
  am Rumpf, nicht am Träger — ob er inline steht oder in einer Datei, ändert an der Frage nichts.
  **Setzung 2** (ein retirierter Eintrag bekommt keines) behält ihren Gegenstand: Die vier
  retirierten Einträge tragen in `done/` dieselbe geschlossene Aufzählung wie vorher — Nummer,
  Überschrift, `Datum`, eine `Aufgehoben durch`-Zeile —, und die Position sagt, *dass* sie
  aufgelöst sind, nicht, *welche Felder* sie führen. Die Frage überlebt den Umzug wörtlich.
  **Setzung 3** (ein Fork bleibt in diesem Block und trägt sein Verdikt im Feld) beantwortet die
  Leserfrage *weicht dieses Repo hier ab?* an einem Ort; auch das ist trägerunabhängig.
  Was fällt, ist die **Deckungs-Messung**: ihre drei Kommandos lesen `harness/conventions.md` und
  geben seit dem Umzug null aus. Über den Bestand gelesen gilt die Gleichung unverändert — die
  erste Zahl ist die Summe der beiden anderen:

  ```sh
  ls -1  harness/conventions/MR-*.md harness/conventions/done/MR-*.md         | wc -l  # gesamt
  grep -l '^- \*\*Ersetzt-Baseline-Regel:\*\*' harness/conventions/MR-*.md \
                                    harness/conventions/done/MR-*.md          | wc -l  # mit Feld
  grep -l '^- \*\*Aufgehoben durch' harness/conventions/done/MR-*.md          | wc -l  # ohne Feld
  ```
- **Verdikt 3 —
  [`MR-043`](../conventions.md#mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf)
  bindet fort, unverändert, und bekommt keine Marke.** Sein Trigger übernimmt seine Bedingung von
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  §Auflösungs-Trigger — *„und die Kopf-Marke gegenstandslos wird"*. Nach Verdikt 1 wird sie das
  nicht, also ist auch sein Trigger nicht eingetreten. Seine Setzung ordnet zwei Aussagen
  **innerhalb** eines Eintrags (das nachgetragene Feld schlägt die Einordnung im Rumpf) und
  berührt die Position an keiner Stelle; ihr Schlusssatz verweist auf ein Instrument, das steht.
  An diesem Eintrag ändert sich nichts.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) hält einen Auflösungs-Trigger gegen den Zustand, den er
  beschreibt (`grep -n '^modules:' .d-check.yml`), und `make mutate` kennt keine Fehlschlag-Form
  dafür. Ob ein Trigger eingetreten ist, bleibt ein **Urteil, kein Muster**
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Träger ist der Trigger-Audit der Closure.
- **Auflösungs-Trigger:** eine Ziel-Form, die den Zustand *teilweise abgelöst* selbst trägt — als
  dritte Position, als Feld oder in einer anderen Gestalt. Dann verliert die Kopf-Marke ihren
  Gegenstand und dieser Eintrag mit ihr.
