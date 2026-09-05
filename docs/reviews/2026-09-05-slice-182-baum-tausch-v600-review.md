# Review-Report — slice-182 (Baum-Tausch `v5.18.0` → `v6.0.0`, Pin-Nachtrag, Template-Reklassifikation)

**Datum:** 2026-09-05 · **Rolle:** Reviewer (Modul 8, frischer Kontext) ·
**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) 1.6.0
**Runde:** 1

## Eingangs-Kontext (fünf Pflicht-Punkte + Slice-Plan)

| Punkt | Inhalt |
|---|---|
| **Diff/Commit-Range** | `b0bd72a..HEAD` = `d75cd8c` · `65c54ff` · `faa8178` (Architect) · `548a20e` (Planner) · `adb1a56` · `7590640` · `a6c5102`; 125 Dateien, 535+/358− (`git diff --stat b0bd72a..HEAD \| tail -1`) |
| **`LH-*`** | [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Pin als Reproduzierbarkeits-Klammer), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| **Aktive ADRs im Commit-Text** | `ADR-0016`, `ADR-0018`, `ADR-0023`, `ADR-0031`, `ADR-0034`, `ADR-0035`, `ADR-0003`, `ADR-0011`, `ADR-0028`, `ADR-0030` |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.1–§3.9, tragend hier §3.3, §3.4, §3.6, §3.7, §3.8 |
| **Vorherige Findings am gleichen Modul** | [`docs/reviews/2026-08-28-slice-081-review.md`](2026-08-28-slice-081-review.md) — derselbe Vorgangstyp (Baum-Tausch): HIGH ×3, MEDIUM ×4; wiederkehrende Klassen dort `Präsens-Aussage-gegen-gepinnten-Stand` (2×), `Zahl-ohne-lieferndes-Kommando` (5×), `Gate-Abbruch-verdeckt-Rest` |
| **Slice-Plan** (Repo-Ergänzung) | [`docs/plan/planning/done/slice-182-baum-tausch-v600-pins-ziehen.md`](../plan/planning/done/slice-182-baum-tausch-v600-pins-ziehen.md) |

**Selbst gefahren, nicht übernommen** (Ergebnisse in den Negativbefunden):
`make gates` · `make full-smoke` · `make regelwerk-check` (Netz) · `make mutate` ·
`make test-go` über drei isolierten Mutations-Kopien · eigener Download des
`v6.0.0`-Release-Assets und Baum-Vergleich.

Alle Zahlen unten stehen neben dem Kommando, das sie liefert
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1); keine ist ein Erwartungswert.

---

## Findings

### HIGH-1 — §Adoptierte Konventions-Quellen sagt das Gegenteil dessen, was derselbe Slice 34 Minuten später hergestellt hat

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Ein Kommentar beschreibt, was da ist* — Geltungsbereich schließt die Zustandsfelder der lebenden Register ein), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
- **pfad:** `harness/conventions.md:64–71`
- **befund:** Der Absatz behauptet im Indikativ Präsens, `BASELINE_ZIP_SHA256`, `BASELINE_TAG`, das `sources`-Paar in `.d-check.yml` und `DefaultTag`/`DefaultBaselineSHA256` trügen „den abgelösten Stand", die Upstream-Provenienz sei „offen", und `make regelwerk-check` prüfe „ein anderes Asset als den vendored Baum". Geschrieben hat ihn `faa8178` (19:45); `adb1a56` (20:19) — derselbe Slice — hat alle fünf Stellen auf `v6.0.0` gezogen. Gemessen: `grep -m1 '^BASELINE_ZIP_SHA256' Makefile` → `ed617e382560793ddd805650a7a0e1e421d68d4fff81253da240a9d47a2e654a`, byte-gleich dem `sha256sum` des von mir frisch geladenen Release-Assets; `make regelwerk-check` → `d-check: 604 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. Der Slice hat DoD 1 und DoD 3 abgehakt (`a6c5102`), während das normative Artefakt, das die Buchung trägt, den entgegengesetzten Zustand ausweist. Ein nachfolgender Lauf, der §Adoptierte Konventions-Quellen als Quelle liest — dafür steht sie da —, hält den Pin-Nachzug für ausstehend und den Slice für unfertig; die Zeile „Träger des Nachzugs ist slice-182" verweist auf Arbeit, die in derselben Commit-Kette bereits geschehen ist.
- **verifizierbar:** nein durch ein Gate — `make gates` EXIT 0, `docs-check: 604 Datei(en) geprüft, 0 Befund(e)`; das Modul `links` prüft Ziele, nicht den Wahrheitsgehalt von Prosa. Ja durch Handlauf: `sed -n '64,71p' harness/conventions.md` gegen `grep -m1 '^BASELINE_ZIP_SHA256' Makefile` und `grep -n 'DefaultTag' internal/fetch/baseline.go`.
- **klasse:** `Präsens-Aussage-gegen-gepinnten-Stand` (`BEO-009` — *Ein Fix, der Verhalten ändert, lässt eine daneben stehende Zusage unverändert stehen*; Register-Stand 10×, **geplant**)

### HIGH-2 — `harness/conventions.md` endet mitten im Satz, und die einzige lebende Umdeutung einer immutablen ADR ist repo-weit verschwunden

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Skill-HIGH-Anker: *„bricht mitten im Satz ab, weil eine Teilersetzung den Rest stehen ließ"*), [`AGENTS.md`](../../AGENTS.md) §3.4 (ADRs sind nach Accepted immutabel)
- **pfad:** `harness/conventions.md:203–205`
- **befund:** Die Datei endet mit `… (Festlegung 1 Punkt 3 sowie die Re-Evaluierungs-Trigger 2 und 6). Der Schnitt` — der Satz bricht ab. `faa8178` hat die vier abschließenden Zeilen entfernt; sie trugen die Aussage, dass die in [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) an drei Stellen genannte Slice-ID 060 als slice-066 zu lesen ist, samt dem Satz *„Diese Umdeutung steht hier und nur hier — die ADR wird dafür nicht angefasst (AGENTS.md §3.4)"*. Der Bestand ist gemessen, nicht vermutet: `git grep -l "slice-066 ist die Auswertung"` → leer über dem gesamten getrackten Baum, `git show faa8178^:harness/conventions.md | tail -6` zeigt den vollständigen Absatz. Die Commit-Message von `faa8178` erwähnt die Löschung an keiner Stelle; sie beschreibt §Baseline, §Adoptierte Konventions-Quellen und 96 Link-Ziele. Ein Lauf, der `ADR-0011` als Constraint liest, findet dort die tote Slice-ID 060 und im Repo nichts mehr, was sie auflöst — und die ADR darf er nach §3.4 nicht anfassen.
- **verifizierbar:** nein — kein Modul aus `grep -n '^modules:' -A 8 .d-check.yml` liest auf Satzvollständigkeit oder auf verschwundenen Text; `make comment-claims: 55 Datei(en) geprueft, 0 Befund(e)` hat keine Markdown-Datei im Prüfbereich. Ja durch `tail -3 harness/conventions.md`.
- **klasse:** `Satz-bricht-nach-Teilersetzung-ab`

### HIGH-3 — `make mutate` bricht seit diesem Slice repo-weit ab, und die CI fährt ihn bei jedem Push

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*Feedback: `make mutate` … meldet jeden gelisteten Wächter, der seine Zähne verloren hat*), [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions), [`harness/README.md`](../../harness/README.md) §CI
- **pfad:** `test/mutations/219-vorlagenhinweis-driftet-lautlos.sh:1` · `test/mutations/220-kopiere-satz-verstellt.sh:1` · `harness/tools/mutate.sh:1515`
- **befund:** `make mutate` endet mit `sha256sum: .harness/baseline/v6.0.0/templates/docs/plan/planning/observations.template.md: Datei oder Verzeichnis nicht gefunden` / `mutate: ABBRUCH — Fingerabdruck der Mutations-Ziele nicht berechenbar.`, EXIT 2 — **kein einziger** der `ls test/mutations/*.sh | wc -l` → **250** Fälle läuft, es entsteht kein Bericht. Ursache ist `d75cd8c` dieses Slice: der Commit hat den Tag im `# files:`-Kopf von 219 und 220 mechanisch auf `v6.0.0` gezogen, während derselbe Commit die genannte Datei entfernt hat (`git diff-tree -r --name-status -M d75cd8c | grep '^D'`). Vor dem Slice lief der Sensor; die Behauptung „kein neuer Defekt dieses Slices" (`d75cd8c`-Message, §6 des Plans) ist damit widerlegt. `.github/workflows/ci.yml:72` ruft `make mutate` auf frischem Klon pro Push/PR — die CI ist ab `d75cd8c` bei jedem Push rot. Der Sweep über alle Fall-Köpfe zeigt genau dieses eine tote Ziel: von den unique `# files:`-Zielen fehlt **1** von **57**.
- **verifizierbar:** ja — `make mutate` (EXIT 2, Ausgabe oben).
- **klasse:** `Gate-Abbruch-verdeckt-Rest` (Wiederholung derselben Klasse aus [`2026-08-28-slice-081-review.md`](2026-08-28-slice-081-review.md)) · `BEO-028` für die Fall-Hälfte

### HIGH-4 — Der genannte Träger der zwei aufgeschobenen Defekte trägt sie nicht

- **kategorie:** HIGH (aus MEDIUM eskaliert: §Kontext-Eskalation der Skill-Datei — dieselbe Beobachtung im Sensor-/Gate-Pfad steigt eine Stufe; der betroffene Sensor liegt tot)
- **quelle:** Baseline-Regelwerk `modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst (*„Urteil bleibt … ob die genannte Folge-Slice-ID die Realisierung tatsächlich auffängt"*)
- **pfad:** `docs/plan/planning/done/slice-182-baum-tausch-v600-pins-ziehen.md:217` und `:229`
- **befund:** Beide neuen §6-Risiken — die fehlende stehende Register-Datei im **emittierten** Repo und der `make mutate`-Komplettabbruch — weisen [slice-177](../plan/planning/done/slice-177-beobachtungs-register-verzeichnis-form.md) als Träger aus („derselbe Träger wie oben"). Gemessen: `grep -n 'mutation\|mutate\|219\|220\|218' docs/plan/planning/done/slice-177-beobachtungs-register-verzeichnis-form.md` → **keine Ausgabe**; `grep -c 'internal/emit' …/slice-177-….md` → **0**. Seine DoD adressiert ausschließlich die Ablage `docs/plan/planning/observations/` **dieses** Repos, den Verweis-Nachzug und `make gates` grün — und `make gates` fährt `mutate` nicht (`grep -n '^record-gates:' Makefile`). [welle-15](../plan/planning/done/welle-15-re-baseline.md) §4 führt **7** Mitglieder (`grep -c '^| \[slice-' docs/plan/planning/welle-15-re-baseline.md`); keines davon nennt `test/mutations/` oder `internal/emit`. Auch der Katalog, aus dem die Zuordnung stammen soll, kennt die Position nicht: `grep -c 'mutation' docs/plan/planning/done/slice-176-inventur-vor-dem-schnitt-v600.md` → **0**. Ein Risiko-Ausgang „Folge-Slice mit ID" ist damit formal gesetzt und materiell leer: schließt slice-177 mit grünem `make gates`, bleibt `make mutate` tot und kein Artefakt erinnert daran.
- **verifizierbar:** nein durch ein Gate — kein Modul der `.d-check.yml` liest Slice-Pläne auf Deckung. Ja durch die zwei `grep` oben.
- **klasse:** `Folge-Slice-traegt-den-Befund-nicht`

### MEDIUM-1 — `test/mutations/218` hat seine Zähne verloren; die Commit-Message sagt das Gegenteil

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6, `BEO-028`
- **pfad:** `test/mutations/218-beobachtungsregister-nicht-emittiert.sh:11`
- **befund:** Der Fall injiziert `"observations.template.md"` (Plural) in `emit.isRecurring` und erwartet, dass `TestTemplates_EmittierterBestandVollstaendig` rot wird. Nach dem Tausch existiert dieser Name nirgends mehr: `git grep -ln 'observations\.template\.md' -- ':!test/mutations' ':!docs/plan/planning/done' ':!docs/reviews'` liefert nur zwei Plan-Dateien, und `courseSet()` führt seit `7590640` `observation.template.md` (Singular). **Rot/Grün selbst gemessen**, in einer Kopie außerhalb des Repos: Fall 218 angewandt → `make test-go` **EXIT 0**, `ok github.com/pt9912/ai-harness-init/internal/emit`. Gegenprobe in derselben Kopie: Fall 215 und Fall 216 → jeweils **EXIT 2**, `--- FAIL: TestTemplates_EmittierterBestandVollstaendig`. Der Anker ist erhalten — die Zeile `case "welle-results.template.md", "MR-NNN-titel.template.md":` steht unverändert in `internal/emit/templates.go:77`, und der neue `case` sitzt korrekt davor (`:75`). Die Zusage der `7590640`-Message *„damit test/mutations/215/216/218 ihren Anker behalten"* trifft aber nur für zwei der drei zu: 218 behält den Anker und verliert seinen Gegenstand. Solange HIGH-3 steht, meldet das kein Lauf.
- **verifizierbar:** ja — `make mutate`, sobald 219/220 wieder ein existierendes Ziel nennen; heute nur über den isolierten `make test-go`-Lauf oben.
- **klasse:** `BEO-028` (*Ein Mutations-Fall nennt eine andere Datei als die, die sein Wächter liest — trifft nichts und bleibt grün*; Register-Stand 1×, offen)

### MEDIUM-2 — Die Provenienz- und Inventur-Zahlen der Commit-Messages halten der Nachmessung nicht stand

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*Eine Zusage — … Commit-Message — …*), [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- **pfad:** Commit `adb1a56` (Message, Absatz *Provenienz-Abgleich*) · Commit `d75cd8c` (Message, Absatz *Datei-Inventar*)
- **befund:** DoD 1 macht genau diese Benennung zum Abnahmekriterium („der Unterschied zum `git archive`-Stand ist gemessen und benannt"). Ich habe das Asset erneut geladen (`curl -sSL …/releases/download/v6.0.0/lab-regelwerk.zip`; `sha256sum` → `ed617e38…e654a`, identisch mit dem Pin) und Datei für Datei gegen `.harness/baseline/v6.0.0/` gehalten. **Substanz bestätigt:** nach Normalisierung der zwei Umschreibe-Regeln (`…/blob/v6.0.0/` → `../../` und `releases/download/v6.0.0/lab-regelwerk.zip` → `releases/latest/download/lab-regelwerk.zip`) bleibt **0** Datei mit Rest-Delta; kein Regelwerks- oder Vorlagen-Inhalt weicht ab, und der Baum ist vollständig (**53** Asset-Dateien, alle vorhanden; einziger Überschuss `SHA256SUMS`, selbst erzeugt). **Zahlen nicht bestätigt:** es differieren **28** von **53** Dateien (nicht 26) mit **29** geänderten Zeilen (nicht 28), und `regelwerk/README.md` trägt **zwei** geänderte Zeilen — die Zusage *„je genau eine geänderte Zeile"* ist falsifiziert. Zweite Stelle: `d75cd8c` nennt „Inhalts-Deltas an sieben Regelwerk- und **sechs** Template-Dateien"; gemessen sind es **7** Template-Dateien (`git diff-tree -r --name-status -M d75cd8c | grep 'templates/' | grep -cE '^R0'`).
- **verifizierbar:** nein durch ein Gate; ja durch den Asset-Download und den Baum-Vergleich (Kommandos oben).
- **klasse:** `Zahl-ohne-lieferndes-Kommando` (Wiederholung derselben Klasse aus [`2026-08-28-slice-081-review.md`](2026-08-28-slice-081-review.md), dort 5×)

### MEDIUM-3 — Das Benutzerhandbuch zeigt eine Ausgabe, die das Werkzeug nicht mehr erzeugt

- **kategorie:** MEDIUM
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md)
- **pfad:** `docs/user/benutzerhandbuch.md:174`
- **befund:** Der Beispielablauf zeigt `ai-harness-init: Bootstrap (Baseline v5.18.0 vendored + …)`. Die Zeile stammt aus `cmd/ai-harness-init/main.go:392` und füllt `tag` aus `cmd/ai-harness-init/main.go:339` (`tag := envOr("COURSE_TAG", fetch.DefaultTag)`); `fetch.DefaultTag` ist seit `adb1a56` `v6.0.0`. Selbst gefahren: ein Emit-Lauf mit dem gebauten Träger gibt `ai-harness-init: Bootstrap (Baseline v6.0.0 vendored + …)` aus. Der Fall ist **innerhalb** der DoD-2-Überschrift („Kein lebender Verweis zeigt auf den alten Tag"), aber **außerhalb** ihrer Bezugsmenge: der Pfad-`grep` sieht eine Versions-Annotation ohne `.harness/baseline/`-Segment nicht — genau die Klasse, die §6-Risiko 1 dieses Plans vorab benennt („eine Version-Annotation neben einem Zitat", `BEO-003`). Für den vorigen Sprung hat diese Zeile ein eigener Slice gezogen (`git log --format='%h %s' -S 'Bootstrag' …` → `ba0c5bb`, slice-165); in [welle-15](../plan/planning/done/welle-15-re-baseline.md) gibt es kein entsprechendes Mitglied, der Fall steht damit ohne Träger.
- **verifizierbar:** nein — die Zeile steht in einem Code-Block, kein `links`/`codepaths`-Modul prüft sie. Ja durch einen Emit-Lauf gegen `sed -n '174p' docs/user/benutzerhandbuch.md`.
- **klasse:** `Präsens-Aussage-gegen-gepinnten-Stand` (`BEO-009`)

### MEDIUM-4 — Der Reviewer-Skill deklariert eine Baseline, die das Repo nicht mehr führt

- **kategorie:** MEDIUM
- **quelle:** [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md), Baseline-Regelwerk `modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse (die Skill-Datei ist die **fixierte** Urteilsgrundlage der Reviewer-Rolle)
- **pfad:** `.harness/skills/reviewer.md:4`
- **befund:** Der Kopf trägt `**Baseline:** Agents-Regelwerk v5.18.0 (Kurs-Welle 111), Modul 10 §Ziel-Form: Reviewer-Skill`, während `ls -d .harness/baseline/v*/ | wc -l` → **1** und dieser eine Baum `v6.0.0` ist. Derselbe Slice hat den Link in Zeile 58 derselben Datei auf `v6.0.0` gezogen (`65c54ff`) und die Versions-Deklaration darüber stehen lassen — die Datei zeigt jetzt in zwei Fassungen zugleich. Das ist die Datei, aus der die Reviewer-Rolle in **jedem** Lauf ihre HIGH-Liste, ihr Output-Schema und ihre Kategorien-Semantik zieht (dieser Lauf eingeschlossen); wer ihre Herleitung nachprüfen will, sucht einen Baum, den der Checkout nicht hat. Wie MEDIUM-3 liegt der Fall außerhalb der DoD-2-Bezugsmenge und ohne Mitglied in [welle-15](../plan/planning/done/welle-15-re-baseline.md); die Präzedenz (`ba0c5bb`, slice-165, Version 1.6.0) zeigt, dass der Re-Pin sonst stattfindet.
- **verifizierbar:** nein — `docs-check` prüft den Link in Zeile 58, nicht die Klartext-Deklaration in Zeile 4. Ja durch `sed -n '4p' .harness/skills/reviewer.md` gegen `ls -d .harness/baseline/v*/`.
- **klasse:** `Präsens-Aussage-gegen-gepinnten-Stand` (`BEO-009`)

### LOW-1 — Zahl ohne Kommando im Slice-Plan: „260+ übrige Fälle"

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1
- **pfad:** `docs/plan/planning/done/slice-182-baum-tausch-v600-pins-ziehen.md:227`
- **befund:** Das §6-Risiko schreibt „keine der 260+ übrigen Fälle läuft". Gemessen: `ls test/mutations/*.sh | wc -l` → **250**. Die Zahl steht ohne das Kommando, das sie liefert, und liegt über dem Ist-Bestand.
- **verifizierbar:** nein durch ein Gate; ja durch das `ls` oben.
- **klasse:** `Zahl-ohne-lieferndes-Kommando`

### LOW-2 — „12 eindeutige Ziele, 0 tot" in `AGENTS.md` ist über den Tausch nicht nachgemessen und aus dem Text nicht reproduzierbar

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1, [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
- **pfad:** `AGENTS.md:40`
- **befund:** Der Satz sagt für die `../templates/…`-Verweise des vendored Regelwerks „(12 eindeutige Ziele, 0 tot — gemessen)" und nennt kein Kommando; sein einziger Beleg, `harness/conventions/MR-007-baseline-committet-vendored-statt-gefetchter-cache.md:26–27`, ist nach `:18` gegen den adoptierten Stand `v5.12.0` gemessen — zwei Sprünge zurück. Derselbe Architect-Commit hat die beiden Nachbarzahlen desselben Abschnitts neu gemessen (`346103` → **351125**, verifiziert mit `cat .harness/baseline/v6.0.0/regelwerk/*.md | wc -c`), diese nicht. Eine unabhängige Messung liefert einen anderen Wert (`grep -rhoE '\.\./templates/[A-Za-z0-9._/-]+' .harness/baseline/v6.0.0/regelwerk/ | sort -u | wc -l` → **23**, davon **0** tot) — was nicht heißt, dass „12" falsch ist, sondern dass ohne genanntes Kommando niemand es entscheiden kann.
- **verifizierbar:** nein — kein Modul der `.d-check.yml` fährt ein Kommando aus dem Fließtext.
- **klasse:** `Zahl-ohne-lieferndes-Kommando`

### LOW-3 — Der DoD-2-Nachtrag lässt `docs-check` mehr belegen, als es prüft

- **kategorie:** LOW
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `docs/plan/planning/done/slice-182-baum-tausch-v600-pins-ziehen.md:111–113`
- **befund:** Der fünfte Ausschluss schließt mit „`make gates` (docs-check, `codepaths`) bleibt über allen 18 betroffenen Dateien grün — keiner der 36 Treffer ist ein strukturell toter Pfad". Alle 36 Treffer **sind** tote Pfade (`.harness/baseline/v5.18.0/` existiert nicht mehr); keiner ist ein **Markdown-Link** — gemessen: `grep -cE '\]\([^)]*\.harness/baseline/v5\.18\.0' <hits>` → **0**. Das grüne `docs-check` belegt damit „kein toter Link", nicht „kein toter Pfad". Die Wortwahl macht aus einer Sensor-Grenze eine Sensor-Aussage.
- **verifizierbar:** ja, in der Gegenrichtung: ein einziger der 36 Treffer als Link geschrieben färbt `docs-check` rot — genau das war der Gegenbeispiel-Lauf, den `faa8178` mit `96 Befund(e)` protokolliert.
- **klasse:** `Sensor-Grenze-als-Sensor-Aussage`

### LOW-4 — Die §3.3-Bedingung, die der Plan selbst gesetzt hat, ist gefeuert und nicht ausgeführt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.3, Slice-Plan §3
- **pfad:** `docs/plan/planning/done/slice-182-baum-tausch-v600-pins-ziehen.md:154–156` · Commit `d75cd8c`
- **befund:** §3 des Plans macht die Commit-Trennung an einer Messung fest: „Weist `git diff-tree -r --name-status -M` über dem Tausch-Commit eine `R`-Zeile aus, ist der Move von der Inhaltsänderung zu trennen." Gemessen: `git diff-tree -r --name-status -M d75cd8c | grep -c '^R'` → **53** `R`-Zeilen, die niedrigste Ähnlichkeit `R060` (`SHA256SUMS`), dazu `R078` (`grundlagen-traceability.md`). Der Tausch ist trotzdem ein Commit, und die `d75cd8c`-Message berichtet die Messung nicht. Der Schaden, gegen den §3.3 schützt, ist hier **nicht** eingetreten — `git` hat alle 53 Umbenennungen erkannt —, aber die Bedingung des Plans ist unausgewertet geblieben, und `R060` liegt nur knapp über der Standard-Schwelle: beim nächsten Sprung mit größerem Delta fällt sie darunter.
- **verifizierbar:** nein durch ein Gate; ja durch das `git diff-tree` oben.
- **klasse:** `Plan-Bedingung-unausgewertet`

### INFO-1 — Die Klassifikation der 36 DoD-2-Resttreffer geht exakt auf

- **kategorie:** INFO
- **pfad:** `docs/plan/planning/done/slice-182-baum-tausch-v600-pins-ziehen.md:93–113`
- **befund:** Ich habe das in der DoD genannte Kommando wörtlich nachgefahren (`git grep -n '\.harness/baseline/v5\.18\.0' -- '*.md' '*.go' '*.sh' '*.yml' 'Makefile'`, minus die vier eingefrorenen Verzeichnisse): **36** Treffer über **18** Dateien. Aufteilung deckungsgleich mit dem Plan — **2** in der Plan-Datei selbst, **4** in `harness/conventions.md` + `MR-005`/`MR-045`/`MR-047`, **30** in **13** Dateien, davon **9** offene Slice-Pläne (090, 091, 101, 112, 114, 134, 140, 151, 174), **2** Welle-Pläne (09, 11), `observations.md` (BEO-021/BEO-023) und `.harness/skills/reviewer.md`. **Kein Treffer bleibt unklassifiziert**, und die Einordnung als datierter Mess-Zeitbezug nach [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) trägt für alle 30: jeder steht in einem Kommando oder Zitat, das den Tag nennt, gegen den gemessen wurde. Die Aufgabenstellung dieses Reviews fragte, ob einer stehen bleibt — die Antwort ist nein. Der Defekt der DoD-2-Hälfte liegt nicht in der Klassifikation der 36, sondern in der **Bezugsmenge**, die MEDIUM-3 und MEDIUM-4 strukturell nicht erreicht.

### INFO-2 — `harness/conventions.md:181` ist mehr als eine veraltete Fundstelle, hat aber einen benannten Träger

- **kategorie:** INFO
- **pfad:** `harness/conventions.md:177–181`
- **befund:** Einer der 4 Architect-Treffer begründet die fehlende Kürzel-Spalte der Modus-Deklaration mit „adoptierter Stand `v5.18.0`". [slice-176](../plan/planning/done/slice-176-inventur-vor-dem-schnitt-v600.md) §9 Position **P-04** misst, dass `v6.0.0` die Spalte **unbedingt** verlangt — die neue Fassung kehrt die Aussage um, sie veraltet sie nicht nur. `faa8178` nennt den Träger ausdrücklich ([`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Folgepflicht 2, eigener Architect-Commit); der Punkt steht hier, damit der Architect-Commit dieses Slice nicht als bereits erledigend gelesen wird.

### INFO-3 — Die Provenienz-Kette hat eine gemessene, unbewachte zweite Hälfte

- **kategorie:** INFO
- **befund:** `make regelwerk-check` hält das geladene Asset gegen `BASELINE_ZIP_SHA256` — **Pin → Asset** ist damit bewacht (`604 Datei(en) geprüft, 0 Befund(e)`, EXIT 0). **Asset → vendored Baum** ist es nicht: der Baum stammt aus `git archive`, `SHA256SUMS` ist selbst erzeugt, und kein Ziel vergleicht beide. Der Unterschied ist real, aber begrenzt und von mir vermessen (MEDIUM-2). **Der emittierte Bestand ist davon nicht betroffen** — gemessen an einem frischen Emit-Lauf: `AGENTS.md:29` und `harness/conventions.md:58` des Ziels tragen die tag-gepinnte URL `releases/download/v6.0.0/…`; die floatende `releases/latest/download/…`-Form steht nur im vendored Blob (`templates/AGENTS.template.md:39`, `templates/harness/conventions.template.md:72`), der nach [`AGENTS.md`](../../AGENTS.md) §3.7 ausgenommen ist.

---

## Negativbefunde (geprüft, ohne Befund)

- **`make gates`** — selbst gefahren, **EXIT 0**: `baseline-verify: v6.0.0 OK — 53 Dateien`, `d-check: 604 Datei(en) geprüft, 0 Befund(e)`, `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)`, 218 bats-Zusicherungen grün, `span-check` ok.
- **`make full-smoke`** — selbst gefahren, **EXIT 0** über alle Abschnitte (Arch-Gate, drittes Layout, Idempotenz, Rollen-Typen, Feldliste).
- **`make regelwerk-check`** (Netz) — selbst gefahren, **EXIT 0**, `0 Befund(e)`.
- **Pin-Kette, alle fünf Stellen** — `Makefile:25/34`, `.d-check.yml:166/167`, `internal/fetch/baseline.go:48/54` tragen `v6.0.0` bzw. `ed617e38…e654a`; der von mir geladene Asset-`sha256sum` ist byte-gleich. `test/sources-pin.bats` koppelt zwei davon (bats 209/210 grün).
- **Baum-Vollständigkeit** — alle **53** Asset-Dateien liegen im vendored Baum, keine fehlt; einziger Überschuss ist das selbst erzeugte `SHA256SUMS`.
- **Provenienz-Substanz** — nach Normalisierung der zwei Umschreibe-Regeln **0** Datei mit Rest-Delta: kein Regelwerks- oder Vorlagen-Inhalt weicht vom Release-Asset ab. Die Kernaussage des Implementers trägt (nur ihre Zahlen nicht, MEDIUM-2).
- **`case`-Reihenfolge in `isRecurring`** — `internal/emit/templates.go:75` steht **vor** der Anker-Zeile `:77`; Fall 215 und 216 färben ihren Wächter weiterhin rot (isolierter `make test-go`, je **EXIT 2**). Nur Fall 218 ist tot (MEDIUM-1).
- **`planTemplates`-Kommentar** — `internal/emit/templates.go:342–350` zitiert den alten Vorlagensatz **nicht** mehr; er beschreibt den geltenden Zustand (Weiche fängt `observation.template.md` vor dem Singleton-Default ab) und nennt die offene Lücke als Grenze. Die Zeitform ist Indikativ Präsens, der Herkunfts-Hinweis ein auflösbares Feld — [`AGENTS.md`](../../AGENTS.md) §3.7 gewahrt. Auch der Kopfkommentar `:13–69` ist durchgezählt korrekt: **zehn** Einträge im Rumpf, **sieben** Kopiere-Sätze, `LH-FA-02` nennt **fünf** von zehn nicht.
- **Mutations-Ziele gesamt** — Sweep über alle `# files:`-Köpfe: **57** eindeutige Ziele, genau **1** fehlend (das aus HIGH-3). Kein weiterer Pfad zeigt ins Leere; 224/244/248 sind korrekt gezogen.
- **Adaptions-Einträge** — von **45** geänderten Dateien unter `harness/conventions/` sind **42** reine Tag-Umschreibungen, **3** tragen die bewusst datiert belassenen Mess-Kommandos (`MR-005`, `MR-045`, `MR-047`) — deckungsgleich mit der `faa8178`-Message.
- **Zeitdokumente** — die Änderungen an `done/slice-157` und `done/slice-167` sind reine Entlinkungen: Adresse entfällt, sichtbarer Text zeichengleich ([`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 gewahrt).
- **Rollen-Trennung / Commit-Zuschnitt** — `git show --pretty=format: --name-only faa8178 | grep -vE '^(AGENTS|harness/conventions)\.md$|^harness/conventions/|^docs/plan/adr/|^$'` → **leer**: der Architect-Commit berührt ausschließlich Architect-Artefakte und nennt die Rolle in seiner Message. [`AGENTS.md`](../../AGENTS.md) §3.8 ist eingehalten; ebenso beim Planner-Commit `548a20e`.
- **`.claude/rules/`-Symlinks** — zeigen auf `v6.0.0`; `ls .claude/rules/*.md | wc -l` → **4** von `ls .harness/baseline/v6.0.0/regelwerk/*.md | wc -l` → **26**, die [`MR-035`](../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)-Menge ist unverändert.
- **`AGENTS.md`-Zahlen** — `351125` und `26` und `4` selbst nachgemessen, alle drei korrekt (die vierte Zahl derselben Sektion: LOW-2).
- **Nicht geprüft** (außerhalb der Reviewer-Rolle): die DoD-Abhakung als solche und die Vollständigkeit der Closure-Pflichten §7 — das ist Verifikation bzw. Planner-Arbeit. Ebenso ungeprüft: die inhaltliche Richtigkeit der `v6.0.0`-Regelwerks-Inhalte selbst (vendored Fremd-Blob).

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 4 | `Präsens-Aussage-gegen-gepinnten-Stand` · `Satz-bricht-nach-Teilersetzung-ab` · `Gate-Abbruch-verdeckt-Rest` · `Folge-Slice-traegt-den-Befund-nicht` |
| MEDIUM | 4 | `BEO-028` · `Zahl-ohne-lieferndes-Kommando` · `Präsens-Aussage-gegen-gepinnten-Stand` (2×) |
| LOW | 4 | `Zahl-ohne-lieferndes-Kommando` (2×) · `Sensor-Grenze-als-Sensor-Aussage` · `Plan-Bedingung-unausgewertet` |
| INFO | 3 | — |

**Wiederholte Klassen in diesem Lauf** (§Kontext-Eskalation der Skill-Datei):
`Präsens-Aussage-gegen-gepinnten-Stand` **3×** (HIGH-1, MEDIUM-3, MEDIUM-4) und
`Zahl-ohne-lieferndes-Kommando` **3×** (MEDIUM-2, LOW-1, LOW-2). Beide erreichen die
dritte Wiederholung und sind damit Steering-Loop-Signale, nicht nur Meldungen. Beide
sind zugleich Wiederholungen aus dem Review desselben Vorgangstyps
([`2026-08-28-slice-081-review.md`](2026-08-28-slice-081-review.md)) — die Klasse
überlebt den Baum-Tausch-Slice, in dem sie zuletzt gefunden wurde.

**Route in den Zähler** (Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — der Review-Report ist die dritte Quelle des
Closure-Eintrags): `BEO-009` bekommt einen weiteren Beleg (HIGH-1, MEDIUM-3,
MEDIUM-4 sind **ein** Vorgang und zählen einmal), `BEO-028` ebenso (MEDIUM-1),
`BEO-003` als benannte Klasse hinter MEDIUM-3/MEDIUM-4.

---

## Verdikt

**Blockiert.** Vier HIGH und vier MEDIUM stehen offen; nach der Ablage-Regel der
Skill-Datei blockieren beide Kategorien typischerweise, und hier gibt es keinen Grund
für eine Ausnahme:

1. **HIGH-2** ist ein Datenverlust, kein Formfehler — eine normative Aussage über eine
   immutable ADR existiert im Repo nicht mehr, und die Datei endet mitten im Satz.
2. **HIGH-3** legt den Sensor still, den [`AGENTS.md`](../../AGENTS.md) §3.6 als sein
   Feedback benennt, und färbt die CI bei jedem Push rot.
3. **HIGH-1** und **HIGH-4** zusammen nehmen dem Slice die zwei Belege, mit denen er
   seine eigene Abhakung stützt: das normative Artefakt widerspricht DoD 1/3, und der
   Risiko-Ausgang zeigt auf einen Träger, der ihn nicht trägt.

**Kein Rollen-Konflikt gemeldet.** Die Befunde stehen keiner Einschätzung des
Implementers frontal entgegen, die dieser verteidigt hätte — HIGH-3 und MEDIUM-1
korrigieren zwei Selbst-Einschätzungen der Commit-Messages, aber es liegt kein
Widerspruch vor, der den Konflikt-Pfad aus Modul 8 auslöste. Löst der Implementer
einen der vier HIGH mit einer Gegenposition auf, greift der Pfad
(*Reviewer → Architect → Verdikt als Artefakt*), nicht die Herabstufung.

**Zwei Befunde brauchen einen Architect-Lauf, nicht den Implementer:** HIGH-1 und
HIGH-2 liegen in `harness/conventions.md`, die nach [`AGENTS.md`](../../AGENTS.md)
§3.8 Architect-Eigentum ist — die Korrektur gehört in einen eigenen Commit, der nur
Architect-Artefakte berührt und die Rolle nennt.

**Was diesen Report nicht abdeckt:** die DoD-Abhakung selbst und die Closure-Pflichten
§7 (Verifikation bzw. Planner), sowie die Inhalte des vendored Fremd-Blobs.
