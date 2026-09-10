# Slice slice-209: Ein Report trennt Fundort von gemessener Fundmenge

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die von der DoD dieses Slice verschieden
wäre — ein Welle-Trigger wäre hier die Abschrift von DoD (1) und (2)
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(eine Trefferliste ist keine Vollständigkeitsaussage — dieselbe Fehlrichtung eine Ebene über dem
Gate),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(eine Zahl steht neben dem Kommando, das sie liefert — die Form, in der eine gemessene Fundmenge
überhaupt behauptbar ist),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
(ein Rollen-Anweisungssatz gehört der Rolle, die ihn ausführt — daraus folgt, **wer** die zwei
Zielorte dieses Slice schreibt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Berührte Spec-Stellen:** — (kein Zielelement der Spec-Straten wird geändert; der Slice ändert
Anweisungssätze, keine Spec).

**Verantwortlich:** —

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-10.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Wer einen Befund behebt, zieht die **gemessene Fundmenge** statt der im Report genannten
**Fundorte** — und der Report sagt selbst, welche der beiden er liefert.

**Der Anlass ist gemessen, nicht vermutet.** Ein Review nennt Fundorte; die Behebung behandelt sie
als Fundmenge; die nächste Runde findet dieselbe Aussage an einer Stelle, die das Wortmuster des
Fixes nicht traf. Der behebende Lauf hat seine Fundmenge dann über ein Wortmuster gezogen statt
über die Eigenschaft — so steht es wörtlich in einem der belegenden Reports
([`2026-09-10-adr-0033-konsistenz-review-runde-3.md`](../../../reviews/2026-09-10-adr-0033-konsistenz-review-runde-3.md),
Zeile 412: *„Ursache wie Runde 2: Der behebende Lauf hat seine Fundmenge über ein Wortmuster
gezogen"*, und in derselben Datei *„an fünf Stellen behoben, die Fundmenge war sechs"*).

Die Klasse liegt im Beobachtungs-Register bei **3×**:

```sh
ls docs/plan/planning/observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/evidence/*.md | wc -l
```

**Kein Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit dem Register; tragend ist, dass sie die Schwelle erreicht hat.

**Die Behebungs-Seite ist die belegte Hälfte.** Die Auflage *miss erst die Fundmenge, dann zieh
alle Stellen zugleich* ist in
[slice-073](../done/slice-073-emittierte-doc-gate-module.md) fünfmal gefahren worden und hat
**jedes Mal** eine größere Menge gefunden, als der auslösende Report nannte. Das ist ein Beleg für
die Wirksamkeit, kein Vorschlag — und der Grund, warum dieser Slice mit ihr beginnt statt mit der
Report-Form.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Eine Hard Rule in [`AGENTS.md`](../../../../AGENTS.md) §3.** Die Regel adressiert den Ablauf
  **einer** Rolle und gehört damit in deren Anweisungssatz, nicht in das repo-weite Briefing; eine
  Hard Rule schriebe ohnehin der Architect (§3.8), und dieser Slice würde damit über zwei
  Norm-Ebenen zugleich verfügen. *(Es wäre ein anderer Vorgang.)*
- **Ein Sensor auf die Report-Form.** Ob ein Befund einen Fundort oder eine Fundmenge meldet, ist
  ein **Urteil** und kein Muster; ein Gate darüber gäbe ein Muster als Kriterium aus, das keines ist
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6), und liefe auf einem gewachsenen Report-Bestand
  dauerhaft rot. Träger bleibt der Rollen-Wechsel. *(Bestand bleibt bewusst stehen.)*
- **Der Bestand der 500+ vorhandenen Reports unter `docs/reviews/`.** Sie sind Zeitdokumente und
  nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 bzw. §3.7 *Cutoff* kein Arbeitsauftrag; gebunden
  ist der Report, der geschrieben wird. *(Bestand bleibt bewusst stehen.)*
- **Die Nachbarklasse
  [`reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts`](../observations/BEO-ALL/reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts/observation.md).**
  Dort schreibt die prüfende Rolle einen **ungemessenen Weg** vor; hier unterschätzt die behebende
  Rolle die **Ausdehnung** der Klasse. Gleiches Symptom (eine Runde mehr), andere Ursache und andere
  Seite — sie zusammenzuziehen hieße, zwei Zähler zu einem zu machen. *(Es wäre ein anderer
  Vorgang.)*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Die Behebungs-Seite trägt die Messpflicht.** Der Anweisungssatz der ausführenden Rolle
  ([`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md), nach
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Eigentum des
  Implementers) verlangt: Wer einen Befund behebt, der eine **Aussage** betrifft, misst deren
  Fundmenge selbst und legt **Kommando und Zahl** ins Übergabe-Artefakt, bevor er zieht. Der Satz
  nennt die Fehlerrichtung, gegen die er steht — Wortmuster statt Eigenschaft —, und bleibt auf
  Aussagen beschränkt: ein Tippfehler hat keine Fundmenge.
- [ ] **(2) Der Report weist die zwei Formen getrennt aus.** Der Reviewer-Anweisungssatz
  (`.harness/skills/reviewer.md`, nach
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Eigentum des
  Reviewers) verlangt je Befund die Angabe, ob er einen **Fundort** oder eine **gemessene
  Fundmenge** meldet — bei einer Fundmenge mit dem Kommando, das sie liefert. **Geschrieben wird
  der Satz im Reviewer-Lauf, nicht im Implementations-Lauf** (§3.8 sinngemäß,
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) wörtlich);
  dieser Plan ist das Übergabe-Artefakt dafür.
- [ ] **(3) `make gates` grün, Review durchgeführt, Report unter `docs/reviews/`**
  (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des Minimal Agent Workflow
  ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8). Closure-Notiz mit
  Steering-Loop-Lerneintrag; Beobachtungs-Register fortgeschrieben — der Eintrag
  `korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` bekommt mit diesem Slice den Ausgang
  **verkörpert** samt Zielort und Herkunfts-Anker `seit slice-209`, statt weiter `geplant` zu
  stehen; jedes Risiko aus §6 mit Ausgang.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) | update | die Messpflicht der behebenden Seite — die belegte Hälfte, DoD (1) |
| `.harness/skills/reviewer.md` | update | die Trennung Fundort/Fundmenge im Report — **Reviewer-Arbeit** ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), eigener Commit, nicht im Implementations-Kontext |
| [`observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/state.md`](../observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/state.md) | update | der Ausgang wandert von `geplant` auf `verkörpert` — das ist Closure-Arbeit dieses Slice |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): WIP-Limit frei, Implementer übernimmt. Keine Abhängigkeit von
einem anderen Slice — beide Zielorte existieren und werden nur ergänzt.

**Rückführungen — vorab benannt:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn sich zeigt, dass die zwei Zielorte
  nicht nur ergänzt, sondern in ihrer Gliederung umgebaut werden müssen — dann sind es zwei
  Vorgänge in zwei Rollen-Eigentümern, nicht einer.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Reviewer-Lauf für DoD (2) zu dem Verdikt
  kommt, dass die Trennung im Report **nicht** ohne einen Sensor trägt — dann ist erst zu klären,
  was ihn tragen könnte, bevor der Satz geschrieben wird.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD (1)–(3) abgehakt; `make gates` grün; die zwei Zielorte tragen den Satz, gemessen mit
`grep -c 'Fundmenge' .claude/commands/implement-slice.md .harness/skills/reviewer.md`; Closure-Notiz
mit Steering-Loop-Eintrag und der Registerzeile auf **verkörpert**.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Eine Regel ohne Sensor ist eine Absichtserklärung.** §1 schließt einen Sensor mit Begründung
  aus; damit trägt allein der Rollen-Wechsel, und die Klasse kann wiederkehren, ohne dass etwas rot
  wird. Das ist derselbe Feedforward-Quadrant, den [`AGENTS.md`](../../../../AGENTS.md) §3.8 und
  §3.10 für sich selbst feststellen — benannt, nicht geschlossen. — **Ausgang:** <eingetreten:
  CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → Beobachtungs-Register>
- **Zwei Zielorte, zwei Rollen-Eigentümer.** DoD (1) gehört dem Implementer, DoD (2) dem Reviewer
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)). Ein Lauf, der
  beide schreibt, ist genau der Fehler, den
  [`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  zählt. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: →
  Beobachtungs-Register>
- **Die Messpflicht kann zur Pflichterfüllung werden.** Ein Kommando neben jedem Befund erzeugt
  Kommandos, die niemand gefahren hat — die Klasse
  [`BEO-ALL/zahl-neben-nie-gefahrenem-kommando`](../observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md).
  DoD (1) begrenzt die Pflicht darum auf Befunde über eine **Aussage**, statt sie über alle zu
  ziehen. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: →
  Beobachtungs-Register>

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien**, vier und nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) aus der Modus-Deklaration
in [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).
Die zwei feineren Sub-Areas treffen nicht: `harness/tools/` wird nicht berührt, `.codex/` ebenso
wenig — die zwei Zielorte sind Rollen-Anweisungssätze und keine ausführbare Harness-Mechanik. Die
Schwelle ≥ 2 von 3 Achsen erreicht damit allein `*`.

**Vorgelagert — offene Beobachtungen sichten:** Das Register
([`observations/`](../observations/)) ist durchgegangen. Der **auslösende** Eintrag ist
[`BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`](../observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/observation.md)
(**3×**, Stand `geplant` mit der Kennung dieses Slice) — er ist der Grund des Schnitts, nicht ein
Nebenrisiko. Drei weitere liegen inhaltlich an, ohne den Slice zu tragen:
[`BEO-ALL/reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts`](../observations/BEO-ALL/reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts/observation.md)
(1×, offen — die in §1 abgegrenzte Nachbarklasse),
[`BEO-ALL/zahl-neben-nie-gefahrenem-kommando`](../observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md)
(4×, verkörpert — die Fehlrichtung, gegen die DoD (1) seine Pflicht begrenzt) und
[`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
(8×, verkörpert — das Risiko der zwei Rollen-Eigentümer in §6). Die Zähler-Stände sind am Tag des
Schnitts abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`) und keine
Erwartungswerte.

**Modus-Begründungsblock:** Alle berührten Sub-Areas GF — die Rollen-Anweisungssätze sind
Greenfield-Bestand, Doc führt und Code folgt; ein Begründungsblock pro Sub-Area entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Zwei Schritte vor der Modus-Begründung).
