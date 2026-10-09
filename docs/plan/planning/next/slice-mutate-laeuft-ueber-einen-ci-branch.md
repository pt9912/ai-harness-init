# Slice slice-mutate-laeuft-ueber-einen-ci-branch: Die Mutations-Fälle eines Slice laufen über einen CI-Branch

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — der Beleg ist der eigene Branch-Lauf; eine Closure-Bedingung über die DoD
hinaus gibt es nicht.

**Bezug:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (git und
docker, kein `gh`), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der
Lauf fährt die gepinnten Images), [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions),
[`MR-069`](../../../../harness/conventions.md#mr-069--ein-job-der-bewusst-nicht-auscheckt-trägt-seine-prüfung-inline),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** pt9912 (Implementer-Lauf).

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein `git push` nach `mutate/<slice-kennung>` startet in CI die Mutations-Fälle, die der
Slice berührt, auf 10 nach Wanduhr gewichteten Shards, und das Ergebnis liegt danach als Datei im
selben Branch, lesbar mit `git fetch` und `git show`, ohne `gh`.

**Anlass** (Messung des Auftraggebers, 2026-10-09): bei Emissions-Dateien nennen über 100 Fälle eine
geänderte Datei; ein lokaler Lauf über 127 Fälle mit 4 Workern dauert etwa eine Stunde, weil 13
`full-smoke`-Fälle zu je 3–4 min auf der seriellen Spur liegen. Die Shard-Zuteilung in `mutate.yml`
ist heute **nicht** gewichtet, sondern Index-Modulo über die sortierten Namen
(`grep -n 'NR - 1' .github/workflows/mutate.yml`); die Gewichtung ist neu.

**Festlegungen des Schnitts:**

- **Branch:** `mutate/<slice-kennung>`, vom Implementer gepusht
  (`git push -f origin HEAD:refs/heads/mutate/<slice-kennung>`). Eine Kennung, ein Branch; ein
  erneuter Push ersetzt den Lauf.
- **Basis:** der Claim-Commit des Slice, also der Commit, der `in-progress/<slice-kennung>.md`
  anlegt (`git log --diff-filter=A --format=%H -1 -- docs/plan/planning/in-progress/<slice-kennung>.md`).
  Eine Anforderungsdatei gibt es nicht; die Basis folgt aus dem Branch-Namen. Ein Diff gegen `main`
  sähe nichts, sobald der Implementer `main` zwischendurch gepusht hat. Fehlt der Claim-Commit, bricht
  der Lauf ab (fail-closed).
- **Fallmenge:** jeder Fall unter `test/mutations/`, dessen `# files:` eine Datei aus
  `git diff --name-only <basis> <commit>` nennt, und jeder geänderte oder neue Fall selbst. Eine leere
  Menge ist ein Ergebnis („0 Fälle“), kein Fehler.
- **Zuteilung:** 10 Shards; schwere Fälle (die Modi der seriellen Spur, `is_heavy_mode` in
  `harness/tools/mutate.sh`, keine zweite Liste) zuerst reihum, danach die leichten auf den Shard mit
  der geringsten Last. Ein Werkzeug für beide Workflows.
- **Workflow:** eigene Datei `.github/workflows/mutate-branch.yml`, Auslöser `push` auf `mutate/**`.
  Eigene Datei, damit das Schreibrecht nicht in den nächtlichen Lauf wandert: `contents: write` trägt
  allein der Ergebnis-Job, `mutate.yml` bleibt lesend. `ci.yml` ignoriert `mutate/**`, sonst fährt
  jeder Push zusätzlich die CI-Jobs samt `full-smoke`.
- **Ergebnis:** `mutate-ergebnis.txt` an der Branch-Wurzel, ein Commit über dem geprüften: geprüfter
  Commit, Basis, Fallmenge, je Fall `ok` oder `BEFUND` mit Shard, Laufzeit je Shard und gesamt.
  Gepusht ohne `--force`: ist der Branch inzwischen weitergelaufen, scheitert der Push, und ein
  veraltetes Ergebnis landet nicht.
- **Nächtlicher Vollsweep:** bleibt nächtlich und über allen Fällen, nutzt aber dieselbe Zuteilung mit
  10 Shards. Zwei Zuteilungsregeln für dieselben Fälle würden auseinanderlaufen, und die
  Index-Modulo-Zuteilung verfehlt den Korridor nachweislich (§8, Register).
- **Lesen und Wegräumen:** Der Verifier liest das Ergebnis einmal zu Beginn seines Laufs
  (`git fetch origin mutate/<slice-kennung> && git show FETCH_HEAD:mutate-ergebnis.txt`), prüft, dass
  der geprüfte Commit der verifizierte ist, übernimmt Fallmenge und Befunde in seinen Bericht und
  löscht danach den Branch (`git push origin --delete mutate/<slice-kennung>`). Den Lauf-Beleg trägt
  ab dann sein Bericht, und der Branch hat keinen Leser mehr. Fehlt die Datei, meldet er das als
  Befund. Er wartet nicht in einer Abfrage-Schleife darauf.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Anpassung von [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  und [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)**:
  der Adaptions-Block gehört dem Architect (`AGENTS.md` §3.8). Hier steht nur die Übergabe in §2.
- **Das lokale `make mutate MUTATE_CASES=…`** bleibt unverändert. Es ist der engste Sensor während
  der Arbeit und der Weg ohne Netz.
- **Den Laufstatus eines Workflows abfragen** (läuft, abgebrochen, Logs): ein anderer Vorgang, der
  Gegenstand von `slice-der-ci-lauf-ist-abrufbar`. Hier zählt allein die Ergebnisdatei.
- **Umbau von `harness/tools/mutate.sh`** (Worker, Spuren, Beleg-Slot): ein anderer Vorgang. Jeder
  Shard ruft `make mutate MUTATE_CASES=…` wie heute.

## 2. Definition of Done

Liefer-Punkte:

- [ ] **Fallauswahl und Zuteilung:** ein Skript unter `harness/tools/` hinter einem `make`-Ziel
      ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions):
      die CI ruft `make`) gibt zu Basis, Commit, Shard-Zahl und Index die Fälle des Shards aus. Ein
      bats-Test belegt: ein Fall mit geänderter `# files:`-Datei ist gewählt, ein unberührter nicht,
      eine geänderte Fall-Datei ist gewählt, ein fehlender Claim-Commit bricht ab, schwere Fälle liegen
      auf verschiedenen Shards. Zu jeder Zusage ist die rot färbende Mutation gesehen (`AGENTS.md` §3.6).
- [ ] **CI-Pfad:** `.github/workflows/mutate-branch.yml` (push auf `mutate/**`, 10 Shards, der
      Ergebnis-Job schreibt `mutate-ergebnis.txt` in den Branch), `ci.yml` ignoriert `mutate/**`,
      `mutate.yml` fährt dieselbe Zuteilung auf 10 Shards; `make ci-lint` ist grün. Ein realer Lauf auf
      `mutate/slice-mutate-laeuft-ueber-einen-ci-branch` liegt vor, sein Ergebnis ist per `git show`
      gelesen und im Bericht zitiert.
- [ ] **Anweisungssätze und Sensor-Doku:** `.claude/commands/implement-slice.md` und
      `.claude/agents/implementer.md` (die Mutations-Pflicht wechselt von „lokal vor dem Commit“ auf
      „Branch gepusht vor der Übergabe an die Verifikation“; der Bericht nennt Branch und geprüften
      Commit), `.claude/agents/verifier.md` (Ergebnis lesen, Commit abgleichen, in den Bericht
      übernehmen, Branch löschen), `harness/sensors/mutate.md` (Weg, Ergebnisform, Grenze) und die
      Werkzeuge-Zeile des neuen Ziels in `harness/README.md`.

Konstant:

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`), kein Self-Review (Modul 8).
- [ ] **Übergabe an den Architect** (eigener Commit, `AGENTS.md` §3.8, kein Liefer-Punkt):
      [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
      und [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
      nennen den Branch-Weg statt des lokalen Laufs. Zu
      [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) ist
      entschieden, ob der Ergebnis-Job mit `contents: write` und einem `git push` außerhalb eines
      `make`-Ziels zulässig ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| neues Skript unter `harness/tools/` (Name frei, etwa `mutate-auswahl.sh`) | neu | Basis aus dem Branch-Namen, Fallmenge aus dem Diff, gewichtete Zuteilung |
| `Makefile`, `harness/README.md` §Werkzeuge | update | `make`-Ziel für das Skript, Zeile mit `kein Gate`; `shell-lint` deckt das Skript |
| `test/mutate-auswahl.bats` | neu | Auswahl, Abbruch ohne Claim-Commit, Verteilung der schweren Fälle |
| `.github/workflows/mutate-branch.yml` | neu | Plan-Job, Matrix mit 10 Shards, Ergebnis-Job mit `contents: write` |
| `.github/workflows/mutate.yml` | update | dieselbe Zuteilung, Matrix mit 10 Shards; der Kopfkommentar nennt die Gewichtung |
| `.github/workflows/ci.yml` | update | `branches-ignore: ['mutate/**']` auf `push` |
| `.claude/commands/implement-slice.md`, `.claude/agents/implementer.md`, `.claude/agents/verifier.md` | update | Pflicht und Lese-Schritt (§1) |
| `harness/sensors/mutate.md` | update | Branch-Weg, Ergebnisform, Grenze der Auswahl |

- Die Shard-Jobs laden das Ergebnis je Shard als Actions-Artefakt hoch, und der Ergebnis-Job setzt
  daraus die Datei zusammen. Lesen kann der Implementer das Ergebnis nur über die Datei im Branch,
  nicht über die Artefakte.
- Der Ergebnis-Job pusht mit explizitem Refspec auf genau `refs/heads/${GITHUB_REF_NAME}` und bricht
  ab, wenn der Name nicht mit `mutate/` beginnt.

## 4. Trigger

**Start** (`next` → `in-progress`): Der Architect hat die Bezüge bestätigt (Planner → Architect) und
den Implementer-Slot frei gemeldet (WIP-Limit 1 je Lauf).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß): Die Fallauswahl verlangt einen Eingriff in `mutate.sh` über einen
  Lese-Aufruf hinaus, oder das Ergebnis lässt sich nicht ohne zusätzlichen Token zurückschreiben.
- `in-progress` → `open` (blockiert): Die Repo- oder Organisations-Einstellung verbietet Workflows
  das Schreiben von Inhalten, oder der Architect lehnt das Schreibrecht nach
  [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) ab.

## 5. Closure-Trigger

Alle Punkte der DoD sind abgehakt. Ein realer Branch-Lauf mit gelesenem Ergebnis ist im
Verifikations-Bericht zitiert, und der Branch dieses Slice ist gelöscht
(`git ls-remote origin 'refs/heads/mutate/*'` nennt ihn nicht). Dazu kommt der Lerneintrag in §7.

## 6. Risiken und offene Punkte

- **Schreibrecht auf Inhalte.** Mit `contents: write` kann der `GITHUB_TOKEN` jeden Branch
  beschreiben, auch `main`. Ein fehlerhafter Ergebnis-Job könnte also dorthin pushen. Gemildert wird
  das durch das Recht nur im Ergebnis-Job, den expliziten Refspec und den Präfix-Abbruch (§3). Kein
  Wächter hält den Refspec. — **Ausgang:** <bei Closure>
- **CI-Minuten.** Jeder `full-smoke`-Fall baut Docker-Images und braucht Netz. Jeder Push auf den
  Branch startet bis zu 10 Shards, und `cancel-in-progress` je Ref bricht nur den älteren Lauf
  derselben Kennung ab. Bei einem privaten Repo zählt jeder Shard gegen das Kontingent
  (`docs/plan/planning/observations/BEO-ALL/mutate-matrix-actions-minuten-bei-privatem-repo/`, 1×). — **Ausgang:** <bei Closure>
- **Parallele Branches mehrerer Läufe.** Zwei Slices laufen auf getrennten Branches. Ein erneuter
  Push derselben Kennung bricht den alten Lauf ab, und ein Ergebnis-Push auf einen weitergelaufenen
  Branch scheitert (ohne `--force`). Branches, die der Verifier nicht löscht, bleiben als Leichen
  liegen; ein Wächter dafür existiert nicht. — **Ausgang:** <bei Closure>
- **Die Ergebnisdatei gelangt nach `main`.** Bringt jemand den Branch-Tip per Fast-Forward, Merge
  oder Cherry-Pick nach `main`, steht dort `mutate-ergebnis.txt`. Kein Gate prüft das. Zur Closure ist
  zu entscheiden: ein Wächter in `make gates` oder benannte Grenze. — **Ausgang:** <bei Closure>
- **Grenze der Auswahl.** Gewählt wird über `# files:`. Ein Fall, dessen Wächter-Test geändert wurde,
  dessen `# files:` aber keine geänderte Datei nennt, läuft nicht; nennt `# files:` die falsche Datei
  (`docs/plan/planning/observations/BEO-ALL/mutations-fall-zeigt-auf-falsche-datei/`, 2×), fehlt der Fall in der Menge. Das ist
  dieselbe Grenze wie bei der lokalen Regel, jetzt aber an einem Werkzeug statt an einem Urteil. —
  **Ausgang:** <bei Closure>
- **Schleife über den Ergebnis-Commit.** Ein Push mit dem `GITHUB_TOKEN` startet heute keinen neuen
  Workflow-Lauf. Ändert sich das, löste der Ergebnis-Commit einen weiteren Lauf aus. Der Workflow
  überspringt deshalb einen Tip, dessen einzige Änderung `mutate-ergebnis.txt` ist. —
  **Ausgang:** <bei Closure>

## 7. Closure-Notiz

- **Was hat funktioniert:** <bei Closure>
- **Was ging anders als geplant:** <bei Closure>
- **Steering-Loop-Eintrag:** <bei Closure>
- **Beobachtungs-Register (`../observations/`):** <bei Closure>
- **Folge-Slices:** <bei Closure>
- **Risiken aus §6:** <bei Closure>
- **Drei Paarungen:** <bei Closure>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (`ALL`: Workflows, Anweisungssätze,
Sensor-Doku) und `harness/tools/` (`TOOLS`: das neue Skript). Beide stehen in der Modus-Deklaration
von `harness/conventions.md`; feiner geschnitten ist nichts.

**Vorgelagert — offene Beobachtungen sichten:** Das Register wurde nach mutate und CI durchgesehen
(gemergter Stand, Zähler = `ls <eintrag>/evidence | wc -l`):

- `docs/plan/planning/observations/BEO-ALL/mutate-shard-kosten-ungleich-verfehlt-zielkorridor/` (1×,
  offen): Die Gewichtung dieses Slice ist die Antwort darauf, und der nächtliche Lauf nutzt sie mit.
- `docs/plan/planning/observations/BEO-ALL/mutate-matrix-actions-minuten-bei-privatem-repo/` (1×,
  offen): Risiko 2 in §6.
- `docs/plan/planning/observations/BEO-ALL/mutations-fall-zeigt-auf-falsche-datei/` (2×, offen): Die
  Auswahl hängt an `# files:` (Risiko 5). Tritt der Fall in diesem Slice auf, erreicht der Eintrag 3×
  und braucht einen eigenen Folge-Slice.
- `docs/plan/planning/observations/BEO-ALL/hintergrund-lauf-wird-gepollt-statt-abgewartet/` (2×,
  offen): Ein Lesen ohne `gh` lädt zum Abfragen in einer Schleife ein. Der Lese-Schritt in §1 liest
  deshalb einmal und meldet sonst einen Befund.
- `docs/plan/planning/observations/BEO-ALL/lauf-beleg-ist-zeitgebunden/` (1×, offen): Die
  Ergebnisdatei nennt den geprüften Commit, und der Verifier gleicht ihn ab.
- `docs/plan/planning/observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/`
  (3×, verkörpert durch `make release-warten`): Die `full-smoke`-Fälle der Shards brauchen dieselbe
  Vorstufe wie der `ci`-Job.

**Modus:** Alle berührten Sub-Areas sind GF.
