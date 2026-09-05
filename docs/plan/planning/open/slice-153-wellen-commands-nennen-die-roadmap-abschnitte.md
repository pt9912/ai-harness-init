# Slice slice-153: Die zwei Wellen-Anweisungssätze nennen die Abschnitte, die die Roadmap führt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Baseline-Test ist das *Mehr*
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): eine beobachtbare
Closure-Bedingung, die mehr beobachtet als die DoD dieses Slice. Es gibt keine.

**Bezug:** [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) (vierter Beleg `slice-136` ist genau
dieser Fund), [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
(entscheidet, wer `.claude/commands/*.md` schreiben darf — die Vorbedingung),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Anweisungssatz, der einen Abschnitt nennt, den es nicht gibt, ist dieselbe
Klasse eine Ebene tiefer),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Link- und Anker-Pflicht als Träger).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine). Die zwei Dateien
sind die Anweisungssätze der Planner-Rolle; nach
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Festlegung 1 gehört ein Anweisungssatz der Rolle, die den Ablauf ausführt —
also dem **Planner**. Die Ableitung bindet erst mit der Annahme jener ADR
(§4 Start).

**Autor:** Planner. **Datum:** 2026-09-02.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

[`close-welle.md`](../../../../.claude/commands/close-welle.md) und
[`plan-welle.md`](../../../../.claude/commands/plan-welle.md) weisen an, eine
Welle in *Aktuelle Welle* zu heben bzw. aus ihr zu entfernen; die Roadmap führt
diesen Abschnitt seit [slice-136](../done/slice-136-roadmap-traegt-die-ziel-form.md)
nicht mehr — sie führt *Offene Wellen*, und Modul 6 Schritt 5 ersetzt die
Nachrück-Prozedur durch *„Befördert wird niemand"*. Gemessen:
`git grep -c 'Aktuelle Welle' -- .claude/commands/` → `close-welle.md:2`,
`plan-welle.md:1`; `grep -c '^## Aktuelle Welle' docs/plan/planning/in-progress/roadmap.md`
→ **0**. Keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2.

Der Slice zieht die drei Stellen nach **und** hängt sie an einen Wächter: als
Anker-Link geschrieben, meldet das Modul `anchors` des Doku-Gates einen
abgelösten Abschnittsnamen von selbst.

**Die emittierte Ebene ist nicht betroffen** —
`git grep -c 'Aktuelle Welle' -- internal/emit/templates/` gibt nichts aus. Der
Fund ist repo-lokal.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Die drei Stellen nennen den Abschnitt, den die Roadmap führt, und
      die Prozedur, die Modul 6 Schritt 5 vorgibt.**
      [`close-welle.md`](../../../../.claude/commands/close-welle.md) Schritt 5
      verliert die Nachrück-Anweisung (*„die erste Zeile aus Nächste Wellen wird
      die neue Aktuelle Welle"*) zugunsten von *„der Zeiger verlässt Offene
      Wellen; befördert wird niemand"*;
      [`plan-welle.md`](../../../../.claude/commands/plan-welle.md) hebt eine
      Welle nach *Offene Wellen*. Danach
      `git grep -c 'Aktuelle Welle' -- .claude/commands/` ohne Treffer.
- [ ] **(2) Der Abschnittsname steht als Anker-Link, und der Wächter ist rot
      gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Die Nennung wird
      `[Offene Wellen](../../docs/plan/planning/in-progress/roadmap.md#offene-wellen)`;
      das Gegenbeispiel ist ein Anker, den die Roadmap nicht führt —
      `make docs-check` meldet dafür `anchor-missing` und ist einmal rot zu
      sehen, bevor der richtige Anker steht.
- [ ] `make gates` grün.
- [ ] Doku-Update: Prüfung, ob
      [`implement-slice.md`](../../../../.claude/commands/implement-slice.md)
      oder [`harness/README.md`](../../../../harness/README.md) denselben
      abgelösten Namen tragen (kein sicherer Treffer).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) bekommt den Ausgang seiner Command-Hälfte
      in der Stand-Spalte (Zähler unverändert: der Slice löst auf, er beobachtet
      nicht neu).
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
| [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update (Schritt 5 + Kopf-Bezug) | DoD (1)/(2) — zwei Nennungen |
| [`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md) | update (Eröffnungs-Schritt 3) | DoD (1)/(2) — eine Nennung |
| [`docs/plan/planning/observations/README.md`](../observations/README.md) | update (`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` Stand) | Register-Pflicht (nicht mitgezählt) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **eine Vorbedingung außerhalb dieses Slice,
kein Liefer-Punkt** —
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
trägt `**Status:** Accepted`
(`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`
→ **1**). Träger ist
[slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md).
Vorher steht nicht fest, wer die zwei Dateien schreiben darf — und ein Lauf, der
sie ohne diese Antwort anfasst, ist genau der Vorgang, den
[`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md) zählt. Der Slice liegt darum in `open/`, nicht
in `next/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der
  Doku-Update-Punkt weitere lebende Fundorte aufdeckt und die Reparatur damit
  über die zwei Dateien hinauswächst.
- `in-progress` → `open` (blockiert — Carveout?): wenn
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  im Reviewer-Durchgang von
  [slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)
  nicht angenommen wird und das Eigentum offen bleibt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Erstens:** `git grep -c 'Aktuelle Welle' -- .claude/commands/` ohne Treffer,
und je Datei mindestens ein Anker-Link auf
`docs/plan/planning/in-progress/roadmap.md#offene-wellen`. **Zweitens:**
`make docs-check` grün **nachdem** derselbe Sensor mit einem falschen Anker rot
gesehen wurde (Ausgabe `anchor-missing`, im Closure-Eintrag zitiert). Dazu die
Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein
Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Wächter deckt weniger, als DoD (2) verspricht:** `anchors` prüft, ob
  der genannte Anker existiert, nicht, ob der Anweisungssatz die *richtige*
  Prozedur beschreibt. Der Prosa-Teil von DoD (1) bleibt unbewacht. —
  **Ausgang:** <entfallen: die Grenze ist im Closure-Eintrag benannt und
  entspricht dem, was das Gate leisten kann | weiter offen → `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` im
  Register>
- **Die Vorbedingung tritt nicht ein**, weil
  [slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)
  liegen bleibt oder die ADR nicht angenommen wird. — **Ausgang:** <entfallen:
  angenommen, Beleg in der Geschichte-Tabelle | eingetreten: Rückführung nach
  `open/` nach §4>
- **Der Anker `#offene-wellen` bricht**, wenn die Roadmap ihren Abschnitt
  erneut umbenennt — dann ist der Wächter der Melder, aber die Reparatur liegt
  wieder bei einem Lauf ohne Sensor für den Prosa-Teil. — **Ausgang:**
  <entfallen: genau das ist die Zusage von DoD (2) — der Bruch wird gemeldet
  statt still | weiter offen → `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` im Register>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `.claude/commands/`. Es
fällt unter den Eintrag `*` (gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
— **alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit
nach dem *Umfang*-Absatz oben.

**Vorgelagert — offene Beobachtungen sichten:** [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
(4×) ist der direkte Gegenstand; sein Ausgang steht in DoD.
[`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md) (4×) trägt die Vorbedingung in §4.
[`BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md) (1×, Plan-Umfang) ist auf diesen Plan angewandt
statt notiert. Keine weiteren Treffer.
