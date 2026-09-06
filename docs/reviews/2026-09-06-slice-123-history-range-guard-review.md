# Review-Report: slice-123 — 2026-09-06

**Review-Art:** Code — geprüft wird der Diff gegen **Slice-Plan + ADRs + Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung und die Closure-Notiz
§7 — das ist Verifier- bzw. Planner-Arbeit in getrenntem Kontext
([`AGENTS.md`](../../AGENTS.md) §3.10, Modul 11).

**Gegenstand:** `slice-123` · Commit-Range `f7400ba..2439519` (fünf Commits:
`11d02e1`, `82debf1`, `bdc96e8`, `141e4d0`, `2439519`) auf `main` · 10 Dateien,
+250/−11

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 (`278248f`) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan [`slice-123`](../plan/planning/done/slice-123-ci-sieht-die-historie.md)
  (§1 Anlass-Messung · §2 DoD (1)–(3) · §3 Plan-Tabelle · §4 Rückführungen · §6 Risiken)
- Aktive ADRs: [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  (vom Implementer für die zwei `implement-slice.md` in Anspruch genommen),
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only),
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) (Norm-Artefakt-Eigentum)
- Berührte `LH-*`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- `MR`-Einträge: [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 3 (die Klasse *blind und grün*),
  [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (CI-Mechanik),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) (Zahl und Kommando)
- [`AGENTS.md`](../../AGENTS.md) Hard Rules — namentlich §3.6, §3.7, §3.8, §3.9, §3.10
- **Vorherige Findings am gleichen Modul:** das Beobachtungs-Register
  [`BEO-ALL/`](../plan/planning/observations/README.md) — die Klassen
  `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` (Zähler **1**),
  `zaehler-label-nennt-falsche-einheit` (Zähler **2**) und
  `zusage-ohne-herstellbares-gegenbeispiel` (Zähler **1**) sind hier je erneut
  getroffen; die Zähler stehen neben ihrem Kommando in §Summary.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
Baseline-Regelwerk `modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

### F-1 — Neu geschriebene Kommentare tragen Lauf-Protokoll, Slice-Nummer und Konjunktiv über die verworfene Alternative

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7
- `pfad`: `harness/tools/history-range-guard.sh:26–27, 29–31, 41–43, 60–61` ·
  `test/mutations/265-history-range-guard-leere-range-uebersehen.sh:5, 12–13` ·
  `test/history-range-guard.bats:3`
- `befund`: Sechs neu geschriebene Kommentarstellen nennen nicht die Stelle, sondern
  ihre Entstehung: `history-range-guard.sh:26–27` trägt „*— ohne die Trennung waere
  die Entscheidungslogik nicht hermetisch pruefbar*" (Konjunktiv über die verworfene
  Alternative, die §3.7 als *Falsch*-Beispiel führt); `:29–31` und `:41–43` begründen
  den BELEG-Block mit „*DoD (1) im Slice-Plan slice-123*" bzw. „*genau der blinde
  Gruen-Fall, den DoD (1) verlangt, einmal rot zu sehen*" und schreiben darunter ein
  Sitzungs-Protokoll (`$ bash …` / `$ echo $?`); `:60–61` beruft sich für eine
  Design-Entscheidung auf ein Zitat aus „*Slice-Plan §1*"; die Mutations-Datei nennt
  in `:5` „*(slice-123 DoD 1)*" als Grund und in `:12–13` „*Ohne den Fixture-Test …
  bliebe das unbewacht*"; der bats-Kopf führt in `:3` „*slice-123*" als Herkunft.
  Alle vier zitierten Adressen lösen nach `docs/plan/planning/**` auf — einem
  Zeitdokument in keinem Rang der Source Precedence, das mit der Closure nach `done/`
  und danach in `done/<welle-id>/archiv.zip` wandert.
- `verifizierbar`: nein — `make comment-claims` prüft, ob ein *genannter Sensor
  existiert*, nicht worüber ein Kommentar spricht (Lauf über diesem Stand:
  `56 Datei(en) geprueft, 0 Befund(e)`); `harness/tools/*.sh` liegt in seinem
  Prüfbereich, `test/**` dauerhaft außerhalb. §3.7 hält für sich selbst fest:
  „Ein Wächter existiert nicht."
- `klasse`: Kommentar nennt den Vorgang seiner Entstehung statt der Stelle

### F-2 — Die Ausgabe-Zeile `Klon-Tiefe:` nennt eine Tiefe und zählt Shallow-Grenzen

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Slice-Plan §2 DoD (1) („*nennt beim
  Rot, was fehlt (Tiefe, angeforderte Range, Zahl der enthaltenen Commits)*")
- `pfad`: `harness/tools/history-range-guard.sh:62–68` (`depth_info`), ausgegeben in
  `:77` und `:105`
- `befund`: `depth_info()` gibt `wc -l <.git/shallow` aus — die Zahl der
  Shallow-Grenzen —, die Meldung beschriftet sie als `Klon-Tiefe`. Gemessen an einem
  Klon mit `--depth 5` (`git log --oneline | wc -l` → 5, `wc -l < .git/shallow` → 1)
  meldet der Wächter `Klon-Tiefe: 1`; die Zahl ist in jedem Klon mit Tiefe > 1 falsch
  und ist genau die Zahl, an der ein CI-Betreiber ablesen soll, ob die Tiefe der Grund
  seines Rots ist. Der Kommentar in `:57–59` beschreibt die Berechnung korrekt, die
  Ausgabe-Beschriftung folgt ihm nicht.
- `verifizierbar`: nein — `test/history-range-guard.bats:14–16` nimmt die Zeile
  ausdrücklich von jeder Wert-Prüfung aus („*wird NICHT auf einen konkreten Wert
  geprueft*"), und der `--decide`-Fixture-Pfad erreicht `depth_info()` nur über das
  Arbeitsverzeichnis des Testlaufs. Reproduzierbar mit
  `git clone --depth 5 file://<repo> <klon> && bash harness/tools/history-range-guard.sh HEAD..HEAD`.
- `klasse`: Zähler-Label nennt falsche Einheit

### F-3 — Die Nummern-Reparatur ließ den Querverweis im emittierten Anweisungssatz stehen

- `kategorie`: MEDIUM
- `quelle`: [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (der
  emittierte Bestand ist Vertrag mit dem Adopter) · Maintainability
- `pfad`: `internal/emit/templates/commands/implement-slice.md:151`
- `befund`: Die Zeile verweist für den dritten Risiko-Ausgang auf „*das
  Beobachtungs-Register (Schritt 24)*", während der Register-Schritt in derselben
  Datei seit `11d02e1`/`82debf1` die Nummer **25** trägt (`:153`); Schritt 24 ist jetzt
  die Closure mit `git mv`. Am Stand `f7400ba` war der Verweis korrekt
  (`git show f7400ba:internal/emit/templates/commands/implement-slice.md` → Zeile 143
  verweist auf 24, Zeile 145 ist der Register-Schritt 24) — die Reparatur hat die
  Listen-Nummern gezogen und den Verweis nicht. Die lokale Fassung
  `.claude/commands/implement-slice.md` trägt den Satz nicht und ist unberührt; beide
  Listen sind lückenlos 1–25 (`grep -nE '^[0-9]+\. '` je Datei → 25 Zeilen, 1…25).
- `verifizierbar`: nein — kein Modul der [`.d-check.yml`](../../.d-check.yml)
  (`links, anchors, ids, matrix, codepaths, spans`) liest Schritt-Nummern innerhalb
  einer Datei, und `internal/emit/templates/` liegt ohnehin im `scan.ignore`-Bereich
  bzw. außerhalb des `comment-claims`-Prüfbereichs.
- `klasse`: Korrektur an einem Vorkommen statt an der Fundmenge

### F-4 — `STAGED=1` ist ein unbedingtes Exit 0 ohne jede Ausgabe, wird aber als Aufruf des Wächters geführt

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Slice-Plan §6 („*Was er abdeckt, muss
  er sagen*") · Slice-Plan §1 Mess-Tabelle, dritte Zeile
- `pfad`: `harness/tools/history-range-guard.sh:97–99` · `Makefile:164` ·
  `harness/README.md:73`
- `befund`: Der `--staged`-Zweig verlässt das Skript vor jeder Prüfung mit Exit 0;
  weil das Rezept mit `@` beginnt, erzeugt `make history-range-guard STAGED=1`
  **keine einzige Ausgabezeile** und Exit 0 — gemessen. `harness/README.md:73` führt
  diese Form gleichrangig neben `RANGE=` als Aufruf „*des Vorlauf-Wächters*", ohne zu
  sagen, dass in diesem Modus nichts geprüft wird. Der Slice-Plan §1 hält in derselben
  Mess-Tabelle, aus der der Wächter entstand, für „*`--staged` ohne gestagte Änderung*"
  dasselbe Symptom fest wie für die leere Range (`0 Befund(e)`, Exit 0); die
  Begründung der Ausnahme im Skriptkopf (`:18–19`: „*braucht keine Tiefe > 1*")
  beantwortet die Tiefen-, nicht die Blindheits-Frage.
- `verifizierbar`: nein — `test/history-range-guard.bats:41–44` prüft für diesen Modus
  ausschließlich `status -eq 0` und zementiert damit den No-op; kein Gate liest das
  Verhältnis von Zusage und Abdeckung.
- `klasse`: Zusage greift weiter als Abdeckung

### F-5 — Die Berufung auf ADR-0028 trägt die emittierte Hälfte der Änderung nicht

- `kategorie`: MEDIUM
- `quelle`: [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  §Was hier NICHT entschieden ist · Slice-Plan §Ebene
- `pfad`: `internal/emit/templates/commands/implement-slice.md:115–122`
- `befund`: [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  Festlegung 1 weist `.claude/commands/implement-slice.md` dem Implementer zu — die
  lokale Hälfte der Änderung ist damit gedeckt. Ihr Abschnitt *Was hier NICHT
  entschieden ist* nennt jedoch ausdrücklich „*und die emittierte Ebene*"; der
  Slice-Plan erklärt im Kopf „**Ebene: Dogfood, nicht emittiert**" und grenzt die
  Tool-Ebene an den Slice ab, „*der die Tool-Ebene entscheidet*" — dieselbe Formel
  führt [`AGENTS.md`](../../AGENTS.md) §3.7 §Geltungsbereich für das, was ein
  emittiertes Repo an Kommentar-Regeln bekommt, und der neue Checklisten-Punkt 20 ist
  genau eine solche Regel. Der Diff ändert die emittierte Fassung trotzdem; F-3 ist
  der Preis, den diese Hälfte bereits gekostet hat.
- `verifizierbar`: nein — kein Modul des Doku-Gates liest Commits oder
  Ebenen-Zuordnungen; §3.8 und §3.10 stellen dieselbe Lücke für sich selbst fest.
- `klasse`: Ebenen-Grenze im Implementations-Kontext überschritten

### F-6 — Der Rot-Nachweis, den der Plan für DoD (2) nennt, ist heute nicht herstellbar

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · Slice-Plan §2 DoD (2)
- `pfad`: `.github/workflows/ci.yml:18–33` · `harness/README.md:73`
- `befund`: DoD (2) nennt als Rot-Kommando: „*die Zuordnung selbst ist rot, wenn ein
  Job mit einem history-lesenden Schritt ohne `fetch-depth: 0` bleibt — genau der
  Fall, den Punkt (1) dann in CI sichtbar macht*". Punkt (1) hat in CI keinen
  Aufrufer: `grep -rn 'run:.*history-range-guard' .github/workflows/` → **0**, und
  `harness/README.md:73` sagt das selbst („*Heute steht der Wächter bereit, ohne einen
  Aufrufer zu haben*"). Damit steht die repo-weite Zuordnungs-Aussage in
  `ci.yml:18–33` — sieben Checkouts, keiner braucht Tiefe > 1 — allein im
  Feedforward-Quadranten, und der Diff benennt diese Wächter-Lücke für die *Zuordnung*
  nicht (nur die für den Wächter selbst).
- `verifizierbar`: ja — die Abwesenheit ist mit
  `grep -rn 'run:.*history-range-guard' .github/workflows/ | wc -l` → `0` messbar;
  ein Gate, das sie rot färbte, existiert nicht.
- `klasse`: Zusage ohne herstellbares Gegenbeispiel

### F-7 — Der OK-Zweig von `decide()` meldet Erfolg, wenn die Zahl-Auswertung fehlschlägt

- `kategorie`: LOW
- `quelle`: Maintainability · [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 3
- `pfad`: `harness/tools/history-range-guard.sh:75–83`
- `befund`: `[ "$count" -eq 0 ]` bricht bei nicht-numerischem `$count` mit
  Rückgabewert 2 ab; unter `set -e` in der `||`-Aufrufform wird die `if`-Bedingung
  damit als *falsch* gelesen und der positive Zweig läuft. Gemessen:
  `bash harness/tools/history-range-guard.sh --decide "HEAD..HEAD"` gibt
  „*[: : Ganzzahliger Ausdruck erwartet*" auf stderr aus, danach
  „*history-range-guard: Range 'HEAD..HEAD' aufgeloest,  Commit(s) — OK.*" und
  **Exit 0**. Der produktive Pfad ist davon nicht betroffen — `RANGE=` leer bricht über
  `${1:?…}` mit Exit 2 ab (gemessen), und `git rev-list --count` liefert bei Erfolg
  stets eine Zahl —; erreichbar ist der Zweig über den dokumentierten
  `--decide`-Eingang, den heute nur der bats-Fixture-Aufruf mit gültigen Ganzzahlen
  benutzt.
- `verifizierbar`: nein — die vier bats-Fälle übergeben ausschließlich gültige
  Ganzzahlen bzw. gar kein Argument; kein Fall in `test/mutations/` trifft den
  OK-Zweig.
- `klasse`: Positive Meldung im Fehlschlag-Zweig einer Auswertung

### F-8 — Plan §3 macht `AGENTS.md` §4 vom Ziel abhängig; das Ziel entstand, §4 blieb unberührt

- `kategorie`: LOW
- `quelle`: Slice-Plan §3 Plan-Tabelle (Zeile `Makefile`)
- `pfad`: `Makefile:163–164` · [`AGENTS.md`](../../AGENTS.md) §4
- `befund`: Die Plan-Tabelle führt „*das Ziel, das den Wächter fährt, falls er eines
  bekommt — dann zieht [`AGENTS.md`](../../AGENTS.md) §4 mit (öffentlicher Vertrag)*".
  Das Ziel existiert (`Makefile:163`, mit `##`-Hilfetext, also in `make help`
  sichtbar); [`AGENTS.md`](../../AGENTS.md) ist im Diff unberührt
  (`git diff --name-only f7400ba..2439519` nennt sie nicht), und weder die
  Ziel-Tabelle §4 noch ihre Nicht-Gate-Aufzählung (`smoke`, `full-smoke`, `mutate`,
  `span-report`, `hook-overhead`) nennen den neuen Namen. Der Diff trägt keine Aussage
  dazu, warum die im Plan gesetzte Bedingung nicht gezogen wurde.
- `verifizierbar`: nein — die `targets`-Achse ist in
  [`.d-check.yml`](../../.d-check.yml) nicht aktiviert (`modules: [links, anchors, ids,
  matrix, codepaths, spans]`).
- `klasse`: Im Plan gesetzte Folge-Bedingung nicht gezogen

### F-9 — DoD (2) ist mit der leeren Menge beantwortet; der Diff sagt nichts zur Rückführungs-Frage aus §4

- `kategorie`: INFO
- `quelle`: Slice-Plan §4 Rückführungen
- `pfad`: `.github/workflows/ci.yml:18–33` · `.github/workflows/release.yml:26–29` ·
  `.github/workflows/upstream-drift.yml:17–21`
- `befund`: Die Entscheidung zu DoD (2) lautet „*keiner der sieben Checkouts braucht
  Tiefe > 1*" und steht mit ihrer Messgrundlage im Diff selbst, nicht nur im
  Agenten-Bericht; jede darin genannte Größe ist nachgeprüft und trifft zu (7
  Checkouts repo-weit, 4 in `ci.yml`; vier Jobs `gates`/`smoke`/`full-smoke`/`mutate`;
  `.d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`;
  `doc-immutable`/`doc-commits` existieren in `d-check.mk` mit `--enable vcs` bzw.
  `--enable commits`; die emittierte `d-check.yml` führt `[links, anchors]`, also löst
  auch `make full-smoke` transitiv keinen history-lesenden Lauf aus). Zugleich trifft
  die Prämisse zu, die Slice-Plan §4 dem wahrscheinlichsten Rückweg
  (`in-progress → next`) unterlegt — „*noch kein history-lesender Schritt existiert*" —,
  und der Diff enthält keine Aussage dazu, warum die Rückführung nicht genommen wurde.
  Ob die leere Menge eine Entscheidung im Sinne von DoD (2) ist oder die Bedingung
  „*lässt sich nicht entscheiden*" erfüllt, ist eine Planner-Frage; hier steht nur der
  beobachtbare Befund.
- `verifizierbar`: nein — eine Lifecycle-Rückführung liest kein Gate.
- `klasse`: Rückführungs-Bedingung des Plans ohne Aussage im Diff

## Negativbefunde

- geprüft, ohne Befund: **Die Kommentare in `.github/workflows/{ci,release,upstream-drift}.yml`
  und im `Makefile`** gegen [`AGENTS.md`](../../AGENTS.md) §3.7 — die drei Korrekturrunden
  haben dort getragen. `git diff f7400ba..2439519 -- <die vier Dateien> | grep '^+' |
  grep -E 'slice-[0-9]|Slice-Plan|DoD|waere|bliebe|muesste|haette|frueher|entschieden'`
  liefert **keine** Treffer; alle Sätze stehen im Indikativ über den Ist-Zustand und
  richten sich an den, der die Stelle ändert. Der Rest der Klasse steht in F-1.
- geprüft, ohne Befund: **Wahrheitsgehalt jeder Aussage in den Workflow-Köpfen** —
  vier Checkouts in `ci.yml`, zwei in `release.yml`, einer in `upstream-drift.yml`,
  repo-weit sieben (`grep -h 'uses: actions/checkout' .github/workflows/*.yml | wc -l`
  → 7); vier Jobs `gates`/`smoke`/`full-smoke`/`mutate`; `.d-check.yml` aktiviert genau
  `links, anchors, ids, matrix, codepaths, spans`; `doc-immutable`/`doc-commits`
  existieren in `d-check.mk` (`grep -nE '^doc-[a-z-]+:' d-check.mk`) und fahren
  `--enable vcs` bzw. `--enable commits`.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.8 (Architect-Eigentum)** —
  weder `AGENTS.md` noch [`harness/conventions.md`](../../harness/conventions.md) noch
  eine Datei unter `harness/conventions/` ist im Diff
  (`git diff --name-only f7400ba..2439519`, 10 Dateien). Der Plan §3 machte eine
  Übergabe davon abhängig, ob der Slice
  [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
  berührt; dessen Text trifft keine Aussage über Checkout-Tiefe oder Historie
  (`grep -nE 'Tiefe|depth|Historie' harness/conventions/MR-014-*.md` findet nur die
  Pin-Nachträge zu `actions/checkout`-Versionen), eine Übergabe war also nicht fällig.
- geprüft, ohne Befund: **Kollision mit
  [`slice-190`](../plan/planning/open/slice-190-bootstrap-legt-die-versprochenen-orte-an.md)** —
  der offene Slice arbeitet an `internal/emit/templates.go` (`structureGitkeeps`),
  dessen `want`-Liste und der emittierten `harness/conventions.md`; keine dieser
  Dateien liegt im Diff. Seine Mess-Grundlage bleibt unberührt: die drei emittierten
  Commands nennen `docs/plan/planning/observations/` vor **und** nach dem Diff je
  genau einmal (`git grep -c 'docs/plan/planning/observations/' <ref> --
  'internal/emit/templates/commands/*.md'` für `f7400ba` und `2439519` → identisch,
  drei Dateien mit je 1). Der Wert **3** aus der Fundstellen-Tabelle von `slice-190` §1
  gilt unverändert.
- geprüft, ohne Befund: **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (kein halluziniertes Gate)** — `gates: record-gates` im `Makefile` ist unverändert,
  `history-range-guard` steht in keiner Prerequisite-Kette, und die neue
  `harness/README.md`-Passage sagt „*kein Gate, in keiner Prerequisite-Kette*". Die
  Sensor-Tabelle in `harness/README.md` §Sensors ist folgerichtig nicht erweitert —
  dieselbe Behandlung wie `slice-mv`, `archive-welle`, `span-report`, `hook-overhead`.
- geprüft, ohne Befund: **Der BELEG-Transkript im Skriptkopf reproduziert.** In einem
  echten Klon (`git clone --depth 1 file:///Development/KI/ai-harness-init <klon>`,
  `git log --oneline | wc -l` → 1) liefert `bash harness/tools/history-range-guard.sh
  HEAD..HEAD` Exit **1** mit den vier zugesagten Zeilen und
  `… HEAD~1..HEAD` Exit **2** — zeichengleich mit `history-range-guard.sh:32–50`.
  Der Inhalt des Belegs stimmt; beanstandet ist in F-1 seine Form, nicht seine
  Wahrheit.
- geprüft, ohne Befund: **Der Mutations-Zahn trifft die Stelle, die der Aufrufer
  benutzt** ([`AGENTS.md`](../../AGENTS.md) §3.6). `sed -i 's/count" -eq 0/count" -eq
  1/'` trifft genau eine Zeile (`grep -c 'count" -eq 0'` → 1), und zwar in `decide()`,
  das **beide** Eingänge (`--decide` und der volle Lauf) durchlaufen. Über der
  mutierten Kopie liefert `--decide "HEAD..HEAD" 0` Exit **0** statt 1 und die Ausgabe
  „*aufgeloest, 0 Commit(s) — OK*" — der bats-Fall 119 wird damit rot. Die
  `# expect:`-Zeile trägt keinen `Test[A-Z]`-Präfix, `narrow_sensor()` wählt also die
  bats-Stufe, deren Fehlschlag-Form `not ok [0-9]+` den Fall fängt.
- geprüft, ohne Befund: **Alle in neuen Kommentaren genannten Nachbar-Artefakte
  existieren** — `test/component-freshness.bats`, `harness/tools/component-freshness.sh`,
  `harness/tools/slice-mv.sh` samt seinem zitierten Abschnitt `ZUSAGE`
  (`grep -c '^# ZUSAGE'` → 1), `test/history-range-guard.bats`.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.9 (Docker-only)** — das neue
  Rezept fährt `bash` und `git` auf dem Host, beides in §3.9 ausdrücklich als
  Host-Voraussetzung geführt; kein Paketmanager und keine Sprach-Toolchain in
  Befehlsposition. Dieselbe Bauart wie `comment-claims` („hermetisch: bash+awk",
  [`AGENTS.md`](../../AGENTS.md) §4) und `slice-mv`.
- geprüft, ohne Befund: **[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)**
  — die einzige im Diff berührte Datei in seinem Geltungsbereich (lebende, repo-eigene
  Markdown-Artefakte) ist `harness/README.md`; ihre neue Passage führt keine Messzahl
  über den Repo-Bestand, sondern Werkzeug-Voreinstellungen und zitierte Ausgaben. Die
  Zahlen in den YAML- und `Makefile`-Kommentaren liegen außerhalb des Geltungsbereichs
  und sind dennoch geprüft (Negativbefund 2).
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.3 (Move und Inhalt getrennt)**
  — der Diff bewegt keine Datei; `git diff --stat` weist ausschließlich Änderungen und
  vier Neuanlagen aus.
- geprüft, ohne Befund: **Numerierung der Pre-completion-Checkliste** — beide Fassungen
  laufen lückenlos 1…25 (`grep -nE '^[0-9]+\. ' <datei>` → 25 Einträge, Werte 1–25 ohne
  Sprung). Beanstandet ist in F-3 nicht die Liste, sondern der Querverweis auf sie.
- geprüft, ohne Befund: **Gate-Läufe über diesem Stand** —
  `make shell-lint` EXIT 0 (deckt `harness/tools/*.sh` und `test/mutations/*.sh`),
  `make ci-lint` EXIT 0, `make comment-claims` → `56 Datei(en) geprueft, 0 Befund(e)`,
  `make docs-check` → `836 Datei(en) geprüft, 0 Befund(e)`, `make test-bats` → die vier
  neuen Fälle 119–122 grün. Diese Zeile ist **kein** Verifikations-Beleg: die
  DoD-Bestätigung führt der Verifier in getrenntem Kontext (Modul 11).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 5 |
| LOW | 2 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Kommentar nennt den Vorgang seiner Entstehung statt
der Stelle · Zähler-Label nennt falsche Einheit · Korrektur an einem Vorkommen statt an
der Fundmenge · Zusage greift weiter als Abdeckung · Ebenen-Grenze im
Implementations-Kontext überschritten · Zusage ohne herstellbares Gegenbeispiel ·
Positive Meldung im Fehlschlag-Zweig einer Auswertung · Im Plan gesetzte
Folge-Bedingung nicht gezogen · Rückführungs-Bedingung des Plans ohne Aussage im Diff

**Drei dieser Klassen führt das Beobachtungs-Register bereits, und eine erreicht mit
diesem Lauf die Schwelle.** Der Zähler ist die Zahl der Evidence-Dateien und steht
neben seinem Kommando
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, gemessen am
2026-09-06, **keine Erwartungswerte**):

| Kennung | Zähler heute | Finding | Stand nach Eintrag |
|---|---|---|---|
| `BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` | 1 | F-1 | 2 |
| `BEO-ALL/zaehler-label-nennt-falsche-einheit` | 2 | F-2 | **3 — Schwelle** |
| `BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel` | 1 | F-6 | 2 |

Die drei Bezeichnungen oben sind die des Registers und nicht neu formuliert: eine
Umformulierung spaltet die Klasse in zwei Pfade, und keiner erreicht dann je 3×
(Modul 6 §Das Beobachtungs-Register). Für `zaehler-label-nennt-falsche-einheit` trägt
der Lese-Schritt der Closure die Folge — bei 3× ist der Eintrag keine Notiz mehr,
sondern eine Lücke mit eigenem Ausgang.

## Verdikt

**Merge-blockierend:** ja — ein HIGH und fünf MEDIUM.

F-1 ist ein Verstoß gegen eine Hard Rule an sechs neu geschriebenen Stellen und
zugleich die Klasse, die der Implementer während des Laufs bereits dreimal korrigieren
musste; sie ist in den Workflows und im `Makefile` geschlossen und in den drei neuen
Dateien unter `harness/tools/` und `test/` offen geblieben. Der **Bestand** ist davon
nicht berührt — `AGENTS.md` §3.7 §Cutoff bindet nur den Kommentar, der geschrieben oder
geändert wird; die formgleiche Stelle in `harness/tools/slice-mv.sh` ist deshalb
ausdrücklich **kein** Finding dieses Reports.

F-5 berührt eine Rollen- und Ebenen-Grenze und ist damit kein reiner
Implementations-Befund: Die lokale Hälfte der `implement-slice.md`-Änderung deckt
[`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Festlegung 1, die emittierte nimmt dieselbe ADR ausdrücklich aus. Wird dem
widersprochen, läuft der Vorgang nicht über eine Herabstufung, sondern über den
Konflikt-Pfad aus Modul 8 (Sequenz mit Übergabe-Artefakten, Verdikt des Architect als
Artefakt).

F-9 ist bewusst INFO und kein Blocker: Die Frage, ob DoD (2) mit der leeren Menge
beantwortet ist oder die Rückführungs-Bedingung aus Slice-Plan §4 erfüllt war, gehört
dem Planner und nicht diesem Report.

**Übergabe:** Findings gehen an den Implementer (Rückkante
Review → Plan bei Plan-Defekt); die **Finding-Klassen** gehen zusätzlich
in die Slice-Closure §7 und von dort in den Zähler. Dieser Report selbst
ist ein **Lauf-Beleg** (Audit: dieser Diff, dieser Skill, dieses Modell,
dieses Verdikt) — er wird über Läufe hinweg nicht wieder gelesen, und
muss es nicht. Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
