# Review: ADR-0037 — Konsistenz-Review, Runde 2

**Review-Art:** Plan-Review gegen Spec/ADR (Modul 10 §Drei Review-Arten) — geprüft wird die
Entscheidung gegen ihre zitierten Quellen, **nicht** DoD-Konformität (Verifier-Rolle, getrennter
Kontext).

**Gegenstand:** [`docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`](../plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
Status `Proposed`, Nacharbeit-Commit `1341d23` (Diff `1341d23^..1341d23` = zwei Dateien, die ADR
und der ADR-Index).

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Reviewer:** frischer Kontext. Keines der geprüften Artefakte selbst geschrieben, an keinem etwas
geändert. **Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf selbst gefahren**;
nichts ist aus der Commit-Message von `1341d23`, aus dem Slice-Plan oder aus der ADR übernommen.
Die fünf blockierenden Befunde der Vorrunde sind **einzeln am Ist-Stand** nachgeprüft, nicht am
Änderungsbericht.

---

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `1341d23` gegen `1341d23^` = `dab5028`. `HEAD` steht in diesem Lauf auf
  `c217082`; zwischen Gegenstand und Prüfung liegen vier Commits, alle aus der parallelen
  `slice-125`-Arbeit und keiner an einer ADR
  (`git log --oneline 1341d23..HEAD -- docs/plan/adr/ | wc -l` → **0**).
- **`LH-*`:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Rang 1, der
  ausgelegte Absatz), [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
- **Referenzierte aktive ADRs**, Status in diesem Lauf gemessen
  (`for f in 0005 0006 0007 0016 0024 0034; do grep -m1 '^\*\*Status:\*\*' docs/plan/adr/$f-*.md; done`):
  alle sechs `Accepted`. Keine `Superseded`/`Deprecated` unter den zitierten.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4 (die Kosten-Asymmetrie, die
  diesen Report trägt), §3.5, §3.6, §3.8, §3.9, §3.10, §3.11. Dazu
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  und [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung).
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-06-adr-0037-konsistenz-review.md) — Verdikt *Konsistenz NICHT BESTÄTIGT*,
  0 HIGH · 5 MEDIUM · 4 LOW · 3 INFO. Als Runden-Muster herangezogen: die vier ADR-0028-Runden.
- **Slice-Plan:** `slice-190` — das Übergabe-Artefakt, dessen zwei Fragen die ADR beantwortet.
  Seine Verzeichnis-Position steht hier bewusst nicht als Pfad
  ([`AGENTS.md`](../../AGENTS.md) §3.11); die Kommandos unten adressieren ihn über den Glob
  `docs/plan/planning/*/slice-190-*.md`, der in diesem Lauf **genau eine** Datei trifft
  (`ls -1 docs/plan/planning/*/slice-190-*.md | wc -l` → **1**, kein Erwartungswert).

**Gate-Lauf.** `make docs-check` in diesem Lauf gefahren (Docker-only, §3.9) →
vor dem Schreiben dieses Reports `d-check: 861 Datei(en) geprüft, 0 Befund(e)`, danach
`d-check: 862 Datei(en) geprüft, 0 Befund(e)`, beide EXIT 0. Jeder Link und jeder Anker der ADR, der
Index-Zeile und dieses Reports löst auf. `make gates` in diesem Lauf ebenfalls gefahren →
**EXIT 0** — der Lauf deckt allerdings auch die fremden Änderungen im Arbeitsbaum (unten) und ist
damit keine Aussage allein über den Gegenstand.

**Der Baum ruht nicht, und das ist hier benannt statt weggelassen.** `git status --porcelain`
meldet drei fremde, nicht committete Änderungen aus der parallel laufenden `slice-125`-Arbeit —
[`.d-check.yml`](../../.d-check.yml), die Roadmap und [`harness/README.md`](../../harness/README.md).
Die `.d-check.yml` trägt dabei ein zusätzliches, noch nicht committetes Modul; der oben genannte
`docs-check`-Lauf ist also über einer **schärferen** Gate-Konfiguration gefahren als der des
Architect (dessen Lauf meldete `840`). Von diesem Report ist keine der drei Dateien angefasst und
keine mitcommittet.

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills.

### M-1 — Der eine Baseline-Beleg ohne dreiteilige Form steht unverändert, und ADR-0016 macht genau ihn zur Vorbedingung des Accept-Übergangs

- `kategorie`: **MEDIUM** (blockiert den Statuswechsel)
- `quelle`: [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 und
  Träger (a)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:366` (Festlegung 4,
  zweiter Spiegelstrich)
- `befund`: Der Satz *„Das Regelwerk legt es im Rückbau an, nicht im Skelett-Schritt"* ist
  unverändert eine Aussage über das Baseline-Regelwerk und trägt keinen der drei Teile, die
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 für einen
  Baseline-Beleg in einem einfrierenden Artefakt verlangt — kein Regelwerks-Dateiname, kein
  Abschnittsname, kein Zitat. Der Tag daneben steht im Ziel-Pfad eines Links auf eine **Vorlage**,
  und ADR-0016 nimmt den lokalen Präfix ausdrücklich aus dem Beleg aus. Festlegung 3 (a) derselben
  ADR lautet: *„Bevor der Status eines ADR auf Accepted wechselt, werden seine Baseline-Belege in
  die Form aus Festlegung 2 gebracht."* Runde 1 führte denselben Satz als L-3 **mit derselben
  Quelle**; die Nacharbeit hat ihn mit der Begründung stehen lassen, jene Runde führe ihn nicht
  als blockierend. Das Severity-Label eines Reports hebt eine in einer aktiven ADR gesetzte
  Vorbedingung nicht auf.
- **Failure-Szenario:** Der Statuswechsel wird vollzogen; ab `Accepted` sperrt
  [`AGENTS.md`](../../AGENTS.md) §3.4 den Satz. Ein späterer Lauf, der die Regelwerks-Aussage
  nachschlagen will, hat weder Datei noch Abschnitt und muss den vendored Baum absuchen — genau
  die Eigenschaft, für die ADR-0016 die Form eingeführt hat; und beim nächsten Baseline-Sprung ist
  nicht entscheidbar, ob die Aussage noch gilt.
- `verifizierbar`: **nein** — der von ADR-0016 selbst beschriebene Form-Sensor ist dort
  ausdrücklich als *„Gebaut ist er nicht"* geführt. Reproduzierbar:
  ```sh
  sed -n '364,367p' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md \
    | grep -cE 'grundlagen-[a-z-]+\.md|modul-[0-9]{2}-[a-z-]+\.md'   # 0 — der Spiegelstrich
                                                                     #     nennt keinen
                                                                     #     Regelwerks-Dateinamen
  ```
  Die Aussage selbst ist **inhaltlich richtig** — in diesem Lauf an der Baseline `v6.0.0`,
  `grundlagen-harness-dateien.md` §Verzeichniskonvention nachgemessen:
  *„docs/plan/planning/reconciliation.md # Reconciliation-Register: nur im Brownfield-Bootstrap"*.
  Es fehlt der Beleg, nicht die Wahrheit.
- `klasse`: *Regelwerks-Aussage ohne dreiteiligen Beleg vor dem Accept-Übergang*

### M-2 — Die neue Subjekt-Grenze *Ort statt Inhalt* und Festlegung 2 setzen sich nicht zusammen, und Konsequenz 2 verspricht mehr, als das Kriterium trägt

- `kategorie`: **MEDIUM** (vor dem Statuswechsel zu klären)
- `quelle`: [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  (Rang 1 — der ausgelegte Satz) · Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:339–342` (Festlegung 4,
  Grund (i)) gegen `:317–322` (Festlegung 2) und `:391–392` (Konsequenz 2)
- `befund`: **Zwei Beobachtungen an derselben Naht.** (1) Grund (i) setzt *„Das Subjekt der
  Festlegung 1 ist ein Ort, nicht sein Inhalt … Ein Index ist eine Datei **in** einem angelegten
  Ort und fällt nicht unter das Subjekt."* Festlegung 2 legt einen Ort über eine **Datei mit
  Inhalt** an und sagt das ausdrücklich: *„Der Träger der Aussage ist die Datei selbst"*. Was die
  zwei Fälle trennt, ist allein, ob der Ort schon *angelegt* ist — genau das Merkmal, das
  Festlegung 2 für ihren eigenen Gegenstand beseitigt: nach ihrem Vollzug ist
  `observations/README.md` „eine Datei in einem angelegten Ort", und das Kriterium kann sie nicht
  mehr herleiten. Das Merkmal steckt im Wort *„angelegten"* und ist nirgends als das
  unterscheidende benannt. (2) Der Satz, dessen Klammer Festlegung 1 für beispielhaft erklärt,
  schreibt den Träger mit vor — *„Leere Struktur-Verzeichnisse (…) werden mit `.gitkeep`
  gehalten"*. Festlegung 2 weicht davon ab; die Deckungs-Zusage *„Die Aufnahme eines Ortes, der
  sie erfüllt, ist **Erfüllung** … **kein Change Request**"* spricht von der Aufnahme eines
  **Ortes** und reicht nicht bis zum abweichenden Träger. Konsequenz 2 sagt dennoch zu, *„der
  nächste Ort derselben Klasse braucht keine eigene Runde, sondern nur die drei Bedingungen"* —
  während der eigene Hauptfall für die Träger-Frage eine eigene Zeile in der Alternativen-Tabelle
  brauchte (Option C, `.gitkeep` statt `README.md`), die keine der drei Bedingungen entscheidet.
- **Failure-Szenario:** Ein späterer Lauf wendet Konsequenz 2 auf den nächsten Ort an, misst
  (a)(b)(c) und setzt ein `.gitkeep` — während ein mitemittierter Text dort eine **Datei** beim
  Namen nennt. Grund (i) erklärt diese Datei für außerhalb des Subjekts, und der Defekt, den diese
  ADR behebt (drei Anweisungssätze nennen einen Ort, zwei davon namentlich eine Datei, und kein
  Pfad legt sie an), entsteht eine Ebene tiefer neu. Ab `Accepted` ist die Klärung eine Folge-ADR.
- **Was dieser Befund nicht bestreitet:** den **Ausschluss** der derivativen Index-Sichten. Grund
  (ii) — die eigene Klassen-Regel desselben
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Absatzes — ist
  von (i) unabhängig und trägt ihn allein; in diesem Lauf verbatim gegen die Quelle gehalten. Der
  Befund betrifft die Komposition der Festlegungen, nicht das Ergebnis.
- `verifizierbar`: **nein** — kein Gate liest, welches Subjekt ein ADR-Satz seinem Kriterium gibt.
  Reproduzierbar:
  ```sh
  sed -n '317,322p;339,342p;391,392p' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
    | grep -o 'Leere Struktur-Verzeichnisse[^;]*'
  # -> "Leere Struktur-Verzeichnisse (Lifecycle- Ordner, ADR-/Carveout-/Reviews-Ordner)
  #     werden mit `.gitkeep` gehalten"
  grep -c 'Der Träger der Aussage ist die Datei selbst' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 1
  ```
- `klasse`: *Kriterium und sein eigener Hauptfall greifen auf verschiedene Subjekte*

### L-1 — Bedingung (a) ist eine Disjunktion, und die zwei (a)-Urteile der Datei ziehen aus verschiedenen Quell-Klassen

- `kategorie`: LOW
- `quelle`: Maintainability · [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:287–298` (a-Beleg) gegen
  `:366–367` (a-Ausschluss)
- `befund`: (a) lautet *„das mitemittierte Regelwerk **oder** ein mitemittierter Text ihn … im
  Indikativ als vorhanden führt"* — eine Disjunktion, die ein erfüllter Teil erfüllt. Für
  `harness/conventions/` zieht die Datei den **Regelwerks**-Zweig (Verzeichniskonvention). Für das
  Reconciliation-Register begründet sie das Scheitern von (a) mit einem **anderen** Text (dem
  mitemittierten Planning-Index), obwohl dieselbe Verzeichniskonvention den Gegenstand sieben
  Zeilen über `harness/conventions/` ebenfalls führt. Was ihn ausschließt, ist der Modus-Zusatz in
  seinem Kommentar (*„nur im Brownfield-Bootstrap"*) — dass ein solcher Zusatz den Indikativ
  aufhebt und dessen Fehlen ihn trägt, ist die Regel, an der beide Urteile hängen, und sie steht
  nicht in der Datei. **Die zwei Urteile sind im Ergebnis konsistent** — in diesem Lauf gemessen:
  der Zusatz steht beim Reconciliation-Register und fehlt bei `harness/conventions/` wie bei
  `observations/`. Konsistent ist damit die Anwendung, nicht die geschriebene Regel.
- **Failure-Szenario:** Ein späterer Lauf misst nach Konsequenz 2 einen neuen Ort, findet ihn in
  derselben Baumdarstellung mit einem Modus-Zusatz und liest — dem `harness/conventions/`-Präzedenz
  folgend, wo die bloße Listung genügte — (a) als erfüllt. Das Gegenbeispiel, das diese ADR
  ausdrücklich draußen halten will, käme über den Disjunktions-Zweig herein.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  sed -n '14,15p;22p' .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md
  # docs/plan/planning/observations/            # Beobachtungs-Register: je Beobachtung ein Verzeichnis
  # docs/plan/planning/reconciliation.md        # Reconciliation-Register: nur im Brownfield-Bootstrap
  # harness/conventions/        # ein MR je Datei; done/ = aufgelöst
  ```
- `klasse`: *Kriterium wird angewandt, ohne dass seine Auswertungs-Regel geschrieben steht*

### L-2 — Die zweite Zahl über den fremden Plan-Stand steht ohne Kommando und ohne Datum

- `kategorie`: LOW
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 · Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:460` und `:461`
  (§Geschichte, beide Zeilen)
- `befund`: Die Korrektur zu M-4 nennt in derselben Klammer **zwei** Aussagen über `slice-190` und
  behandelt sie ungleich: *„§6 trug am 2026-09-06 **sechs** Risiken ohne Ausgang"* steht mit
  Datum, Kommando und *kein Erwartungswert* — *„gemessen nennt §4 **eine** Bedingung für
  `open → next` neben dem WIP-Limit"* steht als Messwert (*„gemessen"*, fett gesetzte Ziffer) ohne
  Kommando und ohne Datum. Zeile `:460` wiederholt sie im Präsens (*„sie **ist** die eine
  Bedingung, die §4 … nennt"*) über eine lebende, vom Planner fortgeschriebene Plan-Datei.
  **Die Aussage ist inhaltlich richtig** — in diesem Lauf an §4 nachgemessen.
- **Failure-Szenario:** Der Planner ergänzt §4 um eine zweite Bedingung. Die dann falsche
  Präsens-Aussage steht in einer nach [`AGENTS.md`](../../AGENTS.md) §3.4 gesperrten Datei; ihre
  Nachbar-Aussage im selben Satz ist durch das Datum davor geschützt, sie nicht.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  sed -n '/^## 4\./,/^## 5\./p' docs/plan/planning/*/slice-190-*.md | grep -A1 'open` → `next'
  # -> "WIP-Limit frei **und** die Change-Request-Frage aus §3 ist beantwortet."
  ```
- `klasse`: *Aussage über den Stand eines fremden Artefakts ohne Messung an ihm*

### L-3 — Das Zitat, das die (a)-Bedingung trägt, nennt einen zweiten Ort, über den die Datei nichts sagt

- `kategorie`: LOW
- `quelle`: Maintainability · [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:287–291`
- `befund`: Der (a)-Beleg zitiert die Regelwerks-Zeile *„harness/conventions/ # ein MR je Datei;
  done/ = aufgelöst"* und schließt daraus auf `harness/conventions/`. Dieselbe Zeile nennt
  `done/`, und die Vorlage, die der zweite Beleg-Halbsatz anführt, nennt es ein zweites Mal
  (*„wandert sie per `git mv` nach `conventions/done/`"*). `harness/conventions/done/` ist ein Ort
  derselben Klasse: er entsteht ohne Bootstrap nicht, sein Träger wäre ein `.gitkeep`, und ob (a)
  für ihn trägt, hängt daran, ob eine Bedingungs-Aussage (*ist der Trigger eingetreten, dann …*)
  als Indikativ zählt. Die Datei entscheidet ihn nicht und erwähnt ihn nicht. Es ist die
  **zweite** Instanz derselben Klasse — Runde 1 führte `docs/plan/carveouts/done/` als L-4, und
  auch dort ist (a) bestritten.
- **Failure-Szenario:** Der Lauf, der Folgepflicht 1 erfüllt, steht vor zwei `done/`-Orten, für
  die Konsequenz 2 *„keine eigene Runde"* zusagt, und findet für beide keine Antwort — die Runde
  fällt trotzdem an, nur ohne Architect.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  sed -n '22p' .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md
  sed -n '86,89p' .harness/baseline/v6.0.0/templates/harness/conventions.template.md
  grep -c 'conventions/done' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 0
  ```
- `klasse`: *Kriterium sagt eine Runde ab, die sein erster Anwendungsfall doch braucht*

### L-4 — Drei Befunde der Vorrunde stehen unverändert

- `kategorie`: LOW
- `quelle`: siehe die genannten Befunde in [Runde 1](2026-09-06-adr-0037-konsistenz-review.md)
- `pfad`: `:329–333` (L-1), `:138–140` gegen `:407–410` (L-2), `:391–392` (L-4)
- `befund`: **Runde-1-L-1** (Festlegung 3 begründet die Idempotenz-Klasse positiv aus einem Umgang
  mit der Datei, den der Baum nicht zeigt), **Runde-1-L-2** (§Kontext weist die Korrektur der
  Handbuch-Zeile 1.13 dem Slice zu, §Konsequenzen nimmt eben diese Zeile ausdrücklich aus und
  verlegt den Nachzug auf die Präsens-Stellen) und **Runde-1-L-4** (`docs/plan/carveouts/done/`
  bleibt außerhalb, obwohl (a) an ihm bestritten ist) sind im Diff nicht berührt. Die Nacharbeit
  sagt das ausdrücklich; hier steht, dass es gemessen so ist.
- **Failure-Szenario:** je das der Vorrunde; alle drei frieren mit dem Statuswechsel ein.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  git diff 1341d23^ 1341d23 -- docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md \
    | grep -cE '^[-+].*(Adopter-Boden|Bestandsbaum des Handbuchs|carveouts/done)'   # 0
  ```
- `klasse`: *Befund der Vorrunde bleibt im Proposed-Fenster liegen*

### INFO-1 — Der Ausschnitt der (b)-Messung spannt zwei `want`-Listen

- `kategorie`: INFO
- `pfad`: `:305–310`
- `befund`: Der Satz nennt *„die `want`-Liste des Mengen-Vergleichs"* (Singular); der abgedruckte
  `sed`-Bereich trifft **beide** `want := []string{`-Blöcke der Datei. Am Ergebnis ändert das
  heute nichts (1 bzw. 0), und die Gegenprobe trägt — ein künftiger Eintrag
  `harness/conventions/` im *zweiten* Block würde die Null jedoch kippen, ohne dass der
  Mengen-Vergleich berührt wäre.
- `verifizierbar`: nein. `grep -c 'want := \[\]string{' internal/emit/templates_test.go` → **2**;
  `sed -n '/want := \[\]string{/,/^[[:space:]]*}$/p' internal/emit/templates_test.go | wc -l` → **25**.
- `klasse`: *Kommando misst einen weiteren Bereich als der Satz benennt*

### INFO-2 — Die Vorlagen-Hälfte des (a)-Belegs nennt keinen Abschnittsnamen

- `kategorie`: INFO
- `pfad`: `:290–298`
- `befund`: Die Regelwerks-Hälfte des (a)-Belegs ist nach
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 vollständig — Tag
  `v6.0.0`, Datei `grundlagen-harness-dateien.md`, Abschnitt §Verzeichniskonvention, Zitat. Die
  zweite Hälfte (*„Die Vorlage … nennt ihn ein zweites Mal"*) trägt Tag und Dateiname nur im
  Kommando-Operanden und keinen Abschnittsnamen (§Adaptions-Block). Ob eine Aussage über eine
  **Vorlage** überhaupt unter die Beleg-Form fällt, sagt ADR-0016 nicht; der Beleg steht ohne sie.
  **Geprüft und in Ordnung:** der zitierte Satz steht im **Rumpf** der Vorlage, nicht in einem
  `<!-- -->`-Block — er überlebt damit den Template-Abbau und ist keine *Norm nur im
  Template-Kommentar*.
- `verifizierbar`: nein.
  `grep -n 'Jede Adaption ist eine eigene Datei unter' .harness/baseline/v6.0.0/templates/harness/conventions.template.md`
  → **86**, im Abschnitt `## Adaptions-Block` (Zeile 83), außerhalb jedes Kommentarblocks.
- `klasse`: *Beleg-Form nur zur Hälfte angelegt*

### INFO-3 — Die Singleton-Klammer wird vom Ist-Stand bereits nicht-abschließend gelesen

- `kategorie`: INFO
- `pfad`: `:274–282`
- `befund`: Der neue Absatz stellt fest, die drei übrigen Klassen-Klammern *„bleiben unberührt"*.
  Für die Singleton-Klammer gilt schon heute, dass sie den emittierten Bestand in **beide**
  Richtungen verfehlt: sie nennt Root-`README.md`, das nicht emittiert wird, und sie nennt
  `docs/plan/planning/README.md` sowie die zwei `.harness/skills/*.md` nicht, die emittiert
  werden. Die Lesart *die Klammer nennt Instanzen, nicht die Menge* ist dort also bereits Praxis —
  das stützt Festlegung 1, und es bleibt in der Datei unausgesprochen.
- `verifizierbar`: nein. `sed -n '269,288p' internal/emit/templates_test.go` (die `want`-Liste des
  Mengen-Vergleichs) gegen die Singleton-Klammer aus
  `sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md`.
- `klasse`: *Abgrenzung erklärt eine Nachbar-Klasse für unberührt, deren Ist-Stand dieselbe Lesart schon trägt*

### INFO-4 — Die Geschichte-Zeile führt INFO-1 als nicht behoben und nennt ihn im selben Satz behoben

- `kategorie`: INFO
- `pfad`: `:461`
- `befund`: *„L-1 bis L-4 und INFO-1 bis INFO-3 sind hier nicht behoben — … INFO-1 ist als
  Nebenwirkung von M-5 mitgezogen"*. Die zwei Halbsätze widersprechen sich für INFO-1; die
  Nachmessung gibt dem zweiten recht (das Kommando liest jetzt `internal/ cmd/`).
- `verifizierbar`: nein.
  `git diff 1341d23^ 1341d23 -- docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md | grep -c "^+.*internal/ cmd/ --include"`
  → **2**.
- `klasse`: *Zwei Halbsätze desselben Eintrags geben verschiedene Auskunft über denselben Posten*

### INFO-5 — Zwei INFO der Vorrunde stehen unverändert

- `kategorie`: INFO
- `pfad`: `:56–66` (INFO-2) und `:22` (INFO-3)
- `befund`: Die zwei verbatim zitierten Kommentar-Absätze stehen weiter in umgekehrter
  Quell-Reihenfolge (Quelle: Zeile **133** *„Im Adaptions-Block …"*, Zeile **143** *„GRENZE: …"*;
  im Zitat umgekehrt), und die `Bezug`-Liste nennt weiter
  [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) ohne Rumpf-Vorkommen, während
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  und [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
  fehlen, obwohl Festlegung 1 die Frage *Erfüllung oder Change Request* entscheidet.
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  ist dagegen ergänzt, in ADR und Index-Zeile.
- `verifizierbar`: nein.
  `grep -n 'Im Adaptions-Block steht zu dieser Weiche\|GRENZE: LH-FA-02' internal/emit/templates.go`
  → **133**, **143**; `grep -c 'MR-015\|MR-036' docs/plan/adr/0037-*.md` → **0**.
- `klasse`: *Bezugsliste deckt die entschiedene Frage nicht*

---

## Negativbefunde (geprüft, ohne Befund)

**Jedes Kommando der ADR in diesem Lauf nachgefahren — jedes liefert den abgedruckten Wert.** Die
Datei trägt **12** `sh`-Blöcke — gemessen mit einem `grep -c` auf die öffnende Zaun-Zeile, kein
Erwartungswert — mit zusammen **22** Kommandos, dazu **eines** inline in der Geschichte-Zeile.
Die zwei Kommando-Zahlen sind **von Hand gezählt**; kein Kommando liefert sie
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1, zweiter Satz). Ergebnisse in der Reihenfolge der Datei: `1` · `1` (die zwei
Emitter-Kommentare) · `1` · `1` (die zwei Baseline-Zitate in `modul-06-roadmap.md`) · `3` · `2`
(Anweisungssätze) · `3` · `2` (Go-Fundstellen, jetzt über `internal/ cmd/`) · die vierzeilige
Klammer-Ausgabe · die Lifecycle-Klammer · `4` · `3` · `| 0.8.0 | 2026-07-21` · `2026-09-03` · `0`
(keine vendored Vorlage) · `1` · `1` (der (a)-Beleg) · `1` · `0` (die (b)-Gegenprobe) · `2` · `1` ·
die zweizeilige Link-Ausgabe der zwei Index-Vorlagen · `6` (die Geschichte-Zeile).
**Keine Abweichung.**

**Die fünf blockierenden Befunde der Vorrunde, einzeln am Ist-Stand nachgeprüft:**

- **M-1 behoben, und der Ersatz-Grund trägt.** Der (c)-Grund ist entfernt und ausdrücklich als
  nicht tragend benannt. Grund (ii) ist in diesem Lauf verbatim gegen
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) gehalten und
  stimmt (Zeilenumbruch nach *„ADR-/"* normalisiert, nach
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 zulässig); er ist von
  (i) unabhängig und trägt den Ausschluss allein. Dass die zitierte Rang-1-Regel ihrerseits mit
  *„nicht als gate-unsichere Platzhalter-Skelette"* begründet ist — also mit dem Grund, den M-1
  als hinfällig nachwies —, ändert daran nichts: sie bindet als Rang-1-Satz, nicht über ihre
  Begründung, und die ADR sagt an derselben Stelle, dass (c) heute nicht mehr trägt. Was an (i)
  offen bleibt, steht als M-2.
- **M-2 behoben.** Die drei Bedingungen stehen einzeln. **(a)** trägt die volle Form nach
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 — Tag `v6.0.0`,
  `grundlagen-harness-dateien.md`, §Verzeichniskonvention, Zitat verbatim (Whitespace
  normalisiert). **(b)** steht an der `want`-Liste mit Gegenprobe, und die Null ist belastbar: die
  Test-Fixture `courseSet()` **führt** `harness/conventions/MR-NNN-titel.template.md` als
  wiederkehrende Vorlage, die Abwesenheit im emittierten Baum ist also ein Urteil des Emit-Pfades
  und kein Loch in der Fixture. **(c)** am leeren `.gitkeep` ist trivial und richtig. Die
  Ausdehnungs-Frage zu (a) steht als L-1, der Ausschnitt der (b)-Messung als INFO-1.
- **Die Prüfung, ob (a) in zwei Richtungen verschieden misst, fällt negativ aus.** Dieselbe
  Verzeichniskonvention führt `harness/conventions/` und
  `docs/plan/planning/reconciliation.md`; der Unterschied ist der Modus-Zusatz *„nur im
  Brownfield-Bootstrap"*, der beim einen steht und beim anderen fehlt — wie auch bei
  `docs/plan/planning/observations/`. Die **Eigenschaft misst konsistent**; dass die
  Auswertungs-Regel dazu ungeschrieben bleibt, ist L-1 und kein Widerspruch.
- **M-3 behoben.** Der Absatz trägt gemessen **vier** Klassen-Klammern, ausgelegt wird genau eine,
  und die Singularisierung ist vollständig: Titel (`:1`), Abschnittsüberschrift (`:153`),
  Entscheidungssatz (`:250–253`), Festlegung 1 (`:255–258`) und die Index-Zeile in
  [`docs/plan/adr/README.md`](../plan/adr/README.md). Der einzige verbliebene Plural steht in der
  Geschichte-Zeile und **zitiert** die abgelöste Formulierung — richtig so.
- **M-4 behoben.** Die Geschichte-Zeile nennt keine Zahl mehr über den fremden Risiko-Stand; die
  zwei benannten Fragen sind am Plan belegt (§4 nennt neben dem WIP-Limit die
  Change-Request-Frage, §6 führt den Register-Ort mit dem verbatim zitierten *„Entscheidung des
  Architect, kein Code-Zug"*). Was von M-4 bleibt, ist L-2.
- **M-5 behoben.** Die Lifecycle-Zahl ist entzweideutigt und in beiden Lesarten mit Kommando
  belegt (**4** Ebenen im Regelwerk, **3** `.gitkeep` im Emitter — beide in diesem Lauf gefahren);
  der Register-Zähler steht mit Stand `2026-09-06`, Ableitungs-Kommando und *kein Erwartungswert*
  nach [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 2; das Kommando liefert in diesem Lauf weiterhin **2**.
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  ist in `Bezug` und Index-Zeile ergänzt.

**Die zusätzlich beauftragten Prüfungen:**

- **Die neuen `LH-FA-02`-Nennungen brechen
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  nicht.** Die Datei trägt jetzt **17** Vorkommen gegen vorher **12**, davon **12** als Link gegen
  vorher **9**; die fünf unverlinkten sind vier Kommando-/Zitat-Zeilen in Codeblöcken und die
  `# `-Überschrift. Kein `d-check:ignore`-Marker ist gesetzt
  (`grep -c 'd-check:ignore' docs/plan/adr/0037-*.md` → **0**), und `make docs-check` ist mit
  `ids: link-policy: always` grün.
- **Der Zielkonflikt zwischen
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  und [`AGENTS.md`](../../AGENTS.md) §3.11 ist tragfähig aufgelöst.** §3.11 nennt den **Glob**
  ausdrücklich als ortsfeste und damit zulässige Pfad-Form; `docs/plan/planning/*/slice-190-*.md`
  überlebt jeden `git mv` des Lifecycle und trifft in diesem Lauf **genau eine** Datei. Das
  Kommando läuft und liefert **6**; der Wert ist als datierte Messung gekennzeichnet — er fällt
  mit der Closure von `slice-190` auf 0, was die Datierung vorwegnimmt.
- **`slice-190` hat sich seit Runde 1 nicht bewegt** — der Glob trifft dieselbe Datei, und §4 wie
  §6 sind unverändert. Selbst gemessen, nicht aus dem Commit übernommen.

**Sonstiges, geprüft ohne Befund:**

- **[`AGENTS.md`](../../AGENTS.md) §3.8 — Commit-Zuschnitt korrekt.**
  `git show --pretty=format: --name-only 1341d23` gibt **zwei** Dateien: die ADR und
  [`docs/plan/adr/README.md`](../plan/adr/README.md). Der ADR-Index gehört nach
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) dem
  Architect; die Message nennt die Rolle im Präfix.
- **§3.4 nicht verletzt.** Die Datei steht auf `Proposed`; das `Proposed`-Fenster ist genau der
  Ort, an dem [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 die
  Korrektur verlangt. Auch die Überarbeitung der **ersten** Geschichte-Zeile ist im
  `Proposed`-Fenster zulässig.
- **§3.10 gewahrt.** Der Commit setzt weder Risiko-Ausgänge noch die Trigger-Zeile von
  `slice-190`; Folgepflicht 3 sagt das ausdrücklich, und der Diff berührt keine Plan-Datei.
- **§3.11 gewahrt.** Kein Pfad in den Planning-Lifecycle — ein `grep -noE` über das Muster
  `docs/plan/planning/(open|next|in-progress|done)/` liefert über der Datei nichts; die drei
  Markdown-Links in den Planning-Baum zeigen auf `observations/…`, nach
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 5 ortsfest. Von neun `.harness/baseline/v6.0.0/…`-Vorkommen stehen acht in
  Codeblöcken; das neunte ist ein Zeiger auf eine Vorlage.
- **§3.5 — keine Gate-Lockerung**, kein Schwellwert, kein `ignore`-Eintrag, keine
  Modul-Abschaltung berührt.
- **[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) — kein Adaptions-Eintrag
  fällig.** Unverändert gegenüber Runde 1: keine der vier Festlegungen weicht von einer
  Baseline-Regel ab.
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — kein
  halluziniertes Gate.** Die Fitness-Function-Tabelle ist unverändert;
  `TestTemplates_EmittierterBestandVollstaendig` existiert
  (`internal/emit/templates_test.go:264`) und vergleicht per Mengengleichheit, `make full-smoke`
  existiert und ist korrekt als Nicht-Gate ausgewiesen, und die zwei nicht gebauten Deckungen sind
  benannt statt behauptet.
- **Ziel-Form vollständig.** Gegen
  [`NNNN-titel.template.md`](../../.harness/baseline/v6.0.0/templates/docs/plan/adr/NNNN-titel.template.md)
  geprüft; die zusätzliche Geschichte-Zeile *„Überarbeitet, weiter Proposed"* ist die im Repo
  etablierte Form (ADR-0028 führt vier davon).
- **ADR-Index deckungsgleich.** Der Titel der Index-Zeile stimmt mit der `# `-Überschrift, Status
  `Proposed`, Bezugs-Liste in derselben Reihenfolge wie der Kopf.
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain in diesem Lauf; alles über
  `make`, `git`, `grep`, `sed`, `awk`, `ls`, `find`, `cp`. Ein Versuch, die Report-Datei mit einem
  Host-Interpreter zu bearbeiten, ist vom PreToolUse-Guard geblockt worden und wurde nicht
  umgangen.
- **Nicht geprüft (fremde Rolle):** DoD-Abhakung und Plan-vs-Code-Konformität — Verifikation,
  getrennter Kontext. Ebenso **nicht** Gegenstand: die drei nicht committeten `slice-125`-Dateien
  im Arbeitsbaum.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 4 |
| INFO | 5 |

**Finding-Klassen dieses Laufs:** *Regelwerks-Aussage ohne dreiteiligen Beleg vor dem
Accept-Übergang* · *Kriterium und sein eigener Hauptfall greifen auf verschiedene Subjekte* ·
*Kriterium wird angewandt, ohne dass seine Auswertungs-Regel geschrieben steht* · *Aussage über
den Stand eines fremden Artefakts ohne Messung an ihm* · *Kriterium sagt eine Runde ab, die sein
erster Anwendungsfall doch braucht* · *Befund der Vorrunde bleibt im Proposed-Fenster liegen* ·
*Kommando misst einen weiteren Bereich als der Satz benennt* · *Beleg-Form nur zur Hälfte
angelegt* · *Abgrenzung erklärt eine Nachbar-Klasse für unberührt, deren Ist-Stand dieselbe Lesart
schon trägt* · *Zwei Halbsätze desselben Eintrags geben verschiedene Auskunft über denselben
Posten* · *Bezugsliste deckt die entschiedene Frage nicht*

**Wiederkehrendes Muster dieses Laufs, dreimal:** *das Kriterium verspricht eine Reichweite, die
sein geschriebener Text nicht hat* (M-2 Träger-Frage, L-1 Auswertungs-Regel von (a), L-3 der
zweite `done/`-Ort). Zusammen mit Runde-1-L-4, das dieselbe Klasse an
`docs/plan/carveouts/done/` traf, ist das die **dritte Wiederholung über zwei Läufe** und nach der
Kontext-Eskalation des Reviewer-Skills ein Steering-Loop-Signal. Die Vergabe eines Register-Belegs
gehört in die Closure, nicht in diesen Report.

**Was sich gegenüber Runde 1 verschoben hat:** Fünf blockierende MEDIUM sind auf zwei gefallen,
und keiner der zwei ist eine Wiederholung — M-1 ist ein bewusst liegen gelassener LOW, dessen
Quelle eine Annahme-Vorbedingung setzt, M-2 entsteht **aus** der Nacharbeit. Die Zahl der Befunde
gegen die Entscheidung selbst ist weiterhin **null**.

---

## Verdikt

**Konsistenz NICHT BESTÄTIGT — zwei blockierende MEDIUM, kein HIGH.**

**Was trägt, und es ist deutlich mehr als in Runde 1.** Alle **23** abgedruckten Kommandos
reproduzieren ohne Abweichung. Die vier inhaltlichen Korrekturen sitzen: der hinfällige
(c)-Grund ist entfernt **und** als nicht tragend benannt, der Ersatz-Grund (ii) ist verbatim gegen
Rang 1 gehalten und trägt allein; die drei Bedingungen für `harness/conventions/` stehen einzeln,
(a) in der vollen Form nach
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 und mit einem Zitat, das
im **Rumpf** der Vorlage steht statt in einem Kommentarblock; der Gegenstand der Auslegung ist
über alle vier Fundorte auf den Singular gezogen; und die Geschichte-Zeile nennt keine Zahl mehr
über fremden Stand. **Die beauftragte Kernfrage hat eine gemessene Antwort:** die (a)-Eigenschaft
misst **nicht** in zwei Richtungen verschieden — dieselbe Verzeichniskonvention führt beide
Gegenstände, und der Modus-Zusatz, der den einen ausschließt, fehlt beim anderen. Auch die zweite:
der `MR-025`/§3.11-Konflikt ist über die Glob-Form aufgelöst, die §3.11 ausdrücklich zulässt, und
der Glob trifft heute genau eine Datei.

**Was blockiert, sind zwei verschiedene Dinge.** **M-1** ist kein neuer Befund, sondern der eine
Posten der Vorrunde, dessen Quelle eine **Vorbedingung des Statuswechsels** setzt:
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) verlangt die
dreiteilige Beleg-Form, **bevor** der Status auf `Accepted` wechselt. Dass Runde 1 den Posten LOW
etikettierte, ändert daran nichts — ein Severity-Label ist keine Ausnahme von einer aktiven ADR,
und die Nacharbeit hat ihn allein wegen des Labels liegen gelassen. Der Aufwand ist ein halber
Satz. **M-2** ist **neu und aus der Nacharbeit entstanden**: die Subjekt-Grenze *Ort statt
Inhalt*, die den (c)-Grund ersetzt, schließt bei symmetrischer Anwendung Festlegung 2s eigenen
Gegenstand aus, und die Träger-Frage, die Festlegung 2 tatsächlich beantworten musste, liegt
außerhalb der drei Bedingungen — während Konsequenz 2 zusagt, der nächste Ort brauche nur diese
drei. Das Ergebnis der Datei ist davon nicht betroffen; ihr Kriterium ist es.

**Warum das vor der Annahme zählt und nicht danach.** Beides sind Sätze, keine Entscheidungen. Ab
`Accepted` sperrt [`AGENTS.md`](../../AGENTS.md) §3.4 jede davon, und der Preis steigt von einer
Zeile auf eine Folge-ADR mit `Supersedes` — dieselbe Kosten-Asymmetrie, mit der
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) ihren
Accept-Übergang begründet.

**Der Baseline-Trigger feuert mit diesem Verdikt nicht.** *„ADR-Review-Runde abgeschlossen →
bindend"* (Baseline `v6.0.0`, `grundlagen-bootstrap.md` §Vier Trigger-Klassen, Zeile der
Acceptance-Trigger-Klasse) setzt eine abgeschlossene Runde voraus; diese Runde schließt mit zwei
blockierenden Befunden, einer davon eine ausdrückliche Vorbedingung des Übergangs.
**Über den `Accepted`-Übergang entscheidet dieser Report nicht** — das ist Architect-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.8); er stellt fest, dass die Bedingung dafür heute nicht
vorliegt.

**Übergabe.** Die Findings gehen an den **Architect** — er hält die ADR
([`AGENTS.md`](../../AGENTS.md) §3.8), und dieser Report hat kein Artefakt außer sich selbst
angefasst. Die Finding-Klassen gehen zusätzlich in die Slice-Closure §7 und von dort in den
Zähler; die Zuordnung zu einer `BEO-ALL/<slug>` fällt beim Schreiben der Closure, nicht hier
([`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md)).

Dieser Report ist ein **Lauf-Beleg** und ersetzt keine Verifikation — DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
