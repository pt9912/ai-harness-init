# Slice slice-stilllegungs-form-hat-einen-waechter: Ein stillgelegter Slice ohne Zeile `Gegenstand:` färbt `make docs-check` rot

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
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (die Kanten `open → done` und
`next → done` kommen mit `v6.9.0`),
[`MR-001`](../../../../harness/conventions.md#mr-001) (eine Gate-Schärfung läuft über den
Steering-Loop), [`MR-054`](../../../../harness/conventions.md#mr-054) (was ins emittierte Gate
geht).

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

**Ziel:** Trägt ein Slice in `done/` in seiner DoD offene Task-Items, verlangt `make docs-check` in
§7 die Zeile `Gegenstand:`. Fehlt sie, meldet das Gate den Grund-Code
`section-open-tasks-marker-missing`. Dafür aktiviert der Slice im Dogfood das Modul `structure` mit
der Bedingung `open-tasks-require-marker`. Ob die Bedingung auch ins emittierte Gate geht,
entscheidet er nach den drei Kriterien aus [`MR-054`](../../../../harness/conventions.md#mr-054).

**Herkunft:**
- Die Ziel-Fassung nennt den Teil urteilsfrei: *„dass die `Gegenstand:`-Zeile eine Kennung oder
  einen Grund trägt"* (`v6.9.0` · `modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein
  anderer übernimmt).
- Am `v0.74.1` (Messstand; den gepinnten Stand führt `d-check.mk`, und die Umsetzung misst an ihm neu) meldet kein aktives Modul einen stillgelegten Slice ohne diese Zeile
  ([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Grenze).
- d-check `v0.76.0` bringt die Bedingung (`CHANGELOG.md`, `[0.76.0]`); den Pin hebt
  `slice-d-check-pin-bringt-die-stilllegungs-bedingung`.

**Der Bestand ist kein leerer Prüfbereich.** Offene Task-Items tragen
`grep -l '^- \[ \]' docs/plan/planning/done/*.md | wc -l` → 30 von
`ls docs/plan/planning/done/*.md | wc -l` → 202 flachen Dateien in `done/`. Keine der zwei Zahlen ist
ein Erwartungswert. Ein Gate über den ganzen Bestand wäre ab dem ersten Lauf rot. Den Prüfbereich
und seine Grenze deklariert darum DoD 1.

**Warum vor der Gruppierung.** Die Gruppierung der Go-Slices legt mehrere Slices über die
Stilllegungs-Kanten nach `done/`. Mit diesem Slice meldet das Gate eine vergessene
`Gegenstand:`-Zeile, statt dass allein der Lauf sie beurteilt
([`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md) §Einen Slice
stilllegen, Prüfung 3).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Pin-Sprünge.** *Zwei andere Slices übernehmen sie:*
  `slice-d-check-pin-bringt-die-stilllegungs-bedingung` und danach der Patch-Sprung
  `slice-d-check-pin-zieht-den-vcs-patch-nach`. Dieser Slice startet nach beiden (§4).
- **Die offenen Task-Items im Bestand werden nicht umgeschrieben.** *Bestand bleibt bewusst
  stehen:* Die Dateien in `done/` sind Zeitdokumente. Der Prüfbereich aus DoD 1 grenzt sie aus.
- **Kein Sensor für den Risiko-Ausgang.** *Ein anderer Slice übernimmt ihn:*
  `slice-risiko-ausgang-hat-einen-sensor`.
- **Ob die Kennung in `Gegenstand:` auflöst, bleibt Urteil.** *Anderer Vorgang:* Die Bedingung
  prüft, dass die Marke da ist, nicht, worauf sie zeigt.

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

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **1 — `.d-check.yml` aktiviert `structure` mit `open-tasks-require-marker` für die
      Slice-Pläne in `done/`, mit deklariertem Prüfbereich.**
      - Die Marke wird im Abschnitt §7 gesucht (`open-tasks-require-marker-section`). Das Muster
        ist gegen die Überschriften im Bestand gemessen.
      - `make docs-check` meldet über dem Bestand keinen Befund.
      - Der Prüfbereich und seine Grenze stehen mit Kommando in
        [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md).
- [ ] **2 — Die Bedingung ist rot gesehen, die Meldung ist gelesen.**
      - In einer Kopie außerhalb des Repos färbt ein stillgelegter Slice ohne `Gegenstand:`
        `make docs-check` mit `section-open-tasks-marker-missing`.
      - Derselbe Slice mit der Zeile bleibt ohne Befund.
      - Die Kommandos stehen im Umsetzungs-Commit. `make mutate` kennt für `make docs-check` keine
        Fehlschlag-Form; das steht als Grenze in der Sensor-Datei.
- [ ] **3 — Die Entscheidung für das emittierte Gate steht mit Beleg.**
      - Die drei Kriterien aus [`MR-054`](../../../../harness/conventions.md#mr-054) sind je mit
        Messung beantwortet: Erprobung, grüner Start, rotes Gegenbeispiel.
      - Geht die Bedingung ins Ziel, zieht die Vorlage nach, und
        [`make full-smoke`](../../../../harness/sensors/full-smoke.md) bleibt grün.
      - Geht sie nicht ins Ziel, steht der Grund in der Sensor-Datei.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) nennt die Bedingung, ihren Prüfbereich und das Gegenbeispiel (DoD 1, DoD 2).
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
| [`.d-check.yml`](../../../../.d-check.yml) | update | `structure` mit der Bedingung (DoD 1) |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | Prüfbereich, Grenze, Gegenbeispiel (DoD 1, DoD 2) |
| emittierte Doc-Gate-Vorlage unter `internal/emit/` | update, falls die Bedingung ins Ziel geht | [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (DoD 3) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-d-check-pin-bringt-die-stilllegungs-bedingung` liegt in
`done/`, ebenso `slice-d-check-pin-zieht-den-vcs-patch-nach`, und das WIP-Limit ist frei.
**Die Gruppierung der Go-Slices startet erst nach diesem
Slice.**

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Ein grüner Start braucht mehr als eine
  Auswahl des Prüfbereichs, etwa eine Änderung an Plänen in `done/`.
- `in-progress` → `open` (blockiert — Carveout?): Die Bedingung kann die Marke nicht in §7 suchen,
  weil sich die Überschriften des Bestands durch kein Muster fassen lassen. Die Anforderung geht dann
  an das d-check-Repo.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make docs-check` ist über dem Bestand grün, mit aktivierter Bedingung.
2. Das Gegenbeispiel aus DoD 2 ist rot gesehen, und `make gates` ist grün.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Prüfbereich schließt zu viel aus**, etwa alle Dateien vor einem Stichtag, und damit auch
   künftige Stilllegungen. *Absehbar:* entfallen, wenn das Gegenbeispiel aus DoD 2 im Prüfbereich
   liegt. — **Ausgang:** <offen>
2. **Die Bedingung zählt Task-Items in anderen Abschnitten als §2.** *Absehbar:* entfallen, wenn
   `section-pattern` auf §2 beschränkt ist und das Gegenbeispiel es zeigt. — **Ausgang:** <offen>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `.d-check.yml`, `internal/emit/`
und `harness/sensors/`; alle liegen in `*`. `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind
nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md) | 2 | offen | die Lücke der Stilllegungs-Form hat mit `v0.76.0` eine Antwort im Werkzeug |
| [`bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md) | 1 | offen | die Prüfungen je Stilllegung bekommen einen Träger im Gate |
| [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | 16 | geplant | DoD 2: das Gegenbeispiel zeigt, dass der Sensor die Form sieht |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
