# Reviewer-Skill — ai-harness-init

**Version:** 1.3.0 · **Datum:** 2026-07-24 ·
**Baseline:** Agents-Regelwerk v3.5.1 (Kurs-Welle 33), Modul 10 §Ziel-Form: Reviewer-Skill
(Output-Schema, Kategorien-Semantik, Report-Pflicht, Pflicht-Kontext-Eingang).

<!-- Versionierung (Modul 10): Änderungen werden versioniert, nicht überschrieben;
die alte Fassung liegt in der git-Historie. 1.1.0 (slice-014): „vorherige Findings
am gleichen Modul" als fünften v3.1.0-Pflicht-Kontext-Punkt ergänzt. Der Slice-Plan
(Repo-Ergänzung aus 1.0.0) BLEIBT erhalten — die Änderung ist rein additiv, nichts
entfernt. 1.2.0 (slice-019): Baseline-Re-Pin v3.1.0→v3.5.0 (Welle 26→32); Modul 10
§Ziel-Form substanziell unverändert (Überschriften identisch, nur ein Link-Label bekam
ein `templates/`-Präfix) — reines Label-/Metadaten-Update, keine Änderung an den fünf
Punkten / Output-Schema / Kategorien. 1.3.0 (slice-043): Baseline-Re-Pin v3.5.0→v3.5.1
(Welle 32→33); die fünf Pflicht-Punkte / Output-Schema / Kategorien sind repo-gepflegt und
unverändert übernommen — reines Baseline-Label-Update. -->

## Eingangs-Kontext (Pflicht — sonst nicht reproduzierbar)

Der Reviewer erhält die **fünf v3.5.1-Pflicht-Punkte** (Modul 10): den
**Diff/Commit-Range**, die betroffenen `LH-*`-Anforderungen (in
[`spec/lastenheft.md`](../../spec/lastenheft.md)), die **referenzierten aktiven ADRs**
(deren ID im PR/Commit vorkommt), die **Hard Rules** ([`AGENTS.md`](../../AGENTS.md) §3)
und **vorherige Findings am gleichen Modul** (damit wiederkehrende Muster erkennbar sind
und nicht jede Sitzung bei null beginnt) — **plus** den **Slice-Plan** (Repo-Ergänzung
über die Baseline-Fünf hinaus: der Review prüft den Diff *gegen* den Plan). Ohne diesen
Block sieht der Reviewer Code, aber nicht die Verträge, gegen die er prüft. **Nicht**
erhalten: die DoD-Abhakung — Plan-/DoD-Konformität prüft die Verifikation (getrennter
Kontext, anderes Prüf-Artefakt).

## Repo-spezifische Anker pro Kategorie

- **HIGH** (blockiert Merge): Stilles-Grün-Pfad in einem Gate oder
  Gate-Skript (Harness-Lüge); halluziniertes Gate
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6));
  Verstoß gegen eine **aktive** ADR oder gegen eine Hard Rule; Gate-Lockerung
  ohne ADR; Slice referenziert eine superseded ADR (nur aktive sind normativ).
- **MEDIUM** (vor Merge zu klären): Spec-Treue-Lücke einer Messmethode;
  Bezug-/Abdeckungslücke einer Akzeptanzanforderung; fehlende Negativtests
  bei neuem öffentlichen Vertrag; Reproduzierbarkeits-Risiko
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- **LOW** (nice-to-fix): Doku-Drift (Prosa-Listen, veraltete Beispiele);
  latente Wartungsfalle (hart verdrahteter Wert); Ketten-Duplikate in Make-Targets.
- **INFO**: dokumentationswürdige, aber undokumentierte Annahme; bewusste
  Won't-Fix-Designnotiz.

**Kontext-Eskalation:** dieselbe Beobachtung im Gate-/Sicherheitspfad steigt
eine Stufe; die dritte Wiederholung derselben Klasse in einer Sitzung ist ein
Steering-Loop-Signal (Guide/Sensor nachziehen statt nur melden). Streit über
eine Kategorisierung ⇒ Regel hier schärfen.

## Anti-Pattern — was du nicht bist

- **Kein Stil-Polizist:** Formatierung/Benennung ohne Konventions-Anker ist kein Finding.
- **Kein Verifier:** DoD-Abhaken und Gate-Lauf-Bestätigung sind nicht deine Rolle.
- **Kein Finding ohne Failure-Szenario:** was sich nicht als konkretes Versagen
  erzählen lässt, wird nicht gemeldet.
- **Kein Lösungsvorschlag im Befund:** Lösungen gehören in die Übergabe an die
  Implementation, nicht ins Finding-Feld.
- **REFUTED nur mit Beleg:** verworfen wird ausschließlich mit Code-/Spec-Zitat,
  nie wegen „spekulativ".

## Output-Schema (pro Finding)

`kategorie` (HIGH/MEDIUM/LOW/INFO) · `quelle` (`LH-*`-ID, ADR-ID, `MR-*`-ID,
Hard-Rule-Name oder „Maintainability") · `pfad` (`Datei:Zeile`) · `befund`
(1–2 Sätze, beobachtbar, ohne Lösungsvorschlag) · `verifizierbar` (ja/nein —
welcher Gate-Lauf würde den Befund bestätigen?).

## Negativbefunde (Pflicht)

Eine „geprüft, ohne Befund"-Zeile pro betrachtetem Bereich — sonst ist
„keine Findings" nicht von „nicht geprüft" unterscheidbar.

## Ablage

Ein Report pro Lauf unter `docs/reviews/<YYYY-MM-DD>-<gegenstand>.md`
(Struktur: Kopf-Metadaten · Findings · Negativbefunde · Kategorie-Summary ·
Verdikt). Nie überschreiben — Folgeläufe bekommen eine neue Datei. Verdikt:
HIGH und MEDIUM blockieren typischerweise; Abweichungen werden im Report begründet.
