# Review-Report: slice-051 — Runde 2 — 2026-07-26

**Review-Art:** Code — geprüft wird der Diff gegen **Plan + aktive ADRs + Hard Rules +
Konventionen** (Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung
(Modul 11, getrennter Kontext, anderes Prüf-Artefakt).

**Gegenstand:** die beiden **Auflösungs-Commits** zu slice-051, Range `00bb7c3..HEAD`:

- `d3315f0` „fix: slice-051 Review-Findings aufgeloest (F-1/F-2/F-3/F-5, INFO-1)" —
  `.gitignore` +6 · `docs/reviews/2026-07-26-slice-051-impl-review.md` neu (256) ·
  `harness/tools/artifact-copy.sh` −1/+3 · `test/mutations/87-artifact-cleanup-trap.sh` neu (14) ·
  `test/mutations/88-artifact-quellpfad.sh` neu (11) · `test/release-matrix.bats` +52/−1.
- `861631b` „docs: Versions-Historie aus dem Handbuch-Rumpf in die Aenderungshistorie" —
  `docs/user/benutzerhandbuch.md`: Kopf 1.5→1.6, Klammer-Satz aus dem §2-Hinweis entfernt,
  neue §11-Zeile 1.6.

**Nicht erneut geprüft:** der Gesamt-Diff bis `00bb7c3` (Runde 1). Runde 2 ist eine
**eigenständige** Bewertung dieser beiden Commits plus des Status jedes Runde-1-Findings am
Diff — nicht an der Behauptung der Commit-Message.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-26 · **Frischer Kontext**, getrennt von
Implementation und Verifikation.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf
nicht reproduzierbar):

- Slice-Plan: `docs/plan/planning/in-progress/slice-051-artifact-dest-anlegen.md`
- berührte `LH-*`-IDs: LH-QA-04 (die Release-Binaries entstehen über diese Targets),
  LH-QA-01 (kein Wächter über leerem Prüfbereich), LH-QA-02 (Reproduzierbarkeit)
- aktive ADRs: ADR-0003 (native Binaries, Docker-only) — in beiden Commits **nicht** berührt
- `AGENTS.md` §3 (Hard Rules 3.1–3.6), insbesondere **3.2** und **3.6** — vollständig gelesen
- Konventionen: `harness/conventions.md` — MR-003, MR-014
- **Vorherige Findings am gleichen Modul (Pflicht-Punkt 5):** [Runde 1](2026-07-26-slice-051-impl-review.md)
  (0 HIGH, 2 MEDIUM, 3 LOW, 1 INFO) sowie die fünf slice-050-Runden. Dominante Klasse dort:
  **„Zusage weiter als Abdeckung"** (`AGENTS.md` §3.6). Sie ist der Maßstab dieser Runde.
- Rollen-Vertrag: `.harness/skills/reviewer.md`, <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
  `.harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md` (beide vollständig gelesen)

**Eigene Sensoren (Docker-only nach ADR-0003, nur `make`-Targets am Repo; nichts Mutierendes
am Arbeitsbaum):**

- `make gates` → **Exit 0** (selbst gefahren; shellcheck und actionlint ohne Ausgabe).
  `shell-lint` deckt `test/mutations/*.sh` — die zwei neuen Fälle sind gelintet.
- `make test` → **112 `ok`, 0 `not ok`** (selbst gezählt; Runde 1 maß 110).
- **Kein** `make mutate` (Auftragsgrenze) — die zwei neuen Fälle sind statisch und über
  eigene Nachstellungen geprüft, nicht über den Treiber.
- **Neun Verstümmelungs-Läufe gegen KOPIEN** des Baums (`mktemp -d` im Scratchpad, das Repo
  nur lesend): je Kopie eine Mutation, dann `test/release-matrix.bats` im **gepinnten**
  bats-Image (`--network none`, Mount `:ro`) — dieselbe Aufruf-Form wie `make test`.
- **Zwei reale Messungen mit Daemon:** `docker create ai-harness-init:build true` +
  `docker cp` in ein fehlendes Verzeichnis (Container danach entfernt), sowie GNU make
  über ein Wegwerf-Makefile mit scheiterndem Rezept — beide für F-3.

**Referenz-Lauf auf der unveränderten Kopie:** `1..15`, alle `ok` (Basis für jeden
Vergleich unten).

---

## Status der Runde-1-Findings

### F-1 (MEDIUM) — Aufräum-Zusage unbewacht → **aufgelöst**

Gemessen, nicht geglaubt. `test/release-matrix.bats:262-273` misst jetzt real das Aufräumen:

| Verstümmelung der Kopie | Ergebnis (`1..15`) |
|---|---|
| `sed -i '/^trap /d'` (= Mutations-Fall 87) | `not ok 14` — **nur** 14, 1–13/15 grün |
| `trap …' EXIT` → `' INT TERM` (Trap ohne EXIT) | `not ok 14` |

Der von Runde 1 als `verifizierbar` benannte Sed ist damit **rot gesehen**, und zwar
punktgenau: keine Nachbar-Assertion färbt mit.

**Kein stiller Grün-Pfad über das Protokoll** (die von Runde 2 ausdrücklich gestellte Frage).
Der Stub schreibt nach `${DOCKER_STUB_LOG:-/dev/null}`; würde die Variable nicht ankommen,
liefe das Protokoll ins Leere. Gemessen:

| Verstümmelung | Ergebnis |
|---|---|
| Stub schreibt hart nach `>> /dev/null` | `not ok 14`, `not ok 15` |
| Log-Zeile im Stub ganz entfernt | `not ok 14`, `not ok 15` |

Beide Tests initialisieren ihre Flags auf `0` und lesen das Protokoll mit `grep` über eine
Datei, die dann gar nicht existiert — der Ausfall ist **fail-closed**. Das Prefix
`DOCKER_STUB_LOG=… run bash …` trägt real (sonst wären die Fälle 87/88 nicht rot geworden).

### F-2 (MEDIUM) — Test-Name „alle drei" → **aufgelöst**

`test/release-matrix.bats:247-257` setzt jede der drei Positionen einzeln leer **plus** den
weggelassenen dritten Parameter. Gesucht wurde die Reduktion des Guards, unter der der Test
grün bliebe — es gibt keine:

| Guard in `harness/tools/artifact-copy.sh:31` reduziert auf | Ergebnis |
|---|---|
| `[ -z "$name" ]` (die Reduktion aus Runde 1) | `not ok 13` |
| `[ -z "$img" ]` | `not ok 13` |
| `[ -z "$destdir" ]` | `not ok 13` |

Jede Ein-Bedingungs-Fassung fällt; der Name deckt sich mit der Messung.

### INFO-1 / F-6 (INFO) — Image-Tag und Quellpfad unbewacht → **aufgelöst**

`test/release-matrix.bats:278-290` prüft **beides** über das Protokoll:

| Verstümmelung | Ergebnis |
|---|---|
| `s\|out/ai-harness-init\|out/ai-harness-init-mutiert\|` (= Fall 88) | `not ok 15` — nur 15 |
| `docker create "$img"` → hart verdrahtetes `ai-harness-init:build` | `not ok 15` |

Die von Runde 1 als „bleibt grün" gemessene Verfälschung des Quellpfads färbt jetzt rot.

### F-3 (LOW) — Exit-Code-Aussage im Skript-Kopf → **aufgelöst, und die Korrektur stimmt**

Der neue Text (`harness/tools/artifact-copy.sh:17-18`) macht zwei Aussagen; beide selbst
nachgemessen:

- „Der Fehler selbst endet mit Exit 1": `docker cp <cid>:/out/ai-harness-init <fehlt>/datei`
  → `invalid output path: directory "…" does not exist`, **Exit 1**.
- „die 2 … war `make`s eigener Abbruch-Code": Wegwerf-Makefile mit `@exit 1` →
  `make: *** [Makefile:2: fail] Fehler 1`, **make-Exit 2**. Die Zeile „Fehler 1" im
  Nutzer-Bericht ist der Rezept-Status, die 2 der Prozess-Status von make.

### F-4 (LOW) — nachformatierter Rot-Lauf in `00bb7c3` → **eingeordnet, nicht reparierbar**

Die Commit-Message von `d3315f0` benennt die Klasse und die Handhabung (Commit bleibt stehen,
Korrektur im Folge-Commit). Kein Artefakt im Baum trägt das nachformatierte Zitat weiter.
Angemessen; kein Restbefund.

### F-5 (LOW) — ungetracktes `bin/` nach dem dokumentierten Aufruf → **aufgelöst**

Der Glob ist korrekt und die Wirkung reicht bis zum MR-003-Hash — gemessen:

- `git check-ignore -v bin/` → `.gitignore:11:/bin/` (Treffer)
- `git check-ignore -v internal/bin/x` → **kein** Treffer → nur das Wurzel-`bin/`, nicht
  jedes `bin/` im Baum. Das ist gewollt: der dokumentierte Aufruf lautet `DEST=./bin`.
- `git check-ignore -v bin` (Datei statt Verzeichnis) → **kein** Treffer; der Schrägstrich
  hält die Regel auf Verzeichnisse begrenzt.
- `git ls-files bin/` → leer; die Regel verdeckt keine getrackte Datei.
- `harness/tools/working-tree-hash.sh` listet mit `git ls-files --cached --others
  **--exclude-standard**` — die Ignore-Regel entfernt `bin/` also wirklich aus der Menge,
  an der MR-003 und der Stop-Hook hängen. Der Fix greift nicht bloß kosmetisch.

### Die zwei neuen Mutations-Fälle 87/88 → **eindeutig, treffend, fail-closed**

- **Anker eindeutig (gemessen):** `grep -c '^trap ' harness/tools/artifact-copy.sh` = 1;
  `grep -c 'out/ai-harness-init' …` = 1. Beide dollarfrei (SC2016-Linie der Fälle 83/86).
- **Genau ihre Zeile:** oben gemessen — 87 färbt ausschließlich Test 14, 88 ausschließlich
  Test 15; kein Fall trifft einen fremden Wächter.
- **`expect:` trifft die reale Fehlschlag-Zeile:** `harness/tools/mutate.sh:344` filtert mit
  `failure_form test` (`not ok [0-9]+`) und sucht darin den `expect:`-String als Fixstring.
  Die realen Zeilen lauten `not ok 14 release: artifact-copy raeumt den Container auf` bzw.
  `not ok 15 release: artifact-copy nimmt das uebergebene Image und den erwarteten Quellpfad`
  — die beiden `expect:`-Strings sind exakte Teilstrings davon.
- **Wachstum:** verliert ein Anker seinen Treffer (Trap in eine Funktion eingerückt, Quellpfad
  in eine Variable gezogen), meldet `mutate.sh` Bedingung 2 („Mutation hat nicht gegriffen —
  Patch veraltet?"); trifft die Mutation nur noch einen Kommentar, feuert Bedingung 3
  („blieb GRUEN — hat keine Zaehne mehr"). Kein Wachstumspfad endet still grün.

### `861631b` → **Trennlinie trägt, mit einer Lücke (siehe N-2) und einer Annahme (N-3)**

Die Sortierung selbst ist am Baum nachvollzogen: die vier verbliebenen `v0.1.0`-Nennungen
(Zeilen 4, 75, 495, 533) sind drei Fähigkeits-Aussagen („ab `v0.1.0` liegen fertige Programme
bereit") plus das Kopf-Feld **Software-Stand** — keine davon ist Changelog im Fließtext, keine
wächst mit dem nächsten Fix. Der gewanderte Satz steht in §11 Zeile 550 **vollständig**,
inklusive der Fehlermeldung `invalid output path: directory … does not exist`; der Leser
verliert die Information nicht, nur ihren Ort. Was der Leser im Rumpf braucht — dass `DEST`
Pflicht ist und der Ordner angelegt wird — ist geblieben.

---

## Neue Findings

Ausschließlich aus den beiden Auflösungs-Commits. Sortiert nach Schwere.

### N-1 — Der Aufräum-Wächter misst „ein `rm` lief", nicht die Zusage „auch wenn `docker cp` scheitert"

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6 („Keine Zusage ohne rot gesehenes Gegenbeispiel");
  Reviewer-Skill §LOW „latente Wartungsfalle"
- `pfad`: `test/release-matrix.bats:269` (`grep -q '^rm ' "$dir/aufrufe"`) i. V. m.
  `Makefile:61` („Der Container wird immer aufgeraeumt (trap), **auch wenn `docker cp`
  scheitert**.")
- `befund`: Die Assertion prüft nur, **dass** eine `rm`-Zeile im Protokoll steht — weder
  **welchen** Container sie entfernt noch **ob** das Aufräumen am Fehlerpfad hängt. Zwei
  Verstümmelungen bleiben gemessen grün (`1..15`, kein `not ok`): (a) `trap` durch ein
  **nachgestelltes** `docker rm -f "$cid"` hinter dem `docker cp` ersetzt — räumt nur im
  Erfolgsfall auf, genau die Hälfte, die `Makefile:61` ausdrücklich zusagt; (b) Trap-Ziel
  auf eine fremde ID gelegt (`docker rm -f falsche-id`) — der erzeugte Container bliebe
  liegen. Der Nachbar-Test 15 pinnt `cid-fake` in der `cp`-Zeile und zeigt damit, dass die
  Technik im selben Protokoll zur Verfügung steht.
- `verifizierbar`: **ja** — `trap`-Zeile löschen und stattdessen `docker rm -f "$cid"
  >/dev/null 2>&1` als letzte Zeile anhängen, dann `make test`: bleibt grün (112 ok).
  In `make mutate` liefe ein solcher Fall als „blieb GRUEN — hat keine Zaehne mehr" auf.
- **Warum LOW und nicht MEDIUM:** die von Runde 1 in F-1 benannte und als `verifizierbar`
  definierte Gegenprobe (`sed '/^trap /d'`) ist rot gesehen und als Fall 87 dauerhaft
  verankert; der Test-Name („raeumt den Container auf") behauptet die ungemessene Hälfte
  **nicht** mit. Die überschießende Zusage steht in `Makefile:61` und stammt aus slice-029
  (`git log -L 55,63:Makefile`), liegt also außerhalb des Diffs dieser beiden Commits.
  Der Code hält die Zusage heute; unbewacht ist ihr Bruch, nicht ihr Ist-Zustand.

### N-2 — Die neue Trennlinie „Fähigkeits-Aussage bleibt / Changelog wandert" steht nur in der Commit-Message und hat im Rumpf einen lebenden Gegenbeleg

- `kategorie`: LOW
- `quelle`: Maintainability (latente Wartungsfalle); `AGENTS.md` §3.6 (Beleg-Reichweite einer
  Commit-Aussage)
- `pfad`: `docs/user/benutzerhandbuch.md:311` gegen die Regel in Commit `861631b`
  („Gegenprobe ueber den Rumpf gefahren")
- `befund`: Zeile 311 trägt weiterhin „Es gibt **kein** `--force` und **keinen**
  Kollisions-Abbruch mehr **(frühere Versionen kannten das)**" — nach der im Commit
  formulierten Sortierung die zweite Sorte („`IN v0.x` war es noch anders" = Changelog im
  Fließtext, die wächst). Die Gegenprobe erfasste nur `v0.1.0`-Zeichenketten; eine
  Historie-Aussage ohne Versionsnummer fiel durch das Raster. Die Regel selbst ist in keinem
  Artefakt des Repos festgehalten — weder in `harness/conventions.md` noch im Kopf von §11
  —, sondern nur in einer Commit-Message.
- `verifizierbar`: **ja** — `grep -nE "frühere|noch nicht so|bisher" docs/user/benutzerhandbuch.md`
  über den Rumpf (bis Zeile 545) liefert Zeile 311; `git log -S` zeigt die Trennlinie
  ausschließlich im Message-Text von `861631b`.

### N-3 — Der Rumpf beschreibt jetzt HEAD, der Kopf nennt weiter `Software-Stand: v0.1.0`

- `kategorie`: INFO
- `quelle`: dokumentationswürdige, aber undokumentierte Annahme (Reviewer-Skill §INFO)
- `pfad`: `docs/user/benutzerhandbuch.md:4` (`**Software-Stand:** v0.1.0`) gegen
  `docs/user/benutzerhandbuch.md:145` (Hinweis ohne Versions-Grenze)
- `befund`: Der §2-Hinweis sagt seit `861631b` unbedingt „Den Zielordner müssen Sie **nicht**
  vorher anlegen"; für den im Kopf genannten Software-Stand `v0.1.0` ist das falsch. Getragen
  wird die Aussage von der ungeschriebenen Annahme, dass Weg B den **Klon-Stand** meint —
  Schritt 1 des Wegs ist ein `git clone` ohne Tag-Auswahl, und Zeile 75 lenkt Versions-Leser
  ausdrücklich auf Weg A. Die Annahme ist plausibel und trägt für den vorgeschriebenen
  Ablauf; benannt ist sie nirgends, während das Kopf-Feld das Gegenteil suggeriert. Runde 1
  hatte die alte Fassung genau wegen ihrer expliziten Abgrenzung als befundfrei gewertet.
- `verifizierbar`: **ja** — `git checkout v0.1.0` und dort `make artifact DEST=./bin` mit
  fehlendem `bin`: der Aufruf bricht ab, obwohl Zeile 145 des mitgelieferten Handbuchs das
  Gegenteil sagt.

---

## Negativbefunde

- geprüft, ohne Befund: **stiller Grün-Pfad über `DOCKER_STUB_LOG`** — die Kernfrage an
  diesem Diff. Beide Ausfälle (Variable kommt nicht an → `/dev/null`; Log-Zeile entfernt)
  färben Test 14 **und** 15 rot; die Flags stehen auf `0`, `grep` über eine fehlende Datei
  scheitert, fail-closed. Gemessen, nicht abgeleitet.
- geprüft, ohne Befund: **Verdeckt der bats-`set -e` die Assertion?** Nein — die Form
  `flag=0; grep … && flag=1; [ "$flag" -eq 1 ]` bricht nicht am `grep` ab (errexit greift für
  ein Kommando vor dem letzten `&&` nicht). Gemessen: der rote Lauf meldet
  `(in test file test/release-matrix.bats, line 272) [ "$aufgeraeumt" -eq 1 ]' failed` —
  die Assertion wird erreicht und das `rm -rf` der Temp-Verzeichnisse davor läuft. Das
  Idiom der Datei (erst aufräumen, dann behaupten) ist intakt.
- geprüft, ohne Befund: **Kreuz-Wirkung der neuen Wächter.** Keine der neun Verstümmelungen
  färbt einen fremden Test rot; jede trifft genau ihren eigenen (`1..15` mit höchstens zwei
  `not ok`, und die zwei nur dort, wo beide Wächter dieselbe Quelle lesen).
- geprüft, ohne Befund: **Der Stub bleibt Werkzeug, nicht Prüfgegenstand** (Plan §6). Die neue
  Protokoll-Zeile ändert am `create`/`cp`/`rm`-Verhalten nichts; Tests 11/12 hängen unverändert
  an der beobachtbaren Wirkung (Verzeichnis da, Datei da), nur 14/15 lesen das Protokoll —
  und für sie gibt es keine andere beobachtbare Spur.
- geprüft, ohne Befund: **`printf`-Erzeugung des Stubs.** Das Format `'%s\n'` verarbeitet
  Escapes nur im Format, nicht in den Argumenten — das eingebettete `printf "%s\n" "$*"`
  landet literal in der Stub-Datei. Real belegt: die Protokoll-Zeilen werden geschrieben
  (`create mein-bild true`, `cp cid-fake:/out/ai-harness-init …`, `rm -f cid-fake`).
- geprüft, ohne Befund: **Hard Rule 3.2** — kein `# shellcheck disable`, kein `//nolint` in
  beiden Commits. `shell-lint` deckt `test/mutations/*.sh` und `harness/tools/*.sh` und lief
  in `make gates` ohne Ausgabe; die zwei neuen Fall-Skripte tragen `set -euo pipefail` und
  das Bit `100755`.
- geprüft, ohne Befund: **Hard Rule 3.3** — kein `git mv` in beiden Commits, also keine
  Move-plus-Rewrite-Vermischung.
- geprüft, ohne Befund: **Hard Rule 3.4 / 3.5** — kein Artefakt unter `docs/plan/adr/`
  berührt, keine Gate-Schwelle gesenkt, kein Modul deaktiviert; die `gates`-Kette und
  `.d-check.yml` sind in beiden Commits unangetastet. Beide Commits **fügen** Wächter hinzu.
- geprüft, ohne Befund: **Hard Rule 3.1 / LH-QA-01** — kein neu genannter Gate ohne Lauf; die
  zwei neuen bats-Wächter laufen real (selbst gefahren: 112 ok, 0 not ok), kein Prüfbereich
  ist leer, und die zwei neuen Mutations-Fälle liegen im bereits aktiven `test/mutations/`
  (84 Fälle, gezählt) statt in einem neuen Gate-Namen.
- geprüft, ohne Befund: **ADR-0003 (Docker-only).** Beide Commits führen keine Host-Toolchain
  und keinen Paketmanager ein; die neuen Fälle nutzen `sed`/`bash` wie die 82 bestehenden.
- geprüft, ohne Befund: **LH-QA-02** — kein Image-Digest, kein Versions-Pin, kein
  `--no-cache-filter` berührt; das gepinnte bats-Image trägt beide neuen Wächter unverändert.
- geprüft, ohne Befund: **LH-QA-04** — Namensschema und Plattform-Matrix nicht berührt; die
  Wächter 1–5 der Datei laufen unverändert grün.
- geprüft, ohne Befund: **MR-003-Wirkungskette des `.gitignore`-Eintrags** — siehe F-5 oben;
  `working-tree-hash.sh` respektiert `--exclude-standard`, der Eintrag ist wurzel-anker- und
  verzeichnis-begrenzt, und er verdeckt keine getrackte Datei.
- geprüft, ohne Befund: **MR-014** — beide Commits fassen `.github/workflows/` nicht an; die
  neuen Checks leben als versionierte Artefakte im Repo (bats-Wächter, Mutations-Fälle), nicht
  in YAML.
- geprüft, ohne Befund: **`README.md:48`** — trägt den Aufruf `make artifact DEST=./bin` ohne
  Verhaltens-Zusage zum Zielordner; aus `861631b` entsteht dort kein Nachzugs-Bedarf.
- geprüft, ohne Befund: **§11-Zeile 1.6 des Handbuchs** — nennt Handbuch-Version, Datum und
  Delta samt Fehlermeldung, in der Form der Zeilen 1.5/1.4; die Kopf-Version wurde
  mitgezogen (1.5 → 1.6). Keine Zeile der Historie wurde überschrieben.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 1 |

## Verdikt

**KONFORM.** **Merge-blockierend: nein.**

Beide MEDIUMs aus Runde 1 sind aufgelöst — und zwar an der Sache, nicht an der Behauptung:
jede der von Runde 1 als `verifizierbar` benannten Gegenproben wurde in dieser Runde selbst
nachgestellt und ist **rot**, während sie vor der Auflösung grün war. Dasselbe gilt für das
angehobene INFO-1 und für die drei LOWs; die Exit-Code-Korrektur (F-3) ist in **beiden**
Hälften nachgemessen, der `.gitignore`-Eintrag (F-5) ist bis in den MR-003-Hash hinein
wirksam, und der von Runde 2 gesuchte stille Grün-Pfad über `DOCKER_STUB_LOG` existiert
nicht: das Protokoll fällt fail-closed aus.

Die beiden neuen Mutations-Fälle sind eindeutig verankert (je genau ein Treffer, gemessen),
treffen punktgenau ihren eigenen Wächter und bleiben bei Wachstum fail-closed — sie machen
die zwei zuvor unbewachten Eigenschaften dauerhaft.

Die zwei LOWs und das INFO blockieren nach Modul 10 nicht. N-1 ist die verbleibende Hälfte
einer **pre-existierenden** Zusage aus slice-029 (`Makefile:61`), deren Ist-Zustand der Code
heute hält; N-2 und N-3 sind Doku-Sortierung im Handbuch, ohne Sensor-Wirkung.

**Steering-Loop-Signal:** die Klasse „Zusage weiter als Abdeckung" erscheint in dieser Runde
nur noch als N-1 — deutlich schwächer als in Runde 1 (zwei MEDIUM) und in slice-050 (fünf
Runden). Die Auflösung hat sie an der Wurzel gefasst (Mutations-Fälle statt Kommentar).
Für die Closure bleiben zwei Nachzüge empfehlenswert, aber nicht blockierend: die
`Makefile:61`-Zusage auf das einschränken, was Fall 87 hält (oder den Fehlerpfad messen), und
die in `861631b` formulierte Trennlinie an einem auffindbaren Ort festhalten statt nur in
einer Commit-Message.

**Übergabe:** Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier
separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
