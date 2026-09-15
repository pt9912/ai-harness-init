# Review-Report: slice-kennungs-waechter-geht-ins-ziel — 2026-09-15

**Review-Art:** Code-Review gegen **Plan + ADRs + Hard Rules** (Baseline `v6.8.0` ·
`regelwerk/modul-10-review-harness.md` §Drei Review-Arten). **Kein DoD-Review** — DoD-/Spec-
Konformität prüft der Verifier (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).

**Gegenstand:** Commit `446cc05d` („Rolle Implementer: slice-kennungs-waechter-geht-ins-ziel -- der
Traeger geht ins Ziel"), 18 Dateien, `+839/−8` gegen `8c1b87b8`. Der Commit ist die Spitze dieses
Laufs (`git log --oneline -1` → `446cc05d`); `git status --porcelain` → leer.

**Kein Self-Review:** Dieser Lauf hat am Gegenstand **nicht** geschrieben — weder am Commit noch an
einer der 18 Dateien. Kein Befund ist aus der Commit-Message oder aus einem Implementer-Bericht
übernommen: die Träger-Menge des emittierten Ziels (F-1), die zwei Fassungen des Prüfers samt ihrem
vergleichenden Sensor (Negativbefund), die zweite Aufzählung der Kennungs-Menge (F-3), die
Idempotenz-Klassifikation der neuen Pfade (F-4) und alle sieben Mutationsfälle sind in diesem Lauf
**einzeln nachgefahren**. Die Commit-Message wird nur dort zitiert, wo sie **Gegenstand** ist (F-5),
nie als Beleg.

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-15

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf nicht
reproduzierbar):

- Slice-Plan `slice-kennungs-waechter-geht-ins-ziel` — §1 Ziel und Abgrenzung, §2 DoD, §3 Plan,
  §4 Trigger, §5 Closure-Trigger, §6 Risiken, §8
- die Wellen-Datei `welle-emittierte-werkzeuge` (§5, die Richtung „erst die ausgeführte Fassung,
  dann die emittierte")
- [`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  (`Proposed`; Festlegungen 1–4, §Was daran entschieden wird und was nicht) ·
  [`ADR-0004`](../../docs/plan/adr/0004-durchsetzungs-emission.md) (Stolperdraht) ·
  [`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md) (Idempotenz-Klassifikation der
  Emission) ·
  [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
- [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) ·
  [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
  (emittiertes Layout) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- `AGENTS.md` §3 (Hard Rules; tragend §3.1, §3.6, §3.7, §3.9, §3.10, §3.11) · §2 (Source Precedence)
  · §6 (Minimal Agent Workflow)
- Baseline `v6.8.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice (die vier
  Out-of-Scope-Klassen) · `regelwerk/modul-08-agentenrollen.md` §Rollen-Regeln ·
  `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill
- Vorherige Findings an den Wellen-Geschwistern, daraus die wiederkehrenden Klassen:
  `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` ·
  `waechter-abdeckung-haengt-an-uninstruierter-konvention` (beide im Beobachtungs-Register) ·
  `slice-226-implementer-anweisungssatz-zieht-nach` F-1
  (`uebernommener-regelwerk-satz-kollidiert-mit-eigener-hard-rule`)

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht ein Kommando
daneben, das sie liefert; wo eine Datei gemeint ist, die der Prozess bewegt, steht die Kennung.

### 1. Der Träger-Bestand des emittierten Ziels — Grundlage von F-1

```sh
grep -rln 'pretooluse-commit-msg' internal/ cmd/       # keine Ausgabe, EXIT 1
grep -n 'command' internal/emit/templates/enforce/settings.json
#  9: ".claude/hooks/pretooluse-command-guard.sh"      (PreToolUse)
# 19: ".claude/hooks/stop-require-gates.sh"            (Stop)
grep -n 'commit' internal/emit/templates/enforce/pretooluse-command-guard.sh
#  :11 und :18 — beides Kommentarzeilen, keine Prüfung
```

Der PreToolUse-Kanal dieses Repos hat **zwei** Zusatz-Guards: den Toolchain-Guard
(`pretooluse-command-guard.sh`, emittiert) und den Commit-Message-Guard
(`pretooluse-commit-msg-guard.sh`, **nicht** in `enforceFiles()`). Der emittierte Guard trägt keine
Kennungs-Prüfung; sein Kopf nennt seine Klasse selbst („blockt Host-Paketmanager und
Host-Toolchains"). Das gebootstrappte Ziel trägt damit **einen** Träger der Kennungs-Zusage, nicht
zwei.

### 2. Die zwei Fassungen des Prüfers — der vergleichende Sensor **existiert**

Die Vermutung dieses Auftrags („dieselbe Doppelung wie bei `slice-mv`, ohne vergleichenden Sensor")
trifft **nicht** zu. Der Diff liefert den Sensor mit:

```sh
grep -n 'kopplung' test/commit-msg-emission.bats
#  "kopplung: die zwei bash-Fassungen der Kennungs-Menge sind einander gleich"
#  "kopplung: die Betreff-Ausnahme der zwei Fassungen ist dieselbe"
```

Verglichen wird die ausführende Zeile `patterns=` als **Menge** (beide Richtungen) und die Zeile
`exempt=`; der Fall fail-closed, wenn `^patterns=` fehlt oder mehrfach vorkommt. Die Gegenrichtung
ist von Bestand gedeckt: `test/mutations/340` mutiert die Dogfood-Fassung, `test/mutations/347` die
emittierte — **beide** lassen die Kopplungs-Gruppe fallen (unten nachgefahren: `not ok 53`).

### 3. Die sieben Mutationsfälle, einzeln in einer `/tmp`-Kopie gefahren

Nicht im Repo (`make mutate` ist Post-integration und war nicht Gegenstand), sondern je Fall in
einer Kopie außerhalb des Repos, mit dem Sensor, den der Fall selbst nennt:

| Fall | `# verify:` | erwarteter Wächter | gefahren | Ergebnis |
|---|---|---|---|---|
| `test/mutations/347` | `test-bats` | `rot: eine Message ohne Kennung wird abgelehnt, mit Exit 1 und lesbarem Grund` | `make test-bats` | `not ok 47` — der erwartete String steht in der Fehlschlag-Ausgabe |
| `test/mutations/348` | `test-go` | `TestCommitMsgTraeger_LiegtImZielUndRuftDiePruefungDortAuf` | `make test-go` | Exit ≠ 0, Name im FAIL-Block |
| `test/mutations/349` | `test-go` | `TestHooksInstallFragment_IstKeinGateUndNenntDenTraeger` | `make test-go` | Exit ≠ 0, Name im FAIL-Block |
| `test/mutations/350` | `test-go` | `TestCommitMsgAnweisung_NenntTraegerUndAktivierung` | `make test-go` | Exit ≠ 0, Name im FAIL-Block |
| `test/mutations/351` | `test-go` | `TestCommitMsgPruefung_IstDieEinzigeFassungDerMenge` | `make test-go` | Exit ≠ 0, Name im FAIL-Block |
| `test/mutations/352` | `test-go` | `TestHooksInstallFragment_TraegtDieReichweite` | `make test-go` | Exit ≠ 0, Name im FAIL-Block |
| `test/mutations/353` | `test-go` | `TestCommitMsgTraeger_NenntSeineZweiGrenzen` | `make test-go` | Exit ≠ 0, Name im FAIL-Block |

**Jeder Zahn trifft die Stelle, die der Aufrufer fährt.** Die sechs Go-Fälle mutieren die
eingebetteten Quellen (`internal/emit/enforce.go`, `templates/enforce/*.mk`, `templates/commands/`,
`templates/d-check.yml`) und die Tests lesen über `emit.Enforce` / `emit.CommandFile` /
`emit.DCheckConfig` — den Weg des Werkzeugs, nicht einen im Test nachgebauten. `347` mutiert die
emittierte Prüfung und fällt über ihren Aufruf in `test/commit-msg-emission.bats`.

**Eine Randnotiz zur Kopie, nicht zum Fall:** in der Kopie ohne `.git` fällt zusätzlich
`not ok 181 driver: die Kopie traegt den Sensor-Bedarf inklusive .git` — das ist die fehlende
`.git` der Kopie und hat mit dem Gegenstand nichts zu tun.

### 4. Die zweite Aufzählung der Kennungs-Menge ist von keinem Sensor gebunden — Grundlage von F-3

Der emittierte Prüfer zählt die Menge in seiner Fehlermeldung ein **zweites** Mal auf
(`internal/emit/templates/enforce/commit-msg-traceability.sh:72`), während die Zusage sie an einer
Stelle führt. Die Stelle ist von keiner Prüfung gebunden:

```sh
sed -i 's@{ADR-NNNN, LH-XX-NN, MR-NNN, slice-N}@{ADR-NNNN, DC-NNNN}@' \
  internal/emit/templates/enforce/commit-msg-traceability.sh      # nur die Meldung, patterns= bleibt
make test-go                                                     # EXIT 0
make test-bats | grep -c '^not ok'                                # 1 — der .git-Artefaktfall der Kopie
```

Die Meldung nennt danach eine Menge, die der Prüfer nicht durchsetzt, und **kein** Lauf färbt rot.
Der Dogfood-Prüfer hat diese zweite Aufzählung nicht (sein Text endet mit der Regel-Quelle), die
emittierte Fassung hat sie neu eingeführt.

### 5. §1 des Plans gegen den Vollzug — Grundlage von F-2

```sh
git diff --name-only 8c1b87b8 446cc05d -- internal/ | wc -l          # 7
git show 446cc05d --stat --format="" | tail -1                       # 18 files changed, +839/-8
```

§1 führt unter „Ausdrücklich NICHT in diesem Slice" den Punkt *„Der Produkt-Code. Diese Eröffnung
schneidet; `internal/` wird von ihr nicht angefasst."* Der Diff liefert sieben Dateien unter
`internal/` und lässt §1 unberührt (der Plan-Diff zieht allein §3); §3 und die DoD (1)/(2) sind ohne
Änderungen unter `internal/emit/` nicht erfüllbar.

### 6. Die Idempotenz-Klasse der drei neuen Ziele — Grundlage von F-4

```sh
grep -c 'githooks' docs/plan/adr/0007-bootstrap-phasen.md            # 0
grep -n 'konvergent\|writeFileMode' internal/emit/enforce.go | head -5
#  der Schreibpfad ist writeFileMode (unbedingtes Überschreiben), kein skip-if-present
grep -rn 'EnforcePaths()\|CommandPaths()' --include=*.go . | grep -v _test | wc -l   # 0 Aufrufer
head -3 /Development/d-check/.githooks/commit-msg
#  "# commit-msg-Hook — Traceability-Gate via Modul commits (ADR-0027, slice-056)"
head -3 /Development/a-check/.githooks/commit-msg
#  "# commit-msg-Hook — die beiden Pending-Prüfungen, die einen Commit VOR seiner Entstehung betreffen"
```

Zwei der neuen drei Ziele sind von der Klassifikations-Tabelle der
[`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md) über Glob-Zeilen gedeckt
(`tools/harness/*`, `harness/mk/*.mk`). `.githooks/commit-msg` ist es nicht — die Tabelle nennt
keine `.githooks/`-Wurzel. Die zwei Repos desselben Baseline-Umfelds (`d-check`, `a-check`) tragen
dort **je einen eigenen** Träger mit eigener Kennungs-Klasse; der emittierte Prüfer nennt diesen
Fall in seinem Kopf und verweist auf `HOOKS_DIR`.

### 7. Der Gate-Lauf über dem committeten Stand

```sh
make gates          # EXIT 0
#  baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
#  d-check: 1445 Datei(en) geprüft, 0 Befund(e)
#  comment-claims: 63 Datei(en) geprueft, 0 Befund(e)
```

Die Gate-Behauptung der Commit-Message reproduziert auf dem committeten Baum. `make full-smoke` und
`make mutate` sind **nicht** gefahren (siehe Grenzen am Ende).

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der Abschnitt §Traceability sagt für das gebootstrappte Ziel „**dieselben zwei Träger, mit derselben Reichweite**" zu. In der Terminologie desselben Abschnitts (§Kopf „Die Regel hat zwei Träger", Tabelle mit PreToolUse-Guard und `.githooks`-Hook) sind das zwei Kanäle; das emittierte Ziel trägt **einen** — der PreToolUse-Commit-Message-Guard ist nicht Teil von `enforceFiles()`, fehlt in der emittierten `.claude/settings.json` und im emittierten Command-Guard. Auch in der Lesart „Hook + Prüfung" bleibt „dieselbe Reichweite" falsch: dem Ziel fehlt der Kanal, der ohne Aktivierungsschritt reist. Der eigene Slice-Plan sagt das Gegenteil derselben Sache (§1: der git-eigene Hook ist der Träger **im Ziel**, der PreToolUse-Kanal „bleibt hier"). | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · [`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 2 und 3 · `AGENTS.md` §3.1 (eine Ebene tiefer) | `harness/README.md:155` | ja — `grep -rln 'pretooluse-commit-msg' internal/ cmd/` (EXIT 1) und die emittierte `settings.json` zeigen die Träger-Menge; **kein** Gate-Lauf prüft die Aussage selbst | `doku-behauptet-traeger-den-das-emittierte-ziel-nicht-hat` |
| F-2 | MEDIUM | §1 bindet `internal/` aus („Diese Eröffnung schneidet; `internal/` wird von ihr nicht angefasst."), der Vollzug liefert sieben Dateien unter `internal/`, und §1 blieb stehen — nur §3 wurde im ausführenden Lauf gezogen. Der Plan widerspricht damit seinem eigenen Vollzug an der Stelle, die Review und Verifikation als Grenze lesen; §4 trägt den Widerspruch weiter („dieser Slice kann mit dem heutigen Kanal beginnen"), obwohl die Form entschieden ist. Die verschobene Out-of-Scope-Grenze ist nach §3.10 ein Übergabe-Artefakt an den Planner, und der Slice kann so nicht schließen. | `AGENTS.md` §3.10 · Baseline `v6.8.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice (Out-of-Scope-Klassen 1–4) | `slice-kennungs-waechter-geht-ins-ziel` §1 (Bullet „Der Produkt-Code") · §3 (Absatz „Der Träger wird nicht neu erfunden") · §4 (Absatz „Keine harte Bindung an `slice-215`") | nein — Träger ist der Rollen-Wechsel (Planner); kein Sensor liest §1 gegen den Diff | `out-of-scope-grenze-des-plans-bleibt-stehend-ueber-ihrem-vollzug` |
| F-3 | MEDIUM | Die Zusage „**Die Kennungs-Menge steht dort in der Zeile `patterns=` … und der Bootstrap legt keine zweite Fassung daneben ab**" ist weiter als ihr Sensor: `TestCommitMsgPruefung_IstDieEinzigeFassungDerMenge` misst genau **eine** Gestalt einer zweiten Fassung (kein `commits:`-Block in der emittierten Config). Der emittierte Prüfer führt die Menge an einer zweiten Stelle — in seiner Fehlermeldung —, und keine Prüfung bindet sie an `patterns=`; die Aufzählung dort lässt sich ändern, ohne dass ein Lauf rot wird (gemessen). Der Testname behauptet „die einzige Fassung", der Rumpf misst einen Sonderfall der zweiten. | `AGENTS.md` §3.6 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | `harness/README.md:167` · `internal/emit/templates/enforce/commit-msg-traceability.sh:72` · `internal/emit/commitmsg_test.go:174` | ja — `make test-go` bleibt über der geänderten Meldung grün (in diesem Lauf gefahren) | `zweite-ungebundene-aufzaehlung-der-kennungs-menge` |
| F-4 | MEDIUM | `.githooks/commit-msg` bekommt eine Idempotenz-Klasse (konvergent, das Ziel überschreibt die Datei bei jedem Lauf), für die die Klassifikations-Tabelle der [`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md) **keine Zeile** hat — sie nennt keine `.githooks/`-Wurzel. Die ADR bindet ihre Ausnahme „konvergent" an *„rein tool-eigene Infrastruktur, die der Adopter nicht editieren soll"* und setzt für den Zweifelsfall `skip-if-present` („nie Adopter-Inhalt clobbern"); `.githooks/` ist im Umfeld dieses Repos nachweislich ein Ort, an dem ein Adopter **seinen eigenen** Träger führt (zwei Nachbar-Repos, je eigene Kennungs-Klasse), und der emittierte Prüfer nennt genau diesen Fall über `HOOKS_DIR`. | [`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md) §Idempotenz über eine Artefakt-Klassifikation · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) | `internal/emit/commitmsg.go` (`commitMsgHookFile`, „KONVERGENT wie die uebrigen Fragmente") · `harness/README.md:157` („beide schreibt der Bootstrap kanonisch neu") | ja — `grep -c 'githooks' docs/plan/adr/0007-bootstrap-phasen.md` → 0 und der Schreibpfad sind lesbar; kein Gate prüft eine Idempotenz-Klassifikation | `emittierter-pfad-ohne-zeile-in-der-idempotenz-klassifikation` |
| F-5 | LOW | Die Commit-Message begründet die übernommene Form damit, „der Slice-Plan führt sie in Abschnitt 3 ausdrücklich als die zu übernehmende Form". §3 nennt `slice-215` als Entscheider; `ADR-0053` kommt im Plan **gar nicht** vor (`grep -c 'ADR-0053' <Slice-Plan>` → 0), und der Bezug-Block führt `ADR-0004` und `ADR-0028`. Der Sache nach trägt der Verweis (der Slice ist geschlossen, die ADR existiert), die benannte Stelle trägt ihn nicht. | Maintainability (Beleg-Kette) | Commit `446cc05d`, Message-Absatz „Die Form erbt die Emission von `ADR-0053` Festlegungen 1 bis 3"; `slice-kennungs-waechter-geht-ins-ziel` §3 | ja — `grep -c 'ADR-0053' <Slice-Plan>`; kein Gate prüft Commit-Message-Prosa | `beleg-beruft-sich-auf-eine-stelle-die-ihn-nicht-fuehrt` |
| F-6 | INFO | Die Dogfood-Fassung des Anweisungssatzes nennt weiter nur die `-F`-Konvention des Agenten-Kanals; den git-eigenen Träger und seinen Aktivierungsschritt nennt sie nicht, während die emittierte Fassung beides trägt. In diesem Klon ist der Träger nicht aktiv (`git config --get core.hooksPath` → Exit 1), und das ist nach [`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4 auch plausibel (die Werkzeug-Commits tragen keine Kennung); ob die Fassung das schweigend lassen darf, entscheidet die Rolle, der der Satz gehört. | [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) · [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) | `.claude/commands/implement-slice.md:37` | ja — der Zustand ist messbar; kein Gate prüft die Vollständigkeit des Satzes | `convention-des-commit-traegers-nicht-in-der-dogfood-fassung-des-anweisungssatzes` |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Die zwei Fassungen des Prüfers — die Vermutung dieses Auftrags („dieselbe Doppelung wie bei `slice-mv`, ohne vergleichenden Sensor")** | **geprüft, ohne Befund — REFUTED.** Der vergleichende Sensor liegt mit dem Diff vor: `test/commit-msg-emission.bats` hält `patterns=` als **Menge** in beide Richtungen und `exempt=` gegen die Dogfood-Fassung, fail-closed bei fehlender oder mehrfacher `^patterns=`-Zeile. Dazu die Gegenrichtung: `test/mutations/340` (Dogfood) und `test/mutations/347` (emittiert) fällen dieselbe Gruppe — in diesem Lauf nachgefahren (`not ok 53`). |
| **Die sieben Mutationsfälle `test/mutations/347`–`353`** | **geprüft, ohne Befund.** Alle sieben einzeln in einer Kopie außerhalb des Repos gefahren: jeder fällt rot, und der erwartete Wächter steht in der Fehlschlag-Ausgabe (§3). Kein Zahn baut seine Verdrahtung selbst nach — die sechs Go-Fälle treffen die eingebetteten Quellen, die die Tests über `emit.Enforce` / `emit.CommandFile` / `emit.DCheckConfig` lesen. |
| **`harness/tools/full-smoke.sh`, Abschnitt „Commit-Kennung"** | **geprüft, ohne Befund — gelesen, nicht gefahren.** Die Aussage-Kette (Dateien liegen, x-Bit, kein Gate, Aktivierung, drei Commit-Versuche, Reichweiten-Zeile) ist gegen die emittierten Vorlagen gelesen; die Nicht-Gate-Aussage hat ihre Vorbedingung (die `gates`-Kette muss erst tragen, was sie tragen muss) und die Platzierung am Lauf-Ende hat ihren Grund im Kommentar. Ein grüner Lauf ist damit **nicht** belegt — siehe Grenzen. |
| **Die Kommentare der vier neuen Quellen gegen `AGENTS.md` §3.7** | **geprüft, ohne Befund.** Jeder neue Kommentar trägt eine der fünf Klassen (Zusage · Kopplung · Abgrenzung · Grenze); keine Chronik-Prosa, kein Konjunktiv über eine verworfene Alternative, keine abwesende Fassung. Die Behauptung „der Shell-Lint dieses Repos fährt `internal/emit/templates/enforce/*.sh`" hält gegen den Shell-Lint-Zeilenbereich im `Makefile`. |
| **Der Aktivierungs-Pfad im Ziel** | **geprüft, ohne Befund.** `include harness/mk/*.mk` existiert im Ziel-Aggregator; das Fragment setzt `HOOKS_DIR ?= .githooks`, hängt an keinem `GATE_CHECKS` und meldet den fehlenden Träger selbst. Die zwei Pfade unter `tools/harness/` und `harness/mk/` sind von der Idempotenz-Tabelle der [`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md) über Glob-Zeilen gedeckt — die Ausnahme steht als F-4. |
| **Der Anweisungssatz des Ziels gegen den emittierten Träger** | **geprüft, ohne Befund.** Der neue Bullet der Vorlage nennt Ort, Aktivierungsschritt und die zwei Grenzen; er beschreibt genau den Träger, den `enforceFiles()` ablegt. |
| **[`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) auf `Proposed` als Form-Geber der Emission** | **geprüft, ohne Befund.** Die ADR nimmt die emittierte Ebene ausdrücklich von ihrem Gegenstand aus („was ein gebootstrapptes Zielrepo an Commit-Wächtern bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet") — dieser Slice ist dort die entscheidende Instanz, die ADR gibt allein die Form. Die HIGH-Klausel des Skills zielt auf **superseded** ADRs; keine ist hier berührt. |
| **§3 des Plans gegen den Vollzug** | **geprüft, ohne Befund.** Die zwei gezogenen Stellen stimmen mit dem gelieferten Stand und mit der emittierten Fassung; abweichend sind allein §1 und §4 (F-2). |
| **Ein halluziniertes Gate** | **geprüft, ohne Befund.** Der Diff führt kein neues `make`-Ziel in `harness/README.md` §Sensors ein; `make hooks-install` steht dort bereits als Werkzeug mit `kein Gate`, und der emittierte Ziel-Aggregator führt `hooks-install` nicht in der `gates`-Kette. |
| **Der Gate-Lauf über dem committeten Stand** | **geprüft, ohne Befund.** `make gates` → Exit 0 (§7); die Zahlen der Commit-Message (`1445` geprüfte Dateien, `0` Befunde, `54` Baseline-Dateien) reproduzieren. |
| **`harness/conventions/**` und die Welle-Closure** | **nicht Gegenstand dieses Laufs** (Architect-Eigentum bzw. Auftrags-Grenze); `MR-057`/`MR-059` sind nicht geprüft. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 3 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** `doku-behauptet-traeger-den-das-emittierte-ziel-nicht-hat` ·
`out-of-scope-grenze-des-plans-bleibt-stehend-ueber-ihrem-vollzug` ·
`zweite-ungebundene-aufzaehlung-der-kennungs-menge` ·
`emittierter-pfad-ohne-zeile-in-der-idempotenz-klassifikation` ·
`beleg-beruft-sich-auf-eine-stelle-die-ihn-nicht-fuehrt` ·
`convention-des-commit-traegers-nicht-in-der-dogfood-fassung-des-anweisungssatzes`

Alle sechs Klassen sind in diesem Lauf **neu vergeben** (keine zitiert einen bestehenden
Register-Eintrag). Die Zuordnung zu `BEO-<KUERZEL>/<slug>` und das Anlegen der Belege sind Sache der
Slice-Closure (§7), nicht dieses Reports. Die zwei Wellen-Geschwister-Klassen
(`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`,
`waechter-abdeckung-haengt-an-uninstruierter-konvention`) sind in diesem Lauf **nicht** um ein
Auftreten gewachsen — die erste ist widerlegt, die zweite bleibt unberührt.

## Verdikt

**Merge-blockierend: ja — F-1 (HIGH) und F-2, F-3, F-4 (MEDIUM).**

F-1 ist der schwerere Befund und **nicht** herabgestuft. Er trifft nicht die Emission — die ist in
sich stimmig, und ihre Zähne halten (§3) —, sondern den Satz, mit dem der Diff sie beschreibt: Im
Abschnitt, den [`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
Festlegung 3 als **Deklaration des Trägers** führt, sagt der Text für das Ziel zwei Kanäle zu, wo
das Ziel einen hat. Wer das Ziel liest — Adopter wie Rolle — rechnet mit einer Deckung ohne
Aktivierungsschritt, die dort nicht liegt. Der eigene Slice-Plan widerspricht dem Satz bereits (§1:
der Agenten-Kanal „bleibt hier"); es ist also kein Streit über eine Auslegung, sondern eine Aussage
gegen den Stand, den derselbe Diff herstellt. Die Klasse ist die, gegen die dieser Slice antritt:
eine Zusage, deren Reichweite weiter ist als ihr Prüfbereich.

F-2 betrifft nicht das Gelieferte, sondern den Plan, gegen den Review und Verifikation messen: §1
schließt `internal/` aus, §3 und die DoD verlangen es, der Vollzug liefert es und §1 steht
unverändert daneben. Der Implementer hat die Grenze als Übergabe-Artefakt gemeldet und **nicht**
selbst umgeschrieben — die Buchstaben von §3.10 sind damit gehalten, weshalb hier MEDIUM und nicht
HIGH steht. Was fehlt, ist der Adressat: ohne die Planner-Entscheidung schließt der Slice mit einem
Plan, der seinem eigenen Lieferumfang widerspricht. Fällt die Auflösung zwischen zwei Rollen
streitig aus, ist das der Konflikt-Pfad (`v6.8.0` · `regelwerk/modul-08-agentenrollen.md`
§Konflikt-Pfad als Rollen-Sequenz), keine Herabstufung.

F-3 ist die einzige Stelle, an der eine **Zusage des Diffs** enger gemessen wird als sie lautet; die
Messung dazu ist in diesem Lauf gefahren (§4). F-4 ist eine Entscheidung, die der Diff faktisch
trifft (konvergent), ohne dass die Tabelle der [`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md)
den Ort führt und ohne dass die Zweifelsregel derselben ADR sichtbar abgewogen wurde — die zwei
Nachbar-Repos zeigen, dass die Wurzel nicht selbstverständlich tool-eigen ist. Beide brauchen eine
Entscheidung, keine Zeile Code.

F-5 und F-6 tragen nicht blockierend: F-5 ist eine Beleg-Kette im Commit-Text, deren Sache stimmt
und deren Adresse nicht; F-6 ist eine ausdrücklich benannte Lücke außerhalb des Lieferumfangs
dieses Slice, mit Verweis auf die Rolle, der der Anweisungssatz gehört
([`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).

**Was dieser Report nicht entscheidet:** wie die Träger im Ziel benannt werden (F-1) · ob §1 gezogen
oder der Lieferumfang beschnitten wird (F-2, Planner) · ob die Meldung des Prüfers gebunden oder die
Zusage enger gefasst wird (F-3) · welche Idempotenz-Klasse `.githooks/commit-msg` bekommt und wo sie
deklariert wird (F-4) · ob und wie die Dogfood-Fassung des Anweisungssatzes nachzieht (F-6).

**Was dieser Report nicht geprüft hat:** `make full-smoke` (nicht gefahren — der Abschnitt
„Commit-Kennung" ist gelesen, seine Wirkung im gebootstrappten Ziel ist damit **nicht** belegt; der
Wellen-Closure-Trigger fährt ihn) · `make mutate` (Post-integration, nicht gefahren) · die
Idempotenz-Wirkung aus F-4 an einem realen Adopter-Lauf (aus dem Schreibpfad und den zwei
Nachbar-Repos gelesen, nicht gefahren) · die DoD-Konformität als solche (Modul 11, anderer
Eingabe-Kontext) · `harness/conventions/**` und die Wellen-Closure (Auftrags-Grenze) · die zwei
benachbarten offenen Wellen.
