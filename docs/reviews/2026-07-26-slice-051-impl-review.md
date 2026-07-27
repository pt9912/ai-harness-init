# Review-Report: slice-051 — 2026-07-26

**Review-Art:** Code — geprüft wird der Diff gegen **Plan + aktive ADRs + Hard Rules +
Konventionen** (Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung
(Modul 11, getrennter Kontext, anderes Prüf-Artefakt).

**Gegenstand:** slice-051 „`artifact`/`release-artifacts` legen `DEST` an — mit Wächter",
Commit-Range `14773e5..HEAD` — drei Commits: `c2349a0` (Plan geschnitten),
`7277c43` (reiner Lifecycle-Move `open → in-progress`, 0 Insertions/0 Deletions),
`00bb7c3` (Implementation). Diffstat der Implementation: `harness/tools/artifact-copy.sh`
neu (39 Zeilen) · [`Makefile`](../../Makefile) −9/+2 · [`.github/workflows/release.yml`](../../.github/workflows/release.yml) −1 ·
[`test/release-matrix.bats`](../../test/release-matrix.bats) +57 · `test/mutations/86-artifact-dest-mkdir.sh` neu (21 Zeilen) ·
[`docs/user/benutzerhandbuch.md`](../user/benutzerhandbuch.md) 1 Zeile · [`roadmap.md`](../plan/planning/in-progress/roadmap.md) 8 Zeilen.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-26 · **Frischer Kontext**, getrennt von
Implementation und Verifikation.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf
nicht reproduzierbar):

- Slice-Plan: `in-progress/slice-051-artifact-dest-anlegen.md`
  (§1 Ziel, §3 Plan, §4 Trigger, §6 Risiken — §2 DoD gelesen, aber **nicht** als Prüfmaßstab
  verwendet; das ist Modul 11)
- berührte `LH-*`-IDs: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die Release-Binaries entstehen über genau
  diese Targets), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Wächter über leerem Prüfbereich),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit)
- aktive ADRs: [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (native Binaries, Docker-only) — im Diff **nicht**
  geändert, Hard Rule 3.4 damit gewahrt
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules 3.1–3.6) — vollständig gelesen
- Konventionen: [`harness/conventions.md`](../../harness/conventions.md) — [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung), [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
- **Vorherige Findings am gleichen Modul (Pflicht-Punkt 5):** die fünf slice-050-Runden
  ([Runde 1](2026-07-26-slice-050-impl-review.md), [Runde 2](2026-07-26-slice-050-impl-review-runde-2.md),
  [Runde 3](2026-07-26-slice-050-impl-review-runde-3.md), [Runde 4](2026-07-26-slice-050-impl-review-runde-4.md),
  [Runde 5](2026-07-26-slice-050-impl-review-runde-5.md)) — dominante Klasse: **„Zusage weiter
  als Abdeckung"** ([`AGENTS.md`](../../AGENTS.md) §3.6), mehrfach als ungeprüfter Allquantor.
  **Die Klasse kehrt hier wieder** — zweimal (F-1, F-2), beide Male in einer Zusage, die dieser
  Slice selbst neu formuliert bzw. in eine jetzt messbare Einheit verschoben hat.
- Rollen-Vertrag: `.harness/skills/reviewer.md`, <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
  `.harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md` (beide vollständig gelesen)

**Eigene Sensoren (lesend, Docker-only nach [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)):**

- `make gates` → **Exit 0** (selbst gefahren; shellcheck und actionlint ohne Ausgabe).
- `make test` → **110 `ok`, 0 `not ok`**; die drei neuen Wächter laufen real als
  `ok 96 / ok 97 / ok 98`.
- **Kein** `make mutate`, nichts Mutierendes (Auftragsgrenze).
- **Eigene Stub-Läufe außerhalb des Repos** (Scratchpad unter `/tmp`, das Repo nur lesend):
  `harness/tools/artifact-copy.sh` original / ohne `mkdir -p` / ohne `trap` / mit
  abgeschwächtem Argument-Guard, je gegen einen protokollierenden `docker`-Stub.
- **Eine reale Messung mit Daemon** (`docker create ai-harness-init:build true` +
  `docker cp` in ein fehlendes Verzeichnis; Container danach entfernt) — für F-3.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills**. Sortiert nach Schwere.

### F-1 — Die Aufräum-Zusage des extrahierten Skripts hat kein rot gesehenes Gegenbeispiel

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („Keine Zusage ohne rot gesehenes Gegenbeispiel"); Reviewer-Skill
  §MEDIUM „fehlende Negativtests bei neuem öffentlichen Vertrag"
- `pfad`: `harness/tools/artifact-copy.sh:38` (der `trap`) i. V. m. [`Makefile:61`](../../Makefile)
  („Der Container wird immer aufgeraeumt (trap), auch wenn `docker cp` scheitert.") und
  [`test/release-matrix.bats:194-204`](../../test/release-matrix.bats) (`rm)`-Arm des Stubs)
- `befund`: Der Stub trägt einen `rm)`-Arm, protokolliert den Aufruf aber nicht, und keine der drei
  Assertionen und kein Mutations-Fall beobachtet, ob `docker rm` je läuft. Gemessen: die Fassung
  **ohne** Zeile 38 lässt alle drei Wächter grün (`status=0`, Verzeichnis da, Datei da) und ruft
  `docker rm` nachweislich nie — protokollierender Stub: mit `trap` → `create · cp · rm -f cid-fake`,
  ohne `trap` → `create · cp`. Die Zusage aus [`Makefile:61`](../../Makefile) ist damit genau in der Einheit
  unbewacht, die der Slice zwecks Prüfbarkeit geschaffen hat.
- `verifizierbar`: **ja** — `sed -i '/^trap /d' harness/tools/artifact-copy.sh`, dann `make test`:
  bleibt grün (110 ok). Ein Mutations-Fall mit diesem Sed liefe in `make mutate` als
  „blieb GRUEN — hat keine Zaehne mehr" auf.

### F-2 — Test-Name behauptet „alle drei Argumente", gemessen wird nur das fehlende dritte

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („Ein Test, dessen Name eine Eigenschaft behauptet, muss die
  Eigenschaft messen, nicht ihre heutige Implementierung.")
- `pfad`: [`test/release-matrix.bats:238-241`](../../test/release-matrix.bats) — `@test "release: artifact-copy verlangt alle
  drei Argumente (Exit 2)"`
- `befund`: Der Test ruft das Skript mit **zwei** Argumenten und prüft Exit 2; die Fälle „Image
  leer" und „Zielverzeichnis leer" werden nicht gemessen, obwohl der Name sie mitträgt. Gemessen:
  reduziert man den Guard in `harness/tools/artifact-copy.sh:29` auf `if [ -z "$name" ]; then`,
  liefert die Assertion des Tests weiterhin Exit 2 (Wächter grün), während
  `artifact-copy.sh "" <dir> <datei>` dann mit **Exit 0** durchläuft statt mit dem zugesagten
  Aufruf-Fehler 2. Das ist die dominante Klasse aus den fünf slice-050-Runden, hier im Test-Namen
  statt in Prosa.
- `verifizierbar`: **ja** — Zeile 29 auf `if [ -z "$name" ]; then` reduzieren, `make test`:
  bleibt grün (der Test kann den geschwächten Guard nicht sehen).

### F-3 — Der Skript-Kopf schreibt `docker cp` einen Exit-Code zu, den `make` erzeugt

- `kategorie`: LOW
- `quelle`: Maintainability (Doku-Drift / falsch attribuierte Messung)
- `pfad`: `harness/tools/artifact-copy.sh:16-17` — „`docker cp` bricht dann mit `invalid output
  path: …` ab **(Exit 2)**"
- `befund`: Real gemessen mit Daemon: `docker cp <cid>:/out/ai-harness-init <fehlendes-dir>/datei`
  endet mit **Exit 1**, nicht 2. Die 2 stammt aus der Plan-Messung §3, wo sie ausweislich der Zeile
  `make: *** [Makefile:64: artifact] Fehler 1` **`make`s eigener** Abbruch-Code ist („Fehler 1" =
  Rezept-Status 1). Der Kommentar verschiebt damit eine gemessene Zahl auf die falsche Quelle.
- `verifizierbar`: **ja** — `docker create ai-harness-init:build true` + `docker cp` in ein nicht
  existierendes Verzeichnis, Exit-Code ablesen (1).

### F-4 — Die Commit-Message führt einen Rot-Lauf als Ausgabe, die so nicht ausgegeben wurde

- `kategorie`: LOW
- `quelle`: Maintainability (Beleg-Treue; Repo-Norm „autoritative Ausgabe verbatim spiegeln oder
  darauf zeigen"), [`AGENTS.md`](../../AGENTS.md) §3.6 (der Rot-Beleg ist die tragende Zusage des Slice)
- `pfad`: Commit `00bb7c3`, Message-Block „DER WAECHTER WURDE ZUERST ROT GESEHEN"
- `befund`: Der zitierte Block nennt `ok     12 release: artifact-copy schreibt auch in ein
  BESTEHENDES Verzeichnis`; der Test im Baum heißt „… BESTEHENDES **Ziel**verzeichnis"
  ([`test/release-matrix.bats:225`](../../test/release-matrix.bats)), und bats setzt in TAP keine Ausrichtungs-Leerzeichen
  hinter `ok`. Der Block ist eine nachformatierte Wiedergabe, wird aber als Lauf-Ausgabe geführt.
  Die Nummern 11/12 sind plausibel (die Datei trug vor dem Slice 10 Tests, gemessen), die Substanz
  ist über Mutations-Fall 86 reproduzierbar — nicht aber das Zitat selbst.
- `verifizierbar`: **ja** — `grep -F "BESTEHENDES Verzeichnis" test/release-matrix.bats` findet
  nichts; `git show 14773e5:test/release-matrix.bats | grep -c '^@test'` = 10.

### F-5 — Der von README/Handbuch vorgeschriebene Aufruf hinterlässt jetzt ein ungetracktes `bin/`

- `kategorie`: LOW
- `quelle`: [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) (Working-Tree-Hash ist inhaltsbasiert über getrackte **und**
  untracked Dateien); Maintainability
- `pfad`: `.gitignore` (führt nur `.harness/state/`) i. V. m. [`README.md`](../../README.md) Zeile 48 /
  [`docs/user/benutzerhandbuch.md`](../user/benutzerhandbuch.md) Zeile 132 (`make artifact DEST=./bin`)
- `befund`: Vor dem Fix brach der dokumentierte Aufruf im Repo ab und legte nichts an; jetzt
  entsteht ein ungetracktes `./bin/` mit dem Binary, das keine `.gitignore`-Zeile deckt. Damit ist
  `git status --porcelain` nach dem dokumentierten Aufruf nicht mehr leer und der
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Working-Tree-Hash verschiebt sich — der Stop-Hook-Nachweis in
  [`.claude/hooks/stop-require-gates.sh`](../../.claude/hooks/stop-require-gates.sh) hängt an genau dieser Menge.
- `verifizierbar`: **ja** — `make artifact DEST=./bin` im Repo, danach `git status --porcelain`
  (zeigt `?? bin/`).

### F-6 — Der `docker`-Stub validiert nur das Ziel-Argument; Image-Tag und Quellpfad sind unbewacht

- `kategorie`: INFO
- `quelle`: dokumentationswürdige, aber undokumentierte Annahme (Reviewer-Skill §INFO);
  Plan §6 „Der Stub darf nicht zum Prüfgegenstand werden"
- `pfad`: [`test/release-matrix.bats:194-204`](../../test/release-matrix.bats) (`docker_stub`)
- `befund`: Der Stub wertet bei `cp` ausschließlich `$3` aus und ignoriert `$2`
  (`<cid>:/out/ai-harness-init`) sowie bei `create` den Image-Tag vollständig. Für die **geprüfte**
  Eigenschaft (DEST wird angelegt) hängen die Tests korrekt an der beobachtbaren Wirkung — Plan §6
  ist insoweit eingelöst. Ein Tippfehler im Quellpfad oder im Tag ließe jedoch alle drei Wächter
  und `make mutate` grün und bräche erst im nächsten Release-Lauf; diese Grenze ist im Kopf der
  Test-Sektion nicht benannt, während der Kopf sonst ausdrücklich über die Stub-Ehrlichkeit spricht.
- `verifizierbar`: **ja** — `/out/ai-harness-init` im Skript verfälschen, `make test`: bleibt grün.

## Negativbefunde

- geprüft, ohne Befund: **Verhaltensverlust durch die Extraktion** — die wichtigste Frage am Diff.
  `docker rm` im Erfolgsfall und `trap - EXIT` im Loop von `release-artifacts` sind **nicht**
  verloren: jeder Skript-Aufruf ist ein eigener Prozess, dessen EXIT-Trap am Iterations-Ende feuert;
  ein Trap-Rest über Iterationen hinweg kann bauartbedingt nicht mehr entstehen. Für `artifact` war
  der alte Zustand ohnehin trap-only.
- geprüft, ohne Befund: **Exit-Code-Erhalt über den EXIT-Trap.** Gemessen (bash 5.2.21):
  `trap "true" EXIT; false` → 1; `set -e; trap "true" EXIT; false` → 1. Ein scheiterndes
  `docker cp` wird also **nicht** durch das erfolgreiche `docker rm -f` im Trap maskiert — kein
  stiller Grün-Pfad. Real durchgespielt: Fassung ohne `mkdir -p` → Exit 1, Original → Exit 0.
- geprüft, ohne Befund: **Fehlerpfade und Quoting in `harness/tools/artifact-copy.sh`.**
  `set -euo pipefail` gesetzt; `${1:-}`-Defaults gegen `set -u`; alle Variablen-Expansionen
  gequotet; `$cid` im Trap einfach-gequotet (Expansion zur Trap-Zeit); Trap **nach** erfolgreichem
  `docker create` gesetzt, also nie mit leerem `cid`; Aufruf-Fehler → Exit 2 auf stderr.
- geprüft, ohne Befund: **Stub-Fidelität für den geprüften Fehlermodus.** Die Behauptung „sein `cp`
  fällt wie `docker cp`, wenn das Verzeichnis fehlt" trägt: real gemessen bricht `docker cp` bei
  fehlendem Elternverzeichnis mit derselben Meldung ab, die der Plan §3 zitiert, und der
  `>`-Redirect des Stubs fällt an derselben Stelle. (Der Exit-Code weicht ab → F-3; die Tests
  hängen daran nicht.)
- geprüft, ohne Befund: **Können die neuen Wächter grün bleiben, während das echte Verhalten
  bricht?** Für die *geprüfte* Eigenschaft nein — durchgespielt: `mkdir -p` entfernt → rot;
  `mkdir` auf den falschen Pfad gelegt → rot; `docker cp`-Ziel auf das Verzeichnis statt die Datei
  → rot. Die verbleibenden Löcher sind als F-1 (Cleanup) und F-6 (Argumente) gemeldet.
- geprüft, ohne Befund: **`.github/workflows/release.yml` ohne `mkdir -p dist`.** Kein Pfad, auf
  dem `dist` fehlt: `mkdir -p "$destdir"` läuft im Skript **vor** `docker create`, also in der
  ersten Iteration; `ls -l dist` und `upload-artifact` folgen erst danach und sind fail-loud
  (`if-no-files-found: error`). Scheitert ein `docker build` vorher, bricht der Step ab, bevor `ls`
  läuft. Die drei anderen `dist`-Verwender (`download-artifact` in `start-smoke` und `publish`)
  legen das Verzeichnis selbst an.
- geprüft, ohne Befund: **`release-artifacts`-Rezept nach dem Umbau.** [`Makefile`](../../Makefile) Zeile 84 trägt
  weiterhin `@set -e;` vor der Schleife — ein Fehlschlag des Skripts in Iteration 3 bricht ab und
  erreicht die Erfolgsmeldung in Zeile 94 nicht. Der Umbau hat den vorherigen Zustand hier eher
  verbessert (die alte letzte Schleifen-Anweisung `trap - EXIT` gab immer 0 zurück).
- geprüft, ohne Befund: **Mutations-Anker `^mkdir -p ` (Fall 86).** Genau ein Treffer in der
  Zieldatei (gemessen), und der Anker ist fail-closed: verliert er seinen Treffer, meldet
  [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) Bedingung 2 („Mutation hat nicht gegriffen — Patch veraltet?")
  statt still zu bestehen. `expect:` matcht die reale bats-Zeile
  (`not ok <n> release: artifact-copy legt ein FEHLENDES Zielverzeichnis an`) über
  `failure_form test`. Dollar-frei, wie im Kopf begründet.
- geprüft, ohne Befund: **Hard Rule 3.2** — kein `# shellcheck disable` und kein `//nolint` im
  Diff; repo-weiter Grep über `*.sh`/`*.bats` liefert 0 Treffer. `shell-lint` deckt die neue Datei
  über `harness/tools/*.sh` und lief in `make gates` ohne Ausgabe.
- geprüft, ohne Befund: **Hard Rule 3.3** — `7277c43` ist ein reiner Move (1 file changed,
  0 insertions, 0 deletions, Rename erkannt); die Link-Reconciliation in
  [`roadmap.md`](../plan/planning/in-progress/roadmap.md) folgt im Inhalts-Commit. `c2349a0` war in sich konsistent
  (Link `../open/…`, Datei in `open/`) — kein Commit im Range mit hängendem Inbound-Link.
- geprüft, ohne Befund: **Hard Rule 3.4** — kein Artefakt unter `docs/plan/adr/` im Diff;
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) unangetastet. **Hard Rule 3.5** — keine Gate-Schwelle gesenkt, kein Modul
  deaktiviert, `gates`-Kette unverändert.
- geprüft, ohne Befund: **Hard Rule 3.1 / [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)** — kein neu genanntes Gate ohne Lauf; die
  drei neuen Wächter laufen auf frischem Checkout im gepinnten bats-Image (selbst gefahren:
  `ok 96/97/98`), kein Prüfbereich ist leer.
- geprüft, ohne Befund: **[`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only).** `bash harness/tools/<x>.sh` aus einem
  Recipe ist die im Repo etablierte Form ([`smoke.sh`](../../harness/tools/smoke.sh), [`baseline-verify.sh`](../../harness/tools/baseline-verify.sh),
  [`mutate.sh`](../../harness/tools/mutate.sh)); keine Host-Toolchain und kein Paketmanager neu eingeführt.
  [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1 wird durch das Entfernen des YAML-`mkdir` **gestärkt**, nicht verletzt.
- geprüft, ohne Befund: **[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)** — kein Image-Digest, kein Versions-Pin und kein
  `--no-cache-filter` im Diff berührt; das Kopier-Verhalten ist von der Bau-Reproduzierbarkeit
  entkoppelt.
- geprüft, ohne Befund: **[`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)** — Namensschema `ai-harness-init-<os>-<arch>[.exe]`
  unverändert an die Schleife übergeben; die bestehenden Wächter „Matrix deckt genau das
  Lastenheft" und „Windows trägt .exe" laufen weiter grün.
- geprüft, ohne Befund: **[`docs/user/benutzerhandbuch.md`](../user/benutzerhandbuch.md) Zeile 145.** Die neue Ist-Aussage
  bezieht sich auf HEAD und grenzt `v0.1.0` ausdrücklich ab — sie greift nicht weiter als der Code,
  den sie beschreibt. [`README.md`](../../README.md) Zeile 48 trägt keinen widersprechenden Hinweis, der
  nachzuziehen wäre.
- geprüft, ohne Befund: **[`roadmap.md`](../plan/planning/in-progress/roadmap.md)** — der Slice steht mit beobachtbarem Trigger und
  Closure-Kriterium in der „Ohne Welle geschnitten"-Tabelle; die slice-050-Zeile bleibt inhaltlich
  unverändert (nur „Kein Slice in Arbeit" → „Sonst kein Slice in Arbeit").

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 3 |
| INFO | 1 |

## Verdikt

**NICHT KONFORM.** **Merge-blockierend: ja** — wegen F-1 und F-2.

Begründung, warum die beiden MEDIUMs hier nicht als „später" durchgewinkt werden: beide sind
Instanzen der Klasse, die in slice-050 fünf Review-Runden gekostet hat, und
[`AGENTS.md`](../../AGENTS.md) §3.6 kennt für eine Zusage ohne rot gesehenes Gegenbeispiel keine
Severity-Ausnahme — eine Zusage ist erst fertig, wenn ihr Gegenbeispiel rot gesehen wurde. Beide
betreffen zudem Zusagen, die **dieser** Slice erst geschaffen (F-2: neuer Test-Name) bzw. bewusst
in eine messbare Einheit verschoben hat (F-1: die Aufräum-Zusage aus [`Makefile`](../../Makefile) Zeile 61 lebt
jetzt in einer Datei, die ein bats-Test erreichen kann) — die Gelegenheit, sie zu messen, entsteht
mit diesem Diff und wird nicht genutzt.

Der Kern des Slice ist davon **nicht** betroffen: der Fix trägt, der Wächter hängt an der
beobachtbaren Wirkung, der Mutations-Anker ist eindeutig und fail-closed, und das Entfernen von
`mkdir -p dist` lässt keinen Pfad ohne `dist` zurück. Die drei LOWs und das INFO blockieren nicht.

**Steering-Loop-Signal:** erneut dieselbe Klasse („Ist-Aussage/Test-Name weiter als die Messung"),
nach fünf Runden in slice-050. Nach Reviewer-Skill §Kontext-Eskalation ist das kein reines
Melde-Ereignis mehr, sondern gehört als Guide-/Sensor-Nachzug in die Closure-Notiz — etwa als
Pre-completion-Schritt „zu jedem neuen Test-Namen den Teil benennen, den er *nicht* misst".

**Übergabe:** Findings gehen an die Implementation (Rückkante Review → Plan bei Plan-Defekt).
Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
