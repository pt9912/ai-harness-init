# MR-083 — MR-076 endet durch die zurückgenommene Wahl, nicht durch einen eingetretenen Trigger

- **Datum:** 2026-10-07
- **Wirksamkeits-Anlass:** Review `2026-10-07-mr-081-review` F-2 (LOW), Übergabe 4 aus §1 von
  slice-sprung-auf-v6170-wird-vollzogen.
- **Geltungsbereich:** der Satz *„Damit ist der zweite Auflösungs-Trigger von MR-076 in der Sache
  eingetreten — die Payload-Lage, die `Optional` begründete, erzwingt keine Abweichung mehr."* im
  Feld **Begründung** von
  [`MR-081`](../conventions.md#mr-081--der-cache-status-ist-pflicht-mit-kennzeichnung-nicht-bekannt-seine-abweichung-entfällt);
  die übrigen Felder von `MR-081` binden fort.
- **Ersetzt-Baseline-Regel:** keine — der Eintrag berichtigt die Begründung eines eigenen Eintrags
  und tritt an keine Baseline-Stelle; nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
- **Adaption.** Kein Auflösungs-Trigger von [`MR-076`](../conventions.md#mr-076) ist eingetreten.
  Der zweite lautet *„das Modul streicht den Cache-Status aus seinem Pflicht-Minimum"*; Kurs-Welle
  154 (`v6.14.0`) streicht nichts, sie hält den Cache-Status Pflicht und ergänzt die Kennzeichnung
  *nicht bekannt*
  (`grep -c 'ausdrücklich als nicht bekannt' .harness/baseline/v6.17.0/regelwerk/modul-15-observability.md`
  → **1**, kein Erwartungswert). `MR-076` endet durch die **zurückgenommene Wahl** — die
  Umstellung von `SPEC-024` auf `Pflicht` —, wie
  [`ADR-0078`](../../docs/plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4
  und der Folgesatz von `MR-081` es sagen. Das Feld *Ausgelöst durch Baseline-Stand* von `MR-081`
  bleibt richtig: `v6.14.0` hat die Rücknahme ausgelöst, nicht einen Trigger gefeuert.
- **Begründung.** Ein Retirement-Check oder ein künftiger Sprung-Durchgang, der *„Trigger
  eingetreten"* liest, hielte die Trigger-Formulierung von `MR-076` für erfüllt; zwei Norm-Quellen
  nennten verschiedene Gründe für dasselbe Ende. Die Kopf-Marke an `MR-081`
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger))
  hält den Leser dort an; `MR-081` bleibt aktiv
  ([`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
- **Auflösungs-Trigger:** permanent, solange `MR-081` aktiv ist; mit dessen Auflösung entfällt der
  Gegenstand.
