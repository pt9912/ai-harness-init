# MR-044 — Das Technik-Stratum trägt die ID-Spalte der Ziel-Form

- **Datum:** 2026-09-02
- **Wirksamkeits-Anlass:** slice-147 — Umsetzung des Form-Diff-Ausgangs aus slice-083 §1.
- **Geltungsbereich:** [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  Punkt 1 der Liste *Was als Delta bleibt* — die **Spaltenzahl**, nicht die Setzung; dazu die
  Abschnitte [3](../../spec/spezifikation.md#3-defaults-und-konstanten),
  [5](../../spec/spezifikation.md#5-metriken-und-tracing-felder) und §6 von
  [`spec/spezifikation.md`](../../spec/spezifikation.md).
- **Löst auf:** die Zahl *„vier Spalten (Feld · Pflicht · Incident-Frage · Sensor)"*. **Nicht** die
  Setzung darum: dass die `Sensor`-Spalte eine Abweichung von der Vorlagen-Form ist, bindet
  unverändert fort, und der Rumpf von [MR-021](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) wird dafür nicht angefasst
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1).
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Ersetzt-Baseline-Regel:**
  [`modul-15-observability.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-15-observability.md#span-audit-attribut-regeln)
  §Span-/Audit-Attribut-Regeln — dieselbe Drei-Spalten-Form, die schon [MR-021](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) nennt
  (*„liste jeden Attribut-Namen, markiere ihn als Pflicht oder Optional und nenne pro Attribut die
  Incident-Frage"*). Dieser Eintrag schreibt die dort registrierte Abweichung fort, er eröffnet
  keine zweite.
- **Adaption: §5 zählt fünf Spalten, und nur eine davon weicht ab.** Die Feldtabelle trägt
  `ID` · `Feld` · `Pflicht` · `Incident-Frage` · `Sensor`; die Werkzeug-Tabelle desselben
  Abschnitts, §3 und §6 tragen dieselbe `ID`-Spalte mit fortlaufendem `SPEC-<NNN>`. **Zwei
  Baseline-Regeln treffen in einer Tabelle aufeinander, und beide gelten:** die Drei-Spalten-Form
  aus dem Observability-Modul und die ID-Vergabe aus
  [`grundlagen-source-precedence.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-source-precedence.md#id-schema-als-klammer)
  §ID-Schema als Klammer, die die vendored Vorlage
  `.harness/baseline/v5.12.0/templates/spec/spezifikation.template.md` in jeder Tabelle von §2 bis
  §6 als `ID`-Spalte ausführt. Die `ID`-Spalte ist damit **keine** Abweichung, sondern die
  Übernahme der zweiten Regel; abweichend bleibt allein die `Sensor`-Spalte.
- **Begründung.** Der Block ist ein Index der Abweichungen, und eine Abweichung wird über ihren
  Umfang gelesen. Eine Zahl, die nach der Änderung des beschriebenen Gegenstands stehenbleibt,
  behauptet einen anderen Umfang als den, der besteht — der Leser prüft die Abweichung dann gegen
  eine Tabelle, die es nicht gibt. **Kein Gate hält das:** kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) zählt Spalten oder hält einen Satz gegen die Datei, die er
  beschreibt (`grep -n '^modules:' .d-check.yml`). Träger ist der Lauf, der die Tabelle anfasst.
- **Auflösungs-Trigger:** permanent, solange beide Baseline-Regeln auf dieselbe Tabelle zeigen.
  Nimmt eine künftige Fassung des Observability-Moduls die `ID`-Spalte in ihre eigene Form auf,
  ist nicht dieser Eintrag nachzubessern, sondern die Abweichung neu zu zählen.
