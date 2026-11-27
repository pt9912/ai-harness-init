# Verifikation — slice-ci-runner-ohne-docker (welle-ohne-docker)

**Verifier-Lauf:** frisch, frischer Kontext (Plan und Review-Report gelesen, Rot-/Run-Belege eigen-händig)
**Code-Stand:** HEAD `b20ffd8b` (main); Kette seit Claim `823d7f9e` — Implementer `381f2a0e`…`cd50eff4` (7), Review `12d76841`, Behebung `cb965055`/`bc46815d`/`678e4f7e`/`6f0b50ca`/`b20ffd8b`
**Review:** `docs/reviews/2026-11-27-slice-ci-runner-ohne-docker.md` (F-1 MEDIUM, F-2 MEDIUM, F-3/F-4/F-5 LOW, F-6/F-7 INFO)
**Betriebsform:** docker-los am Host (Linux); alle Läufe über make-Ziele; kein Commit, kein Push, kein Netz

---

## Urteile je DoD-Punkt (§2, Stand `b20ffd8b`)

- **Liefer-Punkt 1 — Setup-Steps gemäß Inventar-Pins, kein Job setzt den Daemon voraus, Tag-Workflow bleibt gepinnt: BESTÄTIGT (hermetische Form).** Läufe L-1 … L-4 unten; Plan-vs-Code: die je-Job-Setup-Schritte stehen an `ci.yml` (gates · smoke · full-smoke), `mutate.yml` (shard) und `mutate-branch.yml` (shard); der Carrier-Tisch `make dcheck-fetch` je Job; kein Soll-Literal in den drei Workflows und im Skript (F-1-Korrektur: die Bindung liest die Werkzeug-Menge aus dem Inventar, `soll_anker` — ein künftiger Pin-Wert fällt unter dieselbe Bindung, Rot-Beleg B-1); der d-check-Carrier trägt `make dcheck-fetch` (Fall 5); release.yml bleibt im gepinnten Bild (Rot-Beleg B-4).
- **Liefer-Punkt 2 — ein Push/PR-Lauf (`ci.yml`) läuft grün docker-los, full-smoke-Job als Rest-Spur: NICHT BESTÄTIGT AM VERIFIER-LAUF — der Träger ist der reale Runner-Lauf (CI auf dem frischen Klon am Push).** Die hermetische PLAN-Probe (L-3, L-4) und die Review-Übergabe sind Vorbereitung, kein Beleg — der reale Push-Lauf trägt die Zusage, nichts am lokalen Lauf kann ihn ersetzen. Wichtige Grenze für den Träger: der reale CI-Lauf fährt dieselbe Vorbestand-Rotmenge (128 Befunde, lint, shell-lint, bats 158/281, test-go 2 Klassen — siehe Abschnitt Gates); solange die steht, ist die LP2-„grün"-Zusage an CI rot — nicht am Diff, aber am Bestand. Die Trennung (Gates-/Smoke-Kette docker-los; full-smoke-Job an der daemon-gebundenen Rest-Spur, Ausgang beim Nehmer) steht nach der F-2-Korrektur je in Plan §1, LP2 und §5 — Plan und Code sagen jetzt dasselbe.
- **Liefer-Punkt 3 — Nacht-Workflow fährt einen Shard docker-los grün, mutate-branch-Schritte wirksam: NICHT BESTÄTIGT AM VERIFIER-LAUF — derselbe Träger (reale CI-Messung: Wall-Clock und je-Case-Ausgang).** Hermetische Vorstufe: die Wächter-Fälle 2, 3, 5 tragen die Setup-/Carrier-Form der Shard-Jobs (grün, L-2); `make mutate-greift` grün 802/802; der Mutations-Branch-Weg ist als Posten offen (M-1 unten).
- **`make gates` grün: NICHT ERFÜLLT am Stand — rot an vorbestehenden Klassen, keine aus dem Slice-Diff.** Siehe Abschnitt Gates.
- **Review durchgeführt, Report unter docs/reviews/: ERFÜLLT** (`12d76841`, F-1..F-7, Rollenwechsel nach dem Implementer-Lauf, kein Self-Review).
- **Doku-Update (`gates.md`/`mutate.md`): OFFEN (Nehmer)** — die DoD-Zelle verweist bereits auf den Nehmer (Doku-Nachzug-Slice); die Zelle bleibt bis dessen Lieferung offen.
- **Closure-Notiz mit Lerneintrag: OFFEN (Planner-Closure)** — §7 leer, wie geplant.
- **Beobachtungs-Register fortgeschrieben: OFFEN (Planner-Closure)** — `make register-ausgang` am Head: 292 Einträge, 83 über der Schwelle, 0 Befunde; der Stand des Bestands bleibt; die Mess-Belege dieses Laufs (Bruchproben B-1 … B-4, PLAN-Idempotenz) gehen in `evidence/` bei der Closure. Kein Zähler gesetzt — Form hält die DoD-Zelle.
- **Jedes Risiko aus §6 trägt einen Ausgang: OFFEN (formal, Closure); inhaltlich widerlegt/entwaffnet:** Risiko 1 (Setup weicht vom Inventar-Pin ab) — der Setup liest das Soll aus dem Inventar (`soll()`, Spalte 4), Fall 6 färbt über dem künftigen Soll-Literal rot (B-1); Risiko 2 (Shard-Zeiten docker-los) — trägt die reale Messung (LP3-Träger), Vergleichswert-Bestand (Zwei Register-Einträge des Plans §8) bleibt 1× unter der Schwelle.
- **Drei Paarungen: bei der Welle-Closure zu prüfen** — Form hält die DoD-Zelle.

## Gates (Vorbestand-Differenz gegen den Claim, byte-gemessen)

- **`make gates` (HEAD): EXIT 2** — bricht an der ersten rot-gefärbten Stufe `docs-check-host`: **3091 Datei(en), 128 Befund(e)**.
- **`docs-check-host` am Claim (`823d7f9e`, Worktree, mit dem gepinnten Carrier vom Haupt-Repo): EXIT 2 — 3090 Dateien, 131 Befunde.** Zeilen-Kollation der zwei Befundlisten (`diff`): der Net-Unterschied sind **genau 3 Befunde weniger am HEAD** — die drei praeixlosen `slice-doku-nachzug-ohne-docker.md`-Verweise (`done/slice-mutate-treiber-host-modi.md` Zeile 28, 86; Plan-Datei Zeile 71), Reparatur des Planer-Verweis-Commit `3dfd114d`. **Kein neuer Befund über irgendeiner der geänderten Dateien.**
- **Zwei Befunde über der Plan-Datei sind Vorbestand:** Plan Zeile 22 (Platzhalter-ADR-0109-Link, `target-missing`) und Zeile 40 (`MR-014` ohne Definition-Link) — beide byte-identisch am Claim (`git show 823d7f9e:…` gemessen). Grenznots: der `<!-- d-check:ignore -->`-Kommentar an Zeile 22 **wirkt dort nicht** — der Befund bleibt stehen (Posten O-7).
- **`make lint`: EXIT 2 — rot, vorbestehend:** `gochecknoglobals: 1` am `inventoryBasissatz` (`internal/emit/environment.go:57`, Vorgänger-Commit `9bd6f440`, F-6 des Reviews). Kein diff-naher Befund.
- **`make test`: EXIT 2 (Voll-Sweep)** — 1..664, 662 ok, **genau 2 rot: Fall 158** (`halter: die committete Tabelle…`) und **Fall 281** (`d-check.yml: jede Top-Level-ignore-refs-Ausnahme…`) — deckungsgleich mit den zwei Vorbestand-Klassen der Übergabe („158/281"); kein Fall im Diff.
- **`make test-go`: EXIT 2 — zwei Klassen, vorbestehend:** `TestStopHook_CommitBindung` (`internal/emit`, dogfood-Unterfälle) und `TestGoProfile_PinsMatchRepo` (`internal/gen`) — deckungsgleich mit dem Review.
- **`make shell-lint`: EXIT 2 — rot, vorbestehend:** SC2016 ×6, SC2254 ×5 (Bestand-Dateien); **0 Meldungen** über ci-runner-Dateien (`grep -c ci-runner` → 0).
- **`make comment-claims`: grün** — 107 Dateien, 0 Befunde. **`make register-ausgang`: grün** — 292/83/0. **`make mutate-greift`: grün** — 802 Fall/Fälle, 802 greifen, 0 Befunde (Fall 818 = der 802.).
- **`make ci-lint`: EXIT 0** (Wächter-Syntax grün über die fünf Workflows).

## Verifikations-Beleg-Liste (Läufe dieses Laufs, docker-los am Host)

- **L-1** `make ci-lint` → EXIT 0.
- **L-2** `make test-bats BATS_TARGET=test/ci-runner-ohne-docker.bats` → `1..8`, 8 ok.
- **L-3** `CI_RUNNER_SETUP_PLAN=1 make ci-runner-setup` → EXIT 0; je Werkzeug `Soll · Ist — Entscheidung`: go 1.27.4 am PATH — OK · golangci-lint v2.15.0 am PATH — OK · bats/shellcheck/actionlint anwesend — OK; kein Install aufgerufen.
- **L-4** PLAN-Idempotenz im Scratch (Klon `/tmp/vcr`, geräumt): PATH ohne go-Fassung, ohne PREFIX-Ablage → `go · Soll 1.27.4 · Ist fehlt — Install ausgesetzt (PLAN)` (Stilvorbereitung, kein Install); mit Ablage in der F-3-Form (Toolchain-Baum `.harness-ci/go-1.27.4/bin/go` + Symlink `.harness-ci/bin/go`) → `go · Soll 1.27.4 · Ist 1.27.4 — im PREFIX — OK`; **zweiter Zug: byte-gleiche Meldung** — die Idempotenz-Form greift in beide Richtungen (Kontrast-Belege über der realen Quelle, Stubs im Scratch; der reale Install-Zweig trägt LP2/CI, Grenze im Skriptkopf).
- **Rot-Belege (Bewusstes Brechen, je einmal an der realen Quelle, im /tmp-Klon, je mit Rücksetzung):**
  - **B-1 (Fall 6, künftiges Soll-Literal, URL-Form):** der sed-Zug des kuratierten Falls 818 (go-Download-Zeile mit `1.30.0` am ci-runner-setup-Stück der ci.yml) → **`not ok 6`**. Die F-1-Eigenschaftsform hält: ein künftiger Pin-Wert färbt rot, die heutige Werte-Menge ist kein literal im Wächter.
  - **B-2 (F-1-Nennungs-Form, Gegenprobe):** Kommentarzeile `# probe go 1.31.0` an ci.yml → **8 ok** — ein Kommentar nennt einen Wert, ohne ihn zu fahren; die Zusage `# probe`-Lesart wird nicht zur Soll-Nennung gemessen.
  - **B-3 (M2):** `docker run`-Step in ci.yml → **`not ok 4`** (Daemon-Freiheit).
  - **B-4 (M5):** `release-artifacts`-Zug aus release.yml gezogen → **`not ok 8`** (Tag-Workflow-Grenze).
  - Die kuratierte Fall-Anlage trägt Fall 818 (`test/mutations/818-…`, `# files:` ci.yml, `# expect:` nennt Fall 6); die einzelfall-Anlage-Messung über `make mutate MUTATE_CASES` fuhr dieser Lauf nicht — der Fall-Kopf benennt seine Grenze selbst: der Grün-Vorlauf bricht an den vorbestehenden bats-Klassen, die kuratierte Rot-Form trägt der Lauf nach dem Vorbestand-Fix.

## Mutations-Branch (M-1 — Posten, keine Messung verfälscht)

- `make mutate-auswahl` (`SLICE=slice-ci-runner-ohne-docker`): **62 Fälle über `823d7f9e..HEAD`** (Schwelle 8 lokal), Fall `818-ci-runner-soll-literal-gepinnt-im-workflow` in der Menge; Urteil **CI-Branch** — `make`: **Fehler 10, EXIT 2**, Aufrufszeile: `git push origin HEAD:refs/heads/mutate/slice-ci-runner-ohne-docker-b20ffd8b`.
- **Kein Push vollzogen** (kein Netz, keine Rolle-Push-Zusage; `git ls-remote origin 'refs/heads/mutate/slice-ci-runner-ohne-docker*'` → leer). Der Branch-Posten ist an den CI-Auftraggeber; `mutate-ergebnis.txt` ist auf diesem Weg nicht abholbar — kein Befund (kein Branch existierte, Fall-818-Kopf trägt die Grenze).

## Plan-vs-Code je DoD-Punkt (beide Richtungen)

- **LP1 ↔ Code:** Plan §3 nennt die vier Workflow-Updates und den Wächter; Code trägt die Setup-/Carrier-Schritte je Job, den GRENZE-Kommentar des Tag-Workflows (Zustand, Grenze, Träger in Indikativ-Form) und das Skript mit der Inventar-Soll-Lese (Spalte 4), `PLAN`-Modus, Grenzkopf. **Gebautes ohne Plan:** nichts über die Plan-Zeile hinaus — `ci-runner-setup`-Makefile-Ziel trägt seinen `## `-Hilfetext und die `exempt-targets`-Zeile in `.d-check.yml` (keine Senkung: das Ziel ist reines Utility, Form gegen den Bestand von der Übergabe gemessen — 129 Befunde mit gestrichenem Eintrag vs 128 am Bestand, Review-Beleg; diese Lauf-Messung: 128 am Gate bestätigt). `.gitignore` trägt `.harness-ci/` mit Grenzkommentar (scan.ignore respektiert .gitignore nicht, hier steht kein gescannter Text) — keine Senkung.
- **LP2 ↔ Code:** nach F-2-Korrektur LP-Zelle, §1-Rest-Spur-Zeile (mit Nehmen-Kennung) und §5-Closure-Trigger denselben Zustand wie der Code (GRENZE-Kommentar am full-smoke-Job; Kopf-Kommentar nennt beide Rest-Spuren am Namen: full-smoke + adr-immutable, F-4-Korrektur).
- **LP3 ↔ Code:** mutate.yml-Setup-Step, Carrier-Preposition in mutate-branch.yml, `DCHECK_CARRIER`-Zug liest den absoluten Ablage-Pfad desselben Pins; Fall 2/3/5 grün.
- **Gebautes ohne Plan:** der `upstream-drift.yml`-Grenze-Block (F-5-Korrektur: Befund-Kommentar + Plan-§1-Ausschluss-Zeile) — Plan und Code denselben Gegenstand, beide Richtungen bedeckt.

## Verifikation der Review-Findings (je korrigiert nachgelesen)

- **F-1 (MEDIUM): bestätigt und geheilt.** Die Wächter-Fälle 6/7 messen die Eigenschaft (`soll_anker` liest die Werkzeug-Menge aus dem Inventar); Rot-Belege B-1/B-2 beide Richtungen am Bestand. Die Rest-Reichweite (Kommentar-Nennung, Fall 818-Mutation-Entstehung) steht je als Grenze am Ort (Wächter-Kopf, Fall-Kopf).
- **F-2 (MEDIUM): bestätigt und geheilt.** Plan-§2/§1/§5 tragen die Trennung (Plan-Zug `6f0b50ca`).
- **F-3 (LOW): bestätigt und geheilt** — L-4: die F-3-Form (Toolchain-Baum + Symlink an `$PREFIX/go`) greift, die `im PREFIX — OK`-Meldung lebt; beiden Richtungen idempotent gemessen. Der reale Install-Zweig trägt CI (Grenze am Skriptkopf).
- **F-4 (LOW): bestätigt und geheilt** — der Kopf-Kommentar von ci.yml trägt beide Rest-Spuren am Namen (`678e4f7e`); kein gegensätzlicher Satz im selben File mehr.
- **F-5 (LOW): bestätigt und geheilt** — Plan-§1-Ausschluss-Zeile + Befund-Kommentar am `upstream-drift.yml` (`b20ffd8b`).
- **F-6 (INFO): bestätigt, offener Posten** — `gochecknoglobals: 1` am `inventoryBasissatz` (meine Messung deckungsgleich); Trägerschaft je Übergabe.
- **F-7 (INFO): bestätigt, offener Posten** — die Probe-Gleichziehung ist am Ort gelesen (identische Probe-Formen: `environment-check.sh` exakt-Zweig ≙ `version_ist`), nicht durch einen kuratierten Fall getragen; Träger bleibt der gelesene Lauf.
- **Fall 606 (exempt-Eintrag): Übergabeform** — die Entstehung rot sah der Review-Lauf (129 vs 128 Befunde); meine Messung bestätigt die 128 am Gate, ohne die Probe nachzufahren (kein Nachbeleg).

## Offene Posten für die Closure (Planner) bzw. Architektur

- **O-1 — F-6 lint-Vorbestand** (inventoryBasissatz): steht am HEAD rot; der reale CI-Push-Lauf fährt daran rot — vor der LP2-Lese klären (Fix oder benannte Trägerschaft).
- **O-2 — CI-Branch-Push (M-1):** 62 Fälle, Branch-Name `mutate/slice-ci-runner-ohne-docker-b20ffd8b` (Tip `b20ffd8b`); kein Push dieses Laufs; Abholform `git fetch origin mutate/slice-ci-runner-ohne-docker-b20ffd8b && git show FETCH_HEAD:mutate-ergebnis.txt`; nach dem Lesen den Branch und die älteren desselben Slice räumen.
- **O-3 — LP2/LP3 reale Runner-Läufe:** der Träger ist CI (Push-Lauf + Nacht-Shard); Wall-Clock und je-Case-Ausgang in dessen Beleg; die hermetische PLAN-Form ist Vorbereitung.
- **O-4 — Vorbestand-Klassen:** bats 158/281 · test-go 2 Klassen · shell-lint (SC2016/SC2254, Bestand-Dateien) · docs-check 128 — byte-identisch Claim ↔ HEAD (keine aus dem Diff); als Träger der LP2-Grün-Zusage an CI benannt.
- **O-5 — Doku-Nachzug (F-4/F-5-Posten)** beim Nehmen-Slice; die Sensor-Zellen (`gates.md`, `mutate.md`) tragen die CI-Verhältnis-Form bis dahin nicht.
- **O-6 — Fall 818 kuratierte Entstehung:** die Vorbestand-Grenze steht am Fall-Kopf; die Rot-Form trägt der Lauf nach dem Vorbestand-Fix (Welle).
- **O-7 — Plan-Placehold-Link (Zeile 22):** der `<!-- d-check:ignore -->`-Kommentar wirkt dort nicht (Befund bleibt); der reale ADR-0109-Pfad existiert (`0109-gates-lauefer-docker-los-image-weg-opt-in.md`) — Umzug des Platzhalters auf die reale Datei wäre ein Planzeilenzug, die `<!-- -->`-Zeile trägt den Ort.
- **O-8 — Beobachtungs-Register:** die Bruchproben dieses Laufs (B-1 … B-4, L-4) in `evidence/` bei der Closure ergänzen; kein Zähler gesetzt (DoD-Form).

## Sensors dieses Laufs

make docs-check-host (HEAD 3091/128 · Claim 3090/131, Zeilen-Kollation) · make lint · make test (Voll-Sweep 664-er) · make test-go · make shell-lint · make ci-lint · make comment-claims · make register-ausgang · make mutate-greift (802/802) · make test-bats Einzellauf (8/8) · `CI_RUNNER_SETUP_PLAN=1 make ci-runner-setup` (L-3, L-4) · `make mutate-auswahl` (Exit 10, CI-Branch) · Bruchproben B-1..B-4 im /tmp-Klon (je mit Rücksetzung, Scratch geräumt).
