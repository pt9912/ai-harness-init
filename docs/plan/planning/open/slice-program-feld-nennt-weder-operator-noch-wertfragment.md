# Slice slice-program-feld-nennt-weder-operator-noch-wertfragment: Das Feld `program` nennt weder einen Shell-Operator noch das Bruchstück eines Zuweisungs-Werts

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Der Slice ändert **eine** Funktion und eine Spec-Zeile; sein Beleg sind
zwei rot gesehene Mutations-Fälle und ein grüner Gate-Lauf, und beides steht in seiner eigenen
DoD. Ein Closure-Trigger darüber schriebe sie ab (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht).

**Ebene: Produkt-Code — Dogfood *und* emittiert, ohne Vorlagen-Änderung.** `internal/span/` ist
Teil des Produkt-Binärs. Ein emittiertes Repo bekommt **keine** Kopie dieses Codes, sondern einen
Hook-Wrapper, der denselben Träger ruft
([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5).
Die Änderung erreicht damit jedes emittierte Repo über den Träger; **keine Vorlage wird
angefasst**.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (die
Erfassungsschicht, deren Feld hier repariert wird),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (jede Zahl dieses Plans
steht neben dem Kommando, das sie ausgibt),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (die Erfassungs-Policy: was in den
Span darf und was nie — die Wert-Grenze unten ist ihre Anwendung),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (der Träger, über
den die Änderung beide Ebenen erreicht),
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
(das Technik-Stratum ist Rang 2 und **ohne Vertragsänderung fortschreibbar** — die Spec-Zeile ist
darum kein Lastenheft-Thema)

**Berührte Spec-Stellen:** `SPEC-031` (die `Bash`-Zeile der Werkzeug-Tabelle in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5:
*„erstes Token nach übersprungenen `NAME=WERT`-Präfixen"*) — sie beschreibt die heutige Mechanik
wörtlich und wandert mit. `SPEC-021` (`program`, `argc`) bleibt wahr und wird nur gegengelesen.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-24.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `commandProgram()` in `internal/span/span.go` gibt für eine Zeile, die mit `NAME=WERT`-Zuweisungen
beginnt, entweder das Programm zurück, das nach den Zuweisungen läuft, oder **nichts** — nie einen
Shell-Operator und nie ein Bruchstück eines Zuweisungs-Werts. `SPEC-021` verspricht mit `program`
die Antwort auf *„Welches Programm lief?"* (`internal/span/fieldlist.go`: *„nie die Zeile"*).

**Zwei Fehler, ein Grund: der Zuweisungs-Präfix endet für den Code am ersten Leerzeichen.**
`commandProgram` zerlegt die Zeile an Leerraum und überspringt Felder, die wie `NAME=WERT` aussehen;
das nächste Feld gilt als Programm. Das stimmt nur, wenn der Wert **ein** Feld ist und die nächste
Wortgrenze ein Programm trägt.

1. **Operator statt Programm.** Bei `S=/pfad && cd …` ist das nächste Feld `&&`. Der Span trägt
   `"program":"&&"` (JSON-Schreibweise `&&`: `json.Marshal` in `internal/span/emit.go`
   maskiert `&` als Standard-Verhalten, das ist kein Fehler und nicht Gegenstand, s. u.).
2. **Wert-Bruchstück statt Programm.** Ein Wert, der Leerraum enthält (`T=$(date +%s); make`,
   `A="x y" cmd`), zerfällt in mehrere Felder; das erste Feld nach dem ersten gilt als Programm.
   Das ist **dieselbe Leck-Klasse**, gegen die der Kommentar über der Funktion den Prefix-Schutz
   setzt: `TOKEN="abc def" gh pr create` ergäbe nach dem Quelltext `def"` — ein Stück des Werts im
   Log. *Aus dem Quelltext abgeleitet, im Slice rot zu sehen (DoD); der Bestand trägt die
   Kommandozeile nie und kann die Herkunft nicht belegen.*

Gemessen am Bestand unter `.harness/state/spans/` (**keine Erwartungswerte** — der Bestand ist
gitignored, maschinenlokal und wächst; gemessen am 2026-09-24, die Probe gehört gefahren, nicht
zitiert, [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5):

```sh
cd .harness/state/spans
cat *.jsonl | grep -c '"program"'                                       # 33046 Spans mit Feld
cat *.jsonl | grep -c '"program":"\\u0026\\u0026"'                      # 331 Operator
cat *.jsonl | grep -oE '"program":"[^"]*\)(;)?"' | wc -l                # 116 endet auf ) oder );
cat *.jsonl | grep -oE '"program":"(rev-parse|\+%s\);|-d\))"' | sort | uniq -c   # 57 / 22 / 10
```

Die 116 sind Bruchstücke von Befehlssubstitutionen (`+%s);`, `-d)`, Pfade mit `)`); `rev-parse` ist
das Bruchstück von `$(git rev-parse …)`, **vermutet**, nicht belegt.

**Gewünschtes Verhalten — eine Setzung, keine Selbstverständlichkeit.** Zuweisungen bilden ein
**Segment ohne Programm**; ein Operator als **eigenes Feld** beendet es. Das Programm ist das erste
Wort des **nächsten** Segments — unter denselben Regeln, also mit übersprungenen Zuweisungen und
mit derselben Wert-Prüfung. Ein Wert, dessen Ende die Zerlegung an Leerraum nicht sicher findet,
bricht die Erkennung ab: **nichts** wird ausgegeben (`ok=false`, wie beim `=`-Rest heute).

| Kommandozeile | `program` | Begründung |
|---|---|---|
| `A=b && cmd x` · `A=b ; cmd x` · `A=b \| cmd x` · `A=b & cmd x` | `cmd` | die Zuweisung läuft, danach läuft `cmd` |
| `A=b; cmd x` | `cmd` | bleibt, wie heute: das `;` klebt am Wert |
| `A=1 B=2 && make gates` · `A=b && C=d && make` | `make` | eine Kette aus Zuweisungs-Segmenten |
| `A=b \|\| cmd` | **nichts** | eine Zuweisung schlägt nicht fehl, `cmd` läuft nie — der Wert nennte ein Programm, das nicht lief |
| `A=b &&` · `A=b ;` | **nichts** | kein weiteres Segment |
| `TOKEN=x && gh pr create` | `gh` | der Wert `x` wird übersprungen und nie ausgegeben |
| `TOKEN="abc def" gh pr create` · `A="x && y" cmd` | **nichts** | der Wert-Rand ist nicht bestimmbar; `def"` bzw. `y"` wären Wert-Bruchstücke |
| `T=$(date +%s); make` · `` A=`x y` cmd `` | **nichts** | Befehlssubstitution zerfällt an Leerraum |
| `(A=b; cmd)` | **nichts** | bleibt, wie heute (`(A=b;` ist keine Zuweisung, enthält `=`) |

**`argc` behält seine Bedeutung:** die Felder **nach** dem Programm bis Zeilenende. Für
`A=b && cmd x y` ist es 2. Eine segment-begrenzte Bedeutung setzt `slice-204` (s. u.); wer als
zweiter landet, gleicht an.

**Verworfen: ein kleiner Shell-Tokenizer** (Anführungszeichen- und Klammer-Tiefe), der `SHA=$(git rev-parse HEAD) && gh api`
zu `gh` auflöste. Er ist eine andere Größe — Fehlgriffe in Sonderformen (Here-Doc, `${…}`,
verschachtelte Substitution) sind hier kein Schönheitsfehler, sondern ein Leck —, und
[slice-204](../next/slice-204-das-programm-feld-nennt-das-programm.md) benennt in seiner Rückführung
dieselbe Weggabelung. Der Preis der fail-closed-Wahl ist beziffert (die 116 fallen auf *nichts* statt
auf ein Bruchstück) und ist eine Verkleinerung des Nenners, kein falscher Zähler.

**Nachzug des Bestands: nein.** Alte Spans behalten ihren Wert: der Bestand ist gitignored,
maschinenlokal und append-only, kein Arbeitsauftrag dieses Slice, und kein Leser wertet den Wert
als Programm aus — `grep -rlE '"program"|\.Program' --include=*.go --include=*.sh cmd harness/tools internal | grep -v _test`
nennt `span-check.sh` und `full-smoke.sh` (prüfen `"program":"make"`), `hook-overhead.sh` (bildet
mit dem Wert eine Kommandozeile gleicher Länge nach) und `internal/span/`. `make span-report`
liest das Feld **nicht**. Die Folge — der Bestand mischt zwei Bedeutungen — gehört benannt, nicht
repariert (§6).

**Nachbarschaft: `slice-204` schreibt an derselben Funktion und derselben Spec-Zeile.**
[slice-204](../next/slice-204-das-programm-feld-nennt-das-programm.md) (`next/`) lässt
`commandProgram()` **Navigations-Segmente** (`cd`, `set`) überspringen und setzt `argc` auf das
gewählte Segment; er berührt `SPEC-021` und `SPEC-031`. Beide Slices sind lieferbar, ohne auf den
anderen zu warten, aber **gleichzeitig** angefasst erzeugen sie einen Konflikt in derselben
Funktion, demselben Test und derselben Spec-Zeile. Dieser Slice führt den Begriff *Segment ohne
Programm* für Zuweisungen ein; slice-204 verallgemeinert ihn auf `cd`/`set`. **Die Reihenfolge
(dieser zuerst · gefaltet in slice-204) ist vor `open → next` zu entscheiden** (§4).
`Übernimmt:` steht nicht: ein Übernehmen ginge an slice-204 vorbei, der den Gegenstand `cd`/`set`
führt und nicht geschlossen ist.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Änderung der JSON-Schreibweise.** `&` ist `&` — `json.Marshal` (`internal/span/emit.go`)
  maskiert HTML-Zeichen, wenn `SetEscapeHTML(false)` fehlt. Das Format zu ändern hieße jeden
  Leser des Stroms und jede Bestandsdatei in zwei Schreibweisen zu führen; das ist eine
  **Formatentscheidung** und ein **anderer Vorgang**. Nach diesem Slice erscheint `&&` gar nicht
  mehr als `program`, die Frage stellt sich für dieses Feld nicht mehr.
- **Keine Segment-Auswahl über Zuweisungen hinaus** (`cd`, `set`, `for`, `while`, `until`, `if`,
  Klammer- und Block-Formen). Das ist `slice-204` bzw. **anders gelagert**: ein Navigations-Segment
  steht *vor* dem Kommando und lässt sich überspringen; ein Schleifen-Körper *enthält* mehrere —
  eine Auswahl, keine Übersprung-Regel. Die Bezugsmenge beziffert das Feld heute
  (`cat *.jsonl | grep -cE '"program":"(for|set|until|true)"'`, **keine Erwartungswerte**); die
  Vereinfachung *erstes Token* **bleibt bewusst stehen** — Bestand mit Begründung, nicht
  vergessen. Ein Register-Eintrag dazu entsteht bei der Closure (Modul 6: die Slice-Closure
  schreibt das Register), nicht in dieser Planung.
- **Kein Tokenizer, kein Parser.** Begründung oben (*Verworfen*). Wer ihn baut, hat den Plan
  geändert.
- **Keine Vorlage unter `internal/emit/templates/`.** Die Änderung erreicht ein emittiertes Repo
  über den **Träger** — **Schicht-Abgrenzung**, beim Review sofort prüfbar: berührt der Diff
  `internal/emit/`, ist der Slice aus seiner Schicht gelaufen.
- **Keine Änderung der Feldliste.** Der Fragetext in `internal/span/fieldlist.go` (*„das erste Token
  der Kommandozeile"*) ist auch heute ungenau (er kennt die Zuweisungen nicht); die Feldliste
  gehört [slice-109](../next/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md) — **anderer
  Vorgang**, und der Zeiger nimmt die Sendung an, denn slice-109 führt die Aussagen der Feldliste.
- **Keine Entscheidung über das Rollen-Eigentum an den Spec-Straten.** Wer
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md) schreiben darf, benennt **keine**
  Quelle — [`AGENTS.md`](../../../../AGENTS.md) §3.8 weist nur Hard Rules und Adaptions-Block dem
  Architect zu und sagt: *„wo keine Quelle sie benennt, bleibt die Frage offen"*. Die Frage hat
  eine Adresse, die die Sendung annimmt:
  [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md). Der Lauf, der
  `SPEC-031` schreibt, leitet daraus keine Zuständigkeit ab.
- **Keine Änderung an `span-report` oder `hook-overhead`.** Sie lesen das Feld nicht
  (`span-report`) bzw. nur seine Größe (`hook-overhead`); dieser Slice schreibt es —
  **anderer Vorgang**.

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

**Liefer-Punkt 1 — `commandProgram()` nennt ein Programm oder nichts.** Die Tabelle aus §1 ist
die Zusage; jede Zeile ist ein Fall in `internal/span/span_test.go`.

- [ ] Die Fälle der Tabelle sind Tests, **benannt nach der Eigenschaft**, die sie messen (etwa
      `TestCommandProgramNamesAProgramNotAnOperator` und
      `TestCommandProgramNeverEmitsAssignmentValueFragments`), und sie laufen über `span.Derive`
      **und** über den Weg, den der Träger benutzt (`span.Build` bis zur serialisierten Zeile in
      `internal/span/emit.go`): Die Zusage betrifft das **Feld im Strom**, nicht die Funktion.
      `TestCommandProgramSkipsAssignments` bleibt **grün und unverändert** — die bestehende Zusage
      wird nicht umgeschrieben, um die neue zu ermöglichen.
- [ ] **Was bricht die Zusage, und ist es rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6):
      (a) *Operator wird nicht übersprungen* (das heutige Verhalten) → `A=b && cmd x` liefert
      `&&`; der Test nennt Fall und erwartetes `cmd`. (b) *Die Wert-Prüfung fehlt* →
      `TOKEN="abc SECRET" gh pr create` liefert `SECRET"`; der Test nennt den Fall und weist das
      Bruchstück **im serialisierten Span** nach. (c) `TOKEN=x && gh …` schreibt den Wert nie —
      der Schutz des Kommentars über der Funktion bleibt: Bruchstück **und** Wert kommen in keiner
      Ausgabe vor. Jedes einmal gegen die reale Mutation rot, nicht gegen eine nachgebaute.
- [ ] Der Kommentar über `commandProgram()` beschreibt, was die Funktion **jetzt** zusagt
      (Segment-Grenze, Wert-Grenze, `argc`) und nennt seine Wächter beim Namen — nicht mehr allein
      `TestCommandProgramSkipsAssignments`.

**Liefer-Punkt 2 — Zwei Fälle in `test/mutations/` binden die Zusage** (nächste freie Nummern;
`ls test/mutations | sort -n | tail -1` nennt die letzte).

- [ ] Ein Fall nimmt der **Segment-Grenze** die Zähne (Mutation: der Operator wird nicht
      übersprungen), ein Fall der **Wert-Grenze** (Mutation: die Prüfung auf einen nicht
      bestimmbaren Wert entfällt). Beide tragen `# files: internal/span/span.go` und
      `# expect:` den Namen des Tests aus Liefer-Punkt 1.
- [ ] Das `sed`-Muster jedes Falls ist **nach** der Implementierung gegen den Quell-Bestand
      gemessen, nicht gegen die Fassung vor dem Slice
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)):
      es trifft **genau eine** Stelle, und die Mutation färbt **die Zeile des erwarteten Tests**
      rot. Ein Fall, der bei geschwächter Zusicherung noch rot wird, deckt einen anderen Zweig —
      die Gegenprobe steht in der Closure-Notiz.
- [ ] Der Fall der Wert-Grenze trifft den **stillen** Pfad: entfällt die Prüfung, bricht nichts,
      und das Programm wird nur falsch. `make mutate` läuft mit den zwei neuen Fällen und meldet
      `0 Befund(e)`.

**Liefer-Punkt 3 — `SPEC-031` beschreibt die neue Mechanik.**

- [ ] Die `Bash`-Zeile in [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
      §5 nennt: übersprungene Zuweisungs-Segmente, den Wert, dessen Rand nicht bestimmbar ist
      (dann **kein** Feld), und die unveränderte Bedeutung von `argc`. `SPEC-021` ist gegengelesen
      und bleibt wahr. Das Technik-Stratum ist ohne Vertragsänderung fortschreibbar
      ([`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence));
      das Lastenheft wird **nicht** angefasst. Wer schreibt, benennt in §7, dass für dieses
      Stratum **keine** Quelle eine schreibende Rolle benennt
      ([slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md)), und leitet
      keine Zuständigkeit daraus ab.

**Pro Slice konstant — zählt nicht in die drei:**

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — **kein Zähler wird gesetzt**, er
      folgt aus den Dateien.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieser Slice läuft
      **ohne Welle**, sie werden also hier geprüft, nach dem `git mv`.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/span/span.go` | update | `commandProgram()` — Zuweisungs-Präfix als Segment, Operator-Felder, Wert-Grenze; der Kommentar über der Funktion nimmt die Zusagen mit |
| `internal/span/span_test.go` | update | die Tabelle aus §1 als Tests (Segment-Grenze, Wert-Grenze, Schutz vor dem Wert), über `Derive` und den serialisierten Span; `TestCommandProgramSkipsAssignments` unverändert daneben |
| `test/mutations/<N>-span-program-*.sh` | neu (zwei) | nehmen der Segment- und der Wert-Grenze die Zähne |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 | update | `SPEC-031` (`Bash`-Zeile) |

**Zwei Schichten:** Produkt-Code (`internal/span/` samt seinen Fällen) und Spec-Stratum 2. Kein
`cmd/`, kein `Makefile`, kein `internal/emit/`.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert, `Verantwortlich:` ist gesetzt, das
WIP-Limit des Rolleninhabers ist frei. **Vorher entschieden — vor `open → next`, nicht im
Lauf:** die Reihenfolge zu
[slice-204](../next/slice-204-das-programm-feld-nennt-das-programm.md), der dieselbe Funktion,
denselben Test und `SPEC-031` ändert. Zwei Wege: **(a)** dieser Slice zuerst, slice-204 baut auf
dem Begriff *Segment ohne Programm* auf und gleicht `argc` an; **(b)** die zwei Gegenstände
werden in **einem** Slice geführt, und einer der beiden geht als *übernommen* nach `done/`
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt — dann trägt der Nehmer `Übernimmt:`). Diese Entscheidung ist **nicht** Sache dieses
Plans: sie verschiebt den Schnitt zweier Slices.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Tabelle aus §1 lässt sich nur
  erfüllen, wenn die Zeile in Anführungszeichen- oder Klammer-Ebenen zerlegt wird — dann ist es
  ein Tokenizer, und der ist ein anderer Slice als dieser (slice-204 nennt dieselbe Weggabelung).
- `in-progress` → `open` (blockiert — Carveout?): `SPEC-031` lässt sich ohne eine Entscheidung
  über das Rollen-Eigentum am Spec-Stratum nicht schreiben — dann wartet der Slice auf
  [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md), und **das** ist der
  Blocker, nicht der Code. Ebenso, wenn slice-204 während der Arbeit beansprucht wird und die
  Reihenfolge aus dem Start-Punkt nicht mehr trägt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(1)** Die zwei Mutations-Fälle und die Tests aus Liefer-Punkt 1 sind
je einmal rot gesehen (Meldung gelesen: sie nennt den Fall der Tabelle und den erwarteten Test),
`make mutate` meldet `0 Befund(e)` und `make gates` ist grün. **(2)** Ein Lauf des Trägers
(`span-emit`) über einer Payload mit `A=b && ls` schreibt `"program":"ls"`, und eine Payload mit
`TOKEN="abc SECRET" gh pr create` schreibt **kein** `program` und nirgends `SECRET` — gemessen an
der geschriebenen Zeile, nicht behauptet. Dazu der Lerneintrag in einer der drei Formen
(geschärfte Regel · neuer Sensor · benannte Spec-Lücke).

**Kein Konsument wartet auf diesen Wert.** Der Wert trägt für jeden Leser des Roh-Stroms; der
Slice ist ohne einen benannten Konsumenten lieferbar — sonst wäre er ein Zombie-Slice
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die fail-closed-Wahl verkleinert den Nenner.** Aufrufe mit `$(…)`-, Backtick- oder
  Anführungszeichen-Werten (`SHA=$(git rev-parse HEAD) && gh api …`) tragen danach **kein**
  `program` mehr statt eines Bruchstücks; ein Leser des Stroms zählt sie nicht mehr unter einem
  Programm. Die Größenordnung ist am Bestand beziffert (116 Bruchstücke, §1), der Preis ist gewollt.
  — **Ausgang:** <offen>
- **Die Wert-Prüfung kann zu grob oder zu fein greifen.** Zu fein: ein Wert-Rand, den die Prüfung
  für bestimmbar hält und der es nicht ist (`A=x\ y cmd`, `${A:-x y}`), und ein Bruchstück
  gelangt doch ins Log — der Fall, gegen den der Slice steht. Die Fälle der Tabelle sind eine
  Stichprobe, keine Vollständigkeits-Aussage. — **Ausgang:** <offen>
- **Der Bestand mischt danach zwei Bedeutungen.** Spans vor und nach diesem Slice tragen dasselbe
  Feld mit verschiedener Regel; ein Leser, der über die Zeit vergleicht, sieht einen Sprung, der
  keine Verhaltensänderung ist. Kein Feld trägt die Fassung. — **Ausgang:** <offen>
- **Zwei Slices schreiben an einer Funktion.** slice-204 und dieser Slice ändern `commandProgram()`,
  denselben Test und `SPEC-031`; eine Reihenfolge ist im Plan nicht entschieden (§4 Start). Zwei
  Pläne über denselben Gegenstand sind im Repo schon einmal aufgetreten und einer davon wurde
  ohne Lieferung stillgelegt. — **Ausgang:** <offen>
- **Für das berührte Spec-Stratum benennt keine Quelle eine schreibende Rolle.** Der Slice ändert
  eine Zeile in Rang 2 der Source Precedence, ohne dass gesagt ist, wer das darf. Adresse:
  [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md). — **Ausgang:** <offen>

## 7. Closure-Notiz

<!-- Wird bei der Closure gefüllt — Planner, nicht der Lauf, der die Arbeit tat
(AGENTS.md §3.10). -->


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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Der Träger
liegt in `internal/span/`, die zweite Schicht ist `spec/` — `harness/tools/` (`TOOLS`) und
`.codex/` (`CODEX`) sind als Pfade nicht berührt. Eine eigene Sub-Area für die Erfassungsschicht
führt die Modus-Deklaration nicht, und dieser Slice legt keine an: Er ändert eine Funktion, nicht
die Reife-Achse eines Bereichs.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; die Zähler sind als Dateizahl unter
`evidence/` abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
Erwartungswerte** —
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2, gelesen am gemergten Stand vom 2026-09-24). **Kein Eintrag betrifft das Feld `program`
oder die Erfassungsschicht selbst** (`grep -liE 'commandProgram|"program"|argc' docs/plan/planning/observations/BEO-ALL/*/observation.md`
gibt nichts aus). Die Klassen, die diesen Slice **über seine Arbeitsweise** berühren:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md) | 3× | verkörpert | die drei Rot-Nachweise in Liefer-Punkt 1 sind der Regelfall; das Gegenbeispiel ist hier **herstellbar** (Mutation am Quelltext) |
| [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) | 12× | verkörpert | Liefer-Punkt 2 ist genau dieser Fall: zwei neue Zusagen, zwei Fälle |
| [`mutations-fall-deckt-den-lauten-statt-den-stillen-pfad`](../observations/BEO-ALL/mutations-fall-deckt-den-lauten-statt-den-stillen-pfad/observation.md) | 2× | offen | **Beobachtungsstelle:** die Wert-Grenze fällt still (kein Absturz, nur ein falsches Programm); deckt der Fall sie nicht, ist der Eintrag mit diesem Slice bei 3× und eine Lücke mit eigenem Folge-Slice |
| [`mutations-fall-zeigt-auf-falsche-datei`](../observations/BEO-ALL/mutations-fall-zeigt-auf-falsche-datei/observation.md) | 2× | offen | `# files:` zeigt auf `internal/span/span.go`; die Angabe löst auf, ihre Richtigkeit prüft `make mutate` nicht — daher die [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)-Messung in Liefer-Punkt 2 |
| [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | 17× | geplant | der Kommentar über `commandProgram()` nennt heute **einen** Wächter; nach dem Slice sind es mehr — der Kommentar zieht mit (Liefer-Punkt 1, dritter Haken) |
| [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) | 32× | geplant | drei Aussagen stehen neben der geänderten Mechanik: `SPEC-031` (wandert mit, Liefer-Punkt 3), der Funktionskommentar (wandert mit) und der Fragetext in `fieldlist.go` (**bleibt**, §1: `slice-109` führt ihn) |
| [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md) | 3× | verkörpert | die Ebenen-Aussage im Kopf (Dogfood **und** emittiert, über den Träger statt über eine Vorlage) |
| [`plan-entsteht-vor-dem-verdikt-ueber-seinen-gegenstand`](../observations/BEO-ALL/plan-entsteht-vor-dem-verdikt-ueber-seinen-gegenstand/observation.md) | 1× | offen | ein zweiter Plan über `commandProgram()` neben `slice-204`; die Reihenfolge ist deshalb im Start-Punkt (§4) vorab zu entscheiden, statt im Lauf |

Alle Bezeichnungen sind **zitiert**, nicht neu formuliert; dieser Slice weist keinem Eintrag einen
Ausgang zu und erhöht keinen vorab — das Register schreibt die Closure.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.
