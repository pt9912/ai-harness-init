# Slice slice-risiko-ausgang-hat-einen-sensor: Ein Sensor meldet einen Slice in `done/`, dessen Risiko keinen Ausgang trägt

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

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-010`](../../../../harness/conventions.md#mr-010) (die Gate-Konfiguration des Doku-Gates),
[`MR-054`](../../../../harness/conventions.md#mr-054) (was davon ins Ziel geht).

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

**Ziel:** Die urteilsfreie Hälfte der Risiko-Regel hat einen Sensor in `make gates`. Er meldet
jeden Slice in `done/`, der in §6 ein Risiko ohne Ausgang trägt oder einen Ausgang außerhalb der
geschlossenen Menge (eingetreten · entfallen · weiter offen). Das gilt für jede Closure, nicht
nur für eine Stilllegung.

**Quelle der Pflicht:** Baseline `v6.9.0` · `modul-05-planning-harness.md` §Offene Risiken werden
bei Closure aufgelöst: *„Welches Werkzeug die urteilsfreie Hälfte prüft, ist Repo-Entscheidung;
dass sie eine hat, ist es nicht."* **Befund:** Die Verifikation von
`slice-stilllegungs-kanten-sind-gemessen`
(`docs/reviews/2026-09-17-slice-stilllegungs-kanten-sind-gemessen-verify.md` §2 und §3) hat
gemessen, dass kein aktives Modul des gepinnten d-check einen solchen Slice meldet. Das
Beobachtungs-Register und die offenen Pläne führten die Lücke bis zu diesem Slice nicht.

**Der Bestand trägt den Ausgang in wechselnder Form.** Ein grober Blick zeigt 172 Slices in
`done/` mit §6, von denen 109 das Wort *Ausgang* überhaupt enthalten:

```sh
t=0; n=0; for f in docs/plan/planning/done/slice-*.md; do grep -q '^## 6\.' "$f" || continue
  t=$((t+1)); grep -q 'Ausgang' "$f" && n=$((n+1)); done; echo "$t $n"
```

Das ist eine Trefferliste am Stand dieser Anlage, keine Messung der Regel und kein
Erwartungswert. Ein Sensor über den ganzen Bestand wäre darum dauerhaft rot, und er braucht eine
deklarierte Form und einen Stichtag.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Nachrüsten des Bestands.** *Bestand bleibt bewusst stehen:* Der Sensor bindet ab seinem
  Stichtag. Ein nachgetragener Ausgang wäre rekonstruiert statt entschieden.
- **Die Prüfung, ob ein Ausgang trägt** (zum Beispiel ob der genannte Folge-Slice den Befund
  auffängt). *Anderer Vorgang:* Das ist nach derselben Quelle ein Urteil; das Register führt die
  Klasse als `ausgang-nennt-traeger-der-nicht-traegt`.
- **Die Stilllegungs-Form** (`Gegenstand:`, leere Liefer-Punkte). *Anderer Vorgang:* Dafür gibt es
  eine eigene Anforderung an d-check (`harness/sensors/docs-check.md` §Modul `planning`).
- **Die emittierte Ebene.** *Anderer Vorgang:* Ein Modul geht erst nach Erprobung im Dogfood ins
  Ziel ([`MR-054`](../../../../harness/conventions.md#mr-054)); dieser Slice liefert die
  Erprobung.
- **Kein Commit in fremde Repos.** *Schicht-Abgrenzung*, Regel des Auftraggebers vom 2026-09-17:
  Eine Anforderung an d-check formuliert dieses Repo als Text, und der Auftraggeber gibt sie
  weiter.

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

- [ ] **1 — Form und Stichtag sind festgelegt und gemessen.**
      - Festgelegt ist, welche Zeile in §6 als Ausgang gilt: die Form von `slice.template.md` §6
        am Stand `v6.9.0` oder eine deklarierte Erweiterung.
      - Gemessen ist, wie viele Slices in `done/` sie tragen; das Kommando steht daneben.
      - Festgelegt ist, woran der Sensor seinen Stichtag erkennt.
- [ ] **2 — Der Sensor läuft in `make gates` und färbt beide Fälle rot.**
      - Rot werden ein Risiko ohne Ausgang und ein Ausgang außerhalb der Menge, je rot gesehen
        mit gelesener Meldung ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
      - Der Bestand vor dem Stichtag bleibt grün.
      - Ist der Sensor ein Test oder ein repo-eigenes Werkzeug, trägt `test/mutations/` einen
        Fall.
- [ ] **3 — Der Sensor ist dokumentiert.** Die Sensor-Datei nennt Vertrag und Grenze; neben dem
      Urteil über das Tragen ist das auch der Bestand vor dem Stichtag.
      [`harness/README.md`](../../../../harness/README.md) §Sensors führt ein neues Ziel.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md)
      nennt die Lage „Risiko ohne Ausgang" mit dem neuen Sensor statt mit dieser Adresse.
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
| Träger des Sensors: [`.d-check.yml`](../../../../.d-check.yml) mit `d-check.mk` nach einem Pin-Sprung, oder ein repo-eigenes Werkzeug unter `harness/tools/` mit `Makefile`-Ziel | neu / update | [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| Test und `test/mutations/<nnn>-…` | neu, beim repo-eigenen Weg | DoD 2 |
| Sensor-Datei, [`harness/README.md`](../../../../harness/README.md), [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | neu / update | DoD 3 |

**Der Weg über d-check** setzt voraus, dass der Auftraggeber die Anforderung weitergibt (Text vom
2026-09-17 im Bericht an den Koordinator) und ein Release die Prüfung trägt. Sinngemäß lautet
sie: Die Prüfung `closure` des Moduls `planning` meldet für jede Slice-Datei unter `done/` ein
Risiko ohne Ausgang und einen Ausgang außerhalb einer konfigurierbaren Menge; Abschnitt, Muster,
Menge und Stichtag sind konfigurierbar.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei, und der Weg ist gewählt. Entweder
führt ein d-check-Release die Prüfung (dann schließt dieser Slice den Pin-Sprung ein oder folgt
ihm), oder der Architect hat einen repo-eigenen Sensor entschieden. Ein eigenes Werkzeug neben
einem Modul, das es bald gibt, wäre zwei Fassungen eines Wächters.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Pin-Sprung bringt eigene
  Normativ-Fragen mit. Dann wird der Sprung als eigener Slice geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Auf dem d-check-Weg gibt es kein Release mit
  der Prüfung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün mit aktivem Sensor, und beide Gegenbeispiele sind rot gesehen.
2. Die Form und der Stichtag stehen mit Kommando in der Sensor-Datei.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Die Formvielfalt des Bestands macht jede Form willkürlich.** *Absehbar:* entfallen durch
   einen Stichtag ab der Einführung; sonst eingetreten, und der Sensor bleibt dauerhaft rot. —
   **Ausgang:** <offen>
2. **Der Sensor prüft eine Zeile statt eines Risikos.** Ein Risiko über mehrere Zeilen und ein
   Ausgang am Ende seines Absatzes gehören zusammen. *Absehbar:* entfallen, wenn das rote
   Gegenbeispiel ein mehrzeiliges Risiko ist; sonst eingetreten, mit Beleg in
   `zusage-nennt-sensor-der-form-nicht-sieht`. — **Ausgang:** <offen>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo), denn der Sensor liest die
Planungs-Ablage. `harness/tools/` (`TOOLS`) ist nur auf dem repo-eigenen Weg berührt.

**Vorgelagert — offene Beobachtungen sichten:** Gesichtet ist nach Gegenstand; den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`. Keine der Zahlen ist ein
Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| `dritter-risiko-ausgang-ohne-ort` | 6 | verkörpert | ein Nachbar: Der Ort des dritten Ausgangs steht, geprüft wird er nicht |
| `ausgang-nennt-traeger-der-nicht-traegt` | 2 | offen | die Urteils-Hälfte, hier ausgeschlossen (§1) |
| `benannte-luecke-ohne-ausgang` | 2 | offen | dieser Slice ist die Adresse einer benannten Lücke |
| `register-paarung-ohne-gate-modul` | 1 | offen | dieselbe Bauart: eine urteilsfreie Closure-Prüfung ohne Modul |

**Kein Eintrag erreicht mit diesem Slice absehbar 3×.**

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
