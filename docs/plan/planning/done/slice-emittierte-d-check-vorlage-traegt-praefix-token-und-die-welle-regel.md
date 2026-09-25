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
Die zwei benannten Grenzen der Vorlage (Ausschlüsse unten) sind Inhalt des Kommentars aus Liefer-Punkt 2
und Inhalt des Berichts aus Liefer-Punkt 1; sie sind keine Lieferung neben den drei, und Größe und
Schichten ändern sich nicht. Die zwei Fälle zur Ableitung der Kombinationen (Liefer-Punkt 3 (c)) liegen
in `test/mutations/` und mutieren den Träger nur in der Kopie: sie sind Zähne desselben Liefer-Punkts,
keine vierte Lieferung, und der Träger bleibt im Bestand unberührt (Schichten: Emission und Test/E2E).
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
- **Der Ausweg über `exclude-sections` für Spec-Straten** (ein Abschnitt `Geschichte` in einer Spec-Datei
  nimmt Slice- und Welle-Token aus) — *Bestand bleibt bewusst stehen:* die Zeile ist Bestand der Vorlage
  und wird von [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) nirgends
  festgelegt; `exclude-sections` ist in d-check `v0.77.0` nur auf der Ebene der `matrix` und damit für alle
  Klassen zugleich setzbar (je Klasse oder je Regel: Schemafehler), sie global zu entfernen färbt die
  Geschichte-Zeile der ADR-Vorlage der Baseline rot und kostet jeden Adopter einen Marker; die emittierten
  Spec-Vorlagen führen den Abschnitt nicht (ihre Überschrift ist `7. Historie`), der grüne Start ist nicht
  berührt. Eine je Klasse setzbare Ausnahme wäre eine Anforderung an d-check, ein fremdes Repo, und
  Handlung des Auftraggebers. Die Grenze steht als Kommentar-Satz in der Vorlage (Liefer-Punkt 2), als
  Grenze und nicht als Zusage.
- **Das bare `ADR-` ohne Nummer als Muster** — *Bestand bleibt bewusst stehen:* das Token färbt den
  frischen Start rot (Wörter wie `ADR-Bezüge` in den emittierten Spec-Vorlagen), und
  [`MR-054`](../../../../harness/conventions.md#mr-054) lässt die Aufnahme nicht zu; das „nicht enger" in
  [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) §Grenze gilt für Kennungen.
  Auch diese Grenze steht als Kommentar-Satz (Liefer-Punkt 2).
- **Ein Träger-seitiger Vertrag für die Liste der Sprachen und Architekturen** (eine maschinenlesbare
  Ausgabe statt des Wortlauts einer Fehlermeldung) — *Schicht-Abgrenzung:* er änderte den Träger
  (`cmd/`, `internal/gen/`), dieser Slice berührt allein Vorlage, Test und E2E. Die Stufe liest die
  Meldung und schlägt fail-closed an; die Grenze steht in Liefer-Punkt 3 (a) und §6. Die **Inhalte** der
  Listen halten Go-Tests über `Available` der Fehlertypen (Sprachliste, Union und die Liste von `cpp`);
  allein das **Format** der Meldung hat keinen Halter. Ob ein Vertrag
  nötig ist, ist eine Entscheidung des Architect; dieser Slice schneidet ihn nicht, und Größe und
  Schichten bleiben (drei Liefer-Punkte, zwei Schichten).
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

- [x] **Liefer-Punkt 1 (erster) — die Zell-für-Zell-Messung.** Alle ❌-Zellen der Matrix-Tabelle in
      `grundlagen-referenz-richtung.md` des vendored Regelwerks `v6.9.0`
      (`R=.harness/baseline/v6.9.0/regelwerk; sed -n '/^| Dokument ↓/,/^| \*\*Roadmap/p' $R/grundlagen-referenz-richtung.md | grep -o '❌' | wc -l`
      → **22**, gemessen 2026-09-24, kein Erwartungswert) und der Gate-Text (§Prüfung, *„Maschineller
      Gate"*) gegen die eingebettete Vorlage: **je Zelle die Regel, die sie deckt, oder die Lücke,
      benannt.** Die Messung läuft zweimal, vor und nach der Änderung der Vorlage; beide Stände
      stehen im Bericht. Sie bestätigt oder widerlegt die Zählung in [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) §Grenze (drei Zellen
      Rangfolge innerhalb der Straten · neun die Spalten ADR, Slice, Welle der drei Straten-Zeilen ·
      eine ADR → Welle mit Marker · sechs, die nur `aussen` fängt · drei ohne Regel). **Ein Widerspruch
      zu dieser Zählung ist ein Befund an den Architect** (Folge-ADR, [`AGENTS.md`](../../../../AGENTS.md)
      §3.4), kein stilles Nachziehen. **Ein Vorbehalt gegen die Spalte „Regel" einer Zellgruppe ist kein
      Widerspruch zur Zählung,** solange die Zuordnung der Zellen stimmt: der Ausweg, den
      `exclude-sections` für einen Abschnitt `Geschichte` in einer Spec-Datei lässt, und das bare `ADR-`
      ohne Nummer, das keine Regel fängt (das `ids`-Muster verlangt vier Ziffern). Die Messung ist erfüllt,
      wenn beide als **Grenze der Messung** im Bericht stehen — die Zählung 22 = 3 · 9 · 1 · 6 · 3 ist
      eine Stellen-Messung an zwei Stellen
      ([`MR-055`](../../../../harness/conventions.md#mr-055)) und sagt nichts über das Verhalten der
      Vorlage im Ziel für eine Spec-Datei mit `## Geschichte` oder für ein bares `ADR-`. Die Messung ist
      keine Eigenschaft der Vorlage. Ablage: siehe §1 *Wo die Zell-Messung lebt*.
- [x] **Liefer-Punkt 2 — die Vorlage.** `internal/emit/templates/d-check.yml`: Token `slice-` auf der
      Klasse `slice` und `welle-` auf der Klasse `welle` (die Vorlage führt keine Ziffern-Form mehr) ·
      die Regel `{from: spec-straten, to: welle, allow: false}` · das `ids`-Muster für ADR
      segment-tolerant (`ADR-([A-Z]+-)?\d{4}`) · die Klasse `adr` mit dem Pfad
      `docs/plan/adr/[0-9]*.md` **und** `docs/plan/adr/[A-Z]*-[0-9]*.md` (`README.md` bleibt draußen)
      · der Herkunfts-Kommentar in **Zustandsform** ([`AGENTS.md`](../../../../AGENTS.md) §3.7): er nennt
      die Positions-Liste für den Nachzug eines bestehenden Ziels, den Fehlalarm des Präfixes als in Kauf
      genommen samt Ausweg je Klasse (ADR: der Zeilen-Marker; Spec-Straten: Umformulieren — der Marker
      ist dort ein Umgehen, das nur der Reviewer fängt) und dass der Marker nicht Ziel-spezifisch ist —
      dazu **zwei benannte Grenzen der Vorlage:** `exclude-sections` gilt für alle Klassen zugleich und
      nimmt einen Abschnitt `Geschichte` in einer Spec-Datei von Slice- und Welle-Token aus (nur der
      Reviewer fängt es), und das bare `ADR-` ist keine Regel. Der Kommentar-Satz steht direkt hinter dem
      `exclude-sections`-Absatz, in Zustandsform und ASCII, im Wortlaut: *„exclude-sections gilt in d-check
      fuer alle Klassen zugleich; je Klasse oder je Regel ist es nicht setzbar. Ein Abschnitt Geschichte in
      einer Spec-Datei nimmt dort Slice- und Welle-Token aus, was das Regelwerk fuer die Spec-Straten nicht
      vorsieht. Die emittierten Spec-Vorlagen fuehren keinen solchen Abschnitt (ihre Ueberschrift ist 7.
      Historie); wo ein Adopter ihn anlegt, faengt ihn nur der Reviewer. Die blosse Zeichenfolge ADR- ohne
      Nummer faengt keine Regel: sie steht als Wort in den emittierten Spec-Vorlagen, und das ids-Muster
      verlangt vier Ziffern."* Der Satz erweitert die Zusage über den Emitter nicht und ist kein
      Liefer-Punkt neben diesem. **Bricht, wenn** er fehlt oder eine der zwei Grenzen als Zusage (statt als
      Grenze) formuliert; das prüft der Verifier am Wortlaut.
      **Seine Aussagen über das Ziel halten den Zweig des Emitters:** ein bestehendes Ziel bekommt die
      Änderung nicht. Ein Go-Test bindet die Positionen an die eingebettete Vorlage — er misst die
      **Menge** der Token und der Regeln der `matrix`, nicht die Namen der neuen Zeilen, und die
      Ziffern-Form darf nirgends mehr stehen.
- [x] **Liefer-Punkt 3 — die Erprobung im Ziel.** (a) *Grüner Start:* das frisch gebootstrappte Ziel
      fährt `make docs-check` mit `0 Befund(e)` — sprach-agnostisch (ohne `--lang`) **und** je Sprache
      und Architektur, die das Werkzeug trägt (`--lang` mit `--arch flat|hexagonal|hexslice`; eine
      Kombination, die die Sprache nicht trägt, endet mit Exit 2 und der Meldung `unbekannte
      Architektur`, deren Liste `verfuegbar:` die Architektur nicht nennt, und ist kein Fall). Der Beleg der ADR
      (`cat spec/*.md | grep -cE '(slice|welle)-'` im Ziel → 0) misst den sprach-agnostischen Lauf
      allein; die Läufe mit Sprache werden **gemessen, nicht angenommen**. *Was „je Sprache und
      Architektur, die das Werkzeug trägt" bindet:* die Kombinationen der Stufe sind **aus dem Träger
      abgeleitet, nicht geschrieben.** Die Stufe liest die Sprachen aus der Fehlermeldung `unbekannte
      Sprache …; verfuegbar: …` und die Architekturen aus `unbekannte Architektur …; verfuegbar: …`
      (`SupportedLangs()` und `SupportedArchs()` in `internal/gen/`; die zweite ist der Union aus
      `langArchs()`) und fährt jede Sprache gegen jede Architektur. **Der Träger nennt in der Meldung
      `unbekannte Architektur` bei einer Sprache mit gültigem Namen die Architekturen dieser Sprache**
      (`archsForLang()`; `cpp --arch hexagonal` → `verfuegbar: flat, hexslice`), **bei einem unbekannten
      Architekturnamen die Union** (`SupportedArchs()`). Endet eine Kombination mit Exit 2 und der Meldung
      `unbekannte Architektur "<arch>"`, gilt sie als vom Träger nicht getragen und ist kein Fall **nur
      dann, wenn die `verfuegbar:`-Liste derselben Meldung die abgelehnte Architektur nicht nennt**; nennt
      sie diese selbst oder ist sie leer, lehnt der Träger eine getragene Kombination ab (oder die Meldung
      ist nicht einzuordnen), und die Stufe endet mit Exit 1. Die Stufe **schlägt fail-closed an**
      (Exit 1), wenn eine der beiden Meldungen keine Namen nennt oder eine genannte Sprache in keiner
      Kombination grün anläuft. **Bricht, wenn** eine Sprache oder Architektur, die das Werkzeug trägt, in
      diesen zwei Meldungen fehlt, die Meldungen einen Namen nennen, den die Stufe nicht fährt, oder die
      Stufe eine Ablehnung als kein Fall verbucht, deren Liste die abgelehnte Architektur selbst nennt —
      dann sagt die Stufe mehr, als sie misst. **Gegenbeispiel (rot zu sehen):** der Träger lehnt eine
      getragene Kombination mit `unbekannte Architektur` und einer Liste ab, die die Architektur selbst
      nennt → Stufe rot (Exit 1); ohne den Vergleich mit der Liste bliebe sie grün. **Belegt**
      (Implementer, Scratchpad-Träger, Shim und mutierte Kopie; der Verifier wiederholt es): ein Träger,
      dessen `langArchs()` um `cpp hexagonal` ergänzt ist, wird mit einer Kombination mehr gefahren, als die
      frühere feste Liste führte — die Ableitung folgt der Quelle, ohne dass die Stufe geändert wird; ein
      Shim, der `verfuegbar: ` in der Meldung ändert, endet die Stufe mit Exit 1 und Meldung, statt mit
      weniger Kombinationen grün zu bleiben; ein Shim, der `go --arch flat` mit Exit 2 und einer Liste
      ablehnt, die `flat` nennt, endet die Stufe mit Exit 1, und der Fall 444 färbt die Stufe in einer
      mutierten Kopie über `make full-smoke` rot (Exit 2 mit der erwarteten Zeile), während der Code ohne
      den Vergleich unter derselben Mutation grün bleibt. **Nicht belegt:** eine in sich stimmige
      Fehlmeldung — der Träger lehnt eine getragene Kombination mit Exit 2 und einer Liste ab, die die
      Architektur nicht nennt (etwa `go --arch flat` abgelehnt mit `verfuegbar: hexagonal, hexslice`) —, sie
      ist aus der Meldung allein von einer echten Ablehnung nicht zu unterscheiden und bleibt grün (die
      Kombination fehlt dann im Lauf); eine Liste, die einen Namen auslässt, den kein Go-Test über
      `Available` hält (die Liste von `go`), sie liefert weniger Kombinationen ohne Fehler, solange jede
      genannte Sprache grün anläuft; eine Sprache, die der Träger trägt und `SupportedLangs()` nicht
      nennt; und der Fall 445 über einen vollständigen `full-smoke`-Lauf (er ist über die Stufen-Sonde mit
      mutiertem Träger belegt, Gegenprobe: feste Listen bleiben grün; `make mutate` fährt ihn am
      endgültigen Baum). **Grenze:** Der Wortlaut einer Fehlermeldung des Trägers ist die Quelle der Stufe.
      Die **Inhalte** der Listen halten Go-Tests über `Available` der Fehlertypen — die Sprachliste
      (`TestGenerate_UnknownLang`), die Union (`TestGenerateArch_UnknownArch`) und die Liste von `cpp`
      (`TestGenerateArch_LangSpecificArchRejected`); die Liste von `go` hält kein Test über `Available`.
      Das **Format** der Meldung hält kein Test (`grep -rn 'verfuegbar: ' --include='*_test.go' internal cmd
      | wc -l` → **0**, gemessen 2026-09-25, kein Erwartungswert): fail-closed ist die Stufe gegen eine
      Umbenennung des Markers (Fall 445), nicht gegen eine in sich stimmige Fehlmeldung des Trägers. Sie steht
      als Grenze hier und in §6; ein Träger-seitiger Vertrag ist §1 ausgeschlossen. (b) *Je Regel und Muster ein
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
      `ids`-Muster ohne Segment, der Glob ohne Bereichs-Präfix, und die Link-Pflicht des ADR-Musters
      (`link-policy: always` auf der ADR-Zeile von `ids` abgeschaltet — die Zusicherung im Go-Test
      liest dort nur diese Zeile, nicht die Datei, deren Kommentar den Ausdruck ebenfalls nennt). **Die
      zwei Zusagen der Stufe nach (a) tragen je einen Fall, weil sie Zusagen des Plans sind:** der
      Vergleich der abgelehnten Architektur mit der Liste derselben Meldung (Fall 444: die Liste der
      Meldung `unbekannte Architektur` nennt die abgelehnte Architektur selbst → die Stufe endet mit
      Exit 1) und die Ableitung der Sprachen aus der Träger-Meldung statt aus festen Listen (Fall 445: der
      Marker `verfuegbar: ` der Sprachliste wechselt → die Stufe endet mit Exit 1). Beide mutieren den
      Träger in der Kopie und lassen ihn im Bestand unverändert; Erwartungs-Stufe ist `full-smoke`
      (`# verify: full-smoke`), weil kein Go-Test die Stufe führt. Der Fall 444 ist mit Rot, Gegenprobe
      und `make full-smoke` in einer mutierten Kopie belegt; der Fall 445 über die Stufen-Sonde, nicht
      über einen vollständigen `full-smoke`-Lauf — **`make mutate` am endgültigen Baum trägt den Beleg
      beider**, der Verifier fährt ihn. Der `sed`-Anker jedes Falls ist am
      **heutigen** Quell-Bestand gemessen ([`MR-071`](../../../../harness/conventions.md#mr-071)); für 444
      und 445 trifft er in `internal/gen/gen.go` je eine Stelle
      (`grep -c 'Available: archsForLang(lang)}' internal/gen/gen.go` → **1** ·
      `grep -c '; verfuegbar: %s", e.Lang,' internal/gen/gen.go` → **1**, gemessen 2026-09-25, kein
      Erwartungswert).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: die emittierte Konfiguration ist ein öffentlicher Vertrag; Nutzerdoku, die sie
      beschreibt, ist gegen den Ist-Stand geprüft
      (`grep -rn 'slice-\\d\|welle-\\d' docs/user README.md` → leer, gemessen 2026-09-24) und nur bei
      Abweichung nachgezogen; `docs/user/e2e-abdeckung.md` ist erzeugt (`make e2e-abdeckung`), nicht
      von Hand geschrieben.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
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

Die Ausgänge stehen hinter jedem Risiko; die Beobachtungs-Verzeichnisse liegen unter [`../observations/`](../observations).

- **Der grüne Start bricht an einer Form, die die ADR nicht gemessen hat.** Ihr Beleg
  (`cat spec/*.md | grep -cE '(slice|welle)-'` im Ziel → 0) gilt für den sprach-agnostischen Lauf;
  emittierte ADR-, Planungs- und Skelett-Texte der Läufe mit `--lang`/`--arch` können ein Wort der
  Form `slice-…` oder `welle-…` tragen, das die neuen Token als Befund lesen. — **Ausgang: entfallen.** Der grüne Start hält in allen sechs Kombinationen (sprachlos, cpp flat, cpp hexslice, go flat, go hexagonal, go hexslice): `0 Befund(e)` und Spec-Dateien ohne `slice-` und `welle-`; `cpp hexagonal` trägt der Träger nicht. Der Verifier fuhr die Stufe gegen den gebauten Träger (Verifikationsbericht §4.4).
- **Die Messung widerspricht der Zählung der ADR** (drei · neun · eine · sechs · drei). Die ADR ist
  unveränderlich; der Weg ist ein Befund an den Architect (§4). Ein Vorbehalt gegen die Spalte „Regel"
  bei stimmender Zuordnung der Zellen ist Grenze, kein Widerspruch (Liefer-Punkt 1). — **Ausgang: entfallen.** Die Zählung 22 = 3 · 9 · 1 · 6 · 3 stimmt (Verifikationsbericht §2, Zell-Messung des Review-Reports); kein Befund an den Architect. Die zwei Vorbehalte gegen die Spalte „Regel“ (`exclude-sections`, bares `ADR-`) stehen als Grenze im Kommentar-Satz der Vorlage.
- **Die Vorlage trägt zwei benannte Blindflecke** — ein Abschnitt `Geschichte` in einer Spec-Datei nimmt
  dort Slice- und Welle-Token aus, und das bare `ADR-` fängt keine Regel; beide sind Grenzen (§1), keine
  Zusagen. Der Ausgang *entfallen* ist erst zulässig, wenn der Kommentar-Satz aus Liefer-Punkt 2 in der
  Vorlage steht; bis dahin trägt ihn nur dieser Plan. Träger ist der Satz in der vorgegebenen Fassung,
  und der Verifier liest den Wortlaut. Wer die Sonde (`## Geschichte` mit einem Slice-Namen in
  `spec/lastenheft.md` des Ziels → kein Befund) im Verifier-Lauf nicht reproduziert, hat den Grund für
  *entfallen* nicht. — **Ausgang: entfallen.** Der Kommentar-Satz steht direkt hinter dem `exclude-sections`-Absatz der Vorlage im vorgegebenen Wortlaut (ASCII, beide Grenzen als Grenze formuliert), und die Sonde `## Geschichte` mit einem Slice-Namen in `spec/spezifikation.md` des Ziels → `0 Befund(e)` ist im Verifier-Lauf reproduziert (Verifikationsbericht §4.3). Die Grenze besteht fort und ist in §7 als benannte Lücke gegenüber [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) geführt.
- **Die Kombinationen des grünen Starts weichen von dem ab, was der Träger trägt.** Die Stufe leitet sie
  aus zwei Fehlermeldungen des Trägers ab (Liefer-Punkt 3 (a)) und vergleicht die abgelehnte Architektur
  mit der `verfuegbar:`-Liste derselben Meldung; kommt ein Layout oder eine Sprache hinzu, wird sie
  gefahren, ohne dass die Stufe sich ändert, und eine getragene Kombination, die der Träger mit einer
  Liste ablehnt, die sie selbst nennt, endet mit Exit 1. Der Träger der Aussage ist die Ableitung samt
  Vergleich und fail-closed-Anschlag; der Verifier wiederholt die Sonden des Implementers (Scratchpad-Träger
  mit einer Kombination mehr in `langArchs()` · Shim, der `verfuegbar: ` ändert · Shim, der `go --arch
  flat` mit einer Liste ablehnt, die `flat` nennt → Exit 1) und liest die Meldung; dieselbe Ablehnung mit
  einer Liste ohne `flat` bleibt grün und ist die benannte Grenze, kein Erwartungswert der Sonde. `make
  mutate` fährt die Fälle 444 und 445 am endgültigen Baum. — **Ausgang: entfallen.** Die Ableitung aus den zwei Meldungen des Trägers und der Vergleich der abgelehnten Architektur mit der Liste derselben Meldung tragen; die Sonden des Implementers und des Reviewers hat der Verifier wiederholt und die Meldungen gelesen (Scratchpad-Träger mit `cpp hexagonal` in `langArchs()` → 7 Kombinationen; Shim `verfuegbar: ` → Exit 1; Shim `go --arch flat` mit Liste `flat, hexagonal, hexslice` → Exit 1; Verifikationsbericht §4.5). Die Fälle 444 und 445 stehen im Bestand der `make mutate`-Läufe als `ok` (§7). Dieselbe Ablehnung mit einer Liste ohne `flat` bleibt grün und ist die Grenze des nächsten Risikos.
- **Der Wortlaut der Träger-Fehlermeldung ist die Quelle der Ableitung, und ihr Format hält kein Vertrag.**
  Die Inhalte der Listen halten Go-Tests über `Available` (Sprachliste, Union, Liste von `cpp`; die Liste
  von `go` nicht); das Format — Marker, Trenner, Zeilenform — hält kein Test, und eine in sich stimmige
  Fehlmeldung des Trägers (getragene Kombination abgelehnt, Liste ohne die Architektur) ist aus der
  Meldung allein von einer echten Ablehnung nicht zu unterscheiden. Ein Träger-seitiger Vertrag (eine
  maschinenlesbare Quelle der Liste am Träger) wäre Änderung an `cmd/` und `internal/gen/`, nicht an diesem
  Slice (§1). — **Ausgang: weiter offen → Register**, [`sensor-leitet-aus-dem-meldungs-wortlaut-des-traegers-ab-ohne-format-halter`](../observations/BEO-ALL/sensor-leitet-aus-dem-meldungs-wortlaut-des-traegers-ab-ohne-format-halter/observation.md) (1×, `offen`). Der Verifier bestätigt die Grenze an der Sonde: Eine in sich stimmige Fehlmeldung (`go --arch flat` abgelehnt, Liste `hexagonal, hexslice`) endet mit Exit 0 und fünf Kombinationen. Ein Träger-seitiger Vertrag ist Entscheidung des Architect; eine Kennung wird hier nicht vergeben.
- **Der Fehlalarm des Präfixes** (`slice-mv`, `slice-lokal`) trifft ein Ziel, das die Wörter in einer
  ADR oder Spec nennt; die ADR nimmt ihn in Kauf und nennt den Ausweg je Klasse. Meldet ein Ziel einen
  Fall, den weder Umformulieren noch Marker löst, ist der Re-Evaluierungs-Trigger 4 der ADR erreicht —
  dieser Slice schneidet ihn nicht. — **Ausgang: entfallen.** Kein Lauf dieses Slice hat einen Fehlalarm gemeldet, den weder Umformulieren noch Marker löst (grüner Start in sechs Kombinationen; Ausweg-Fall: dieselbe ADR-Zeile mit Marker → `0 Befund(e)`, Verifikationsbericht §4.4). Der Fehlalarm ist von der ADR in Kauf genommen und trägt ihren Re-Evaluierungs-Trigger 4; das Risiko gehört der ADR, nicht mehr diesem Slice.
- **Ein Zahn deckt einen anderen Zweig.** Ein Gegenbeispiel, das schon unter der alten Konfiguration
  rot ist, belegt nicht, dass erst die Änderung es findet; die Gegenrichtung in Liefer-Punkt 3 (b) ist
  die Probe. — **Ausgang: entfallen.** Die Gegenrichtung trägt: dasselbe Gegenbeispiel bleibt mit der Ziffern-Form, ohne die Regel, ohne den Glob und ohne das Segment im Muster grün (Verifikationsbericht §4.4), und die Gegenproben zu den Fällen 435 und 443 (Zusicherung geschwächt bzw. auf die ganze Datei gestellt → Test grün) zeigen, dass die Zusicherung das Rot trägt (§4.6).
- **Der Herkunfts-Kommentar sagt über das Ziel mehr, als der Emitter dort tut** (ein bestehendes Ziel
  bekommt die Änderung nicht). Liefer-Punkt 2 bindet die Aussagen an den Zweig des Emitters. —
  **Ausgang: entfallen.** Der Verifier fand die Aussagen des Herkunfts-Kommentars gegen den Zweig des Emitters stimmig: Ein Ziel mit vorhandener `.d-check.yml` bleibt byte-gleich (Sonde, Verifikationsbericht §3). Der Zähler von [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) bleibt bei 2×, es gibt kein drittes Auftreten.
- **Ein Fall bindet weniger, als sein Name sagt** — die drei Klassen aus §8 (eine `!`-Negation mitten
  im `bats`-Fall, eine weite Assertion über einer engen, eine Zusage ohne eigenen Mutations-Fall). Der
  Slice führt sie nicht als Liefer-Punkt; der Träger ist die Gegenprobe je Zahn und die Lesung der
  Meldung im Review. — **Ausgang: weiter offen → Register.** Eine der drei Klassen ist in abgeschwächter Form aufgetreten — die Zusage über den skip-if-present-Pfad der Datei hängt am generischen Mechanismus und hat keinen eigenen Fall: [`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md) (2×, `offen`). Die Negation mitten im `bats`-Fall und die weite Assertion über einer engen sind an den neuen Fällen nicht aufgetreten (der Slice legt keinen `bats`-Fall an, der Go-Test hält je Unterfall eine Assertion); ihre Einträge [`negation-mitten-im-bats-fall-ohne-wirkung`](../observations/BEO-ALL/negation-mitten-im-bats-fall-ohne-wirkung/observation.md) und [`weite-assertion-verdeckt-die-bindung-der-engen`](../observations/BEO-ALL/weite-assertion-verdeckt-die-bindung-der-engen/observation.md) bleiben bei 1×.
- **Der Slice ist größer als eine Review-Sitzung.** Der Schnitt entlang der Positionen steht in §4.
  — **Ausgang: entfallen.** Die Rückführung `in-progress → next` ist nicht eingetreten: Die drei Liefer-Punkte und die zwei Schichten hielten (Verifikationsbericht §8), zwei Review-Runden. Gewachsen ist der Umfang innerhalb der Liefer-Punkte — Ableitung der Kombinationen aus dem Träger, Vergleich mit der Liste, die Fälle 444 und 445 —, kein vierter Liefer-Punkt.

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

Geschrieben von der Rolle Planner in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nach zwei Review-Runden
(`docs/reviews/2026-09-25-slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel.md`,
`docs/reviews/2026-09-25-slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel-runde-2.md`)
und Verifikation
(`docs/reviews/2026-09-25-verify-slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel.md`).

- **Was hat funktioniert:** Die Zell-Messung bestätigt die Zählung der ADR:
  `R=.harness/baseline/v6.9.0/regelwerk; sed -n '/^| Dokument ↓/,/^| \*\*Roadmap/p' $R/grundlagen-referenz-richtung.md | grep -o '❌' | wc -l`
  → **22** = 3 · 9 · 1 · 6 · 3 (Rang innerhalb der Straten · Spalten ADR, Slice, Welle der drei Straten-Zeilen ·
  ADR → Welle · nur `aussen` fängt · ohne Regel), gemessen 2026-09-25, kein Erwartungswert; vor der Änderung der
  Vorlage 3 · 6 · 1 · 6 · **6** — die drei Welle-Zellen der Spec-Straten hatten keine Regel. Die Zahl ist eine
  **Stellen-Messung** an zwei Stellen (Matrix-Tabelle und Gate-Text des Regelwerks gegen die eingebettete Vorlage,
  [`MR-055`](../../../../harness/conventions.md#mr-055)); das Verhalten im Ziel ist an je einer Sonde je Zellgruppe
  nachgemessen, **nicht** an jeder der 22 Zellen — von den drei Rang-Zellen ist eine sondiert, die zwei anderen teilen
  dieselbe Zeile `direction: no-downward`; die drei Lücken (ADR → Carveout, ADR → Roadmap, Slice → Roadmap) sind im Ziel
  real (`0 Befund(e)`). Der grüne Start hält in sechs Kombinationen (sprachlos · `cpp flat` · `cpp hexslice` ·
  `go flat` · `go hexagonal` · `go hexslice`; `cpp hexagonal` trägt der Träger nicht), fünf Gegenbeispiele werden mit gelesener
  Regel rot und je mit der Gegenprobe grün (Ziffern-Form, ohne Regel, ohne Segment, ohne Glob), und der Ausweg über den
  Zeilen-Marker endet mit `0 Befund(e)`. Der Go-Test bindet die **Menge** der Token und der Regeln, die Fälle 435 bis 445
  färben je die benannte Position rot; die Gegenproben zu 435 und 443 (Zusicherung geschwächt bzw. auf die ganze Datei
  gestellt → Test grün) zeigen, dass die Zusicherung das Rot trägt (Verifikationsbericht §2, §4.4 bis §4.6).
- **Was ging anders als geplant:** (1) Die Kombinationen des grünen Starts sind **aus den Meldungen des Trägers
  abgeleitet**, nicht als feste Liste geschrieben, und die Stufe vergleicht die abgelehnte Architektur mit der
  `verfuegbar:`-Liste derselben Meldung; der Abnahme-Wortlaut wurde nach dem Vergleich der abgelehnten Architektur mit der
  Liste vom Planner nachgezogen (`753820c4`, `ae6b6f7f`, `06f883e3`), nicht von der ausführenden Rolle
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10). (2) Die Fälle 444 und 445 sind Zähne der zwei Zusagen der Stufe und
  mutieren den Träger nur in der Kopie. (3) Die Vorlage trägt den Kommentar-Satz mit den zwei Grenzen (Liefer-Punkt 2),
  und der Fall 443 bindet die Link-Pflicht des ADR-Musters an die Zeile, nicht an die Datei. (4) **Die Zähne 440 bis 442**
  (Ziffern-Form nirgends, Menge der Token, Menge der Regeln) stehen im Doc-Kommentar des Go-Tests, in der Aufzählung von
  Liefer-Punkt 3 (c) nicht; sie sind Zähne der Zusage aus Liefer-Punkt 2, kein Scope-Zuwachs, und der Verifier hat sie in
  der Kopie rot gesehen (Verifikationsbericht §4.6, §8).
- **Die Grenzen der Vorlage** (benannt, nicht geschlossen): `exclude-sections` gilt in d-check am gepinnten Stand für alle
  Klassen zugleich, je Klasse oder je Regel ist es nicht setzbar; ein Abschnitt `Geschichte` in einer Spec-Datei nimmt dort
  Slice- und Welle-Token aus (Sonde im Ziel: `0 Befund(e)`; unter `## 7. Historie` dagegen zwei Befunde), und der Marker im
  Spec-Stratum wirkt mechanisch — beides fängt allein der Reviewer. Das bare `ADR-` ohne Nummer fängt keine Regel (Sonde
  `Siehe ADR- und ADR-12` → `0 Befund(e)`). Beide Grenzen stehen als Grenze im Kommentar-Satz der Vorlage. Eine je Klasse
  setzbare Ausnahme wäre eine **Anforderung an d-check**, ein fremdes Repo, und **Handlung des Auftraggebers**; hier steht
  sie nur als Text, an d-check ist nichts geändert.
- **`make mutate`-Beleg — kein einzelner grüner Lauf, sondern die Vereinigung zweier Läufe am selben Baum.** Baum:
  Working-Tree-Hash `8221ba8bcfc81980c3416ae4caebd846300582b912cefc14a76db0ad8fb9a361`
  (`bash harness/tools/working-tree-hash.sh`, vom Verifier vor und nach beiden Läufen gemessen; die Zeitstempel der Logs
  06:54 und 07:35 liegen nach dem letzten Commit um 06:12; den Hash *zwischen* den Läufen misst niemand nach). Lauf 1:
  `mutate: 425 ok, 8 Befund(e)` — alle acht (Fälle 105 und 236 bis 242) mit derselben Ursache, `DeadlineExceeded … docker.io/docker/dockerfile:1.7 … net/http: timeout`
  beim Bild-Bau, das Urteil des Falls wurde nie erreicht. Lauf 2: `mutate: 432 ok, 1 Befund(e)` — Fall 212,
  `container is marked for removal and cannot be started` (Docker-Daemon, Exit 125). Die Vereinigung der `ok`-Mengen deckt
  alle Fälle (`ls test/mutations/*.sh | wc -l` → **433**, gemessen 2026-09-25); der Verifier hat die Mengen aus den Logs neu
  abgeleitet, `comm` in beide Richtungen ohne Rest, und jeder der neun Fälle mit Befund ist im anderen Lauf `ok`. Die neun
  mutieren nichts, was der Slice geändert hat (`git diff --stat 0abb97ac..HEAD -- internal cmd Makefile` nennt allein
  `internal/emit/emit_test.go` und `internal/emit/templates/d-check.yml`). Ein dritter Lauf wurde abgebrochen
  (`ABGEBROCHEN, keine vollstaendige Messung`) und trägt weder Beleg noch Gegenbeleg. **Der Verifier hat `make mutate`
  nicht gefahren** (Auftrag); die Formulierung der DoD *„der Verifier fährt ihn“* ist damit nicht wörtlich erfüllt, der Beleg
  ist die Auswertung der Logs. **Was ein einzelner grüner Lauf zusätzlich zeigte** — kein Wechselspiel paralleler Worker, der
  Beleg-Slot nach [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) (die Schlüsseldatei
  `.harness/state/mutate-passed.key` besteht nicht, gemessen 2026-09-25) und die vollständige Zeit-Bilanz —, sind
  Eigenschaften des **Laufs**, nicht der Zähne; für die Frage dieses Slice (bindet jeder Zahn aus dem richtigen Grund?)
  trägt die Vereinigung, mehr behauptet dieser Beleg nicht. **Der Baum hat sich seitdem bewegt:** Hash zu Beginn der
  Closure `b2c5c6d0737f493695da222f5a3e9b866f702c0a86a5b24cc47945a7d625089e`; der Unterschied ist der Verifikationsbericht
  (`git diff --name-only 06f883e3..HEAD` → allein dieser Bericht), und `git diff --stat 06f883e3..HEAD -- internal cmd harness test Makefile .d-check.yml`
  ist leer — der Prüfgegenstand ist unverändert, die Schlüssel-Gleichheit ist damit nicht belegt.
- **CI:** Der `ci`-Lauf 36036245381 am Commit `d235b24d` endete im Job `full-smoke` rot; die Ursache am Baseline-Fetch, `HTTP 500`,
  ist die Angabe des Auftraggebers (das Log war mir nicht lesbar); ein späterer Lauf am Commit `4c0e0f1f` ist grün
  (Lauf 36085391934). Ohne abgeschlossenen Vorgang zählt das nicht, es ist **benannt, nicht gezählt** in
  [`sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt`](../observations/BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt/observation.md);
  ein Vermerk in `ci-rennt-gegen-die-publikation-des-gepinnten-releases` gehört nicht dorthin — dort ist die Ursache ein 404
  vor der Publikation, hier ein Server-Fehler.
- **Handoff-Zahlen, je mit ihrem Kommando** (gemessen 2026-09-25, keine Erwartungswerte):
  `ls test/mutations/4{35..45}-*.sh | wc -l` → **11** Zähne dieses Slice;
  `ls test/mutations/*.sh | wc -l` → **433**;
  `ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **173** Verzeichnisse im Register.
- **`make gates`:** Stempel `.harness/state/gates-passed.diffsha` = `b2c5c6d0…089e` und `bash harness/tools/working-tree-hash.sh`
  gleich am Stand vor der Closure (Lauf des Verifiers); der Lauf über den Closure-Stand steht in der Übergabe an den
  Auftraggeber, nicht in dieser Datei.
- **Adressen vor dem Move ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** kein eingefrorenes Artefakt nennt den Slice als
  Pfad — `git grep -nE '(open|next|in-progress|done)/slice-emittierte-d-check-vorlage|\]\(slice-emittierte-d-check-vorlage'`
  → kein Treffer (gemessen 2026-09-25); die Reviews und der Bericht nennen die Kennung, keinen Pfad.
- **Steering-Loop-Eintrag (Form: benannte Spec-Lücke, daneben ein neuer Sensor).** *Die Lücke:*
  [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) (`Accepted`) sagt für die Spec-Straten
  *Umformulieren, keine ausgenommene Sektion* zu; die emittierte Vorlage hält das für einen Abschnitt `Geschichte` nicht, weil
  `exclude-sections` nur für alle Klassen zugleich setzbar ist. Sie steht benannt am Kommentar-Satz der Vorlage, in §1 dieses
  Plans und hier; **entschieden** ist sie nicht — die ADR ist unveränderlich ([`AGENTS.md`](../../../../AGENTS.md) §3.4, §3.8),
  und ob eine Folge-ADR die Zusage einschränkt oder d-check die Ausnahme je Klasse bekommt, ist Entscheidung des Architect
  bzw. Handlung des Auftraggebers. *Der Sensor:* die `full-smoke`-Stufe `kennungs_form_im_ziel` mit Kopfzeile und Eintrag in
  der Abdeckungs-Sicht, der Go-Test `TestDCheckConfig_KennungsForm` und die Zähne 435 bis 445. Kein Zielort-Feld: mit diesem
  Slice ist keine Regel an einem Zielort verkörpert worden.
- **Beobachtungs-Register (`../observations/`):** je Beleg
  `evidence/slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel.md`; Zähler gelesen am 2026-09-25 mit
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  **Neu angelegt (je 1×, `offen`):**
  [`sensor-leitet-aus-dem-meldungs-wortlaut-des-traegers-ab-ohne-format-halter`](../observations/BEO-ALL/sensor-leitet-aus-dem-meldungs-wortlaut-des-traegers-ab-ohne-format-halter/observation.md)
  (der Wortlaut der Träger-Meldung ist die Quelle der Ableitung, ihr Format hält kein Test) und
  [`sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt`](../observations/BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt/observation.md)
  (kein vorhandener Eintrag trägt die Ursache Registry oder Daemon; der CI-Lauf oben ist dort benannt, nicht gezählt).
  **Ergänzt, je eine Evidence-Datei:**
  [`emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md)
  (**2×**, `offen`; die Vorlage ist mit diesem Slice **entschieden** strenger als die eigene `.d-check.yml` — gezählt ist der
  Zustand ohne Wächter, nicht seine Ursache),
  [`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  (**2×**, `offen`; die Zusage über den skip-if-present-Pfad der Datei hängt am generischen Mechanismus und hat keinen
  eigenen Fall — die Bindung ist *schwächer* als die der ersten Lage, die Zuordnung ist ein Urteil und in der Evidence-Datei
  so geführt),
  [`mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`](../observations/BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf/observation.md)
  (**3×**, `offen`; der Beleg gilt für einen Baum vor den Doku-Commits der folgenden Rollen) und
  [`eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  (**5×**, Stand `geplant` unverändert; der Ruhe-Marker der Roadmap). **Nicht erhöht:**
  [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
  bleibt bei 2× — die Aussagen des Herkunfts-Kommentars stimmen gegen den Zweig des Emitters (Review und Verifier);
  [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  bleibt bei 13× (die neuen Positionen tragen die Fälle 435 bis 445);
  [`negation-mitten-im-bats-fall-ohne-wirkung`](../observations/BEO-ALL/negation-mitten-im-bats-fall-ohne-wirkung/observation.md)
  und [`weite-assertion-verdeckt-die-bindung-der-engen`](../observations/BEO-ALL/weite-assertion-verdeckt-die-bindung-der-engen/observation.md)
  bleiben bei 1× — der Slice legt keinen `bats`-Fall an, und der Go-Test hält je Unterfall eine Assertion;
  [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  bleibt bei 2× (Vorlage und eigene Konfiguration unterscheiden sich deklariert). **Lese-Schritt:**
  `mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf` **erreicht mit diesem Slice 3×** und steht `offen`; der
  Ausgang wird vom Lese-Schritt zugewiesen — *verkörpert* braucht einen Zielort, *geplant* die Kennung eines Slice, und keines
  von beidem schreibt dieser Lauf; das ist zulässig und vorübergehend bis zum nächsten Lese-Schritt (Baseline-Regelwerk
  `modul-06-roadmap.md` §Beobachtungs-Register). **Keine Regel getragen haben** die Finding-Klassen der Review-Runden, die
  nirgends als Beobachtung stehen (etwa *Ausnahme-Sektion nimmt eine Klasse aus, die die Zusage nicht benennt*, *Menge im E2E
  hartverdrahtet ohne Kopplung an die Quelle*, *Zusage der E2E-Ableitung ohne dauerhaften Zahn*): kein Eintrag ohne benannte
  Wiederkehr — sie bleiben in den Summary-Zeilen der Reports.
- **Folge-Slices:** *Adressen, keine Anlage in dieser Closure.* (1) Die **Commit-Prüfung** zu [ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md) Festlegung 4 (Dogfood-Prüfung,
  `commits:`-Block, `patterns=`) — ein Folge-Schnitt **ohne Kennung und ohne Datei**; §1 (*Ausdrücklich NICHT*, erster Punkt) ist
  seine Adresse. Der offene Slice `slice-kennungs-erkennung-traegt-die-zugelassenen-formen` (Datei in `open/`) gehört zu diesem
  Schnitt; ob der Schnitt ihn aufnimmt oder er umgeschnitten wird, entscheidet der Planner beim Schnitt, nicht hier. (2) Die
  Regeln `adaptionsblock → slice` und `adaptionsblock → welle` samt Neutralisierung (Festlegung 2(b)) — ein Folge-Schnitt
  **ohne Kennung und ohne Datei**; §1 (zweiter Punkt) ist seine Adresse. (3) Der **Träger-seitige Vertrag** für die Listen der
  Sprachen und Architekturen — Entscheidung des Architect, keine Kennung; bis dahin steht die Grenze als Beobachtung im
  Register. (4) Die **Anforderung an d-check** (`exclude-sections` je Klasse) — Handlung des Auftraggebers.
- **Risiken aus §6:** zehn, je ein Ausgang — *entfallen* mit Grund: grüner Start, Zählung der Messung, zwei benannte Blindflecke,
  Kombinationen des grünen Starts, Fehlalarm des Präfixes, ein Zahn deckt einen anderen Zweig, Herkunfts-Kommentar,
  Slice-Größe; *weiter offen → Register:* Wortlaut der Träger-Meldung
  (`sensor-leitet-aus-dem-meldungs-wortlaut-des-traegers-ab-ohne-format-halter`) und *ein Fall bindet weniger, als sein Name
  sagt* (`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`). Keines ist *eingetreten*.
- **Drei Paarungen:** Dieses Repo führt Wellen-Betrieb; sie prüft die nächste Welle-Closure — auch für diesen wellenlosen Slice
  (`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, Tabelle *Träger im Repo ohne Wellen*). Der Slice trägt keinen Eintrag
  mit dem Pflichtfeld der Anker-Paarung (ohne Gegenstand); der einzige genannte Folge-Slice mit Datei ist
  `slice-kennungs-erkennung-traegt-die-zugelassenen-formen`; jede genannte Beobachtung ist ein Verzeichnis mit nicht leerem
  `evidence/`.

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
