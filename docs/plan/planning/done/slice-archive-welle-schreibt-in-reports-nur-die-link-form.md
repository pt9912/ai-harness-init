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

**Verantwortlich:** Implementer (pt9912).

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

- [x] **Liefer-Punkt 1 — die Form-Regel im Träger.** Der Nachzug in `internal/archive` (die Ersetzung
      in `internal/archive/refs.go`) ersetzt in einer Datei unter `docs/reviews/` die Adresse nur
      hinter `](` (bis `)` oder `#`); jede andere Pfad-Adresse dort bleibt Byte für Byte. Die
      Zähl-Seite (`Fund` und die Vorschau) und die Ersetz-Seite folgen derselben Regel. *Bricht,
      wenn:* die Form-Regel entfällt (die Adresse in Span, Operand, Block oder Fließtext ist
      umgeschrieben — Politik A der ADR), oder der Link-Nachzug dort entfällt (der Link ist tot —
      Politik B, an einem Move `+2` `target-missing` gemessen), oder der Träger nur den
      unmittelbaren Backtick-Kontext ausnimmt (er besteht den reinen Span-Fall und bricht Operand,
      Block und Fließtext).
- [x] **Liefer-Punkt 2 — die Tests, die sie halten.** Ein Go-Test in `internal/archive`: (a) **eine**
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
- [x] **Liefer-Punkt 3 — die Sensor-Doku.** `harness/sensors/archive-welle.md` nennt die Form-Regel
      in seiner Grenze, samt der zwei benannten Lücken (Code-Block-Zitat, Referenz-Definition).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
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

**Adress-Messung vor dem Move** ([`AGENTS.md`](../../../../AGENTS.md) §3.11): kein eingefrorenes
Artefakt nennt diese Datei als Pfad, weder mit `open/` als Code-Span noch als Markdown-Link; die
Geschwister und das Register nennen sie bei der Kennung
(`grep -rnI --exclude-dir=.git --exclude-dir=.harness -E 'slice-archive-welle-schreibt-in-reports-nur-die-link-form\.md|(open|next|in-progress|done)/slice-archive-welle-schreibt-in-reports-nur-die-link-form|\]\(slice-archive-welle-schreibt-in-reports-nur-die-link-form' . | grep -v 'planning/done/slice-archive-welle-schreibt-in-reports-nur-die-link-form.md' | wc -l`
→ **1**, gemessen 2026-09-26). Der eine Treffer ist ein Falsch-Treffer des ersten Zweigs: der Dateiname
als Muster eines Zähl-Kommandos in der Closure-Notiz des Geschwisters
`slice-lifecycle-move-schreibt-in-reports-nur-die-link-form` (`done/`), ohne Verzeichnis-Präfix und
kein Verweis; der Lifecycle-Zweig allein (Präfix und Link) gibt **0**. Der Move hat damit keinen
Verweis nachzuziehen.

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

Jedes Risiko trägt seinen Ausgang; die Belege stehen in §7 (Zeile *Risiken aus §6*).

- **Der Anker des neuen Mutations-Falls liegt verschoben** — das Muster trifft die Fassung der
  letzten Lektüre, nicht den Quell-Bestand
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
  **Ausgang:** *entfallen* — jeder Anker der Fälle 467 bis 473 trifft am Stand der Verifikation genau
  eine Stelle in `internal/archive/refs.go`, und jeder Fall färbt an der behaupteten Mutation rot.
- **Ein Regex-Träger besteht alle Fälle und bricht die Byte-Gleich-Zusage** — er nimmt nur den
  unmittelbaren Backtick-Kontext aus (Fitness-Zeile 1 der ADR, Gegenbeispiel). Der Fall mit vier
  Nicht-Link-Formen in **einer** Datei ist der Wächter dagegen. **Ausgang:** *entfallen* — die
  Gegenprobe (Träger mit nur dem Backtick-Kontext) färbt den Fall in Review und Verifikation je rot.
- **Zähl- und Ersetz-Seite laufen auseinander** — zählt `ZaehlePraefix` in `docs/reviews/` weiter den
  Pfad-Span, meldet die Vorschau Verweise, die der Nachzug nicht mehr schreibt. **Ausgang:**
  *entfallen* — ein Test vergleicht beide Seiten über derselben Datei gegen ein Literal, und Fall 470
  färbt rot.
- **Das Link-Zitat im Code-Span wird mitersetzt** — die Grenze der ADR, im Bestand inert (Kommando in
  der ADR). **Ausgang:** *weiter offen* — Register-Eintrag
  [`link-zitat-im-code-span-wird-vom-nachzug-mitersetzt`](../observations/BEO-ALL/link-zitat-im-code-span-wird-vom-nachzug-mitersetzt/observation.md);
  Träger der Neu-Bewertung ist Trigger 6 der ADR, benannt in der Sensor-Doku.

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

Geschrieben von der Rolle Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nach Review und
Verifikation. Alle Kommandos gemessen am 2026-09-26 am Stand `f982adb8`, keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

- **Was hat funktioniert:** Der Schnitt hielt: drei Liefer-Punkte, zwei Schichten, keine der beiden Rückführungen
  aus §4 ausgelöst. Der Verifier (Stand `335edffe`) bestätigte Liefer-Punkt 1 und 2. Die Fälle `467` bis `473` färben
  je den benannten Test aus dem behaupteten Grund rot; in der Gegenprobe (Zusicherung im benannten Test entfernt,
  Mutation aktiv) wurden `469`, `471`, `472` und `473` grün, die Zusicherungen binden also; beide Einzel-Klassen-Mutanten
  von `472` (nur die erste, nur die zweite Zeichenklasse ohne `\n`) sind rot; ein Träger, der nur den unmittelbaren
  Backtick-Kontext ausnimmt, färbt den Fall mit **einer** Datei und vier Nicht-Link-Formen rot (Review am Stand `5d7a1de2`
  und Verifier je gefahren). Closure-Trigger 2 in einer Kopie von `git archive` außerhalb des Repos: in `docs/reviews/`
  29 geänderte Zeilenpaare, 0 Abweichungen außerhalb der Link-Ziele, kein neues `target-missing`. **Ergebnis-Fakten:**
  `ls test/mutations/*.sh | wc -l` → **461**;
  `git diff --shortstat 2427de2b..f982adb8 -- internal test harness/sensors` → **10** Dateien, **538** Einfügungen,
  **12** Löschungen.
- **Was ging anders als geplant:** Der Review (Runde 1, Stand `5d7a1de2`; 0 HIGH, 1 MEDIUM, 2 LOW, 3 INFO) fand R-1: die
  Zeilengrenze der Link-Regel ist im Doc-Kommentar zugesagt und von keinem Test gehalten (`\n` aus beiden Zeichenklassen:
  Suite grün); R-2 dieselbe Klasse für die Verzeichnisgrenze; R-3 den Rang-Zeiger im Kopf von `VerweisFund`; R-6 den
  Schreibfehler als Ausgang zwischen den zwei Commits, in der Sensor-Doku nicht genannt. Der Implementer zog sie in
  `fc638444` (zwei Go-Tests, Kommentare), `a038a349` (Fälle `472`, `473`) und `335edffe` (Sensor-Doku). **Gebaut, nicht
  geplant:** sieben Fälle statt *eines* Falls (§3: `467` und `468` sind der geplante, `469` bis `473` sind Zähne für
  Zusagen der Kommentare), sieben Tests statt drei, in der Sensor-Doku der Vertragssatz im Kopf und der Schreibfehler als
  Ausgang. Der Verifier wertete das als größer als geplant, nicht außerhalb des Gegenstands, **und der Planner schließt
  sich an.** **Wer was gelesen hat:** der Review las bis `5d7a1de2`; `fc638444`, `a038a349` und `335edffe` hat nur der
  Verifier gelesen und gefahren; `f982adb8` (eine Zeile der Sensor-Doku, die Rückweg-Kommandozeile zu V-1) hat **weder ein
  Reviewer noch der Verifier** gelesen — der Planner las den Diff und fuhr `make gates` (Exit 0) über diesen Stand. Eine
  Nachrunde ist nicht gelaufen und wird nicht behauptet; das Häkchen *Review durchgeführt* bestätigt Runde 1 samt gezogenen
  Findings. **Liefer-Punkt 3 trägt mit Vorbehalt:** der Verifier fand V-1 (die Doku nannte `git clean -fd -- done/<welle-id>`,
  aus der Repo-Wurzel kein Pfad); die Zeile ist nachgezogen, aber der Doku-Text ist an **keinen** Test gebunden — der Test
  des Fehlerpfads prüft nur die `git reset`-Hälfte (Register, unten).
- **Mutate: Teilmessung, keine Gesamtaussage.** Real gefahren ist
  `make mutate MUTATE_JOBS=1 MUTATE_CASES='240 467 468 469 470 471 472 473'` (Verifier, Stand `335edffe`, die vollen
  Fall-Namen): `8 ok, 0 Befund(e)`, `TEILLAUF 8 von 461 — kein Beleg`; der Beleg-Slot `.harness/state/mutate-passed.key`
  war vorher wie nachher nicht vorhanden. **Nicht gefahren:** ein voller `make mutate`; der Beleg-Slot von
  [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) ist nicht geschrieben. Eine Aussage
  über das grüne Ganze trägt diese Closure nicht.
- **Nicht gemessen:** der Schreibfehler-Pfad des Nachzugs (`os.WriteFile` bricht ab, die Datei kann halbgeschrieben
  bleiben): gelesen, von Review, Verifier und Planner nicht gefahren — das Testbild läuft als root, ein Dateimodus löst dort
  keinen Fehler aus; die Sensor-Doku sagt es mit diesem Grund, und der Ausgang mit verletzter Stub-Form ist gefahren
  (`TestAnwendenBrichtBeiVerletzterStubFormAb`). Die Maskierung `QuoteMeta(base)` in der Link-Regel trägt **keinen** Zahn
  (Schwächung grün im Review; der Verifier fuhr sie nicht), für die Namen dieses Repos ohne Wirkung. Die Meldungen der
  Fälle `469` und `470` hat der Verifier nicht selbst gelesen (Treiber-Urteil rot mit dem erwarteten Test); der Review las
  sie. Die Wirkung eines Ziels hinter dem Zeilenumbruch auf `make docs-check` ist nicht gefahren. **Die Politik-D-Messung
  lief nur in einer Kopie mit hergestellten Vorbedingungen:** `archive-welle` auf `welle-11-traeger-aussage` ist auf dem
  Repo-Stand gesperrt (Hänger-Wächter, Exit 3; die Sensor-Doku nennt das selbst); die Kopie bog 56 Verweise um, legte den
  Welle-Plan nach `done/`, kopierte eine Ergebnisnotiz und legte ein `archiv.zip` an, danach schrieb der Lauf zwei Commits.
  Das ist nicht der Vorgang, den die Sensor-Doku für dieses Repo freigibt. Im Gesamtlauf der Kopie stand außerdem ein neues
  `target-missing` in einer `Accepted`-ADR (kein Nachzug dort,
  [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2). **Closure-Trigger 2 ist damit
  bestätigt mit Vorbehalt:** er gilt für den Baum `docs/reviews/`, nicht für den Gesamtlauf und nicht am Repo-Stand.
- **Steering-Loop-Eintrag (Form: neuer Sensor).** Der Träger `archive-welle` führt die Form-Regel, und sie ist gemessen
  statt behauptet: die Go-Tests `TestNachziehenUnterReviewsSchreibtNurDieLinkForm`,
  `TestNachziehenUnterReviewsSchreibtEineDateiOhneLinkNicht`, `TestNachziehenUnterReviewsErsetztLinkSyntaxImCodeSpanMit`,
  `TestNachziehenInDoneErsetztJedeForm`, `TestPraefixLinkAnDerWortgrenze`,
  `TestNachziehenUnterReviewsUeberquertKeineZeilengrenze` und
  `TestNachziehenUnterReviewsGiltNurFuerDasVerzeichnisNichtFuerSeinenPraefix` in `internal/archive/refs_test.go`, und die
  Mutations-Fälle `467` bis `473`, von denen `467`/`468` je eine Hälfte einer Datei binden, `469` den zweiten Baum, `470`
  die Zähl-Seite, `471` die Link-Grenze, `472` die Zeilengrenze, `473` die Verzeichnisgrenze. **Kein Zielort-Feld und
  kein Herkunfts-Anker:** die Regel ist eine Setzung von
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) (`Accepted`) und trägt
  ihre eigene Kennung; die Paarung (a) hätte nichts, gegen das sie prüft. **Grenzen des Sensors, benannt:** das Zitat im
  Code-Block ist ungebunden (Trigger 6 der ADR); das Link-Zitat im Code-Span bindet der Test als *„wird mitersetzt"*; die
  Referenz-Definition meldet kein Gate (Trigger 7 hängt an einem `git grep`); Klammern im Ziel und ein Ziel hinter dem
  Zeilenumbruch nennt die Sensor-Doku nicht; der Schreibfehler-Pfad ist ungefahren; die Maskierung des Namens ist ohne
  Zahn; ein Kopplungs-Test gegen `.d-check.yml` führt dieses Werkzeug noch nicht (der dritte Slice der Liste, `open/`).
  **Der Übergang aus [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  Festlegung 5 endet mit dieser Closure:** beide Träger führen die Form-Regel (`make slice-mv` seit
  `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form`, `archive-welle` mit diesem Slice); ein Norm-Text ändert
  daran nichts, und eine ADR-Änderung ist nicht nötig ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Die Zustandsaussagen,
  die den Übergang als laufend nennen, zieht der Planner nach dem Move nach (Register-Zustände und Kopplungs-Slice).
- **Beobachtungs-Register (`../observations/`):** je Beleg `evidence/slice-archive-welle-schreibt-in-reports-nur-die-link-form.md`;
  Zähler gelesen mit `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  **Neu angelegt (1×, `offen`):**
  [`zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel`](../observations/BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/observation.md)
  (R-1, R-2, R-5 Teil b — ein Vorgang zählt einmal),
  [`kommentar-begruendet-die-gemeinsame-liste-nur-fuer-einen-ihrer-leser`](../observations/BEO-ALL/kommentar-begruendet-die-gemeinsame-liste-nur-fuer-einen-ihrer-leser/observation.md)
  (R-4) und
  [`nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung`](../observations/BEO-ALL/nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung/observation.md)
  (V-3, V-4). **Neu angelegt mit zwei Belegen (2×, `offen`):**
  [`regel-rand-ohne-benannte-luecke`](../observations/BEO-ALL/regel-rand-ohne-benannte-luecke/observation.md)
  (R-5 Teil a und V-5 hier; dazu ein Beleg für den Shell-Träger `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form`,
  dessen Review sie als R-2 führte — seine Closure trug den Fund nicht ein, er ist hier nachgetragen) und
  [`link-zitat-im-code-span-wird-vom-nachzug-mitersetzt`](../observations/BEO-ALL/link-zitat-im-code-span-wird-vom-nachzug-mitersetzt/observation.md)
  (der Ausgang *weiter offen* des Risikos 4, hier und beim Shell-Träger — auch dort nachgetragen).
  **Ergänzt:**
  [`zitierte-ausgabe-weicht-vom-literal-ab`](../observations/BEO-ALL/zitierte-ausgabe-weicht-vom-literal-ab/observation.md)
  (**2×**, `offen`; V-1) und
  [`eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  (**12×**, Stand `geplant` unverändert; der Vorgang ist der Claim-Commit `cc5de0d9`, der den Ruhe-Marker der Roadmap
  entfernte; der Planner stellt ihn mit dieser Closure wieder her).
  **Dieselbe Beobachtung? — je Kandidat begründet, Urteil des Planners.** *V-1* in `zitierte-ausgabe-…`: die Doku zitiert
  eine Kommandozeile, die das Werkzeug ausgibt, und weicht vom Literal ab — dort ist es eine Meldung; wer sie stattdessen
  in
  [`prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
  (**3×**, `verkörpert`) einordnet, lässt `zitierte-ausgabe-…` bei 1×. *R-1* nicht in
  [`zeichenmenge-mitglied-ohne-eigenen-zahn`](../observations/BEO-ALL/zeichenmenge-mitglied-ohne-eigenen-zahn/observation.md)
  (1×) und nicht in
  [`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  (4×, `verkörpert` für die Klasse): die Begründung steht in der neuen Beobachtung unter *Benannt, nicht gezählt*; wer
  R-1 der ersten zuordnet, hebt sie auf 2×. *R-4* nicht in
  [`ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md)
  (4×, `geplant`): dort geht es um die Berechtigung eines Eintrags, hier um den Grund für den zweiten Leser. **Nicht
  eingetragen, mit Grund:** R-3 (Rang-Zeiger im Kopf von `VerweisFund`) und R-6 (Schreibfehler nicht in der Sensor-Doku)
  sind im Vorgang behoben, der Review nennt zu keinem eine frühere Instanz; V-2 (Modus der Fall-Dateien) ist INFO ohne
  Befund. Der Shell-Träger trug außerdem R-3 (*Regel-Ausprägung ohne Fall*, INFO) — keine Instanz der neuen Beobachtung,
  weil kein Kommentar etwas zusagt; seine Closure hat sie nicht eingetragen, und diese trägt sie nicht nach.
  **Lese-Schritt:** mit diesem Slice erreicht **kein** Eintrag erstmals die Schwelle **3×**; die Einträge über der Schwelle,
  die er berührt (`eigentums-frage-…`), tragen ihren Ausgang (`geplant`). Alle Einträge des Registers mit `evidence/` ab drei
  Dateien tragen einen Ausgang, keiner steht über der Schwelle auf `offen`. Ein Norm-Artefakt des Architect entsteht daraus
  nicht; eine Übergabe an den Architect ist nicht fällig.
- **Folge-Slices:** keiner neu. R-4 geht nicht in
  `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt`: dessen Gegenstand ist die Zeile
  `exempt-paths` in `.d-check.yml`, nicht die Go-Liste `AusgenommenePfade()` in `internal/archive/scan.go` — zwei verschiedene
  Ausnahmelisten —, und ein Kommentar in `scan.go` brächte dem Test-Slice eine zweite Schicht. Träger ist der Rolleninhaber,
  der `scan.go` ändert (Register). Der Kopplungs-Slice bleibt in `open/` mit seinen zwei Liefer-Punkten; sein Start-Trigger
  (beide Träger in `done/`) ist mit dem Move dieser Closure erfüllt, seine Zustandsaussage zieht der Planner nach dem Move nach.
- **Risiken aus §6:** vier, je ein Ausgang — *entfallen* mit Grund: die ersten drei (Anker, Regex-Träger, Zähl- und
  Ersetz-Seite); *weiter offen:* das Link-Zitat im Code-Span, als Register-Eintrag
  `link-zitat-im-code-span-wird-vom-nachzug-mitersetzt` mit Träger Trigger 6 der ADR. Keines ist *eingetreten*. Dass der
  Ausgang *entfallen* trägt, ist gelesen: zu jedem der drei gibt es einen Rot-Beleg einer Rolle, die nicht der Implementer ist.
- **Adressen vor dem Move ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** das Kommando aus §4 zählt außerhalb dieser Datei am
  2026-09-26, nach Anlage der Register-Belege, **1** Zeile; es ist derselbe Falsch-Treffer wie in §4 (der Dateiname als
  Muster eines Zähl-Kommandos in der Closure-Notiz des Geschwisters in `done/`, ohne Verzeichnis-Präfix, kein Verweis). Der
  Lifecycle-Zweig allein — `(open|next|in-progress|done)/<Kennung>` als Code-Span und `](<Kennung>` beziehungsweise
  `](…/<Kennung>.md)` als Markdown-Link — trifft außerhalb dieser Datei **0** Zeilen. Kein eingefrorenes Artefakt nennt den
  Slice als Pfad; die Reports, der Kopplungs-Slice und das Register nennen die Kennung. Der Move hat keinen Verweis
  nachzuziehen.
- **Drei Paarungen:** werden nach dem Move geprüft (Planner); das Ergebnis steht an dieser Stelle.

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
