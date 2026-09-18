# Slice slice-pin-kopplung-bekommt-ihren-mutations-fall: Der Pin-Kopplungs-Wächter bekommt seinen kuratierten Mutations-Fall

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der
Digest-Pin ist die Reproduzierbarkeits-Zusage, die der Wächter hält),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Wächter, dessen Zahn nicht kuratiert ist, ist beim nächsten Eingriff unbewacht — §3.6),
[`MR-061`](../../../../harness/conventions.md#mr-061) (der permanente Auflösungs-Trigger, bei jedem
d-check-Release die Pin-Stellen zu bewegen — genau der Eingriff, gegen den der Fall wacht),
[`MR-066`](../../../../harness/conventions.md#mr-066) (die Pin-Linie und ihre drei Digest-Wege).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-18.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `test/mutations/` bekommt einen Fall, dessen Mutation die Pin-Zeilen in
[`d-check.mk`](../../../../d-check.mk) allein auf einen Stand mit anderem Tag und anderem Digest
setzt und der als erwartete Färbung beide Kopplungs-Tests nennt
(`TestDefaultImage_MatchesCanonical`, `TestDefaultDigest_MatchesCanonical` in
`internal/emit/emit_test.go`). Damit listet `make mutate` den Pin-Kopplungs-Wächter: eine künftige
Pin-Bewegung, die die Kopplung der zwei Stellen bricht — etwa nur eine der beiden Stellen
nachgezogen —, färbt beim Mutations-Lauf einen Befund, statt für den Wächter still zu bleiben.

**Herkunft:** Review F-1 (MEDIUM) des Vorgangs
`slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme`, geführt unter der Klasse
[`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
(vierte Fundstelle). Der Wächter trägt seine Zähne — die Rotation wurde am Wegwerf-Klon real rot
gefahren —, aber keinen kuratierten Fall:
`grep -rln 'DCHECK_DIGEST\|DCHECK_IMAGE\|DefaultDigest\|DefaultImage' test/mutations/` → kein
Treffer; der bestehende Fall `01-baseline-pin-kopplung.sh` deckt die Baseline-Pins, nicht den
d-check-Pin. Der fehlende Fall ist ein Bestands-Posten der Mutations-Kuratierung.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine zweite Verkörperung der Klasse.** *Bestand bleibt bewusst stehen:* Die Regel trägt
  [`AGENTS.md`](../../../../AGENTS.md) §3.6, das Register führt sie als **verkörpert** — dieser
  Slice schreibt den fehlenden Fall, keine neue Regel und keinen zweiten Anker.
- **`internal/emit/emit_test.go` bleibt unverändert.** *Schicht-Abgrenzung:* Die Kopplung steht
  und ist real rot gemessen; der Defekt liegt in der Kuratierung, nicht im Wächter. Ein Eingriff
  in die Tests wäre ein zweiter Vorgang mit eigener Rot-Bedingung.
- **Kein Eingriff in [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh).**
  *Anderer Vorgang:* Der Sensor liest `test/mutations/` als Fall-Verzeichnis; ein neuer Fall ist
  Daten, kein Werkzeug-Code.

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

- [ ] **1 — Der Fall existiert und bindet die Kopplungs-Zusage.**
      - Eine Datei unter `test/mutations/`, deren Mutation **nur** die Pin-Zeilen in
        [`d-check.mk`](../../../../d-check.mk) — die kanonische Quelle beider Kopplungs-Tests —
        auf einen fremden Stand (anderer Tag, anderer Digest) setzt und deren erwartete Färbung
        beide Testnamen nennt.
      - **Rot:** Der Fall färbt bei der Mutation keinen der beiden Namen; oder er färbt auch bei
        der geschwächten Zusage (ein Testname entfernt) unverändert — dann deckt ihn ein anderer
        Zweig und er bindet die Zusage nicht.
- [ ] **2 — Der Mutations-Sensor listet den Wächter.**
      - `make mutate` meldet den neuen Fall als gelistet und färbt ihn aus dem richtigen Grund
        rot; die Meldung ist gelesen — der Begründungstext eines roten Laufs ist Teil des
        Wächters. Der Einzelfall zeigt die Färbung vor dem vollen Lauf, der nächtlich in CI liegt.
      - **Rot:** `make mutate` meldet den Fall nicht; oder seine Meldung nennt eine andere
        Mutation als die geführte.
- [ ] **3 — `make gates` grün.**
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: entfällt — der Gate-Index ändert sich nicht (`make mutate` bleibt Werkzeug
      ohne Gate-Anspruch).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei nicht.
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
| `test/mutations/<Nummer>-pin-kopplung.sh` | neu | der Fall; Nummer, Benennung und Form nach den bestehenden Fällen abgeschrieben |
| `internal/emit/emit_test.go` | unverändert | §1: die Kopplung steht und ist rot gemessen; der Defekt liegt in der Kuratierung |
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | unverändert, geprüft | §1: der Fall ist Daten; der Sensor liest das Fall-Verzeichnis |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei; die Kennung ist vom Review des
Vorgangs `slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme` benannt und im Register
belegt. Kein weiterer Start-Trigger.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Fall braucht einen Eingriff in
  [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) oder in die Kopplungs-Tests, um
  rot zu werden — dann bindet die Kuratierung nicht und der Schnitt ist falsch.
- `in-progress` → `open` (blockiert — Carveout?): Der Fall-Form des Fall-Satzes widerspricht
  etwas, das [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) fail-closed ablehnt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make mutate` listet den Fall und färbt ihn aus dem richtigen Grund rot (Ausgabe gelesen).
2. `make gates` grün.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Die Mutation greift zu breit** und färbt einen anderen Wächter (etwa den
   Baseline-Pin-Kopplungs-Zahn) statt der d-check-Pin-Kopplung. **Ausgang:** *absehbar* entfallen,
   wenn die Mutation nur die zwei Pin-Zeilen berührt und der Befund die Kopplung trifft; sonst
   eingetreten → die Mutation engen, bis sie aus dem richtigen Grund rot.
2. **Die Fall-Form verletzt die Konventionen des Fall-Satzes** (Benennung, `# verify:`-Zeile,
   Driver-Kopplung) und fällt am `make test`/`make docs-check` statt am Mutations-Lauf.
   **Ausgang:** *absehbar* entfallen, wenn die Form von den bestehenden Fällen abgeschrieben ist;
   sonst eingetreten → Form nachziehen.
3. **Der volle Mutations-Lauf ist für den Beleg zu teuer** (gemessen liegt er im Stundenbereich;
   die CI fährt ihn nächtlich in `mutate.yml`). **Ausgang:** *absehbar* entfallen, wenn der
   Einzelfall vor dem vollen Lauf die Färbung zeigt und der volle Lauf der CI überlassen bleibt;
   sonst weiter offen → der Beleg trägt am Einzelfall und an der nächtlichen CI.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `test/mutations/` und der Mutations-Sensor
unter `harness/tools/` (nur geprüft, nicht geändert); beide liegen in `*` (gesamtes Repo).
`.codex/` ist nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) | 11 | verkörpert | Dieser Slice schreibt den Fall, den der vierte Beleg benannt hat; der Ausgang des Eintrags (verkörpert) ändert sich nicht, sein Beleg kommt bei der Closure dieses Slices dazu |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).