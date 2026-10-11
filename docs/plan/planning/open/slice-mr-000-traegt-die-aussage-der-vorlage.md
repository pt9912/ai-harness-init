# Slice slice-mr-000-traegt-die-aussage-der-vorlage: MR-000 trägt die Aussage der Vorlage — und eine begrenzte Stichprobe über modul-14/15/16

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — Mitglied aus deren §4 (dort unter dem
Namen `slice-064`); der Closure-Trigger der Welle (Matrix 4 × 2) fordert ihn.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage).

**Berührte Spec-Stellen:** `—`. Der Slice berührt den Adaptions-Block, kein Spec-Stratum.

**Verantwortlich:** — (bis zur Priorisierung). Die Änderung an [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) ist Architect-Arbeit in
eigenem Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.8).

**Autor:** Planner. **Datum:** 2026-10-11.

---

## 1. Ziel und Abgrenzung

**Ziel:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) sagt, was die vendored Vorlage sagt — ihre Eingrenzung auf Verzeichniskonvention,
Lifecycle-Regeln, Carveout-Disziplin und ID-Schema —, oder die Verschärfung gegenüber der Vorlage
steht als Deklaration mit Geltungsbereich, Begründung und Auflösungs-Trigger da; dazu eine
Stichprobe über die Abschnitte von `modul-14`, `modul-15` und `modul-16` mit dem Befund *Muster* oder
*kein Muster*.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Out-of-Scope-Punkte von [welle-09](../welle-09-modul-15-konformitaet.md) §6** — sie gelten
  für den Slice unverändert; namentlich die Kurs-Vorlagen selbst: ein Fehlen dort ist ein
  Upstream-Befund, keine repo-eigene Kopie.
- **Eine Inventur aller Regelwerk-Abschnitte** — die Stichprobe ist auf drei Module begrenzt, weil
  nur sie an Modul 15 grenzen; mehr wäre ein anderer Vorgang mit eigenem Schnitt.
- **Ein Sensor aus dem Befund der Stichprobe** — ergibt sie ein Muster, ist der Sensor ein eigener
  Kandidat (Folge-Slice mit Kennung, vergeben vom Closure-Lauf), weil Befund und Abhilfe verschiedene
  Gegenstände sind.
- **Ein Byte im vendored Baum** — `.harness/baseline/` ist ein Fremd-Blob, den nur ein
  Vendoring-Vorgang bewegt.
- **Der Wortlaut von [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) in diesem Plan** — Hard Rules und Adaptions-Block schreibt der
  Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8); der Plan nennt den Gegenstand, nicht den Text.

## 2. Definition of Done

- [ ] [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) trägt die Aussage der Vorlage oder deklariert die Verschärfung vollständig (Architect-Commit); Beleg: Kommando gegen `.harness/baseline/v6.18.0/templates/harness/conventions.template.md`.
- [ ] Stichprobe über `modul-14`, `modul-15`, `modul-16`: je Abschnitt Regel, Träger im Repo oder Zustand, mit Kommando; Befund *Muster* oder *kein Muster* in §7. Bei *Muster* liegt der Kandidat als Datei in `open/`.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang.
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions/MR-000-baseline-aussage.md`](../../../../harness/conventions/MR-000-baseline-aussage.md) | update | Aussage der Vorlage oder vollständige Deklaration; Form (Kopf-Marke oder neuer Eintrag) entscheidet der Architect |
| `harness/conventions.md` | update | Index-Zeile von [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage), derivativ |
| `.harness/baseline/v6.18.0/regelwerk/modul-14-docker-harness.md`, `modul-15-observability.md`, `modul-16-produktiver-betrieb.md` | lesen | Stichproben-Gegenstand |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Auftraggeber; `Verantwortlich:` gesetzt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Stichprobe fördert mehr als ein Muster zutage, das der Slice nicht in einem Review-Lauf tragen kann.
- `in-progress` → `open` (blockiert — Carveout?): der Architect lehnt die Rücknahme ab und die Deklaration braucht eine ADR, die noch nicht angenommen ist.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Review-Report liegt vor, Closure-Notiz mit Lerneintrag
geschrieben.

## 6. Risiken und offene Punkte

- [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) ist ein angenommener Eintrag, der Nachbar-Einträge anspricht; die Korrektur-Form (Kopf-Marke oder neuer Eintrag) entscheidet der Architect — **Ausgang:** bei Closure zu setzen (eingetreten: slice-<Kennung> | entfallen: Grund | weiter offen: → BEO-<KUERZEL>/<slug>)
- Die Stichprobe ergibt ein Muster, das einen Sensor verlangt — **Ausgang:** bei Closure zu setzen (eingetreten: slice-<Kennung> | entfallen: Grund | weiter offen: → BEO-<KUERZEL>/<slug>)

## 7. Closure-Notiz

Wird bei Closure gefüllt.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`) — die einzige
deklarierte Sub-Area, die Schwelle ≥ 2 von 3 Achsen ist erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen
(`ls docs/plan/planning/observations/BEO-ALL | wc -l`). Treffer an [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)/Baseline-Aussage:
`BEO-ALL/baseline-aussage-ohne-mess-tag`, `BEO-ALL/adaptions-block-spricht-ueber-sich-selbst`,
`BEO-ALL/adaptions-achse-1-kurzschluss`; Zähler je Verzeichnis
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, Ausgang in dessen `state.md`
(Stand 2026-10-11 gelesen, nicht neu geurteilt).

Alle berührten Sub-Areas GF.
