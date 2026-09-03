# Slice slice-151: Für die zwei Spec-Straten benennt eine Quelle die schreibende Rolle

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Baseline-Test ist das *Mehr*
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): eine beobachtbare
Closure-Bedingung, die mehr beobachtet als die DoD dieses Slice. Es gibt keine —
der Closure-Trigger unten wäre die Abschrift der eigenen DoD.

**Bezug:** [ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)
(grenzt die Architect-Zuordnung ausdrücklich auf `AGENTS.md` §3 und den
Adaptions-Block ein und lässt damit genau diese Lücke),
[ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
und [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
(dieselbe Frage, andere Artefaktklassen — Präzedenz für die Ableitung),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 (*„wo keine Quelle sie benennt, bleibt
die Frage offen"*), [`BEO-007`](../observations.md) (der Zähler, dessen dritter
und vierter Beleg genau diese zwei Dateien sind).

**Berührte Spec-Stellen:** `—`. Der Liefergegenstand ist eine ADR über das
Eigentum an zwei Spec-Dateien, kein Satz *in* ihnen.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine — das Feld setzt der
Übergang `open→next`). Der Liefergegenstand ist eine Norm-Aussage über
Rollen-Eigentum und damit **Architect**-Arbeit
([`AGENTS.md`](../../../../AGENTS.md) §3.8, Baseline-Regelwerk
`modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect
schreibt"*).

**Autor:** Planner. **Datum:** 2026-09-02.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

Für [`spec/spezifikation.md`](../../../../spec/spezifikation.md) und
[`spec/architecture.md`](../../../../spec/architecture.md) — Rang 2 und 3 der
Source Precedence — benennt heute keine Quelle die schreibende Rolle
(`grep -c '^\*\*Rolle:\*\*' spec/spezifikation.md spec/architecture.md` → je
**0**; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Eine ADR entscheidet sie und durchläuft im selben Slice ihren
Acceptance-Trigger.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Eine ADR entscheidet die schreibende Rolle für die zwei
      Spec-Straten** — per `cp` aus
      `.harness/baseline/v5.12.0/templates/docs/plan/adr/NNNN-titel.template.md`.
      Sie nennt ihren Geltungsbereich extensional (diese zwei Dateien), leitet
      aus [ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)
      §Kontext ab statt aus dem Bestand, und trägt einen
      Re-Evaluierungs-Trigger. Der ADR-Index
      ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt die neue Zeile.
- [ ] **(2) Die ADR durchläuft ihren Acceptance-Trigger in diesem Slice.** Ein
      Reviewer-Durchgang prüft auf Konsistenz (Baseline-Regelwerk
      `modul-08-agentenrollen.md` §Rollen-Regeln), danach setzt der Architect
      `**Status:** Accepted` und trägt den Trigger in die Geschichte-Tabelle
      (*„ADR-Review-Runde abgeschlossen → bindend"*, `grundlagen-bootstrap.md`
      §Vier Trigger-Klassen). Index-Status nachgezogen. **Ein eigener
      Folge-Slice für die Annahme entsteht nicht** — genau das ist die Klasse,
      die [slice-152](slice-152-adr-0029-acceptance-trigger.md) nachträglich
      auffängt.
- [ ] `make gates` grün.
- [ ] Doku-Update: [`AGENTS.md`](../../../../AGENTS.md) §3.8 bekommt den Zeiger
      auf die neue ADR — in eigenem Architect-Commit, **nach** DoD (2), nach dem
      Muster des bestehenden [ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)-Zeigers.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben —
      [`BEO-007`](../observations.md) bekommt den Ausgang seiner
      Spec-Straten-Hälfte (Stand-Spalte, Zähler unverändert: der Slice löst
      auf, er beobachtet nicht neu).
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste
      Welle-Closure — dieses Repo fährt Wellen-Betrieb, und das gilt auch für
      wellenlose Slices.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/00NN-…​.md` | neu (per `cp` aus der vendored Vorlage), Architect | DoD (1)/(2) |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update (Index-Zeile + Status), Architect | DoD (1)/(2) — derivatives Register desselben Originals ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| [`AGENTS.md`](../../../../AGENTS.md) | update (§3.8 Zeiger), Architect, eigener Commit | Doku-Update, fällig erst mit der Annahme |
| [`docs/plan/planning/observations.md`](../observations.md) | update (`BEO-007` Stand) | Register-Pflicht (nicht mitgezählt) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit. Keine
technische Vorbedingung; der Slice hängt an keinem anderen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Entscheidung
  die zwei Dateien nicht gemeinsam tragen kann und je Stratum eine eigene
  Ableitung verlangt.
- `in-progress` → `open` (blockiert — Carveout?): wenn die
  Reviewer-Konsistenzprüfung einen Rollen-Widerspruch findet, der nach
  Baseline-Regelwerk `modul-08-agentenrollen.md` §Konflikt-Pfad erst ein
  Verdikt braucht.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Erstens:** die neue ADR trägt `**Status:** Accepted` und eine
Geschichte-Zeile, die den Acceptance-Trigger benennt; der ADR-Index führt
denselben Status. **Zweitens:** `make gates` grün nach dem letzten Commit
(Stop-Hook-Stempel deckt den Arbeitsbaum). Dazu die Closure-Notiz mit
Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Entscheidung fällt breiter aus als der Geltungsbereich** und
  beantwortet die Rollenfrage für *jedes* Norm-Artefakt ohne benannte Rolle —
  dann ist sie keine Lückenfüllung mehr, sondern eine Regel über eine Menge,
  die außerhalb dieses Slice wächst. — **Ausgang:** <entfallen: der
  Geltungsbereich bleibt extensional auf die zwei Dateien | eingetreten:
  Folge-Slice mit ID für die allgemeine Fassung>
- **Die zwei Spec-Dateien tragen kein Kopf-Feld für die Rolle**, während die
  Ziel-Form der Baseline eines vorsieht ([`BEO-010`](../observations.md),
  zweiter Beleg). Die ADR entscheidet dann etwas, das im Artefakt selbst nicht
  ablesbar ist. — **Ausgang:** <entfallen: die ADR ist der Ort der Aussage, das
  Kopf-Feld ist Form-Arbeit von [slice-148](../done/slice-148-architecture-traegt-ihr-id-schema.md)s
  Nachfolge | eingetreten: Folge-Slice mit ID für das Kopf-Feld>
- **Der `AGENTS.md`-§3.8-Zeiger überlädt den Absatz**, der heute einen Fall
  trägt und mit [slice-145](../next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)
  einen zweiten bekommt. — **Ausgang:** <entfallen: der Zeiger bleibt ein
  auflösbarer Verweis ohne zweite Begründungs-Prosa ([`AGENTS.md`](../../../../AGENTS.md) §3.7)
  | eingetreten: die Form wird vor dem Commit angepasst>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `docs/plan/adr/` und das
Wurzelverzeichnis (`AGENTS.md`). Beide fallen unter den Eintrag `*` (gesamtes
Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
— **alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit
nach dem *Umfang*-Absatz oben.

**Vorgelagert — offene Beobachtungen sichten:** [`BEO-007`](../observations.md)
steht bei 4× und ist der direkte Gegenstand dieses Slice (Spec-Straten-Hälfte);
sein Ausgang steht in DoD, nicht bloß als Sichtungs-Notiz.
[`BEO-016`](../observations.md) (1×, Plan-Umfang) ist auf diesen Plan angewandt
statt notiert. Keine weiteren Treffer für die berührten Sub-Areas.
