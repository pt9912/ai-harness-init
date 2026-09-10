# Slice slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr — Schritt 5 der Kopier-Prozedur läuft

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle (reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Slice über einer Emit-Regel, einzeln
lieferbar. **(2) Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner
eigenen DoD. **(3) Auslöser reaktiv oder gewollt?** Reaktiv: ein Review-Lauf hat einen Schritt der
Kopier-Prozedur benannt, den das Emit nicht ausführt. Kein Fähigkeits-Sprung — das Werkzeug lernt
nichts Neues, es tut den Schritt zu Ende, den es zur Hälfte tut. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist der Baum, den ein Bootstrap ablegt. Die
Guidance-Kommentare in `AGENTS.md`, `harness/conventions.md` oder `spec/lastenheft.md` **dieses**
Repos sind kein Gegenstand — sie stehen dort seit dem eigenen Bootstrap und sind gefüllt worden,
nicht emittiert.

**Bezug:**
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (was der Bootstrap ablegt,
ist ein Repo-File),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Singletons
werden *zu gestempelten `.md`-Zielen* — der Satz, an dem die halbe Ausführung hängt),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die
Command-Vorlagen tragen **adaptierbare Marker** — die Ausnahme, die dieser Slice **nicht**
anfassen darf),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (der vendored Baum
reist unverändert mit und ist ebenfalls keine Ausnahme, sondern gar kein Gegenstand),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0005`](../../adr/0005-ziel-repo-distribution.md),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel nennt, was sie rot färbt),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(der Vorlagen-Satz gehört dem Kurs — geändert wird das Emit, nie die Vorlage),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).

**Berührte Spec-Stellen:**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — der Satz
*„Singletons … werden zu gestempelten `.md`-Zielen"*. Der Verweis zeigt **aufwärts**: das
Lastenheft nennt diesen Slice nie.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-30.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Was das Werkzeug emittiert, ist ein Repo-File und keine Vorlage — auch dort, wo die Hilfe im
HTML-Kommentar steht statt im Blockquote.**

Der Befund stammt aus dem Review-Durchgang zu
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md); dessen §6 verlangt
für jeden übergebenen Posten eine Slice-ID, und **dieser Slice ist sie** — für den
`StripHintBlock`-Posten und den `BEDIENHINWEIS`-Posten zugleich, weil beide dieselbe Ursache haben
(unten gemessen: jeder Bedienhinweis im emittierten Baum steht **in** einem HTML-Kommentar, nicht
daneben).

### Die Prozedur hat sechs Schritte, das Emit führt fünf davon

Der Set-Index des vendored Satzes schreibt vor, wie eine Vorlage zu einem Repo-File wird
(`sed -n '/^## Verwendung/,/^## /p' .harness/baseline/v6.5.0/templates/README.md`). Schritt 4
lautet *„Template-Hinweis-Block oben entfernen"*, Schritt 5 *„HTML-Kommentar-Hilfen entfernen
(`<!-- ... -->`) — **außer** `<!-- d-check:ignore … -->`-Marker"*. Beide Schritte sind im Baum
belegbar:

```sh
grep -c 'HTML-Kommentar-Hilfen entfernen' .harness/baseline/v6.5.0/templates/README.md  # -> 1
grep -c 'func StripHintBlock' internal/emit/templates.go                                # -> 1  (Schritt 4)
grep -c 'd-check:ignore' internal/emit/templates.go                                     # -> 9  (Schritt 5)
```

**Die dritte Zeile ist der Befund und zugleich der Liefer-Nachweis.** Beim Schnitt lieferte sie
**0** — Schritt 5 lief nicht, und das ist der Grund, aus dem dieser Slice existiert. Die **9** oben
ist über den adoptierten Stand am Abschluss gemessen. Beide sind **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); tragend ist die Bewegung von null auf nicht-null. **Die Baseline-Adresse in diesem
Block und in §3 ist beim Abschluss auf den adoptierten Stand gezogen** — sie nannte `v5.18.0` bzw.
`v5.12.0`, und vendored liegt allein `v6.5.0` (`ls .harness/baseline/`); die Kommandos liefen so
ins Leere. Schritt 4 und Schritt 5 stehen im adoptierten Set-Index wortgleich, die Messung ist über
ihm neu gefahren (§6 Risiko 4).

`StripHintBlock` trifft nur den Blockquote, der die Zeichenkette `Template-Hinweis` führt. Die
HTML-Kommentare bleiben stehen — und mit ihnen die Bedienhinweise, denn die stehen **in** einem
HTML-Kommentar, nicht daneben.

### Der Ist-Bestand, gemessen am emittierten Baum statt am Vorlagen-Satz

```sh
B=.harness/state/bin/ai-harness-init                 # aus `make host-bin`
P=$(mktemp -d); (cd "$P" && git init -q . && "$B" --name probe >/dev/null)
find "$P" -name '*.md' -not -path '*/.git/*' -not -path '*/.harness/baseline/*' -print0 \
  | xargs -0 grep -n '<!--' | grep -v 'd-check:ignore' > /tmp/rest.txt
wc -l    < /tmp/rest.txt                              # -> 55  Kommentar-Hilfen gesamt
grep -c  '/\.claude/'  /tmp/rest.txt                  # -> 10  ANPASSEN-Marker, sie BLEIBEN
grep -vc '/\.claude/'  /tmp/rest.txt                  # -> 45  aus dem vendored Satz, sie GEHEN
cut -d: -f1 /tmp/rest.txt | grep -v '/\.claude/' | sort -u | wc -l   # -> 10 Dateien
```

**Die Zahlen wandern** mit dem Vorlagen-Satz und mit dem Emitter und sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). **Die Trennlinie ist die Herkunft, nicht der Wortlaut:** die **10** unter `.claude/`
kommen aus dem eigenen Vorlagen-Satz `internal/emit/templates/` und tragen `ANPASSEN`-Marker, die
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
ausdrücklich verlangt (*„tragen repo-spezifische Stellen … als **adaptierbare** Marker"*); die
Kopier-Prozedur des Kurses spricht nicht über sie. Die **45** kommen aus dem vendored Satz, und für
sie gilt Schritt 5.

### Der schärfste Fall sagt es selbst

Der erste Bedienhinweis in der emittierten `observations.md` unter `docs/plan/planning/` lautet
wörtlich
*„BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md §Verwendung, Schritt 5) und darf
deshalb nichts Tragendes halten."* Er fällt nicht weg. Ein Adopter liest in seinem eigenen Register
einen Satz, der seine eigene Abwesenheit behauptet — und darunter eine Muster-Tabelle mit
erfundenen `BEO-<NNN>`-Zeilen im abgelösten Nummern-Schema, gegen die derselbe Block warnt.
Dieselbe Form steht im
emittierten `docs/plan/planning/in-progress/roadmap.md`
(`grep -rl 'BEDIENHINWEIS' "$P" | grep -v '/\.harness/baseline/'` → **2** Dateien).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Kein emittiertes Dokument aus dem vendored Satz trägt noch eine Kommentar-Hilfe, und
      die zwei Ausnahmen sind gemessen unberührt.** Über den Baum aus §1: **jede** verbliebene
      Fundstelle der `grep -vc '/\.claude/'`-Zeile ist einzeln klassifiziert und **keine** davon
      ist eine Kommentar-Hilfe, die `grep -c '/\.claude/'`-Zeile bleibt unverändert, und jeder
      `d-check:ignore`-Marker steht noch
      (`grep -rc 'd-check:ignore' "$P" --include='*.md' | grep -v ':0$'` liefert dieselbe Menge wie
      vorher). **Vorher-Nachher über dasselbe Kommando**, nicht gegen eine notierte Zahl.

      **Der Zielwert ist bei der Closure korrigiert, und hier steht warum.** Der Punkt band die
      Abnahme ursprünglich an den Wert **0**. Eine *richtige* Behebung hat ihn legitim auf **1**
      gehoben: die Regel schont seit Runde 1 das Backtick-**Zitat** der Kommentar-Syntax, statt es
      zu zerstören, und das Zitat trägt ein `<!--`, das der Zähler mitzählt. Der Wert 0 war damit
      nicht mehr erreichbar, ohne ein emittiertes Norm-Artefakt zu beschädigen — die ausführende
      Rolle durfte ihn nach [`AGENTS.md`](../../../../AGENTS.md) §3.10 nicht anfassen und hat die
      Verschiebung dreifach als Übergabe-Artefakt gemeldet. **Ersetzt ist nicht die Zahl durch eine
      andere Zahl**, sondern das Instrument durch eines, das die Sache misst: Ein `<!--`-Zähler
      trennt eine **Hilfe** nicht von einem **Zitat**, also entscheidet die Klassifikation jeder
      Fundstelle statt ihrer Summe. Das ist der schärfere Falsifikator — bei einem festen Wert 1
      bliebe der Punkt grün, wenn eine Hilfe überlebte und das Zitat verschwände. Eine wandernde
      Zahl als Erwartungswert festzuschreiben verbietet ohnehin
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2.

      **Erfüllt, am Abschluss selbst gemessen** (Träger aus `make host-bin`, Emit in ein leeres
      `git init`-Verzeichnis außerhalb des Repos): Die Zeile liefert **11** Fundstellen —
      **10** unter `.claude/` (die `ANPASSEN`-Marker aus
      [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren),
      unverändert) und **1** darüber hinaus:
      `.harness/skills/reviewer.md:30`, byte-gleich zu
      `.harness/baseline/v6.5.0/templates/.harness/skills/reviewer.template.md:42` und damit
      unbeschädigt. Keine Erwartungswerte. Der schärfste Fall aus §1 ist weg —
      `grep -rl 'BEDIENHINWEIS' "$P" | grep -v '/\.harness/baseline/'` liefert **0** Dateien (§1
      nannte 2); die HIGH-3-Sonde `grep -rn '``[^`]' "$P" --include='*.md'` trifft nur
      Code-Fence-Anfänge (```` ```mermaid ````, ```` ```json ````), keine leergeräumte
      Inline-Code-Spanne. Die `d-check:ignore`-Menge steht vollständig.
- [x] **(2) Ein `test/mutations/`-Fall färbt die Regel rot.** Ohne ihn ist (1) eine Zusage ohne
      Gegenbeispiel ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Der Fall trifft die Stelle, die der
      Emitter wirklich benutzt — nicht eine im Test nachgebaute Verdrahtung.
      **Erfüllt:** vier Fälle (`291`–`294`). `291` und `292` treffen die **zwei getrennten,
      gleichrangigen** Verdrahtungen — `planTemplates` (`internal/emit/templates.go`) und
      `RootReadme` (`internal/emit/readme.go`), gemessen mit
      `grep -rn 'StripCommentHints' internal/emit/*.go | grep -v _test`: genau diese zwei
      Aufrufstellen und keine dritte. `293`/`294` treffen die Maskierungs-Hälfte. Alle vier sind in
      zwei vollständigen `make mutate`-Läufen (je 280 ok, 0 Befund(e)) real rot gesehen worden.
      **Was der Punkt nicht deckt und was darum §7 trägt:** `dcheckIgnoreMarkerPattern`,
      `backtickSpanPattern` und `unmaskQuotedCommentSyntax` sind in keinem Fall genannt.
- [x] `make gates` bringt **keinen Befund hervor, der diesem Slice zuzurechnen ist** — Vorher-
      Nachher-Vergleich derselben Ausgabe, nicht „grün": der Lauf trägt fremde Posten mit eigenen
      Folge-Slices (§6). Dazu `make smoke` und `make full-smoke` über denselben Baum, weil der
      Gegenstand **emittiert** ist und `make gates` ihn nicht sieht (§6).
      **Erfüllt:** alle drei in der Verifikation gefahren, alle drei grün
      (`docs-check` 1043 Datei(en) / 0 Befund(e), `comment-claims` 57 / 0, `span-check` OK;
      `full-smoke` über die volle Matrix). Der Gate-Stempel deckt den Baum dieser Closure —
      `cat .harness/state/gates-passed.diffsha` und `bash harness/tools/working-tree-hash.sh`
      liefern denselben Wert.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist. **Kein öffentlicher Vertrag
      berührt:** Der Gegenstand ist der emittierte Baum, kein Gate und kein `make`-Ziel;
      [`harness/README.md`](../../../../harness/README.md) und
      [`AGENTS.md`](../../../../AGENTS.md) bleiben unverändert. Die Grenzen der neuen Funktion
      stehen an ihr selbst, nicht in einem Register.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag. **Erfüllt:** §7.
- [x] Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap und führt keines; das Item
      entfällt mit diesem Grund, nicht still.
- [x] Beobachtungs-Register fortgeschrieben: neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine
      weitere Beleg-Datei im vorhandenen `evidence/` unter
      [`../observations/`](../observations/) — *keine Beobachtung angefallen* ist ebenfalls eine
      Antwort und wird in §7 notiert. **Erfüllt:** elf Belege, vier Verzeichnisse neu; Stände in
      §7, wo auch steht, warum die Adress-Form dieses Punktes bei der Closure gezogen wurde.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
      **Erfüllt:** vier Risiken, vier Ausgänge — drei *entfallen*, eines *weiter offen*; siehe §6.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste Welle-Closure — dieses
      Repo fährt Wellen-Betrieb, und die liest auch Slices ohne Wellen-Zugehörigkeit.
      **Erfüllt als Zuweisung, nicht als Prüfung:** `welle-09` und `welle-13` stehen offen
      (`ls docs/plan/planning/welle-*.md` gegen den Abschnitt *Offene Wellen* der Roadmap), also
      liegt der Lese-Schritt dort. Als Übergabe ist die Deckung trotzdem gefahren — Ergebnis in §7.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | update | Schritt 5 der Kopier-Prozedur läuft im Emit-Pfad der Singletons — dort, wo `StripHintBlock` heute Schritt 4 tut; die `d-check:ignore`-Ausnahme steht in derselben Funktion, nicht in einer Liste daneben |
| `internal/emit/readme.go` | update | **bei der Closure nachgetragen, nicht beim Schnitt geplant.** `RootReadme` ist die **zweite**, gleichrangige Verdrahtung derselben Singleton-Klasse (`project-readme.template.md`); das Mess-Kommando in §1 deckt sie ohne Unterscheidung mit ab, die Tabelle nannte sie nicht. Kein Scope-Leck — die Verifikation hat den Diff dagegen gehalten und keine weitere ungeplante Datei gefunden |
| `internal/emit/` (Test) | neu | die Regel wird über den **realen** Vorlagen-Satz gemessen, nicht über eine Fixture — die Grenze aus `.dockerignore` steht in §6 |
| `test/mutations/` | neu | ein Fall, der die Regel aushebelt und den Wächter rot färbt |
| `.harness/baseline/v6.5.0/templates/**` | **unverändert** | der Satz gehört dem Kurs ([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)) und liegt unveränderlich vendored; geändert wird das Emit, nie die Vorlage. *(Die Zeile nannte `v5.12.0`; die Adresse ist bei der Closure auf den adoptierten Stand gezogen — §6 Risiko 4.)* |
| `internal/emit/templates/**` | **unverändert** | der eigene Vorlagen-Satz; seine `ANPASSEN`-Marker sind nach [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) gewollt und dürfen nicht mitfallen |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md)
liegt in `done/`. Der Grund ist **tragend, nicht ordnend**: jener Slice entscheidet, welche Vorlage
überhaupt emittiert wird, und der Prüfbereich dieses Slice ist genau die Ergebnis-Menge. Läuft er
davor, misst dieser Slice über einem Satz, den der andere noch verändert.

**Reihenfolge innerhalb von `next/`: vor
[slice-073](../done/slice-073-emittierte-doc-gate-module.md) — Ökonomie, kein Zwang.** Dieser Slice
entfernt die Kommentar-Hilfen des vendored Satzes auch aus der emittierten AGENTS- und
Konventions-Datei; genau deren Prosa trägt die zwei `codepath-missing`-Befunde, an denen jener
Slice `codepaths` heute als nicht emittierbar führt. Läuft dieser zuerst, misst jener einmal statt
zweimal.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn sich zeigt, dass die Entfernung
  eines HTML-Kommentars in mindestens einer Vorlage die Markdown-Struktur um ihn herum ändert
  (Leerzeilen-Semantik, Tabellen-Fortsetzung) und der Slice damit zwei Gegenstände trägt — die
  Regel und ihre Struktur-Reparatur.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein entfernter Kommentar tragenden Inhalt
  hält, der nirgendwo sonst steht. Dann ist die Frage *was gehört in den emittierten Stand* keine
  Emit-Frage mehr, sondern eine an die Vorlage — und die gehört dem Kurs.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **das Kommando aus §1 liefert über den frisch emittierten Baum
`0` Kommentar-Hilfen aus dem vendored Satz bei unveränderter `ANPASSEN`- und
`d-check:ignore`-Menge**, und **`make smoke` wie `make full-smoke` sind grün**. Dazu die
Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

**Vier Risiken, vier Ausgänge** — je einer aus der geschlossenen Menge *eingetreten · entfallen ·
weiter offen*. Drei *entfallen*, eines *weiter offen*; keines *eingetreten*, und bei zweien steht
unten, warum der vorformulierte Ausgang nicht getragen hätte. **Das ist selbst ein Befund:** Zwei
der vier Risiken boten beim Schnitt Ausgänge an, die auf den tatsächlichen Verlauf nicht passen —
einer beschrieb unter *eingetreten* die Nachbar-Form statt des Falls, einer nannte unter demselben
Namen eine benannte Grenze, die Modul 5 dort nicht vorsieht (dort steht Carveout oder Folge-Slice). Ein vorformulierter Ausgang ist eine
Hypothese über den Ausgang, kein Ausgang; §7 trägt das als Lerneintrag.

- **Ein HTML-Kommentar kann tragenden Inhalt halten.** Die Prozedur nennt eine einzige Ausnahme
  (`d-check:ignore`); ob sie die einzige **nötige** ist, sagt sie nicht. Ein Kommentar, der eine
  Struktur zusammenhält statt sie zu erklären, fiele mit. Die Bezugsmenge ist das Kommando aus §1,
  keine Zahl hier.
  — **Ausgang: entfallen**, und der vorformulierte Wortlaut ist wörtlich der, der zutrifft: *jede
  Fundstelle des Kommandos einzeln geprüft, keine trägt.* Bei der Closure selbst gefahren über
  einem frisch emittierten Baum: **11** Fundstellen — **10** `ANPASSEN`-Marker unter `.claude/`
  (nach [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
  gewollt, nicht Gegenstand der Regel) und **1** Backtick-**Zitat** der Kommentar-Syntax in
  `.harness/skills/reviewer.md:30`, byte-gleich zur Vorlage. Kein Kommentar des emittierten Baums
  hält tragenden Inhalt, der mit Schritt 5 fiele.

  **Warum nicht *eingetreten*, obwohl die zweite Frage des Risikos mit Nein beantwortet ist.**
  `d-check:ignore` war **nicht** die einzige nötige Ausnahme — eine zweite (das Backtick-Zitat)
  musste gebaut werden, und ihr Fehlen hat in Runde 1 real ein emittiertes Norm-Artefakt
  entwertet. Der Gegenstand des Risikos ist aber ein **Kommentar**, der Inhalt hält; getroffen
  war ein **Zitat** der Kommentar-Syntax, das die Regel für einen Kommentar hielt — die
  Nachbar-Form, nicht der Fall. Und *eingetreten* verlangt nach Baseline-Regelwerk
  `modul-05-planning-harness.md` einen Carveout oder einen Folge-Slice: Ein Carveout hat keinen
  Gegenstand (kein Gate ist rot), und ein Folge-Slice hätte keinen Auftrag — die Behebung ist
  **in** diesem Slice gelaufen und durch `293`/`294` bewacht. Das Risiko ist verbraucht, nicht
  vertagt.

  **Die §4-Rückführung `in-progress → open` ist damit zu Recht nicht gezogen worden**, und zwar
  aus ihrem eigenen Grund: Sie begründet sich mit *„dann ist die Frage … keine Emit-Frage mehr,
  sondern eine an die Vorlage"*. Die Vorlage war unverändert richtig — nachgemessen, die Zeile ist
  byte-gleich zu `.harness/baseline/v6.5.0/templates/.harness/skills/reviewer.template.md:42` —,
  falsch war der Emitter. Eine Vorwärts-Korrektur war die passende Antwort, der Rückweg wäre die
  falsche gewesen.

  **Was als benannte Grenze bleibt, statt als Risiko:** Zwei Lückenformen der Näherung
  (Doppel-Backtick-Span, zwei freistehende Backticks) sind bewusst nicht behoben — Entscheidung
  des Auftraggebers, in §7 als solche festgehalten. Keine ist im heutigen Vorlagen-Satz auslösbar
  (die drei Proben am Doc-Block bei der Closure erneut gefahren, alle drei leer), und sie stehen
  im Kommentar ausdrücklich als **Beispiele einer offenen Liste**, nicht als Katalog — der zweite
  von [`AGENTS.md`](../../../../AGENTS.md) §3.6 zugelassene Weg.
- **Kein Ziel in `make gates` fährt den realen Vorlagen-Satz und die Emit-Regel zusammen.**
  `.dockerignore` führt `.harness`, die Go-Test-Stufe sieht den vendored Baum also nicht; der
  Nachweis hängt an `make smoke`/`make full-smoke`, und der zweite braucht Netz.
  — **Ausgang: weiter offen**, wandert ins Beobachtungs-Register als
  [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md),
  Zähler **1×** — unter der Schwelle, also ohne Ausgang.

  **Die Bedingung besteht unverändert, gemessen statt übernommen:** `.dockerignore` führt
  `.harness` in Zeile 5, der Integrations-Wächter läuft gegen die `courseSet()`-Fixture, und
  `test/courseset-fixture.bats` hält von ihr nur Dateibestand und Platzhalter-Pfad-Form gegen den
  realen Satz, **keine Kommentare**. Schärfer als der Risikotext vermutete: Auch der genannte
  Ersatz-Sensor trägt nicht — `make smoke` prüft ein emittiertes `docs-check` mit
  `modules: [links, anchors]` und bliebe grün, wäre die Funktion gar nicht verdrahtet. Damit deckt
  weder `make gates` noch CI die reale Wirkung; es bleibt `make full-smoke`.

  **Warum der dritte Ausgang und nicht der vorformulierte zweite.** Der Plan schrieb für
  *eingetreten* eine **benannte Grenze** vor — die steht auch, wörtlich am Wächter
  (`internal/emit/templates.go`, Absatz *„Ob die Regel den REALEN Vorlagen-Satz erreicht, misst
  kein Gate"*). Nur ist *eingetreten* nach Baseline-Regelwerk
  `modul-05-planning-harness.md` an einen Carveout oder einen Folge-Slice gebunden, und keiner von
  beiden hat hier einen Gegenstand: Es ist kein Gate rot, und die Bedingung ist nicht *geschehen
  und vorbei*, sondern **steht weiter** — für den nächsten Emit-Slice genauso. Genau dafür ist der
  dritte Ausgang da: *„Der dritte Ausgang hängt das Risiko an den Zähler, statt einen zweiten
  Mechanismus zu erfinden: drei Slices lang offen heißt Schwelle erreicht."* Trifft der nächste
  Emit-Slice dieselbe Wand, eskaliert das Register es zum Slice — ohne dass diese Closure einen
  Auftrag erfindet, den niemand erteilt hat.
- **Die Herkunfts-Trennung ist heute ein Pfad-Präfix.** Dass die zu erhaltenden Marker unter
  `.claude/` liegen, ist eine Eigenschaft des heutigen Emit-Bestands, keine Zusage: kommt ein
  Dokument aus `internal/emit/templates/` außerhalb dieses Präfixes dazu, trennt das Präfix nicht
  mehr. Der Wächter muss an der **Quelle** unterscheiden, nicht am Zielpfad.
  — **Ausgang: entfallen**, im vorformulierten Wortlaut: *die Unterscheidung liegt am Emit-Pfad,
  nicht an einem Präfix.* Selbst gemessen:
  `grep -rn 'StripCommentHints' internal/emit/*.go | grep -v _test` nennt genau **zwei**
  Aufrufstellen — `templates.go:364` (`planTemplates`) und `readme.go:44` (`RootReadme`);
  `grep -c 'StripCommentHints' internal/emit/agents.go internal/emit/commands.go` liefert **0**
  und **0**. Die `.claude/`-Dokumente mit ihren `ANPASSEN`-Markern entstehen also auf Pfaden, die
  die Regel überhaupt nicht anfassen — der Pfad-Präfix in den Mess-Kommandos ist eine **Ablesehilfe
  für die Messung**, nicht das trennende Merkmal im Code. Ein neues Dokument aus
  `internal/emit/templates/` außerhalb von `.claude/` bliebe damit ebenso unberührt, solange es
  nicht durch `planTemplates`/`RootReadme` läuft; die im Risiko befürchtete stille Kopplung an
  einen Zielpfad besteht nicht.
- **Zwei Mess-Kommandos und eine Plan-Zeile nennen einen Baseline-Tag, den das Repo nicht führt.**
  §1 liest den Set-Index unter `.harness/baseline/v5.18.0/`, §3 nennt `.harness/baseline/v5.12.0/`;
  vendored liegt allein der adoptierte Stand (`ls .harness/baseline/`). Die Kommandos laufen so ins
  Leere, und kein Gate sagt es: `codepaths.roots` führt `[spec, docs, harness]`, ein Pfad unter
  `.harness` liegt außerhalb
  ([slice-201](../done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md)). Der Bezug ist der
  Schritt 5 des Set-Index, nicht ein Tag — der Lauf zieht die Adressen auf den adoptierten Stand
  nach, bevor er misst.
  — **Ausgang: entfallen**, im vorformulierten Wortlaut: *die Adressen sind nachgezogen und die
  Messung neu gefahren.* Nachgezogen hat sie **diese Closure**, nicht der ausführende Lauf — die
  drei Fundstellen (§1-Fließtext, §1-Codeblock, §3-Tabelle) nannten `v5.18.0` bzw. `v5.12.0`,
  `ls .harness/baseline/` führt allein `v6.5.0`. Über dem adoptierten Stand neu gefahren, und die
  Bezugs-Aussage hält: Der Set-Index trägt Schritt 4 und Schritt 5 wortgleich
  (`sed -n '/^## Verwendung/,/^## /p' .harness/baseline/v6.5.0/templates/README.md`), und
  `grep -c 'HTML-Kommentar-Hilfen entfernen' .harness/baseline/v6.5.0/templates/README.md`
  liefert **1**. Der Slice hing damit nie an einem Tag, sondern an einem Prozedur-Schritt, den auch
  der adoptierte Stand führt — nur waren die Adressen tot, und **kein Gate sagt das**:
  `codepaths.roots` führt `[spec, docs, harness]`, ein Pfad unter `.harness` liegt außerhalb.
  Die Klasse ist im Register bereits geführt
  ([`BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht`](../observations/BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht/observation.md),
  Ausgang als [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)
  geschnitten) — **kein neuer Beleg von hier**: Dieser Slice hat den toten Pfad nicht geschrieben,
  er hat ihn geerbt, und die Klasse trifft den schreibenden Lauf.

## 7. Closure-Notiz

**Rolle:** Planner (frischer Kontext, [`AGENTS.md`](../../../../AGENTS.md) §3.10) · **Datum:**
2026-09-10

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennungen **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert: die Vorwärts-Korrektur statt des Rückwegs.** §4 hatte die Rückführung
  `in-progress → open` für genau den Fall vorformuliert, der in Runde 1 eintrat — ein entfernter
  Kommentar beschädigt tragenden Inhalt. Der Rückweg wurde **nicht** gezogen, und das war richtig:
  Seine eigene Begründung lautet *„dann ist die Frage … eine an die Vorlage"*, und die Vorlage war
  unverändert richtig. Der Fehler lag im Emitter, also gehörte er dort behoben. Eine
  Rückführungs-Bedingung, die **auslöst**, ist damit noch kein Auftrag zurückzugehen — ihr
  *Grund* entscheidet, nicht ihr Wortlaut. Das Zweite, das getragen hat: der Slice hat über die
  ganze Kette **den emittierten Baum** gemessen, nie den Vorlagen-Satz. Der schärfste Fall aus §1 —
  ein `BEDIENHINWEIS`-Block, der seine eigene Abwesenheit behauptet — ist genau deshalb sichtbar
  geworden und heute weg.
- **Was ging anders als geplant: der Code war nach Runde 4 fertig, der Kommentar nach Runde 7.**
  Sieben Review-Runden, sechs davon blockierend. Code, Gate-Lage und Emit standen seit Runde 4
  unverändert; die Runden 5, 6 und 7 betrafen **ausschließlich** den Doc-Block, der die Grenzen der
  Regel beschreibt. Und dreimal in Folge hat der Fix für einen Befund den nächsten eingesetzt
  (4→5, 5→6, 6→7) — jedes Mal dieselbe Familie: eine Deckung benennen, die nicht deckt. Aufgelöst
  ist es nicht durch eine bessere Messung, sondern durch **Streichen**: Der Block sagt jetzt an der
  strittigen Stelle, dass **nichts** deckt — der zweite von
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 ausdrücklich offen gelassene Weg, und der einzige, der
  nicht auf dieselbe Weise wieder brechen kann. **Die Asymmetrie ist die Lehre:** Eine 30-Zeilen-
  Funktion war in einem Lauf geschrieben; die ehrliche Beschreibung dessen, was sie **nicht** kann,
  brauchte vier.
- **Eine Entscheidung des Auftraggebers, festgehalten als Entscheidung und nicht als Rest.** Nach
  vier Runden an derselben Heuristik ist entschieden worden, **zwei Lückenformen nicht zu
  beheben**: den Doppel-Backtick-Span (ein Backtick-**Lauf** der Länge zwei um ein Zitat) und die
  zwei freistehenden Backticks um eine echte Hilfe. Die Gründe stehen zusammen: Beide sind im
  heutigen Vorlagen-Satz **nicht auslösbar** (die drei Proben am Doc-Block bei dieser Closure
  erneut gefahren, alle drei leer; dazu positionell **0** Fence-Bindungen über vendored Satz,
  Fixture und emittiertem Baum), keine ist eine **Regression** — die Regel existierte vorher gar
  nicht —, und beide stehen im Kommentar ausdrücklich als **Beispiele einer offenen Liste**
  (*„Jede dieser Formen ist ein GEGENBEISPIEL gegen Vollstaendigkeit, kein Katalog"*), nicht als
  Katalog mit Lücken. Das ist kein Versäumnis: Die Alternative wäre gewesen, eine
  Zeilen-Paritäts-Näherung zu einem CommonMark-Parser auszubauen — ein anderer Gegenstand, und
  einer, den kein Befund verlangt hat. **Was der Preis ist, steht daneben:** Der Vorlagen-Satz ist
  Fremdtext, den [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
  bei jedem Re-Baseline vollständig tauscht; die drei Proben sind darum eine **notwendige, keine
  hinreichende** Bedingung und gehören beim nächsten Sprung erneut gefahren. Der Kommentar sagt
  genau das.
- **Steering-Loop-Eintrag — zwei, beide *benannte Spec-Lücke*, beide ohne `liegt in`.**

  **(a) Ein Review-Report darf melden, was nicht hält; was er als Erledigungsweg *vorschreibt*,
  muss er messen.** Runde 5 hat die Rückkehr einer gestrichenen Messung ausdrücklich als
  Erledigungsweg benannt, ohne zu prüfen, ob diese Messung ihre Eigenschaft trifft; der ausführende
  Lauf hat die verlangte Handlung geliefert, und Runde 6 hat das Ergebnis als HIGH gemeldet — die
  Zählung ist ordnungsblind. Eine Runde später trat die Spiegelform auf: Runde 7 prüfte einen Satz,
  der wörtlich aus dem Verdikt von Runde 6 stammte, und fand in der vorgeschriebenen Formulierung
  eine weitere Ungenauigkeit — gefunden nur, weil dieser Lauf die Eigenschaft mit einem eigens
  kalibrierten Instrument **unabhängig** maß, statt Formulierungen zu vergleichen. **Keine Quelle
  dieses Repos trägt die Regel:** Modul 10 normiert die Findings, Modul 8 die Übergabe-Artefakte,
  und beide schweigen dazu, dass eine *Vorgabe* denselben Beleg-Maßstab trägt wie ein *Befund*.
  Kennung:
  [`BEO-ALL/reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts`](../observations/BEO-ALL/reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts/observation.md),
  Zähler **1×** — unter der Schwelle, also *gezählt, nicht verkörpert*. **Der Träger gehört einer
  anderen Rolle:** Nach [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  ist `.harness/skills/reviewer.md` Reviewer-eigen, und diese Closure schreibt es nicht.

  **(b) Ein vorformulierter Risiko-Ausgang ist eine Hypothese über den Ausgang, kein Ausgang.**
  Zwei der vier §6-Risiken boten beim Schnitt Formulierungen an, die auf den eingetretenen Fall
  nicht passen: Risiko 1 beschrieb unter *eingetreten* die Nachbar-Form statt des Falls (getroffen
  war ein **Zitat** der Kommentar-Syntax, nicht ein **Kommentar**, der Inhalt hält), und Risiko 2
  nannte unter *eingetreten* eine benannte Grenze — einen Ausgang, den Baseline-Regelwerk
  `modul-05-planning-harness.md` unter diesem Namen nicht führt (dort steht Carveout **oder**
  Folge-Slice). Beide Male hat der Review die Diskrepanz gesehen und ausdrücklich an die Closure
  übergeben, statt eine passende Formulierung zu erfinden — der Mechanismus hat also getragen. Die
  Lücke ist die **Form**: Modul 5 verlangt, dass §4 die Rückführungs-*Bedingung* vorab benennt, und
  sagt über vorformulierte §6-*Ausgänge* nichts — weder dass sie erlaubt sind noch dass sie an die
  geschlossene Dreier-Menge gebunden wären. Ein Plan, der sie trotzdem schreibt, legt der Closure
  eine Antwort in den Mund, die der Fall nicht bestätigt. Kein Wächter kann das sehen: Kein Modul
  aus `modules:` der [`.d-check.yml`](../../../../.d-check.yml) liest §6, und `make mutate` kennt
  keine Fehlschlag-Form dafür. Ohne Register-Kennung — Erstauftreten, hier **benannt statt
  gezählt**, weil es eine Beobachtung über *diesen* Plan ist und nicht über eine Klasse, die schon
  einmal woanders auftrat.
- **Beobachtungs-Register (`../observations/`):** **elf** Belege, alle mit dem Vorgangs-Namen
  `slice-140` — sieben Review-Runden und eine Verifikation über *einem* Slice sind **eine**
  Gelegenheit, kein achtfaches Auftreten (`modul-06-roadmap.md`: *„Zwei Funde im selben Vorgang
  sind eine Gelegenheit, kein zweites Auftreten"*). **Sieben** in bestehende Verzeichnisse ergänzt,
  **vier** Verzeichnisse neu angelegt. Zähler als Dateizahl abgelesen
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
  Erwartungswerte**):
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  **19×** ·
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  **11×** ·
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  **8×** ·
  [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  **7×** ·
  [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  **5×** ·
  [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  **3×** ·
  [`commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md)
  **2×** · neu, je **1×**:
  [`neue-oeffentliche-funktion-ohne-benannte-grenze`](../observations/BEO-ALL/neue-oeffentliche-funktion-ohne-benannte-grenze/observation.md) ·
  [`reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts`](../observations/BEO-ALL/reparatur-vorgabe-ohne-messung-des-vorgeschriebenen-artefakts/observation.md) ·
  [`vorgelagerter-pflicht-schritt-bleibt-platzhalter`](../observations/BEO-ALL/vorgelagerter-pflicht-schritt-bleibt-platzhalter/observation.md) ·
  [`waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md).

  **Einer erreicht mit diesem Slice die Schwelle, und diese Closure weist ihm keinen Ausgang zu.**
  `neuer-waechter-ohne-mutations-fall` steht bei **3×**. Dieses Repo führt Wellen-Betrieb —
  `welle-09` und `welle-13` stehen offen —, damit liegt der **Lese-Schritt** bei der
  Welle-Closure, auch für einen Slice ohne Wellen-Zugehörigkeit (`modul-06-roadmap.md`
  §Wann Arbeit eine Welle braucht: *„Ein Repo mit Wellen hat eine Welle-Closure, und die liest und
  prüft alles, was seit der letzten Welle in `done/` liegt — auch Slices ohne
  Wellen-Zugehörigkeit"*). Zwischen dem Beleg, der den Zähler auf 3 hebt, und diesem Schritt steht
  der Eintrag `offen`; das ist ausdrücklich zulässig und vorübergehend. **Diese Closure zählt, sie
  entscheidet nicht.** Als Übergabe steht der Rückstand hier gemessen statt behauptet:

  ```sh
  for d in docs/plan/planning/observations/BEO-ALL/*/; do
    n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l)
    s=$(grep -m1 '^\*\*Stand:\*\*' "$d"state.md | sed 's/\*\*Stand:\*\* //')
    [ "$n" -ge 3 ] && [ "$s" = "offen" ] && printf '%3s  %s\n' "$n" "$(basename "$d")"
  done | sort -rn
  ```

  **Der Beleg zählt das Auftreten, nicht den Rest im Baum.** Die meisten dieser Klassen sind
  innerhalb des Vorgangs behoben worden; gezählt werden sie trotzdem — der Zähler misst
  Wiederholung über Vorgänge hinweg, und eine Klasse, die nur zählt, wenn sie ungefixt liegen
  bleibt, misst die Gründlichkeit des Reviews statt der Häufigkeit des Musters.
- **Folge-Slices: keiner.** Eine Entscheidung, kein Versehen — und in einem Punkt gegen den
  Reflex dieses Repos. Drei Befunde hätten je einen Slice ausgelöst: die drei Bezeichner ohne
  Mutations-Fall, der fehlende Sensor über dem realen Vorlagen-Satz, die zwei offen gelassenen
  Lückenformen. Der erste steht bei **3×** und gehört damit dem Lese-Schritt der Welle-Closure, die
  über den Ausgang entscheidet — nicht dieser Closure. Der zweite ist als *weiter offen* an den
  Zähler gehängt (§6 Risiko 2); erreicht er die Schwelle, schneidet ihn der Lese-Schritt. Der
  dritte ist eine getroffene Entscheidung des Auftraggebers und braucht keine Adresse, sondern die
  benannte Grenze, die er hat. **Eine Adresse existiert bereits und wird nicht verdoppelt:** die
  toten Baseline-Pfade aus Risiko 4 hängen an
  [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md).
- **Risiken aus §6:** vier Risiken, vier Ausgänge — **drei *entfallen* mit Begründung, eines
  *weiter offen*** ins Register; siehe §6. Keines *eingetreten*: Das Risiko, das am nächsten daran
  war, ist **in** diesem Slice verbraucht worden (Behebung plus zwei Mutations-Fälle), und
  *eingetreten* verlangt einen Carveout oder einen Folge-Slice — beide ohne Gegenstand, wenn nichts
  rot ist und nichts übrigbleibt.
- **Bei der Closure am Plan selbst nachgezogen, vor dem Einfrieren** — dieselbe Bewegung wie in der
  Vorgänger-Closure, aus demselben Grund: Diese Datei wird mit dem `git mv` Chronik und wird nicht
  wieder angefasst. (1) Drei tote Baseline-Adressen (`v5.18.0`/`v5.12.0` → `v6.5.0`, §6 Risiko 4).
  (2) Die abgeschaffte Kennungs-Form `BEO-<NNN>` und die flache Registerdatei in §2 und §8 — das
  Nummern-Schema besteht nicht mehr, die Ablage ist seit
  [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  ein Verzeichnis je Beobachtung. Die Nennung in §1 bleibt: Sie beschreibt das abgelöste Schema
  ausdrücklich **als abgelöst** und ist dort richtig. (3) `internal/emit/readme.go` in der
  §3-Tabelle, mit sichtbarer Marke *bei der Closure nachgetragen* — die Datei ist die zweite,
  gleichrangige Verdrahtung derselben Singleton-Klasse und war vom §1-Mess-Kommando ohnehin
  gedeckt; ohne die Zeile läse jeder künftige Plan-vs-Code-Diff sie als Scope-Leck, und die
  Verifikation musste dafür einen eigenen Absatz schreiben.
- **Vor dem `git mv` gemessen ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** **fünf** eingefrorene
  Artefakte nennen diese Datei als Pfad — einer unter `done/`, vier Rollen-Reports —, außerhalb von
  Markdown **null**
  (`git grep -l 'slice-140-emittierter-stand-ohne-vorlagen-hilfen' -- ':!*.md' ':!.harness/baseline'`).
  `make slice-mv` nimmt weder `done/**` noch `docs/reviews/**` aus und schreibt sie im
  Nachzugs-Commit. Der Move ist trotzdem gefahren: Die Auflösung dieser Lage ist dem **Architect**
  zugewiesen, und bis dahin ist der bewegende Lauf der Träger — er hat hier gemessen und
  entschieden, statt es zu übersehen. Gezählt als siebter Beleg der Klasse.
- **Drei Paarungen:** **nicht dieser Closure geschuldet** — im Repo **mit** Wellen-Betrieb trägt
  sie die nächste Welle-Closure. Als Übergabe dennoch gefahren, mit Ergebnis: **(a) Anker** — kein
  Steering-Loop-Eintrag trägt ein Feld `liegt in`, die Paarung hat keinen Gegenstand.
  **(b) Folge-Slice** — der einzige genannte ist
  [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md), und
  er existiert als Datei im Planning-Lifecycle. **(c) Register** — jede hier zitierte Kennung löst
  als Verzeichnis auf; die zweite Hälfte *„jede Registerzeile trägt mindestens einen Beleg"* meldet
  unverändert **einen** Eintrag ohne `evidence/`,
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab` — **kein** Rückstand und derselbe Fall, den
  die drei vorigen Closures benannt haben: Der Eintrag führt sein einziges Vorkommen unter
  *Benannt, nicht gezählt*, und ein Vorkommen ohne abgeschlossenen Vorgang bekommt nach
  `modul-06-roadmap.md` ausdrücklich keinen Beleg.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `internal/emit/` (eigener Zuschnitt, eigene
Tests, eigene Ziel-Form — drei von drei Achsen) und `test/` (eigener Zuschnitt, eigene
Werkzeugkette — zwei von drei). Beide erfüllen die Schwelle ≥ 2; keine ist zu grob geschnitten.

**Vorgelagert — offene Beobachtungen sichten: nicht gefahren, und das steht hier statt eines
nachträglich erfundenen Ergebnisses.** Der Schnitt hat die Sichtung ausdrücklich auf die
Bearbeitung vertagt (*„sie ist vor der Bearbeitung gegen das Register zu fahren … der Stand des
Registers wandert zwischen Schnitt und Bearbeitung"*), und dort ist sie nie ausgeführt worden:
Weder der Übernahme-Commit noch einer der acht folgenden Läufe hat diesen Abschnitt angefasst, und
keiner der sieben Review-Reports hat ihn beanstandet. Die drei zuletzt geschlossenen Nachbar-Slices
tragen an derselben Stelle ein Ergebnis
(`grep -A3 'Vorgelagert — offene Beobachtungen sichten' docs/plan/planning/done/slice-{197,200,201}*.md`);
dieser nicht.

**Die Closure trägt das Ergebnis nicht nach.** Ein Sichtungs-Ergebnis, das nach der Arbeit
entsteht, ist keines — der Schritt existiert, damit offene Beobachtungen die **Planung** dieses
Slice beeinflussen, und diese Wirkung lässt sich nicht rückwirkend herstellen. Was der Schritt
gekostet hat, ist statt dessen **gemessen**: Dieser Slice hat **sieben** bereits geführte Klassen
des Registers erneut getroffen — darunter eine, die mit ihm die 3×-Schwelle erreicht — und **vier**
weitere neu angelegt (§7). Eingetragen als
[`BEO-ALL/vorgelagerter-pflicht-schritt-bleibt-platzhalter`](../observations/BEO-ALL/vorgelagerter-pflicht-schritt-bleibt-platzhalter/observation.md),
Zähler **1×**. *(Die Adresse dieses Blocks nannte eine flache `observations/README.md`; die Ablage
ist seit [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
ein Verzeichnis je Beobachtung — bei der Closure gezogen.)*

Alle berührten Sub-Areas GF: `internal/emit/` und `test/` gehören zum Greenfield-Bestand; der Modus
steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md). Der Modus-Begründungsblock entfällt
damit nach dem *Umfang*-Absatz oben.
