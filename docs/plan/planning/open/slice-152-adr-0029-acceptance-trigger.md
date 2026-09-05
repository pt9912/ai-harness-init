# Slice slice-152: ADR-0029 durchläuft ihren Acceptance-Trigger

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Baseline-Test ist das *Mehr*
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): eine beobachtbare
Closure-Bedingung, die mehr beobachtet als die DoD dieses Slice. Es gibt keine.

**Bezug:** [ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
(der Gegenstand), [ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
(deren Festlegung 2 den Re-Evaluierungs-Trigger stellt, den der Gegenstand einlöst),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
(Nachbarfrage; ihr Acceptance-Trigger liegt bei
[slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)
— derselbe Bauplan), Baseline-Regelwerk `grundlagen-bootstrap.md` §Vier
Trigger-Klassen (Acceptance-Trigger), [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md).

**Berührte Spec-Stellen:** `—`.
[ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) ist
*„Prozess-ADR ohne Spec-Stratum"*.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine). Der
Liefergegenstand ist ein ADR-Status-Übergang und damit **Architect**-Arbeit
([`AGENTS.md`](../../../../AGENTS.md) §3.8, Baseline-Regelwerk
`modul-08-agentenrollen.md` §Rollen-Regeln); die Konsistenz-Prüfung davor liegt
beim Reviewer.

**Autor:** Planner. **Datum:** 2026-09-02.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

[ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
steht auf `Proposed`, und vor diesem Slice nannte keine lebende Planning-Datei
sie — gemessen mit
`git grep -l 'adr/0029-' -- docs/plan/planning/open docs/plan/planning/next docs/plan/planning/in-progress 'docs/plan/planning/*.md'`,
das seit diesem Plan genau ihn ausgibt. Ein Acceptance-Trigger ohne Träger ist eine Absichtserklärung
mit Verfallsdatum (Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 2). Dieser Slice holt den Schritt nach:
Reviewer-Konsistenzprüfung, dann `Accepted` durch den Architect.

**Die Klasse ist größer als der Einzelfall und wird mitgezählt.** Drei ADRs
stehen auf `Proposed` (`grep -l '^\*\*Status:\*\* Proposed' docs/plan/adr/0*.md | wc -l`
→ **3**), und **zwei** davon —
[ADR-0025](../../adr/0025-register-mit-gemischten-originalen.md) und
[ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) —
haben keinen Träger für ihren Acceptance-Trigger; nur
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) hat
einen ([slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)).
Keine Erwartungswerte, [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) [ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
      durchläuft den Acceptance-Trigger und trägt ihn.** Ein Reviewer-Durchgang
      prüft auf Konsistenz (Baseline-Regelwerk `modul-08-agentenrollen.md`
      §Rollen-Regeln); danach setzt der Architect `**Status:** Accepted` und
      ergänzt die Geschichte-Tabelle um die Zeile, die den Trigger benennt. Der
      ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt
      denselben Status (`grep -c '0029.*Proposed' docs/plan/adr/README.md` →
      **0** danach).
- [ ] **(2) [ADR-0025](../../adr/0025-register-mit-gemischten-originalen.md)
      bekommt einen benannten Träger für ihren Acceptance-Trigger** — entweder
      denselben Reviewer-/Architect-Zug in diesem Slice, wenn die
      Konsistenzprüfung sie mitträgt (beide entscheiden dieselbe Bewegung:
      Ableitung je Aussage statt je Datei), oder einen Folge-Slice mit ID. Ein
      dritter Ausgang — sie bleibt trägerlos — ist keiner.
- [ ] `make gates` grün.
- [ ] Doku-Update: Prüfung, ob [`AGENTS.md`](../../../../AGENTS.md) §3.8 einen
      Zeiger schuldet (dort steht heute der Fall
      [ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md));
      kein sicherer Treffer.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — **neue
      Kennung für die Klasse** *ein `Proposed`-ADR hat keinen Träger für ihren
      Acceptance-Trigger* (Sub-Area `*`, 1×, Beleg `slice-152`); dazu
      [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md) Stand-Spalte um den `.claude/agents/`-Ausgang
      ergänzt. Die Kennung entsteht bei **dieser** Slice-Closure, nicht früher:
      Modul 6 §Das Beobachtungs-Register weist das Schreiben der Slice-Closure
      zu, und ein Beleg ist formgebunden auf eine Slice-Datei in `done/`.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste
      Welle-Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) | update (Status + Geschichte-Zeile), Architect | DoD (1); nach `Accepted` immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| [`docs/plan/adr/0025-register-mit-gemischten-originalen.md`](../../adr/0025-register-mit-gemischten-originalen.md) | update (Status) **oder** unberührt | DoD (2) — welcher der zwei Ausgänge, entscheidet die Konsistenzprüfung |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update (Status-Spalte), Architect | DoD (1)/(2) — derivatives Register desselben Originals |
| [`docs/plan/planning/observations/README.md`](../observations/README.md) | update (neue Kennung + `BEO-ALL/anweisungssatz-eigentum-ohne-quelle` Stand) | Register-Pflicht (nicht mitgezählt) |

**Commit-Zuschnitt nach Rollen:** ein Reviewer-Durchgang ohne eigenen Commit
(Konsistenz ist Voraussetzung, kein Artefakt), danach ein Architect-Commit für
die Status-Übergänge, zuletzt die Planner-Closure.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit. Keine
technische Vorbedingung. **Nicht** blockiert auf
[slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md):
[ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
§Kontext sagt selbst, dass sie an keiner fremden Annahme hängt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die
  Konsistenzprüfung
  [ADR-0025](../../adr/0025-register-mit-gemischten-originalen.md) **nicht**
  mitträgt und DoD (2) dadurch eine eigene Ableitung braucht.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Prüfung einen
  Rollen-Widerspruch findet, der nach Baseline-Regelwerk
  `modul-08-agentenrollen.md` §Konflikt-Pfad ein Verdikt oder eine Folge-ADR
  statt eines Status-Wechsels verlangt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Erstens:**
`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md`
→ **1**, mit einer Geschichte-Zeile, die den Acceptance-Trigger nennt.
**Zweitens:** kein `Proposed`-ADR ohne benannten Träger — je verbleibendem
Treffer aus `grep -l '^\*\*Status:\*\* Proposed' docs/plan/adr/0*.md` liegt eine
Planning-Datei vor, die ihn nennt. Dazu die Closure-Notiz mit
Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Konsistenzprüfung findet einen inhaltlichen Einwand** gegen eine der
  drei Festlegungen von
  [ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md).
  — **Ausgang:** <entfallen: nur Konsistenz-Bestätigung | eingetreten: die ADR
  wird vor der Annahme korrigiert (sie ist noch `Proposed`, keine Folge-ADR
  nötig) — Beleg in der Geschichte-Tabelle>
- **DoD (2) wächst zu einem zweiten Liefergegenstand**, weil
  [ADR-0025](../../adr/0025-register-mit-gemischten-originalen.md) eine eigene
  Konsistenzprüfung braucht. — **Ausgang:** <entfallen: sie reist im selben Zug
  mit | eingetreten: Folge-Slice mit ID, und dieser Slice trägt nur den
  benannten Träger>
- **Der Zähler der neuen Kennung startet bei 1×**, obwohl die Klasse zum
  Zeitpunkt dieses Slice schon zwei Instanzen hat — dieselbe Grenze, die
  [`BEO-ALL/zaehler-startet-bei-null`](../observations/BEO-ALL/zaehler-startet-bei-null/observation.md) führt. — **Ausgang:** <weiter offen →
  `BEO-ALL/zaehler-startet-bei-null` im Register (kein neuer Mechanismus)>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `docs/plan/adr/`. Es fällt
unter den Eintrag `*` (gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
— **alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit
nach dem *Umfang*-Absatz oben.

**Vorgelagert — offene Beobachtungen sichten:** [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md)
(4×) berührt diesen Slice — [ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
schließt die `.claude/agents/*.md`-Hälfte, die
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Festlegung 3 offen ließ; sein Ausgang steht in DoD.
[`BEO-ALL/zaehler-startet-bei-null`](../observations/BEO-ALL/zaehler-startet-bei-null/observation.md) (1×, Zähler startet bei null) trägt einen
Risiko-Ausgang in §6. [`BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md) (1×, Plan-Umfang) ist auf
diesen Plan angewandt statt notiert. Keine weiteren Treffer.
