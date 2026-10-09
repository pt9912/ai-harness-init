# Review: ADR-0062 — Nachprüfung nach blockierendem Befund

- **Datum:** 2026-10-09
- **Rolle:** Reviewer (frischer Kontext)
- **Gegenstand:** Commit `96787be1` (Nachbesserung von
  [ADR-0062](../plan/adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md),
  Status `Proposed`)
- **Anlass:** [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 — nach einem
  blockierenden Befund ist der Beleg die nächste Runde derselben Rolle
- **Vorgänger-Befunde:** `2026-10-09-adr-runde-0088-0062-0063-0089.md` §2 (M-1, L-1, L-2)
- **Geprüft gegen:** ADR-0015, ADR-0024, ADR-0028, ADR-0048, MR-015/MR-036, `AGENTS.md` §3.8

## Urteil

**Annahmereif.** M-1, L-1 und L-2 sind behoben; der Fix erzeugt keinen blockierenden Widerspruch.
Kategorie-Summary dieser Runde: 0 HIGH · 0 MEDIUM · 1 LOW · 2 INFO.

## Vorgänger-Befunde

- **M-1 behoben.** Festlegung 1 führt ADR-0015 nicht mehr als Instanz, lässt deren Datei-Bindung
  (`AGENTS.md` §3, Adaptions-Block; Messung nach `AGENTS.md` §3.8) ausdrücklich unverändert und nimmt
  die zwei Artefakte aus Festlegung 1 aus. Die Fortgeltung der vier hängt nicht mehr an einer
  Konsistenz-Bedingung („die Geltung der vier hängt nicht an dieser Festlegung"), und der
  Konfliktfall ist benannt: die jeweilige der vier gilt.
- **L-1 behoben.** Festlegung 2 trifft die Architect-Zuordnung selbst und stützt sie auf
  `modul-08-agentenrollen.md` §Rollen-Regeln („ADR-Änderung: Architect schreibt"); sie verneint die
  Ableitung aus ADR-0015 Festlegung 1 und MR-015 und verweist auf ADR-0028 Festlegung 2, die genau
  diese Ableitung ausschließt (ADR-0028 Z. 278–285 bestätigt das).
- **L-2 behoben.** Alle Baseline-Verweise stehen auf `v6.17.0`
  (`grep -c 'v6\.9\.0' docs/plan/adr/0062-*.md` → 0); die drei Kommandos in §Kontext geben je **1**
  (nachgefahren).

## Neue Befunde

### L-1 — Zwei Auflösungswege für denselben Konflikt

- `kategorie`: LOW · `quelle`: ADR-0062 Festlegung 1, Re-Evaluierungs-Trigger 3
- `pfad`: `docs/plan/adr/0062-…md` §Entscheidung 1 (Z. 181–184) und §Re-Evaluierungs-Trigger, dritter Punkt
- `befund`: Festlegung 1 (neu) löst einen Konflikt zwischen Festlegung 1 und „einer der vier" zugunsten
  der jeweiligen der vier auf. Trigger 3 sagt für den Fall, dass eine Nachfolgerin einer der vier
  Festlegung 1 widerspricht: „ein echter Konflikt und braucht eine eigene Entscheidung".
  Failure-Szenario: eine Folge-ADR löst ADR-0024 per `Supersedes` ab und widerspricht Festlegung 1;
  ein Lauf liest die Nachfolgerin als „die jeweilige der vier" und wendet sie ohne Entscheidung an,
  ein anderer hält den Fall nach Trigger 3 offen. Nicht blockierend: der Fall setzt eine künftige
  Folge-ADR voraus, die selbst eine Architect-Entscheidung ist.
- `verifizierbar`: nein (Urteil) · `klasse`: Konflikt-Regel und Trigger geben verschiedene Auflösung

### INFO-1 — „Instanz-Entscheidungen" umfasst an vier Stellen weiter ADR-0015

Festlegung 1 sagt, ADR-0015 sei „keine Instanz in diesem Sinn"; Festlegung 3 (Überschrift
„Residuen der Instanz-Regeln", mit ADR-0015 Festlegung 1 als erstem Residuum), Option A/C, die
Folgepflicht Reviewer und Trigger 3 nennen die vier weiterhin „Instanz-Entscheidungen". Die Menge
bleibt eindeutig bestimmbar (die vier im Bezug); Trigger 3 („die Instanz-Aufzählung in Festlegung 1
ist neu zu lesen") findet für ADR-0015 keine Aufzählung, sondern die Ausnahme.

### INFO-2 — §Kontext nennt MR-015 als Träger der Commit-Konstruktion

§Kontext (letzter Absatz „Was die Baseline regelt") und der Acceptance-Trigger nennen MR-015; MR-015
trägt die Kopf-Marke *ÜBERHOLT → MR-036*, bindend ist die Konstruktion über die Baseline
(`grundlagen-source-precedence.md` §Spec-Stratifizierung, `v6.17.0` Z. 205). Nicht durch den Fix
entstanden, und ADR-0015 Festlegung 2 führt dieselbe Herkunft — kein Widerspruch in der Sache.

## Geprüft, ohne Befund

- ADR-0015: Festlegung 1/2 und §Was hier NICHT entschieden ist stimmen mit der neuen Lesart (zwei
  benannte Artefakte, übrige ohne Aussage, Commit-Konstruktion) überein.
- ADR-0024 / ADR-0028 / ADR-0048: die Instanz-Beschreibungen in Festlegung 1 und die Residuen in
  Festlegung 3 decken sich mit deren Verengungen; ADR-0028 Festlegung 2 schließt die Ableitung aus
  ADR-0015 aus, wie Festlegung 2 jetzt sagt.
- MR-015/MR-036: keine Architect-Aussage, die Festlegung 2 noch beanspruchte; die Commit-Konstruktion
  steht in MR-036 und der Baseline `v6.17.0`.
- `AGENTS.md` §3.8: die Datei-Messung (Obergrenze) ist als Messung, nicht als Bindung zitiert; die
  Zeiger auf ADR-0024/ADR-0028 dort widersprechen der neuen Festlegung 1 nicht.
