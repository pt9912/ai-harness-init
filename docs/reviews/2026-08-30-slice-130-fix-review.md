# Review — slice-130, Fix-Runde (`722e272`)

**Rolle:** Reviewer (Modul 8/10, frischer Kontext). **Datum:** 2026-08-30.
**Gegenstand:** `722e272` — die Fix-Runde auf das Review
[`4d02b6e`](2026-08-30-slice-130-review.md) (2 HIGH · 3 MEDIUM · 2 LOW · 2 INFO) zur
Implementierung `7e6eb0b`. Fünf Dateien, davon eine reine Kommentar-Änderung am
Produktionscode.
**Maßstab:** Slice-Plan · aktive ADRs · Hard Rules. **Nicht** Maßstab: die DoD-Abhakung
(Verifier, getrennter Kontext).

**Eingangs-Kontext (fünf Pflicht-Punkte + Slice-Plan).**
Diff-Range `722e272~1..722e272`; als bindender Kontext dazu `add5f43` (Hard Rule §3.7,
Quellen-Klausel, Cutoff **heute**) und `a6d436c` (Architect-Entscheidungen A und B).
Anforderungen: [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
Aktive ADRs im Bezug: [`ADR-0005`](../plan/adr/0005-ziel-repo-distribution.md),
[`ADR-0020`](../plan/adr/0020-emittierte-modul-15-regeln.md),
[`ADR-0024`](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
— alle `Accepted`. [`ADR-0025`](../plan/adr/0025-register-mit-gemischten-originalen.md) ist
`Proposed` und damit **nicht** normativ; sie ist hier notiert, nicht geprüft (INFO-3).
Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3.2, §3.3, §3.4, §3.6, §3.7, §3.8, §3.9.
Vorherige Findings am gleichen Modul: [Review slice-130](2026-08-30-slice-130-review.md),
[Review slice-138](2026-08-30-slice-138-fix3-review.md),
[Review slice-133](2026-08-29-slice-133-review.md) — die dort wiederkehrende Klasse ist
*Grenz-/Vollständigkeitsaussage ohne gemessene Menge*; sie kehrt hier wieder (MEDIUM-2, LOW-1).
Slice-Plan: [`slice-130`](../plan/planning/done/slice-130-emitter-entscheidet-jedes-neue-template.md).

**Bindende Vorentscheidungen (nicht Gegenstand dieses Laufs).**
`a6d436c` (Architect) entscheidet: `isBrownfieldOnly` ist **keine** Abweichung, kein `MR`,
`slice-130` muss nicht zurück in die Umsetzung. Geprüft wurde hier deshalb **nicht**, ob die
Entscheidung richtig ist, sondern ob der Code-Kommentar ihren Stand wiedergibt (MEDIUM-1).
`ADR-0025` beantwortet HIGH-2 und braucht ihre eigene Review-Runde.

**Selbst gefahrene Sensoren (nichts übernommen).**

```sh
make -k gates      # -> genau EIN rotes Ziel
```

`d-check: 464 Datei(en) geprüft, 1 Befund(e)`, und der Befund ist
`harness/conventions.md:1019 … target-missing` =
[`CO-005`](../plan/carveouts/CO-005-adaptions-block-datierter-beleg.md), Träger
[slice-132](../plan/planning/in-progress/slice-132-adaptions-block-ohne-totes-ziel.md) — erwartet rot.
Über dem Log desselben Laufs: `grep -cE '^ok ' <log>` → **196**,
`grep -cE '^not ok ' <log>` → **0**, `1..196`; `comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`;
`baseline-verify: v5.12.0 OK — 51 Dateien`; `span-check` grün. Gelaufen sind alle elf Ziele
(`baseline-verify`, `docs-check`, `lint`, `build`, `test-bats`, `test-go`, `shell-lint`,
`ci-lint`, `comment-claims`, `host-bin`, `span-check`).

`make smoke` / `make full-smoke` **nicht** erneut gefahren, mit Grund statt aus Bequemlichkeit:
der Diff ändert an `internal/emit/templates.go` **ausschließlich Kommentarzeilen** —
`git show 722e272 --unified=0 -- internal/emit/templates.go | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -vE '^[+-]//' | grep -vE '^[+-]\s*$'`
→ **keine Zeile**. Das Emit-Verhalten ist gegenüber dem im Vor-Review gemessenen Stand
(`20 Datei(en) geprüft, 0 Befund(e)`, Exit 0) unverändert.

`make mutate` **nicht** gefahren (212 Fälle, ~50 min). Kein Befund dieser Liste hängt daran;
die Zähne des neuen Wächters sind stattdessen **außerhalb des Repos simuliert** (s.
Negativbefund 3 und MEDIUM-2), auf einer Kopie des vendored Satzes, ohne den Baum anzufassen.

Nach dem Schreiben dieses Reports erneut `make docs-check`: `465 Datei(en) geprüft, 1 Befund(e)`
— derselbe `CO-005`-Befund, kein zusätzlicher. Der Report bringt keinen eigenen hervor.

---

## Findings

### MEDIUM-1 · Der `GRENZE`-Absatz liest sich als offen, wo seit `a6d436c` nichts mehr offen ist — und die Antwort liegt in keinem Rang

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Ein Kommentar beschreibt, was da ist* —
  Zustands-Hälfte) · §3.8 (Rollen-Eigentum) ·
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)
- **pfad:** `internal/emit/templates.go:99-108`
- **befund:** Der Absatz schließt mit *„Ob daraus dennoch eine Abweichung im Sinne des
  Adaptions-Blocks folgt, ist eine Architektur-Frage (AGENTS 3.8) und **hier nicht
  entschieden**."* Die Frage **ist** entschieden — `a6d436c` beantwortet sie mit *keine
  Abweichung, kein `MR`, `MR-000` gilt fort*. Der Rang-Zeiger auf §3.8 ist zulässig und richtig;
  die Zustandsaussage daneben ist es nicht mehr. Verschärfend: die Entscheidung hat **keinen
  lebenden Träger** — `git grep -n 'isBrownfieldOnly' -- ':!internal/emit' ':!test'` liefert
  genau zwei Treffer, eine Zeile im `CO-004`-Geschichtslog und eine im Vor-Review; `a6d436c`
  ändert nur `docs/plan/adr/0025-…md` und `docs/plan/adr/README.md`
  (`git show --stat a6d436c`), und `grep -n 'Brownfield' docs/plan/adr/0025-…md` → kein Treffer.
  Die einzige Fundstelle der Antwort ist die Commit-Message. Ein Lauf, der die Weiche anfasst,
  liest den Kommentar als offenen Posten, sucht im Adaptions-Block nach einem `MR`, findet
  keinen — und schreibt entweder die *erfundene Abweichung*, die `a6d436c` ausdrücklich
  ausschließt, oder fährt die dreiteilige Messung ein zweites Mal.
- **verifizierbar:** nein, kein Gate — kein Modul von `.d-check.yml` liest Go-Kommentare, und
  `make comment-claims` prüft die Existenz eines genannten Sensors, nicht den Zustand einer
  Aussage. Belegt durch die zwei `git`-Kommandos oben.

### MEDIUM-2 · Der neue Wächter deklariert „GRENZE, zweifach" — die dritte Grenze ist die einzige, die still grün lässt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*keine Zusage ohne rot gesehenes
  Gegenbeispiel*) · Reviewer-Skill §MEDIUM (*Spec-Treue-Lücke einer Messmethode*)
- **pfad:** `test/courseset-fixture.bats:183-189` (Grenz-Block) gegen `:126-139` (`kopiere_ziel`)
- **befund:** Der Block zählt seine Grenzen ab (*„GRENZE, zweifach. (1) … (2) …"*). Eine dritte
  besteht und ist nicht genannt: `kopiere_ziel` nimmt **den ersten Backtick-Ausdruck hinter dem
  Wort „Kopiere"** — nicht den Ziel-Pfad. Steht davor ein anderer Inline-Code-Ausdruck, ist die
  Extraktion **nicht leer, sondern falsch**, und der `OHNE-ZIEL:`-Pfad, der die *leere*
  Extraktion laut macht, greift nicht. Die Menge ist gemessen, nicht behauptet: über die
  21 in-scope-Vorlagen tragen **18** Hinweis-Blöcke mehr als **ein** Backtick-Paar hinter dem
  Wort „Kopiere" (Kommando im Anhang), und **0** haben heute einen falschen ersten Treffer —
  die Klassifikation stimmt also aktuell, sie hängt nur an der Wortstellung. Die Formulierung
  ist keine erfundene: der Hinweis von
  `harness/conventions/MR-NNN-titel.template.md` führt *„wandert die Datei per `git mv` nach
  `done/`"* bereits im selben Blockquote. Gegenprobe auf einer Kopie außerhalb des Repos, mit
  **derselben** Drift, die Fall `219` fährt, nur anders formuliert
  (der Kopiere-Satz lautet dabei ``Kopiere per `git mv` nach `docs/plan/planning/<bereich>/observations.md` ``):
  die Extraktion liefert `git mv`, die abgeleitete Menge verliert die Vorlage, der `diff` gegen
  den `isRecurring`-Rumpf ist **leer** — **grün**, ohne `OHNE-ZIEL`-Zeile. Genau der Fall, den
  der Kommentar an `internal/emit/templates.go:26-32` als abgedeckt zusagt (*„Ohne ihn faengt
  kein Sensor den Fall, dass upstream einen Ziel-Pfad umschreibt"*).
  **Warum nicht HIGH:** über den heutigen Satz misst der Wächter korrekt — alle 21 Extraktionen
  liefern den richtigen Ziel-Pfad, selbst nachgefahren. Er lügt nicht jetzt; die
  Grenz-*Zählung* ist falsch.
- **verifizierbar:** ja, ohne Gate — die Simulation oben auf einer Kopie des vendored Satzes.
  Kein Gate-Lauf färbt den Befund rot: `test-bats` ist über dem unveränderten Satz grün, und
  `make mutate` prüft die Haltbarkeit vorhandener Zähne, nicht die Reichweite ihrer Grenzsätze.

### MEDIUM-3 · Die Übergaben dieser Runde haben weiterhin keinen lebenden Träger (Wiederholung aus `4d02b6e`)

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan §6 Risiko 1 (*„Ausgang: eingetreten: Übergabe an die schreibende Rolle
  des Lastenhefts, **Slice-ID nachtragen**"*) ·
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) ·
  [`AGENTS.md`](../../AGENTS.md) §3.4
- **pfad:** `spec/lastenheft.md` (`LH-FA-02`, *fünf*) gegen `internal/emit/templates.go:47-54`
  (sieben); `docs/plan/adr/0020-emittierte-modul-15-regeln.md:528`
- **befund:** Der Vor-Review hat diesen Posten als MEDIUM-3 geführt und ihn ausdrücklich
  **nach** HIGH-1 terminiert; HIGH-1 ist mit `a6d436c` beantwortet, der Posten damit fällig.
  `722e272` beantwortet ihn mit einer Zuständigkeits-Aussage im Commit-Body (*„Der Implementer
  kann den Posten nicht selbst tragen — `MR-015` gibt den annehmenden Akt dem Auftraggeber"*).
  Das trifft für den **annehmenden Akt** zu und ist nachgelesen: `MR-015` Setzung 1 legt ihn in
  die Nutzer-Entscheidung, Setzung 2 in einen eigenen, nur `spec/lastenheft.md` ändernden
  Commit. Der **Träger** ist aber nicht der annehmende Akt — der Plan verlangt in §6 Risiko 1
  wörtlich eine nachgetragene Slice-ID. Gemessen existiert keiner:
  `git grep -n 'sieben wiederkehrend\|fünf wiederkehrend\|fuenf wiederkehrend' -- docs/plan/planning/open docs/plan/planning/next docs/plan/planning/in-progress docs/plan/carveouts spec docs/plan/adr harness/conventions.md`
  → **drei** Treffer, davon zwei im aufgelösten `CO-004` und einer in `ADR-0020:528` selbst;
  **kein** offener Slice, kein Carveout, keine Zeile in Roadmap oder Welle. Dasselbe gilt für
  die zwei weiteren Übergaben dieser Runde (der `StripHintBlock`-Defekt aus dem zerfallenen
  `MR-017`-Argument und der `BEDIENHINWEIS`-Posten aus LOW-2): beide leben allein im
  Commit-Body. Das Instrument, das diese Klasse sichtbar hielt, ist
  [`CO-004`](../plan/carveouts/done/CO-004-emitter-klassifikation-offen.md) — und es ist in
  derselben Kette aufgelöst worden.
  **Adressat:** Planner. Der Implementer darf weder `LH-*` noch eine `Accepted`-ADR (§3.4) noch
  einen Slice-Schnitt schreiben; das ist kein Einwand gegen ihn, sondern die Feststellung, dass
  der Posten den Kontext verlassen hat, ohne anzukommen.
- **verifizierbar:** ja, ohne Gate — das `git grep` oben. Kein Modul von `docs-check` prüft die
  Vollständigkeit einer Aufzählung, und keines liest Commit-Bodies.

### MEDIUM-4 · Zwei lebende Planungs-Register sagen, `CO-004` halte den `test`-Gate — er ist grün

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Zustandsfeld-Hälfte, Cutoff ab 2026-08-29) ·
  Baseline-Regelwerk `modul-07-carveouts.md`
- **pfad:** `docs/plan/planning/in-progress/roadmap.md:38-39`;
  `docs/plan/planning/welle-10-re-baseline.md:275-276`
- **befund:** Die Roadmap sagt im Präsens *„Auf den **Gates** halten ihn **zwei** Carveouts:
  `CO-004` auf `test` … und `CO-005` auf `docs-check`"*, die Welle-Datei *„**Zwei** Carveouts
  halten den Zwischenzustand der Gates sichtbar statt still"*. Gemessen hält nur noch **einer**:
  im eigenen `make -k gates`-Lauf ist `test` grün (`1..196`, `grep -cE '^not ok ' <log>` → **0**),
  `CO-004` liegt in `carveouts/done/` und sagt das selbst. Beide Sätze tragen den Link bereits
  auf `carveouts/done/…` — die Verweis-Adresse behauptet *aufgelöst*, die Prosa daneben
  *hält den Gate*; die Kette hat die Adresse in `5cf8245` nachgezogen und den Satz stehen
  lassen. **Instrument-Prüfung gegen den Vor-Review:** dessen Negativbefund 12 sprach `5cf8245`
  mit *„verändert wurden ausschließlich Link-Adressen"* frei. Das stimmt buchstäblich und geht
  am Punkt vorbei: eine dieser Adressen sitzt **in** einem Satz, dessen Zustandsaussage sie
  falsch macht. Der Negativbefund ist insoweit einzuschränken.
  `docs/plan/planning/open/slice-137-…:234-236` nennt dieselben zwei Carveouts, bindet die
  Aussage aber ausdrücklich an den *Schnitt-Zeitpunkt* — dort ist es **kein** Befund.
  **Adressat:** Planner (Roadmap und Welle-Datei sind seine Artefakte); der Implementer hat die
  drei Fundstellen im Body von `7e6eb0b` benannt und korrekt nicht angefasst.
- **verifizierbar:** ja, ohne Gate — der Gate-Lauf gegen den zitierten Satz. Kein Modul von
  `docs-check` liest Zustandsfelder; `links` prüft nur, ob das Ziel existiert.

### LOW-1 · Die erste genannte Grenze steht im Konjunktiv, obwohl ihre Vorbedingung real vierfach erfüllt ist

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Indikativ über den Zustand)
- **pfad:** `test/courseset-fixture.bats:183-186`
- **befund:** *„teilten sich zwei Vorlagen einen Basenamen und wäre nur eine wiederkehrend, sähe
  das weder dieser Test noch der Emitter"* — der Konjunktiv liest sich, als sei schon das Teilen
  hypothetisch. Gemessen teilen **vier** in-scope-Vorlagen den Basenamen `README.template.md`
  (`harness/`, `docs/plan/adr/`, `docs/plan/carveouts/`, `docs/plan/planning/`; Kommando im
  Anhang). Hypothetisch ist allein die zweite Hälfte der Bedingung. Der Abstand zum Ausfall ist
  damit **ein** Upstream-Schritt, nicht zwei — und die Folge träfe den Emitter, nicht nur den
  Test: `isRecurring(path.Base(rel))` (`internal/emit/templates.go:324`) würde alle vier
  gemeinsam aus dem Emit nehmen, darunter `harness/README.md`.
- **verifizierbar:** ja, ohne Gate — `find … -name 'README.template.md'` über den vendored Satz.

### LOW-2 · Die `KOPPLUNG`-Zusage von Fall 219 nennt eine Treiber-Meldung, die der Treiber in diesem Fall nicht gibt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `test/mutations/219-vorlagenhinweis-driftet-lautlos.sh:18-20`
- **befund:** *„Nach einem Bump zeigt er ins Leere, und der Treiber meldet den Fall als
  unveraendert — laut, nicht still."* Die Konsequenz *laut* stimmt, der Weg dorthin nicht:
  `harness/tools/mutate.sh` fährt unter `set -euo pipefail` (`:97`) und sichert die Zieldateien
  **vor** der Mutation mit `( cd "$WORK" && tar -cf "$BACKUP/files.tar" "${file_list[@]}" )`
  (`:492`). Bei einem toten Pfad scheitert schon dieses `tar`; der Worker endet, `status.$idx`
  wird nie geschrieben, und der Befund entsteht über die *Fall-ohne-Ergebnis*-Schranke von
  `merge_report`. Die Meldung *„Mutation hat nicht gegriffen bei: …"* (`:562`) wird nie
  erreicht. Fall 219 ist der **einzige** Fall des Bestands, dessen `# files:`-Ziel unter
  `.harness/baseline/<tag>/` liegt (`grep -n '^# files:' test/mutations/*.sh | grep -c baseline`
  → **1**), die Kopplung ist also neu und ihr Fehlerbild ungefahren.
- **verifizierbar:** nein mit heutigen Mitteln — der Nachweis verlangte einen Baseline-Bump oder
  einen manipulierten Fall-Kopf; beides ist kein Gate-Lauf.

### LOW-3 · Der eingeschobene Wächter-Absatz trennt den Doppelpunkt von der Liste, die er ankündigt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*schreibt an den, der die Stelle ändert*)
- **pfad:** `internal/emit/templates.go:22-34`
- **befund:** Zeile 22-23 endet mit *„Die zwei mit v5.12.0 dazugekommenen sagen es selbst, jede
  in ihrem Template-Hinweis**:**"*, danach steht acht Zeilen lang der neue Absatz über
  `courseset-fixture.bats`, und erst ab `:35` folgt die zweigliedrige Liste, die der
  Doppelpunkt ankündigt. Wer einen dritten wiederkehrenden Eintrag nachträgt, folgt dem
  Doppelpunkt und landet im Wächter-Absatz. Der Einschub ist inhaltlich richtig; er sitzt an
  der Stelle, an der die Ankündigung ihre Fortsetzung erwartet.
- **verifizierbar:** nein — Struktur eines Doc-Kommentars, kein Sensor.

### INFO-1 · Der Plan nennt `MR-017` weiterhin wörtlich als Risiko-Ausgang, die Code-Begründung ruht nicht mehr darauf

- **kategorie:** INFO
- **quelle:** Slice-Plan §6 Risiko 3 ·
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- **pfad:** `docs/plan/planning/done/slice-130-emitter-entscheidet-jedes-neue-template.md:278-282`
- **befund:** Die Entfernung der `MR-017`-Nennung aus dem Weichen-Kommentar (LOW-1 des
  Vor-Reviews) ist **korrekt und korrekt getrennt**: `MR-017` begrenzt sich selbst auf
  *„jede vom Tool **emittierte** Gate-Konfiguration … also jeder **Prüfbereich**"*
  (nachgelesen), und die Emit-Disposition einer Register-Vorlage ist kein Prüfbereich. Der Plan
  ist ein **Planner**-Artefakt; ihn im Implementations-Lauf zu ändern wäre der Fehler, nicht
  ihn stehen zu lassen. Was bleibt, ist ein Posten für die Closure: der vorformulierte Ausgang
  *„eingetreten: benannte Entscheidung mit Begründung am Code, nach dem Fehlerbild aus
  `MR-017` — laut falsch schlägt leise falsch"* ist so nicht mehr wahr; entschieden wurde
  entlang der Bootstrap-Prozedur. Wer ihn bei der Closure wörtlich übernimmt, trägt die
  außerhalb ihres Geltungsbereichs zitierte Kennung in ein **lebendes** Artefakt.
- **verifizierbar:** nein — kein Gate liest Geltungsbereiche von `MR-*`-Einträgen.

### INFO-2 · Der `isBrownfieldOnly`-Kommentar wächst von 29 auf 46 Zeilen Abwägung, und §3.7 legt die Abwägung in die ADR

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Die Abwägung gehört in die ADR*) ·
  Slice-Plan §2 DoD (1) (*die Begründung steht am Code … §3.7*)
- **pfad:** `internal/emit/templates.go:73-118`
- **befund:** Gemessen (Kommando im Anhang): der Doc-Kommentar von `isBrownfieldOnly` geht von
  **29** auf **46** Zeilen, der von `isRecurring` von **25** auf **34**. Der Zuwachs ist
  Abwägung — drei Belege für die Nicht-Emit-Entscheidung plus der Grenz-Absatz. Das ist **kein
  Verstoß**: die Quellen-Klausel aus `add5f43` zielt auf *Herkunft als Prosa* (Befund-Kennung,
  Slice-Nummer als Erzählung, Lauf-Protokoll), nicht auf sachliche Begründung, und die
  zitierten Quellen (`modul-02-harness-bootstrap.md`, `LH-FA-01`, `planning/README.md`) lösen
  auf. Es ist eine **Spannung**, und sie ist im Plan angelegt: DoD (1) verlangt die Begründung
  am Code und beruft sich dafür auf dieselbe §3.7, deren Begründungs-Absatz die Abwägung in die
  ADR legt. Feedforward — benannt, nicht entschieden; der Ort für die Entscheidung ist der
  Architect, nicht dieser Lauf und nicht dieser Report.
- **verifizierbar:** nein — Umfang eines Kommentars ist kein Gate-Gegenstand.

### INFO-3 · `ADR-0025` ist `Proposed` und in diesem Lauf nicht geprüft

- **kategorie:** INFO
- **quelle:** [`ADR-0025`](../plan/adr/0025-register-mit-gemischten-originalen.md) ·
  [`AGENTS.md`](../../AGENTS.md) §3.4
- **befund:** `a6d436c` schneidet HIGH-2 des Vor-Reviews in eine eigene ADR und hält sie
  ausdrücklich auf `Proposed`, weil ihr Acceptance-Trigger die abgeschlossene Review-Runde
  verlangt. Für **diesen** Lauf folgt daraus: sie ist **nicht normativ**, und der dritte Griff
  an `docs/plan/carveouts/README.md` in `722e272` verstößt gegen nichts — `ADR-0024`
  Festlegung 2 sagt für dieses Register wörtlich *„dann bleibt die Frage offen und braucht eine
  eigene Entscheidung"*, und `modul-07-carveouts.md` gibt `git mv` und Config-Updates dem
  Implementer. Notiert, nicht geprüft.
- **verifizierbar:** entfällt.

---

## Die Cutoff-Einheit: Zeile oder Block?

**Weder noch — gebunden ist die AUSSAGE nach Whitespace-Normalisierung. Und der Bestand daneben
ist ausdrücklich ein Planungs-Schnitt, keine Cutoff-Frage.**

**Der konkrete Fall entscheidet sich vorher, und anders als gemeldet.** Der Implementer meldet
eine Zeile (`slice-024s Voll-Smoke …`) als geerbt; die Beauftragung nennt sie *byte-identisch*
auf der Minus-Seite. Gemessen ist sie das nicht:

```sh
git show 722e272^:internal/emit/templates.go | sed -n '76p'
#  //<TAB>  slice-024s Voll-Smoke die wiederkehrenden Vorlagen entschied. Dazu faellt beim
git show 722e272:internal/emit/templates.go  | sed -n '93p'
#  //<TAB>  IM emittierten Stand, an dem slice-024s Voll-Smoke die wiederkehrenden Vorlagen
```

Byte-identisch ist der **Satz**, nicht die Zeile — der Absatz ist neu umbrochen. Unter der
Zeilen-Lesart wäre die Stelle also **gebunden** und ein Verstoß; unter der Satz-Lesart nicht.
Die Frage ist damit nicht akademisch, sie kippt diesen Fall.

**Warum die Aussage und nicht die Zeile.** §3.7 sagt *„Gebunden ist der Kommentar, der
geschrieben oder geändert wird"* — „der Kommentar", nicht „die Zeile"; Zeilen zählt die Sektion
nur als **Maß des Bestands**, nicht als Gegenstand der Bindung. Dazu kommt ein technisches
Argument, das ohne Wertung auskommt: eine Zeile ist in umbrochener Prosa ein
**Formatierungs-Artefakt**. Ob ein Satz in einer oder zwei Zeilen steht, entscheidet die
Spaltenbreite. Eine Regel, deren Anwendbarkeit davon abhängt, wo der Umbruch fällt, ist keine
Regel über Inhalt — und sie ließe sich in beide Richtungen erzwingen, durch Umbrechen wie durch
Zusammenziehen.

**Warum nicht der Block.** Die Block-Lesart macht mit jedem Ein-Wort-Fix am Kopf eines
47-Zeilen-Doc-Kommentars den ganzen Kommentar fällig. Das widerspricht dem Satz, der unmittelbar
neben der Bindung steht: *„der Bestand ist kein Arbeitsauftrag dieser Sektion"* — und `add5f43`
schreibt dieselbe Grenze noch einmal aus: *„Ob der Bestand darüber hinaus geräumt wird,
entscheidet ein Planungs-Schnitt und nicht diese Sektion: die vier Klassen überlappen in
derselben Zeile, und wer eine Zeile räumt, muss sie lesen."* Die Block-Lesart nähme genau diese
Entscheidung vorweg.

**Die Aussage ist messbar, und das ist der Punkt.** Normalisiert man Zeilenumbrüche und
Whitespace und vergleicht satzweise, ist der Unterschied zwischen *getragen* und *geschrieben*
ein `comm`-Aufruf, kein Urteil. Über die zwei berührten Doc-Kommentare dieses Diffs:

```sh
norm() { sed 's|^//||' | tr '\n' ' ' | tr -s ' \t' ' ' | sed 's/\. /.\n/g' \
         | sed 's/^ //;s/ $//' | LC_ALL=C sort -u; }
# je Revision ueber die Bloecke von isRecurring und isBrownfieldOnly, dann
LC_ALL=C comm -13 alt.txt neu.txt | grep -cE 'slice-[0-9]|Review-Befund'   # -> 0
LC_ALL=C comm -12 alt.txt neu.txt | grep -cE 'slice-[0-9]|Review-Befund'   # -> 2
```

**0** neu geschriebene Sätze tragen eine Slice-Nummer als Erzählung oder eine Befund-Kennung;
**2** getragene tun es. Unter der hier vertretenen Lesart ist der Diff gegenüber der
Quellen-Klausel **sauber** — und die vom Implementer selbst gemeldete Zeile ist **kein**
Verstoß.

**Was daraus folgt, gehört nicht in diesen Report.** Dass 464 Zeilen über 124 Dateien unter
jeder Lesart stehen bleiben, ist richtig beobachtet und ist genau der Posten, den `add5f43`
einem Planungs-Schnitt zuweist. Ob dieser Schnitt existiert, ist eine Planner-Frage; gemessen
existiert er heute nicht
(`git grep -ln 'Quellen-Klausel\|3\.7' -- docs/plan/planning/open docs/plan/planning/next` →
kein Träger). Das ist eine Beobachtung, kein Finding gegen `722e272` — die Sektion selbst nimmt
die Bestands-Räumung ausdrücklich aus ihrem Auftrag heraus.

---

## Negativbefunde (geprüft, ohne Befund)

1. **Die vier Stellen von MEDIUM-1 des Vor-Reviews sagen jetzt dasselbe wie der Ort.**
   `grep -nE 'ausstehend|steht (noch )?aus|zieht mit dem Move|alten Ort|bis dahin'` über
   `CO-004` und den Index liefert **eine** Zeile, und die ist die `§Geschichte`-Zeile vom
   2026-08-30. Status-Kopf, beide Haken und die Index-Zelle sind gezogen; die Haken-Bilanz ist
   `3` gehakt zu `1` offen (Folge-Slice), und der Erklärungs-Absatz darunter nennt genau diese
   Aufteilung.
2. **Die `§Geschichte`-Doppelzeile trägt — sie folgt der `CO-003`-Präzedenz wörtlich.** Dort
   steht die Zeile *„Modul-7-Übergang **aufgelöst** — Trigger eingetreten, Vollzug ausstehend
   und übergeben"* (2026-08-28) unverändert neben der späteren *„**Vollzogen**: `git mv` nach
   `done/` …"* (2026-08-28) — selbes Datum, alte Zeile erhalten. `CO-004` macht es identisch.
   **Zweideutig ist es nicht:** ein `§Geschichte`-Log ist Chronik von Beruf, seine Zeilen sind
   datierte Ereignisse und keine Zustandsfelder; den Zustand tragen Kopf, Haken, Index und Ort,
   und die sagen alle vier dasselbe (Negativbefund 1). Chronik **umzuschreiben** wäre der
   Fehler gewesen — §3.7 verlangt für Zustandsfelder den Zustand, nicht für ein Log die
   Rückdatierung.
3. **Der neue Wächter hat Zähne, unabhängig nachgewiesen.** Die Mutation von Fall `219` wurde
   auf einer **Kopie** des vendored Satzes außerhalb des Repos nachgestellt und die Logik der
   drei Funktionen (`kopiere_ziel`, `wiederkehrend_real`, `wiederkehrend_code`) unverändert
   darüber gefahren: der `diff` meldet `< observations.template.md` — rot, mit genau der Zeile,
   die der Fehlermeldungs-Block beschreibt. Der `OHNE-ZIEL:`-Pfad wurde auf demselben Weg
   geprüft (Kopiere-Satz entfernt): er feuert und erscheint im `diff`. Der Baum wurde dabei
   nicht angefasst; `make mutate` ist nicht gelaufen.
4. **Der Wächter misst die Eigenschaft, nicht die heutige Aufzählung.** Über alle **21**
   in-scope-Vorlagen liefert `kopiere_ziel` einen Ziel-Pfad (0 leere), und genau **7** tragen
   einen `<…>`-Platzhalter darin — dieselben sieben, die `isRecurring` nennt. Der Vergleich
   läuft gegen den **Rumpf** der Funktion, nicht gegen `courseSet()`; die Rumpf-Begrenzung ist
   nötig und wirkt, weil der Kommentar darüber dieselben Dateinamen im Fließtext führt (`awk`
   endet an der ersten spaltenbündigen `}`, die innere `}` des `switch` ist eingerückt).
5. **Die zwei benannten Grenzen treffen zu.** (1) `internal/emit/templates.go:324` ruft
   `isRecurring(path.Base(rel))` — der Basename-Vergleich bildet die Signatur ab, nicht eine
   Bequemlichkeit. (2) `.dockerignore:5` führt `.harness`; die `go-test`-Stufe sieht den realen
   Satz nicht, und kein Ziel in `make gates` fährt realen Satz **und** Emit-Regel zusammen.
   Beides selbst nachgelesen. Einschränkend gilt MEDIUM-2: die Zählung *zweifach* trifft nicht.
6. **Die Aufzählung im `GRENZE`-Absatz ist vollständig über den Bereich, den der Set-Index
   selbst absteckt.** Der Absatz sagt, *„derivative Indexe, Planning-Index, `welle-results` und
   `MR-NNN-titel`"* stünden in keinem der beiden Eimer — das sind fünf Vorlagen. Gemessen führt
   `templates/README.md` **10** Singletons und **5** Wiederkehrende von **20 Dokument-Skeletten**
   (die Zahl steht dort selbst, `:8` und `:14`); 20 − 15 = 5, und es sind genau diese fünf. Die
   zwei Skill-Vorlagen fehlen zu Recht: dieselbe README sagt `:105` *„Skill-Dateien sind **keine**
   Dokument-Skelette"*. Die Aussage ist also nicht bloß illustrativ, sie ist deckungsgleich.
7. **Die Set-Index-Aussage, die HIGH-1 trug, ist am Text nachgelesen und wird durch das
   Nicht-Emit nicht falsch.** `templates/README.md` §*Ein- vs. wiederkehrende Templates* führt
   `reconciliation` unter den Singletons, definiert als *„einmal beim Bootstrap zu `.md` füllen,
   dann das `.template.md` verwerfen"*. Für ein Brownfield-Repo ist das wahr; für Greenfield
   spricht der Satz nicht. Das ist die Grundlage, auf der `a6d436c` entscheidet — hier nur
   gegengelesen, nicht neu bewertet (Auftrag).
8. **§3.2 ist eingehalten.** `git show 722e272 | grep -nE '^\+.*(nolint|shellcheck disable)'` →
   keine Zeile. `test/mutations/*.sh` liegt im Prüfbereich von `shell-lint` (`Makefile:389`),
   und das Ziel war im eigenen Gate-Lauf grün — Fall `219` löst SC2016 durch Wortwahl statt
   durch Suppression, wie sein Kommentar sagt.
9. **§3.3 ist nicht berührt.** `722e272` enthält keinen Move (`git show --stat` → fünf Dateien,
   eine davon neu, keine umbenannt).
10. **§3.8 ist nicht berührt.** Weder `AGENTS.md` noch `harness/conventions.md` stehen im Diff;
    der Lauf schreibt kein Norm-Artefakt und gibt die Abweichungs-Frage ausdrücklich ab. Das ist
    genau die Bewegung, die §3.8 verlangt — und sie ist an `a6d436c` als eigenem Architect-Commit
    nachweisbar.
11. **§3.9 ist eingehalten.** Alle gefahrenen Sensoren liefen über `make`; die eigenen Sonden
    dieses Reviews nutzen `bash`, `awk`, `grep`, `sed`, `find`, `git` — keine Host-Toolchain,
    kein Paketmanager, kein Netz.
12. **`LH-QA-01` ist gewahrt.** Der Diff fügt kein Make-Ziel und keinen Gate-Anspruch hinzu.
    `make comment-claims` meldet im eigenen Lauf `46 Datei(en) geprueft, 0 Befund(e)`; der im
    Kommentar genannte bats-Fall existiert wörtlich
    (`test/courseset-fixture.bats:190`). Anzumerken ist die Grenze des Ziels selbst: sein
    `CLAIM`-Vokabular (`harness/tools/comment-claims.sh:30`) kennt *„misst"* nicht, der Satz an
    `templates.go:26` wird also gar nicht erst geprüft — die Existenz ist von Hand belegt.
13. **`MR-025` ist eingehalten, und die Zahl stimmt nicht nur nachbarschaftlich.** Der
    `CO-004`-Kopf nennt *„`make test-bats` am 2026-08-30: `1..196`"*; das Ziel existiert
    (`Makefile:54`) und liefert im eigenen Lauf genau diese Zeile. Der Satz sagt zusätzlich,
    dass die Zahl mit dem Test-Bestand wandert.
14. **Der Emit-Bestand ist unverändert.** Die Änderung an `internal/emit/templates.go` ist rein
    kommentarisch (Kommando im Kopf dieses Reports); `smoke`/`full-smoke`/`test-go` messen
    denselben Gegenstand wie im Vor-Review.
15. **Der dritte Griff an `docs/plan/carveouts/README.md` verstößt gegen keine aktive ADR.**
    `ADR-0024` Festlegung 2 lässt die Eigentums-Frage für dieses Register ausdrücklich offen,
    und `modul-07-carveouts.md` gibt `git mv` und Config-Updates dem Implementer. `ADR-0025` ist
    `Proposed` und bindet nicht (INFO-3).

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 4 | MEDIUM-1, MEDIUM-2, MEDIUM-3, MEDIUM-4 |
| LOW | 3 | LOW-1, LOW-2, LOW-3 |
| INFO | 3 | INFO-1, INFO-2, INFO-3 |

**Instrument-Prüfung über die Liste.** MEDIUM-2 und LOW-1 sitzen im selben Grenz-Block, messen
aber Verschiedenes (eine **fehlende** Grenze gegen eine **falsch modalisierte**); fällt die eine,
bleibt die andere. MEDIUM-3 und MEDIUM-4 hängen beide am aufgelösten `CO-004`, sind aber
gegenläufig: MEDIUM-3 sagt, ein Posten habe **keinen** Träger, MEDIUM-4, zwei Träger sagten etwas
**Falsches**; keiner ist das Instrument des anderen. MEDIUM-1 hängt an `a6d436c` — würde diese
Entscheidung zurückgenommen, entfiele der Befund vollständig; er ist damit der einzige, dessen
Instrument außerhalb dieses Diffs liegt, und das ist am Befund vermerkt. LOW-2 ist von den
übrigen unabhängig, weil er den Treiber betrifft und nicht den Wächter.

**Wiederholungs-Signal (Kontext-Eskalation).** Die Klasse *Grenz-/Vollständigkeitsaussage ohne
gemessene Menge* trägt in diesem Lauf MEDIUM-2 und LOW-1; sie stand in den Reviews zu
slice-081, slice-133, slice-138 und in der Vorrunde zu slice-130 jeweils schon im Befund. Das ist
mehr als die dritte Wiederholung — nach dem Reviewer-Skill ein Steering-Loop-Signal. Bemerkenswert
ist die Form, die sie diesmal annimmt: der Lauf **baut** den Sensor, den die Vorrunde verlangt
hat, und deklariert dabei die Grenzen seines eigenen Sensors abgezählt. Die Klasse ist also nicht
Nachlässigkeit, sondern hängt an der Gewohnheit, eine Menge zu **benennen**, wo sie zu **messen**
wäre — der Träger wäre eine Checklisten-Zeile vor jeder Formulierung *„N-fach"*, nicht mehr
Sorgfalt.

---

## Verdikt

**NICHT KONFORM — 0 HIGH, 4 MEDIUM.** Die Fix-Runde ist substanziell: beide HIGH sind
beantwortet (einer durch die Architect-Entscheidung, einer durch eine eigene ADR), MEDIUM-1 des
Vor-Reviews ist an **vier** statt drei Stellen behoben und folgt dabei der `CO-003`-Präzedenz
korrekt, LOW-1 ist übernommen und die Streichung ist gegen den Geltungsbereich von `MR-017`
belegt. Der neue Wächter aus MEDIUM-2 ist die stärkste Arbeit dieses Diffs: er misst die
**Definition** gegen den **realen** Satz statt gegen die Fixture, seine Zähne sind unabhängig
nachgestellt, und beide Extraktionen sind gegen den leeren Fall abgesichert.

Was blockiert, blockiert an vier verschiedenen Stellen und trifft **nicht dieselbe Rolle**:

- **Am Implementer** hängen MEDIUM-1 (der Grenz-Absatz behauptet eine Offenheit, die seit
  `a6d436c` nicht mehr besteht) und MEDIUM-2 (die abgezählte Grenz-Aussage des eigenen
  Wächters). Beides sind Kommentar-Aussagen an Stellen, die dieser Diff geschrieben hat.
- **Am Planner** hängen MEDIUM-3 (kein lebender Träger für die Übergaben; der Plan verlangt in
  §6 Risiko 1 wörtlich eine Slice-ID) und MEDIUM-4 (Roadmap und Welle-Datei sagen, `CO-004`
  halte einen Gate, der grün ist).

**Zum Verifier kann der Slice noch nicht** — aber der Grund liegt nicht in der Code-Arbeit.
Der Verifier prüft die DoD, und deren Punkte (2) und (3) sind vom Zustand des Baums gedeckt;
was fehlt, sind zwei Kommentar-Korrekturen und zwei Planner-Posten. MEDIUM-1 und MEDIUM-2 sind
in einem Implementer-Lauf zu schließen. MEDIUM-3 und MEDIUM-4 sind es **nicht** — sie verlangen
einen Rollen-Wechsel, und ein Implementer-Lauf, der Roadmap, Welle-Datei oder einen
Slice-Schnitt anfasste, beginge genau den Fehler, den `AGENTS.md` §3.8 und die Begründung
darunter beschreiben.

**Kein Rollen-Konflikt liegt vor** (Modul 8): kein HIGH, und keiner der vier MEDIUM ist
Gegenstand einer Meinungsverschiedenheit zwischen Rollen — MEDIUM-1 und MEDIUM-4 sind
Nachlauf-Drift zweier Entscheidungen, die inhaltlich unbestritten sind.

---

## Anhang — Kommandos zu den Zahlen dieses Reports

```sh
# 18 von 21: Hinweis-Bloecke mit mehr als EINEM Backtick-Paar hinter dem Wort "Kopiere"
R=.harness/baseline/v5.12.0/templates
n=0; tot=0
while read -r rel; do
  tot=$((tot+1))
  blk="$(awk '/^>/{p=1; sub(/^>[ \t]?/,""); buf=buf" "$0; next} p{exit} END{print buf}' "$R/$rel")"
  after="${blk#*Kopiere}"
  [ "$(printf '%s' "$after" | grep -o '`[^`]*`' | wc -l)" -gt 1 ] && n=$((n+1))
done < <(cd "$R" && find . -type f | sed 's|^\./||' | grep '\.template\.md$' \
         | grep -v '^project-readme\.template\.md$' | LC_ALL=C sort)
echo "$n von $tot"

# 4: in-scope-Vorlagen mit dem Basenamen README.template.md
find .harness/baseline/v5.12.0/templates -type f -name 'README.template.md' | wc -l

# 1: einziger Mutations-Fall mit einem # files:-Ziel unter .harness/baseline/
grep -n '^# files:' test/mutations/*.sh | grep -c baseline

# 29 -> 46 bzw. 25 -> 34: Zeilen der beiden Doc-Kommentare
for r in 722e272^ 722e272; do
  git show $r:internal/emit/templates.go \
    | awk '/^\/\/ isBrownfieldOnly/{f=1} f&&/^func isBrownfieldOnly/{exit} f' | wc -l
done

# 20 Dokument-Skelette, 10 Singletons + 5 Wiederkehrende im Set-Index
sed -n '8p;14p' .harness/baseline/v5.12.0/templates/README.md
sed -n '/Ein- vs\. wiederkehrende/,/^## /p' .harness/baseline/v5.12.0/templates/README.md
```

**Keine Erwartungswerte** ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl wandert mit dem vendored Satz bzw. dem Baum.
