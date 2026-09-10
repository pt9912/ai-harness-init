# Slice slice-191: Das Benutzerhandbuch zeigt den Bestand, den der Bootstrap wirklich anlegt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Die Closure-Bedingung wäre die Abschrift der DoD unten
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).
Damit **nicht** in der Roadmap geführt.

**Ebene: Dogfood-Doku über die emittierte Ebene.** Gegenstand ist
[`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §6 —
eine Datei **dieses** Repos, die über den Bestand eines **fremden** Ziels
spricht. Der Generator selbst ist nicht berührt.

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(der emittierte Bestand, über den §6 spricht),
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
(die Erfassungsschicht — der Teil dieses Bestands, den §6 heute gar nicht kennt, §1),
[`ADR-0022`](../../../../docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
(Festlegung 7 — warum ihre Feldliste im geprüften Doku-Bereich des Ziels liegt und damit zum
sichtbaren Bestand gehört),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Gegenkraft, falls dieser Slice einen Wächter setzt: kein Gate über leerem
Prüfbereich),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(eine Zahl im Text steht neben dem Kommando, das sie liefert — die Regel, aus der
die Form der Lösung folgt),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* ist ein Steering-Loop, kein ADR),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes
Gegenbeispiel).

**Berührte Spec-Stellen:** `ARC-003` (Idempotente Ablage,
[`spec/architecture.md §1`](../../../../spec/architecture.md#1-komponenten-übersicht))
· Technik: `—`.

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-06.

---

## 1. Ziel

**Wer das Handbuch liest, sieht, was der Bootstrap wirklich anlegt — und wer
etwas hinzufügt oder vergisst, sieht es am Handbuch, nicht erst an einem
fremden Repo.**

§6 *Was wird angelegt* zeigt heute einen zusammenfassenden Baum. Er nennt
**zwölf** Einträge:

```sh
sed -n '/^mein-projekt\/$/,/^```$/p' docs/user/benutzerhandbuch.md \
  | grep -cE '^[│├└ ]'                                              # 12
```

Der reale Bestand eines dokument-only gebootstrappten Ziels ist um eine
Größenordnung größer — gemessen an einem frischen Lauf
(`ai-harness-init --name smoke` in ein leeres `git`-Repo):

```sh
find . -path ./.git -prune -o -path ./.harness/baseline -prune -o -type f -print | wc -l   # 44
find . -path ./.git -prune -o -path ./.harness/baseline -prune -o -type d -print | wc -l   # 24
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen wandern mit dem Generator. Genau das ist der Punkt.

**Die Verkürzung ist nicht Bequemlichkeit, sie ist der Grund, warum eine Lücke
lange unbemerkt blieb.** Der Baum fasst `docs/plan/` zu **einer** Zeile zusammen
und beschreibt ihren Inhalt als *„Architektur-Entscheidungen, Slices, Roadmap,
Beobachtungs-Register"*. Das Beobachtungs-Register entsteht dort nicht — die
Zeile behauptet einen Ort, den kein Emissions-Pfad anlegt, und weil sie kein
Verzeichnis einzeln nennt, fällt das beim Lesen nicht auf. Dasselbe gilt für
`harness/conventions/` und `docs/plan/carveouts/done/`, die
[slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md) nachträgt.

**Die zweite Instanz derselben Klasse ist keine Zeile, sondern eine ganze Fähigkeit.** Das Handbuch
beschreibt den Ist-Zustand des Werkzeugs; über
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
(Erfassungsschicht emittieren) steht darin nichts:

```sh
grep -icE 'span|telemetri|erfassung|aufzeichn|feldliste' docs/user/benutzerhandbuch.md   # 0
```

**Kein Erwartungswert**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit dem Handbuch; tragend ist, dass sie null ist. Was die fünf Muster
**nicht** treffen, ist ungemessen: die Null gilt für sie, nicht für jede denkbare Umschreibung.

**Die Lücke ist nicht theoretisch, und sie liegt schon in Phase 1.** Die Feldliste entsteht in
`emit.Enforce` — einer von acht Emissions-Stufen der Init-Strecke, unbedingt aufgerufen und
sprach-agnostisch, weil der Träger das *laufende* Bild kopiert und nicht am Sprachmodul hängt:

```sh
grep -n 'erfassung-feldliste' internal/emit/fieldlist.go          # FieldListPath, ein Zielort im Ziel
grep -cE '^\tif err := emit\.[A-Z]' cmd/ai-harness-init/main.go   # 8, darunter emit.Enforce
sed -n '/^\treturn FieldList(targetDir)$/p' internal/emit/enforce.go   # der Zweig, der sie schreibt
grep -n 'os.Executable()' internal/emit/enforce.go                # der Traeger ist das laufende Bild
```

Ein Adopter bekommt damit ein Repo, dessen Hooks bei Werkzeug-Aufrufen Spans schreiben und das eine
Feldliste darüber mitführt — im **geprüften** Doku-Bereich seines Ziels
([`ADR-0022`](../../../../docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 7). §6 nennt weder die Datei noch die Fähigkeit. **Das ist derselbe Defekt wie die
`docs/plan/`-Zeile, eine Stufe größer:** dort behauptet eine Bündelung einen Ort, den kein
Emissions-Pfad anlegt; hier verschweigt sie einen, den jeder Lauf anlegt. Beide Richtungen fängt
nur eine Aufzählung, die gehalten wird.

**Zwei Einschränkungen gehören dazu, sonst sagt der Befund mehr als er misst.** *Erstens* ist der
**Code-Pfad** gemessen, nicht ein Baum: die vier Kommandos zeigen, dass die Stufe unbedingt läuft
und an keinem Sprachmodul hängt — dass die Datei im dokument-only-Baum steht, bestätigt der Lauf,
der §6 ohnehin gegen einen frischen Bootstrap hält. *Zweitens* hängt sie an einem **Laufzeit-Zweig**:
`emit.Enforce` schreibt Feldliste und Hook-Wrapper nur, wenn die Träger-Ablage gelingt, und meldet
sonst den Grund, ohne den Bootstrap scheitern zu lassen
([`ADR-0022`](../../../../docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 5(a)). **Für DoD (1) heißt das:** der Baum zeigt den Gelingens-Zweig und sagt, dass er
es tut — ein Baum, der die zwei Artefakte unbedingt behauptet, wäre an einem Ziel ohne abgelegten
Träger falsch, und der Wächter aus DoD (2) müsste die Bedingung kennen, statt sie zu übersehen.

**Zwei weitere Familien fehlen, jede auf ihre Art.** Der Baum trägt `.claude/` als **einen**
Eintrag — die drei Workflow-Commands verschwinden darin — und führt von `.harness/` nur den
`baseline/`-Zweig, während der Skill-Ordner daneben überhaupt nicht vorkommt:

```sh
sed -n '/^mein-projekt\/$/,/^```$/p' docs/user/benutzerhandbuch.md \
  | grep -cE 'skills|commands'                                                        # 0
grep -c '".claude/commands/' internal/emit/commands.go                                # 3
sed -n '/^func TestTemplates_EmittierterBestandVollstaendig/,/^}$/p' \
  internal/emit/templates_test.go | grep -cE '"\.harness/skills/'                     # 2
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Beide Familien sind vertraglich zugesagt —
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) für
die Workflow-Commands,
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) für den
Reviewer-/Closure-Skill —, und beide liegen im Ziel. Für DoD (1) sind sie **keine Ausnahme,
sondern der Regelfall**: ein Baum, der jede Datei einzeln nennt, zeigt sie ohne Zusatzregel. Dass
ein Adopter danach auch **weiß**, wozu sie da sind, ist eine andere Frage; sie liegt bei
[slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md) und steht hier unter
*Nicht in diesem Slice* (§6).

**Der Baum zeigt den Bestand, nicht das Zielbild.** Die Richtung ist nicht selbstverständlich:
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) nennt
`CLAUDE.md` als Teil der Durchsetzungsschicht, und kein Emissions-Pfad legt sie an. Wer den Baum
aus dem Zielbild ableitet, schreibt eine Zeile über eine Datei, die kein Lauf erzeugt — dieselbe
Klasse Defekt wie die `docs/plan/`-Zeile oben, nur aus der anderen Quelle. Gemessen steht der Fall
in [slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md) §6; hier gilt die Regel:
die Soll-Menge kommt aus dem Emitter (§3), nicht aus dem Lastenheft.

**Zwei Dinge sind zu liefern, und sie hängen zusammen.** Erst muss entschieden
sein, *was* der Baum zeigt — ohne diese Entscheidung gibt es nichts, was ein
Wächter halten könnte; dann muss er gegen den realen Bestand gehalten werden,
sonst ist er in drei Slices wieder alt. Ein Baum, den ein Mensch pflegt, ist
eine zweite Fassung derselben Aussage, und Kopien driften.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) §6 zeigt den vollständigen Bestand, für beide Phasen.**
  `docs/user/benutzerhandbuch.md` §6 nennt für den dokument-only-Bootstrap
  **jede** Datei und **jedes** Verzeichnis einzeln, das der Lauf real anlegt, und
  für den Sprachmodul-Bootstrap das Delta dazu. **Die Ausnahme ist zu benennen,
  nicht stillschweigend zu machen:** `.harness/baseline/` trägt allein
  `find . -path ./.git -prune -o -type f -print | wc -l` **98** gegen **44** ohne
  ihn — der vendored Baum ist ein Fremd-Blob, seine Datei-für-Datei-Auflistung
  wäre kein Bestandsbild, sondern ein Inhaltsverzeichnis des Kurses. Er steht als
  **ein** Eintrag mit seiner Zahl daneben.
  **Die Erfassungsschicht gehört dabei zum Bestand, nicht zum Beiwerk:** ihre Artefakte entstehen
  nach §1 schon in Phase 1, also führt der Baum sie wie jede andere Datei — mit einem Etikett, das
  die Fähigkeit beim Namen nennt. Das ist eine **Präzisierung dieses Punktes, kein zusätzlicher**:
  ein vollständiger Baum zeigt sie ohnehin, und was der Befund hinzufügt, ist die Pflicht, das
  Etikett zu wählen statt den Pfad kommentarlos einzureihen. *Was* erfasst wird, wie ein Adopter es
  ausliest oder abschaltet, bleibt außerhalb (§6, *Nicht in diesem Slice*).
- [ ] **(2) Der Baum ist gegen den realen Bestand gehalten, nicht von Hand
  gepflegt.** Ein Wächter vergleicht die im Handbuch genannten Pfade mit der
  Menge, die der Emitter liefert. **Diese Menge ist die der ganzen Init-Strecke, nicht die der
  Vorlagen-Stufe allein** — die `want`-Liste in
  `TestTemplates_EmittierterBestandVollstaendig` deckt gemessen **eine** der acht Stufen und
  keinen Pfad der Erfassungsschicht; ein Wächter auf ihr wäre gegen genau den Befund aus §1 blind.
  Welche Quelle die Soll-Menge liefert, entscheidet der erste Lauf gegen die vier Kandidaten in §3.
  **In beide Richtungen**, wie bei der Bijektion in Modul 6: ein genannter Pfad
  ohne Emission und ein emittierter Pfad ohne Nennung sind derselbe Defekt.
  **Rot-Nachweis:** ein Eintrag wird aus `structureGitkeeps()` genommen, ohne das
  Handbuch anzufassen — der Wächter muss rot werden; und ein Pfad wird im
  Handbuch erfunden — er muss ebenfalls rot werden. **Einer der beiden nimmt seinen Eintrag aus der
  Erfassungs-Stufe** (`grep -n 'return FieldList' internal/emit/enforce.go`) statt aus der
  Vorlagen-Stufe: ein Nachweis, der nur `structureGitkeeps()` anfasst, belegt genau die Achse, die
  die verworfene Soll-Quelle schon sah, und ließe die Blindstelle aus §1 ungemessen. Beide Richtungen einmal rot
  gesehen, sonst ist der Wächter eine Behauptung
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Ein `test/mutations/`-Fall hält den
  Zahn.
- [ ] **(3) Die Aussage über den Register-Ort ist mit dem Bestand in
  Übereinstimmung.** Die `docs/plan/`-Zeile nennt heute das
  Beobachtungs-Register als Inhalt; ob der Ort entsteht, entscheidet das Risiko
  aus [slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md) §6.
  **Dieser Slice erfindet die Entscheidung nicht** — er schreibt den Baum so,
  wie der Bestand zum Zeitpunkt der Umsetzung ist, und der Wächter aus (2) hält
  ihn danach unabhängig davon, wie sie ausfällt.
- [ ] `make gates` grün; `make full-smoke` grün; `make mutate` grün über die CI.
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
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §6 | update | DoD (1) und (3) — der vollständige Baum für beide Phasen |
| ein Wächter über der Pfad-Menge (Ort offen: Go-Test neben `templates_test.go` oder bats-Fall) | neu | DoD (2); der Ort folgt aus der Frage, welche Quelle die Menge liefert, und die steht in Go |
| `test/mutations/` | neu | der kuratierte Fall zum Wächter aus DoD (2) |
| `internal/emit/` | **unverändert** | der Generator ist nicht Gegenstand; wer hier etwas ändert, ist in [slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md) |
| [`harness/README.md`](../../../../harness/README.md) §Sensors | update **falls** der Wächter ein `make`-Ziel bekommt | ein genanntes Ziel muss existieren ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); hängt er in `make test`, entfällt der Eintrag |

**Was die Umsetzung zuerst entscheidet** (Modul 9 §4): **welche Quelle die
Soll-Menge liefert.** Der Befund aus §1 macht daraus eine Mengen-Frage mit Zahlen statt einer
Geschmacksfrage: die Init-Strecke hat **acht** Emissions-Stufen, und die Wahl entscheidet, wie
viele davon der Wächter überhaupt sehen kann.

```sh
grep -oE '^\tif err := emit\.[A-Za-z]+' cmd/ai-harness-init/main.go | sed 's/.*emit\.//' | tr '\n' ' '
# DocGate BaselineVerify Templates RootReadme Enforce Commands Agents Makefile

T='/^func TestTemplates_EmittierterBestandVollstaendig/,/^}$/p'
sed -n "$T" internal/emit/templates_test.go | grep -oE 'emit\.[A-Za-z]+' | sort -u   # emit.Templates
sed -n "$T" internal/emit/templates_test.go | grep -cE '^\t\t"'                      # 16
sed -n "$T" internal/emit/templates_test.go | grep -cE 'erfassung-feldliste|span-emit|\.claude/'  # 0

sed -n '/^func emitDokumentSatz/,/^}$/p' internal/emit/emitteddocs_test.go \
  | grep -oE 'emit\.[A-Za-z]+' | sort -u | wc -l                                     # 5
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl wandert mit dem Emitter. Vier Kandidaten, und sie sind nicht gleichwertig:

| Kandidat | gedeckte Stufen | Grenze |
|---|---|---|
| die `want`-Liste in `internal/emit/templates_test.go` | **1** von 8, **16** Pfade, **0** aus der Erfassungsschicht | **verworfen** — gegen den Befund aus §1 strukturell blind; eine Test-Konstante über einer Teilstrecke |
| `emitDokumentSatz` in `internal/emit/emitteddocs_test.go` | **5** — Vorlagen, Root-README, Commands, Rollen-Typen, Feldliste | nennt seine Grenze im eigenen Kopf (*„ein SECHSTER fiele heraus, bis er hier steht"*); Gate-Fragmente und `Makefile`-Aggregator fehlen, und die Liste ist eine zweite Fassung der Emitter-Reihe |
| die Emitter selbst über einen Temp-Baum | alle acht, **wenn** der Lauf alle acht ruft | dieselbe Zweitfassungs-Falle, nur vollständiger; im Test teurer |
| ein echter Bootstrap-Lauf | alle acht plus die Laufzeit-Zweige (Träger gelegt / nicht gelegt) | am nächsten am Nutzer, braucht Docker und fällt damit aus `make test` heraus |

**Was der Befund entscheidet und was nicht.** Verworfen ist Kandidat 1 — das ist gemessen und
kein Urteil. Zwischen den übrigen drei entscheidet der erste Lauf; dieser Plan nähme die Wahl
sonst ohne Messung vorweg. **Die Fehlerrichtung ist bei allen dreien dieselbe**: eine Quelle, die
die Stufen aufzählt, ist eine zweite Fassung von `emitAll` und altert genau wie der Baum, den sie
halten soll — wer eine wählt, benennt in DoD (2), wie ihre eigene Vollständigkeit gehalten wird.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**`open` → `next`:** [slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md)
liegt in `done/`. **Kein Zwang, sondern Ökonomie:** slice-190 bewegt die
Soll-Menge, und ein Baum, der davor geschrieben wird, ist beim Merge von
slice-190 wieder alt. Läuft dieser Slice zuerst, färbt sein eigener Wächter aus
DoD (2) den Nachbarn rot — was funktioniert, aber die Arbeit zweimal macht.

**Ein zweiter Anspruch liegt auf demselben Abschnitt, und er antwortet entgegengesetzt.**
[slice-111](slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md) — offen seit dem
2026-08-26 — nimmt sich §6 des Handbuchs ebenfalls vor. Sein DoD (2) *„Der Baum sagt, ob er
aufzählt oder zusammenfasst"* lässt die Bündelung ausdrücklich zu, mit der Begründung, eine
Einzel-Aufzählung altere bei jedem Slice; DoD (1) hier zählt auf. **Beide antworten auf denselben
Einwand, und er ist berechtigt:** eine Aufzählung altert — *wenn sie niemand hält*. DoD (2) hier
ist dieser Halter, den slice-111 nicht zur Verfügung hatte; damit ist der Widerspruch aufgelöst
und nicht überstimmt. Die Bedienwissen-Hälfte von slice-111 bleibt davon unberührt und ist sein
eigener Liefer-Wert (§6, *Nicht in diesem Slice*).

**Folge für die Reihenfolge:** läuft slice-111 zuerst, schreibt er eine ausgesprochene
Zusammenfassung, die dieser Slice wieder aufzählt — die Arbeit doppelt sich wie im
slice-190-Fall oben. Läuft dieser Slice zuerst, ist slice-111s DoD (2) an einem Baum zu messen,
den ein Wächter hält; ob es damit erfüllt oder gegenstandslos ist, entscheidet **sein** Lauf.
Dieser Slice schreibt nicht in den fremden Plan.

**Ein dritter Anspruch liegt auf derselben Datei, aber nicht auf demselben Abschnitt.**
[slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md) beschreibt drei Fähigkeiten,
die der Vertrag zusagt und der Ist-Text verschweigt — Workflow-Commands, Reviewer-/Closure-Skill,
Pointer-/Trust-Abschnitt der emittierten README. Die Grenze ist die **Form**: dort Prosa über
Fähigkeiten (§4, §9), hier die Pfad-Aufzählung in §6 und ihr Wächter. Keine Reihenfolge ist
erzwungen, und der Wächter aus DoD (2) urteilt über Pfade, nicht über Absätze — er wird von
slice-195 weder rot noch grün.

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls sich zeigt, dass
  der Wächter aus DoD (2) eine **dritte** Bestands-Quelle braucht, die es noch
  nicht gibt (etwa einen Bootstrap-Lauf außerhalb von `make test`). Dann trennt
  ein Re-Schnitt den vollständigen Baum von seinem Wächter — der Baum allein hat
  Liefer-Wert, der Wächter ohne ihn nicht.
- `in-progress` → `open` (blockiert — Carveout?): falls der vollständige Baum in
  §6 als Lesehilfe unbrauchbar wird — 44 Zeilen statt 12 sind ein
  Benutzerhandbuch, kein `find`-Protokoll. Dann ist erst zu klären, wie
  Vollständigkeit und Lesbarkeit zusammengehen (zwei Bäume? ein Anhang?), bevor
  geschrieben wird.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(a)** beide Rot-Nachweise aus DoD (2) sind
gefahren und ihre Ausgabe gelesen — der weggenommene Emissions-Eintrag **und**
der erfundene Handbuch-Pfad, je mit der Meldung, die der Wächter dabei ausgibt;
**(b)** `make gates` und `make full-smoke` grün, `make mutate` grün über die CI.

Dazu: DoD vollständig; Review konform (Modul 10); Verifikation bestätigt
(Modul 11); jedes Risiko aus §6 mit Ausgang; Closure-Notiz mit
Steering-Loop-Lerneintrag; `git mv` nach `done/` als eigener Move-Commit. Den
Abschluss schreibt der **Planner** in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Vollständigkeit und Lesbarkeit ziehen gegeneinander.** Ein
  Benutzerhandbuch ist zum Lesen da; ein Baum mit **44** Dateien ist eine
  Bestandsliste. Wird der Baum unbenutzbar, ist die Rückführung nach `open` der
  richtige Zug (§4) und nicht die stille Kürzung — die wäre der Zustand, aus dem
  dieser Slice kommt. — **Ausgang:** <offen>
- **Der Wächter kann die falsche Ebene messen.** Prüft er die *Zahl* der
  Einträge statt der *Menge*, ist er grün, sobald ein Pfad gegen einen anderen
  getauscht wird — dieselbe Klasse, die
  [`BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  führt. DoD (2) verlangt darum den Mengen-Vergleich in beide Richtungen und
  nicht einen Zähler. — **Ausgang:** <offen>
- **`.harness/baseline/` bleibt aggregiert, und das ist eine bewusste Lücke.**
  Der vendored Baum steht als **ein** Eintrag mit seiner Datei-Zahl. Wächst er
  bei einem Baseline-Sprung, bleibt der Handbuch-Baum formal richtig, ohne die
  Änderung zu zeigen. Der Ausgang wäre ein zweiter Wächter über der Zahl; er ist
  hier **nicht** gebaut, und die Lücke steht benannt statt behauptet. —
  **Ausgang:** <offen>
- **Der Baum nennt eine Fähigkeit, die das Handbuch sonst nirgends einführt.** Nach §1 ist die
  Zeile der Feldliste die **erste und einzige** Erwähnung der Erfassung im ganzen Dokument
  ([`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)); ein
  Etikett im Baum ist kein Abschnitt. Wer das für zu wenig hält, hat recht — der Träger dafür ist
  [slice-111](slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md), nicht ein vierter
  DoD-Punkt hier (Modul 5 §Ziel-Form, ≤ 3). Bis er läuft, steht die Fähigkeit **benannt und
  unerklärt** da; das ist die bewusste Grenze dieses Schnitts und keine Auslassung. —
  **Ausgang:** <offen>
- **Der Baum kann aus dem Vertrag statt aus dem Bestand entstehen.** Wer beim Schreiben
  [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) daneben
  legt, nimmt `CLAUDE.md` auf — zugesagt, aber von keinem Emissions-Pfad angelegt (§1). Der
  Wächter aus DoD (2) fängt das in der einen Richtung (genannter Pfad ohne Emission), und genau
  dafür verlangt DoD (2) beide Richtungen; bis er steht, trägt allein die Regel aus §1. —
  **Ausgang:** <offen>
- **Die Register-Zeile hängt an einer fremden Entscheidung.** DoD (3) schreibt
  den Bestand zum Zeitpunkt der Umsetzung; fällt die Entscheidung aus
  [slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md) §6 **nach**
  diesem Slice, ändert sich der Baum noch einmal. Der Wächter aus DoD (2) fängt
  das — er wird dann rot, und das ist der gewollte Ausgang, nicht ein Fehler
  dieses Slice. — **Ausgang:** <offen>
- **Nicht in diesem Slice:** der Generator selbst
  ([slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md)), die
  emittierte Modul-Liste
  ([slice-073](../in-progress/slice-073-emittierte-doc-gate-module.md)), **die Erklärung der Erfassungsschicht —
  *was* erfasst wird, wie ein Adopter es ausliest oder abschaltet, und die zwei `make`-Ziele
  dafür**, und jede Aussage über den Bestand außerhalb von §6 des Handbuchs.
  Die Erklärungs-Hälfte ist **kein neu zu schneidender Slice**: sie liegt als
  [slice-111](slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md) in `open/` und führt
  sie in DoD (1) samt dem Nachzug an §5 *Konfiguration* und §9 *Glossar* des Handbuchs. Der
  Zuschnitt hier fügt ihr nichts hinzu und nimmt ihr nichts weg — er benennt nur die Naht (§4).
- **Ebenfalls nicht in diesem Slice: die Erklärung der drei übrigen zugesagten Fähigkeiten** —
  Workflow-Commands, Reviewer-/Closure-Skill und der Pointer-/Trust-Abschnitt der emittierten
  README. Ihre Pfade zeigt DoD (1) wie jeden anderen; was sie **leisten**, führt
  [slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md).
- **Und ebenfalls nicht: zwei Soll/Ist-Deltas.** Die Sprachenliste in
  [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) und `CLAUDE.md`
  in [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
  nennen, was der Bestand nicht führt — der Normalfall zwischen einem Zielbild und einem Bestand
  und kein Befund; gemessen stehen beide in
  [slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md) §6. Für diesen Slice folgt
  daraus **eine** Regel und sonst nichts: Der Baum zeigt, was der Emitter anlegt (§1).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) —
[`docs/user/`](../../../../docs/user) und [`test/`](../../../../test) liegen
darunter. `harness/tools/` und `.codex/` sind **nicht** berührt; der Wächter aus
DoD (2) läuft dort nicht, und wenn die Umsetzung ihn dorthin legt, ist die
Sub-Area-Wahl neu zu stellen.

**Vorgelagert — offene Beobachtungen sichten:** Die Ablage
[`observations/`](../observations/README.md) ist durchgegangen; je Slug die Zahl
der `evidence/`-Dateien und die erste Zeile seiner `state.md`:

```sh
for s in zusage-neben-geaenderter-ableitung-bleibt-stehen \
         vollstaendigkeits-zusage-misst-falsche-ebene \
         emittierte-vorlagen-klassifikation-ohne-traeger \
         zusage-nennt-sensor-der-form-nicht-sieht \
         ueberholter-offener-plan-ohne-genormten-ausgang \
         slice-plan-umfang-waechst-ueber-umsetzung-hinaus; do
  d="docs/plan/planning/observations/BEO-ALL/$s"
  echo "$s $(ls "$d/evidence" | wc -l)x $(head -1 "$d/state.md")"
done
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die sechs Einträge des Kommandos berühren diesen Slice, weitere
Treffer: keine.

- [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **der Gegenstand dieses Slice.** Der `state.md` des Eintrags nennt genau
  diese Unterklasse als das, was offen bleibt: *„jede Unterklasse, in der die
  Zusage kein Anker ist … dort ist der Ausgang eine Regel ohne Sensor"*. DoD (2)
  ist der Sensor für **eine** dieser Unterklassen — die Bestands-Beschreibung —,
  nicht für alle. Was er nicht deckt, bleibt am Eintrag.
  **Der Befund aus §1 ist ein weiteres Vorkommen genau dieser Klasse:** die Ableitung hat sich
  bewegt (die Init-Strecke bekam die Erfassungs-Stufe), die Zusage daneben — der Baum in §6 —
  stand still. Er ist **benannt, nicht gezählt**: dieser Slice ist nicht geschlossen, und ein
  Beleg entsteht bei der Closure, nicht bei der Planung
  (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register).
- [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  — **getroffen**: ein Wächter über einer *Zahl* statt einer *Menge* wäre genau
  ihr Fall. Steht als Risiko in §6 und ist der Grund, warum DoD (2) den
  Mengen-Vergleich in beide Richtungen verlangt.
- [`emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  — berührt, **nicht getroffen**: dieser Slice klassifiziert keine Vorlage. Er
  macht die Folgen einer Klassifikation nur sichtbar, was der Eintrag als
  fehlenden Träger führt.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  — berührt, weil DoD (2) einen Sensor zusagt. **Nicht getroffen**, solange die
  zwei Rot-Nachweise aus §5 (a) gefahren sind: ein Sensor, der beide Richtungen
  rot gesehen hat, sieht die Form. Die verworfene Soll-Quelle aus §3 wäre der Gegenfall gewesen —
  ein Wächter, dessen Prüfbereich die Form gar nicht enthält.
- [`ueberholter-offener-plan-ohne-genormten-ausgang`](../observations/BEO-ALL/ueberholter-offener-plan-ohne-genormten-ausgang/observation.md)
  — **berührt, Zuordnung offen.** Die geteilte Hälfte ist wörtlich die Lage aus §4: *„Wer ihn
  liegen lässt, führt einen zweiten Anspruch auf dieselbe Linie"* — zwei offene Pläne über §6 des
  Handbuchs, mit entgegengesetzter Formantwort. (Der dritte,
  [slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md), steht daneben und nicht
  dagegen: er beschreibt Fähigkeiten und beantwortet die Formfrage nicht.) Der Anlass ist ein
  **anderer**: die Identitäts-Zeile
  des Eintrags bindet ihn an einen Versions-Sprung, hier ist es ein zweiter Schnitt auf dieselbe
  Fläche. Ob das dieselbe Beobachtung ist oder eine benachbarte, entscheidet der Lauf, der den
  Beleg schreibt — nicht dieser Plan, und eine unveränderliche `observation.md` wird dafür nicht
  gedehnt.
- [`slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md)
  — berührt durch die Aufnahme des Befundes selbst. **Nicht getroffen:** die Beweisführung wächst,
  die **Liefer-Zahl nicht** — der Befund präzisiert DoD (1) und korrigiert die Soll-Quelle in
  DoD (2), statt einen vierten Punkt anzuhängen; die Erklärungs-Hälfte geht an einen Plan, den es
  schon gibt (§6). Ein vierter Punkt wäre hier zugleich der Verstoß gegen Modul 5 §Ziel-Form und
  ein Vorkommen dieses Eintrags gewesen.

**Alle berührten Sub-Areas GF.** Der Modus-Begründungsblock entfällt damit
(§Umfang oben); `*` steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
als Greenfield, und dieser Slice führt keine neue Sub-Area ein.
