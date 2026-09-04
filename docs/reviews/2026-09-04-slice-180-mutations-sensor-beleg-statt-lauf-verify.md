# Verifikation slice-180 — Beleg statt Lauf im Mutations-Sensor

**Rolle:** Verifier (Modul 11). **Datum:** 2026-09-04. **Frischer Kontext**, kein Anteil an
Implementation, Architektur, Planung oder Review dieses Slice.

**Eingang:** DoD-Bestätigung und Sensor-Belege des Implementers
([`slice-180`](../plan/planning/in-progress/slice-180-mutations-sensor-beleg-statt-lauf.md), §7),
plus drei Reviewer-Runden gegen denselben Diff:
[Runde 1](2026-09-04-slice-180-mutations-sensor-verify.md) (2 HIGH, 3 MEDIUM, 3 LOW, 1 INFO,
blockiert), [Runde 2](2026-09-04-slice-180-mutations-sensor-verify-runde-2.md) (1 HIGH, 3 MEDIUM,
1 LOW, blockiert), [Runde 3](2026-09-04-slice-180-mutations-sensor-verify-runde-3.md) (0 HIGH,
1 MEDIUM (R3-2), 1 LOW (R3-1), **freigegeben mit Auflage** vor Closure). Die drei Reviewer-Dateien
tragen trotz der Namensendung `-verify(-runde-N).md` **Reviewer**-Inhalt (Kopf: „Rolle: Reviewer"),
nicht Verifier-Inhalt — abweichend vom sonstigen Repo-Muster (`-review.md`/`-review-runde-N.md` für
Reviewer, `-verify.md` ohne Kollisionsgefahr für Verifier, siehe z. B.
`2026-09-04-slice-175-schreibender-pfad-review*.md` vs. `…-verify.md`). Diese Datei trägt darum
einen längeren, nicht kollidierenden Namen (`…-beleg-statt-lauf-verify.md`) statt der schlicht
falsch benannten Zielform; die Diskrepanz ist hiermit benannt, nicht korrigiert — Umbenennung
fremder Rollen-Artefakte ist nicht Verifier-Arbeit.

**Gegenstand:** `HEAD` = `7290352` auf dem Arbeitsbaum von `in-progress/slice-180-…md`
(`git log --oneline -3` → `cfa398b` R3-1-Fix · `7290352` Implementer Runde 2+3 · `65b5b3e`
`slice-mv`). Vor dieser Verifikation war der Baum sauber (`git status --porcelain` leer).

---

## R3-1 (LOW, bereits vom Nutzer behoben) — gegengeprüft

Commit `cfa398b` selbst gelesen (`git show cfa398b`): der Diff ändert ausschließlich
Kommentarzeilen im Kopf von `isolation_key`s Aufrufpunkt in `main()` — kein Code-Pfad, keine
Bedingung, keine Zeichenkette, die zur Laufzeit gelesen wird. Die neue Fassung trägt Kommando plus
Nicht-Erwartungswert-Marke statt einer festen Zahl (`MR-025` Setzung 2), wie R3-1 verlangte. **Kein
Verhaltensunterschied zum Stand, den Runde 3 mit `250 ok, 0 Befund(e)` freigegeben hat** — das
tragende Argument dafür, warum ein Neu-Lauf von `make mutate` nach diesem Fix nicht *zwingend*
nötig war, um R3-1 als erledigt zu betrachten (siehe unten trotzdem real gefahren).

## R3-2 (MEDIUM) — Hauptauftrag: erfüllen die zwei Zwischen-Edits Closure-Trigger 2(c)?

**Befund bestätigt.** §5 definiert Probe (c) als *„eine Änderung an einem Pfad, den die Kopie
trägt und `git ls-files --cached --others --exclude-standard` **nicht** führt"*. Die zwei in §7
zitierten unabsichtlichen Zwischen-Edits trafen die Plan-Datei selbst, `../observations.md` und
`test/mutations/74-mutate-kopie-ohne-git.sh` — alle drei **getrackt**:

```
$ git ls-files --cached --others --exclude-standard | grep -cF \
  -e docs/plan/planning/in-progress/slice-180-mutations-sensor-beleg-statt-lauf.md \
  -e docs/plan/planning/observations.md \
  -e test/mutations/74-mutate-kopie-ohne-git.sh
3
```

Damit fällt keiner der drei Pfade unter die definierende Bedingung von (c) („… nicht führt"). Und
keiner ist ein `# files:`-Ziel eines Mutations-Falls (`grep -rn "…" test/mutations/*.sh` → leer),
also strenggenommen auch nicht (a). Was die Edits real zeigen, ist die **allgemeinere** Eigenschaft,
aus der (a) folgt: jede getrackte Datei bewegt den Schlüssel, nicht nur ein Fall-Ziel. §7s Satz
*„derselbe Beleg, den Closure-Trigger 2 (a)/(c) verlangt"* schrieb damit eine Deckung zu, die die
zitierten Edits nicht tragen — R3-2 trifft zu, wie vom Reviewer befundet.

**Entscheidung: Probe (c) real gefahren, nicht die Formulierung eingeschränkt.** Der eine Pfad, der
(c)s Bedingung erfüllt, ist eindeutig bestimmt (§3 des Plans misst ihn bereits, ADR-0035 §Kontext
nennt ihn ebenfalls): `.claude/settings.local.json` — von `prepare_isolation` kopiert, aber über
das **globale** `~/.config/git/ignore` (`**/.claude/settings.local.json`) von
`--exclude-standard` ausgenommen, also nicht in `git ls-files`:

```
$ git check-ignore -v .claude/settings.local.json
/home/db/.config/git/ignore:1:**/.claude/settings.local.json	.claude/settings.local.json
$ git ls-files --cached --others --exclude-standard | grep -c settings.local
0
$ comm -23 <(bash -c "source harness/tools/mutate.sh 2>/dev/null||true; isolation_key_files"|sort -u) \
           <(git ls-files --cached --others --exclude-standard | sort -u)
.claude/settings.local.json
```

Zwei unabhängige, real gefahrene Proben gegen den echten Baum (keine synthetische Kopie):

1. **Schlüssel-Bewegung, isoliert.** Inhalt der Datei um eine Zeile geändert, `isolation_key()`
   davor/danach verglichen, Datei danach byte-identisch zurückgesetzt:

   ```
   before: ff9dd0975c2f95e310dd818bfaf1037ab545b0eb2137a7287812934c2cfc39b1
   after:  29b501f0aba8d5b976f88311bd0e1a75f1640fcb89f888981dd46da1b2f6ef68
   DIFFER (expected)
   restored: ff9dd0975c2f95e310dd818bfaf1037ab545b0eb2137a7287812934c2cfc39b1
   RESTORE OK
   diff <backup> .claude/settings.local.json → leer (byte-identisch)
   ```

2. **`main()` live, End-to-End.** Dieselbe Änderung, danach `bash harness/tools/mutate.sh`
   (`timeout -s TERM 8`) direkt gestartet: der Lauf druckt **nicht** die Übersprung-Meldung
   (*„… liegt vor … Kein Fall-Lauf."*), sondern läuft messbar in den Grün-Vorlauf hinein
   (`mutate: Gruen-Vorlauf make test-go …`, danach `250 Faelle auf 4 Worker …`), bis der `TERM`
   ihn nach 8 s sauber abbricht (`mutate: ABBRUCH — TERM empfangen …`, `0 ok, 4 Befund(e)`, Exit
   124 durch `timeout`). Kein Stale Lock danach (`.harness/state/mutate.lock` existiert nicht,
   `cleanup()` griff über den `TERM`-Trap), kein Leftover-Temp-Verzeichnis, Datei danach
   byte-identisch zurückgesetzt (`git status --porcelain .claude/settings.local.json` leer, weil
   ohnehin ignoriert — geprüft über direkten `diff` gegen die Sicherungskopie).

Beide zusammen sind der Beweis, den §5 für (c) verlangt: der eine qualifizierende Pfad bewegt den
Schlüssel **und** der bewegte Schlüssel bringt `main()` real dazu, den Fall-Satz zu fahren statt
überzuspringen — nicht angenommen, sondern beobachtet (ADR-0035 Festlegung 2, „gezeigt, nicht
angenommen"). Ergänzend strukturell gedeckt durch DoD (2a) (`test/mutate-driver.bats:938`,
„… jeder von prepare_isolation kopierte Pfad geht in den Schlüssel ein oder steht in der
Ausnahmeliste"): dieser Test läuft gegen die **echte** `$REPO` und garantiert, dass
`.claude/settings.local.json` (nicht `.git`) zwingend im Schlüssel landet — meine zwei Proben oben
sind die dazugehörige *Verhaltens*-Hälfte für genau diesen Pfad, nicht nur die *Mengen*-Hälfte.

**§7 des Plans korrigiert** (eigene Änderung dieses Verifier-Laufs, Diff unten): der Satz, der die
zwei Zwischen-Edits fälschlich (a)/(c) zuschrieb, benennt jetzt, was sie tatsächlich zeigen (die
allgemeine Trackiertheits-Eigenschaft), verweist auf den R3-2-Fund, und trägt die Probe (c) oben
mit Werten und Verweis auf diesen Report nach. Kein Code, kein DoD-Häkchen, keine Zusage außerhalb
von §7 berührt.

```
$ git diff --stat -- docs/plan/planning/in-progress/slice-180-mutations-sensor-beleg-statt-lauf.md
 .../slice-180-mutations-sensor-beleg-statt-lauf.md | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)
```

**Ausgang R3-2: geschlossen — Probe (c) real gefahren, §7 korrigiert.** Kein weiterer
Implementer-Turn nötig; die Korrektur ist Verifikations-Arbeit (Plan-vs-Beleg-Abgleich), nicht
Umsetzung.

## Nicht behoben, nicht blockierend: INFO-1 aus Runde 1

Runde 1 fand, dass `isolation_key()` nur Dateiinhalte hasht, nicht Datei-**Modi** (ein reiner
`chmod` bewegt den Schlüssel nicht), aber „keinen Fehlerpfad gefunden" — INFO, nicht verifizierbar,
kein beobachtetes Versagen. Runde 3 führt es unverändert als offen, blockiert aber selbst nicht
darauf. Ich schließe mich dieser Einordnung an: kein Code läuft modus-abhängig
(`bash "$case_file"`), kein Sensor dieses Slice deckt oder muss es decken. Kein neuer Befund.

---

## Normale Verifikation

### `make gates`

Zweimal frisch gefahren (vor und nach der §7-Korrektur, siehe unten). Erster Lauf (vor der
§7-Korrektur) `EXIT 0`: `baseline-verify: v5.18.0 OK — 53 Dateien` · `d-check: 599 Datei(en)
geprüft, 0 Befund(e)` · `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)` · bats `218 ok, 0 not
ok` (`grep -c '^not ok'` → 0) · `span-check: Traeger vorhanden, span-emit hat einen Span
geschrieben, Ablageort git-ignoriert`. Zweiter, unabhängiger Lauf (`make gates` erneut, komplett
frisch) bestätigte `EXIT 0` identisch. Nach der §7-Korrektur separat `make docs-check` gefahren:
schlug zunächst mit `target-missing` auf den noch nicht existierenden Verweis auf **diese** Datei
fehl (erwartungsgemäß, da der Verweis auf sich selbst zeigt und vor dem Schreiben dieses Reports
nicht auflösen konnte) — nach dem Schreiben dieser Datei erneut gefahren, siehe unten.

### `make mutate`

Der zuletzt aufgezeichnete Beleg (`c58120c7d9…`, aus Runde 3) war beim Start dieser Verifikation
**bereits** entwertet — nicht durch mich, sondern durch `cfa398b` (R3-1, selbst eine getrackte
Datei-Änderung, bewegt den Schlüssel strukturell wie jede andere): `isolation_key()` des sauberen
Baums lieferte `ff9dd097…`, ungleich dem Beleg. Da der Diff von `cfa398b` verifiziert
kommentar-only ist (oben), ist dieser Mismatch **erwartetes, korrektes** Verhalten der Zusage
(„EIN Beleg-Slot … ein Lauf über einem ANDEREN Prüfgegenstand entwertet ihn") und kein Befund.

Statt mich auf den Diff-Vergleich zu beschränken, habe ich einen **vollen** `make mutate`-Lauf
gefahren (`MUTATE_JOBS=4 bash harness/tools/mutate.sh`, 16:58–17:19 Uhr,
`/tmp/tmp.0iDeSBmSZ1` als Isolationskopie), um einen frischen, zum damaligen Baum passenden Beleg
zu erzeugen und die Fitness Function ein weiteres Mal gegen den vollständigen Fall-Satz laufen zu
lassen:

```
mutate: untere Schranke jeder Parallelisierung = laengster Einzelfall: 80.71 s (199-mutate-zeitschranke-greift-nie); Fall-Arbeit gesamt 4702.9 s
mutate: 250 ok, 0 Befund(e)
```

Exit 0, Vollständigkeit 250/250 (`ls test/mutations/*.sh | wc -l` → 250, deckungsgleich). Der Beleg
wurde geschrieben (`.harness/state/mutate-passed.key`, Zeitstempel 17:19) und passte zum Baum zum
Zeitpunkt des Laufstarts. **Meine eigenen anschließenden §7-Edits bewegen den Schlüssel erneut** —
das ist dieselbe, jetzt zweifach beobachtete Eigenschaft aus R3-2 (jede getrackte Änderung bewegt
ihn), kein Defekt. Der aktuell auf der Platte liegende Beleg passt darum **nicht mehr** exakt zum
finalen Stand dieses Reports; ein erneuter voller Lauf (weitere ~18 Minuten) wurde nicht angehängt,
weil er nichts Neues über den Treiber-Code aussagen würde (unverändert seit dem 250/0-Lauf oben) —
das ist explizit benannt, kein verschwiegener Rest.

### Plan-vs-Code-Diff

`git diff 65b5b3e HEAD --stat` (Basis: `slice-mv`-Commit vor der Implementer-Arbeit) zeigt exakt
die sieben in §3 der Plan-Tabelle genannten Berührungspunkte, nichts darüber hinaus:
`harness/tools/mutate.sh` (+169/−9), `test/mutate-driver.bats` (+151 neu), drei neue Fälle
(`262`/`263`/`264`), `test/mutations/74-…` (Anker-Nachzug), `harness/README.md` (+2/−1). Kein
`Makefile`-Eintrag (das offene Item „nur falls `MUTATE_FORCE` eine Vorgabe braucht" korrekt als
nicht nötig aufgelöst — die Variable wird durchgereicht, kein Default im Rezept).
`working-tree-hash.sh` unberührt, wie ADR-0035 Festlegung 3 verlangt.

DoD-Punkte gegen Code geprüft:

- **(1)** vier Eigenschaften — Zustand `.harness/state/` (gitignored, außerhalb der Bezugsmenge:
  `ISOLATION_EXCLUDES=(./.harness/state)`), Schlüssel (`isolation_key_files`/`isolation_key`,
  dieselbe `ISOLATION_EXCLUDES`-Definition wie `prepare_isolation`, plus die eine deklarierte
  Ausnahme `ISOLATION_KEY_EXEMPT=(./.git)`), Schreibpunkt (`finalize_belief` nur bei
  `fail_count -eq 0`, letzte Anweisung von `main()`), Übersprung (Exit 0, Beleg-Stand, keine
  Fall-Zahl, Zeile 1478–1481) — alle vier im Code wie beschrieben, `MUTATE_FORCE` als Ausschalter
  vorhanden und dokumentiert.
- **(2)** drei Fitness-Function-Zeilen mit Trägern: (a)/(2a) `test/mutate-driver.bats:938` + Fall
  `262`, (b)/(2b) Fall `264` + `test/mutate-driver.bats:1061` (Schlüssel-Vergleich, aus Runde 2
  nachgezogen), (c)/(2c) `test/mutations/263` + `test/mutate-driver.bats:1030` (SOFORTIGE
  Entwertung). Alle drei bats-Tests liefen in `make gates` grün, alle drei Fälle liefen im vollen
  `make mutate`-Lauf oben grün mit.
- **(3)** Kopf von `mutate.sh` führt jetzt sechs (nicht mehr fünf) fail-closed-Bedingungen inkl.
  der Übersprung-Bedingung mit Bezugsmenge, Ausnahme und benanntem Rest; `harness/README.md`
  trägt denselben Inhalt für externe Leser — beide Stellen gegengelesen, decken sich mit dem Code.
- **`make gates` grün** — bestätigt oben, zweifach.
- **Closure-Notiz** — §7 vorhanden, jetzt inklusive der R3-2-Korrektur.
- **Beobachtungs-Register nicht fortgeschrieben** — korrekt unverändert
  (`git diff 65b5b3e HEAD -- docs/plan/planning/observations.md` leer); nach Modul 6 ist der
  Schreibpunkt die Slice-Closure (Planner), nicht dieser Implementer- oder Verifier-Lauf. Vier
  Kandidatenzeilen (`BEO-031`…`034`) liegen in §7 vorbereitet, aktuell höchste vergebene Kennung
  ist `BEO-030` — keine Kollision.
- **Jedes Risiko trägt einen Ausgang** — alle 11 Risiken aus §6 geprüft: 1 (weiter offen,
  `BEO-031`-Kandidat), 2 (weiter offen, `BEO-032`-Kandidat), 3 (entfallen, Code enthält keine
  Dateityp-Filterung — bestätigt: `isolation_key_files()` filtert nicht nach Extension), 4
  (entfallen, kein `git diff`/`git log` im Schlüsselpfad — bestätigt: `grep -n 'git diff\|git log'
  harness/tools/mutate.sh` zwischen `isolation_key_files` und `finalize_belief` liefert nichts), 5
  (entfallen, Wanduhr-Verhältnis gemessen — meine eigene Zeitmessung oben bestätigt dieselbe
  Größenordnung: ~18 Min. voll vs. Sekundenbruchteile Übersprung), 6 (weiter offen,
  `BEO-033`-Kandidat), 7 (entfallen, ADR-0035 unbewegt seit Plan-Erstellung — bestätigt:
  `git log --oneline -- docs/plan/adr/0035-…md` → ein Commit, Status weiter `Proposed`), 8
  (eingetreten, im Slice aufgelöst — Runde-3-Reviewer bestätigte unabhängig), 9 (entfallen, Lock
  vor Beleg-Check — bestätigt per Zeilennummern), 10 (weiter offen, bereits `BEO-003`), 11 (weiter
  offen, bereits `BEO-007`). Kein Risiko ohne Ausgang.
- **Drei Paarungen** — korrekt als „noch nicht geprüft" markiert; sie laufen am formalen
  `git mv`-Closure-Schritt (Planner), den weder Implementer noch Verifier ausführen (Modul 6 §Wer
  schreibt, wer liest / Modul 8 §Rollen-Sequenz für eine Welle).

**Nichts Ungeplantes gefunden.** Der Diff bewegt sich vollständig innerhalb der in §3 der Plan-
Tabelle genannten Dateien; die einzige Abweichung vom ursprünglichen Plan-Text selbst ist meine
eigene §7-Korrektur, oben offengelegt.

---

## Verdikt

**Freigegeben für Closure.** Alle drei DoD-Kernpunkte (1)/(2)/(3) sind im Code verifiziert, nicht
nur behauptet; `make gates` läuft zweifach grün; ein vollständiger `make mutate`-Lauf über dem
ausgelieferten Stand bestätigt `250 ok, 0 Befund(e)`. Der einzige verbleibende Auflagenpunkt aus
Review-Runde 3 (R3-2) ist geschlossen: Closure-Trigger 2(c) wurde in diesem Verifier-Durchgang
**real gefahren** — der qualifizierende Pfad (`.claude/settings.local.json`) bewegt den Schlüssel
und bringt `main()` nachweislich zum vollen Lauf statt zum Übersprung —, und §7 des Plans trägt die
korrigierte Zuschreibung samt Verweis auf diesen Report. R3-1 (LOW) ist als Kommentar-only-Fix
gegengeprüft. Die zwei offenen DoD-Häkchen (Beobachtungsregister, drei Paarungen) sind laut Modul 5/6
korrekt dem formalen `in-progress/` → `done/`-Schritt des Planners vorbehalten und kein
Verifier-Blocker.

**Zwei Hinweise für den Planner vor dem `git mv`:**

1. Der aktuell auf der Platte liegende Mutate-Beleg (`.harness/state/mutate-passed.key`) passt
   **nicht** exakt zum finalen Commit-Stand dieses Reports (meine eigenen §7-Edits nach dem vollen
   Lauf haben den Schlüssel zuletzt bewegt) — erwartetes Verhalten, kein Befund; ein erneuter
   Closure-naher `make mutate`-Lauf holt den Beleg wieder ein, falls gewünscht.
2. Die drei Reviewer-Reports zu diesem Slice sind unter `-verify(.md/-runde-N.md)` abgelegt statt
   unter dem repo-üblichen `-review(.md/-runde-N.md)` — eine Namenskonvention-Abweichung, die ich
   als Verifier nicht behebe (fremdes Rollen-Artefakt), aber hiermit benenne, weil sie mich
   zwang, diesen Report anders zu benennen als die Vorlage `<datum>-<gegenstand>-verify.md`
   wörtlich vorgibt.

**Sensor-Belege dieses Reports, alle selbst gefahren:** `make gates` ×2 · `make mutate` ×1 voll
(250/250) · zwei isolierte `isolation_key()`-Proben gegen `.claude/settings.local.json` · eine
`main()`-Live-Probe (`timeout -s TERM 8`) · `git show cfa398b` · `git diff 65b5b3e HEAD` (Stat und
Inhalt) · `git log` gegen ADR-0035 und `docs/plan/planning/observations.md`.
