# Review-Report: slice-050 (Runde 5) — 2026-07-26

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Review-Art** | Code-Review (Modul 10) — fertiger Diff gegen Plan, Spec, Hard Rules |
| **Gegenstand** | `7314b7c` · `85e3c26` · der reale Release-Text von `v0.1.0` (`gh release view v0.1.0 --json body`) |
| **Skill-Version** | [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) 1.4.0 |
| **Baseline** | Agents-Regelwerk v3.5.2, [`modul-10-review-harness.md`](../../.harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md) |
| **Modell** | Claude Opus 5 (1M context) |
| **Runde** | 5 — Runden 1–4 je NICHT KONFORM; Runde 4: 0 HIGH, 1 MEDIUM (S-1), 3 LOW (S-2/S-3/S-4) |
| **Kontext frisch** | ja — kein Kontext aus den Runden 1–4 übernommen; alle Aussagen unten sind in dieser Sitzung neu gemessen |

### Eingangs-Kontext (die fünf v3.5.2-Pflicht-Punkte + Slice-Plan)

| Pflicht-Punkt | Bezug |
|---|---|
| **Diff/Commit-Range** | `3780d21..85e3c26` (zwei Commits) **plus** ein git-externes Artefakt: der publizierte Release-Text von `v0.1.0`. Alles vor `3780d21` ist in den Runden 1–4 geprüft und hier **nicht** erneut aufgerollt. |
| **Betroffene `LH-*`** | [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Plattform-Matrix, §7 Historie 0.14.0/0.14.1), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Zusage ohne deckenden Lauf) |
| **Referenzierte aktive ADRs** | keine — beide Commits nennen keine ADR-ID; kein Go-Code, kein Gate, kein Workflow berührt |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.6 („Keine Zusage ohne rot gesehenes Gegenbeispiel"; „DoD-Punkt" und „Commit-Message" sind dort ausdrücklich Zusage-Träger) |
| **Vorherige Findings am gleichen Modul** | Runde 4 S-1/S-2/S-3/S-4 ([`2026-07-26-slice-050-impl-review-runde-4.md`](2026-07-26-slice-050-impl-review-runde-4.md)) inkl. Implementations-Nachtrag |
| **Slice-Plan** (Repo-Ergänzung) | [`slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md) |
| Konventions-Anker | [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) (Change Request bei Personalunion), [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) |

**Messumgebung.** `HEAD` = `85e3c26`; `origin/main` lokal = `3780d21`; `git ls-remote origin refs/heads/main`
= `3780d217f8054a7cafedefbe48b1a39c75a1462f` — die lokale Remote-Referenz ist mit dem realen Remote
**identisch**, die unten gefahrenen `origin/main`-Befehle liefern also, was ein externer Leser sieht.
`git ls-remote origin refs/tags/v0.1.0` = `7bbb88b…` (annotiertes Tag auf `0c31697`).

---

## (A) Status der Runde-4-Findings

### S-1 (MEDIUM) — Release-Text spricht die Installationsschritte frei · **behoben**

Der beanstandete Satz („**Die sechs Binaries sind davon nicht betroffen**, ebenso wenig die Download-
und Installationsschritte selbst") existiert **nicht mehr**. Die Freispruch-Konstruktion ist ersatzlos
weg; an ihre Stelle tritt eine andere Bauform. Der aktuelle Text (16 Zeilen, `--json body`) wurde
Satz für Satz gemessen:

| Aussage im aktuellen Release-Text | Eigene Messung | Urteil |
|---|---|---|
| „vorgefertigte Programme für sechs Plattformen (Linux · macOS · Windows × amd64 · arm64)" | `gh release view v0.1.0 --json assets` → **sechs** Assets, Namen zeichengleich mit der `matrix.include`-Liste in [`release.yml`](../../.github/workflows/release.yml):69–80 | **trifft zu** |
| „Der vollständige Durchlauf (Repo aufsetzen, Prüfungen grün) läuft auf **linux/amd64**." | [`ci.yml`](../../.github/workflows/ci.yml):58–62 — Job `full-smoke`, **ein** Job, `runs-on: ubuntu-24.04`, keine Matrix | **trifft zu** |
| „Für alle sechs ausgelieferten Dateien ist geprüft, dass das Programm auf seiner Plattform **startet** — mehr nicht." | `gh run view 30193450074 --json jobs` (der `push`-Lauf auf `v0.1.0`) → **acht** Jobs, **alle `success`**, darunter sechs `start-smoke`-Jobs, je einer pro Binary; `publish` lädt genau das Artefakt hoch, das die sechs geprüft haben ([`release.yml`](../../.github/workflows/release.yml):113–116) | **trifft zu** |
| „Die sechs Binaries sind das Produkt dieses Release und von allem Folgenden nicht betroffen." | sechs Assets (s. o.); `git diff --stat v0.1.0 origin/main` → **acht Dateien, ausschließlich `.md`** — kein Go-Code, kein Workflow, kein Makefile | **trifft zu** |
| „die FAQ antwortet noch „Gibt es ein fertiges Download-Binary? — Derzeit nicht"" | `git show v0.1.0:docs/user/benutzerhandbuch.md` → „**Derzeit nicht.** Sie bauen das Programm einmalig aus dem Quellcode…" | **wörtlich getroffen** |
| „der Anhang sagt „keine Release-Versionsnummer"" | im Tag: „(daher **keine Release-Versionsnummer** — maßgeblich ist der Quellcode-Stand des Repos)" | **wörtlich getroffen** |
| „der Kasten im Installations-Abschnitt sagt den vollständigen Durchlauf „bei jedem Release auf Linux" zu" | im Tag: „wird **bei jedem Release** auf **Linux** gefahren"; der Kasten steht unter `### Systemanforderungen` **innerhalb** von `## 2. Installation und Zugriff` (Heading-Liste des getaggten Handbuchs: 53 → 55 → 67) | **wörtlich getroffen, Ortsangabe korrekt** |
| „(real: pro Quellcode-Änderung, nur linux/amd64 — siehe oben)" | [`ci.yml`](../../.github/workflows/ci.yml):20–26 — `on: push` **und** `pull_request`, **kein** `paths`-Filter; der Job läuft also mindestens bei jeder Quellcode-Änderung | **trifft zu** |
| „im Download-Weg fehlt ein `mkdir -p` vor dem `mv` nach `~/.local/bin`" | im Tag: `chmod +x …` direkt gefolgt von `mv … ~/.local/bin/ai-harness-init`, dazwischen nichts | **trifft zu** |
| „während das Ergebnis die Aufrufbarkeit unbedingt zusagt" | im Tag: „Das Programm ist unter dem kurzen Namen `ai-harness-init` aufrufbar." — ohne Bedingung | **trifft zu** |

**Die Entlastungs-Aussage über die sechs Binaries ist belegt**, nicht behauptet: sechs Assets gezählt,
sechs `start-smoke`-Jobs grün, und der gesamte Delta `v0.1.0 → origin/main` besteht aus `.md`-Dateien.
**Damit ist das Failure-Szenario von S-1 geschlossen:** kein Satz des Textes spricht die
Installationsschritte mehr frei — im Gegenteil, der fehlende `mkdir -p` und die unbedingte
Ergebnis-Zusage sind jetzt **namentlich als Abweichung genannt**. Ein Adopter, der dem getaggten §2
Weg A folgt, ist vorgewarnt.

Zur Bauform (Prüfpunkt (i) des Auftrags): der Befehl
`git diff v0.1.0 origin/main -- docs/user/benutzerhandbuch.md README.md` wurde **real gefahren** und
liefert einen nicht-leeren Diff (README-Gate-Zeile + sieben Stellen im Handbuch), also genau das, was
der Text behauptet. `origin/main` ist für einen externen Leser auflösbar: `git clone` legt die
Remote-Tracking-Referenz `origin/main` und (per Default) auch das Tag `v0.1.0` an — beide Enden des
Diffs existieren ohne Zusatzschritt. **Restrisiko, unten als T-3 geführt:** der Befehl ist auf zwei
Dateien verengt, der Satz darüber ist es nicht.

**Status: behoben (MEDIUM aufgelöst).**

### S-2 (LOW) — DoD-Punkt zählt die Lastenheft-Commits falsch · **im Kern behoben, zwei Restdefekte** → T-1, T-2

Der DoD-Punkt ([`slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md):45–53) nennt **keine Zahl** mehr. Er trägt jetzt eine
Regel plus den Messbefehl. **Selbst gefahren** (Prüfpunkt (B)):

```
$ git log --format=%h --no-merges 63236d3..321b849 -- spec/lastenheft.md
$ … | wc -l
0
```

**0 Zeilen** — der Befehl im Artefakt und sein zugesagtes Ergebnis stimmen überein. Das
Failure-Szenario von S-2 (drei Artefakte, drei Zählungen) ist geschlossen: es gibt keine Zählung mehr,
die veralten könnte. **Zwei Restdefekte** an derselben Zeile bleiben und werden unten als **T-1** und
**T-2** neu geführt — beide betreffen nicht die Zahl, sondern den Satz, der die Range einordnet.

**Status: im Kern behoben; Restdefekte als neue LOW-Findings.**

### S-3 (LOW) — Begründung der Patch-Stufe `0.14.1` trennt nicht · **behoben**

Die Zeile ([`spec/lastenheft.md`](../../spec/lastenheft.md):326) trägt jetzt beide von S-3 vermissten Elemente:

| Anforderung aus S-3 | Aktueller Wortlaut | Messung | Urteil |
|---|---|---|---|
| Das Kriterium muss **von `0.13.0`/`0.14.0` trennen** | „0.13.0 und 0.14.0 änderten je die **Messmethode** … diese Zeile ändert weder die Anforderung noch die Messmethode" | `git show 30f0fcd -- spec/lastenheft.md` und `git show 5c4930b` ändern beide die **Messmethode**-Aufzählung von [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix); `git show 614351e -- spec/lastenheft.md` fasst die Messmethode-Punkte **nicht** an, sondern nur den zweiten Punkt unter „Grenze der Messmethode" ([`spec/lastenheft.md`](../../spec/lastenheft.md):277–289) | **sachlich haltbar** — das genannte Unterscheidungsmerkmal ist real |
| Die Begründung der `X.Y.0`-Abweichung muss **in der Zeile** stehen | „Sie ist damit die erste Zeile ohne `X.Y.0`; die Abweichung steht bewusst hier statt in einer Konvention…" | alle 15 Historie-Zeilen gezählt ([`spec/lastenheft.md`](../../spec/lastenheft.md):312–326): `0.1.0`…`0.14.0` sind **ausnahmslos** `X.Y.0`, `0.14.1` ist die erste Abweichung | **trifft zu, und steht jetzt in der Zeile** |

Die frühere, an der eigenen Fußabdruck-Sprache falsche Klammer („keine Anforderungs-ID berührt") ist
**ersetzt**, nicht nur ergänzt. Das Failure-Szenario von S-3 (der nächste Autor kann Patch/Minor nicht
ableiten) ist im Kern geschlossen; eine verbliebene Unschärfe im Nachsatz ist unten als **INFO-1**
geführt, weil sie das Kriterium nicht umkehrt.

**Status: behoben.**

### S-4 (LOW) — Historie-Zeile `0.14.0` führt die zurückgenommene Auflösung im Präsens · **behoben**

Der beanstandete Halbsatz („und **nennt ihre Auflösung** (Voll-Smoke zusätzlich auf einem
Linux-ARM-Runner fahren)") steht **nicht mehr** in [`spec/lastenheft.md`](../../spec/lastenheft.md):325. Gegenprobe über die ganze
Datei: `grep -n "nennt ihre Auflösung"` → keine Treffer; die Zeichenkette „Voll-Smoke zusätzlich auf
einem Linux-ARM-Runner" kommt nur noch in der Rücknahme-Klammer vor, und dort im **Präteritum** mit
explizitem Rücknahme-Vermerk („war ungemessen und ist in 0.14.1 zurückgenommen"). Die Zeile beschreibt
damit ihren eigenen Stand, ohne eine zurückgenommene Aussage affirmativ zu führen. **Das
Failure-Szenario von S-4** (jemand schneidet den `ubuntu-24.04-arm`-Slice, der Lauf bricht in
`docs-check` ab) ist geschlossen: die Klammer sagt ausdrücklich, dass der Satz ungemessen war.

Ein Nebeneffekt der Formulierung ist unten als **T-4** geführt.

**Status: behoben.**

---

## (B) `7314b7c` gegen [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2

| Kriterium (Wortlaut MR-015 Setzung 2) | Messung | Urteil |
|---|---|---|
| „in einem **eigenen Commit**" | `git show --stat 7314b7c` → `spec/lastenheft.md \| 4 ++--`, **eine** Datei | **erfüllt** |
| „der **ausschließlich** `spec/lastenheft.md` ändert" | genau diese eine Datei, `1 file changed, 2 insertions(+), 2 deletions(-)` | **erfüllt** |
| „und **vor** dem `open → in-progress`-Move des umsetzenden Slice liegt" | ein *umsetzender* Slice existiert nicht — der Commit präzisiert zwei Historie-Zeilen und beauftragt nichts | **leer erfüllt** (kein Bezugsobjekt), wie schon bei `614351e` in Runde 4 |
| „mechanisch beantwortbar: `git log -- spec/lastenheft.md` + `git show --stat`" | genau so gemessen | **erfüllt** |
| Geltung **auch für rein redaktionelle** Änderungen (MR-015 §„Was der Ist-Stand trotzdem belegt": „`c615da7`/`7b717f4` sind der Beleg, dass genau die das Signal verwischen") | `7314b7c` ist redaktionell **und** ein eigener Ein-Datei-Commit — genau die Disziplin, die MR-015 dafür verlangt | **erfüllt** |
| Setzung 3 (Spalten-Zuordnung) nach dem Edit weiterhin gewahrt | `0.14.0` endet auf „Anlass: slice-050-Review N-2 \| Nutzer-Entscheidung 2026-07-26"; `0.14.1` auf „Anlass: slice-050-Review Runde 3, R-1/R-3 \| Nutzer-Entscheidung 2026-07-26" | **konform, unverändert** |

**`MR-015` Setzung 2 ist gewahrt.** Eine Anschluss-Beobachtung zur Versions-Stufe steht als
**INFO-2**.

---

## (C) Neue Findings

Sortiert nach Kategorie (Modul 10: „HIGH zuerst, immer" — hier gibt es keine).

### T-1 — Der DoD-Satz behauptet über **alle** Lastenheft-Commits etwas, das [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) selbst widerlegt

- `kategorie`: **LOW**
- `quelle`: Hard Rule [`AGENTS.md`](../../AGENTS.md) §3.6 (der „DoD-Punkt" ist dort ausdrücklich Zusage-Träger) ·
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Ist-Messung
- `pfad`: [`slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md):47–49
- `befund`: Der Satz lautet „**jeder** Commit, der `spec/lastenheft.md` ändert, liegt **außerhalb**
  dieser Range — es sind Nutzer-Entscheidungen (Change Requests) bzw. deren Korrekturen, **keine
  Slice-Commits**". Der zweite Teil ist als Allquantor formuliert und ist falsch:
  `git log --oneline --no-merges -- spec/lastenheft.md` liefert **19** Commits, darunter
  **`7b717f4` „fix(build,ci): slice-048 Review- und Verifier-Findings aufgeloest"** — ein
  Slice-Commit, der `spec/lastenheft.md` ändert (`git diff 7b717f4^ 7b717f4 -- spec/lastenheft.md`:
  Zeilenreihenfolge `0.12.0`/`0.13.0`, `1 file changed, 1 insertion(+), 1 deletion(-)`). Genau dieser
  Commit ist in [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Ist-Messung **namentlich** als „rein redaktionelle Berührung" und
  als eine der „beiden slice-nahen Berührungen" geführt — die zitierte Konvention widerlegt den Satz,
  der sie zitiert. Der beigestellte Messbefehl misst diesen Allquantor **nicht**: er misst die
  Leerheit der Range (`63236d3..321b849`), also eine andere Aussage.
- `verifizierbar`: **ja, statisch** — `git log --oneline --no-merges -- spec/lastenheft.md` plus
  `git show --stat 7b717f4` gegen den Wortlaut der Zeile. **Kein Gate deckt es**;
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Durchsetzung sagt selbst, die Regel lebe „allein im
  **inferential-feedforward**-Quadranten".
- **Failure-Szenario (konkret).** Der nächste Reviewer oder Verifier braucht die Antwort auf „hat je
  ein Slice-Commit das Lastenheft angefasst?" — die Frage, für die [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 überhaupt
  existiert. Er findet sie im DoD-Punkt beantwortet („keine Slice-Commits"), fährt den dort
  angebotenen Befehl, bekommt 0 Zeilen und hält die Aussage für gemessen. Tatsächlich hat er nur die
  Leerheit einer fünf Commits langen Range bestätigt; `7b717f4` liegt außerhalb und bleibt unentdeckt.
  Er trägt die falsche Aussage in die Closure-Notiz — und der Cutoff-Absatz von
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) („ein Sensor, der die Historie mitprüfte, wäre dauerhaft rot, 10 von 16"),
  der genau von diesen Alt-Berührungen handelt, wird unlesbar.

### T-2 — Die Range ist als „die Commits DIESES Slice" beschriftet, enthält aber zwei Slice-Commits nicht mehr

- `kategorie`: **LOW**
- `quelle`: Hard Rule [`AGENTS.md`](../../AGENTS.md) §3.6 · Skill-Anker LOW („latente Wartungsfalle, hart verdrahteter Wert")
- `pfad`: [`slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md):45–46
- `befund`: Der Punkt setzt „**die Commits DIESES Slice**" mit `63236d3..321b849` gleich. Diese Range
  enthält fünf Commits (`git log --oneline 63236d3..321b849`: `813418c`, `38b60ed`, `0c31697`,
  `a4dac1f`, `321b849`). Der Slice hat seither **drei weitere** Commits bekommen — `3780d21`,
  `85e3c26` (beide ausdrücklich slice-050-Arbeit) sowie den noch ausstehenden Closure-Commit —, die
  alle außerhalb liegen. Der Fix von S-2 hat die **Zahl** entfernt, weil sie „konstruktionsbedingt
  veraltet", das **eingefrorene Range-Ende** aber stehen gelassen; es veraltet aus demselben Grund
  und mit derselben Geschwindigkeit.
- `verifizierbar`: **ja, statisch** — `git log --oneline 63236d3..HEAD` (acht Commits) gegen
  `git log --oneline 63236d3..321b849` (fünf) und gegen die Beschriftung der Zeile. Kein Gate deckt es.
- **Failure-Szenario (konkret).** Der Closure-Commit dieses Slice fasst `spec/lastenheft.md` an — sei
  es nur, um einen Link oder eine Historie-Zeile nachzuziehen, also genau die Klasse, die `c615da7`
  und `7b717f4` bereits zweimal erzeugt haben. Die Verifikation hakt den DoD-Punkt ab, indem sie den
  dort hinterlegten Befehl fährt: er endet weiter mit 0 Zeilen, weil er bei `321b849` aufhört. Der
  Punkt ist grün, während die Eigenschaft, die er zusagt („`spec/lastenheft.md` unberührt über die
  Commits dieses Slice"), gebrochen ist — und der Bruch ist genau der Fall, für den
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 gebaut wurde.

### T-3 — Der Messbefehl im Release-Text ist auf zwei Dateien verengt, der Satz darüber nicht — und die dritte Datei widerspricht dem Release-Text

- `kategorie`: **LOW**
- `quelle`: Hard Rule [`AGENTS.md`](../../AGENTS.md) §3.6 („die Zusage auf das einschränken, was … hält") ·
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) · Skill-Anker LOW („Doku-Drift")
- `pfad`: `gh release view v0.1.0 --json body`, Absatz 4 (Zeilen 7–11 des Body)
- `befund`: Der Absatz trägt die unrestringierte Aussage „**Die mitgelieferte Dokumentation dieses
  Tags** ist an mehreren Stellen überholt" und bietet dann „statt einer Aufzählung, die selbst wieder
  unvollständig sein kann" den Befehl
  `git diff v0.1.0 origin/main -- docs/user/benutzerhandbuch.md README.md`. Der Befehl trägt seine
  eigene Aufzählung — die Pathspec. `git diff --stat v0.1.0 origin/main` zeigt neben den beiden
  genannten Dateien eine dritte inhaltlich betroffene: **`spec/lastenheft.md`, 23 Zeilen**. Im Tag
  steht dort ([`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix), Version 0.13.0) „**linux:** **Voll-Smoke**" und „**macos ·
  windows:** **Start-Smoke**" — also die Zusage eines Voll-Smokes auch für `linux/arm64`, die der
  Release-Text in seinem eigenen zweiten Absatz korrigiert („läuft auf **linux/amd64**"). Der
  angebotene Befehl macht genau diesen Widerspruch **nicht** sichtbar.
- `verifizierbar`: **ja, statisch** — `git diff --stat v0.1.0 origin/main` gegen die Pathspec im
  Release-Body; `git show v0.1.0:spec/lastenheft.md` gegen Absatz 2 des Body. **Kein Gate deckt es:**
  `make docs-check` sieht nur den Arbeitsbaum, nie einen Tag und nie einen Release-Text (eigener Lauf
  unten: grün).
- **Failure-Szenario (konkret).** Ein Adopter lädt `ai-harness-init-linux-arm64` und will wissen,
  worauf die Plattform-Zusage vertraglich beruht. Er entnimmt dem Release-Text, dass die
  mitgelieferte Doku überholt sein kann, fährt den dort angebotenen Befehl, sieht Abweichungen nur in
  Handbuch und README — und liest daraufhin die **Anforderung** im getaggten
  `spec/lastenheft.md` als aktuell. Dort steht, `linux` bekomme den Voll-Smoke. Er schließt daraus,
  dass sein arm64-Binary vollständig durchgeprüft ist, obwohl für es nur der Start belegt ist. Das ist
  dieselbe Verwechslung, gegen die die `0.14.0`-Präzisierung eingeführt wurde — nur eine Ebene weiter
  außen, im veröffentlichten Artefakt.

### T-4 — Die `0.14.0`-Zeile sagt „wird nicht umgeschrieben" in dem Commit, der sie umschreibt

- `kategorie`: **LOW**
- `quelle`: [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §„Die bestehenden 13 Zeilen werden NICHT umgeschrieben" ·
  Hard Rule [`AGENTS.md`](../../AGENTS.md) §3.6 · Skill-Anker LOW („Doku-Drift")
- `pfad`: [`spec/lastenheft.md`](../../spec/lastenheft.md):325, Kursiv-Klammer am Zeilenende
- `befund`: Die Klammer schließt mit „*Diese Zeile beschreibt den Stand von 0.14.0 und **wird nicht
  umgeschrieben**.*" — eingefügt von `7314b7c`, das dieselbe Zeile umschreibt: der Halbsatz „und nennt
  ihre Auflösung (Voll-Smoke zusätzlich auf einem Linux-ARM-Runner fahren)" ist **gelöscht**
  (`git show 7314b7c -- spec/lastenheft.md`, `2 insertions(+), 2 deletions(-)`). Die Selbstaussage der
  Zeile ist damit an ihrer eigenen Commit-Historie messbar unzutreffend. Inhaltlich ist der Vorgang
  korrekt (der Sachverhalt bleibt erhalten, nur ins Präteritum verschoben) — die **Formel** ist es
  nicht.
- `verifizierbar`: **ja, statisch** — `git show 7314b7c -- spec/lastenheft.md` gegen den Wortlaut
  der eingefügten Klammer. Kein Gate deckt es.
- **Failure-Szenario (konkret).** Der nächste Fall dieser Klasse tritt ein: eine Historie-Zeile trägt
  eine Aussage, die später zurückgenommen wird. Der Autor sucht Präzedenz, findet `0.14.0` und liest
  dort, Historie-Zeilen würden „nicht umgeschrieben". Er lässt die falsche Aussage stehen und ergänzt
  nur eine neue Zeile darunter — und reproduziert damit **exakt** den Zustand, den S-4 beanstandet hat
  und den `7314b7c` beseitigen sollte. Die Zeile, die die Lehre trägt, gibt die gegenteilige Anweisung.

### INFO-1 — „sie fügt nichts hinzu" ist auf Vertragsebene wahr und auf Textebene messbar anders

- `kategorie`: **INFO**
- `quelle`: [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Fußabdruck
- `pfad`: [`spec/lastenheft.md`](../../spec/lastenheft.md):326
- `befund`: Das Patch-Kriterium endet auf „nimmt eine falsche Tatsachen-Aussage in einer erläuternden
  Grenz-Notiz zurück — **sie fügt nichts hinzu**". `git show --stat 614351e` meldet
  `9 insertions(+), 5 deletions(-)`; die Notiz erhält sechs neue Zeilen mit einem **neuen gemessenen
  Befund** (Single-Arch-Manifest, `gates`-Prerequisite). Auf **Vertragsebene** — der Ebene, auf der der
  ganze Satz argumentiert („ändert weder die Anforderung noch die Messmethode") — ist die Aussage
  korrekt: die Ergänzung weist ausdrücklich als „offen und **nicht zugesagt**" aus, sagt also nichts
  zu. Die Ebenen-Bindung steht aber nur implizit. **Kein Finding**, weil die dominante Lesart trägt
  und das Kriterium in seiner trennenden Hälfte (Messmethode ja/nein) unberührt bleibt; notiert, weil
  ein Nachnutzer, der `git show --stat` daneben legt, eine Erklärung braucht.
- `verifizierbar`: **ja, statisch** — `git show --stat 614351e`.

### INFO-2 — `7314b7c` bumpt die Lastenheft-Version nicht; die Abgrenzung steht nur in der Commit-Message

- `kategorie`: **INFO**
- `quelle`: [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Fußabdruck („ein Version-Bump des Lastenhefts, eine Zeile in dessen `## Historie` …")
- `pfad`: `git show --stat 7314b7c` · [`spec/lastenheft.md`](../../spec/lastenheft.md):3
- `befund`: `7314b7c` ändert `spec/lastenheft.md`, lässt aber `**Version:** 0.14.1` stehen und legt
  keine Historie-Zeile an — es deklariert sich damit mechanisch als **Nicht-CR**, was der Sache
  entspricht (nur `## Historie`-Prosa, und `## Historie` ist per
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) sogar aus der `matrix`-Prüfung ausgenommen). Zugleich passt die
  Änderungs-Art wörtlich auf das Kriterium, das `0.14.1` zwei Zeilen tiefer für die **Patch**-Stufe
  formuliert („nimmt eine falsche Tatsachen-Aussage in einer erläuternden … Notiz zurück"). Was die
  beiden Fälle trennt — normativer `LH-*`-Text gegenüber chronologischer Historie-Prosa — steht
  ausschließlich in der Commit-Message („Weder Anforderung noch Messmethode berührt … die
  Versions-Stufe bleibt 0.14.1"), nicht im Dokument. **Kein Finding:** die Setzung, die
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) mechanisch prüfbar macht (eigener Commit, nur diese Datei), ist eingehalten;
  ob der Fußabdruck auch redaktionelle Berührungen versionieren soll, ist eine Frage an
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) selbst und damit an einen eigenen Trigger, nicht an diesen Diff
  (Rollen-Verweis: Konventions-Pflege, nicht Code-Review).
- `verifizierbar`: **ja, statisch** — `git show --stat 7314b7c` und `git show 7314b7c:spec/lastenheft.md | sed -n 3p`.

---

## Negativbefunde (geprüft, ohne Befund)

- geprüft, ohne Befund: **Der Messbefehl im Release-Text läuft real.**
  `git diff v0.1.0 origin/main -- docs/user/benutzerhandbuch.md README.md` liefert einen nicht-leeren
  Diff (ein Hunk in `README.md`, sieben in `docs/user/benutzerhandbuch.md`) — er zeigt, was der Text
  behauptet, und endet mit Exit 0.
- geprüft, ohne Befund: **`origin/main` ist für einen externen Leser auflösbar und aktuell.**
  `git ls-remote origin refs/heads/main` = `3780d21…` = die lokale Remote-Tracking-Referenz; ein
  frischer `git clone` legt sowohl `origin/main` als auch (per Default) das Tag `v0.1.0` an, beide
  Diff-Enden existieren also ohne Zusatzschritt.
- geprüft, ohne Befund: **Alle vier im Release-Text genannten Abweichungen sind wörtlich im Tag
  auffindbar** — FAQ („Derzeit nicht"), Anhang („keine Release-Versionsnummer"), Kasten („bei jedem
  Release auf Linux", Ortsangabe „Installations-Abschnitt" durch die Heading-Kette 53/55/67 gedeckt),
  fehlendes `mkdir -p` samt unbedingter Ergebnis-Zusage. Keine Paraphrase, keine Fehlzuordnung.
- geprüft, ohne Befund: **Der `release`-Lauf zu `v0.1.0` deckt die Start-Aussage.**
  `gh run view 30193450074` → acht Jobs, alle `success`; die sechs `start-smoke`-Jobs tragen die sechs
  Binary-Namen, `publish` lädt dasselbe Artefakt hoch. Die DoD-Zeile „`release`-Lauf grün über alle
  acht Jobs … sechs Assets — gezählt, nicht angenommen" trifft zu.
- geprüft, ohne Befund: **Die Entlastungs-Aussage über die sechs Binaries.**
  `--json assets` → sechs, Namen zeichengleich mit [`release.yml`](../../.github/workflows/release.yml):69–80; `git diff --stat v0.1.0
  origin/main` → acht Dateien, ausschließlich `.md`. Kein Go-Code, kein Workflow, kein Makefile im
  Delta.
- geprüft, ohne Befund: **Die macOS-Suchpfad-Aussage im Release-Text** („dieser Ordner liegt auf macOS
  nicht im Standard-Suchpfad") ist repo-extern und im Repo nicht messbar; sie ist deckungsgleich mit
  der Fassung, die `a4dac1f` ins Handbuch auf `main` geschrieben hat, und steht zu keiner Repo-Quelle
  im Widerspruch. Kein Widerspruchs-Befund; als externe Tatsachenbehauptung außerhalb der
  Reviewer-Reichweite benannt statt stillschweigend abgehakt.
- geprüft, ohne Befund: **Der DoD-Messbefehl selbst gefahren** —
  `git log --format=%h --no-merges 63236d3..321b849 -- spec/lastenheft.md` → **0 Zeilen**, wie im
  Artefakt zugesagt.
- geprüft, ohne Befund: **`7314b7c` gegen [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2** — eine Datei, `spec/lastenheft.md`,
  `2 insertions(+), 2 deletions(-)`; Setzung 3 (Anlass in der Änderungs-, annehmende Instanz in der
  Verweis-Spalte) in beiden geänderten Zeilen unverändert gewahrt.
- geprüft, ohne Befund: **Die Trennungs-Aussage der `0.14.1`-Zeile** — `30f0fcd` und `5c4930b` ändern
  je die Messmethode-Aufzählung von [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix); `614351e` fasst ausschließlich den zweiten
  Punkt unter „Grenze der Messmethode" an. Das genannte Unterscheidungsmerkmal ist real.
- geprüft, ohne Befund: **„erste Zeile ohne `X.Y.0`"** — alle 15 Historie-Zeilen gezählt
  ([`spec/lastenheft.md`](../../spec/lastenheft.md):312–326); `0.1.0`…`0.14.0` sind ausnahmslos `X.Y.0`.
- geprüft, ohne Befund: **Die `0.14.0`-Zeile führt keine zurückgenommene Aussage mehr affirmativ** —
  „nennt ihre Auflösung" ist repo-weit verschwunden; die verbliebene Nennung steht im Präteritum mit
  Rücknahme-Vermerk.
- geprüft, ohne Befund: **Kein Gate-, ADR- oder Workflow-Pfad berührt.** `git show --stat` beider
  Commits: drei Markdown-Dateien insgesamt (`spec/lastenheft.md`, der Slice-Plan, der Runde-4-Report).
  Kein Go-Code, kein Makefile, keine `.github/workflows/*`, keine ADR — [`AGENTS.md`](../../AGENTS.md) §3.1
  (halluzinierte Gates), §3.2 (Lint-Suppression), §3.4 (ADR-Immutabilität) und §3.5 (Gate-Lockerung)
  sind mangels Berührungsfläche nicht verletzbar; §3.3 (`git mv` + Inhalt) greift nicht, es gibt keine
  Umbenennung.
- geprüft, ohne Befund: **Sensor-Lauf** — `make docs-check` (Docker-only, `--network none`, gepinntes
  Image): `d-check: 191 Datei(en) geprüft, 0 Befund(e)`. Die neuen Links und Anker in beiden Commits
  tragen. Kein mutierendes Target gefahren (kein `make mutate`, kein `make gates`) — die
  Gate-Lauf-Bestätigung ist Verifier-Sache, nicht Reviewer-Sache.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | **0** | — |
| MEDIUM | **0** | — |
| LOW | **4** | T-1, T-2, T-3, T-4 |
| INFO | **2** | INFO-1, INFO-2 |

### Zur wiederkehrenden Klasse — fünfte Runde, Trendaussage

| Runde | Schwerste Kategorie | Träger der ungedeckten Zusage |
|---|---|---|
| 1 | HIGH | Nutzer-Doku, Gate-Pfad |
| 2 | — | Commit-Message / Ablehnungs-Begründung |
| 3 | HIGH | [`spec/lastenheft.md`](../../spec/lastenheft.md) · veröffentlichter Release-Text |
| 4 | MEDIUM | veröffentlichter Release-Text (erneut) · DoD · Historie-Zeile |
| **5** | **LOW** | DoD-Erklärsatz · Pathspec eines Messbefehls · Selbstaussage einer Historie-Zeile |

Die Klasse ist **nicht verschwunden**, aber sie ist zum ersten Mal in vier Runden **nicht mehr
merge-blockierend**: alle vier verbliebenen Instanzen sind Rest-Unschärfen an Sätzen, deren tragende
Aussage jetzt gemessen ist — kein Freispruch, kein Allquantor mehr, der einen Leser in einen
gebrochenen Ablauf schickt. Die Bauform-Umstellung („der Allquantor trägt den Befehl neben sich")
wirkt; ihre neue Schwachstelle ist, dass ein Befehl seine eigene stillschweigende Verengung mitbringen
kann — **die Pathspec bei T-3, das Range-Ende bei T-2**. Das ist ein präziserer Steering-Loop-Input
für den Roadmap-Kandidaten „Regeln ohne Feedback-Quadrant schließen" als die bloße Wiederholungszahl:
gesucht ist nicht „mehr Messbefehle", sondern ein Sensor auf die **Deckungsgleichheit von Behauptung
und Messumfang**. Ein Gate darauf existiert nicht und wird von diesem Report auch nicht zugesagt.

---

## Verdikt

## **KONFORM**

Begründung nach Modul 10 (HIGH und MEDIUM blockieren typischerweise, LOW/INFO nicht):

- **0 HIGH, 0 MEDIUM.** Das einzige MEDIUM der Runde 4 (**S-1**) ist behoben — nicht verengt,
  sondern in der Bauform ersetzt. Der beanstandete Freispruch existiert nicht mehr; jede verbliebene
  Aussage des Release-Textes wurde in dieser Runde einzeln gegen Repo, Tag, `release.yml`, `ci.yml`
  und den realen Lauf `30193450074` gemessen und trifft zu. Die verbliebene Entlastungs-Aussage über
  die sechs Binaries ist belegt (sechs Assets gezählt, sechs `start-smoke`-Jobs grün, Delta
  `v0.1.0 → origin/main` ausschließlich `.md`).
- **S-2, S-3, S-4** sind ebenfalls aufgelöst; der DoD-Punkt trägt keine Zahl mehr, sein Messbefehl
  wurde selbst gefahren (0 Zeilen), die Patch-Begründung trennt jetzt real von `0.13.0`/`0.14.0`, und
  die `0.14.0`-Zeile führt keine zurückgenommene Aussage mehr im Präsens.
- **`MR-015` Setzung 2 ist von `7314b7c` gewahrt** (ein Commit, eine Datei); Setzung 3 bleibt in
  beiden geänderten Zeilen intakt.
- **Die vier neuen LOW-Findings blockieren nicht.** T-1 und T-4 sind Formulierungs-Defekte mit
  Präzedenz-Wirkung, kein Leser wird durch sie in einen gebrochenen Ablauf geschickt. T-2 ist eine
  latente Wartungsfalle, deren Auslösebedingung (ein Lastenheft-Touch im Closure-Commit) heute nicht
  eingetreten ist — `3780d21` und `85e3c26` fassen die Datei nicht an, gemessen. T-3 verengt einen
  Zeiger, widerspricht aber keiner Aussage des Release-Textes; die dort gegebene Kernaussage („läuft
  auf linux/amd64", „für alle sechs nur der Start") ist korrekt und steht im selben Text **vor** dem
  Befehl.
- **Keine Milderung aus Runden-Müdigkeit.** Modul 10 §„Gegen: bei zwei Kategorisierungen die mildere"
  verbietet, ein MEDIUM leiser zu drehen, weil eine Formulierung „schon besser geworden" ist — S-1
  ist nicht milder bewertet, sondern **an seinem eigenen Failure-Szenario gemessen und geschlossen**:
  der Satz, der den Adopter in den kaputten `mv`-Ablauf schickte, ist weg, und der Ablauf ist
  namentlich als Abweichung ausgewiesen.

**Für die Closure:** die vier LOW und zwei INFO sind Übergabe-Material, kein Merge-Hindernis. **T-2**
verdient dabei die einzige zeitkritische Beachtung: seine Auslösebedingung fällt mit dem
Closure-Commit zusammen. Die Verifikation sollte den DoD-Punkt nicht über den eingefrorenen
Range-Befehl, sondern über `git diff 63236d3..HEAD -- spec/lastenheft.md` abhaken und die dabei
gefundenen Lastenheft-Commits einzeln einordnen — das ist Verifier-Arbeit (Modul 11), nicht Teil
dieses Verdikts.

---

## Nachtrag der Implementation (2026-07-26) — Auflösung der Runde-5-Findings

Verdikt **KONFORM**; kein LOW/INFO blockiert. Aufgelöst wurden sie trotzdem — zwei davon standen
in der **DoD**, die der Verifier als Prüfliste liest, und eine falsche DoD-Aussage würde die
Verifikation vergiften.

- **T-1 (LOW) — bestätigt, behoben.** Mein DoD-Satz „**jeder** Lastenheft-Commit … keine
  Slice-Commits" war ein Allquantor über die **Repo-Historie** und damit falsch: `7b717f4` ist ein
  Slice-Commit an `spec/lastenheft.md` — und
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Ist-Messung listet ihn selbst.
  Die Aussage ist jetzt ausdrücklich **auf diesen Slice beschränkt** und benennt `7b717f4` als das
  Gegenbeispiel, aus dem die Setzung überhaupt entstand. Fünfte Instanz derselben Klasse in dieser
  Sitzung — diesmal in der DoD.
- **T-2 (LOW) — bestätigt, behoben.** Die Range `63236d3..321b849` war als „die Commits DIESES
  Slice" beschriftet, enthielt aber `3780d21`/`85e3c26` und den Closure-Commit nicht: der Befehl
  wäre grün geblieben, während die zugesagte Eigenschaft bricht — und der Auslöser fiele mit der
  Closure zusammen. Geprüft wird jetzt `63236d3..HEAD`, also die **volle** Range bis zum
  Closure-Stand. Selbst gefahren: `git log --format='%h %s' 63236d3..HEAD -- spec/lastenheft.md`
  listet exakt `30f0fcd`, `614351e`, `7314b7c` — alle drei `spec:`-Commits mit Nutzer-Entscheidung,
  kein `impl:`/`fix:`/`close:`-Commit dieses Slice.
- **T-3 (LOW) — bestätigt, behoben.** Der Satz sprach von „der mitgelieferten Dokumentation dieses
  Tags", der Messbefehl deckte nur zwei Dateien — und ausgerechnet `spec/lastenheft.md` steht im
  Tag noch auf 0.13.0 mit der undifferenzierten Zusage „linux: Voll-Smoke", die dem **Kopf des
  Release-Textes** widerspricht. Der Befehl lautet jetzt `git diff v0.1.0 origin/main -- '*.md'`
  (selbst gefahren: acht Dateien, darunter `spec/lastenheft.md`), und die Abweichung ist in der
  Auswahl namentlich genannt.
- **T-4 (LOW) — bestätigt, behoben.** „Diese Zeile … wird nicht umgeschrieben" stand in genau dem
  Commit, der die Zeile umschrieb. Der Zusatz sagt jetzt, was er tut: er **ordnet ein**, der
  beschriebene Stand von 0.14.0 wird **nicht revidiert**.
- **INFO-1/INFO-2 — angenommen, keine Änderung.** „sie fügt nichts hinzu" ist ausdrücklich auf der
  Vertragsebene gemeint (der Diff ist +9/−5); die Frage, ob eine Historie-Präzisierung ohne
  Versions-Bump zulässig ist, gehört an [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  und nicht in diesen Slice — sie geht in die Closure-Notiz.
