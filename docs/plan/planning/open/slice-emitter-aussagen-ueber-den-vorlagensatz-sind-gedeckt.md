# Slice slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt: Was der Emitter über eine Vorlage entscheidet und über den Vorlagensatz behauptet, ist gedeckt und am geltenden Satz gemessen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht beobachtet keine Closure-Bedingung mehr, als diese DoD belegt.

**Bezug:**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (die
zweiklassige Ablage — der Vertrag, gegen den die Weichen des Emitters gehalten werden),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (eine Probe gilt für den
Satz, gegen den sie lief, und für keinen anderen),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Zusage, deren Operand nicht mehr existiert, behauptet eine Deckung, die niemand geprüft hat),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — die Zahlen unten wandern und sind keine Erwartungswerte),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(eine Aussage über die Baseline nennt den Tag, gegen den sie gemessen ist),
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(die Lastenheft-Änderung selbst ist ein Change Request, nicht Teil dieses Slice — §4).

**Berührte Spec-Stellen:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
— der Slice **liest** sie als Vertrag und hält den Code dagegen; geschrieben wird sie hier nicht.

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

**Ziel:** Was [`internal/emit/templates.go`](../../../../internal/emit/templates.go) über eine
Vorlage **entscheidet**, ist einer Aussage in
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) zugeordnet
und von einem Wächter in beide Richtungen gehalten; was dieselbe Datei über den **Vorlagensatz**
behauptet, ist gegen den geltenden Satz gefahren und trägt dessen Tag als Mess-Stand.

**Übernimmt:** `slice-139-lastenheft-deckt-die-emit-disposition`,
`slice-mess-aussagen-des-emitters-gegen-v680-messen`.

**Warum die zwei ein Slice sind.** Beide gehen auf dieselbe Datei und dieselbe Frage: *Deckt eine
Quelle, was hier behauptet wird?* Der eine holt die Deckung aus Rang 1, der andere aus dem Satz,
gegen den die Proben liefen. Getrennt geschnitten fassen sie
[`internal/emit/templates.go`](../../../../internal/emit/templates.go) zweimal nacheinander an, und
der zweite Lauf müsste den Wächter des ersten erneut lesen.

**Die Ausgangslage, gemessen statt geschätzt** — **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); alle vier Zahlen wandern mit ihrem Bestand:

```sh
# (a) die namentliche Aufzaehlung in Rang 1 gegen den Rumpf von isRecurring
sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
  | grep -o 'Wiederkehrende\*\* Vorlagen ([^)]*)' | grep -o ' · ' | wc -l      # 4 Trenner = 5 Glieder
awk '/^func isRecurring/,/^}/' internal/emit/templates.go \
  | grep -o '"[A-Za-z-]*\.template\.md"' | sort -u | wc -l                     # 11
# (b) die Weichen, die ueber die Emit-Disposition entscheiden
grep -cE '^func (isRecurring|isDerivativeIndex|isBrownfieldOnly)\(' internal/emit/templates.go  # 3
# (c) die Proben nennen einen Satz, den das Repo nicht mehr fuehrt
git grep -c 'v6\.7\.2' -- internal/emit/templates.go                           # 3
```

**Zu (a):** Dieselbe Menge, zwei Stände — die Aufzählung in Rang 1 ist kürzer als der Code, und
kein Wächter hält sie zusammen. **Zu (c):** Zwei der drei Stellen sind **Kommandos**, die ihren
eigenen Beleg liefern sollen; ihr Operand ist ein Vorlagenbaum unter einem Tag, den
[`harness/conventions.md`](../../../../harness/conventions.md) §Baseline nicht mehr als Stand
führt. Ein Nachfahren liefert heute einen Fehler statt der zugesagten leeren Ausgabe, und die
Zusage *„die Grenze ist heute nicht auslösbar"* ruht damit auf einer Messung gegen einen Satz, der
nicht mehr da ist. Der Block verlangt es selbst: jede Re-Baseline fährt die Proben gegen den
**neuen** Satz erneut.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Das Lastenheft wird hier nicht geschrieben.** Die Aufzählung in
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) zu
  ändern, ist eine Vertragsänderung und damit ein Change Request nach
  [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  — ein **anderer Vorgang**, und er ist Vorbedingung dieses Slice (§4).
- **Der Vorlagensatz selbst wird nicht verändert.** Er ist byte-verifiziert; die Proben lesen ihn,
  sie schreiben ihn nicht. Der **Bestand bleibt stehen**.
- **Fällt eine Probe nicht leer aus, wird die Grenz-Aussage nicht weicher formuliert.** Dann steht
  der Befund mit Fundstelle da, und der Ausgang ist ein **Folge-Slice**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.7) — nicht eine stillschweigende Umschrift in diesem.
- **Keine Änderung an der Emit-Disposition selbst.** Der Slice stellt die **Deckung** her, nicht
  eine andere Entscheidung darüber, was wiederkehrend ist — **Schicht-Abgrenzung**.

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

**Drei Liefer-Punkte**, jeder mit dem Kommando, das ihn **rot** färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Ein Wächter hält die wiederkehrende Menge aus
      [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) gegen
      den Rumpf von `emit.isRecurring` — in beide Richtungen.** Er misst die **Aufzählung**, nicht
      ihre heutige Länge: eine Zahl im Test wäre genau der Erwartungswert, den
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2 ausschließt.
      **Rot:** `make test` mit einem `test/mutations/`-Fall, der einen Namen auf **einer** der
      beiden Seiten entfernt; sein `# expect:`-Kopf nennt den fallenden Wächter.
- [ ] **(2) Jede Weiche, die über die Emit-Disposition einer Vorlage entscheidet, ist einer Aussage
      in [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
      zugeordnet** — vollständig über die Weichen, nicht über die auffälligen. Der Nenner ist das
      Kommando (b) aus §1 plus die Voreinstellung *Singleton*, keine Zahl in diesem Plan. Wo keine
      Aussage deckt, steht das als benannter Befund **mit Adressat**, nicht als Lücke.
      **Rot:** derselbe Go-Test — er fällt, sobald eine Weiche ohne zugeordnete Aussage dasteht.
- [ ] **(3) Die drei Proben sind gegen den geltenden Vorlagensatz gefahren, und die Zusage daneben
      trägt genau ihr Ergebnis.** Jede nennt den Stand, gegen den sie lief, und die Ausgabe, die
      sie lieferte — leer oder nicht; jeder Operand in den Kommentar-Kommandos löst auf
      (`[ -e ]` über den genannten Pfaden), und `git grep -c` auf den abgelösten Tag liefert `0`.
      Der genannte Stand ist der aus
      [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline, nicht ein im Plan
      eingefrorener ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
      **Rot:** `make gates` — der Lauf nennt den abgelösten Tag nicht mehr; das Gegenbeispiel ist
      der Kommentar mit dem alten Operanden, dessen Nachfahren einen Fehler liefert statt der
      zugesagten leeren Ausgabe.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: berührt ist ein Vertrag — er ist **Vorbedingung** (§4) und wird hier nicht
      geschrieben. Gegenstand dieses Slice sind Wächter und Doc-Kommentare an unexportierten
      Funktionen; weder ein `make`-Ziel noch ein Sensor-Vertrag noch eine emittierte Vorlage
      ändert sich.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
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
| [`internal/emit/templates.go`](../../../../internal/emit/templates.go) | update | die drei Proben und die Zuordnung der Weichen zu Rang-1-Aussagen |
| [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go) | neu / update | der Wächter aus DoD 1 und 2, in beide Richtungen |
| [`test/mutations/`](../../../../test/mutations) | neu | ein Fall, der einen Namen auf einer Seite entfernt |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Vorbild für die Form ist der Wächter in
  [`test/courseset-fixture.bats`](../../../../test/courseset-fixture.bats), der dieselbe Menge aus
  dem **vendored Satz** ableitet; dieser hier leitet sie aus **Rang 1** ab, und die zwei Quellen
  sind verschieden.
- Reihenfolge: zuerst (3) — die Proben zu fahren ist billig und sagt, ob der Satz überhaupt trägt
  —, danach der Wächter aus (1) und (2).

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit des Rolleninhabers ist frei, die zwei
übernommenen Slices liegen in `done/`, **und** die Aufzählung in
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ist als
Change Request entschieden — der Wächter aus DoD 1 kann eine Menge nicht gegen einen Vertrag
halten, der die Menge nicht führt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Eine Probe fällt nicht leer aus und
  verlangt eine Änderung an der Maskierung selbst. Dann ist das ein eigener Gegenstand, und dieser
  Slice behält die Deckungsfrage.
- `in-progress` → `open` (blockiert — Carveout?): Der Change Request zu
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ist beim
  Start doch nicht entschieden.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün, und `git grep -c` auf den abgelösten Tag in
   [`internal/emit/templates.go`](../../../../internal/emit/templates.go) liefert `0`.
2. Der Wächter aus DoD 1 ist mit seinem `test/mutations/`-Fall einmal rot gesehen; die gelesene
   Ausgabe der drei Proben steht im Umsetzungs-Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Change Request zu Rang 1 ist beim Start nicht entschieden.** *Absehbar:* entfallen, wenn
   der Start-Trigger aus §4 wirklich geprüft wird; sonst eingetreten mit der Rückführung nach
   `open` als Ausgang.
2. **Eine Probe fällt nicht leer aus.** *Absehbar:* entfallen, wenn alle drei leer bleiben; sonst
   eingetreten, und der Ausgang ist ein Folge-Slice mit der Fundstelle — nicht eine weichere
   Formulierung.
3. **Der Wächter misst die Länge statt der Aufzählung.** *Absehbar:* entfallen, wenn der
   Mutations-Fall einen **Namen** tauscht statt einen zu entfernen und der Wächter trotzdem fällt.
4. **Ein weiterer Baseline-Sprung fällt zwischen Plan und Lauf**, und die Proben laufen gegen den
   vorletzten Satz. *Absehbar:* entfallen, wenn DoD 3 den Stand aus
   [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline liest statt einen im
   Plan genannten.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `internal/emit/`, `test/` und
`test/mutations/` — alle in `*`. `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind nicht
berührt. Die berührte Sub-Area erfüllt das Inklusionskriterium; ausdifferenziert wird nichts.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge des Registers führen die Sub-Area
`*`; gesichtet ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die `state.md` des
Eintrags; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | 4 | geplant | DoD 3 in einem Satz |
| [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) | 28 | geplant | die Proben blieben stehen, während ihr Operand wechselte |
| [`folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md) | 7 | geplant | §6 Risiko 4 — der Ziel-Satz wird gelesen, nicht im Plan eingefroren |
| [`baseline-aussage-ohne-mess-tag`](../observations/BEO-ALL/baseline-aussage-ohne-mess-tag/observation.md) | 4 | verkörpert | DoD 3 nennt den Stand, gegen den gemessen wurde |

Keiner der vier erreicht **mit diesem Slice** erstmals 3×; ein eigener Folge-Slice entsteht daraus
nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
