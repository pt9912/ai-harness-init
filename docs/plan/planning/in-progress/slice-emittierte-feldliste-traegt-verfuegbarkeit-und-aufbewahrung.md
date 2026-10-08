# Slice slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung: Die emittierte Feldliste trägt die Verfügbarkeits-Aussagen und die Aufbewahrung, die Spec §5 als Zeilen führt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-erfassungsschicht-im-ziel](../welle-erfassungsschicht-im-ziel.md) — nach
`slice-agent-role-traegt-nicht-bekannt`, dessen Spec-Zeilen dieser Slice liest.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Arbeits-Bezug),
[`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) (Festlegung 3 und 9,
Folgepflicht 3), [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (Folgepflicht 3: die emittierte Ebene
bleibt vom Spec-Umbau unberührt — dieser Slice ist die Tool-Ebene),
[`MR-081`](../../../../harness/conventions.md#mr-081) und [`MR-077`](../../../../harness/conventions.md#mr-077)
(die Abweichungen, deren Begründung die Feldliste nennt), [`AGENTS.md`](../../../../AGENTS.md) §3.6, §3.7.

**Berührte Spec-Stellen:** — (der Slice ändert keine; er **liest** die Zeilen von
[§5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) zu den Abweichungen 2 bis 6 und zu `SPEC-087` als Quelle
seiner Aussagen, nach dem Umbau in `slice-spec-5-wird-nach-adr-0074-umgebaut`).

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-09-30.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die emittierte Feldliste (`internal/span/fieldlist.go`, Tool-Ebene, im Zielrepo wirksam) trägt die
Verfügbarkeits-Aussagen und die Aufbewahrung, die ihr fehlen: (1) Cache-Status — Haupt-Kontext gegen Subagent
(Pflicht mit Kennzeichnung, `SPEC-024`/`SPEC-087` — die Feldliste trägt sie schon, nur die Differenz zählt); (2) die PR-Nummer steht **bewusst nicht** im Schema, und der Grund (Abweichung 2); (3) der
Haupt-Kontext trägt keine Zahl (Abweichung 6, mit 3 und 5, soweit dort etwas fehlt); (4) die Aufbewahrung und
`make span-clean` (Abweichung 4). Jede Aussage ist getestet und im gebootstrappten Ziel per E2E belegt.

**Ausgangslage, gemessen** (keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025)):

```sh
grep -c 'span-clean' internal/span/fieldlist.go    # 0  die Aufbewahrung steht nicht in der Feldliste
```

Die Wortlaute erfindet der Slice nicht: Quelle sind die Spec-Zeilen nach dem Umbau und die zwei Adaptions-Einträge.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Änderung an `spec/`.** Die Zeilen entstehen im Umbau-Slice; dieser liest sie — Schicht-Abgrenzung.
- **Kein neues Schema-Feld.** Die PR-Nummer bleibt außerhalb des Schemas; sie durch Code aufzulösen wäre die andere
  Wahl der Entscheidung (Auflösung statt Adaptions-Eintrag) und braucht einen Architect-Beschluss, keinen
  Implementer-Griff.
- **Kein Norm-Text.** Was die Feldliste sagt, steht schon in den Einträgen; fehlt ein Satz, ist es eine Übergabe an
  den Architect.
- **Keine Änderung an der emittierten Spec-Vorlage im Emit-Baum**
  ([`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 9): das Kommando
  `grep -rl 'Präzisiert' internal` bleibt leer.
- **Kein Sensor für „Feldliste und Spec sagen dasselbe".** Das ist `slice-feldabdeckung-existenz-sensor` (`open/`)
  mit Existenz-Abgleich; die Wortlaut-Gleichheit hält keiner — dieselbe Lücke, die das Register führt.

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

- [ ] **Liefer-Punkt 1 — die Aussagen in der Feldliste.** `internal/span/fieldlist.go` trägt die vier Aussagen aus
      §1, je im Wortlaut, der die Quelle nennt (Spec-Zeile bzw. Adaptions-Eintrag), ohne ein Datum als Zustand
      auszugeben, das die Quelle nicht trägt.
- [ ] **Liefer-Punkt 2 — Test je Aussage.** Ein Test je Aussage in `internal/span/fieldlist_test.go`, dessen Name
      die Aussage führt. **Rot gesehen:** eine Aussage aus der Feldliste streichen → genau dieser Test wird rot,
      mit der Meldung, die die gestrichene Aussage nennt (nicht irgendein Test); dazu ein Fall unter
      `test/mutations/` (`make mutate` mit `MUTATE_CASES`), sonst ist der Wächter unbewacht
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **Liefer-Punkt 3 — E2E im gebootstrappten Ziel.** Eine Stufe von `make full-smoke` liest die Aussagen im
      **emittierten** Text des Ziels; sie trägt die Stufen-Kopfzeile, sodass `make e2e-abdeckung` sie führt
      (Sicht `docs/user/e2e-abdeckung.md` neu erzeugt). **Rot gesehen:** die Aussage im Träger streichen → die Stufe
      färbt rot; ohne Netz nicht fahrbar, wird das im Bericht genannt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: `docs/user/` nennt die Feldliste, wo sie beschrieben ist; Prüfung
      `grep -rln 'fieldlist\|Feldliste' docs/user` steht im Bericht, ein Treffer wird nachgezogen.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
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
| `internal/span/fieldlist.go` | update | Liefer-Punkt 1: vier Aussagen |
| `internal/span/fieldlist_test.go` | update | Liefer-Punkt 2: ein Test je Aussage, Rot durch Streichen |
| `test/mutations/` | neu | ein Fall je Aussage-Wächter (604–607), dazu 608 an der realen Quelle: die Spezifikation benennt den Gegenstand einer Zeile um |
| `harness/tools/full-smoke.sh` | update | Liefer-Punkt 3: Stufe mit Kopfzeile |
| `docs/user/e2e-abdeckung.md` | neu erzeugt | `make e2e-abdeckung` nach der neuen Stufe |

**Fortgeschrieben im Lauf (Implementer):**

- Die Feldliste nennt ihre Quelle beim **Gegenstand** der Spec-Zeile und beim **Titel** des
  Adaptions-Eintrags, nicht bei der Kennung: `TestEmittierteDateienTragenNurImZielAufloesendeKennungen`
  hält, dass eine emittierte Datei keine Kennung trägt, die im Ziel nicht auflöst
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Die Tests lesen
  Gegenstand und Titel aus der Spezifikation bzw. der Eintrags-Datei, statt sie abzuschreiben.
- Aussage (1) war zur Hälfte geliefert (Kennzeichnung der Cache-Zähler, Satz zu den Verbrauchs-Zählern);
  ergänzt ist die Differenz: Zahl nur im Span eines Subagenten-Aufrufs im Vordergrund, der Cache des
  Haupt-Kontexts in keinem Span. Eine „Abweichung 3" führt §5 nicht mehr; Abweichung 5 deckt der
  bestehende Satz zu den Verbrauchs-Zählern.

- **Zwei Schichten:** Go-Tool (Feldliste, Test) und E2E-Skript; die Spec und die Vorlage bleiben unberührt.
- Der Lauf liest zuerst die Spec-Zeilen und die zwei Einträge und stellt je Aussage fest, was die Feldliste
  **schon** sagt (`SPEC`-Zeile Cache-Status, Pflicht-Satz) — nur die Differenz wird ergänzt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-spec-5-wird-nach-adr-0074-umgebaut` liegt in `done/`
(`ls docs/plan/planning/done/slice-spec-5-wird-nach-adr-0074-umgebaut.md` nennt die Datei) — die Aussagen stehen erst
danach als Zeilen, aus denen der Lauf sie liest — **eingetreten**. Dazu `slice-agent-role-traegt-nicht-bekannt` in `done/`, sonst liest der Lauf `SPEC-056`/`SPEC-087` im alten Wortlaut.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die E2E-Stufe mehr als die Feldliste selbst trägt
  (etwa ein neues Fixture-Ziel) — dann Teilung: Feldliste und Test zuerst, Stufe danach.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Architect die PR-Nummer per Code auflösen will
  (die andere Wahl der Entscheidung) — dann ändert sich die Aussage 2, der Plan wird neu geschnitten.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) die vier Tests grün und ihr Rot bei gestrichener Aussage gelesen, der Mutations-Fall
färbt rot; (2) `make gates` grün mit Stempel und die E2E-Stufe im Ziel grün oder ihre Nicht-Fahrbarkeit benannt. Dazu
der Lerneintrag. Den Abschluss schreibt der Planner ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Feldliste und Spec-Zeile weichen im Wortlaut ab**, und der Existenz-Abgleich sieht nur Namen. — **Ausgang:**
  wird bei der Closure eingetragen (eingetreten / entfallen / weiter offen).
- **Die emittierte Zusage reicht weiter, als im Ziel geschieht** — die E2E-Stufe ist die Antwort; ist sie nicht
  fahrbar, bleibt das Risiko. — **Ausgang:** wird bei der Closure eingetragen.
- **Eine Aussage der Feldliste ändert die Feld-Bedeutung ohne Fassungs-Angabe.** — **Ausgang:** wird bei der Closure
  eingetragen.

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

Wird bei der Closure vom Planner gefüllt ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist die Sub-Area `*` (gesamtes Repo, Kürzel `ALL`, Modus
Greenfield); die Deklaration führt für `internal/span/` keine feinere — benannt, nicht gelöst.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, gemergter Stand; Zähler = Dateien unter
`evidence/`. Treffer am Gegenstand „emittierte Feldliste, Kopplung an die Spec":

- [`feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor`](../observations/BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor/observation.md)
  — 1×, offen.
- [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
  — 11×, verkörpert in `AGENTS.md` §3.6; ein weiterer Beleg ist Evidenz.
- [`span-feld-bedeutung-wechselt-ohne-fassungs-angabe`](../observations/BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe/observation.md)
  — 3×, `geplant` auf `slice-span-traegt-die-fassung-seiner-erfassungsregel` (läuft vor diesem Slice).

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
