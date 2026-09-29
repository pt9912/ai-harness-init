# Review: `slice-sprung-auf-v6130-wird-vollzogen`

**Vorgang:** [`slice-sprung-auf-v6130-wird-vollzogen`](../plan/planning/in-progress/slice-sprung-auf-v6130-wird-vollzogen.md) ·
**Diff:** `b8597a22^..2c54e5a8` (6 Commits, 155 Dateien, +951/−471) ·
**Regierende Fassung des Sprungs:** [`ADR-0072`](../plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md)
(`Accepted`) · **Reviewer:** unabhängiger Lauf (Modul 10)

Geprüft gegen Plan (§1 Ziel/Abgrenzung, §3 Plan, §4 Trigger), ADR-0072,
[`ADR-0056`](../plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) als Form-Vorbild,
[`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md),
[`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache),
[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen),
[`MR-063`](../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen),
[`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
und [`AGENTS.md`](../../AGENTS.md) §3. DoD-Abhakung ist nicht Gegenstand (Verifier).

## Findings

### 1. HIGH — `Stand:`-Feld der §Baseline bleibt auf `v6.9.0`

- `kategorie`: HIGH (Merge-Blocker)
- `quelle`: Plan §1 Ziel („Buchung des Vollzags in §Baseline"), Liefer-Punkt 1.5 (Inline-Nennung
  des abgelösten Tags = Adresse), [`AGENTS.md`](../../AGENTS.md) §3.7 (Zustandsfeld),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
- `pfad`: `harness/conventions.md:11`
- `befund`: Das Zustandsfeld `**Stand:** `v6.9.0`` blieb stehen, während der Archite-Commit
  `2c54e5a8` die vier umliegenden Adress-Zeilen derselben Sektion (Baum-Pfad, README-Kommando,
  URL, baseline-verify-Beleg) auf `v6.13.0` zog. Die Sektion widerspricht sich in sich: Der
  adoptierte Stand ist `v6.13.0`, das Feld sagt `v6.9.0`. Der Plan weist die Buchung dem
  Archite-Commit ausdrücklich zu; ausgelassen ist nicht Bestand geblieben (der §3.7-Cutoff
  schützt nicht), sondern die aufgetragene Änderung unterblieben. Die Datei selbst nennt das
  Feld „den Bezugspunkt, den ein Versions-Sensor … gegen jeden Baseline-Pin im Repo hält" —
  der liest hier die falsche Version.
- `verifizierbar`: ja — `grep -n 'Stand:' harness/conventions.md` gegen
  `grep -n '^BASELINE_TAG' Makefile`; `make baseline-verify` (meldet `v6.13.0 OK`).
- `klasse`: „Architect-Buchung zieht die umliegenden Adressen, nicht das Zustandsfeld, das sie
  setzen sollte"

### 2. HIGH — migration.md: Sprung-Zeile fehlt, Präsens-Aussage über den vendored Baum falsch

- `kategorie`: HIGH (Merge-Blocker)
- `quelle`: Plan §2 DoD-Form („harness/migration.md trägt die Sprung-Zeile … Architect-Commit"),
  [`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
- `pfad`: `harness/migration.md:50` (Sprung-Tabelle) und `harness/migration.md:58` (Präsens-Absatz)
- `befund`: Die Sprung-Tabelle endet mit `v6.8.0` → `v6.9.0 (vollzogen)`; die Zeile für
  `v6.9.0` → `v6.13.0` (Ziel-Fassung `v6.13.0`,
  [`ADR-0072`](../plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md)) fehlt. Der
  Begleitabsatz behauptet im Präsens „Der aktuell vendored Stand ist `v6.9.0`" — der gemessene
  Baum ist `v6.13.0`; das eigene Kommando (`ls -1 .harness/baseline/`) steht daneben und widerlegt
  die Aussage. Beides: dieselbe Unterlassung der Architect-Buchung wie in Finding 1.
- `verifizierbar`: ja — `grep -nE '^\| .?v6' harness/migration.md` und
  `ls -1 .harness/baseline/`.
- `klasse`: „Präsens-Aussage über den vendored Baum überlebt den Tausch ohne Ausgang"

### 3. MEDIUM — Architect-Schritt (Register-Zuordnung) steht aus; drei Instanz-Gruppen `ausstehend`

- `kategorie`: MEDIUM (Closure-Blocker)
- `quelle`: Plan §3 (Register-Zuordnung, eigener Architect-Commit), Plan §4 Rückführung (b),
  [`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2
- `pfad`: `docs/migrations/v6.13.0.md:50`, `:56`, `:58`, `:63`
- `befund`: Der einzige Architect-Commit im Diff (`2c54e5a8`) zieht nur Adressen; die
  Register-Zuordnung, die §3 des Plans „nach dem Tausch-Commit und vor Liefer-Punkt 3.3"
  anordnet, ist nicht ablesbar. Der migrations-Report hält vier Instanz-Gruppen unter
  „ausstehend — Architect-Schritt" offen ([`AGENTS.md`](../../AGENTS.md) samt §5-Form,
  `spec/lastenheft.md` als Rang-1-Quelle, `harness/conventions.md` (ID-Schema-Erweiterung),
  `harness/sensors/*.md`) und deklariert die Rückführung (b)-Lage selbst. Die Plan-Reihenfolge
  (Zuordnung vor LP 3.3) wurde gebrochen, der Report hält die Lücke aber ausdrücklich statt
  still offen (Ist-Maßstab statt Prozedur-Schritt). Der Slice darf nicht schließen, bevor die
  Architect-Entscheidung (Umschrift vs. Folge-Slice/Carveout) vorliegt.
- `verifizierbar`: ja — die „ausstehend"-Zeilen im migrations-Report; kein Commit im Diff
  berührt die vier Instanz-Gruppen inhaltlich.
- `klasse`: „Architect-Übergabe bleibt über die Review hinaus offen"

### 4. MEDIUM — reviewer.md-Nachzug im Architect-Commit statt bei der ausführenden Rolle

- `kategorie`: MEDIUM
- `quelle`: Plan §2 Liefer-Punkt 1 (Nachzugs-Absatz: `.harness/skills/reviewer.md` „bei der
  Rolle, die sie ausführt" — [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)),
  [`AGENTS.md`](../../AGENTS.md) §3.8 (Commit-Zuschnitt nach schreibender Rolle)
- `pfad`: Commit `2c54e5a8` (`.harness/skills/reviewer.md`, 2 Links)
- `befund`: Der Archite-Commit trägt `harness/skills/reviewer.md` mit, obwohl der Plan diesen
  Nachzug der ausführenden Rolle zuordnet; ein Commit der ausführenden Rolle existiert im Diff
  nicht. Der Nachzug selbst ist korrekt (gate-sichtbare Links), die Rollen-Zuordnung im
  Commit-Zuschnitt weicht vom Plan ab — die Rollen-Ablesbarkeit in `git log` ist hier die
  Grundlage von §3.8/§3.10.
- `verifizierbar`: nein — kein Gate liest den Rollen-Zuschnitt von Commits (§3.8 benennt die
  Lücke selbst).
- `klasse`: „Nachzug einer Rollen-Datei wird vom Archite-Lauf mitgezogen"

### 5. INFO — Adress-Nachzug in ADR-0061 (Proposed) im Implementer-Commit

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.8, Modul 8 („Architect schreibt ADRs")
- `pfad`: Commit `82329947`, `docs/plan/adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md:51`, `:180`
- `befund`: Die zwei Baseline-Links in ADR-0061 (Status `Proposed`, §3.4 greift nicht) wurden im
  Implementer-Commit nachgezogen; die Nachzugs-Eigentümer-Liste des Plans (§2, LP 1) nennt ADRs
  unter keinen Eigentümer. Die Entscheidung ist in der Commit-Message begründet (Link ist
  gate-sichtbar, ADR nicht eingefroren); die Zuordnungs-Lücke im Plan bleibt als Beobachtung.
- `verifizierbar`: nein — kein Gate liest den Rollen-Zuschnitt.
- `klasse`: „Nachzugs-Eigentümer-Liste des Plans nennt ADRs nicht"

## Geprüft, ohne Befund

- **Lebende Markdown-Adressen:** Markdown-Links auf `.harness/baseline/v6.9.0` über die
  Plan-Pathspec: **0**. Restliche Inline-Nennungen des alten Tags in lebenden Dateien je Treffer
  gegen [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  geurteilt: `MR-057`/`MR-058`/`MR-059`/`MR-060`/`MR-062` („gemessen am adoptierten Stand
  `v6.9.0`" — datiert, korrekt), vier Treffer in offenen Slice-Plänen (datierte Zitat-Angaben,
  korrekt), `.d-check.yml`-Kommentare (Herkunfts-Datierung, korrekt), `internal/emit/templates.go`
  (Re-Proben, auf `v6.13.0` nachgezogen), `internal/emit/baumaussage.go` (Träger ohne Tag).
  ADR-0062/0065/0069 (Accepted bzw. Stand-Zitat) unangetastet. `spec/lastenheft.md` und
  `harness/sensors/`: **0** Treffer. Die zwei Ausnahmen sind Finding 1 und 2.
- **Pin-Stellen:** `Makefile` (`BASELINE_TAG`, `BASELINE_ZIP_SHA256`), `.d-check.yml`
  (`sources`-Paar), `internal/fetch/baseline.go` (`DefaultTag`, `DefaultBaselineSHA256`),
  `internal/emit/baumaussage.go` (`InventurMessTag`) — alle auf `v6.13.0`/dessen sha256
  `b5151e77…`, byte-gleich über alle vier Stellen. sha256 am Asset mit drei Quellen belegt
  (Tausch-Commit-Meldung + Übergabe-Artefakt, Kontrolllauf gegen `v6.9.0` byte-gleich zum
  alten Pin).
- **Symlinks:** 7 Zeiger in `.claude/rules/`, 0 auf einem anderen Tag.
- **§3.4:** keine `Accepted`-ADR im Diff verändert; einzig ADR-0061 (Proposed) als
  Adress-Nachzug (Finding 5).
- **§3.3/Commit-Zuschnitt:** Move-Commits (`4420a4f4`/`83c61b92`) getrennt vom Inhalt;
  Ruhe-Marker-Rückzug (`b8597a22`) eigener Commit; jede Message nennt Rolle und Kennung
  (`ADR-0072`, `LH-QA-01`, `LH-QA-02`, `LH-FA-09`, `MR-007`).
- **MR-063:** der Tausch-Commit führt die Strenge-Bilanz auf Nicht-Null-Basis ausdrücklich
  („alle 9 aktive Module … behalten ihre Basis"); Risiko 6 des Plans entfällt.
- **§3.7 an neuen/geänderten Kommentaren:** `templates.go`-Proben (Indikativ, „gilt für den
  jeweils aktuellen Satz"), `.d-check.yml`-Datierungen, `baumaussage.go`-Träger — keine
  verordesene Chronik, keine Verfahrens-Herkunft.
- **Übergabe-Artefakte als Eingabe:** Freshness-Report über alle 71 aktiven Einträge
  (6 Einheiten betroffen mit Release-Attribution + 65 nicht betroffen = 71; kein Ausgang
  *widerspricht*/*Bezug entfallen*; Stichprobe gegen
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) → 0); migrations-Report mit
  Delta am vendorten Baum gemessen (8 Vorlagen, Tausch-Commit gegen Vorgänger) und 15+9+1
  Register-Zeilen = 25 Vorlagen.
- **Register-Belege:** Commit `b94b44ee` zieht die Linktiefe in zwei Evidence-Dateien auf 7
  Ebenen; die Belege nennen Vorgang, Fund und Anker.

## Ergebnis

**Merge-Blocker: ja** — die Findings 1 und 2. Die Architect-Buchung des Zielstands ist
unvollständig: `harness/conventions.md` §Baseline und `harness/migration.md` (Sprung-Zeile +
Präsens-Absatz) tragen die Buchung nicht, die der Plan dem Archite-Commit zuweist, und
`harness/migration.md` bleibt mit einer falschen Präsens-Aussage über den vendored Baum stehen.
Beides ist in einem kleinen Archite-Nachzug behebbar; der Diff selbst ist an allen geprüften
Stellen sauber, die Findings betreffen Auslassungen, keine falschen Neuschreibungen.
Finding 3 (ausstehende Register-Zuordnung, Rückführung (b)-Lage) blockiert die Closure, nicht
den Diff.
