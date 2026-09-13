# Slice slice-wellen-schnitt-folgt-der-eroeffnungs-regel: Die drei lebenden Träger des Wellen-Schnitts lehren die geltende Arbeitsweise

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD unten: Der
Gegenstand ist ein Text-Nachzug an drei benannten Stellen, und sein Beleg ist der `docs-check`-Lauf,
der ohnehin in jeder DoD steht (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind drei **lebende** Artefakte **dieses** Repos.
Die gleichnamige Vorlage, die das Werkzeug in ein Zielrepo schreibt
([`internal/emit/templates/commands/plan-welle.md`](../../../../internal/emit/templates/commands/plan-welle.md)),
bleibt unberührt (§1) — die zwei Ebenen tragen verschiedene Verträge und verschiedene Gründe.

**Bezug:**
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) (Festlegung 1 setzt die
Arbeitsweise; §Konsequenzen trägt die drei Planner-Folgepflichten, die dieser Slice einlöst),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Festlegung 1 — der
Anweisungssatz gehört der Rolle, die ihn ausführt; sie adressiert Liefer-Punkt 3),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Träger sagt, was gilt; eine Anleitung in ein rotes Gate sagt es nicht),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind zwei
Planungs-Artefakte und ein Rollen-Anweisungssatz).

**Verantwortlich:** `—` bis zur Priorisierung. Der Liefergegenstand ist dreimal Planner-Eigentum:
Welle-Plan und Roadmap nach Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz für eine
Welle, der Anweisungssatz nach
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1.

**Autor:** Planner. **Datum:** 2026-09-13.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Kein lebendes Artefakt dieses Repos lehrt mehr, dass eine Welle-Datei vor Eintritt ihres
Start-Triggers flach entsteht — die Arbeitsweise, die
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 beendet und die
`waves`-Fähigkeit des Moduls `planning` seither rot färbt.

### Der Lieferwert ist einer, die Träger sind drei

Alle drei sagen dieselbe Sache, und ein Nachzug an nur einem hilft nicht: Wer den Anweisungssatz
berichtigt und den Roadmap-Satz stehen lässt, folgt beim nächsten Wellen-Schnitt der Roadmap. Der
Schnitt läuft deshalb über den **Lieferwert** und nicht über die drei Dateien.

```sh
grep -c 'aktive bzw. geplante' .claude/commands/plan-welle.md                                        # 1
grep -c 'Ob eine flache Welle \*aktuell\* oder \*geplant\* ist' .claude/commands/plan-welle.md       # 1
grep -c 'aktiv/geplant' .claude/commands/plan-welle.md                                               # 1
grep -c 'geplant' .claude/commands/plan-welle.md                                                     # 4
grep -c 'Ein verlinkter Name hat eine flache Plan-Datei' docs/plan/planning/in-progress/roadmap.md   # 1
grep -c 'Ein Sensor nach \[slice-125\]' docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md  # 1
grep -c 'roadmap.md) unter \*Offene Wellen\*' docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md  # 1
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle wandern mit dem Stand; der erste Schritt der Umsetzung ist, sie neu zu fahren.

**Die vierte Fundstelle steht hier, weil ein Befund seine Fundmenge nennt und nicht nur seinen
Fundort.** [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen nennt
für den Anweisungssatz **drei** Stellen; `grep -c 'geplant'` liefert **4**. Die vierte steht im
Commit-Schritt (*„die neue Welle entsteht flach = aktiv/geplant"*) und trägt dieselbe Gleichsetzung.
Wer bei drei aufhört, lässt sie stehen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Änderung an [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
  selbst.** Die Datei steht auf `Accepted` und ist nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren; sie wird ihre Folgepflichten auf Dauer als
  fällig führen, auch wenn dieser Slice sie einlöst. *Bestand bleibt bewusst stehen.*
- **Kein Eintrag im Adaptions-Block.**
  [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 2 setzt, dass
  keiner entsteht, und der Block ist Architect-Eigentum
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). *Schicht-Abgrenzung* — beim Review sofort prüfbar.
- **Keine Eröffnung und keine Schließung einer Welle, und keine Aussage darüber, ob die drei
  offenen Wellen ihre Beginn-Bedingung erfüllen.** Das ist ein Urteil je Welle und ausdrücklich
  nicht Gegenstand der Entscheidung, die diesen Slice auslöst
  ([ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Was diese Entscheidung
  nicht tut). *Es wäre ein anderer Vorgang.*
- **Keine Änderung an der emittierten Vorlage**
  [`internal/emit/templates/commands/plan-welle.md`](../../../../internal/emit/templates/commands/plan-welle.md).
  Sie trägt dieselbe Gleichsetzung (`grep -c 'geplant' internal/emit/templates/commands/plan-welle.md`
  → **3**, kein Erwartungswert), aber auf der anderen Ebene: Was in ein Zielrepo geht, entscheidet
  ein eigener Vertrag, und die Folgepflicht der ADR nennt allein die Dogfood-Datei.
  *Es wäre ein anderer Vorgang.*
- **Kein Nachzug an [`close-welle.md`](../../../../.claude/commands/close-welle.md).** Sein Schritt 6
  lehrt eine **Beförderung** (*„die erste Zeile aus Nächste Wellen wird die neue Aktuelle Welle"*),
  die Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 6 mit *„Befördert
  wird niemand"* ausschließt, und er nennt einen Abschnitt (*Aktuelle Welle*), den die Roadmap
  dieses Repos nicht führt (`grep -c '^## Aktuelle Welle' docs/plan/planning/in-progress/roadmap.md`
  → **0**, kein Erwartungswert). Das ist eine **andere** Norm-Aussage mit einem **anderen** Alter;
  die Folgepflicht der ADR nennt drei Träger, nicht vier. *Es wäre ein anderer Vorgang.*
- **Kein Produkt-Code.** Der Slice ändert zwei Planungs-Artefakte und einen Anweisungssatz;
  `internal/`, `cmd/` und `harness/tools/` bleiben unberührt. *Schicht-Abgrenzung.*

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
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

**Drei Liefer-Punkte, einer je Träger:**

- [ ] **(1) [`welle-13`](../welle-13-regeln-bekommen-ihren-sensor.md) §1 Punkt 2 trägt keine der
      zwei überholten Aussagen mehr.** Weder die Ansage *„Ein Sensor nach `slice-125` muss diese
      Abweichung tragen"* — der Sensor **soll** sie nicht tragen — noch den Verweis, die vier
      `waves`-Befunde benennten die Abweichung, *„die die `roadmap.md` unter Offene Wellen
      erklärt"*, dessen Ziel-Erklärung seit `1be6be03` nicht mehr dasteht. Die daneben stehenden
      Messzahlen sind datierte Messungen und bleiben unangetastet
      ([ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen).
- [ ] **(2) [`roadmap.md`](../in-progress/roadmap.md) §Nächste Wellen beschreibt die Vorschau-Zeile
      so, wie [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1
      sie setzt.** Der Satz *„Ein verlinkter Name hat eine flache Plan-Datei (geschnitten,
      Start-Trigger nicht eingetreten)"* ist ersetzt, nicht ergänzt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7): Eine Kennung in der Vorschau steht unverlinkt und
      ohne Datei, und ein Gegenbeispiel färbt `docs-check` rot (`wave-preview-exists`).
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6))
- [ ] **(3) [`plan-welle.md`](../../../../.claude/commands/plan-welle.md) lehrt an **allen**
      Fundstellen die geltende Arbeitsweise** — den zwei im Kopf, der Anweisung in Schritt 9 und
      der vierten im Commit-Schritt (§1). Der Nachzug ist an der gemessenen Fundmenge geprüft, nicht
      am Fundort: `grep -c 'geplant' .claude/commands/plan-welle.md` liefert danach nur noch
      Treffer, die mit der flachen Datei nichts gleichsetzen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Liefer-Punkte (2) und (3) **sind** dieses Item — die Roadmap ist Rang 5 der
      Source Precedence und der Anweisungssatz die Anleitung, nach der gearbeitet wird.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — **hier nicht**: Dieses
      Repo fährt Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein
      Erwartungswert), also prüft sie die nächste Welle-Closure, auch für diesen Slice ohne
      Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`welle-13`](../welle-13-regeln-bekommen-ihren-sensor.md) §1 Punkt 2 | update | zwei überholte Aussagen, Messzahlen bleiben — Liefer-Punkt (1) |
| [`roadmap.md`](../in-progress/roadmap.md) §Nächste Wellen | update | der Satz über verlinkte/unverlinkte Namen — Liefer-Punkt (2) |
| [`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md) | update | Kopf (2×), Schritt 9, Commit-Schritt — Liefer-Punkt (3) |

**Kein Test-Eintrag, und das ist kein Vergessen.** Der Prüfgegenstand ist Prosa in drei lebenden
Dateien; ihr Wächter ist der Gate-Lauf über den Bestand, den sie beschreiben. Ein `*_test.go` oder
`*.bats` daneben hielte den Text gegen eine zweite Fassung seiner selbst. Was **maschinell** trägt,
ist die Gegenprobe zu Liefer-Punkt (2): eine Vorschau-Zeile mit Datei färbt `wave-preview-exists`
— gemessen in `slice-offene-wellen-liste-hat-einen-waechter`
und in [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul
`planning` als Lage 1 der Fünf-Lagen-Tabelle beschrieben.

**Reihenfolge, und sie ist nicht beliebig:** erst die Fundmenge je Träger neu messen (§1), dann
ersetzen — **ersetzen, nicht danebenstellen**
([`AGENTS.md`](../../../../AGENTS.md) §3.7). Ein Absatz, der die frühere Arbeitsweise noch einmal
referiert, um sie aufzuheben, ist die Chronik, die §3.7 aus dem lebenden Artefakt heraushält.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice**, und kein gleichzeitig
laufender Vorgang schreibt an einem der drei Träger. Beobachtbar ohne Rückfrage, auf dem
**Hauptzweig**:

```sh
ls docs/plan/planning/in-progress/ | grep -c '^slice-'                        # 0  (WIP frei; Exit 1 bei 0)
grep -rlE 'plan-welle\.md|welle-13-' docs/plan/planning/in-progress/ | grep -c .   # 0
```

**Der Trigger ist kein Ergebnis dieses Slice** — er spricht über den Bestand von `in-progress/` vor
der Arbeit. Die Annahme von
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) steht **nicht** im
Start-Trigger: Sie ist der Anlass (§1) und bereits eingetreten; ein Trigger, der eine schon wahre
Bedingung nennt, ordnet nichts.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Einer der drei Träger verlangt mehr als
  einen Text-Nachzug** — etwa weil der Roadmap-Satz nur zusammen mit einer Umstellung der
  Vorschau-Tabelle richtig wird, oder weil der Anweisungssatz seinen Schritt 9/10 neu schneiden
  muss statt ihn umzuschreiben. Dann liefert dieser Slice eine **Form-Änderung** neben dem Nachzug,
  und Form gehört vor Nachzug.
- `in-progress` → `open` (blockiert — Carveout?): **Ein Wellen-Schnitt oder eine Welle-Closure läuft
  parallel.** Beide schreiben an Roadmap und Welle-Dateien; zwei Läufe darin erzeugen einen
  Konflikt, den kein Gate meldet. Die Blockade ist dann die Parallelität, nicht die Sache.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Die sieben Mess-Kommandos aus §1 liefern für die überholten Formulierungen `0`**, und
   `make gates` meldet Exit 0 — der Nachzug ist da und der Bestand hält ihn.
2. **Der Umsetzungs-Commit trägt das Kommando, das eine Vorschau-Zeile mit Datei rot färbt, samt
   Grund-Code (`wave-preview-exists`) und Ausgabe.** Damit ist die Aussage, die Liefer-Punkt (2) in
   die Roadmap schreibt, gesehen statt hergeleitet ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

**Lerneintrag:** in der Form **geschärfte Regel** — die Arbeitsweise, die
[ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1 setzt, steht
danach an jedem Ort, an dem sie gelesen wird, statt nur an dem, an dem sie entschieden wurde.

**Ob der Eintrag daneben ein `liegt in`-Feld trägt, entscheidet die Closure und nicht dieser Plan.**
Das Feld steht nur, wenn mit diesem Slice wirklich eine Regel **verkörpert** wurde; was aus einer
ADR folgt, trägt bereits eine ID und braucht keinen zweiten Anker (Baseline-Regelwerk
`grundlagen-traceability.md` §Herkunfts-Anker, Geltungsbereich).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Der Nachzug trifft den Fundort statt die gemessene Fundmenge.** Die ADR nennt drei Stellen,
  `grep` findet vier (§1); und derselbe Satz kann in einem Träger über zwei Zeilen umgebrochen sein,
  sodass ein zeilenweises Muster ihn nicht findet — genau so liefert
  `grep -c 'unter \*Offene Wellen\* erklärt'` über `welle-13` **0**, während die Aussage dasteht.
  Das ist die gemessene Klasse
  [`BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`](../observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/observation.md).
  **Gegenmittel im Plan:** Liefer-Punkt (3) prüft gegen die Fundmenge, nicht gegen die
  Stellen-Aufzählung der ADR.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(2) Der Nachzug stellt die alte Arbeitsweise daneben, statt sie zu ersetzen.** Ein Absatz
  *„bis [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) entstand die Datei
  früher …"* ist Chronik im lebenden Artefakt; jede weitere Runde verlängert ihn, und der nächste
  Lauf liest zwei Arbeitsweisen nebeneinander. **Dafür trägt keine Regel dieses Repos:**
  [`AGENTS.md`](../../../../AGENTS.md) §3.7 nennt als Geltungsbereich Code, Konfiguration, Skripte
  und die Zustandsfelder der lebenden Register — Markdown-Fließtext steht in keinem davon, und
  [`make comment-claims`](../../../../harness/sensors/comment-claims.md) nimmt jede Markdown-Datei
  dauerhaft aus.
  **Gegenmittel im Plan:** §3 macht *ersetzen statt danebenstellen* zur Reihenfolge-Regel; ein
  Wächter steht dahinter nicht, und dieser Plan behauptet keinen.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(3) [`welle-13`](../welle-13-regeln-bekommen-ihren-sensor.md) ist eine offene Welle-Datei, und
  ihr §1 trägt datierte Messungen neben der überholten Aussage.** Wer beim Nachziehen eine Messzahl
  mitkorrigiert, schreibt eine Messung um, die zu ihrem Datum richtig war
  ([`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  zieht dieselbe Linie für Werkzeug-Aussagen). Die ADR sagt es ausdrücklich: *„Die dort
  danebenstehenden Messzahlen sind datierte Messungen und kein Arbeitsauftrag."*
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(4) Der Roadmap-Satz beschreibt einen Zustand, den der Bestand heute gar nicht zeigt.** Unter
  *Nächste Wellen* steht derzeit kein verlinkter Name
  (`sed -n '/^## Nächste Wellen/,/^## /p' docs/plan/planning/in-progress/roadmap.md | grep -c '^| \[welle-'`
  → **0**, kein Erwartungswert). Eine Ersetzung, die nur den Satz tauscht und kein Gegenbeispiel
  fährt, ist über der leeren Menge wahr — die Klasse
  [`BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md).
  **Gegenmittel im Plan:** Closure-Kriterium 2 verlangt das rot gesehene Gegenbeispiel.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes der vier mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo,
Kürzel `ALL`), deklariert in [`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigene Regeln
([`AGENTS.md`](../../../../AGENTS.md) §3.7 für das Ersetzen statt Danebenstellen,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
für die Messzahlen), eigener Prüfbereich
([`make docs-check`](../../../../harness/sensors/docs-check.md) über dem gesamten Doku-Bestand) und
eigene Fehlermodi (eine Anleitung, die in ein rotes Gate führt). **`TOOLS` ist geprüft und nicht
berührt:** Keine Aussage über `harness/tools/` ändert sich. **`CODEX` ebenso wenig** — `.codex/`
führt allein den SessionStart-Injektor; die drei Anweisungssätze liegen unter `.claude/commands/`.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen —
**104** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**,
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2: ein Zähler-Stand ist eine datierte Messung); alle führen dieselbe Sub-Area `*`, die
Sichtung ist damit vollständig. **Vier Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| `zusage-neben-geaenderter-ableitung-bleibt-stehen` | 24× | geplant (`slice-153`) | §1 — die drei Träger **sind** diese Klasse, einmal in groß |
| `korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` | 6× | offen | §6 Risiko 1 — drei genannte Stellen, vier gemessene |
| `zusicherung-ueber-der-leeren-menge-wahr` | 2× | offen | §6 Risiko 4 — die Vorschau-Tabelle trägt heute keinen verlinkten Namen |

```sh
for s in zusage-neben-geaenderter-ableitung-bleibt-stehen \
         korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge \
         zusicherung-ueber-der-leeren-menge-wahr; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Keiner der drei erreicht mit diesem Slice 3×** — alle drei standen **vor** ihm dort, zwei über und
einer unter der Schwelle. **Ein eigener Folge-Slice entsteht aus der Sichtung also nicht.**

**Für §6 Risiko 2 führt das Register keine passende Kennung**, und das ist die Antwort und keine
Auslassung: Die nächstliegende Klasse
[`BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
(**8×**, `offen`,
`ls docs/plan/planning/observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/evidence/*.md | wc -l`)
spricht über Kommentare in Code, Konfiguration und Skripten — den Geltungsbereich von
[`AGENTS.md`](../../../../AGENTS.md) §3.7 —, nicht über Markdown-Fließtext. Ob der Fall unter eine
vorhandene fällt oder eine neue braucht, entscheidet die Closure dieses Slice, falls er eintritt.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — was ein lebendes Artefakt tragen darf und was in `git` gehört,
  steht in [`AGENTS.md`](../../../../AGENTS.md) §3.7; dass eine Adresse in einem eingefrorenen
  Artefakt bei ihrer Kennung genannt wird, in §3.11; die Zahl-Disziplin in
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
  Der Gegenstand selbst — eine Norm-Entscheidung in die lebenden Träger ziehen — ist mit
  [slice-224](../done/slice-224-delta-nachweis-und-planungs-nachzug.md) schon einmal denselben Weg
  gegangen.
- **Phase-Reife:** Phase 4 für die Planungs-Doku — der Lifecycle ist bewacht
  (`grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l` → **8**, kein Erwartungswert; das
  Modul `planning` trägt Marker- und Listen-Hälfte), und die Grenzen stehen in
  [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md). Was zu Phase 5
  fehlt, ist genau dieser Slice: ein Träger, der die bewachte Regel auch **lehrt**.
- **Evidenz-/Diskrepanz-Risiko:** **mittel**. Die tragende Diskrepanz ist nicht Doku gegen Code,
  sondern **Anleitung gegen Gate**: Drei lebende Träger führen in einen Zustand, den `docs-check`
  seit der Aktivierung der `waves`-Fähigkeit rot meldet. Der Befund ist benannt und nicht latent —
  [ADR-0046](../../adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen führt ihn als
  *„ein Zustand mit zwei Lesarten, und er gehört kurz gehalten"*. Die Inventur, die ihn schließt,
  sind die sieben Mess-Kommandos aus §1.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund im Sinne des
  Reconciliation-Registers; die Datei `reconciliation.md` existiert in diesem Repo nicht
  (`ls docs/plan/planning/reconciliation.md` → Exit 2), und das zugehörige DoD-Item entfällt
  deshalb in §2. Graduation entfällt (n/a bei GF). Der Trigger, der die Achse auf Phase 5 höbe, ist
  ein Wächter, der Anweisungssatz und Gate-Verhalten gegeneinander hält; einen solchen gibt es
  nicht, und dieser Slice behauptet ihn nicht.
