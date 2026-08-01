# Spezifikation — ai-harness-init

**Status:** Aktiv. **Letzte Änderung:** 2026-08-01.

**Bezug zum Lastenheft:** Diese Spezifikation präzisiert die in
[`spec/lastenheft.md`](lastenheft.md) formulierten Anforderungen (`LH-*`-IDs). Bei
Konflikt gewinnt das Lastenheft.

## Aufnahme-Regel

Ein Satz gehört hierher, wenn **alle drei** zutreffen:

1. Er ist eine **technische Festlegung dieses Repos** — ein Wert, ein Feld, eine
   Schranke, eine Fassung. Etwas, gegen das gemessen werden kann.
2. Er ist **ohne Vertragsänderung fortschreibbar**: die Anforderung, die er
   präzisiert, bleibt beim Fortschreiben unberührt.
3. Er **wächst mit seinem Gegenstand** — die nächste Zeile seiner Tabelle verdrängt
   keinen anderen Text.

Nicht hierher gehören: die **Begründung** einer Entscheidung (sie steht in der
Entscheidung und zeigt von dort aufwärts hierher), die **Abweichung** von der
adoptierten Baseline (repo-lokales Konventionsdokument), die **Anforderung**
([`spec/lastenheft.md`](lastenheft.md)) und die **Komponentensicht**.

Zwei Formregeln, weil beide von außen gelesen werden:

- **Der bindende Text zeigt nicht abwärts.** Außerhalb der [Historie](#7-historie)
  steht hier keine Entscheidungs- und keine Planungs-Kennung: ein Wert steht für
  sich, das Warum findet man über die aufwärts zeigende Entscheidung. Gemessen wird
  davon in `.d-check.yml` die **verlinkte** Kennung (`matrix`-Klasse `spec-straten`)
  und die **nackte** Entscheidungs-Kennung (`ids`); für eine nackte Planungs-Kennung
  führt `ids.patterns` kein Muster — dort gilt die Regel ohne Wächter.
- **Abschnittsnummern werden nie neu vergeben.** Sie sind die der vendored Vorlage
  `.harness/baseline/v3.5.2/templates/spec/spezifikation.template.md`; ein
  Abschnitt ohne Inhalt lässt seine Nummer frei, und ein hinzukommender bekommt
  seine eigene. Neu zu nummerieren verschöbe die Anker, auf die von außen gezeigt
  wird — und ein Teil dieser Zeiger steht in Dokumenten, die nicht mehr geändert
  werden dürfen.

---

## 3. Defaults und Konstanten

Werte, die in Code, Konfiguration oder Gate-Schwelle fest sind — je mit der
Begründung ihrer Höhe, nicht nur mit ihrer Höhe.

| Name | Wert | Begründung |
|---|---|---|

## 5. Metriken und Tracing-Felder

Die verbindlichen Felder je Span, jedes mit seiner Pflichtigkeit und der
Incident-Frage, die es beantwortet; dazu je erklärter Abweichung vom Pflicht-Minimum
eine Begründung. Ein Feld ohne Incident-Frage wird nicht erfasst.

| Feld | Pflicht | Incident-Frage |
|---|---|---|

## 6. Externe Verträge

Schnittstellen zu Systemen, die uns nicht gehören, je mit der Fassung, gegen die
festgelegt ist.

| System | Version | Vertrag-Datei |
|---|---|---|

## 7. Historie

| Datum | Änderung | ADR |
|---|---|---|
| 2026-08-01 | Initial | — |
