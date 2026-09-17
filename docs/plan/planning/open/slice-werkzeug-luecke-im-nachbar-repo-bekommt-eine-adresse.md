# Slice slice-werkzeug-luecke-im-nachbar-repo-bekommt-eine-adresse: Eine gemessene Lücke im gepinnten Nachbar-Werkzeug bekommt eine Adresse

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (das gepinnte
Werkzeug ist die Reproduzierbarkeits-Zusage, und seine Lücken wandern mit dem Pin),
[`MR-064`](../../../../harness/conventions.md#mr-064) und
[`MR-065`](../../../../harness/conventions.md#mr-065) (je ein Neu-Prüf-Satz für einen Fall im
Auflösungs-Trigger).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Eine Regel an einem Norm-Artefakt sagt, welche Adresse eine gemessene Lücke im
gepinnten Nachbar-Werkzeug `d-check` bekommt und wer darüber entscheidet. Bleibt die Regel
unbewacht, steht das dort benannt.

**Warum eine Regel.**

- Die Lücke kann dieses Repo nicht schließen. Die Abhilfe liegt im Nachbar-Repo desselben
  Nutzers, und über dessen Baum entscheidet kein Slice dieses Repos.
- Ohne Regel bleibt die Messung im Zeitdokument liegen, das sie erhoben hat.

**Beleg**, 3× erreicht mit `slice-d-check-pin-zieht-den-vcs-patch-nach`:
[`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md).
Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/evidence/ | wc -l`;
die Zahl ist kein Erwartungswert.

**Was der dritte Beleg vorführt, ohne dass es Norm ist.**

- Für das Lesen von Packs unter fremdem Präfix gab es zwei Stücke:
  - einen eingehenden Änderungswunsch im Nachbar-Repo, den der Auftraggeber freigab;
  - einen Neu-Prüf-Satz im Auflösungs-Trigger von
    [`MR-064`](../../../../harness/conventions.md#mr-064), den der nächste Pin-Sprung liest.
- Für einen Klon, der seine Objekte über Alternates liest, steht die Freigabe aus.

Ob die Regel beide Stücke verlangt, entscheidet das Verdikt aus §4.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Änderungswunsch an das Nachbar-Repo, auch nicht für den Alternates-Fall.** *Anderer
  Vorgang:* In fremden Repos committet dieser Prozess nichts, und ob ein Wunsch geht, entscheidet
  der Auftraggeber.
- **Kein Pin-Sprung.** *Anderer Vorgang:* Den Sprung auf einen Release, der eine Lücke schließt,
  trägt der Auflösungs-Trigger von [`MR-061`](../../../../harness/conventions.md#mr-061) und
  [`MR-064`](../../../../harness/conventions.md#mr-064).
- **Kein Sensor.** *Anderer Vorgang:* Ob eine Lücke im Nachbar-Werkzeug liegt, ist ein Urteil. Kein
  Modul aus `modules:` der [`.d-check.yml`](../../../../.d-check.yml) urteilt über das Werkzeug,
  das es selbst ist.
- **Die zwei früheren Belege werden nicht nachgezogen.** *Bestand bleibt bewusst stehen:* Sie
  stehen in Zeitdokumenten. Gebunden ist die Lücke, die ab der Regel gemessen wird.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Zwei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **1 — Die Regel steht am Zielort aus dem Verdikt des Architect.** Sie nennt ihren
      Geltungsbereich, die Rolle, die über eine Adresse im Nachbar-Repo entscheidet, und ihre
      Bewachung oder die fehlende Bewachung.
      - **Rot:** Ein `grep -c` über dem Regelsatz am genannten Zielort liefert 0.
- [ ] **2 — Die `state.md` des Belegs aus §1 trägt `verkörpert`**, mit Zielort und dem
      Herkunfts-Anker `seit slice-werkzeug-luecke-im-nachbar-repo-bekommt-eine-adresse`.
      - **Rot:** Die `state.md` nennt keinen Zielort, oder der Zielort trägt den Anker nicht.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: keines über die zwei Liefer-Punkte hinaus; kein öffentlicher Vertrag ist berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| der Zielort aus dem Verdikt: [`AGENTS.md`](../../../../AGENTS.md) §3, ein Eintrag unter [`harness/conventions/`](../../../../harness/conventions/) oder ein Rollen-Anweisungssatz unter `.claude/commands/` | update oder neu | die Regel (DoD 1), geschrieben von der Rolle aus dem Verdikt |
| die `state.md` des Belegs aus §1 | update | Ausgang `verkörpert` mit Zielort und Anker (DoD 2) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei. Das Verdikt des Architect zu Zielort
und schreibender Rolle liegt als Artefakt vor (Baseline-Regelwerk `modul-08-agentenrollen.md`
§Rollen-Sequenz für eine Welle, Schritt 3b).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Das Verdikt verlangt zwei Zielorte mit
  verschiedenen schreibenden Rollen, etwa die Norm beim Architect und den Ablauf in einem
  Rollen-Anweisungssatz. Dann wird der zweite ein eigener Slice.
- `in-progress` → `open` (blockiert — Carveout?): Das Verdikt verlangt eine ADR, und die ist nicht
  angenommen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Die Regel steht am Zielort, und das `grep` aus §2 findet sie.
2. Die `state.md` trägt `verkörpert` mit Zielort und Anker, und `make gates` ist grün.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Die Regel verlangt eine Adresse im Nachbar-Repo, die dieses Repo nicht setzen kann.**
   *Absehbar:* entfallen, wenn die Regel die Freigabe beim Auftraggeber verortet und hier nur das
   Übergabe-Artefakt an ihn verlangt. — **Ausgang:** <offen>
2. **Eine Regel ohne Wächter wirkt nicht stärker als heute.** *Absehbar:* weiter offen; die
   Grenze steht dann in der `state.md` des Belegs. — **Ausgang:** <offen>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** offen bis zur Closure.
- **Was ging anders als geplant:** offen bis zur Closure.
- **Steering-Loop-Eintrag:** offen bis zur Closure.
- **Beobachtungs-Register (`../observations/`):** offen bis zur Closure.
- **Folge-Slices:** offen bis zur Closure.
- **Risiken aus §6:** offen bis zur Closure, jedes mit genau einem Ausgang.
- **Drei Paarungen:** offen bis zur Closure.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist der Zielort aus dem Verdikt; jeder Kandidat
aus §3 liegt in `*`. `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md) | 3 | geplant | der Gegenstand (§1) |
| [`benannte-luecke-ohne-ausgang`](../observations/BEO-ALL/benannte-luecke-ohne-ausgang/observation.md) | 2 | offen | Nachbarklasse: Sie fragt, wohin eine Grenz-Beschreibung verschwindet, wenn die Lücke geschlossen ist |
| [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md) | 6 | verkörpert | Die Freigabe beim Auftraggeber braucht ein Übergabe-Artefakt |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
