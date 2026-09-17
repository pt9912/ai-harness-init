# Slice slice-ausgang-auf-einen-folge-slice-prueft-dessen-dod: Ein Ausgang, der einen Folge-Slice als Träger nennt, ist gegen dessen DoD gelesen

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

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Ausgang, der formal steht und nichts trägt, ist dieselbe Klasse auf der Planungs-Ebene),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (wem ein
Anweisungssatz gehört; Festlegung 2 lässt die Norm-Aussage ohne Original offen).

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

**Ziel:** Die Slice-Closure liest jeden Ausgang, der einen Folge-Slice als Träger nennt, gegen
dessen DoD. Gemeint sind der Risiko-Ausgang, die Adresse eines Review-Befunds und die Adresse
einer Grenze. Adressiert die DoD den Befund nicht, schärft die Closure die DoD des noch nicht
begonnenen Slice oder wählt einen anderen Ausgang. Die Regel steht an einem Ort, den jede
Slice-Closure liest, mit dem Herkunfts-Anker
`seit slice-mv-zieht-praefixlose-geschwister-verweise-nach`.

**Herkunft:** Der Eintrag
[`ausgang-nennt-traeger-der-nicht-traegt`](../observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/observation.md)
hat mit `slice-mv-zieht-praefixlose-geschwister-verweise-nach` zum ersten Mal 3× erreicht. Der
Lese-Schritt jener Closure hat ihm den Ausgang *geplant* mit dieser Kennung gegeben. Die
Baseline nennt die Frage ein Urteil: *„ob die genannte Folge-Slice-ID die Realisierung
tatsächlich auffängt"* (`v6.9.0` · `modul-05-planning-harness.md` §Offene Risiken werden bei
Closure aufgelöst). Einen Ort für dieses Urteil hat das Repo nicht.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Sensor für die Deckung.** *Anderer Vorgang:* Ob eine DoD einen Befund adressiert, ist
  ein Urteil. Die urteilsfreie Hälfte, die Form des Ausgangs, hat die Adresse
  `slice-risiko-ausgang-hat-einen-sensor`.
- **Die Ausgänge im Bestand unter `done/` werden nicht nachgelesen.** *Bestand bleibt bewusst
  stehen:* Die Dateien sind Zeitdokumente, und ein nachträglicher Befund hätte dort keinen
  Träger.
- **Keine Änderung an einem Werkzeug oder Gate.** *Schicht-Abgrenzung:* Der Gegenstand ist ein
  Schritt der Planner-Rolle.

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

Zwei Liefer-Punkte.

- [ ] **1 — Die Regel steht an ihrem Zielort, mit Herkunfts-Anker.** Zielort und schreibende
      Rolle hat der Architect bestätigt, und sein Verdikt liegt als Artefakt vor (Baseline-Regelwerk
      `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 3b, im Repo ohne Wellen
      bei der Slice-Closure). Die Regel nennt, woran der Lauf das Urteil festmacht: den Befund und
      die DoD-Zeile des Folge-Slice, die ihn trägt.
- [ ] **2 — Die Regel hat ihr Gegenbeispiel** ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Für
      jeden der drei Belege des Eintrags ist gezeigt, an welchem Schritt der Regel der Ausgang
      aufgefallen wäre. Fiele einer nicht auf, nennt die Regel ihre Grenze.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: keines über Liefer-Punkt 1 hinaus, solange der Zielort ein Anweisungssatz
      ist. Wird es ein öffentlicher Vertrag, zieht der Slice ihn nach.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. Die `state.md` von `ausgang-nennt-traeger-der-nicht-traegt` trägt danach *verkörpert* mit Zielort und Anker.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Zielort der Regel, Kandidat [`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md) | update | Liefer-Punkt 1; den Ort bestätigt der Architect |
| `docs/plan/planning/observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/state.md` | update | Ausgang *verkörpert* |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei. Keine Abhängigkeit hält den Start.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Architect verlangt für die Regel
  eine ADR. Dann ist die ADR ein eigener Vorgang, und dieser Slice wartet auf sie.
- `in-progress` → `open` (blockiert — Carveout?): Keine Quelle benennt eine schreibende Rolle
  für den Zielort, und der Architect lässt die Frage offen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Die Regel steht am bestätigten Zielort mit dem Anker aus §1, und `make docs-check` meldet
   keinen Befund.
2. Die drei Belege sind gegen die Regel gelesen (Liefer-Punkt 2), und `make gates` ist grün.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Die Regel wird zur Pflichterfüllung**, ein Satz „DoD geprüft" ohne Urteil. *Absehbar:*
   entfallen, wenn die Regel Befund und tragende DoD-Zeile nennen lässt (Liefer-Punkt 1). —
   **Ausgang:** <offen>
2. **Der Zielort bindet nur einen Lauf, der ihn lädt.** Das Register führt die Klasse als
   `bedingung-ohne-traeger-im-lauf-den-sie-bindet`. *Absehbar:* weiter offen, wenn kein Ort
   gefunden ist, den jede Slice-Closure liest. — **Ausgang:** <offen>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Der Gegenstand ist ein Schritt des Prozesses und liegt in
`*`. `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`ausgang-nennt-traeger-der-nicht-traegt`](../observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/observation.md) | 3 | geplant, diese Kennung | der Gegenstand |
| [`bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md) | 1 | offen | §6, Risiko 2 |
| [`dritter-risiko-ausgang-ohne-ort`](../observations/BEO-ALL/dritter-risiko-ausgang-ohne-ort/observation.md) | 6 | verkörpert | Nachbar: Dort fehlte dem Ausgang *weiter offen* der Ort, hier fehlt dem Ausgang mit Folge-Slice die Prüfung |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
