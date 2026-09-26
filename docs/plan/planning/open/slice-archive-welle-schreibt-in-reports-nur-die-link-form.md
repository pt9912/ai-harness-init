# Slice slice-archive-welle-schreibt-in-reports-nur-die-link-form: `archive-welle` schreibt beim Nachzug in `docs/reviews/` nur die Adresse hinter `](`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — dieser Slice trägt keine Closure-Bedingung, die über seine
DoD hinaus etwas beobachtet, siehe Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht (Modul 6).

**Bezug:** [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
(`Accepted`; Festlegung 1 und Folgepflicht 1),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (Festlegung 1, an einer Stelle geschnitten durch die erste ADR dieser Liste),
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (der zweite Träger des Nachzugs),
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der Prüfbereich des Doku-Gates bleibt, wie er ist).

**Berührte Spec-Stellen:** `—` — Prozess-ADR ohne Spec-Stratum: sie ändert die
Reichweite eines Werkzeugs, keine Spec-Aussage und keine Gate-Schwelle.
Der Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP), `grundlagen-source-precedence.md` §ID-Schema als Klammer).

**Verantwortlich:** `—` bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-26.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Nachzug von `archive-welle` (`internal/archive`) ersetzt in einer Datei unter
`docs/reviews/` die Adresse nur dort, wo sie unmittelbar hinter `](` steht; jede andere
Pfad-Adresse in dieser Datei bleibt Byte für Byte, und in den übrigen Bäumen ersetzt er wie bisher
jede Form
([`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
Festlegung 1). Die Erkennung ist syntaktisch, keine Span- oder Fence-Erkennung.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Nachzug von `make slice-mv` (Shell)** — ein Folge-Slice übernimmt ihn:
  `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form`. Zweite Sprache, eigene Test-Ebene;
  keiner der beiden Träger wartet auf den anderen, und beide zusammen sprengten das Größenmaß
  (§3, Größenurteil). Der Shell-Träger liegt in `done/`; bis dieser Slice schließt, gilt der Übergang aus
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  Festlegung 5.
- **Der Kopplungs-Test gegen `.d-check.yml`** — ein Folge-Slice übernimmt ihn:
  `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt`. Er hält eine
  Config-Zeile, keinen Träger, und folgt nach beiden Trägern.
- **Der Hänger-Wächter und seine Ausnahmeliste** — der `Suchraum` des Wächters liest
  `docs/reviews/**` vollständig, und die Liste `AusgenommenePfadeNachzug` in
  `internal/archive/scan.go` behält ihre Einträge; `docs/reviews/**` wird **keiner**. Das
  Abnahme-Kriterium 1 von
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) regelt den Suchraum des
  Wächters und gilt unverändert; der Nachzug ist ein anderer Zweig desselben Trägers.
- **Kontext-Erkennung im Träger (Span-Grenzen, Fence-Zustand)** — Alternative D″ ist in
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  abgelehnt; das Link-Zitat im Code-Span wird mitersetzt, Trigger 6 der ADR hält, wann das neu zu
  bewerten ist.
- **Das Zitat im Code-Block und die Referenz-Definition `[name]: ziel`** — benannte Lücken der ADR
  (Trigger 6 und 7): der Bestand ist leer, und eine Zusage ohne rot gesehenes Gegenbeispiel wäre
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 verletzt.
- **Der Nachzug in den übrigen Bäumen** (`docs/plan/planning/done/`, `docs/plan/carveouts/done/`, das
  eingefrorene Glied des Beobachtungs-Registers) — bleibt in jeder Form
  ([`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  Festlegung 1 und 3).
- **`.d-check.yml`** — unberührt; es entsteht keine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5.
- **Bestand in Reports** — was frühere Nachzüge dort umgeschrieben haben, bleibt: Zeitdokument, und
  ein Nachziehen wäre ein eigener Vorgang.

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

- [ ] **Liefer-Punkt 1 — die Form-Regel im Träger.** Der Nachzug in `internal/archive` (die Ersetzung
      in `internal/archive/refs.go`) ersetzt in einer Datei unter `docs/reviews/` die Adresse nur
      hinter `](` (bis `)` oder `#`); jede andere Pfad-Adresse dort bleibt Byte für Byte. Die
      Zähl-Seite (`Fund` und die Vorschau) und die Ersetz-Seite folgen derselben Regel. *Bricht,
      wenn:* die Form-Regel entfällt (die Adresse in Span, Operand, Block oder Fließtext ist
      umgeschrieben — Politik A der ADR), oder der Link-Nachzug dort entfällt (der Link ist tot —
      Politik B, an einem Move `+2` `target-missing` gemessen), oder der Träger nur den
      unmittelbaren Backtick-Kontext ausnimmt (er besteht den reinen Span-Fall und bricht Operand,
      Block und Fließtext).
- [ ] **Liefer-Punkt 2 — die Tests, die sie halten.** Ein Go-Test in `internal/archive`: (a) **eine**
      Datei unter `docs/reviews/` trägt einen Link auf die bewegte Datei und vier Nicht-Link-Formen
      (reiner Pfad-Span, Operand in einem Kommando-Span, Pfad im Code-Block, Pfad im Fließtext):
      der Link ist nachgezogen, die vier Formen sind Byte für Byte gleich. (b) Link-Syntax als
      Zitat in einem Code-Span wird mitersetzt — die Grenze ist gemessen. (c) In einer Datei unter
      `docs/plan/planning/done/` werden Link, reiner Pfad-Span und Operand weiter ersetzt. (d) Ein
      Mutations-Fall in `test/mutations/` färbt bei **beiden** Mutationen (Form-Regel entfällt ·
      Link-Nachzug entfällt) je einen Fall rot und bindet beide Hälften einer Datei. *Bricht, wenn:*
      (a) ein Fall nur den reinen Span führt — der Regex-Träger, der nur den unmittelbaren
      Backtick-Kontext ausnimmt, bliebe grün; (b) ein Träger eine Kontext-Erkennung bekommt — der
      Fall fällt, und das ist Re-Evaluierungs-Trigger 6 der ADR, keine Umkehrung des Falls; (c) die
      Form-Regel auf einen zweiten Baum ausgedehnt wird; (d) ein Fall nur eine Hälfte bindet. Jedes
      dieser Rot ist einmal gesehen und in seiner Meldung gelesen
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **Liefer-Punkt 3 — die Sensor-Doku.** `harness/sensors/archive-welle.md` nennt die Form-Regel
      in seiner Grenze, samt der zwei benannten Lücken (Code-Block-Zitat, Referenz-Definition).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
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
| `internal/archive/refs.go` | update | Liefer-Punkt 1: Regel und Pfad-Zweig für Dateien unter `docs/reviews/`; Zähl- und Ersetz-Seite gleichlaufend |
| `internal/archive/refs_test.go` | update | Liefer-Punkt 2 (a)–(c): Fälle nach den Fitness-Zeilen 1, 2 und 5 der ADR |
| `test/mutations/` | neu | Liefer-Punkt 2 (d): ein Fall, der beide Hälften einer Datei bindet; Anker gegen den Quell-Bestand gemessen ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)) |
| `harness/sensors/archive-welle.md` | update | Liefer-Punkt 3: Grenze |

- **Größenurteil.** Drei Liefer-Punkte, zwei Schichten (Go-Werkzeug samt Tests, und die Doku dazu).
  Der Träger ist ein eigener Slice, weil er mit dem Shell-Träger keine Sprache, keine Test-Ebene und
  keinen Mutations-Fall teilt; die Begründung des Schnitts steht ausgeführt im Geschwister
  `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form`, §3.
- **Ansatz.** Je Träger eine Regel mit dem Anker `](` und ein Pfad-Zweig für Dateien unter
  `docs/reviews/`, keine Kontext-Erkennung. Nach Lektüre von `internal/archive/refs.go` sind die
  geschwister-relative und die aufsteigende Form (`ZaehleGeschwister`, `ZaehleAufsteigend`) heute
  schon an `](` verankert; die Präfix-Form (`ZaehlePraefix`) ist es nicht — das ist die Stelle, an
  der die Regel greift. Das ist Lektüre, nicht gebaut; der Implementer bestätigt es an der
  Ersetz-Seite.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): der Slice ist priorisiert und sein Rolleninhaber gesetzt. Keine
Abhängigkeit von den zwei Geschwistern: `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form`
und der Kopplungs-Slice laufen unabhängig.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Zähl- und Ersetz-Seite lassen sich nicht
  ohne einen Umbau von `VerweisFund` angleichen, der über die Regel hinausgeht; oder der Umbau
  verlangt eine Kontext-Erkennung (dann ist es Alternative D″, und die ADR ist neu zu bewerten).
- `in-progress` → `open` (blockiert): `codepaths.exempt-paths` nimmt `docs/reviews/**` nicht mehr
  aus (Re-Evaluierungs-Trigger 1 der ADR) — die Regel ist dann zu streichen, der Slice ist
  gegenstandslos und geht als Stilllegung nach `done/`; oder eine Folge-ADR ersetzt
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  vor der Closure.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Die Tests aus Liefer-Punkt 2 laufen in `make gates` grün, und die Rot-Belege der DoD sind je
   einmal gesehen; wo der Implementer-Bericht einen nicht führt, trägt der Verifier ihn nach
   (Baseline-Regelwerk `modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen).
2. In einer Kopie von `git archive` außerhalb des Repos meldet `make docs-check` nach einem Nachzug
   mit einem Report-Link und einem Report-Span-Verweis keinen `target-missing` mehr als vor ihm
   (Politik D der ADR; das Rezept steht im Architect-Verdikt
   `2026-09-26-architect-verdikt-slice-mv-und-eingefrorene-adressen`).

Der Lerneintrag steht in §7 in einer der drei Formen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Die Ausgänge stehen als Vorschau da; gesetzt werden sie bei der Closure.

- **Der Anker des neuen Mutations-Falls liegt verschoben** — das Muster trifft die Fassung der
  letzten Lektüre, nicht den Quell-Bestand
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
  **Ausgang:** *entfallen*, wenn der Anker gegen `internal/archive/refs.go` am Stand der
  Implementation gemessen und der Fall an genau der behaupteten Mutation rot gesehen ist; sonst
  *eingetreten* und im Slice behoben.
- **Ein Regex-Träger besteht alle Fälle und bricht die Byte-Gleich-Zusage** — er nimmt nur den
  unmittelbaren Backtick-Kontext aus (Fitness-Zeile 1 der ADR, Gegenbeispiel). Der Fall mit vier
  Nicht-Link-Formen in **einer** Datei ist der Wächter dagegen. **Ausgang:** *entfallen*, wenn die
  Gegenprobe (Träger mit nur dem Backtick-Kontext) den Fall rot färbt; sonst *eingetreten*: der Fall
  wird im Slice nachgeschärft.
- **Zähl- und Ersetz-Seite laufen auseinander** — zählt `ZaehlePraefix` in `docs/reviews/` weiter den
  Pfad-Span, meldet die Vorschau Verweise, die der Nachzug nicht mehr schreibt. **Ausgang:**
  *entfallen*, wenn ein Test beide Seiten über derselben Datei vergleicht; sonst *eingetreten* und
  im Slice behoben.
- **Das Link-Zitat im Code-Span wird mitersetzt** — die Grenze der ADR, im Bestand inert (Kommando in
  der ADR). **Ausgang:** *weiter offen* als benannte Grenze in der Sensor-Doku; Träger ist Trigger 6
  der ADR, kein Register-Eintrag, solange kein Nachzug eine solche Zeile umschreibt.

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

Wird bei der Closure vom Planner geschrieben
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht vom Implementer; die Zeilen folgen der Vorlage.

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo), so, wie die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) sie
führt; eine neue oder gröbere Sub-Area entsteht nicht. Die Schwelle von 2 aus 3 Achsen ist an
diesem Eintrag nicht neu gemessen.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen; drei Einträge tragen
den Gegenstand dieses Slice (Nachzug schreibt in ein eingefrorenes Artefakt). Der Zähler ist die
Zahl der Dateien unter dem `evidence/` des Eintrags (Stand 2026-09-26; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):

```sh
for d in docs/plan/planning/observations/BEO-ALL/verweis-nachzug-*/; do echo "$(ls "$d"evidence/*.md | wc -l) $d"; done
# 2 …/verweis-nachzug-bricht-tree-operand/
# 6 …/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/
# 14 …/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/
```

[`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
und
[`verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`](../observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/observation.md)
stehen über der Schwelle und sind `verkörpert` (Zielort:
[`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) neben
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)); mit diesem Slice tritt
keiner erstmals über 3×. [`verweis-nachzug-bricht-tree-operand`](../observations/BEO-ALL/verweis-nachzug-bricht-tree-operand/observation.md)
steht unter der Schwelle: Ein Tree-Operand `<sha>:<pfad>` steht nicht hinter `](` und bliebe in
`docs/reviews/` damit Byte für Byte — abgeleitet aus der Form-Regel, nicht gemessen. Trifft der
Vorgang dieses Slice eine der Klassen, legt die Closure den Beleg an.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF.
