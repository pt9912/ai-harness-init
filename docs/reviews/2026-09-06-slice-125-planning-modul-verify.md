# Review-Report: slice-125 — 2026-09-06

**Review-Art:** Verifikation — geprüft wird gegen **DoD und Spec** (Modul 11), nicht gegen
Plan/ADR/Hard Rules (das ist Reviewer-Arbeit, drei Runden liegen vor, zuletzt
freigegeben — `2026-09-06-slice-125-re-check-runde-3.md`, Verdikt „merge-blockierend: nein").
Dieser Lauf liest den Slice-Plan im **aktuellen** Wortlaut (§3.10 wurde eingehalten: kein
Nachschreiben der DoD). **Nicht Gegenstand:** Closure-Notiz §7, DoD-Häkchen (Planner, §3.10),
und der offene MEDIUM aus Runde 3 (R-1, elf lebende Stellen mit falscher Modul-Liste) — sein
Gegenstand liegt in Architect- und Planner-Artefakten, der Report ist die Übergabe.

**Gegenstand:** `slice-125` · Bestand `c63ef63..94c0080` auf `main` (12 Commits:
`c63ef63`, `b3e49d5`, `abf05be`, `48f7f58`, `6584b06`, `1d18ea4`, `b3c0283`, `ac237dc`,
`487e326`, `bd25cb7`, `cd7eaaf`, `94c0080` — Reviewer-Commits `0491611`/`a019ea6`/`09cad1f`
ausgenommen). Elf berührte Dateien: `.d-check.yml`, `docs/plan/planning/in-progress/roadmap.md`,
`.github/workflows/ci.yml`, `harness/README.md`, `Makefile`, `test/planning-modul-wiring.bats`,
`test/mutations/{269,270,271,272,273}-planning-*.sh`.

**Modell:** claude-sonnet-5 · **Datum:** 2026-09-06

**Eingangs-Kontext:**

- Slice-Plan `docs/plan/planning/in-progress/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md`
  (§1 Anlass und Baseline-Messung · §2 DoD (1)–(3) · §3 Plan-Tabelle · §4 Rückführungen · §6
  Risiken).
- Drei Review-Reports — als Kontext gelesen, nicht als Prüfgrundlage übernommen; jede Behauptung
  unten ist selbst nachgemessen: `2026-09-06-slice-125-planning-modul-review.md` (Runde 1, ein
  HIGH + vier MEDIUM), `2026-09-06-slice-125-re-check-nacharbeit.md` (Runde 2, ein HIGH + drei
  MEDIUM), `2026-09-06-slice-125-re-check-runde-3.md` (Runde 3, ein MEDIUM, freigegeben).
- `LH-QA-01` (keine halluzinierten Gates), `LH-QA-02` (Reproduzierbarkeit), `ADR-0003`
  (Docker-only), `MR-052` (d-check-Pin v0.74.1, `planning` verfügbar), `MR-025` (Zahl neben
  Kommando).
- `AGENTS.md` §3.6 (rot gesehenes Gegenbeispiel), §3.7 (Kommentar-/Zustandsfeld-Regel), §3.9
  (Docker-only), §3.10 (Abnahmekriterium bleibt beim Planner).
- Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine (Ruhe-Marker als
  derivative Aussage über `in-progress/`), `modul-06-roadmap.md` §Roadmap-Struktur.

---

## 1. DoD-Punkte, einzeln nachgemessen

### DoD (1) — `planning` ist in `.d-check.yml` aktiviert und läuft in `make gates`, über einer für dieses Repo wahren Invariante

**Erfüllt.** Selbst nachgemessen, nicht übernommen:

```
$ grep -m1 '^modules:' .d-check.yml
modules: [links, anchors, ids, matrix, codepaths, spans, planning]
$ make gates            # EXIT 0, u. a. "d-check: 867 Datei(en) geprüft, 0 Befund(e)"
```

Der geforderte Rot-Nachweis — `slice-*.md` nach `in-progress/` legen, während die
Roadmap-Sektion den Ruhe-Marker trägt — selbst gegen eine isolierte Kopie außerhalb des
Arbeitsbaums gefahren (`git archive HEAD | tar -x`, `--network none`, Mount `:ro`, Image
`ghcr.io/pt9912/d-check` per Digest `sha256:e31a372…`, identisch mit `d-check.mk`):

```
$ sed -i '/^## Offene Wellen$/a\
\
Nichts in Arbeit.' <kopie>/docs/plan/planning/in-progress/roadmap.md
$ ls <kopie>/docs/plan/planning/in-progress/
roadmap.md
slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md
$ docker run --rm --network none -v "<kopie>:/repo:ro" \
    ghcr.io/pt9912/d-check@sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641
d-check: 867 Datei(en) geprüft, 1 Befund(e)
docs/plan/planning/in-progress/roadmap.md:11 … planning-drift  Slice(s) in
  docs/plan/planning/in-progress, aber die Roadmap-Sektion „## Offene Wellen“ trägt den
  Ruhe-Marker „Nichts in Arbeit.“ — die Sektion muss die Arbeit benennen
$ echo $?
1
```

Kontrolle über derselben unveränderten Kopie: `867 Datei(en) geprüft, 0 Befund(e)`, Exit 0 —
**der unveränderte Baum bleibt grün**, wie DoD (1) verlangt. Beide Läufe sind hiermit unabhängig
reproduziert.

### DoD (2) — Die gewählte Sektion kann wirklich driften (beide Richtungen), nicht nur behauptet

**Erfüllt.** DoD (1) belegt bereits eine Richtung (Marker bei besetztem `in-progress/`). Die
Gegenrichtung selbst nachgestellt — `slice-125` aus `in-progress/` einer Kopie entfernt, **ohne**
den Marker zu setzen:

```
$ rm <kopie2>/docs/plan/planning/in-progress/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md
$ docker run --rm --network none -v "<kopie2>:/repo:ro" ghcr.io/pt9912/d-check@sha256:e31a372…
d-check: 866 Datei(en) geprüft, 23 Befund(e)
docs/plan/planning/in-progress/roadmap.md:11 … planning-drift  kein Slice in
  docs/plan/planning/in-progress, aber die Roadmap-Sektion „## Offene Wellen“ trägt den
  Ruhe-Marker „Nichts in Arbeit.“ nicht — er gehört dorthin
$ echo $?
1
```

(Die übrigen 22 Befunde dieses Laufs sind `target-missing` auf Links, die auf die entfernte
Slice-Datei zeigen — ein Artefakt des synthetischen Lösch-Experiments, kein Teil des
Rot-Nachweises.) Beide Richtungen färben real rot über derselben Config — die Invariante ist
über der gewählten Sektion **nicht trivial**, wie DoD (2) verlangt. Der begleitende Fließtext
(§1 der Roadmap, „## Offene Wellen") benennt „aktiv" konsistent mit dieser Messung.

### DoD (3) — Über die `waves`-Fähigkeit ist entschieden, die zwei Befunde sind benannt

**Erfüllt.** `waves` ist nicht aktiviert:

```
$ grep -E '^  (waves|closure|observations):' .d-check.yml
<leer>
```

`harness/README.md` (Absatz „Was das Modul `planning` in `docs-check` deckt, und was nicht")
nennt den Grund neben dem, was `docs-check` nicht prüft: `waves.mode: many` verlangt eine
Bijektion zwischen den Zeigern unter „Offene Wellen" und den flachen Welle-Dateien
(Default-Modus `one` prüft stattdessen ein Singleton), und beide Modi kennen die in der Roadmap
selbst dokumentierte Abweichung dieses Repos nicht (Welle-Datei wird vor Eintritt ihres
Start-Triggers geschnitten — `ls docs/plan/planning/welle-*.md` führt drei Dateien, „Offene
Wellen" nennt zwei Zeiger). Da `waves` **nicht** aktiviert ist, greift die im DoD (3) genannte
Rot-Bedingung („aktiviert, ohne dass welle-09s Lage geklärt ist") nicht — konsistent geprüft:
kein `wave-drift`/`wave-preview-exists` in `make gates` (bestätigt: `d-check: 867 Datei(en)
geprüft, 0 Befund(e)`, kein Grund-Code `wave-*`).

### Standard-Punkte der Vorlage

- **`make gates` grün:** selbst gefahren, **EXIT 0** — `baseline-verify` (v6.0.0, 53 Dateien),
  `docs-check` (867 Dateien, 0 Befund(e)), `comment-claims` (56 Dateien, 0 Befund(e)), `lint`,
  `build`, `test` (Go `-count=1`, alle Pakete `ok`), `shell-lint`, `ci-lint` (actionlint clean),
  `host-bin`, `span-check` (Träger vorhanden, Span geschrieben, git-ignorierter Ablageort).
  `make record-gates` danach separat gefahren — Stempel deckt den Arbeitsbaum, Baum vor und nach
  dem Lauf sauber (`git status --porcelain` leer).
- **`make mutate` ohne Befund:** als **Vollauf** gefahren (`MUTATE_FORCE=1 make mutate`), Ergebnis
  **`259 ok, 0 Befund(e)`**. Die fünf slice-eigenen Fälle einzeln bestätigt — jeder trifft die im
  `# expect:` benannte Zusicherung:

  ```
  mutate: ok  269-planning-modul-aus-modules-entfernt        -> planning ist in modules: aktiviert rot
  mutate: ok  270-planning-heading-auf-modul-default-…       -> heading … rot
  mutate: ok  271-planning-marker-zeile-entfernt              -> marker … rot
  mutate: ok  272-planning-heading-auf-marker-lose-sektion    -> heading … rot
  mutate: ok  273-planning-block-rumpf-entfernt               -> waves bleibt aus … rot
  ```

  Dies ist unabhängig von Runde 3s Sonden S1–S12 (Reviewer) noch einmal als vollständiger,
  repo-weiter Lauf erbracht — kein Rückgriff auf den Beleg-Slot aus `ADR-0035`, da der letzte
  Stand vor diesem Lauf nicht als vollständig grün vorlag (drei Nacharbeits-Runden dazwischen).
- **Doku-Update:** `harness/README.md` aktualisiert (Deckungs-Absatz, geprüft unter §3 unten).

## 2. Plan-vs-Code-Diff

Vollständiger Datei-Diff über den Slice-Bestand (die drei Reviewer-Commits `0491611`/`a019ea6`/
`09cad1f` sind reine Report-Commits, ausgenommen):

```
.d-check.yml                                              |  16 +-
.github/workflows/ci.yml                                  |   2 +-
Makefile                                                  |   6 +-
docs/plan/planning/in-progress/roadmap.md                 |  22 +-
harness/README.md                                         |  26 +-
test/mutations/269-planning-modul-aus-modules-entfernt.sh          |  10 +
test/mutations/270-planning-heading-auf-modul-default-…            |  10 +
test/mutations/271-planning-marker-zeile-entfernt.sh               |  11 +
test/mutations/272-planning-heading-auf-marker-lose-sektion.sh     |  11 +
test/mutations/273-planning-block-rumpf-entfernt.sh                |  16 +
test/planning-modul-wiring.bats                                    |  76 ++++
```

**Deckt Plan §3, was der Plan vorsah:** `.d-check.yml` (update — `planning` in `modules:` **und**
der `planning:`-Block mit `roadmap`/`heading`/`marker`, kein `waves`) · `roadmap.md` (update —
Auflösung des vorliegenden `planning-drift` durch den neuen Erklärungsabsatz und die Entfernung
des zum Umsetzungszeitpunkt falschen Ruhe-Markers, siehe §4 unten) · `harness/README.md` (update
— Deckungs-Absatz) · `test/` (neu — bats-Datei + fünf Mutationsfälle). `docs/plan/planning/
README.md` war „ggf. update" und blieb unberührt — zu Recht: die dort stehende Aussage
(„Slices tragen ihren Status über das Verzeichnis") ist von der hier geschärften „aktiv"-Frage
nicht betroffen. `harness/conventions.md` — explizit „nicht durch diesen Slice" — bestätigt
unberührt (kein Treffer im Diff), die Übergabe an den Architect ist zwar per `MR-037`
gegenstandslos geworden (F-7, INFO, Runde 1), berührt aber keine DoD-Klausel.

**Über Plan §3 hinaus, aber begründet (Review-getriebene Selbstkorrektur, kein Scope-Creep):**
`.github/workflows/ci.yml` und `Makefile` sind in keiner Zeile von §3 genannt. Beide Änderungen
korrigieren eine Modul-Zahl-Aussage, die **derselbe Diff** falsch gemacht hat (sechs statt sieben
Module) bzw. eine Isolations-Lücke, die **dieselbe Aktivierung** aufgerissen hat
(`regelwerk-check`s sechs `--disable`-Flags ließen `planning` nach der Aktivierung ungefiltert
mitlaufen — Finding N-1, HIGH, Runde 2, in `cd7eaaf` behoben). Das ist Aufräumen der eigenen
Nebenwirkung, keine Ausweitung der Funktion: Der Kern (`planning:`-Block, Bindung auf „## Offene
Wellen") tut exakt, was §1/DoD (1)–(3) beschreiben, nichts darüber hinaus. Kein Scope-Creep
gefunden.

## 3. Spec-/ADR-Konformität

- **`LH-QA-01` (keine halluzinierten Gates):** Der zentrale Fall dieses Slice — ein Modul war
  aktiv, aber ohne Config-Block wirkungslos (§1 der Plan-Datei, gemessen: `0 Befund(e)` ohne
  `planning:`-Block trotz eines echten Drifts am Mess-Stand). Nach diesem Diff prüft `planning`
  eine für dieses Repo reale, in beide Richtungen drift-fähige Invariante (§1 oben) —
  **konform, und der Anlassfall selbst ist behoben.**
- **`LH-QA-02` (Reproduzierbarkeit):** Alle Sonden liefen netzlos (`--network none`), gegen
  isolierte Kopien außerhalb des Arbeitsbaums, mit demselben per Digest gepinnten Image wie
  `make docs-check`. Deterministisch (kein Zeitstempel, kein Zufall im Modul `planning`,
  hermetisch laut `.d-check.yml`-Kommentar). **Konform.**
- **`ADR-0003` (Docker-only):** Der neue bats-Test läuft über `make test` → `test-bats` im
  gepinnten `BATS_IMAGE`; die fünf Mutationsfälle sind reine `sed`-Skripte, ausgeführt vom
  Mutations-Treiber, nicht vom Host direkt. Keine Host-Toolchain in Rezept oder Test. **Konform.**
- **Deckt `harness/README.md`, was `planning` prüft und was nicht?** Ja, nach Runde 2/3 der
  Nacharbeit vollständig: Der Absatz nennt die Marker-Hälfte (aktiv, gebunden auf „## Offene
  Wellen") und die drei nicht aktivierten Fähigkeiten einzeln — `waves` (Grund: Bijektion vs.
  Singleton, Abweichung des Repos unbekannt, **kein** Träger-Slice), `closure` (anderer
  Gegenstand, Träger `slice-129`), `observations` (vierte, additiv fünfte Fähigkeit, **kein**
  Träger-Slice, Zeiger auf `BEO-ALL/register-paarung-ohne-gate-modul`). Selbst gegen den
  gepinnten Werkzeug-Quellstand geprüft: `grep -n ObservationsConfig
  /Development/d-check/internal/hexagon/core/model/config.go` bestätigt die vierte Fähigkeit
  wörtlich als „VIERTE planning-Fähigkeit". Der einzige verbleibende Mangel dieses Absatzes
  (Runde 3, R-1, MEDIUM) betrifft **andere** Dateien (den ADR-Index, `AGENTS.md`, sieben fremde
  Slice-Pläne), nicht diesen Absatz selbst.

## 4. §6-Risiken — auf verdeckte DoD-Verletzung geprüft

Alle vier Einträge in §6 gelesen und einzeln gegen die Frage geprüft, ob einer in Wahrheit ein
DoD-Defekt ist, der als Risiko getarnt wurde:

| Risiko | Befund |
|---|---|
| Prüfbereich ist die Roadmap, ein Planner-Artefakt — Druck, die Roadmap dem Sensor anzupassen | Kein DoD-Verstoß. DoD (2) verlangt genau diese Entscheidung explizit und dokumentiert; sie liegt vor (§1 oben). |
| Versuchung, den Befund wegzukonfigurieren (`heading`/`marker` auf eine triviale Sektion) | **War real** und wurde vom Review gefunden (F-1, HIGH, Runde 1: zwei stille Config-Änderungen ließen `docs-check` grün, ohne dass ein Zahn sie hielt) — **und ist behoben**: alle fünf `test/mutations/26{9}-27{0,1,2,3}`-Fälle sind jetzt gelistet und selbst nachgefahren (§1 Standard-Punkte oben). Kein offener DoD-Verstoß mehr. |
| `wave-preview-exists` auf `welle-09` — ungelöstes Prozess-Thema, dieser Slice entscheidet es nicht | Kein DoD-Verstoß — DoD (3) verlangt nur die Entscheidung „waves bleibt aus, mit Grund", nicht die Auflösung von `welle-09`. Konsistent mit §3 oben. |
| Diese Datei wandert selbst durch den Prüfbereich — der Gate muss grün sein, **während** `in-progress/` besetzt ist | Für den **aktuellen** Zustand (`in-progress/` besetzt) kein DoD-Verstoß — DoD (1) verlangt genau das, und es ist erfüllt. **Der Text deckt aber nicht den symmetrischen Fall bei der Closure** — siehe §5 unten, eigener Befund, keine DoD-Verletzung *heute*. |

**Kein als Risiko getarnter DoD-Defekt gefunden**, der heute besteht. Ein Gap für den Moment
*nach* der Closure ist real, aber gehört strukturell nicht zu DoD (1)–(3) dieses Slice — siehe §5.

## 5. Die Besonderheit: Ruhe-Marker-Rückstellung bei Closure

**Befund: nicht in einem Artefakt festgehalten, das die Closure konsultieren würde — bestätigt
durch eigene Reproduktion, kein Automatismus außer dem Gate selbst.**

Selbst reproduziert (§1 DoD (2), zweite Messung): Wird `slice-125` aus `in-progress/` entfernt
(wie es der `git mv` nach `done/` bei der Closure tut), **ohne** den Ruhe-Marker
`Nichts in Arbeit.` wieder in den Block unter „## Offene Wellen" einzutragen, meldet `docs-check`
sofort `planning-drift`, Exit 1 — der neue Sensor würde **seinen eigenen Abschluss** rot färben.

Geprüft, wo diese Bedingung heute steht:

- **Slice-Plan §6** (siehe Tabelle oben, letzte Zeile) benennt nur die *Umsetzungszeit*-Hälfte
  („Gate muss grün sein, während `in-progress/` besetzt ist"), nicht die *Closure*-Hälfte.
- **Slice-Plan §7** (Closure-Notiz) ist leer (`<!-- Erst nach Abschluss füllen. -->`) — noch kein
  Trägerartefakt, korrekt, da Planner-Arbeit nach §3.10.
- **Runde-1-Review** (F-5(b)) benannte die Bedingung explizit als Übergabe an den Planner: „wird
  `in-progress/` bei der Closure leer, muss der Ruhe-Marker … zurück … sonst meldet
  `planning-drift`". Runde 2 bestätigte „nicht behoben — korrekt unterlassen, denn am Ist-Stand
  richtig". **Runde 3s abschließende „Übergabe"-Liste an den Planner nennt diesen Punkt nicht
  mehr** — sie führt `roadmap.md:59` (N-4, eine andere Modul-Zahl-Aussage), `welle-13-…:319` und
  die sieben fremden Slice-Pläne aus R-1, aber nicht F-5(b). Der Punkt ist damit zwischen den
  Runden **nicht verloren** (er steht in Runde 1 und ist dort nachlesbar), aber er ist **nicht
  mehr im aktiven Hand-off** der freigebenden Runde — und Review-Reports werden laut Modul 10
  über Läufe hinweg nicht wieder gelesen.
- **`make slice-mv`** (das Werkzeug, das den `git mv` bei der Closure typischerweise fährt) „zieht
  Pfade nach, keine Zustandssätze" (`harness/README.md`, erste der drei gemessenen Grenzen) —
  es restauriert den Marker nicht automatisch.
- **Das Beobachtungs-Register** führt keinen Eintrag zu dieser konkreten Bedingung; die Nachbar-
  Beobachtung `zusage-neben-geaenderter-ableitung-bleibt-stehen` hat einen strukturell ähnlichen,
  aber anderen Fall dokumentiert (`evidence/slice-187.md`: der Ruhe-Marker blieb bei einem
  *anderen* Slice stehen, während `in-progress/` ihn schon trug — die Umkehrung des hier
  betrachteten Falls).

**Bewertung:** Das ist **keine DoD-Verletzung dieses Slice** — DoD (1)–(3) sind, wie oben gezeigt,
alle erfüllt, und das mechanische Netz greift: Der Stop-Hook dieses Repos
(`stop-require-gates.sh`) lässt keinen Abschluss ohne einen frischen, baumdeckenden
`make gates`-Lauf zu; ein Planner, der `slice-125` nach `done/` bewegt und danach `make gates`
fährt (repo-weiter Workflow-Schritt, `AGENTS.md` §6 Schritt 6), sieht die Drift **vor** jedem
Commit-Abschluss und muss sie beheben, bevor die Session enden kann. Der Fehler kann also nicht
unbemerkt auf `main` landen — aber die Bedingung ist **nirgends explizit vorgeschrieben**, nur
mechanisch erzwungen, und ein Planner-Lauf, der den Move committet, ohne zwischenzeitlich
`make gates` zu fahren (z. B. bei einem reinen `git mv` ohne Folge-Commit-Prüfung), würde sie erst
im nächsten fremden Lauf entdecken. **Empfehlung an den Planner:** den Punkt bei der Closure
explizit im Risiko-Ausgang oder in der Closure-Notiz §7 festhalten (Ausgang *eingetreten* wäre
falsch, es ist noch nicht eingetreten; *entfallen* wäre falsch, die Bedingung besteht; richtig ist,
die Rückstellung des Markers als expliziten Closure-Schritt vor dem `git mv`-Commit zu benennen,
nicht nur dem Gate zu überlassen).

## Negativbefunde

- geprüft, ohne Befund: **DoD (1), (2), (3)** — jeweils der behauptete Rot-Nachweis selbst
  gefahren, gegen isolierte Kopien, nicht nur die Behauptung übernommen (Abschnitt 1).
- geprüft, ohne Befund: **`make gates`** — EXIT 0, selbst gefahren, Stempel via
  `make record-gates` erneuert, Arbeitsbaum vor/nach dem Lauf sauber.
- geprüft, ohne Befund: **`make mutate`** als Vollauf — `259 ok, 0 Befund(e)`, alle fünf
  slice-eigenen Fälle einzeln bestätigt.
- geprüft, ohne Befund: **`LH-QA-01`/`LH-QA-02`/`ADR-0003`** gegen den aktuellen Code-Stand
  (Abschnitt 3).
- geprüft, ohne Befund: **Scope-Creep in der Kernfunktion** — der `planning:`-Block und seine
  Bindung tun exakt, was §1/DoD beschreiben; die zwei über §3 hinausgehenden Dateien
  (`ci.yml`, `Makefile`) sind Selbstkorrekturen derselben Änderung, keine Funktionsausweitung
  (Abschnitt 2).
- geprüft, ohne Befund: **§6-Risiken als versteckte DoD-Verletzung** — keiner der vier Einträge
  maskiert einen heute bestehenden DoD-Defekt (Abschnitt 4).
- **geprüft, mit Befund ohne DoD-Bezug:** die Ruhe-Marker-Rückstellung bei Closure ist nicht in
  einem von der Closure konsultierten Artefakt festgehalten — mechanisch durch den Stop-Hook
  abgesichert, aber nicht explizit vorgeschrieben (Abschnitt 5).
- **nicht geprüft, außerhalb dieses Gegenstands:** der offene MEDIUM aus Runde 3 (R-1, elf lebende
  Fundorte einer falschen Modul-Zahl, neun unbenannt) — Architect-/Planner-Artefakte, keine
  DoD-Aussage dieses Slice berührt (bestätigt: DoD (1)–(3) nennen keine dieser elf Dateien).

## Verdikt

**DoD erfüllt: (1) ja · (2) ja · (3) ja — alle drei selbst nachgemessen, nicht übernommen.**

**Kein Merge-Blocker aus Verifier-Sicht.** Der Kern des Slice hält, was er zusagt: ein zuvor
aktives, aber wirkungsloses Modul (`LH-QA-01`-Fall) prüft jetzt eine reale, beidseitig
drift-fähige Invariante, mit einem vollständigen Mutations-Zahn-Satz und einem repo-weit grünen
`make gates`/`make mutate`. Die zwei über den Plan hinausgehenden Dateien sind Selbstkorrekturen,
kein Scope-Creep.

**Eine echte, aber nicht blockierende Lücke:** Die Bedingung „Ruhe-Marker muss bei Closure
zurückgestellt werden, sonst wird `make gates` rot" ist real (selbst reproduziert, Abschnitt 5),
seit Runde 1 des Reviews bekannt (F-5(b)), aber in der abschließenden Übergabe von Runde 3 nicht
mehr genannt und in keinem von der Closure gelesenen Artefakt (§6, §7) festgehalten. Sie ist
**mechanisch abgesichert** (Stop-Hook verlangt einen frischen grünen `make gates`-Lauf vor
Session-Ende) und daher **kein DoD-Verstoß dieses Slice** — aber ein Punkt, den die Closure
explizit behandeln sollte, statt sich allein auf das Gate zu verlassen.

**Übergabe:** Dieser Bericht geht an den Planner (Modul 8, Verifier→Planner-Kante). Er ersetzt
kein Review — Plan-/ADR-/Hard-Rule-Konformität ist bereits dreifach geprüft und zuletzt
freigegeben. Er ersetzt keine Closure-Entscheidung über den in Abschnitt 5 benannten Punkt oder
über den in Runde 3 offen gelassenen MEDIUM (R-1) — das ist Planner-Urteil, einschließlich der
Frage, ob F-5(b) einen eigenen Beobachtungs-Register-Eintrag braucht oder als Closure-Notiz-Satz
genügt.
