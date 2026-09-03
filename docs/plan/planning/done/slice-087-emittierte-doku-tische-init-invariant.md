# Slice slice-087: Kein emittiertes Dokument behauptet ein nicht Init-invariantes `make`-Ziel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — die **Tool**-Ebene, Vorarbeit. Er ist
Mitglied, weil die Zelle *Doku-Konsistenz-Drift × Tool* ohne ihn nicht belegbar ist: `slice-063`
darf den Träger erst konfigurieren, wenn kein emittiertes Dokument mehr ein Ziel behauptet, das
einer Bootstrap-Variante fehlt. Bliebe er außerhalb, deckte der Closure-Trigger *„alle Slices
dieser Welle in `done/`"* genau das nicht ab, woran die Welle hängt.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (erste
Hälfte: *„Jeder emittierte Gate-Target läuft auf frischem Checkout"* — die Anforderung, gegen die
der emittierte Bestand heute selbst verstößt; ihre Messmethode `make gates`/Exit 0 sieht es nicht),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (*out-of-the-box grün* —
die Zusage, die ein verdrahteter Doku-Konsistenz-Träger heute bräche),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (der
emittierte Stand ist gate-sicher — die Schranke, an der die Neutralisierung gemessen wird),
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
emittierte Doc-Gate-Baseline — sie trägt den Abnehmer dieser Vorarbeit, wird hier aber **nicht**
berührt),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche — hier als Gegenkraft: *laut falsch* ist nur dann
besser als *leise falsch*, wenn der Adopter am Befund ablesen kann, dass er einer ist),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(der Schnitt-Test — er entscheidet die Welle, nicht die Größe; §4),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (**Accepted** — die Phasen-Trennung: `--lang` ist
optional, und genau daraus entsteht die Varianz, die dieser Slice schließt),
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) (**Accepted** — der Abnehmer:
Festlegung 4(e) macht diese Vorarbeit zur Vorbedingung der Emission, Festlegung 4(c) bindet jede
spätere Emissions-Phase an dieselbe Eigenschaft. **Der Befund hängt nicht an ihr:** die
behaupteten, nirgends existierenden Ziele verletzen
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) auch
ohne jede Doc-Gate-Konfiguration — die Entscheidung ist der Grund für die *Reihenfolge*, nicht für
die Arbeit).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-16.

---

## 1. Ziel

**Kein emittiertes Dokument behauptet im frisch gebootstrappten Ziel noch ein `make`-Ziel, das die
Init-Phase nicht selbst schreibt — in jeder Bootstrap-Variante, und ein Wächter hält die
Eigenschaft fest.**

**Der Gegenstand ist der Dokument-Satz, nicht eine Aufzählung von Fundorten.** Welche Dokumente
`internal/emit` ins Ziel schreibt und wie viele davon überhaupt ein `make`-Ziel nennen, steht
gemessen in [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(e)
(2026-08-16) — **verwiesen, nicht abgeschrieben**: eine zweite Fassung derselben Zählung driftet
mit dem nächsten Baseline-Sprung, und die Bedingung hängt nicht an ihr. **Drei** Dokumente
verletzen die Bedingung heute, und sie sind der Gegenstand dieses Slice:

| Emittiertes Dokument | Anspruch | existiert wo? | Beleg |
|---|---|---|---|
| `AGENTS.md`, `harness/README.md` — die zwei Gate-**Tabellen**, zusammen 20 Nennungen von 9 Zielen (2026-08-16, `grep -noE 'make [a-z][a-z0-9-]+'` über die zwei Vorlagen) | `arch-check`, `ci`, `coverage-gate`, `coverage-gate-critical`, `fullbuild` | in **keiner** Variante — auch `arch-check` nicht, wenn ein Arch-Gate emittiert wird, denn das Target heißt dort `a-check` | `grep -rnoE '^(coverage-gate\|fullbuild\|ci\|arch-check):' internal/gen internal/emit` → **kein Treffer**; Positivkontrolle mit `(test\|lint\|build)` → sechs Treffer |
| dieselben zwei | `lint`, `test` | **nur** mit `--lang`, im Code-Gate-Fragment `harness/mk/<lang>.mk` | [`internal/gen/golang.go`](../../../../internal/gen/golang.go) und [`internal/gen/cpp.go`](../../../../internal/gen/cpp.go) definieren je `test`, `lint`, `build` |
| `.harness/skills/closure-note-reviewer.md` — **Prosa, keine Tabelle**, zwei Nennungen | `verify-closure-notes` | in **keiner** Variante, und auch in diesem Repo nicht | gemessen wird die **Regel**, nicht das Wort: `grep -rnE '^verify-closure-notes:' --include='*.go' --include='*.mk' --include='Makefile' .` → **0 Zeilen**, rc 1; Positivkontrolle mit `^record-gates:` über denselben Pfad → **3 Dateien** |

**Zum dritten Dokument gehört, wo seine Nennungen liegen** — sonst repariert die Umsetzung die
falsche. Die vendored Vorlage nennt das Ziel **dreimal**; die erste Nennung steht im
`> **Template-Hinweis.**`-Blockquote und fällt beim Emit ohnehin weg
([`internal/emit/templates.go`](../../../../internal/emit/templates.go), `StripHintBlock` schneidet
genau diesen führenden Blockquote). Die zwei **übrigen** überleben und stehen im emittierten
Artefakt: einmal in der `Gilt für:`-Zeile und einmal als Pflicht-Eingang des Reviewers
(*„das Ergebnis von `make verify-closure-notes` für denselben Stand"*). Der Skill ist seit
slice-030 als Singleton in-scope — `inScope` ist dort ausdrücklich als **Regel** geschrieben, nicht
als Allowlist, und genau darum kann der Dokument-Satz wachsen, ohne dass jemand eine Liste pflegt.

**Warum `lint`/`test` mitmüssen, obwohl sie „meistens" wahr sind.** Sie sind die teurere Hälfte
der Gate-Tabellen-Ansprüche: eine
Behauptung, die in *einer* Variante zutrifft, macht jeden Befund über sie **unentscheidbar**. Die
sechs Sonden aus
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) §Kontext zeigen es an der Ausgabe des
Trägers — heutiger Tisch: **13 Befunde, davon 4 falsch**; die naheliegende Teil-Reparatur (nur die
fünf nirgends existierenden entfernen): **4 Befunde, alle vier falsch**; wahr und falsch sind
**byte-gleich**; nur der Init-invariante Tisch schweigt in **beiden** Varianten. Wer nur die
nirgends existierenden fünf entfernt, erzeugt den Fehler also erst — und `exempt-targets: [lint, test]` hilft nicht
(dieselbe Sonde, unverändert 4 Befunde: die Ausnahmeliste greift auf der Vollständigkeits-Richtung,
nicht auf Richtung 1).

**Was der Slice damit herstellt, ist eine Eigenschaft, keine Liste:** über den **ganzen**
emittierten Dokument-Satz ist die Menge der behaupteten Ziele eine Teilmenge der Menge, die die
Init-Phase definiert. Beide Mengen schreibt dasselbe Werkzeug; die Invariante ist deshalb prüfbar,
ohne dass jemand eine Datei-Liste pflegt. **Der Gegenstand ist deshalb die Eigenschaft und nicht
die drei Fundorte:** ein Wächter, der die zwei Gate-Tabellen aufzählt, schweigt zum dritten
Dokument und ist beim vierten wieder falsch — und beide Fehler sind still.

## 2. Definition of Done

- [x] **(1) Kein emittiertes Dokument behauptet nach der Emission noch ein nicht Init-invariantes
  `make`-Ziel — belegt an einem frisch gebootstrappten Ziel, in beiden Bootstrap-Varianten.** Die
  Ansprüche fallen **emit-seitig**, nicht in der vendored Vorlage: die Kurs-Vorlagen
  gehören dem Kurs ([welle-09](../welle-09-modul-15-konformitaet.md) §6,
  [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)),
  und die Baseline ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 unveränderlich. Die Form ist
  vorgemacht: [`internal/emit/templates.go`](../../../../internal/emit/templates.go) neutralisiert
  die eine gate-unsichere Zeile der Roadmap-Vorlage beim Schreiben. **Welche Form die
  Neutralisierung nimmt — Zeile streichen oder Anspruch auf ein existierendes Ziel umschreiben —
  entscheidet die Umsetzung am Fehlerbild, nicht dieser Plan**
  ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed));
  die Zusage ist die Eigenschaft, nicht der Handgriff.
- [x] **(2) Ein netzloser Wächter hält die Eigenschaft, und er ist rot gesehen.** Ein Go-Test über
  dem emittierten Inhalt hält **jede** `make`-Nennung **jedes emittierten Dokuments** gegen die
  Ziel-Menge der Init-Phase und wird rot, sobald eine Nennung nicht darin liegt; dazu ein
  `test/mutations/`-Fall ([`AGENTS.md`](../../../../AGENTS.md) §3.6), der genau das einmal rot
  färbt. **Er prüft zwei Eigenschaften und keine zwei Listen** — weder die Namen der Ziele noch die
  Namen der Dokumente. **Die Dokument-Seite ist bereits als Regel geschrieben und nicht
  nachzubauen — aber sie steht an drei Emittern, nicht an einem, und die Menge ist deren
  Vereinigung:** [`internal/emit/templates.go`](../../../../internal/emit/templates.go)
  klassifiziert mit `inScope` und liefert über `TemplateTargets` die Ziel-Relpfade der aus dem
  Vorlagen-Satz abgeleiteten Singletons; die Root-`README.md` kommt aus
  [`internal/emit/readme.go`](../../../../internal/emit/readme.go) (`RootReadmePath` — `inScope`
  schließt ihre Vorlage ausdrücklich aus, sie hat einen eigenen Emit-Schritt); die
  Workflow-Commands kommen aus
  [`internal/emit/commands.go`](../../../../internal/emit/commands.go) (`CommandPaths()`, aus dem
  tool-eigenen eingebetteten Satz). Wer die Menge allein bei `TemplateTargets` abholt, deckt den
  Vorlagen-Satz und lässt genau die Dokumente aus, die keiner trägt — die Zählung dazu führt §1.
  Jede der drei Quellen bleibt dabei eine **Regel**: ein neu hinzugekommenes Dokument fließt mit,
  ohne dass jemand eine Liste pflegt. Die Grenze ist benannt und liegt bei einem **weiteren
  Emitter** — er fiele wieder heraus, und genau darum hängt die Quellen-Angabe an den Emittern
  und nicht an Dateinamen. Zählt der Wächter stattdessen Fundorte auf, bindet er den heutigen
  Bestand statt der Regel: das vierte Dokument und die nächste Emissions-Phase, die ein Ziel
  mitbringt, liefen still an ihm vorbei.
- [x] `make gates` grün.
- [x] Doku-Update für den berührten öffentlichen Vertrag — **erwartet unberührt**:
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md) wird von diesem Slice **erfüllt**, nicht
  geändert (§3); der Nachweis ist `git diff --stat` über den ganzen Slice.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Bewegt dieser Slice eine Anforderung? — Nein, er stellt eine her

[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) sagt
bereits, was hier hergestellt wird; der emittierte Bestand hält es nur nicht ein. Damit ist dies
kein Change Request nach
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(er bewegt eine Anforderung — hier bewegt sich keine), sondern die Reparatur eines Bestands gegen
seinen eigenen Vertrag. Dieselbe Klasse wie
[slice-073](../open/slice-073-emittierte-doc-gate-module.md): reaktiv, aus einer Messung am Bestand.

### Dateien

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/templates.go`](../../../../internal/emit/templates.go) | update | die emit-seitige Neutralisierung in **allen** verletzenden Dokumenten des Vorlagen-Satzes — die zwei Gate-Tabellen **und** den Closure-Note-Reviewer-Skill; dieselbe Datei schreibt beide, und die Roadmap-Vorlage macht die Form vor |
| [`internal/emit/readme.go`](../../../../internal/emit/readme.go) | update | die Root-`README.md` gehört zum Dokument-Satz aus DoD (2), hat aber einen **eigenen** Emit-Schritt: ohne dieselbe Neutralisierung hier fiele sie aus der Zusage heraus, obwohl DoD (2) sie ausdrücklich mitzählt |
| `internal/emit/` (Go-Test, paket-nah bei dem Paket, das er misst — `ls internal/emit/*_test.go \| wc -l` → **9**) und `test/mutations/` (der Gegenfall) | neu | der Wächter aus DoD (2) und sein rot gesehener Gegenfall |
| `.harness/baseline/v3.5.2/templates/**` | **unverändert** | die vendored Baseline ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 unveränderlich; ein Befund dort ist ein Upstream-Befund ([welle-09](../welle-09-modul-15-konformitaet.md) §6) |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md), [`docs/plan/adr/`](../../adr/) | **unverändert** | keine Anforderung wird bewegt, keine Entscheidung getroffen — die trifft `slice-062` |
| `internal/emit/templates/d-check.yml`, [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | **unverändert** | die Doc-Gate-Konfiguration und die zwei Beleg-Richtungen sind `slice-063`; dieser Slice stellt nur dessen Eintritts-Bedingung her |

### Was die Umsetzung zuerst nachmisst

Die Zahlen oben sind aus dem **Vorlagen- und Emissions-Bestand** gerechnet, nicht an einem frisch
gebootstrappten Ziel gemessen. Vor dem ersten Handgriff sind sie dort neu zu fahren — sie hängen
am vendored Stand, und der wandert mit jeder Baseline ([welle-10](welle-10-re-baseline.md)
zielt bereits auf einen anderen Tag). Ein Baseline-Sprung kann Ansprüche auflösen **oder**
hinzufügen; die Eigenschaft aus DoD (2) überlebt beides, eine abgeschriebene Namensliste nicht.

### Vorfrage, die diese Umsetzung benennt statt misst — wer sie erbt und was an ihr hängt

**Sieht das Modul `targets` eine `make`-Nennung in Prosa, außerhalb einer Tabelle?** Das ist
**ungemessen**, und die Messung ist dieser Vorarbeit ausdrücklich zugewiesen
([`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(d): *„ob das Modul eine
Prosa-Nennung außerhalb einer Tabelle überhaupt sieht, ist ungemessen … die Messung gehört zur
Vorarbeit aus 4(e)"*). Sie ist hier **benannt, nicht gefahren** — sie gehört an das gepinnte Image
in einer Wegwerf-Kopie außerhalb dieses Repos, wie die sechs Sonden der Entscheidung, und kein
Handgriff dieses Slice führt dorthin. Dieselbe Klasse steht als offene Frage schon in der Roadmap
(*ob `targets` eine Aufzählung innerhalb einer Prosa-Zeile erreicht*) — es ist eine Eigenschaft
des Trägers, keine Eigenschaft unserer Dokumente.

**Wer sie erbt: der Beleg-Slice der Welle** — `slice-063`, in
[welle-09](../welle-09-modul-15-konformitaet.md) §4 benannt und noch nicht geschnitten. Er ist der
einzige Lauf, für den ihr Ausgang eine Folge hat: er konfiguriert den `targets:`-Block im Ziel, und
die Messung entscheidet allein, ob `doc-tables:` den emittierten Skill je decken **könnte**. Damit
sie den Schnitt erreicht und nicht in einer geschlossenen Datei liegen bleibt, führt sie die
[Roadmap](../in-progress/roadmap.md) neben der Zeile, die `slice-063` als benannt-und-ungeschnitten
ausweist.

**Woran sie hängt, und woran nicht.** **Nicht** an der Arbeit dieses Slice: das dritte Dokument
behauptet ein Ziel, das in keiner Variante existiert, und das ist unter jedem Ausgang der Messung
falsch. Sie entscheidet allein, ob `doc-tables:` den Skill je decken **könnte**:

- **Sieht das Modul die Prosa-Nennung**, dann ist das dritte Vergleichs-Ziel des Regelwerks
  (*Skill-Dateien*) für `slice-063` erreichbar, und die Lücke, die
  [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(e) als *still* benennt —
  ein Verstoß im Skill, den `doc-targets` nicht meldet —, ist per Konfiguration schließbar statt
  nur per Wächter. Dann ist auch zu prüfen, ob der emittierte `doc-tables:`-Satz um den Skill
  wächst; das ist `slice-063`, nicht dieser Slice.
- **Sieht es sie nicht**, ist die Bedingung aus 4(e) dauerhaft breiter als der Träger, der sie
  später prüft. Dann ist der Wächter aus DoD (2) für dieses Dokument der **einzige** mögliche
  Träger, und das ist keine Lücke, sondern der Grund, warum DoD (2) über den Dokument-Satz läuft
  und nicht über `doc-tables:`.

## 4. Trigger

**`open` → `next`:** keiner. Der Befund steht am Bestand und ist ohne fremde Entscheidung
lieferbar — insbesondere **nicht** hinter `slice-062`: die Ansprüche sind heute falsch, ob eine
ADR sie erwähnt oder nicht. Modul 5 §Ziel-Form (*„kein Slice wartet auf den nächsten"*) ist damit
gewahrt, und die Abhängigkeit läuft in die andere Richtung — `slice-063` wartet auf **diesen**.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

**Warum Mitglied von [welle-09](../welle-09-modul-15-konformitaet.md) und nicht wellenlos** (der
Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 fragt, ob eine **neue Welle** nötig ist — hier steht die Welle schon, gefragt ist die
**Mitgliedschaft**): das Closure-Kriterium der Welle verlangt je Zelle einen belegten Zustand, und
die Zelle *Doku-Konsistenz-Drift × Tool* ist ohne diese Vorarbeit nicht belegbar. Eine Welle, deren
Closure an einem Nicht-Mitglied ohne Eintritts-Trigger hängt, hat ihr Kriterium nicht — sie
verschiebt es. Der Preis der Mitgliedschaft ist benannt: die Welle schließt später, dafür sagt
`alle Slices dieser Welle in done/` wieder die Wahrheit.

Rückführungen:

- `in-progress` → `next`: falls die Neutralisierung mehr als einen Mechanismus braucht (etwa:
  Tabellenzeilen streichen, `lint`/`test` an die Sprach-Phase binden, die Prosa-Nennungen des
  Skills anders behandeln als Tabellenzellen) und der Wächter aus DoD (2) damit einen weiteren
  Liefergegenstand bekäme.
- `in-progress` → `open`: falls sich zeigt, dass ein emittiertes Dokument ohne seine Ansprüche
  seine Aufgabe nicht mehr erfüllt — dann ist zu **entscheiden**, was ein emittierter Gate-Tisch
  dem Adopter zeigt und wovon ein emittierter Skill seinen Pflicht-Eingang bezieht, und das ist
  eine ADR-Frage, keine Emissions-Frage.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates`,
`make mutate` und `make full-smoke` grün — letzteres in **beiden** Bootstrap-Varianten und im
sprachlosen Ziel **vor** dessen `add-lang`-Schritt (§6); `git mv` nach `done/` (eigener
Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Die Lücke im Voll-Smoke ist nicht die fehlende Variante, sondern die Platzierung — gemessen.**
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) bootstrappt **vier**
  tmp-Repos; die zwei, die hier zählen, sind `tmprepo` (`--lang go`, `:43`) und `tmprepo_doc`
  (**sprachlos**, `:156`) — die anderen zwei sind `--arch`-Varianten mit Sprache (`:521`, `:562`).
  Der sprachlose Zustand wird ausdrücklich geprüft (`make gates` auf `tmprepo_doc`, `:160`), ist
  danach aber nur ein **Zwischenstand**: `:212-213` zieht dort zweimal `add-lang go` nach
  (Mono-Repo-Schritt), später `add-lang cpp` und die Arch-Achse. Ein Beleg, der erst danach
  greift, misst die sprachlose Variante **nie**. Wer hier oder in `slice-063` einen Zahn setzt,
  setzt ihn deshalb **vor** dem `add-lang`-Schritt — sonst behauptet der Beleg eine
  Varianten-Klammer, die er nicht hat. Ein drittes tmp-Repo zu bauen wäre die falsche Antwort: die
  zweite Variante ist da, sie wird nur zu spät gemessen.
- **Die Eigenschaft bindet auch jede spätere Emissions-Phase, und der Träger dafür ist der
  Wächter, nicht dieser Text.**
  [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(c) verlangt, dass eine
  Phase, die ein Ziel emittiert, **keinen** Doku-Anspruch darauf emittiert — die Konfiguration ist
  *skip-if-present* ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)) und kann nach der
  Init-Phase nicht mehr wachsen. Als Prosa wäre das eine Regel ohne Feedback-Quadrant; als
  Teilmengen-Test aus DoD (2) fällt sie beim nächsten Verstoß rot auf. **Das ist der Grund, warum
  DoD (2) die Eigenschaft prüft und nicht die Namen.**
- **Für das dritte Dokument gibt es im Ziel keinen Träger, und das bleibt so — auch nach
  `slice-063`.** `doc-tables:` nennt nach
  [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(d) zwei Dateien, und ob
  das Modul eine Prosa-Nennung überhaupt sieht, ist die Vorfrage aus §3. Ein Verstoß im
  Closure-Note-Reviewer-Skill bliebe für `doc-targets` deshalb **still**. Der Wächter aus DoD (2)
  ist damit für dieses Dokument nicht die zweite Absicherung, sondern die einzige — und das ist
  der Grund, warum er über den Dokument-Satz läuft und nicht über die Konfiguration des Trägers.
- **Was dieser Slice ausdrücklich NICHT tut.** Die Doc-Gate-Konfiguration im Ziel (der
  `targets:`-Block) und die zwei Beleg-Richtungen gehören `slice-063`; die Entscheidung darüber
  `slice-062`; die zwei `codepath-missing`-Stellen der emittierten Vorlagen-Prosa gehören
  [slice-073](../open/slice-073-emittierte-doc-gate-module.md) — **dieselbe Klasse Befund** (eine
  emittierte Vorlage behauptet, was im Ziel nicht existiert) und derselbe Ausweg
  (emit-seitige Neutralisierung), aber **andere Befund-Art** und nur **eine** gemeinsame Vorlage:
  jene Stellen liegen in der emittierten AGENTS- und der emittierten Konventions-Datei, die
  Gate-Ansprüche in der AGENTS-Vorlage und der Vorlage von
  [`harness/README.md`](../../../../harness/README.md). **Der Auflösungs-Trigger von
  [slice-073](../open/slice-073-emittierte-doc-gate-module.md) DoD (3) fällt hier also NICHT** — wer das
  annimmt, hakt eine fremde Nicht-Emission an einer Messung ab, die sie nicht getroffen hat.
- **Die Migration bereits gebootstrappter Ziele bleibt offen.** Emittierte Dokumente sind
  *skip-if-present*/konvergent je nach Klasse ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md));
  ein heute schon gebootstrapptes Repo bekommt die Korrektur nicht automatisch. Das ist die
  Idempotenz-Klasse, kein Versehen — aber es gehört benannt, weil die Zusage aus DoD (1) dort
  nicht gilt.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Über den ganzen emittierten Dokument-Satz ist die Menge der behaupteten `make`-Ziele
eine Teilmenge der Menge, die die Init-Phase schreibt — in **beiden** Bootstrap-Varianten. Beide
Mengen liest dasselbe Werkzeug aus denselben Konstanten: `InitInvariantTargets()` aus den
Fragmenten, die die Init-Phase schreibt, die Ansprüche aus dem, was
[`internal/emit/templates.go`](../../../../internal/emit/templates.go),
[`internal/emit/readme.go`](../../../../internal/emit/readme.go) und
[`internal/emit/commands.go`](../../../../internal/emit/commands.go) ins Ziel legen. Ein
hinzukommendes Dokument fließt mit, ohne dass jemand eine Liste pflegt; ein hinzukommendes, nicht
Init-invariantes Ziel in einem alten Dokument fällt bei jedem `make test-go` auf.

**Die Neutralisierung sitzt an zwei Emittern, nicht an einem.** Der Dokument-Satz aus DoD (2)
entsteht aus dreien, und die Root-`README.md` hat einen **eigenen** Emit-Schritt — ohne dieselbe
Neutralisierung dort fiele sie aus der Zusage heraus, obwohl DoD (2) sie mitzählt. Der dritte
Emitter braucht sie heute nicht: sein eingebetteter Satz nennt über alle drei Workflow-Commands
genau ein Ziel und ein Muster
(`grep -rhoE 'make [a-z][a-z0-9-]*\*?' internal/emit/templates/commands/*.md | sort -u` →
`make gates` und `make verify-*`), und `gates` schreibt die Init-Phase selbst. Das ist ein
**Zustand**, keine Eigenschaft des Emitters — er hat Folgen, siehe *Grenzen* und den
Steering-Loop-Eintrag.

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD (1)–(4) erfüllt.** Bestätigt im
   [Verifikations-Report](../../../reviews/2026-08-25-slice-087-verify.md) §2.1–§2.4 an **vier**
   real gebootstrappten Zielen (zwei Binärstände × zwei Varianten), jede Zahl dort selbst erhoben
   statt aus dem Umsetzungs-Protokoll übernommen. Das Rot der Kern-Zusage ist in beiden Varianten
   gesehen, das Grün danach ebenso.
2. **`make gates`, `make mutate` und `make full-smoke` grün** — letzteres in **beiden** Varianten
   und im sprachlosen Ziel **vor** dessen `add-lang`-Schritt, wie §5 es verlangt. Belege unten
   unter *Gates*.
3. **Review konform (Modul 10).** [Code-Review](../../../reviews/2026-08-25-slice-087-review.md)
   (`dbfda8e`): **frei**;
   `grep -c '^### F-' docs/reviews/2026-08-25-slice-087-review.md` → **2** Findings, keines am
   Code — eines an einer Plan-Zelle, eines an einer Formulierung über den Erfassungs-Umfang.
4. **Verifikation bestätigt (Modul 11).**
   [Verifikations-Report](../../../reviews/2026-08-25-slice-087-verify.md) (`96bb0be`): **frei für
   die Closure**; `grep -c '^| \*\*V-' docs/reviews/2026-08-25-slice-087-verify.md` → **5** eigene
   Befunde, keiner blockierend.
5. **Closure-Notiz mit Steering-Loop-Eintrag.** Diese Notiz; der Eintrag steht unten.

**Wo der Liefergegenstand in der Historie liegt.** Die Sache liegt in **einem** Commit: `b484e3a`
(`git show --stat b484e3a` → **4** Dateien, `379 insertions(+), 3 deletions(-)`) — die
Neutralisierung an zwei Emittern, der Wächter als paket-naher Go-Test und sein Gegenfall unter
`test/mutations/`. `dbfda8e` und `96bb0be` tragen die zwei Verdikte, die übrigen Commits des Slice
sind Lifecycle-Moves und die Link-Züge danach.

**Was der Slice nicht deckt — die Grenzen, jede gemessen.**

- **Eine der drei Leerlauf-Sperren ist für die Hälfte ihrer eigenen Meldung stumm.** Sie meldet
  *„der Scanner findet nichts, oder die Neutralisierung raeumt zu breit"*; eine zu breit räumende
  Neutralisierung lässt sie **grün**, weil ihr Zähler an einem Emitter vorbei gefüllt wird, den
  die Neutralisierung nicht durchläuft. **Unbewacht ist deshalb nichts** — dasselbe Fehlerbild
  färbt einen anderen Test desselben Pakets rot, im selben `make test-go`. Der Steering-Loop-Eintrag
  unten führt es aus.
- **Die zwei Erfassungen sind unabhängig implementiert, teilen aber ihr Alphabet.** Emit-Regel und
  Test-Scanner lesen beide `make ` + `[a-z][a-z0-9-]*` samt derselben Stern-Regel; ein Anspruch
  außerhalb dieses Zeichenvorrats ist für **beide** unsichtbar. Heute gibt es im vendored Satz
  plus den Workflow-Commands keinen solchen Kandidaten (Kommando im
  [Verifikations-Report](../../../reviews/2026-08-25-slice-087-verify.md) §3.3), und die Grenze
  steht im Wächter selbst.
- **Die breite Erfassungs-Regel greift auch außerhalb von Tabellen, und sie trifft dort eine
  Stelle.** Gezählt über die Eigenschaft *eine `make`-Nennung des vendored Vorlagen-Satzes, die in
  einer Adopter-Platzhalter-Klammer steht*:
  `grep -rn -E '<z\.? ?B\.[^>]*make [a-z]' --include='*.template.md' .harness/baseline/v3.5.2/templates`
  → **3** Zeilen. Eine nennt ein Init-invariantes Ziel und bleibt unberührt; von den zwei übrigen
  liegt eine in einer **wiederkehrenden** Vorlage, die nach
  [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
  referenziert statt emittiert wird. Es bleibt **eine** Stelle im emittierten Satz —
  `AGENTS.template.md:89`, ein Ausfüll-Beispiel —, und sie trägt danach die verschachtelte Form
  `<z.B. \`<make-target>\`>`. Sie war vorher schon Platzhaltertext und nie eine Behauptung über
  das Ziel-Repo; der Adopter füllt sie aus. **„Alle unkritisch" sagt das nicht** — es sagt, dass
  keine Zeile Schaden nimmt, und lässt offen, dass eine davon keine Tabellenzeile ist.
- **`InitInvariantTargets()` ist enger als die reale Ziel-Menge des Ziels**, weil `d-check.mk`
  erst zur Bootstrap-Zeit entsteht. Die Richtung ist fail-closed, wie
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  sie verlangt: ein Anspruch auf ein `doc-*`-Rezept würde neutralisiert, obwohl das Ziel existiert
  — laut falsch statt leise falsch; ein Anspruch auf ein Ziel, das **nicht** existiert, kann durch
  diese Enge nicht durchrutschen. Wirkung heute keine (Kommandos im
  [Verifikations-Report](../../../reviews/2026-08-25-slice-087-verify.md) §3.4).
- **Der Wächter läuft über einer Fixture, nicht über der realen vendored Baseline.**
  `.dockerignore` schließt `.harness` aus dem Go-Build-Kontext aus; der Test *kann* die reale
  Vorlage nicht sehen. Die Grenze steht im Code, und was sie auffängt, ist die Regel selbst — die
  über Namen nicht verfügt, wohl aber über das Alphabet oben.
- **Für das dritte Dokument gibt es im Ziel keinen Träger, und das bleibt so.** `doc-tables:`
  nennt nach [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(d) zwei
  Dateien; ein Verstoß im Closure-Note-Reviewer-Skill bliebe für `doc-targets` still. Der Wächter
  aus DoD (2) ist für dieses Dokument nicht die zweite Absicherung, sondern die einzige.

**Steering-Loop-Eintrag — geschärfte Regel.**

**Die Meldung eines Wächters ist eine Diagnose, kein Deckungs-Beleg. Eine Deckungs-Aussage über
eine einzelne Zusicherung entsteht aus dem Eingriff, der sie hat feuern lassen — nicht aus ihrer
Lesung.**

**Gemessen an diesem Slice.** Die dritte Leerlauf-Sperre des Wächters nennt zwei Fehlerbilder und
fängt eines. Der Grund ist mechanisch: der Emitter der Workflow-Commands schreibt seinen Satz
verbatim, ohne durch die Neutralisierung zu gehen
(`grep -c 'Neutralize' internal/emit/commands.go` → **0**, Exit 1), und dieser Satz allein legt
**13** erlaubte Ansprüche in jedes Ziel
(`grep -rhoE 'make [a-z][a-z0-9-]*\*?' internal/emit/templates/commands/*.md | sort | uniq -c` →
`13 make gates`, `1 make verify-*`). Der Zähler der Sperre kann darum nie null werden, gleich wie
breit die Neutralisierung räumt. **Die Deckung wurde der Sperre zugeschrieben, indem sie gelesen
wurde; eine einzige Sonde hat die Zuschreibung in einem Lauf widerlegt.**

**Warum [`AGENTS.md`](../../../../AGENTS.md) §3.6 das heute nicht fängt.** Die Sektion zählt vier
Träger einer Zusage auf — Doc-Kommentar, Test-Name, DoD-Punkt, Commit-Message. Diese Zusage saß in
keinem davon, sondern in einem **Review-Report**: ein Bericht, der einer Zusicherung Deckung
zuschreibt, sagt dasselbe zu wie ein Test-Name und schuldet denselben Beleg. Die Erweiterung ist
ein **Anheben** und braucht darum kein ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5;
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
hält *„Anheben → Steering-Loop"* fest).

**Träger: der Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). §3.6 gehört ihm,
und §3.8 verlangt für die Änderung einen eigenen Commit, der ausschließlich Artefakte derselben
Rolle berührt — diese Closure darf sie also nicht selbst schreiben. **Auslöser:** derselbe bereits
fällige Architect-Lauf, den die
[slice-093](../done/slice-093-mutations-treiber-erreicht-full-smoke.md)-Closure für die dritte
Setzung in
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
benannt hat — kein neuer Termin. **Was dieser Lauf misst, ist ein Bestand und keine Phrase-Suche:**
Leerlauf-Sperren der Form `if <zähler> == 0 {` mit `t.Fatal*` in den zwei Folgezeilen —
`grep -rn -A2 -E 'if [a-zA-Z_]+ == 0 \{' --include='*_test.go' . | grep -cE 't\.(Fatalf|Fatal|Errorf)'`
→ **5**; davon nennt genau **eine** Meldung zwei Fehlerbilder (dasselbe Kommando, `| grep -c ' oder '`
→ **1**). Beide Zahlen wandern mit dem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); die zweite ist der Gegenstand, an dem die Regel greift.

**Warum diese Notiz kein Träger ist.** Was in einer geschlossenen Slice-Datei steht, schlägt kein
Lauf wieder auf — [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) §Optionen hat
genau diese Option verworfen und die Wirkungslosigkeit mit Kommando und Nenner ausgeschrieben.
Deshalb steht hier der Träger und nicht die Hoffnung.

**Kein zweiter Eintrag für die stumme Sperre selbst, und das ist entschieden.** Das Fehlerbild ist
rot gesehen, nur von einem anderen Test desselben Pakets; die Zusage aus
[`AGENTS.md`](../../../../AGENTS.md) §3.6 ist auf Suite-Ebene eingelöst. Eine Regel *„jede
Leerlauf-Sperre bekommt ihren eigenen `test/mutations/`-Fall"* kostete pro Wächter einen weiteren
Fall und beschriebe eine Lücke, die hier keine ist — falsch war die Zuschreibung, nicht der
Wächter. Der Eintrag oben trifft deshalb die Zuschreibung.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| Die Messung aus [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4(d) — sieht das Modul `targets` eine Prosa-Nennung außerhalb einer Tabelle? | **`slice-063`**, der Beleg-Slice der Welle: der einzige Lauf, für den ihr Ausgang eine Folge hat. Die [Roadmap](../in-progress/roadmap.md) führt sie neben der Zeile, die ihn als benannt-und-ungeschnitten ausweist, damit sie den Schnitt erreicht (§3) |
| [`AGENTS.md`](../../../../AGENTS.md) §3.6 um den Review-Report als Träger einer Zusage | **Architect**, an seinem bereits fälligen Lauf — kein neuer Termin |
| Die Zustands-Zeile in [welle-09](../welle-09-modul-15-konformitaet.md) §4 nennt diesen Slice in `open/` | **die Welle-Closure**, ein eigener Schritt derselben Rolle. Die Zeile weist sich selbst als nachrangig aus (*„Der Zustand ist das Verzeichnis, nicht diese Zeile"*), und der Zustand steht im Verzeichnis |
| Das gemeinsame Alphabet der zwei Erfassungen | **kein Träger, und das ist entschieden**: heute gibt es keinen Kandidaten außerhalb dieses Zeichenvorrats, die Grenze steht im Wächter, und ein zweites Alphabet erfände eine Fehlerklasse, die der Bestand nicht hat |
| Die Migration bereits gebootstrappter Ziele | **kein Träger, und das ist entschieden**: sie ist **geteilt**, nicht offen — der Skill heilt beim Re-Lauf (konvergent), die zwei Gate-Tische nie (skip-if-present, [`ADR-0007`](../../adr/0007-bootstrap-phasen.md)). Die Zusage aus DoD (1) gilt für frische Bootstraps, und §6 sagt das |
| Die verschachtelte Platzhalter-Form in der emittierten `AGENTS.md` | **kein Träger, und das ist entschieden**: die Zeile war vor wie nach der Neutralisierung ein Ausfüll-Beispiel des Adopters und hat nie etwas über das Ziel-Repo behauptet; sie enger zu erfassen hieße, die Regel an eine Fundstelle zu binden |

**Gates.** Der [Verifikations-Lauf](../../../reviews/2026-08-25-slice-087-verify.md) hat sie über
dem Baum bei `dbfda8e` selbst gefahren, Exit-Codes getrennt erhoben: `make gates` **Exit 0**
(`baseline-verify: v3.5.2 OK — 42 Dateien`, `d-check: 369 Datei(en) geprüft, 0 Befund(e)`,
`comment-claims: 40 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün), `make mutate` **Exit 0**
mit `mutate: 146 ok, 0 Befund(e)` und dem neuen Fall als `ok`, `make full-smoke` **Exit 0** mit
beiden Varianten-Zeilen. Der Stempel band den Lauf an den Baum, nicht an eine Erinnerung:
`bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha` waren danach
byte-gleich, und `record-gates` schreibt ihn nur als **letzter** Prerequisite grüner Gates
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)).
Die Dateizahl des Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Diese Notiz, der `done/`-Move und der Link-Zug danach verschieben den Stempel erneut;
der Lauf, der ihn wieder bindet, gehört zu ihnen.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/` und
`test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
