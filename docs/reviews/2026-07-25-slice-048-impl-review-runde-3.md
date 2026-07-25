# Review-Report: slice-048 — Impl-Review Runde 3 (eng: Start-Smoke-Skript + MR-014-Nachtrag) — 2026-07-25

**Review-Art:** Code — geprüft gegen `harness/conventions.md` MR-014 Setzung 1
(Wortlaut und Reichweite der neuen Ausnahme), `AGENTS.md` Hard Rules (3.5 Gates
nicht ohne ADR lockern, 3.6 keine Zusage ohne rot gesehenes Gegenbeispiel) und
den Slice-Plan §2 DoD. **Nicht** gegen die DoD-Erfüllung als solche (Verifier,
Modul 11).

**Auftragsgemäß eng:** geprüft wurden **zwei Flächen** —

1. `harness/tools/start-smoke.sh` samt seiner beiden bats-Wächter am Ende von
   `test/release-matrix.bats` und dem Mutations-Fall
   `test/mutations/83-release-startsmoke-marker.sh`;
2. der **MR-014-Nachtrag** in `harness/conventions.md` (Setzung 1) und der
   korrespondierende Kopf-Absatz in `.github/workflows/release.yml`.

Matrix-Target, `Dockerfile`, `publish`-Job und die übrigen Wächter sind **nicht**
Gegenstand (zweimal geprüft in Runde 1 und Verifikation); was dort auffiel, steht
als INFO mit einem Satz.

**Gegenstand:** `7b717f4` (Fix-Commit, führt beide Flächen ein), plus die
Workflow-Nachbesserungen `57c77ae` und `1de032c`.

**Skill:** `.harness/skills/reviewer.md` @ `1de032c` · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-25

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- `docs/plan/planning/in-progress/slice-048-release-artefakte.md` (§2 DoD)
- `harness/conventions.md` MR-014 (Setzung 1 samt Nachtrag 2026-07-25), MR-001
- `AGENTS.md` §3 Hard Rules (3.2, 3.5, 3.6), §4 Quality Gates
- `spec/lastenheft.md` LH-QA-04, LH-QA-01 · ADR-0003
- Vorläufer: `docs/reviews/2026-07-25-slice-048-impl-review.md`,
  `docs/reviews/2026-07-25-slice-048-verification.md`
- `.harness/baseline/v3.5.1/regelwerk/modul-10-review-harness.md` (Kategorien, Negativbefund-Pflicht)

**Mess-Grundlage dieses Laufs** (READ-ONLY, kein `make`, keine Host-Toolchain;
hermetische `bash`-Sonden auf Kopien außerhalb des Repos):

| Frage | Messung |
|---|---|
| Binary endet != 0 | `set -euo pipefail; out="$(bash -c "exit 3")"` → Skript endet mit **rc=3**, keine Folgezeile — fail-closed |
| Binary schreibt nur auf stderr, Exit 0 | `out` bleibt **leer**, beide Marker fehlen → Exit 1 — fail-closed |
| Binary gibt nichts aus, Exit 0 | `grep -qF` gegen leeren Here-String schlägt fehl → Exit 1 — fail-closed |
| Binary hängt | kein Zeitlimit im Skript; die Kommando-Substitution wartet unbegrenzt (Code gelesen, Zeile 28) |
| Marker vs. Dateiname | Usage kommt aus eigenem Const `cmd/ai-harness-init/main.go:34` (nicht `flag.Usage`); `argv[0]`/Pfad landet nie in `$out` |
| Argument **ohne** Slash | `[ -f "$bin" ]` grün, `"$bin" --help` macht **PATH-Lookup**: ohne Treffer rc=127; **mit** gleichnamigem Kommando in PATH läuft das **fremde** Binary, Skript meldet `OK`, rc=0 (Sonde B) |
| `chmod … \|\| true` | Sonde mit stets scheiterndem `chmod` in PATH + nicht ausführbarer Datei → **rc=126** aus `set -e`, keine Maskierung |
| Anker Fall 83 | `/grep -qF/` trifft im heutigen Stand **genau eine** Zeile (`start-smoke.sh:39`) |
| Wirkung Fall 83 | mutierte Kopie: Fake ohne Usage → rc **0** (vorher 1); Fake **mit** Usage → rc 0 unverändert → nur der negative Wächter rötet |
| Zwei-Marker-Zusage | Ein-Marker-Variante (`add-lang` entfernt) läuft unter **beiden** bats-Fixtures unverändert grün (rc 0 / rc 1) |
| „von `shell-lint` gedeckt" | `shell-lint`-Rezept lintet `harness/tools/*.sh` → trifft zu |

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

<!-- Kein Fließtext, kein Lösungsvorschlag im Befund. -->

### F-1 — Die Schranke der Ausnahme wird vom selben Commit verletzt: der Start-Smoke läuft auch auf den Linux-Runnern

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` §3.6 (Zusage ohne Deckung) · `harness/conventions.md` MR-014 Setzung 1
- `pfad`: `harness/conventions.md:588-589` gegen `.github/workflows/release.yml:70-73` und `:94-100`
- `befund`: Der Nachtrag setzt als einzige normative Schranke „Diese Ausnahme gilt
  **genau** für Steps auf Runnern ohne `make`; auf den Linux-Runnern bleibt
  `make <target>` verbindlich." Der `start-smoke`-Job hat **einen** Step für **alle
  sechs** Matrix-Einträge und ruft `bash harness/tools/start-smoke.sh` auch auf
  `ubuntu-24.04` und `ubuntu-24.04-arm`, wo `make` vorhanden ist — zwei der sechs
  Läufe fallen also unter die Regel, nicht unter die Ausnahme. Derselbe zu enge
  Zuschnitt steht in den beiden Paraphrasen `.github/workflows/release.yml:13-14`
  („Die eine Ausnahme ist der Start-Smoke auf den macOS-/Windows-Runnern") und
  `harness/tools/start-smoke.sh:10-13`, sowie im beschreibenden Halbsatz
  `harness/conventions.md:583-584` („läuft auf **macOS- und Windows-Runnern**").
- `verifizierbar`: ja — Lesen der Matrix gegen den Nachtragstext; **kein Gate misst
  es** (`ci-lint` prüft Syntax, `docs-check` prüft keine Aussagen über YAML).

### F-2 — Der Normsatz konditioniert auf den Runner, nicht auf die Eigenschaft, die den Zweck wahrt

- `kategorie`: MEDIUM
- `quelle`: `harness/conventions.md` MR-014 Setzung 1 („eine Quelle, nicht zwei") · `AGENTS.md` §3.5
- `pfad`: `harness/conventions.md:586-589`
- `befund`: Die zweckwahrende Eigenschaft — die Prüfung liegt als versioniertes, von
  `shell-lint` gedecktes Skript im Repo, der Workflow **ruft** sie nur auf, es
  entsteht keine zweite Definition in der YAML — steht ausschließlich im
  **Begründungs**-Satz. Der **Norm**-Satz („gilt genau für Steps auf Runnern ohne
  `make`") trägt sie nicht. Nach diesem Wortlaut ist ein künftiger Inline-Block mit
  Prüf-Logik direkt in `release.yml` gedeckt, sobald er auf `windows-2025` oder
  `macos-26` läuft — also genau die zweite Definition, gegen die Setzung 1 gerichtet
  ist. Die Ausnahme reicht damit in dieser Achse weiter als ihr gemessener Grund.
- `verifizierbar`: nein — Wortlaut-Befund; kein Sensor kann eine zu weit gefasste
  Regel röten (das ist der Grund, warum sie im MR-Block präzise stehen muss).

### F-3 — `"$bin" --help` ist ein PATH-Lookup, wenn das Argument keinen Slash trägt: Grün über einem fremden Binary möglich

- `kategorie`: MEDIUM
- `quelle`: `spec/lastenheft.md` LH-QA-01 (kein Nachweis über fremdem Bereich)
- `pfad`: `harness/tools/start-smoke.sh:23` und `:28`
- `befund`: `[ -f "$bin" ]` prüft eine **Datei**, `"$bin" --help` führt bei einem
  Argument ohne `/` dagegen ein **Kommando** aus dem PATH aus. Gemessen (Sonde B):
  liegt ein gleichnamiges Kommando im PATH, druckt dieses seine Usage, das Skript
  meldet `start-smoke: OK — ai-harness-init laeuft auf dieser Plattform` und endet
  mit 0, während die lokale, mit Exit 1 abbrechende Datei nie ausgeführt wurde — die
  Erfolgsmeldung nennt einen Pfad, der nicht gemessen wurde. Ohne PATH-Treffer endet
  derselbe Aufruf mit rc=127 „Befehl nicht gefunden", obwohl die Existenzprüfung
  eine Zeile zuvor grün war. Heute nicht erreichbar (der Workflow übergibt
  `dist/…`, die bats-Fixtures absolute Pfade), also latent; kein Wächter deckt den
  Fall, weil beide Fixtures Slashes tragen.
- `verifizierbar`: ja — `bash harness/tools/start-smoke.sh <name-ohne-slash>` in
  einem Verzeichnis mit gleichnamigem Kommando im PATH.

### F-4 — Die Zwei-Marker-Zusage hat kein Gegenbeispiel

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6
- `pfad`: `harness/tools/start-smoke.sh:33` und `:38` gegen `test/release-matrix.bats:127-148`
- `befund`: Der Kommentar sagt zu „Geprueft werden der Werkzeugname **und** ein
  Kommando aus der Usage". Gemessen bleibt eine Ein-Marker-Variante (Schleife nur
  über `ai-harness-init`) unter **beiden** bats-Fixtures grün — die positive Fixture
  trägt beide Marker, die negative keinen; ein Binary, das nur den Werkzeugnamen
  druckt, kommt in keinem Fixture vor. Fall 83 entfernt die Prüfung als Ganzes und
  deckt die feinere Zusage darum nicht.
- `verifizierbar`: ja — `make test` gegen eine Kopie mit verkürzter Marker-Liste
  bleibt grün.

### F-5 — Die Marker sind an keine Quelle gekoppelt

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6 (Test misst die Eigenschaft, nicht seine Fixture)
- `pfad`: `harness/tools/start-smoke.sh:38`, `test/release-matrix.bats:130` gegen `cmd/ai-harness-init/main.go:34-66`
- `befund`: `ai-harness-init` und `add-lang` stehen als Literale im Sensor **und** in
  der Fixture; nichts bindet sie an den `usage`-Const, aus dem die reale Ausgabe
  stammt. Wird das Subkommando umbenannt, bleiben beide bats-Wächter grün und der
  Bruch zeigt sich erst im Release- oder Dispatch-Lauf. Es ist dieselbe „feste Liste
  im Test statt gelesener Quelle"-Klasse wie F-4 aus Runde 1, die für die
  Plattform-Liste bereits per `lh_platforms()` aufgelöst wurde.
- `verifizierbar`: ja — Umbenennung im `usage`-Const, `make test` bleibt grün.

### F-6 — Der gemessene Grund deckt zwei der vier `make`-losen Runner-Labels nicht, und trägt keinen Beleg-Anker

- `kategorie`: LOW
- `quelle`: „keine fabrizierten Belege" (autoritative Quelle zeigen statt behaupten) · `AGENTS.md` §3.6
- `pfad`: `harness/conventions.md:584-585`
- `befund`: Der Nachtrag nennt als Messung die Runner-Images-Readmes für
  `windows-2025` und `macos-26`. Die Matrix trägt vier Nicht-Linux-Labels —
  zusätzlich `macos-26-intel` und `windows-11-arm` (`.github/workflows/release.yml:74-81`),
  eigene Images mit eigenen Readmes. Ein Anker auf die Quelle (Repo, Pfad oder URL
  der Readmes) fehlt, ein späterer Leser kann die Aussage also nicht nachmessen.
  Der Dispatch-Lauf `30166346539` lief auf allen sechs Runnern und hätte die
  Abwesenheit von `make` empirisch festmachen können; er hat sie nicht gemessen,
  weil der Step durchgehend `bash` ruft.
- `verifizierbar`: ja — ein `make --version || echo absent`-Step in einem
  Dispatch-Lauf.

### F-7 — Kein Zeitlimit um den Binary-Aufruf

- `kategorie`: LOW
- `quelle`: Maintainability · `spec/lastenheft.md` LH-QA-04 (Messmethode)
- `pfad`: `harness/tools/start-smoke.sh:28`
- `befund`: Ein Binary, das auf `--help` hängt, hält die Kommando-Substitution
  unbegrenzt; der Job läuft in das GitHub-Default-Timeout statt in eine benannte
  Aussage, auf bis zu sechs Runnern parallel. Im Ergebnis fail-closed, in der Zeit
  nicht. (Ein portables Zeitlimit ist nicht trivial — `timeout` ist auf den
  macOS-Runnern nicht selbstverständlich vorhanden.)
- `verifizierbar`: ja — Sonde mit einem `sleep`-Fake.

### F-8 — DoD-Punkt sagt weiterhin „ruft **nur** `make`-Targets"

- `kategorie`: INFO
- `quelle`: Slice-Plan §2 DoD
- `pfad`: `docs/plan/planning/in-progress/slice-048-release-artefakte.md:42-44`
- `befund`: Der noch offene DoD-Punkt „Release-Workflow: … ruft **nur**
  `make`-Targets (MR-014 Setzung 1 — keine zweite Build-Definition im Workflow)"
  wurde bei der Auflösung von F-5 (Runde 1) nicht nachgezogen; der Workflow ruft
  jetzt zusätzlich ein Skript. Der Punkt ist bei Closure explizit zu reformulieren,
  nicht still umzudeuten.
- `verifizierbar`: ja — Textvergleich DoD gegen `release.yml`.

### F-9 — Anker von Fall 83 ist heute eindeutig, aber breit formuliert

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.6 · Steering-Lehre slice-047 (breite `sed`-Mutation wird unspezifisch)
- `pfad`: `test/mutations/83-release-startsmoke-marker.sh:13`
- `befund`: `/grep -qF/` trifft im heutigen Stand genau eine Zeile (gemessen). Ein
  zweiter **funktionaler** `grep -qF` im Skript würde mitmutiert; der Fall röte dann
  weiterhin seinen Wächter, seine Aussage umfasste aber zwei Eigenschaften unter
  einem `expect:`. Heute kein Befund — die Klasse, die den Vorgänger-Slice viermal
  getroffen hat, ist hier nur latent.
- `verifizierbar`: ja — `awk '/grep -qF/' harness/tools/start-smoke.sh` zählt die Treffer.

### F-10 — Außerhalb des Auftrags: der `publish`-Block ist Logik in der YAML

- `kategorie`: INFO
- `quelle`: MR-014 Setzung 1 (dieselbe „eine Quelle"-Achse)
- `pfad`: `.github/workflows/release.yml:129-151`
- `befund`: Der `publish`-Step trägt rund zwanzig Zeilen Inline-`bash` mit echter
  Fallunterscheidung (Prerelease-Erkennung, `view`/`create`/`upload`); sie ist von
  `shellcheck` nicht gedeckt und lebt nur in der YAML — dieselbe Achse, die der
  Nachtrag für den Start-Smoke gerade geregelt hat. Auftragsgemäß nicht weiter
  geprüft.
- `verifizierbar`: ja — `shell-lint`-Rezept deckt `.github/workflows/` nicht ab.

## Negativbefunde

<!--
Eine Zeile pro betrachtetem Bereich. Ohne diesen Block ist "keine
Findings" nicht von "nicht geprüft" unterscheidbar (Modul 10
§Reviewer berichtet auch, was er nicht gefunden hat).
-->

- geprüft, ohne Befund: **fail-closed bei Exit != 0** — die Zuweisung
  `out="$("$bin" --help)"` propagiert den Exit-Code unter `set -e` (Sonde: rc=3, keine
  Folgezeile). Der Kommentar `start-smoke.sh:26-27` sagt genau das zu und hält es.
- geprüft, ohne Befund: **fail-closed bei stderr-only und bei leerer Ausgabe** — in
  beiden Fällen bleibt `$out` leer, beide Marker fehlen, Exit 1.
- geprüft, ohne Befund: **Marker-Kollision mit dem Dateinamen** — die Usage stammt aus
  einem eigenen Const (`cmd/ai-harness-init/main.go:34`), nicht aus `flag.Usage`;
  `argv[0]` und der übergebene Pfad landen nie in `$out`, der Grep kann über diesen
  Weg nicht falsch grün werden. (Der andere Weg zu einem falschen Grün ist F-3.)
- geprüft, ohne Befund: **`chmod +x … || true` maskiert keinen Fehlerfall** — mit stets
  scheiterndem `chmod` und nicht ausführbarem Ziel endet der Lauf mit rc=126 aus
  `set -e`. Das `|| true` deckt nur den Windows-Fall, in dem das Bit bedeutungslos ist.
- geprüft, ohne Befund: **Fall 83 bricht Verhalten, nicht Kompilat** — die mutierte
  Kopie meldet ein Binary ohne Usage als `OK` (rc 0 statt 1), während der positive
  Wächter unverändert grün bleibt; rot wird also genau der im `expect:` benannte
  Wächter. Bedingung 4 in `harness/tools/mutate.sh:344` verlangt diesen Namen in der
  Fehlschlag-Ausgabe, und `# files:` benennt die mutierte Datei korrekt.
- geprüft, ohne Befund: **das bats-Paar misst die Eigenschaft, nicht nur seine Fixture** —
  positive und negative Richtung zusammen fixieren den Marker-Zweig (ein Sensor, der
  jedes Exit-0-Binary durchließe, röte den negativen Test; ein Sensor, der nie grün
  würde, röte den positiven). Einschränkungen: F-4 und F-5.
- geprüft, ohne Befund: **„von `shell-lint` gedeckt"** — das `shell-lint`-Rezept lintet
  `harness/tools/*.sh`; die Begründung im MR-Block trifft für diesen Teil zu.
- geprüft, ohne Befund: **Setzung 3/4 unberührt** — der Nachtrag senkt kein Gate und
  ändert keine Pin-Regel; MR-001 („Gate-*Anheben* → Steering-Loop, kein ADR") und
  `AGENTS.md` §3.5 sind nicht einschlägig, weil hier weder Schwelle noch Strenge
  gesenkt wird, sondern der Geltungsbereich einer Formvorschrift benannt wird.
- nicht geprüft (auftragsgemäß): Matrix-Target im `Makefile`, `Dockerfile`,
  `publish`-Job über F-10 hinaus, die vier älteren Wächter in
  `test/release-matrix.bats` und die Fälle 78–82.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 3 |
| LOW | 4 |
| INFO | 3 |

## Verdikt

**Bezogen auf die zwei geprüften Flächen: NICHT KONFORM.**

Die Kernfrage des Auftrags — reicht die Ausnahme weiter als ihr gemessener Grund? —
ist **in beide Richtungen mit ja zu beantworten**, und die beiden Richtungen sind
verschieden:

- **Zu eng gegenüber dem Ist:** die Schranke schließt die Linux-Runner aus, auf denen
  der Step tatsächlich läuft (F-1). Der Nachtrag beschreibt damit einen Workflow, den
  es nicht gibt.
- **Zu weit gegenüber dem Zweck:** die Schranke bindet an den Runner statt an die
  Eigenschaft, die Setzung 1 schützt (F-2). „Kein `make` auf dem Runner" ist der
  **Anlass** der Ausnahme, „die Definition lebt versioniert im Repo, die YAML ruft nur"
  ist ihre **Bedingung**; nur letztere gehört in den Normsatz.

Die Begründung „der Zweck bleibt gewahrt: die Prüfung lebt versioniert im Repo,
`shell-lint` deckt sie" ist **keine bequeme Umdeutung** — sie ist inhaltlich tragfähig
und für das Skript nachgemessen (Negativbefunde). Tragfähig ist sie aber genau, weil
der Check **einmal** existiert und auf allen sechs Runnern **identisch** läuft; eine
Aufteilung in `make` auf Linux und Skript auf macOS/Windows erzeugte die zwei
Definitionen, die Setzung 1 verbietet. Der geschriebene Norm-Satz sagt das Gegenteil.
Der Defekt ist also der **Wortlaut**, nicht die getroffene technische Entscheidung.

Die Messung selbst (F-6) ist datiert und benennt Image-Namen, deckt aber nur zwei der
vier `make`-losen Labels ab und zeigt nicht auf ihre Quelle — für die einzige
Tatsachenbehauptung, die eine Regel-Ausnahme trägt, zu wenig Anker.

**Merge-blockierend:** ja — drei MEDIUM. F-1 und F-2 betreffen den normativen Text
in `harness/conventions.md` und sind ohne Code-Änderung auflösbar; F-3 ist eine
Ein-Zeilen-Härtung im Sensor plus Wächter. Die LOW-Befunde F-4/F-5 gehören in
denselben Zug, weil sie dieselbe Datei betreffen und §3.6 je einen roten Fall
verlangt; F-6/F-7 sind vertagbar, wenn sie benannt werden.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
