# Review-Report — slice-177 (Das Beobachtungs-Register läuft in der Verzeichnis-Form)

**Datum:** 2026-09-05 · **Rolle:** Reviewer (Modul 8, frischer Kontext) ·
**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) 1.7.0
**Runde:** 1

## Eingangs-Kontext (fünf Pflicht-Punkte + Slice-Plan)

| Punkt | Inhalt |
|---|---|
| **Diff/Commit-Range** | `2b7db5c..5dd0cf3` = `ed0a661` (Migrations-Commit) · `5dd0cf3` (DoD-Häkchen); **234** Dateien, 1078+/411− (`git diff --shortstat 2b7db5c 5dd0cf3`). Mitgeprüft, weil sie dieselbe Ziel-Form treffen: `e0ff54f` (Merge slice-178, darin die vom Koordinator von Hand angelegten `BEO-040`/`BEO-041`), `df86429` (Architect, drei Adaptions-Zeilen), `de07232` (Koordinator, zwei Nacharbeiten). **Nicht** geprüft: der slice-178-Inhalt selbst — anderer Gegenstand. |
| **`LH-*`** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der Gate-Prüfumfang ändert mit der Ablage seinen Gegenstand), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Ziel-Form kommt aus dem gepinnten Baum) |
| **Aktive ADRs im Commit-/Plan-Text** | `ADR-0034` (tragend), `ADR-0030`, `ADR-0028`, `ADR-0016`, `ADR-0018`, `ADR-0033`, `ADR-0023`, `ADR-0026`, `ADR-0027`, `ADR-0032` |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.1–§3.9, tragend hier §3.3, §3.4, §3.5, §3.6, §3.7, §3.8, §3.9 |
| **Vorherige Findings am gleichen Modul** | [`2026-09-05-slice-182-baum-tausch-v600-review.md`](2026-09-05-slice-182-baum-tausch-v600-review.md) — unmittelbarer Vorgänger in derselben Welle: HIGH ×4, MEDIUM ×4, LOW ×4, INFO ×3. Wiederkehrende Klassen dort: `Präsens-Aussage-gegen-gepinnten-Stand` (`BEO-009`, 3×), `Sensor-Grenze-als-Sensor-Aussage` (LOW-3, `BEO-025`), `Folge-Slice-traegt-den-Befund-nicht` (HIGH-4). **Alle drei kehren hier wieder** — siehe HIGH-2, HIGH-3, MEDIUM-1. Dazu [`2026-08-31-slice-144-review.md`](2026-08-31-slice-144-review.md) HIGH-1, aus dem [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) hervorging — die Regel, die HIGH-4 unten trifft. |
| **Slice-Plan** (Repo-Ergänzung) | [`slice-177`](../plan/planning/in-progress/slice-177-beobachtungs-register-verzeichnis-form.md) |

**Selbst gefahren, nicht aus Commit-Messages übernommen** (Ergebnisse in den
Negativbefunden): `make gates` (EXIT 0) · zwei kontrafaktische `d-check`-Läufe über einer
`git archive HEAD`-Kopie im Scratch-Bereich, mit demselben gepinnten Digest und derselben
netzlosen Docker-Form wie `make docs-check` ([`AGENTS.md`](../../AGENTS.md) §3.9 — der
Arbeitsbaum wurde dabei nicht angefasst) · Zähler- und Beleg-Namens-Abgleich über alle 39
migrierten Einträge gegen den Elternstand · Rename-Messung über dem Migrations-Commit ·
Form-Prüfung über alle 41 Verzeichnisse und 84 Beleg-Dateien.

Alle Zahlen unten stehen neben dem Kommando, das sie liefert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1); keine ist ein Erwartungswert.

---

## Findings

### HIGH-1 — Die Ablage trägt eine fortlaufende Nummer, wo die entschiedene Ziel-Form das Sub-Area-Kürzel verlangt

- **kategorie:** HIGH
- **quelle:** [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 3 (`Accepted`), Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register, [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) (eine Abweichung schuldet einen Eintrag)
- **pfad:** `docs/plan/planning/observations/BEO-001/` … `BEO-041/` (41 Verzeichnisse)
- **befund:** Das erste Pfad-Segment jedes Beobachtungs-Verzeichnisses ist eine fortlaufende Nummer. Die Ziel-Form adressiert `BEO-<KUERZEL>/<slug>` und sagt dazu ausdrücklich *„Eine fortlaufende Nummer gibt es nicht mehr — sie setzte voraus, dass man alle vergebenen kennt, was über offene Branches niemand kann"*; [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 3 entscheidet den Wert für die einzige berührte Sub-Area: `*` (gesamtes Repo) → `ALL`, und der Slice-Plan zitiert genau das in DoD 1. Gemessen: `git grep -rn 'BEO-ALL' -- '*.md' ':!.harness/baseline'` → leer, Exit 1; `ls docs/plan/planning/observations/ | grep -c '^BEO-[0-9]'` → **41**. Der Katalog des vorausgehenden Inventur-Slice führt die Umstellung als eigene Position: [slice-176](../plan/planning/done/slice-176-inventur-vor-dem-schnitt-v600.md) §9, P-02 — *„Kennung: `BEO-<NNN>` → `BEO-<KUERZEL>/<slug>`; **keine Vergabestelle, keine fortlaufende Nummer**"*, Träger slice-177, **kein neuer Slice**. Das Versagen ist nicht prognostiziert, sondern in diesem Diff bereits eingetreten: die Merge-Konfliktlösung zu slice-178 musste die zwei neuen Kennungen `BEO-040`/`BEO-041` von Hand vergeben, also den Stand aller vergebenen Nummern über zwei Zweige hinweg kennen — genau die Voraussetzung, die die Ziel-Form abschafft. DoD 1 ist mit `[x]` als erfüllt markiert, obwohl derselbe Punkt das Kürzel-Segment nennt. Trägt man die Nummer-Form stattdessen als bewusste Repo-Abweichung, fehlt der nach [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) fällige Eintrag im Adaptions-Block (`git grep -l 'BEO-<NNN>' -- harness/conventions.md harness/conventions/` → leer, Exit 1). Beide Lesarten führen auf einen Befund.
- **verifizierbar:** nein durch ein Gate — [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) §Fitness Function sagt für Festlegung 3 selbst *„hat keinen Sensor"*, und `make gates` steht EXIT 0. Ja durch Handlauf: `ls docs/plan/planning/observations/` gegen `sed -n '/^\*\*3\./,/^\*\*4\./p' docs/plan/adr/0034-*.md`.
- **klasse:** `Entschiedene-Ziel-Form-nicht-vollzogen`

### HIGH-2 — Der neue `codepaths`-Tombstone blendet 24 tote Adressen in lebenden Artefakten aus, und sein Config-Kommentar nennt einen engeren Bereich, als der Eintrag hat

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Ein Kommentar beschreibt, was da ist*), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Stilles-Grün-Pfad), [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
- **pfad:** `.d-check.yml:168–172` (Kommentar), `.d-check.yml:180` (Eintrag)
- **befund:** Der siebte Eintrag unter `codepaths.ignore-refs` wirkt **referenz-weit** über den ganzen Baum. Sein Kommentar benennt als Nutznießer *„der Bestand in `docs/plan/planning/done/` und `docs/reviews/`"*. Gemessen wirkt er weiter: über einer `git archive HEAD`-Kopie mit **nur** dieser einen entfernten Zeile meldet derselbe gepinnte d-check `772 Datei(en) geprüft, 113 Befund(e)`, mit ihr `772 … 0`. Die 113 verteilen sich auf `docs/plan/planning/done/` **89**, `docs/plan/planning/open/` **12**, `docs/plan/planning/in-progress/` **5** (die eigene Plandatei), `.claude/commands/` **3**, `internal/emit/templates/commands/` **3**, `docs/user/` **1** — also **24** außerhalb der zwei genannten Klassen, davon **18** in Artefakten, die kein Zeitdokument sind, und **3** davon im **emittierten** Vorlagen-Satz, der jeden Adopter bindet. `docs/reviews/**` liegt ohnehin schon in `codepaths.exempt-paths` und trägt keinen der 113 Befunde. Der Eintrag als solcher liegt innerhalb der Wachstums-Klausel von [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) (*„wächst nur mit weiteren bewusst entfernten Artefakten"*) — beanstandet ist nicht seine Existenz, sondern dass sein Kommentar eine Reichweite beschreibt, die er nicht hat, und dass DoD 2 desselben Slice *„Belegt durch `make docs-check`"* für die Zusage *„lebende Artefakte sind nachgezogen"* anführt, während derselbe Commit den Sensor für genau diese Klasse blind macht. Ein nachfolgender Lauf, der einen dieser 18 Pfade schreibt oder stehen lässt, bekommt grünes `docs-check` und liest das als Deckung.
- **verifizierbar:** ja — `git archive HEAD | tar -x -C <kopie>`, dort `sed -i '180d' .d-check.yml`, dann `docker run --rm --network none -v "<kopie>:/repo:ro" ghcr.io/pt9912/d-check@sha256:5ea03abe7918381c68203d8ac078a78d0d4ab91b5478e87c66b5a7b4fda41288` → `772 … 113`, gegen `772 … 0` ohne den Schnitt.
- **klasse:** `Sensor-Grenze-als-Sensor-Aussage` (`BEO-025` — *eine Zusage nennt einen Sensor, der die zugesagte Form nicht sieht*; Register-Stand 5×, **geplant** → slice-181. Wiederholung von LOW-3 aus [`2026-09-05-slice-182-baum-tausch-v600-review.md`](2026-09-05-slice-182-baum-tausch-v600-review.md), eine Stufe höher, weil der Sensor hier nicht bloß eng ist, sondern von demselben Commit verengt wurde, der ihn als Beleg anführt.)

### HIGH-3 — DoD 4 ist abgehakt, während die Planning-README die abgeschaffte Form weiter beschreibt — in genau der Zeile, die dieser Commit angefasst hat

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*Keine Zusage ohne rot gesehenes Gegenbeispiel* — ein DoD-Punkt ist dort namentlich als Zusage geführt)
- **pfad:** `docs/plan/planning/README.md:31–35`
- **befund:** Der Abschnitt *## Beobachtungs-Register* sagt nach dem Diff: „`observations.md` liegt **flach** in diesem Verzeichnis, neben den Wellen … **die Datei** steht, sie wandert nicht … Die Regeln stehen in **der Datei** selbst." Vier Aussagen, alle nach der Migration falsch: die Ablage ist ein Verzeichnis, die genannte Datei existiert nicht (`ls docs/plan/planning/observations.md` → *Datei oder Verzeichnis nicht gefunden*), und die Regeln stehen in `observations/README.md`. Der Commit hat genau diese Zeile bearbeitet — er hat das Link-Ziel von `observations.md` auf `observations/README.md` gezogen und die vier Aussagen daneben stehen lassen (`git diff 2b7db5c 5dd0cf3 -- docs/plan/planning/README.md` zeigt eine einzige geänderte Zeile). DoD 4 wurde mit `5dd0cf3` als erfüllt markiert und sagt: *„jede Quelle, die die Register-**Form** beschreibt statt nur auf sie zu zeigen, ist nachgezogen oder als Übergabe benannt (§6)"*. Diese Quelle ist weder das eine noch das andere: §6 nennt den Register-Kopftext, die drei Anweisungssätze und ihre emittierten Gegenstücke, nicht die Planning-README; und der gemessene Bestand von [slice-184](../plan/planning/open/slice-184-register-form-im-bestand-nachziehen.md) §1 trifft sie ebenfalls nicht (`grep -c 'BEO-<NNN>\|Registerzeile\|Zähler erhöhen' docs/plan/planning/README.md` → **0**). Die Planning-README ist der Einstieg in das Layout; ein Lauf, der ihr folgt, sucht eine flache Datei und legt sie im Zweifel wieder an.
- **verifizierbar:** nein durch ein Gate — `make docs-check` prüft Ziele, nicht den Wahrheitsgehalt von Prosa; das Ziel dieser Zeile löst auf. Ja durch Handlauf: `sed -n '29,35p' docs/plan/planning/README.md` gegen `ls docs/plan/planning/observations/`.
- **klasse:** `Zusage-neben-geaenderter-Ableitung-bleibt-stehen` (`BEO-009`; Register-Stand 11×, **geplant**)

### HIGH-4 — Ein Implementer-Commit schreibt in die Reviewer-eigene Skill-Datei, während derselbe Commit drei Architect-Zeilen aus demselben Grund unangetastet lässt

- **kategorie:** HIGH
- **quelle:** [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 (`Accepted` seit 2026-09-03, Cutoff *„geprüft wird ab dem Commit, der diese ADR annimmt"*), [`AGENTS.md`](../../AGENTS.md) §3.8 (dieselbe Trennungs-Logik)
- **pfad:** `.harness/skills/reviewer.md:111` in `ed0a661`
- **befund:** `ed0a661` („Rolle Implementation: slice-177 …") ändert eine Zeile in `.harness/skills/reviewer.md`. Die Anwendungs-Tabelle von [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 führt genau diese Datei mit der Rolle **Reviewer** und hält fest, dass die Artefaktklasse gebunden ist, nicht die Datei-Form. Der Widerspruch liegt im Commit selbst: derselbe Lauf hat die drei toten Verweise in [`MR-041`](../../harness/conventions.md#mr-041), [`MR-047`](../../harness/conventions.md#mr-047) und [`MR-048`](../../harness/conventions.md#mr-048) ausdrücklich **nicht** repariert, obwohl die Reparatur identisch trivial war, und sie als Architect-Übergabe in §6 eskaliert — mit der richtigen Begründung. Dieselbe Begründung trägt für die Skill-Datei, und sie wurde nicht angewandt. Der Rollen-Wechsel ist der einzige Träger dieser Regel; ein Gate gibt es dafür nicht.
- **verifizierbar:** nein — kein Modul aus `modules:` der [`.d-check.yml`](../../.d-check.yml) liest Commits, und `make mutate` kennt keine Fehlschlag-Form für einen Commit-Zuschnitt ([`AGENTS.md`](../../AGENTS.md) §3.8 stellt dieselbe Lage für sich selbst fest). Ja durch Handlauf: `git show --stat ed0a661 -- .harness/skills/`.
- **klasse:** `Fremdes-Rollen-Artefakt-im-Implementations-Kontext`

### MEDIUM-1 — Die Adress-Hälfte der lebenden Artefakte ist zwischen slice-177 und slice-184 zirkulär zugewiesen

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst (ein Ausgang muss *tragen*), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** [`slice-177`](../plan/planning/in-progress/slice-177-beobachtungs-register-verzeichnis-form.md) §6, zweites Risiko · [`slice-184`](../plan/planning/open/slice-184-register-form-im-bestand-nachziehen.md) §1
- **befund:** slice-177 §6 führt die Zeile *„Beobachtungs-Register (`../observations.md`) fortgeschrieben"* unter der **Form-Beschreibung** und weist sie slice-184 zu; slice-184 §1 sagt in der Gegenrichtung: *„Der Gegenstand ist die Form-Beschreibung, nicht die Adresse. Den Pfad `observations.md` → `observations/` zieht slice-177 über seine Bezugsmenge nach"* — und noch einmal: *„die Adresse zieht slice-177 über seine eigene Bezugsmenge nach"*. Der Pfad in dieser Zeile ist eine Adresse, keine Form-Beschreibung. Ergebnis: 18 tote Adressen in lebenden Artefakten (Aufstellung in HIGH-2) haben keinen benannten Träger, und der Ausgang *weiter offen* jenes Risikos trägt nicht, was er zu tragen vorgibt. Die Klasse ist dieselbe, die der Vorgänger-Review als HIGH-4 gemeldet hat.
- **verifizierbar:** ja — derselbe kontrafaktische Lauf wie in HIGH-2 (`772 … 113`), plus `git grep -n 'Beobachtungs-Register (\`\.\./observations\.md\`) fortgeschrieben' -- docs/plan/planning/open docs/plan/planning/next`.
- **klasse:** `Folge-Slice-traegt-den-Befund-nicht` (Wiederholung aus [`2026-09-05-slice-182-baum-tausch-v600-review.md`](2026-09-05-slice-182-baum-tausch-v600-review.md) HIGH-4)

### MEDIUM-2 — Das Gate-Ergebnis dieses Slice hängt an einem ungeignorten Verzeichnis, und der benannte Ausgang schließt das nicht

- **kategorie:** MEDIUM
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **pfad:** `.gitignore`, `.d-check.yml:28` (`scan.ignore`), `.claude/worktrees/`
- **befund:** `scan.roots` ist `["."]`, und `scan.ignore` führt `.claude/worktrees/**` nicht; `.gitignore` ebenso wenig (`grep -c worktree .gitignore` → **0**, Exit 1). §6 des Plans hat den Fall gemessen — 5484 zusätzliche `docs-check`-Befunde und ein falscher `bats`-Fehlschlag in `test/comment-claims.bats:27` über eine `pipefail`/`SIGPIPE`-Interaktion — und ihm den Ausgang *weiter offen* gegeben, ausdrücklich ohne Träger. Das Verzeichnis ist zum Prüfzeitpunkt leer (`ls -A .claude/worktrees | wc -l` → **0**), und nur deshalb ist mein `make gates` EXIT 0 reproduzierbar. Ein paralleler Lauf, der dort wieder einen Worktree anlegt, macht denselben Baum rot, ohne dass sich ein Byte des Repos geändert hat.
- **verifizierbar:** ja — `make gates` bei belegtem gegen leeres `.claude/worktrees/`; die rot-dann-grün-Messung liegt in §6 des Plans vor und ist mit dem heutigen leeren Zustand einseitig bestätigt.
- **klasse:** `Gate-Ergebnis-haengt-an-ungeignortem-Pfad`

### MEDIUM-3 — Zwei Verweis-Konventionen auf dieselbe Kennungsklasse stehen unentschieden nebeneinander

- **kategorie:** MEDIUM
- **quelle:** Maintainability, [`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form) (die Präzedenz derselben Form-Umstellung, die ihren Verweis-Mechanismus ausdrücklich festlegt)
- **pfad:** repo-weit; Beispiele `docs/plan/planning/in-progress/roadmap.md` (Implementer-Form) gegen `harness/conventions/MR-041-*.md`, `MR-047-*.md`, `MR-048-*.md` (Architect-Form, `df86429`)
- **befund:** Der Implementer hat **alle** `BEO-*`-Verweise auf die Register-Wurzel gezogen, der Architect-Commit `df86429` drei davon auf den Eintrag selbst. Gemessen: `git grep -o 'observations/README\.md' -- '*.md' ':!.harness/baseline' | wc -l` → **84**, `git grep -o 'observations/BEO-[0-9]*/[a-z0-9-]*/' -- '*.md' ':!.harness/baseline' | wc -l` → **3**. Keine Quelle entscheidet, welche der beiden gilt; die Ziel-Form gibt der Kennung erstmals eine eigene Adresse, was die Wurzel-Form ungenutzt lässt und die Eintrags-Form gegen Slug-Änderungen empfindlich macht. Zwei Konventionen für dieselbe Referenzklasse driften — dasselbe Muster, das [`MR-045`](../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form) beim Adaptions-Block durch einen ausdrücklichen Anker-Mechanismus vermieden hat.
- **verifizierbar:** ja — die zwei `git grep -o … | wc -l` oben.
- **klasse:** `Zwei-Konventionen-fuer-dieselbe-Referenzklasse`

### LOW-1 — 84 Link-Label nennen eine Datei, die es nicht mehr gibt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Doku-Drift), Maintainability
- **pfad:** u. a. `docs/plan/planning/README.md:31`, `.harness/skills/reviewer.md:111`, `docs/plan/planning/open/slice-134-adr-index-traegt-die-ziel-form.md:162`
- **befund:** Die nachgezogenen Verweise tragen durchgängig die Form ``[`observations.md`](../observations/README.md)`` — das Ziel löst auf, das Label ist ein Inline-Code-Pfad auf eine gelöschte Datei. `codepaths` sieht ein Label innerhalb von `[…]` nicht: im kontrafaktischen Lauf ohne Tombstone erzeugt keine dieser 84 Stellen einen Befund, obwohl der Pfad tot ist. Der Leser bekommt einen funktionierenden Link mit falscher Beschriftung.
- **verifizierbar:** ja — `git grep -c '\[`observations\.md`\](' -- '*.md' ':!.harness/baseline'`, gegen die 113-Befund-Liste des kontrafaktischen Laufs, die keine dieser Stellen führt.
- **klasse:** `Label-nennt-abgeloesten-Pfad`

### LOW-2 — DoD 3 des Plans behauptet ein rotes `docs-check`, gemessen ist es grün

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** [`slice-177`](../plan/planning/in-progress/slice-177-beobachtungs-register-verzeichnis-form.md) §2, DoD 3 und §6, fünftes Risiko
- **befund:** Beide Stellen sagen im Indikativ Präsens, `docs-check` bleibe mit genau **3** `target-missing`-Befunden rot, solange die drei Architect-Zeilen stehen. Der Architect-Commit `df86429` hat sie gezogen; mein `make docs-check` meldet `772 Datei(en) geprüft, 0 Befund(e)`, `make gates` EXIT 0. Die Aussage ist Chronik geworden und steht in einem lebenden Plan — Nachzug ist Closure-Arbeit des Planners, nicht des Implementers.
- **verifizierbar:** ja — `make docs-check`.
- **klasse:** `Zusage-neben-geaenderter-Ableitung-bleibt-stehen` (`BEO-009`)

### LOW-3 — Ein Zeitdokument derselben Klasse wird zweifach behandelt

- **kategorie:** LOW
- **quelle:** [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4
- **pfad:** `docs/plan/planning/done/slice-178-regierende-fassung-des-sprungs-v600.md:140,242`
- **befund:** Der gesamte `done/`-Bestand ist nach [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 entlinkt worden — Text bleibt, Adresse fällt; Stichproben in `slice-137`, `slice-149`, `welle-10-results.md` bestätigen das durchgängig. `done/slice-178-…` trägt dagegen zwei aufgelöste Links auf `../observations/README.md`, angelegt als die Datei noch in `in-progress/` lag und beim `git mv` nicht mitgezogen. Kein Befund heute (die Ziele lösen auf), aber beim nächsten vorgeschriebenen Ortswechsel der Ablage steht diese eine `done/`-Datei wieder mit toter Adresse da, während ihre Nachbarn keine haben — die Klasse, die `BEO-017` führt.
- **verifizierbar:** ja — `git grep -n 'observations/' -- 'docs/plan/planning/done/*.md'` liefert genau diese zwei Treffer plus zwei Prosa-Nennungen ohne Link.
- **klasse:** `Zeitdokument-Klasse-uneinheitlich-behandelt` (`BEO-017`)

### INFO-1 — Die Zerlegung ist verlustbehaftet, der Verlust ist gemessen und hat keinen Sensor

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (die Chronik gehört nicht in die `Stand`-Zelle)
- **pfad:** `docs/plan/planning/observations/`
- **befund:** Der alte Träger misst `git show ed0a661^:docs/plan/planning/observations.md | wc -c` → **87 596** Zeichen, der neue `find docs/plan/planning/observations -name '*.md' -exec cat {} + | wc -c` → **48 294**. Der Unterschied ist überwiegend die Chronik-Prosa, die §3.7 aus einer `Stand`-Zelle ohnehin verbannt — die Stichproben `BEO-003` und `BEO-009` zeigen, dass die tragenden Messungen je Beleg in die Evidence-Dateien gewandert sind statt verloren zu gehen. Dass das für **alle** 39 Einträge gilt, ist ein Urteil je Eintrag und maschinell nicht prüfbar; ein Sensor dafür existiert nicht und wird hier auch nicht gefordert. Die Zeile steht, damit die Grenze der Prüfung benannt ist und nicht als Deckung gelesen wird.
- **verifizierbar:** nein.
- **klasse:** `Urteilsbehaftete-Migration-ohne-Sensor`

### INFO-2 — [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Folgepflicht 2 ist offen und wird durch HIGH-1 gegenstandslos

- **kategorie:** INFO
- **quelle:** [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Folgepflicht 2 (Architect-Commit)
- **pfad:** `harness/conventions.md:189–204`
- **befund:** §Modus-Deklaration pro Sub-Area führt weiterhin *„Eine Kürzel-Spalte führt diese Tabelle nicht"* und begründet das gegen den abgelösten Stand `v5.18.0` (`grep -n 'adoptierter Stand `v5.18.0`' harness/conventions.md` → 1 Treffer). Die Folgepflicht ist Architect-Arbeit und liegt außerhalb dieses Slice; sie wird aber erst sinnvoll, wenn die Ablage das Kürzel überhaupt benutzt (HIGH-1). Beide Posten gehören in dieselbe Übergabe.
- **verifizierbar:** ja — `sed -n '189,204p' harness/conventions.md`.
- **klasse:** `Folgepflicht-ohne-Gegenstand`

### INFO-3 — Der zweite Beleg aus [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 4 ist unabhängig nachgemessen und hält

- **kategorie:** INFO
- **quelle:** [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 4, [`AGENTS.md`](../../AGENTS.md) §3.3
- **pfad:** Commit `ed0a661`
- **befund:** Die Ein-Commit-Erlaubnis hing an einer Messung, die der vollziehende Lauf vorzulegen hatte. `git diff-tree -r --name-status -M ed0a661 | awk '{print substr($1,1,1)}' | sort | uniq -c` → **161** `A`, **1** `D`, **72** `M`, **0** `R`. Die Prämisse von §3.3 trifft damit nicht zu, der Vorgang bleibt ein Commit, und der Re-Evaluierungs-Trigger *„wenn die Rename-Messung einen Rename ausweist"* ist nicht gefeuert. Kein Befund — die Zeile steht, weil die ADR die Messung ausdrücklich beim Reviewer und nicht bei der Behauptung des Implementers verortet.
- **verifizierbar:** ja — Kommando oben.
- **klasse:** —

---

## Negativbefunde (geprüft, ohne Befund)

- **Vollständigkeit der Migration, Zähler-Achse.** `git show ed0a661^:docs/plan/planning/observations.md | grep -c '^| BEO-'` → **39**; `git ls-tree -r --name-only ed0a661 docs/plan/planning/observations | grep -c '/observation\.md$'` → **39**. Summe der Zähler-Spalte am Elternstand (`awk -F'|' '/^\| BEO-/{gsub(/[^0-9]/,"",$5); s+=$5} END{print s}'`) → **82**; Evidence-Dateien am Migrations-Commit → **82**. Am HEAD **41**/**84** — die zwei Zusätze sind `BEO-040`/`BEO-041` aus der Merge-Konfliktlösung.
- **Vollständigkeit der Migration, Eintrags-Achse.** Nicht nur die Summe, sondern je Eintrag geprüft und über die **Namen** der Belege, nicht nur ihre Anzahl: für alle 39 Kennungen ist die sortierte Menge der Dateinamen unter `evidence/` zeichengleich mit der Belege-Spalte des Elternstands. **39 von 39, 0 Abweichungen** — die Behauptung des Implementers hält und ist hier eine Stufe schärfer gemessen.
- **Stand-Werte.** Alle 39 Werte sind unverändert übernommen (2× `verkörpert`, 4× `geplant`, 35× `offen` inkl. der zwei neuen). `BEO-007` steht in beiden Fassungen auf `geplant` — der alte Zellentext nennt *„verkörpert"* nur für einen von drei Teilen und schließt mit *„Die Zeile trägt darum weiter **geplant**"*.
- **Ziel-Form je Datei.** Alle 41 `observation.md` tragen H1 in Zeile 1 und `**Sub-Area:**`; alle 41 `state.md` beginnen mit `**Stand:**`; alle 84 Evidence-Dateien tragen `**Vorgang:**` und `**Fund:**`. Kein `Zähler:`-Feld ist stehen geblieben (`grep -rn 'Zähler:' docs/plan/planning/observations/` → leer). Kein Template-Bedienhinweis wurde mitkopiert.
- **`Stand`-Zelle trägt keine Chronik** (Skill-HIGH-Anker). Kein `state.md` führt „Der N-te Beleg …", „Erstauftreten", „Bis slice-…" oder ein Lauf-Protokoll; die Belege stehen als Fund je Datei. Größter `state.md`: **1 248** Zeichen, Summe **11 458** (`wc -c docs/plan/planning/observations/BEO-*/*/state.md`). `verkörpert` trägt Zielort **und** Herkunfts-Anker, `geplant` trägt eine Kennung.
- **Register-Paarung, maschinelle Hälfte.** Jede der 84 Evidence-Dateien nennt einen Vorgang, dessen Datei in `docs/plan/planning/done/` liegt — über alle geprüft, kein Ausreißer. Jedes Verzeichnis hat ein nicht leeres `evidence/`.
- **Das vierte `ignore-refs`-Paar entspricht [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 2 wörtlich** und ist genau tragend: über der Kopie mit entfernten Zeilen 103–104 meldet derselbe gepinnte d-check `772 Datei(en) geprüft, 1 Befund(e)` — `docs/plan/adr/0028-…:81 ../planning/observations.md target-missing` —, mit dem Paar `772 … 0`. Die **geprüfte Datei-Zahl bewegt sich nicht** (772 in beiden Läufen), also ist es ein Referenz- und kein Datei-Ventil; die Folgepflicht-1-Belegläufe sind damit unabhängig nachgefahren. `scan.ignore` und `codepaths.exempt-paths` sind unverändert (`git diff 2b7db5c 5dd0cf3 -- .d-check.yml` berührt beide nicht).
- **Der `codepaths.ignore-refs`-Zuwachs ist keine Gate-Senkung ohne ADR — REFUTED mit Beleg.** [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) §Auflösungs-Trigger sagt: *„permanent; … `ignore-refs` wächst nur mit weiteren **bewusst entfernten** Artefakten"*, und `docs/plan/planning/observations.md` ist nach [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 1 bewusst entfernt. Die Präzedenz ist der sechste Eintrag (`harness/tools/archive-welle.sh`, [`ADR-0033`](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)) und in Form und Kommentar-Stil identisch. [`AGENTS.md`](../../AGENTS.md) §3.5 ist damit **nicht** ausgelöst. Beanstandet bleibt allein die Reichweiten-Aussage des Kommentars (HIGH-2), nicht der Eintrag.
- **Zeitdokument-Delinking nach [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4.** Stichproben über `done/slice-137`, `done/slice-149`, `done/welle-10-results.md`, `done/welle-14-results.md` und `docs/reviews/`: durchgängig Adresse entfernt, Text zeichengleich erhalten (`[`BEO-005`](../observations.md)` → `` `BEO-005` ``), **nicht** auf die neue Form umgebogen. Kein Zeitdokument wurde versehentlich umgezielt außer dem in LOW-3 genannten Fall, und keines wurde versehentlich inhaltlich verändert.
- **`make gates` — selbst gefahren, EXIT 0.** `baseline-verify: v6.0.0 OK — 53 Dateien` · `d-check: 772 Datei(en) geprüft, 0 Befund(e)` · bats `1..218`, **218** `ok`, **0** `not ok` · `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)` · `go test -count=1 ./...` grün · `span-check` grün. Der Stand des Koordinators ist damit unabhängig bestätigt.
- **`test/ignore-refs-restbreite.bats` deckt das neue Paar ohne Anpassung.** Die zwei Fälle *„der Top-Level-ignore-refs-Block wird vollständig und in bekannter Form gelesen"* (`ok 119`) und *„jede Top-Level-ignore-refs-Ausnahme deckt höchstens einen Markdown-Link ihrer Quelldatei"* (`ok 120`) laufen grün; der Wächter liest den Block generisch und schreibt keine Eintrags-Zahl fest — [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Folgepflicht 3 hält.
- **Die Bezugsmengen-Zahlen von DoD 2 halten.** Am Elternstand `git grep -l 'observations\.md' ed0a661^ -- '*.md' ':!.harness/baseline' | wc -l` → **112**, dieselbe Suche mit `-o … | wc -l` → **615**, und `git grep -o 'observations\.md#' ed0a661^ …` → **0**. Alle drei Angaben des Plans sind zeichengenau nachgemessen.
- **Nur eine eingefrorene Quelle ist betroffen.** Der kontrafaktische Lauf ohne das vierte Paar liefert genau **einen** Befund, und er liegt in [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md); kein zweiter Treffer in `docs/plan/adr/`. Die Nennungen in [`ADR-0030`](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) und [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) lösen keinen Befund aus — die Form-Aussage aus [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Folgepflicht 4 (YAML-Fragment und umzäunter Block feuern `codepaths` nicht) ist damit unabhängig bestätigt.
- **`BEO-040`/`BEO-041` (Merge-Konfliktlösung, nicht vom Implementer) passen formal in die Ziel-Form.** Drei Dateien je Eintrag, Pflichtfelder vollständig, Evidence-Dateiname ist die Vorgangs-Kennung (`slice-178.md`), `state.md` ohne Chronik, Pfadtiefen nach `de07232` korrekt (sechs `../` aus `<slug>/`, sieben aus `evidence/`) — `docs-check` bestätigt beide Tiefen. Der **einzige** Formmangel ist der geteilte aus HIGH-1: sie tragen die fortlaufende Nummer statt `ALL`. Inhaltlich sind sie konsistent mit dem, was `done/slice-178-…` §6/§7 als Ausgang führt.
- **Kein Go-, Shell- oder Workflow-Code im Diff.** `git diff --name-only 2b7db5c 5dd0cf3 -- '*.go' '*.sh' '*.yml' ':!.d-check.yml'` → leer; `lint`, `build`, `shell-lint`, `ci-lint` und `comment-claims` haben zu diesem Diff nichts zu sagen außer ihrem Grün.
- **Kein halluziniertes Gate, keine neue Gate-Zusage.** Der Diff führt kein neues Make-Target und keine neue Modul-Aktivierung ein; `modules:` in [`.d-check.yml`](../../.d-check.yml) ist unverändert.

## Nicht geprüft (Abgrenzung)

- Der **Inhalt** von slice-178 und [`ADR-0036`](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) — anderer Gegenstand, eigener Review.
- Die **DoD-Abhakung als solche** ist Sache der Verifikation (getrennter Kontext). Geprüft habe ich nur, ob die *Aussagen in* den DoD-Punkten gegen den Baum halten — das trägt HIGH-1, HIGH-3 und LOW-2.
- Der **Kollisions-Vorteil** der neuen Ablage: §6 nennt ihn selbst als hergeleitet, nicht rot gesehen. Ich habe kein Merge-Verhalten gemessen und bestätige die Zusage nicht.

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 4 | HIGH-1 `Entschiedene-Ziel-Form-nicht-vollzogen` · HIGH-2 `Sensor-Grenze-als-Sensor-Aussage` (`BEO-025`) · HIGH-3 `Zusage-neben-geaenderter-Ableitung-bleibt-stehen` (`BEO-009`) · HIGH-4 `Fremdes-Rollen-Artefakt-im-Implementations-Kontext` |
| MEDIUM | 3 | MEDIUM-1 `Folge-Slice-traegt-den-Befund-nicht` · MEDIUM-2 `Gate-Ergebnis-haengt-an-ungeignortem-Pfad` · MEDIUM-3 `Zwei-Konventionen-fuer-dieselbe-Referenzklasse` |
| LOW | 3 | LOW-1 `Label-nennt-abgeloesten-Pfad` · LOW-2 `Zusage-neben-geaenderter-Ableitung-bleibt-stehen` (`BEO-009`) · LOW-3 `Zeitdokument-Klasse-uneinheitlich-behandelt` (`BEO-017`) |
| INFO | 3 | INFO-1 `Urteilsbehaftete-Migration-ohne-Sensor` · INFO-2 `Folgepflicht-ohne-Gegenstand` · INFO-3 — |

**Wiederkehrende Klassen über Läufe hinweg** (für den Steering-Loop-Zähler bei der
Closure): `BEO-009` bekommt mit HIGH-3 einen weiteren Beleg · `BEO-025` mit HIGH-2 ·
`BEO-017` mit LOW-3. Die Klasse hinter MEDIUM-1 (*ein benannter Träger trägt den Befund
nicht*) tritt zum zweiten Mal in zwei aufeinanderfolgenden Slices derselben Welle auf und
hat noch keine Kennung.

## Verdikt

**BLOCKIERT.** Vier HIGH und drei MEDIUM; HIGH und MEDIUM blockieren nach
[`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) §Ablage typischerweise
den Merge, und hier gibt es keinen Grund abzuweichen: **HIGH-1** trifft den Liefergegenstand
selbst — die Ablage steht nicht in der Form, die eine `Accepted`-ADR und die adoptierte
Baseline für sie entschieden haben, und der Schaden ist in diesem Diff bereits eingetreten
(zwei von Hand vergebene Nummern beim Merge). **HIGH-2** und **MEDIUM-1** hängen zusammen:
Der Verweis-Nachzug ist unvollständig, und der Sensor, den der Slice als Beleg dafür
anführt, wurde von demselben Commit für diese Klasse blind gemacht.

**Ausdrücklich anerkannt:** Die eigentliche Zerlegungsarbeit ist von hoher Qualität und
hält jeder Nachmessung stand, die ich gefahren habe — 39 von 39 Einträgen, 82 von 82
Belegen, jeder Beleg-Name zeichengleich, jeder Stand-Wert übernommen, keine `Stand`-Zelle
mit Chronik, jeder Beleg-Vorgang in `done/` auflösbar, jede Pflicht-Feld-Form vollständig.
Kein Finding trifft die Zerlegung; alle vier HIGH treffen die **Umgebung** des Umzugs —
Pfad-Form, Sensor-Reichweite, eine stehengebliebene Form-Beschreibung und einen
Rollen-Übergriff.

**Konflikt-Pfad ([Modul 8](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md#konflikt-pfad-als-rollen-sequenz-modul-8)):**
HIGH-1 und HIGH-4 berühren `Accepted`-ADRs. Widerspricht die Implementation einem der
beiden Befunde, ist der Weg die Sequenz mit Übergabe-Artefakten über den Architect — nicht
eine Herabstufung, weil der Implementer widerspricht. HIGH-1 hat dabei einen benennbaren
zweiten Ausgang: eine Folge-ADR, die `BEO-<NNN>` als bewusste Repo-Abweichung setzt, samt
Eintrag im Adaptions-Block. Welcher der Wege gilt, entscheidet der Architect, nicht dieser
Report.
