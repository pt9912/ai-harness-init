# Review — slice-185: Der Adaptions-Durchgang gegen `v6.0.0`

## Kopf-Metadaten

- **Rolle:** Reviewer (Modul 8/10), frischer Kontext, kein Selbst-Review.
  Skill: [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) `1.7.0`.
- **Datum:** 2026-09-05
- **Gegenstand:** [slice-185](../plan/planning/done/slice-185-adaptions-durchgang-gegen-v600.md)
  — noch **nicht** geschlossen (`in-progress/`).
- **Commit-Range:** `ec0d820..5d0c868` (drei Commits, ermittelt über
  `git log --oneline --grep 'slice-185'`):
  - `ec0d820` — zwei Zustandsfelder in [`harness/conventions.md`](../../harness/conventions.md)
  - `8b2ce37` — §9 Durchgangs-Protokoll, DoD, §6-Risiko-Ausgänge, §7 Closure-Notiz,
    zwei Register-Belege
  - `5d0c868` — Bijektions-Prüfung in §9 §Bilanz
- **Berührte `LH-*`:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  (der Pin, gegen den die Einträge messen). [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  mittelbar über den Gate-Lauf.
- **Referenzierte ADRs (Status selbst gemessen, `grep -m1 '^\*\*Status:\*\*'`):**
  [ADR-0014](../plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) `Accepted` ·
  [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) `Accepted` ·
  [ADR-0017](../plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) `Accepted` ·
  [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) `Accepted` ·
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) `Accepted` ·
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) `Accepted` ·
  [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) `Accepted` ·
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) **`Proposed`**
  (siehe LOW-1). Keine superseded ADR referenziert.
- **Hard Rules geprüft:** [`AGENTS.md`](../../AGENTS.md) §3.1, §3.3, §3.4, §3.5, §3.7, §3.8, §3.9.
- **Vorherige Findings am gleichen Modul:**
  [`2026-09-05-slice-178-nachtraeglich-review.md`](2026-09-05-slice-178-nachtraeglich-review.md)
  (MEDIUM-4 *Rollenwechsel ohne Übergabe-Artefakt*, INFO-2 *Pflicht mit unangenommener Quelle*) ·
  [`2026-09-05-slice-182-baum-tausch-v600-review.md`](2026-09-05-slice-182-baum-tausch-v600-review.md).
  Beide Klassen treten hier erneut auf (MEDIUM-3, LOW-1).
- **Selbst gefahrene Sensoren:** `make gates` → **EXIT 0**;
  `d-check: 800 Datei(en) geprüft, 0 Befund(e)`.

**Was dieser Report nicht ist:** kein Verifier. Die DoD-Abhakung und das
Plan-vs-Code-Urteil prüft die Verifikation in getrenntem Kontext.

---

## Vorbemerkung — was ich unabhängig nachgemessen habe

Die Kernbehauptung des Slice („47× *bleibt gültig*, 0× in den anderen vier Kategorien") ist
**nicht** durch Nachfahren der Plan-eigenen `grep`s geprüft worden — das erbte den Defekt, den ein
Instrument hätte. Gefahren wurden stattdessen:

```sh
# 1 — Bezugsmenge und Bijektion (Plan §Bilanz, verbatim nachgefahren)
ls harness/conventions/MR-*.md | wc -l                                   # 47
ls harness/conventions/done/*.md | wc -l                                 #  4
diff <(ls harness/conventions/MR-*.md | xargs -n1 basename | cut -d- -f1-2 | sort) \
     <(grep -oE '^\| \[MR-[0-9]{3}\]\([^)]*\) \| (bleibt gültig|gegenstandslos|teilweise überholt|Bezug entfallen|widerspricht)' \
         docs/plan/planning/done/slice-185-adaptions-durchgang-gegen-v600.md \
       | grep -oE 'MR-[0-9]{3}' | sort -u)                               # leer, Exit 0
# 2 — Ausgangs-Zeilen gezählt und auf Dopplung geprüft
… | grep -oE 'MR-[0-9]{3}' | sort | uniq -c | awk '$1>1'                 # leer (47 Zeilen, keine doppelt)
# 3 — Änderungs-Menge des Sprungs (Plan §Methode, verbatim nachgefahren)
#     14 Dateien mit Netto-Delta, davon 7 in regelwerk/; 99 hinzugefügte Regel-Zeilen; 26 Regelwerks-Dateien
# 4 — Delta-/Volltext-Schnitt gegen die Tabellen des Plans
sort -u <(…19-Treffer…) <(…7-Treffer…)  vs.  Kennungen der Delta-Tabelle    # identisch, 20
```

Dazu: **alle 99 hinzugefügten Zeilen selbst gelesen** (je Datei ausgezählt: `grundlagen-traceability.md` 38 ·
`modul-06-roadmap.md` 26 · `modul-05-planning-harness.md` 10 · `grundlagen-harness-dateien.md` 8 ·
`modul-10-review-harness.md` 5 · `regelwerk/README.md` 3 · `slice.template.md` 2 · sechs Ein-Zeiler ·
`grundlagen-begriffe.md` 1 = 99), die neue Vorlage `observation.template.md` gelesen,
§`harness/conventions.md` als Konventionsspeicher und §Das vollständige Artefakt-Set am Zielstand
**vollständig** gelesen, 18 der zitierten Mess-Kommandos unabhängig gefahren (alle reproduziert,
inkl. der acht Zeilennummern-Angaben), und geprüft, dass **jeder** in den 47 Einträgen genannte
Baseline-Pfad am Zielstand existiert.

**Ergebnis dieser Gegenprobe: „47× *bleibt gültig*" trägt.** Kein Eintrag ist am Zielstand
gegenstandslos, teilweise überholt, ohne Bezug oder im Widerspruch. Die Befunde unten betreffen die
**Beleg-Form** des Durchgangs und den **Rollen-Zuschnitt**, nicht sein Verdikt.

---

## Findings

### MEDIUM-1 — Die „viermal"-Zahl in §Methode unterschreitet die Fundmenge der eigenen Tabellen, und sie steht schon eingefroren im Register

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025) Setzung 1/2 (eine Zahl steht neben
  dem Kommando, das sie liefert; eine Handzählung sagt, dass sie eine ist) ·
  Baseline-Regelwerk [`modul-06-roadmap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md)
  §Das Beobachtungs-Register (`evidence/<vorgangs-id>.md` — *unveränderlich ab Merge*)
- **pfad:** [`slice-185-adaptions-durchgang-gegen-v600.md:390–394`](../plan/planning/done/slice-185-adaptions-durchgang-gegen-v600.md)
  und [`observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/evidence/slice-185.md:2`](../plan/planning/observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/evidence/slice-185.md)
- **befund:** §Methode sagt *„in diesem Durchgang **viermal** belegt … Sie liegen in
  `modul-14-docker-harness.md` (zwei), `grundlagen-source-precedence.md` und
  `grundlagen-referenz-richtung.md`; die Zeilennummern stehen in den Zeilen unten."* Die Zeilen
  unten melden einen Zeilenumbruch am Zitat für **acht** Einträge in **sechs** Dateien —
  [`MR-007`](../../harness/conventions.md#mr-007) (`modul-02-harness-bootstrap.md`),
  [`MR-009`](../../harness/conventions.md#mr-009),
  [`MR-048`](../../harness/conventions.md#mr-048),
  [`MR-049`](../../harness/conventions.md#mr-049) (alle drei `modul-14-docker-harness.md`),
  [`MR-014`](../../harness/conventions.md#mr-014) (`grundlagen-durchsetzungsschicht.md`),
  [`MR-015`](../../harness/conventions.md#mr-015) (`grundlagen-source-precedence.md`),
  [`MR-019`](../../harness/conventions.md#mr-019) (`grundlagen-referenz-richtung.md`),
  [`MR-032`](../../harness/conventions.md#mr-032) (`grundlagen-harness-dateien.md`, Zeile 243).
  Für alle acht gibt `grep -c -F '<volles Zitat>'` am Zielstand eine **0**, und alle acht stehen
  wörtlich da. Gemessen:

  ```sh
  B=.harness/baseline/v6.0.0
  grep -c -F 'Update = bewusster Commit, der nur die Digest-Zeile anhebt'      $B/regelwerk/modul-14-docker-harness.md          # 0
  grep -c -F 'Base-Image per Digest pinnen (`FROM …@sha256:…`), nicht per Tag' $B/regelwerk/modul-14-docker-harness.md          # 0
  grep -c -F 'wer das nicht tut, hat die Rezept-Form und benennt sie besser auch so' $B/regelwerk/modul-14-docker-harness.md    # 0
  grep -c -F 'Die Quellen wandern beim Build ins Image, die Ergebnisse kommen über `stdout` heraus.' $B/regelwerk/modul-14-docker-harness.md # 0
  grep -c -F 'Weil der Vendoring-Pfad `<tag>`-gescopt ist, liegen alte und neue Form nebeneinander' $B/regelwerk/modul-02-harness-bootstrap.md # 0
  grep -c -F 'Der Zustand ist die Verzeichnis-Position, kein Status-Feld.'     $B/regelwerk/grundlagen-harness-dateien.md       # 0
  grep -c -F 'Der Inhalts-Nachweis hat eine Lücke bei frischem Klon bzw. gelöschtem State mit cleanem Tree (kein Nachweis prüfbar) — dort ist **CI das Netz**.' $B/regelwerk/grundlagen-durchsetzungsschicht.md # 0
  grep -c    'Der Träger ist dann der'                                        $B/regelwerk/grundlagen-source-precedence.md      # 0
  ```

  Dieselbe „vier" steht in der Beleg-Datei des Registers, die den Zähler von
  [`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../plan/planning/observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
  auf 2× hebt. Sie ist mit `8b2ce37` bereits auf `origin/main` und damit nach Modul 6
  unveränderlich; die Klasse, die sie beschreibt, ist im selben Zug halb so groß beziffert, wie der
  Durchgang sie belegt. Keine der Zahlen trägt ein Kommando oder die Handzählungs-Ansage, die
  §Bilanz an anderer Stelle ausdrücklich setzt.
- **verifizierbar:** **nein** — kein Modul aus `modules:` der [`.d-check.yml`](../../.d-check.yml)
  hält eine Prosa-Zahl gegen ihre Fundmenge, und `make mutate` kennt keine Fehlschlag-Form dafür.
  Ablesbar an den acht Kommandos oben plus
  `grep -oE 'MR-[0-9]{3}\]\([^)]*\) \| bleibt gültig \| [^|]*' <plan> | grep -E 'bricht nach|bricht zwischen|umgebrochen nach'`.
- **klasse:** *Extensionale Zahl unterschreitet die eigene Fundmenge*

### MEDIUM-2 — Die sechs Gegenstände partitionieren die 99 Zeilen nicht vollständig; die Schluss-Aussage läuft nur über die sechs

- **kategorie:** MEDIUM
- **quelle:** DoD-Punkt 2 des Slice (*„Die Volltext-Hälfte ist gelaufen und als solche
  ausgewiesen"*) · Baseline-Regelwerk
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md)
  §Freshness-Audit der vendored Baseline (je Eintrag ein Ausgang mit eigenem Beleg) ·
  Beobachtung [`delta-durchgang-uebersieht-deckung`](../plan/planning/observations/BEO-ALL/delta-durchgang-uebersieht-deckung/observation.md)
- **pfad:** [`slice-185-adaptions-durchgang-gegen-v600.md:369–388`](../plan/planning/done/slice-185-adaptions-durchgang-gegen-v600.md)
- **befund:** Der Plan sagt *„Die 99 Zeilen und die eine neue Datei sind gelesen und tragen **sechs**
  Gegenstände"* und schließt daraus *„**Keiner der sechs** berührt eine der 47 Adaptionen"*. Eine der
  99 Zeilen trägt keinen der sechs: der Aufzählungspunkt *„**Was offen bleibt:** Die
  **Carveout-Frist** misst in Wellen … Einen wellenlosen Ersatz-Träger gibt es dafür nicht; das
  bleibt eine benannte Lücke"* in
  [`modul-06-roadmap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md)
  §Wann Arbeit eine Welle braucht. Er ist weder Register (1), noch Kürzel-Spalte (2), noch
  Archivierung (3) — Gegenstand 3 ist im Plan als *„Die Archivierung der Zeitdokumente hat im
  wellenlosen Betrieb einen Träger"* definiert —, noch Fluss-Diagramm (4), Release-URL (5) oder
  Stand-Zeile (6). Damit läuft die tragende Schluss-Aussage über eine Menge, die die ausgezählte
  nicht ausschöpft; das *Auszählen* ist genau die Eigenschaft, mit der der Slice die Volltext-Hälfte
  als „geschlossen statt behauptet" ausweist (§7, Steering-Loop-Eintrag). Gemessen — die 26
  `modul-06`-Zeilen zerfallen in 1 (Carveout-Frist) + 2 (Archivierung) + 23 (Register):

  ```sh
  ALT=$(mktemp -d); git archive d75cd8c^ .harness/baseline/v5.18.0 | tar -x -C "$ALT"
  diff "$ALT/.harness/baseline/v5.18.0/regelwerk/modul-06-roadmap.md" \
       .harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md \
    | grep '^>' | grep -v '<!-- Quelle:' | grep -vE '^> *$'          # 26 Zeilen, erste = Carveout-Frist
  ```

  **Folgenlos in diesem Lauf, und das ist gemessen, nicht angenommen:** kein Eintrag des Blocks hat
  die Carveout-Frist zum Gegenstand (`grep -lin 'carveout' harness/conventions/MR-*.md` →
  [`MR-008`](../../harness/conventions.md#mr-008), [`MR-029`](../../harness/conventions.md#mr-029),
  [`MR-040`](../../harness/conventions.md#mr-040), [`MR-041`](../../harness/conventions.md#mr-041),
  keiner davon über eine Frist), und die neue Zeile stellt ausdrücklich *keine* Pflicht auf.
  Der Befund ist die Lücke im Argument, nicht ein falscher Ausgang.
- **verifizierbar:** **nein** — dieselbe Begründung wie bei MEDIUM-1; ablesbar am `diff`-Kommando
  oben gegen die Gegenstands-Tabelle.
- **klasse:** *Partition der ausgezählten Menge ist unvollständig*

### MEDIUM-3 — Die Closure-Schritte laufen im Architect-Commit, vor Review und Verifikation

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk
  [`modul-08-agentenrollen.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md)
  §Rollen-Sequenz für einen Slice (`I→R→Vf→P`, *„Closure in `done/` + Lerneintrag"* beim Planner)
  und §Rollen-Regeln (*„kein Rollenwechsel ohne Übergabe-Artefakt"*) ·
  [`.claude/commands/implement-slice.md`](../../.claude/commands/implement-slice.md)
  §Closure — Planner-Rolle, Schritt 23 (*„Erst wenn der Review konform **und** die Verifikation die
  DoD bestätigt hat, schließt der **Planner**"*) und Schritt 24 (*„Das Beobachtungs-Register
  fortschreiben … der **Schreib**-Schritt, und er hängt an der Closure, nicht an der
  Implementation"*)
- **pfad:** Commit `8b2ce37` — `docs/plan/planning/in-progress/slice-185-…md` (§6 Risiko-Ausgänge,
  §7 Closure-Notiz, DoD-Häkchen) und zwei `observations/BEO-ALL/*/evidence/slice-185.md`
- **befund:** Derselbe Architect-Lauf, der das Durchgangs-Protokoll §9 schrieb — sein eigenes
  Werkstück —, hat im selben Commit die Closure-Notiz §7, die drei Risiko-Ausgänge §6 und die zwei
  Register-Belege geschrieben. Beide sind nach Modul 8 und nach dem repo-eigenen Anweisungssatz
  Planner-Arbeit **nach** Review und Verifikation; zwischen dem schreibenden und dem schließenden
  Kontext liegt kein Übergabe-Artefakt. Das Feld `Verantwortlich: Architect` im Slice-Kopf trägt das
  nicht: Es benennt nach
  [`modul-05-planning-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-05-planning-harness.md)
  §Lifecycle als State Machine den Rolleninhaber der **Implementer**-Rolle, nicht den der Closure.
  Das konkrete Versagen liegt vor: Die Register-Beleg-Datei ist nach Modul 6 *unveränderlich ab
  Merge* und steht bereits auf `origin/main` — der Befund MEDIUM-1 über ihren Inhalt kann sie nicht
  mehr korrigieren, weil sie geschrieben wurde, bevor ein zweiter Kontext sie lesen konnte. Genau
  dafür existiert die Trennung.
- **verifizierbar:** **nein** — kein Gate liest Commits ([`AGENTS.md`](../../AGENTS.md) §3.8 stellt
  das für sich selbst fest). Ablesbar an `git show --stat 8b2ce37` und
  `git log --oneline origin/main..HEAD`.
- **klasse:** *Rollenwechsel ohne Übergabe-Artefakt* — **zweite** Instanz nach
  [`2026-09-05-slice-178-nachtraeglich-review.md`](2026-09-05-slice-178-nachtraeglich-review.md)
  MEDIUM-4. Die Register-Klasse
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  steht bei **1×** (`ls …/evidence | wc -l`); der slice-178-Fund ist dort nie gebucht worden.
- **Abgrenzung, damit die Quelle stimmt:** [`AGENTS.md`](../../AGENTS.md) §3.8 ist **nicht**
  verletzt — sie bindet Commits an Hard Rules und Adaptions-Block, und der eine Commit, der den
  Block berührt (`ec0d820`), ist sauber isoliert (siehe Negativbefunde).
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) sagt über andere
  Norm-Artefakte ausdrücklich nichts. Träger dieses Befundes sind Modul 8 und der repo-eigene
  Anweisungssatz.

### LOW-1 — Die §Baseline-Zelle spricht einer `Proposed`-ADR Bindungskraft zu, in dem Absatz, den `ec0d820` bearbeitet hat

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4 (eine ADR bindet ab `Accepted`) · §3.7,
  Zustandsfeld-Hälfte (*„Gebunden ist die Zelle, die geschrieben oder geändert wird"*)
- **pfad:** [`harness/conventions.md:28–36`](../../harness/conventions.md) (§Baseline)
- **befund:** `ec0d820` zieht in derselben Zelle den Status von
  [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) von `Proposed` auf
  `Accepted` nach — und lässt zwei Klauseln weiter stehen: *„Die Form dieser Zeile … und der Ort
  einer Zielstand-Setzung **stehen in** [ADR-0031] Festlegung 2"* sowie *„Festlegung 1 von
  [ADR-0031] **bindet** allein den Sprung auf `v5.18.0`"*. Die Zeichenkette `Festlegung 1 von` liegt
  auf einer der vom Commit geänderten Zeilen.
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) steht auf
  `Proposed` (`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0031-*.md`; ADR-Index Zeile 38 ebenso) und
  ist von keiner ADR superseded. Damit trägt die Zelle, die der Commit als „Zustand, keine Chronik"
  ausweist, weiterhin eine Bindungs-Aussage über ein nicht angenommenes Dokument.
- **verifizierbar:** **nein**; ablesbar an
  `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0031-*.md` → `Proposed` und `git show ec0d820`.
- **klasse:** *Bindungs-Aussage über eine nicht angenommene ADR* — dieselbe wie
  [`2026-09-05-slice-178-nachtraeglich-review.md`](2026-09-05-slice-178-nachtraeglich-review.md)
  INFO-2 (*Pflicht mit unangenommener Quelle*), hier eine Stufe höher, weil die Zelle in diesem
  Slice angefasst wurde und der §3.7-Cutoff sie damit bindet.

### LOW-2 — Die Bijektion in §Bilanz verdrahtet den `in-progress/`-Pfad und wird beim Closure-Move stumm falsch

- **kategorie:** LOW
- **quelle:** Maintainability · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  (ein Beleg-Kommando muss nach dem Vorgang noch dasselbe messen)
- **pfad:** [`slice-185-adaptions-durchgang-gegen-v600.md:509–517`](../plan/planning/done/slice-185-adaptions-durchgang-gegen-v600.md)
- **befund:** Der zweite Operand nennt `docs/plan/planning/in-progress/slice-185-….md` als festen
  Pfad. Nach dem `git mv` nach `done/` liefert das `grep` dort nichts, der `diff` meldet 47
  fehlende Kennungen — also *einen Defekt*, wo keiner ist, statt leer zu bleiben. Der Plan sagt es
  im Folgesatz dazu (*„nach dem `git mv` nach `done/` ist er dort nachzuziehen"*), was den Befund
  auf LOW hält; der Nachzug hängt an einer Handlung, die kein Sensor einfordert, und
  `make slice-mv` zieht Verweise nach, keine Kommando-Argumente.
- **verifizierbar:** **ja** — nach dem Closure-Move das Kommando erneut fahren: es gibt dann 47
  `<`-Zeilen statt einer leeren Ausgabe.
- **klasse:** *Beleg-Kommando mit hart verdrahteter Lifecycle-Adresse*

### INFO-1 — Die Auszähl-Schleife überspringt Dateien, die nur in einem der beiden Bäume liegen

- **kategorie:** INFO
- **quelle:** §9 §Methode, zweite Hälfte
- **pfad:** [`slice-185-adaptions-durchgang-gegen-v600.md:347–361`](../plan/planning/done/slice-185-adaptions-durchgang-gegen-v600.md)
- **befund:** Beide Schleifen tragen `[ -f "$B/$f" ] || continue`. Zwischen den Tags ist genau eine
  Datei entfallen und eine entstanden:

  ```sh
  comm -13 <(cd "$ALT/.harness/baseline/v5.18.0" && find . -name '*.md' | sort) \
           <(cd .harness/baseline/v6.0.0        && find . -name '*.md' | sort)   # ./templates/docs/plan/planning/observation.template.md
  comm -23 …                                                                     # ./templates/docs/plan/planning/observations.template.md
  ```

  Die **neue** ist in der Prosa gesondert genannt (*„plus eine neue Vorlage"*) und gelesen. Die
  **entfallene** ist es nicht — dabei ist eine entfallene Baseline-Datei genau der Kandidat für den
  Ausgang *Bezug entfallen*, und die zweite Schleife würde einen Eintrag, dessen Zieldatei
  verschwunden ist, als „netto 0 geänderte Zeilen" führen statt als fehlend. Folgenlos gemessen:
  `git grep -n 'observations\.template\.md' -- 'harness/conventions/'` findet nichts, und jeder in
  den 47 Einträgen genannte Baseline-Pfad existiert am Zielstand (einzige Ausnahme: INFO-3).
- **verifizierbar:** **nein**; ablesbar an den zwei `comm`-Kommandos.
- **klasse:** *Mess-Schleife blendet die asymmetrische Menge aus*

### INFO-2 — Die Bijektion kollabiert Doppelzeilen über `sort -u`

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** [`slice-185-adaptions-durchgang-gegen-v600.md:509–517`](../plan/planning/done/slice-185-adaptions-durchgang-gegen-v600.md)
- **befund:** Der zweite Operand endet auf `sort -u`. Zwei Ausgangs-Zeilen für **dieselbe** Kennung
  — etwa mit zwei verschiedenen Ausgängen — blieben damit unsichtbar; die Prüfung deckt „jeder
  Eintrag hat mindestens eine Zeile", nicht „genau eine". Heute ohne Gegenstand:
  `… | sort | uniq -c | awk '$1>1'` ist leer bei 47 Zeilen.
- **verifizierbar:** **ja** — eine Zeile im Plan verdoppeln; die Bijektion bleibt leer.
- **klasse:** *Deckungs-Prüfung misst Existenz, nicht Eindeutigkeit*

### INFO-3 — Zwei Einträge zitieren eine Baseline-Datei, die es am Zielstand nicht gibt

- **kategorie:** INFO
- **quelle:** [`MR-040`](../../harness/conventions.md#mr-040) (drei Ausgänge für eine
  Präsens-Aussage über den vendored Baum)
- **pfad:** [`MR-015`](../../harness/conventions.md#mr-015) Zeile 11 und
  [`MR-025`](../../harness/conventions.md#mr-025) Zeile 105 —
  `.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md`
- **befund:** Von allen Baseline-Pfaden im Eintrags-Bestand zeigt genau dieser eine am Zielstand ins
  Leere; die Datei existiert weder unter `v6.0.0` noch unter `v5.18.0`. Der Slice ordnet die Klasse
  ausdrücklich [slice-091](../plan/planning/open/slice-091-vendored-baum-ohne-anspruch.md) und
  [slice-092](../plan/planning/open/slice-092-traeger-inventur.md) zu (§Was dieser Durchgang
  **nicht** trägt) — kein Befund gegen diesen Slice, aber der Posten hat, anders als die 87
  Tag-Nennungen daneben, kein lebendes Ziel mehr und ist damit von anderer Härte.
  Gemessen:
  `grep -ohE '(regelwerk|templates)/[A-Za-z0-9._/-]+\.(md|yml|json)' harness/conventions/MR-*.md | sort -u | while read p; do [ -e ".harness/baseline/v6.0.0/$p" ] || echo "FEHLT: $p"; done`
  → eine Zeile.
- **verifizierbar:** **nein**; ablesbar am Kommando oben.
- **klasse:** *Zitierter Pfad ohne Ziel am adoptierten Stand*

---

## Negativbefunde (geprüft, ohne Befund)

- **„Alle 47 *bleibt gültig*" als Sachurteil** — geprüft über den **neuen Volltext**, nicht über das
  Delta: alle 99 hinzugefügten Regel-Zeilen gelesen, die neue Vorlage gelesen,
  §`harness/conventions.md` als Konventionsspeicher und §Das vollständige Artefakt-Set am Zielstand
  vollständig gelesen, dazu die umgeschriebene §Das Beobachtungs-Register. **Kein Befund:** Kein
  Eintrag hat das Beobachtungs-Register, seine Kennungsform oder die Archivierung zum Gegenstand;
  die einzige Baseline-Verschärfung des Sprungs (Kürzel-Spalte nicht mehr bedingt) ist in
  [`harness/conventions.md`](../../harness/conventions.md) §Modus-Deklaration bereits eingelöst
  (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → 45, Sub-Area-Zeile über allen 45
  identisch).
- **Stichprobe von 9 Einträgen, unabhängig gegen `v6.0.0` gehalten** —
  [`MR-000`](../../harness/conventions.md#mr-000), [`MR-002`](../../harness/conventions.md#mr-002),
  [`MR-009`](../../harness/conventions.md#mr-009), [`MR-020`](../../harness/conventions.md#mr-020),
  [`MR-029`](../../harness/conventions.md#mr-029), [`MR-031`](../../harness/conventions.md#mr-031),
  [`MR-037`](../../harness/conventions.md#mr-037), [`MR-045`](../../harness/conventions.md#mr-045),
  [`MR-046`](../../harness/conventions.md#mr-046). Alle zitierten Sätze stehen wörtlich, alle
  Zähl-Ergebnisse reproduziert (u. a. `<PREFIX>-FA-<NN>` → 2, `seit slice-<NNN>` → 3,
  `Adopter` → 6 Zeilen, `implementer` → 0 Dateien, `SessionStart`/`check-lines`/`citations`/
  `structure`/`Erwartungswert` → leer, Symlinks → 4, Regelwerks-Dateien → 26). **Kein Befund.**
- **Die vier grep-blinden Zitate, unabhängig auf ihren Ausgang geprüft** — alle acht (MEDIUM-1)
  stehen wörtlich am Zielstand; *bleibt gültig* ist für jeden von ihnen die richtige Einstufung,
  *Bezug entfallen* wäre falsch gewesen. Die Zeilennummern der Rows (29, 65/72, 85, 243, 72, 290)
  sind exakt reproduziert. **Kein Befund am Ergebnis**, nur an der Zahl (MEDIUM-1).
- **Bijektion §Bilanz** — verbatim nachgefahren, Ausgabe leer bei Exit 0; 47 Ausgangs-Zeilen, keine
  doppelt; die vier aufgelösten Einträge in `conventions/done/` sind korrekt **nicht** in der
  Bezugsmenge (ihre Zweitspalte trägt keinen der fünf Ausgänge und wird vom Muster nicht getroffen).
  **Kein Befund** außer INFO-2.
- **Delta-/Volltext-Schnitt (20/27)** — beide `git grep`-Kommandos gefahren (19 und 7), Vereinigung
  20, `diff` gegen die Kennungen der Delta-Tabelle **identisch**. Die zwei Regexe nennen genau die
  14 Dateien mit Netto-Delta. Zusätzlich geprüft, ob einer der 27 eine bewegte Datei ohne
  Pfad-Nennung berührt (Suche nach `Modul 5/6/10`, `Beobachtungs-Register`, `Herkunfts-Anker`,
  Vorlagen-Namen): fünf Treffer, alle inzidentell (`Steering-Loop`, `git archive`, Release-Archiv).
  **Kein Befund.**
- **[`AGENTS.md`](../../AGENTS.md) §3.8 (Architect-Commit-Zuschnitt)** — `ec0d820` berührt
  ausschließlich [`harness/conventions.md`](../../harness/conventions.md)
  (`git show --stat`: 1 Datei, 4+/3−), nennt die Rolle in der Message und trennt den Adaptions-Block
  sauber von den Plan-Änderungen. **Kein Befund.**
- **§3.3 (Move und Rewrite getrennt)** — keiner der drei Commits enthält einen Move; die
  `slice-mv`-Commits davor sind fremde Vorgänge. **Kein Befund.**
- **§3.4 (ADRs immutabel)** — keine ADR-Datei im Diff; der Durchgang fasst nach seinem eigenen
  §1 keine an, und [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4
  dritter Punkt ist eingehalten. **Kein Befund.**
- **§3.5 (Gates nicht ohne ADR gelockert)** — [`.d-check.yml`](../../.d-check.yml) und das
  `Makefile` sind im Diff nicht enthalten; die Lockerungs-Frage ist an
  [`MR-020`](../../harness/conventions.md#mr-020) und
  [`MR-029`](../../harness/conventions.md#mr-029) einzeln beantwortet und beide Baseline-Sätze
  stehen unverändert (je `grep -c` → 1). Kein Carveout fällig, `docs/plan/carveouts/` unberührt.
  **Kein Befund.**
- **§3.9 (Docker-only)** — die Belege des Plans und dieses Reviews nutzen nur `git`, `diff`, `grep`,
  `comm`, `tar`, `mktemp`; keine Host-Toolchain, kein Paketmanager. Alle Gates über `make`.
  **Kein Befund.**
- **Folge-Slice-Paarung** — jede im Plan genannte Kennung existiert im Lifecycle:
  [slice-091](../plan/planning/open/slice-091-vendored-baum-ohne-anspruch.md),
  [slice-092](../plan/planning/open/slice-092-traeger-inventur.md),
  [slice-153](../plan/planning/open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md),
  [slice-186](../plan/planning/done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md).
  **Kein Befund.**
- **Register-Paarung (maschinelle Hälfte)** — jede in §6/§7 zitierte Beobachtung existiert als
  Verzeichnis, und **kein** Verzeichnis hat ein leeres `evidence/` (45 geprüft). Die drei genannten
  Zähler-Stände sind die Zahl der Evidence-Dateien: 2 · 13 · 1. **Kein Befund.**
- **Zahlen in `ec0d820`** — `ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **45**, und
  das Kommando steht jetzt neben der Zahl ([`MR-025`](../../harness/conventions.md#mr-025)
  Setzung 1); `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0036-*.md` → `Accepted`. Beide Zellen
  tragen Zustand, keine Chronik. **Kein Befund** (außer LOW-1 zur Nachbar-Klausel).
- **[welle-15](../plan/planning/done/welle-15-re-baseline.md) §4** führt slice-185 mit Zeiger auf
  `in-progress/`. **Kein Befund.**
- **`make gates`** — selbst gefahren, **EXIT 0**; `d-check: 800 Datei(en) geprüft, 0 Befund(e)`;
  `test` 218 bats-Fälle ok, 8 Go-Pakete ok; `span-check` grün. Deckungsgleich mit der Angabe in der
  Commit-Message von `8b2ce37`. **Kein Befund.**

---

## Kategorie-Summary

| Kategorie | Zahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 3 | Extensionale Zahl unterschreitet die eigene Fundmenge · Partition der ausgezählten Menge ist unvollständig · Rollenwechsel ohne Übergabe-Artefakt |
| LOW | 2 | Bindungs-Aussage über eine nicht angenommene ADR · Beleg-Kommando mit hart verdrahteter Lifecycle-Adresse |
| INFO | 3 | Mess-Schleife blendet die asymmetrische Menge aus · Deckungs-Prüfung misst Existenz, nicht Eindeutigkeit · Zitierter Pfad ohne Ziel am adoptierten Stand |

**Wiederkehrende Klassen für die Closure-Route** (Modul 5, dritte Quelle des Closure-Eintrags — die
Buchung ist Planner-Arbeit, nicht meine):

- *Rollenwechsel ohne Übergabe-Artefakt* →
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md),
  heute **1×**; der Fund aus dem slice-178-Review ist dort nie gebucht worden.
- *Extensionale Zahl unterschreitet die eigene Fundmenge* — Nachbarklasse zu
  [`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../plan/planning/observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md),
  aber nicht dieselbe: dort übersieht ein `grep` eine Deckung, hier unterschreitet eine Prosa-Zahl
  die Menge, die derselbe Text belegt. Ob das eine neue Kennung braucht oder unter
  [`zahl-neben-nie-gefahrenem-kommando`](../plan/planning/observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md)
  fällt, entscheidet der schreibende Lauf.

---

## Verdikt

**Blockierend — 3 MEDIUM offen.** Das **Sachurteil des Slice trägt**: „47× *bleibt gültig*, 0× in
den vier anderen Kategorien" ist unabhängig gegen den `v6.0.0`-Volltext nachgeprüft und hält; ich
habe keinen Eintrag gefunden, der am Zielstand gegenstandslos, teilweise überholt, bezugslos oder im
Widerspruch wäre. Das auffällige Ergebnis ist erklärbar und belegt, nicht übersprungen: der Sprung
schreibt ein Harness-Artefakt um, über das keine der 47 Adaptionen geschrieben ist.

Blockierend sind die drei MEDIUM, weil sie die **Beleg-Kette** treffen, auf der genau dieses Urteil
ruht:

- **MEDIUM-1** und **MEDIUM-2** sind beide Löcher in der Auszählung, mit der der Slice die
  Volltext-Hälfte als „geschlossen statt behauptet" ausweist — und diese Auszählung **ist** der
  Steering-Loop-Lerneintrag, den Modul 5 für den Übergang nach `done/` verlangt. Ein Lerneintrag,
  der eine Methode als geschlossen verkauft, deren Partition eine Zeile auslässt und deren
  Fundmenge halb so groß beziffert wird, wie sie ist, schließt den Loop nicht.
- **MEDIUM-3** ist die zweite Instanz derselben Klasse binnen eines Tages und hat hier eine
  greifbare Folge: die Register-Beleg-Datei mit der Zahl aus MEDIUM-1 ist bereits gemergt und nach
  Modul 6 unveränderlich.

Kein HIGH: keine Hard Rule verletzt, keine aktive ADR verletzt, keine superseded ADR referenziert,
kein stilles Grün in einem Gate, kein halluziniertes Gate. `make gates` ist selbst gefahren und
grün (EXIT 0, `d-check` 800/0).

**Für den Konflikt-Pfad:** MEDIUM-3 berührt einen Rollen-Zuschnitt und ist damit kein reines
Implementations-Finding. Wird ihm widersprochen, greift Modul 8 §Konflikt-Pfad (Sequenz mit
Übergabe-Artefakten, drei legitime Verdikte) — nicht die Herabstufung, weil der schreibende Lauf
anderer Meinung ist.
