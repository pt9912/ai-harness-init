# Slice slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel: Die emittierte `.d-check.yml` erkennt einen benannten Slice und eine Welle und hält die Spec-Straten von der Welle fern

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057) Setzung 1 — ein freier Slug in
lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — sein Closure-Trigger fordert nichts, was die DoD unten nicht schon
belegt: kein repo-weiter Beleg, kein Replay; damit fehlt das *Mehr*, an dem sich eine Welle
entscheidet (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Er ist der
erste Schnitt der Liefer-Gegenstände von
[ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md); die Folge-Schnitte (§1)
sind einzeln lieferbar und bilden kein Bündel mit gemeinsamer Closure-Bedingung.

**Ebene: emittiert.** Gegenstand ist die Vorlage `internal/emit/templates/d-check.yml` und damit der
Vertrag gegenüber Zielrepos. `.d-check.yml` wird nur an einem freien Pfad geschrieben
([ADR-0007](../../adr/0007-bootstrap-phasen.md) Festlegung 3, skip-if-present): **ein bereits
gebootstrapptes Ziel erreicht die Änderung nicht.**

**Bezug:**
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Repo bootstrappen),
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
emittierte `.d-check.yml`),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate, dessen Zusage der grüne Start nicht trägt),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Messung ist wiederholbar,
das Werkzeug gepinnt),
[ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) (**Accepted** — die
Festlegungen 1, 2(a), 3 und 6 und Folgepflicht 1 soweit die Vorlage; Festlegung 4 und 2(b) bleiben
bei den Folge-Schnitten),
[`MR-054`](../../../../harness/conventions.md#mr-054) (Erprobung, grüner Start, rotes Gegenbeispiel),
[`MR-055`](../../../../harness/conventions.md#mr-055) (eine Messung trägt die Stelle, die sie liest),
[`MR-063`](../../../../harness/conventions.md#mr-063) (jede Position eine Nicht-Null-Basis),
[`MR-071`](../../../../harness/conventions.md#mr-071) (die Fall-Anlage misst den Anker gegen den
Quell-Bestand),
[`MR-057`](../../../../harness/conventions.md#mr-057) (die Namens-Form; ihre Grenze zur emittierten
Ebene ist der Anlass der ADR),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 und §3.7 (Zusage mit Gegenbeispiel; Kommentar in
Zustandsform),
[`MR-025`](../../../../harness/conventions.md#mr-025) (jede Zahl dieses Plans steht neben dem
Kommando, das sie liefert).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle des Vertrags; Gegenstand ist der
Inhalt einer emittierten Konfigurationsdatei).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-24.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die `.d-check.yml`, die das Werkzeug in ein frisches Zielrepo schreibt, trägt die
Kennungs-Form des Regelwerks `v6.9.0` an den Stellen, die
[ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) in den Festlegungen 1,
2(a) und 3 setzt — Präfix-Token `slice-` und `welle-`, die Regel `spec-straten → welle`, ein
segment-toleranter `ids`-Muster für ADR samt Klasse `adr` mit Bereichs-Präfix-Glob —, und der Beleg
steht: die Zell-für-Zell-Messung der 22 ❌-Zellen, der grüne Start am frischen Ziel und je Regel und
Muster ein Gegenbeispiel, das im Ziel rot wird.

**Der Befund, an dem der Schnitt hängt.** Die Vorlage führt für Slice und Welle die Ziffern-Form
(`grep -nE "token: '(slice|welle)-" internal/emit/templates/d-check.yml`, gemessen 2026-09-24): ein
benannter Slice oder eine benannte Welle — die Form, die
[`MR-057`](../../../../harness/conventions.md#mr-057) diesem Repo vorschreibt und das Regelwerk in
§Vergabe für alle setzt — wird von der Matrix nie gefangen; die Regel `spec-straten → welle` fehlt,
obwohl die Matrix-Tabelle des Regelwerks die Spalte Welle in allen drei Straten-Zeilen auf ❌ setzt.

**Wo die Zell-Messung lebt.** [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) Festlegung 6 nennt Gegenstand und Reihenfolge der Messung
(*erster* Liefer-Punkt, je Zelle Regel oder Lücke), nicht ihre Ablage. **Setzung dieses Plans:** die
Tabelle ist das **Übergabe-Artefakt des Implementers an den Reviewer** — ein Bericht im Handoff, ein
Zeitdokument und kein Bestandsprodukt —, und §7 der Closure trägt das Ergebnis (Zellen je Klasse)
samt dem Kommando, das sie zählt. Sie liest **zwei Stellen** — die Matrix-Tabelle und den Gate-Text
des Regelwerks `v6.9.0` und die eingebettete Vorlage — und sagt nichts über das Verhalten im Ziel
([`MR-055`](../../../../harness/conventions.md#mr-055): eine Messung trägt die Stelle, die sie liest);
das Verhalten trägt Liefer-Punkt 3. Ob die Tabelle ein lebendes Artefakt werden soll, ist eine offene
Frage, die dieser Plan nicht entscheidet.

**Größe, und warum Liefer-Punkt 3 nicht herausgeschnitten ist.** Drei Liefer-Punkte, zwei Schichten
(Emission und Test/E2E). Die Vorlage selbst ist ein kleiner Eingriff; das Volumen liegt im Beleg, und
jedes Stück ist eine Wiederholung einer vorhandenen Form (`full-smoke`-Zahn, `test/mutations/`-Fall).
**Schnitte man Liefer-Punkt 3 heraus, lieferte der Slice Positionen ohne das rot gesehene
Gegenbeispiel, das
[ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) Festlegung 6 als
Beleg-Pflicht der Lieferung führt** — eine Zusage ohne Gegenbeispiel
([`AGENTS.md`](../../../../AGENTS.md) §3.6). Fällt der Slice trotzdem zu groß aus, geht der Schnitt
entlang der **Positionen** (Token und Regel · `ids`-Muster und Klasse `adr`), jede mit ihrem Beleg —
nicht entlang der Schicht (§4).

**Die Überschneidung mit dem offenen Slice zur Kennungs-Erkennung, eingeordnet.**
[slice-kennungs-erkennung-traegt-die-zugelassenen-formen](../open/slice-kennungs-erkennung-traegt-die-zugelassenen-formen.md)
ist **Dogfood**: [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 4 nimmt die emittierte
Ebene aus, und seine Fundliste liest die Werkzeuge dieses Repos samt `commits.id-patterns` der
eigenen `.d-check.yml`. **Dieser Slice berührt keine dieser Stellen** — allein die eingebettete
Vorlage. Die Überschneidung liegt an anderer Stelle: [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) Festlegung 4 zieht die Dogfood-Fassung
der Commit-Prüfung und den `commits:`-Block der eigenen `.d-check.yml` mit, und beides liegt in der
Fundliste jenes Slice. **Übergabe an den Planner:** jener Slice gehört zum Schnitt der
Commit-Prüfung, nicht zu diesem; dort ist zu entscheiden, ob er dessen Dogfood-Hälfte aufnimmt oder
umgeschnitten wird.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Commit-Prüfung** ([ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) Festlegung 4: die sechs Muster in `patterns=`, die Dogfood-Fassung,
  der `commits:`-Block, die Kopplungs-Tests, die Klassen-Liste im Kopf der Prüfung, die Zähne der
  Menge, die Zeile zu Werkzeug-Commits in `harness/README.md`) — *ein Folge-Schnitt übernimmt es.*
  Seine Kennung wird vergeben, wenn dieser Slice in `done/` liegt (Baseline-Regelwerk
  `modul-05-planning-harness.md` §Regeln gegen typische Fehlannahmen). Einzeln lieferbar sind beide,
  weil sie **keine Datei teilen** und verschiedene Reichweiten haben: die Prüfung wird bei jedem Lauf
  kanonisch neu geschrieben, die Konfiguration nur an freiem Pfad
  ([ADR-0054](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1).
- **Die Regeln `adaptionsblock → slice` und `adaptionsblock → welle` samt Neutralisierung**
  (Festlegung 2(b)) — *ein Folge-Schnitt nach diesem übernimmt es.* Sie hängen an den Token dieses
  Slice und an der Bedingung 2(c): erst wenn der grüne Start mit den genannten Eingriffen hält und der
  Marker mit dem Adaptions-Block als Quellklasse wirkt, gehen sie in die Vorlage. In diesem Slice
  steht keine Regel mit dem Adaptions-Block als Quelle.
- **Die eigene `.d-check.yml` dieses Repos** — *Bestand bleibt bewusst stehen:* [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md)
  Festlegung 5 entscheidet, dass Klassen, Token, Matrix und `ids`-Muster nicht mitziehen; die
  Vorlage ist damit strenger als das eigene Repo, und das ist deklariert.
- **Der Nachzug bestehender Ziele** — *Bestand bleibt bewusst stehen:* skip-if-present schützt den
  Adopter-Boden; der Nachzug ist Handarbeit nach der Positions-Liste im Herkunfts-Kommentar, und kein
  Wächter meldet die Differenz ([ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) §Fitness Function: *benannt, nicht geschlossen*).
- **Das Vertrags-Präfix und die Carveout-Kennung als aktive Muster** — *Bestand bleibt bewusst
  stehen:* das Präfix gehört dem Adopter und ist im frischen Ziel nicht bekannt
  ([`MR-054`](../../../../harness/conventions.md#mr-054) Setzung 3); die Vorlage führt sie weiter als
  begründeten Kommentar.
- **Das Regelwerk selbst** — *es wäre ein anderer Vorgang:* der Widerspruch zwischen dem Text von
  §Vergabe und den Vorlagen des Regelwerks und die Auslassung von `welle-` im Gate-Text sind Sache des
  Kurses, eines fremden Repos.
- **Werkzeuge, die eine Kennung nur in Ziffernform kennen** — *Bestand bleibt bewusst stehen* ([ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md)
  §Grenze, *Nicht Gegenstand*): ein eigener Vorgang mit eigener Fundliste.

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

- [ ] **Liefer-Punkt 1 (erster) — die Zell-für-Zell-Messung.** Alle ❌-Zellen der Matrix-Tabelle in
      `grundlagen-referenz-richtung.md` des vendored Regelwerks `v6.9.0`
      (`R=.harness/baseline/v6.9.0/regelwerk; sed -n '/^| Dokument ↓/,/^| \*\*Roadmap/p' $R/grundlagen-referenz-richtung.md | grep -o '❌' | wc -l`
      → **22**, gemessen 2026-09-24, kein Erwartungswert) und der Gate-Text (§Prüfung, *„Maschineller
      Gate"*) gegen die eingebettete Vorlage: **je Zelle die Regel, die sie deckt, oder die Lücke,
      benannt.** Die Messung läuft zweimal, vor und nach der Änderung der Vorlage; beide Stände
      stehen im Bericht. Sie bestätigt oder widerlegt die Zählung in [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) §Grenze (drei Zellen
      Rangfolge innerhalb der Straten · neun die Spalten ADR, Slice, Welle der drei Straten-Zeilen ·
      eine ADR → Welle mit Marker · sechs, die nur `aussen` fängt · drei ohne Regel). **Ein Widerspruch
      zu dieser Zählung ist ein Befund an den Architect** (Folge-ADR, [`AGENTS.md`](../../../../AGENTS.md)
      §3.4), kein stilles Nachziehen. Ablage: siehe §1 *Wo die Zell-Messung lebt*.
- [ ] **Liefer-Punkt 2 — die Vorlage.** `internal/emit/templates/d-check.yml`: Token `slice-` auf der
      Klasse `slice` und `welle-` auf der Klasse `welle` (die Vorlage führt keine Ziffern-Form mehr) ·
      die Regel `{from: spec-straten, to: welle, allow: false}` · das `ids`-Muster für ADR
      segment-tolerant (`ADR-([A-Z]+-)?\d{4}`) · die Klasse `adr` mit dem Pfad
      `docs/plan/adr/[0-9]*.md` **und** `docs/plan/adr/[A-Z]*-[0-9]*.md` (`README.md` bleibt draußen)
      · der Herkunfts-Kommentar in **Zustandsform** ([`AGENTS.md`](../../../../AGENTS.md) §3.7): er nennt
      die Positions-Liste für den Nachzug eines bestehenden Ziels, den Fehlalarm des Präfixes als in Kauf
      genommen samt Ausweg je Klasse (ADR: der Zeilen-Marker; Spec-Straten: Umformulieren — der Marker
      ist dort ein Umgehen, das nur der Reviewer fängt) und dass der Marker nicht Ziel-spezifisch ist.
      **Seine Aussagen über das Ziel halten den Zweig des Emitters:** ein bestehendes Ziel bekommt die
      Änderung nicht. Ein Go-Test bindet die Positionen an die eingebettete Vorlage — er misst die
      **Menge** der Token und der Regeln der `matrix`, nicht die Namen der neuen Zeilen, und die
      Ziffern-Form darf nirgends mehr stehen.
- [ ] **Liefer-Punkt 3 — die Erprobung im Ziel.** (a) *Grüner Start:* das frisch gebootstrappte Ziel
      fährt `make docs-check` mit `0 Befund(e)` — sprach-agnostisch (ohne `--lang`) **und** je Sprache
      und Architektur, die das Werkzeug trägt (`--lang` mit `--arch flat|hexagonal|hexslice`; eine
      Kombination, die die Sprache nicht trägt, endet mit Exit 2 und ist kein Fall). Der Beleg der ADR
      (`cat spec/*.md | grep -cE '(slice|welle)-'` im Ziel → 0) misst den sprach-agnostischen Lauf
      allein; die Läufe mit Sprache werden **gemessen, nicht angenommen**. (b) *Je Regel und Muster ein
      rotes Gegenbeispiel, mit gelesener Meldung* (die Regel benannt, nicht irgendeine), als
      `full-smoke`-Stufe **mit Stufen-Kopfzeile** — sonst fällt sie aus `make e2e-abdeckung`, dessen
      erzeugte Datei nachgezogen wird: ein benannter Slice-Name in einer ADR · ein Welle-Name in einer
      ADR · ein Welle-Name in einer Spec-Datei (die Regel `spec-straten → welle`) ·
      `ADR-<Bereich>-<NNNN>` blank im Text (das segment-tolerante Muster) · eine Datei mit
      Bereichs-Präfix unter `docs/plan/adr/`, die einen Slice-Namen nennt (der Glob der Klasse `adr`)
      · und die Gegenprobe des Ausweges: dieselbe ADR-Zeile mit dem Marker → `0 Befund(e)`.
      **Beide Richtungen** ([`MR-063`](../../../../harness/conventions.md#mr-063), jede Position auf
      einer Nicht-Null-Basis): dasselbe Gegenbeispiel bleibt mit der Ziffern-Form bzw. ohne die Regel
      bzw. ohne den Glob **grün** — sonst belegt der Fall nur, dass *irgendein* Befund entsteht, nicht
      dass erst die Änderung ihn findet. (c) *Je Zahn ein Mutations-Fall* in `test/mutations/`:
      Präfix zurück in die Ziffern-Form (je Klasse), die Regel `spec-straten → welle` gestrichen, das
      `ids`-Muster ohne Segment, der Glob ohne Bereichs-Präfix; der `sed`-Anker jedes Falls am
      **heutigen** Quell-Bestand gemessen ([`MR-071`](../../../../harness/conventions.md#mr-071)).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: die emittierte Konfiguration ist ein öffentlicher Vertrag; Nutzerdoku, die sie
      beschreibt, ist gegen den Ist-Stand geprüft
      (`grep -rn 'slice-\\d\|welle-\\d' docs/user README.md` → leer, gemessen 2026-09-24) und nur bei
      Abweichung nachgezogen; `docs/user/e2e-abdeckung.md` ist erzeugt (`make e2e-abdeckung`), nicht
      von Hand geschrieben.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
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
| `internal/emit/templates/d-check.yml` | update | Liefer-Punkt 2: Token, Regel, `ids`-Muster, Klasse `adr`; die Absätze des Herkunfts-Kommentars, die die Ziffern-Form nennen, werden in Zustandsform neu geschrieben (wer die Zeile ohnehin anfasst, zieht sie nach) |
| `internal/emit/emit_test.go` | update | Liefer-Punkt 2: der Go-Test der Vorlage (`TestDCheckConfig_EntschiedeneModulListe` steht dort) bekommt die Menge der Token und der Regeln |
| `harness/tools/full-smoke.sh` | update | Liefer-Punkt 3: grüner Start je Sprache und Architektur, die Stufen mit Kopfzeile und die Zähne im Ziel |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | `make e2e-abdeckung` — den Inhalt der erzeugten Datei hält ein Fall in `test/e2e-abdeckung.bats` |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | Liefer-Punkt 3 (c): die Zähne; Nummern im Anschluss an die höchste **zum Anlagezeitpunkt vergebene** — der Implementer liest sie dort (`ls -1 test/mutations/*.sh \| sed -n 's#.*/\([0-9]*\)-.*#\1#p' \| sort -n \| tail -1`), sie steht hier nicht; andere Läufe vergeben Nummern zwischen Schnitt und Anlage |
| Bericht der Zell-Messung | kein Bestandsprodukt | Liefer-Punkt 1: Handoff des Implementers, siehe §1 |

- **Reihenfolge:** Messung des Ist-Stands → Vorlage samt Go-Test (`make test`, netzlos) → grüner Start je
  Form → Gegenbeispiele (`make full-smoke`, Docker) → Zähne (`make mutate`, kein Gate) → Messung des
  Soll-Stands.
- **Was der Slice nicht anfasst:** `.d-check.yml` dieses Repos, `harness/conventions.md`,
  `internal/emit/templates/enforce/` (die Commit-Prüfung) und alles unter `harness/tools/` außer
  `full-smoke.sh` — die Grenze, an der der Folge-Schnitt der Commit-Prüfung beginnt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei; der `git mv` landet auf
dem Hauptzweig, vor der Arbeit. Keine Vorbedingung des Auftraggebers; die Vorbedingung im Repo ist
[ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) `Accepted` (seit
2026-09-24).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Beleg (Liefer-Punkt 3) ist in
  **einer** Review-Sitzung nicht prüfbar — dann Schnitt entlang der **Positionen**: Token und Regel
  mit ihren Gegenbeispielen und Zähnen, danach `ids`-Muster und Klasse `adr` mit ihren; nie die
  Vorlage ohne ihren Beleg. Oder der grüne Start braucht mehr Eingriffe an emittierten Texten, als
  eine Neutralisierung nach dem Vorbild der bestehenden trägt: dann ist die Menge der Eingriffe eine
  Entscheidung des Architect, und der Slice hält an.
- `in-progress` → `open` (blockiert — Carveout?): die Messung aus Liefer-Punkt 1 widerspricht der
  Zählung der ADR — die ADR ist ab `Accepted` unveränderlich, der Weg ist die Übergabe an den
  Architect (Folge-ADR mit `Supersedes`), und der Slice wartet auf das Verdikt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `make test` ist grün mit dem Go-Test der Vorlage, und `make full-smoke`
ist grün mit den Stufen aus Liefer-Punkt 3 — der grüne Start je Form und jedes Gegenbeispiel rot mit
der benannten Meldung; der Bericht trägt die Zell-Messung mit beiden Ständen; (2) `make gates` ist
grün, und die erzeugte Datei `docs/user/e2e-abdeckung.md` ist nachgezogen. Dazu der Lerneintrag in
einer der drei Formen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Die Ausgänge setzt die Closure; bis dahin steht hinter jedem Risiko `Ausgang: offen bis Closure`.

- **Der grüne Start bricht an einer Form, die die ADR nicht gemessen hat.** Ihr Beleg
  (`cat spec/*.md | grep -cE '(slice|welle)-'` im Ziel → 0) gilt für den sprach-agnostischen Lauf;
  emittierte ADR-, Planungs- und Skelett-Texte der Läufe mit `--lang`/`--arch` können ein Wort der
  Form `slice-…` oder `welle-…` tragen, das die neuen Token als Befund lesen. — **Ausgang:** offen
  bis Closure.
- **Die Messung widerspricht der Zählung der ADR** (drei · neun · eine · sechs · drei). Die ADR ist
  unveränderlich; der Weg ist ein Befund an den Architect (§4). — **Ausgang:** offen bis Closure.
- **Der Fehlalarm des Präfixes** (`slice-mv`, `slice-lokal`) trifft ein Ziel, das die Wörter in einer
  ADR oder Spec nennt; die ADR nimmt ihn in Kauf und nennt den Ausweg je Klasse. Meldet ein Ziel einen
  Fall, den weder Umformulieren noch Marker löst, ist der Re-Evaluierungs-Trigger 4 der ADR erreicht —
  dieser Slice schneidet ihn nicht. — **Ausgang:** offen bis Closure.
- **Ein Zahn deckt einen anderen Zweig.** Ein Gegenbeispiel, das schon unter der alten Konfiguration
  rot ist, belegt nicht, dass erst die Änderung es findet; die Gegenrichtung in Liefer-Punkt 3 (b) ist
  die Probe. — **Ausgang:** offen bis Closure.
- **Der Herkunfts-Kommentar sagt über das Ziel mehr, als der Emitter dort tut** (ein bestehendes Ziel
  bekommt die Änderung nicht). Liefer-Punkt 2 bindet die Aussagen an den Zweig des Emitters. —
  **Ausgang:** offen bis Closure.
- **Ein Fall bindet weniger, als sein Name sagt** — die drei Klassen aus §8 (eine `!`-Negation mitten
  im `bats`-Fall, eine weite Assertion über einer engen, eine Zusage ohne eigenen Mutations-Fall). Der
  Slice führt sie nicht als Liefer-Punkt; der Träger ist die Gegenprobe je Zahn und die Lesung der
  Meldung im Review. — **Ausgang:** offen bis Closure.
- **Der Slice ist größer als eine Review-Sitzung.** Der Schnitt entlang der Positionen steht in §4.
  — **Ausgang:** offen bis Closure.

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

Leer bis zur Closure; sie schreibt der Planner im frischen Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind das gesamte Repo `*` (Kürzel `ALL`:
`internal/emit/`, `docs/user/`, `test/`) und `harness/tools/` (Kürzel `TOOLS`: `full-smoke.sh`), beide
in der
[Modus-Deklaration](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) geführt. Die
Deklaration kennt keine feinere Zerlegung des Rests; ob `*` die Schwelle von 2 aus 3 Achsen erfüllt,
ist die Frage der Deklaration und nicht dieses Slice — er liest sie als vorhandene (Urteil, kein
Sensor).

**Vorgelagert — offene Beobachtungen sichten:** Das Register
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **171**, gemessen 2026-09-25 bei der
Priorisierung, kein Erwartungswert) ist nach Verzeichnisname durchgegangen; Sub-Area ist überall `*`.
Die Zähler-Stände unten sind die Zahl der Dateien unter dem `evidence/` des Eintrags
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gemessen 2026-09-25; die vier
zuerst genannten Stände stehen gegenüber dem Schnitt unverändert). Treffer nach Sachbezug:

- [`emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md)
  — **1×**. Die Vorlage ist mit diesem Slice **absichtlich** strenger als die eigene `.d-check.yml`
  ([ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) Festlegung 5, deklariert; ein Wächter für die Differenz existiert nicht). Das ist ein
  zweites Auftreten derselben Klasse — ob die Closure es zählt, ist ihr Urteil.
- [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
  — **2×**. Der Herkunfts-Kommentar der Vorlage sagt etwas über das Ziel aus; trägt er mehr, als der
  Emitter dort tut, ist es das **dritte** Auftreten, und der Eintrag ist eine Lücke mit eigenem
  Folge-Slice. Liefer-Punkt 2 bindet die Aussage an den skip-if-present-Zweig.
- [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  — **13×**, `verkörpert`. Die neuen Positionen sind neue Zähne; Liefer-Punkt 3 (c) trägt die Fälle.
- [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  — **2×**, nach Urteil **berührt, nicht erhöht:** Vorlage und eigene Konfiguration unterscheiden sich
  deklariert, ihre Gleichheit wird nicht behauptet.

- [`negation-mitten-im-bats-fall-ohne-wirkung`](../observations/BEO-ALL/negation-mitten-im-bats-fall-ohne-wirkung/observation.md)
  — **1×**, `offen`. Berührt, sobald der Slice einen `bats`-Fall anlegt oder anfasst (der Fall in
  `test/e2e-abdeckung.bats` für die erzeugte Datei; kein neuer Fall ist geplant): eine `!`-Negation,
  die nicht das letzte Kommando des Falls ist, bindet nichts. Kein Sensor meldet die Klasse; Träger
  ist das Review, das jede Negation gegen ihre Stellung im Fall liest.
- [`weite-assertion-verdeckt-die-bindung-der-engen`](../observations/BEO-ALL/weite-assertion-verdeckt-die-bindung-der-engen/observation.md)
  — **1×**, `offen`. Berührt durch Liefer-Punkt 3 (c) und den Go-Test aus Liefer-Punkt 2: hält ein Test
  eine Position mit einer weiten **und** einer engen Assertion, fängt die weite jede Mutation, die die
  enge fangen soll. Die Gegenprobe je Zahn (Liefer-Punkt 3 (b), beide Richtungen) ist der Träger.
- [`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  — **1×**, `offen`. Berührt: der Herkunfts-Kommentar (Liefer-Punkt 2) und die Meldungs-Lesung der
  Gegenbeispiele sind Zusagen, die an einer Assertion hängen können, ohne dass ein Fall in
  `test/mutations/` sie führt. Liefer-Punkt 3 (c) führt je Zahn einen Fall; die Zusagen darüber hinaus
  bleiben Urteil des Reviews. **Ein dritter Treffer** einer der drei Klassen durch diesen Slice hebt
  sie über die Schwelle — ob die Closure ihn zählt, ist ihr Urteil.

Andere Einträge nach Namenslesung nicht berührt (Urteil, kein Sensor).

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas sind GF** (`ALL` und `TOOLS` in der Modus-Deklaration): der Slice
schreibt eine Vorlage nach der ADR; er inventarisiert keinen Bestand.
