# Slice slice-126: Eine Commit-Message ohne Kennung wird rot — vor dem Commit, und damit steht der Träger, den auch slice-121 braucht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — Achse (3) des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. **Hängt an
[slice-123](../done/slice-123-ci-sieht-die-historie.md)**, sobald der Sensor eine Commit-Spanne liest.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Commit-Messages **dieses** Repos. Im
Emissions-Baum kommt der Gegenstand nicht vor
(`git grep -lni 'commit-msg\|COMMIT_EDITMSG' -- internal/emit/templates/ | wc -l` → **0**, gemessen
für [slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) und hier übernommen).

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §5 (*„Requirement- und ADR-IDs in PRs/Commits referenzieren"* —
die Zusage, die hier ihren Sensor bekommt),
[`harness/README.md`](../../../../harness/README.md) §Traceability (dieselbe Zusage, zweiter Ort),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate
über einem Bestand, den niemand mehr ändern kann, senkt seine eigene Aussage — daraus folgt der
Cutoff in DoD (2)),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel nennt die **Commit-Message** ausdrücklich als
Zusage-Träger),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Hook- und Nachweis-Mechanik dieses Repos — sie entscheidet, wo ein Vor-Commit-Sensor hängt),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
(`doc-commits` ist eines der elf advisory-Ziele; wird es behauptet, zieht Setzung 2 mit).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Eine Commit-Message ohne Traceability-Kennung färbt rot, bevor der Commit steht — und der Ort,
an dem das geschieht, ist danach ein benannter, wiederverwendbarer Träger.**

### Der Anlass: eine Zusage an zwei Orten, ohne einen Sensor

[`AGENTS.md`](../../../../AGENTS.md) §5 und
[`harness/README.md`](../../../../harness/README.md) §Traceability sagen zu, dass PRs und Commits
mindestens eine `LH-*`/`ADR-*`-Kennung nennen. Gelesen wird eine Commit-Message von nichts:
`git grep -lnE 'git (log|show|cat-file).*(%B|--format=.%s)|commit-msg|COMMIT_EDITMSG' -- Makefile d-check.mk .d-check.yml harness/tools/ .claude/hooks/ .codex/ .github/ test/`
→ kein Treffer (Exit 1).

### Das Modul, und was es wirklich prüft — gemessen, nicht aus dem Namen geschlossen

Gegen eine Kopie außerhalb des Repos (Stand `1f5741f`, netzlos, `:ro`, Image `v0.65.0` per Digest),
Flags aus [`d-check.mk`](../../../../d-check.mk):

| Lauf | Ergebnis |
|---|---|
| `doc-commits`-Flags, `--range HEAD~20..HEAD`, **ohne** `commits:`-Block (heutiger Stand) | `425 Datei(en) geprüft, 0 Befund(e)`, **Exit 0** |
| dieselben Flags, **mit** `commits:`-Block (`id-patterns` für `ADR-`/`LH-`/`MR-`/`slice-`) | **2 Befunde** `commit-untraceable`, Exit 1 |
| `--commit-msg <datei>` auf eine Message **ohne** jede Kennung | **1 Befund** `commit-untraceable` auf einem Pseudo-Commit `pending`, Exit 1 |

**Drei Dinge folgen daraus.**

1. **`doc-commits` ist heute ein stilles Grün** — ohne `commits:`-Block ist das Modul inert und
   meldet trotzdem Exit 0. Dieselbe Klasse wie bei `targets` und `planning`.
2. **Der Träger existiert schon, und er ist kein Nachbau.** `--commit-msg <datei|->` nimmt eine
   Message-Datei entgegen, **bevor** ein Commit existiert, und meldet gegen einen Pseudo-Commit
   `pending`. Dieses Repo committet über `git commit -F <datei>`; die Datei ist also da, wenn der
   Sensor sie braucht.
3. **Das Modul prüft die Anwesenheit einer Kennung, nicht die Wahrheit einer Aussage.** Eine
   Message, die den nicht auflösbaren Hash `0f8d1a1` **und** eine gültige Kennung trägt, geht mit
   **Exit 0** durch — gemessen mit derselben `--commit-msg`-Form.

### Warum das [slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) nicht ersetzt, aber trägt

Die zwei Slices prüfen **verschiedene Eigenschaften** derselben Zeichenkette:
`commits` fragt *„steht hier eine Kennung?"*,
[slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) fragt *„bezeichnet dieses Hex-Token ein
Objekt dieses Repos?"*. Messung 3 ist der Beleg, dass die eine die andere nicht abdeckt: der tote
Hash passiert `commits` ungehindert.

**Gemeinsam ist ihnen der Träger**, und der ist die teure Hälfte.
[slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) §6 hält fest, ein Vor-Commit-Sensor habe
*„in diesem Repo keinen Präzedenzfall"*, und §3 führt den Ort als **offen**. Nach diesem Slice ist
er es nicht mehr. Daraus folgt die Arbeitsteilung: **dieser Slice entscheidet und baut den Ort**,
[slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) hängt seine Eigenschaft dort an, statt
einen zweiten Ort zu erfinden. Zusammenlegen wäre falsch — sechs slice-eigene DoD-Punkte, und Modul 5
§Ziel-Form nennt das nicht *„eine längere DoD"*, sondern *„der Schnitt ist falsch"*.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [x] **(1) Eine Message-Datei ohne Kennung wird rot, bevor der Commit steht.** Der Sensor läuft an
      einem benannten Ort und nennt in der Meldung, **welche** Eigenschaft er prüft.
      **Rot:** eine Message-Datei ohne `ADR-`/`LH-`/`MR-`/`slice-`-Kennung → Exit ≠ 0 mit
      `commit-untraceable`; dieselbe Datei mit Kennung → Exit 0. Beide Läufe gehören in den
      Umsetzungs-Commit.
      **Erfüllt.** Der Ort ist zweistufig und beide Stufen sind benannt: das Ziel
      `make commit-msg-check MSG=<datei>` (`grep -n '^commit-msg-check:' Makefile`) und der
      PreToolUse-Zusatz
      [`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../../../.claude/hooks/pretooluse-commit-msg-guard.sh),
      zweiter Eintrag im `"Bash"`-Matcher der
      [`.claude/settings.json`](../../../../.claude/settings.json). **Rot gesehen** an einer echten
      Message-Datei ohne jede Kennung (`commit-untraceable`, Exit ≠ 0) und grün an derselben Datei
      mit `slice-1` ergänzt (Exit 0); beide Läufe stehen im Umsetzungs-Commit `10ba393a` und sind
      in der Verifikation (`docs/reviews/2026-09-11-…-verify.md` §DoD) unabhängig nachgefahren.
      **Die Meldung nennt die Eigenschaft, nicht den Gegenstand:** Der Block-Text des Hooks führt
      beide Ursachen, die zu einem Nicht-Null-Exit führen können — fehlende Kennung **oder**
      gescheiterte Prüf-Instanz — und hängt die Diagnose-Zeile an
      (`grep -n 'ABGELEHNT' .claude/hooks/pretooluse-commit-msg-guard.sh`); der Hilfetext des Ziels
      sagt *„gegen Traceability-Kennung"*, nicht *„Commit-Message geprüft"*.
- [x] **(2) Der Prüfbereich ist entschieden und trägt seinen Cutoff.** Zu entscheiden sind die
      `id-patterns` (welche Kennungen dieses Repo als Traceability zählt), die `exempt-pattern`
      (Merge/Revert) und **ob neben dem Vor-Commit-Lauf eine Range in CI läuft — und ab welchem
      Commit**.
      **Rot:** ein Maßstab über der ganzen Historie. Er wäre an einem Bestand rot, den niemand mehr
      ändern kann, und fiele damit unter
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) —
      dieselbe Cutoff-Begründung wie in
      [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).
      Mechanisch rot: der gewählte Range-Lauf meldet über dem Bestand **vor** dem Cutoff einen
      Befund.
      **Erfüllt, und die dritte Frage ist gegen die Range entschieden statt offengelassen.** Die
      `id-patterns` stehen im `commits:`-Block der [`.d-check.yml`](../../../../.d-check.yml)
      (`ADR-\d{4}`, `LH-[A-Z]{2}-\d{2}`, `MR-\d{3}`, `slice-\d+`), daneben
      `exempt-pattern: '^(Merge |Revert )'`. **Kein Range-Lauf in CI**, und der Grund ist gemessen,
      nicht vorsichtig: Am gepinnten Stand bricht **jeder** `--range`-Lauf des Moduls `commits` mit
      `Range-Basis-Vorfahren nicht lesbar` ab, sobald `commits.id-patterns` irgendeine nicht-leere
      Liste trägt — auch die drei eingebauten Muster verbatim —, und mit leerer oder fehlender
      Liste prüft er gar nichts mehr (`0 Befund(e)`, Exit 0). Beide Läufe stehen mit ihren Sonden
      in [`harness/README.md`](../../../../harness/README.md); die Verifikation hat den
      Abbruch-Zweig unabhängig reproduziert. **`commits` steht darum nicht in `modules:`**
      (`grep -n '^modules:' .d-check.yml`) — kein stilles Grün im hermetischen `docs-check`, und
      `doc-commits` wird als *unbedienbar* geführt statt als aktiv behauptet
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
      **Der Cutoff ist damit strukturell und braucht kein Datum:** Der Hook prüft den **werdenden**
      Commit, nie die Historie; er beginnt mit seinem ersten Aufruf. Dass ein rückwirkender Maßstab
      die falsche Wahl gewesen wäre, steht neben seinem Kommando im selben Absatz des
      [`harness/README.md`](../../../../harness/README.md).
- [x] **(3) Der Träger ist als Träger dokumentiert, nicht nur als Ziel.** In
      [`harness/README.md`](../../../../harness/README.md) steht, wo ein Message-Check hängt, was er
      bekommt (Datei gegen Range) und was er **nicht** prüft — ausdrücklich: **nicht** die Wahrheit
      der Aussagen, nur die Anwesenheit einer Kennung.
      **Rot:** `make mutate` meldet **BEFUND** auf den `test/mutations/`-Fall, der die
      Kennungs-Prüfung entfernt — der Zahn muss die Stelle treffen, die der Aufrufer benutzt, sonst
      misst er sich selbst.
      **Erfüllt.** [`harness/README.md`](../../../../harness/README.md) §Sensors führt den Träger
      mit Ort (der PreToolUse-Zusatz-Hook, `make commit-msg-check MSG=<datei>`), Umfang (eine
      Message-**Datei** über `--commit-msg`, nicht die Historie) und Grenze: geprüft wird **nur die
      Anwesenheit** einer Kennung, **nicht ihre Wahrheit** — eine Message mit einem nicht
      auflösbaren Hash und einer gültigen Kennung geht durch. Dazu drei benannte blinde Flecken:
      der in Anführungszeichen gesetzte Variablen-Pfad (dauerhaft unerreichbar, kein Rateversuch),
      `git commit -m` (*nicht garantiert*, Fundmenge im Bestand null) und die Commits, die
      **innerhalb** eines Repo-Werkzeugs entstehen. **Der Zahn sitzt an der realen Stelle:**
      `test/mutations/307-commit-msg-guard-block-bedingung-invertiert.sh` und
      `308-commit-msg-guard-match-nur-schmales-f.sh` mutieren
      `.claude/hooks/pretooluse-commit-msg-guard.sh` selbst (`# files:`-Zeile beider Fälle), nicht
      eine Test-Kopie; `test/commit-msg-guard.bats` deckt Match-Extraktion, Existenz-Vorprüfung und
      beide Verdikte hermetisch (`grep -c '^@test' test/commit-msg-guard.bats` → **18**). Der
      abschließende Lauf: `mutate: 294 ok, 0 Befund(e)` und
      `mutate: Vollstaendigkeit — 294 von 294 Fall-Dateien mit Ergebnis, jede Fall-ID genau einmal
      gezogen.`; beide neuen Fälle mit Status `ok`, keine `BEFUND`-Zeile zu 307 oder 308 — das vom
      Verifier vorab geschriebene Abnahme-Kriterium in allen vier Teilen.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | der `commits:`-Block (`id-patterns`, `exempt-pattern`). **`commits` gehört NICHT in `modules:`** — es braucht eine Range bzw. eine Message-Datei und liefe im hermetischen `docs-check` ins Leere |
| [`Makefile`](../../../../Makefile) | update | das Ziel, das den Vor-Commit-Lauf fährt (`--commit-msg`), und ggf. das Range-Ziel für CI. Ein neues behauptetes Ziel zieht [`AGENTS.md`](../../../../AGENTS.md) §4 mit |
| [`.claude/hooks/`](../../../../.claude/hooks) | offen | falls der Ort ein Hook-Griff auf `git commit -F` ist; dann berührt der Slice [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) und die vom Guard selbst benannte Grenze |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | update | nur falls DoD (2) eine Range in CI entscheidet — dann ist [slice-123](../done/slice-123-ci-sieht-die-historie.md) **Voraussetzung**, sonst ist der Lauf dort blind und grün |
| `test/` | neu | der bats-Fall, den DoD (3) mit einem `test/mutations/`-Fall belegt |
| [`harness/README.md`](../../../../harness/README.md) | update | der Träger und seine Grenze (DoD (3)) |
| [`slice-121`](../open/slice-121-commit-message-nennt-was-es-gibt.md) | **nicht durch diesen Slice** | dessen §3/§4/§6 sind mit der Träger-Messung nachgezogen; die **Eigenschaft** bleibt seine |
| [`AGENTS.md`](../../../../AGENTS.md) §3, [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8); §4 darf der Slice anfassen, §3 nicht |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet, das WIP-Limit ist frei — und
[slice-123](../done/slice-123-ci-sieht-die-historie.md) liegt in `done/`, falls DoD (2) eine Range in CI
entscheidet.** Der Vor-Commit-Zweig allein braucht keine Historie und könnte früher laufen; weil die
Entscheidung aber **Teil** der DoD ist und nicht vor ihr steht, wartet der Slice.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: DoD (2) endet mit **zwei** Läufen (Vor-Commit **und** Range), die je
  eigene Zähne, eigene Doku und eigene Ausnahmen brauchen. Dann sind es zwei Slices, kein vierter
  DoD-Punkt.
- `in-progress` → `open`: der einzige tragfähige Ort erweist sich als agenten-gebunden — ein
  Hook, den nur **ein** Klient fährt ([`.codex/hooks.json`](../../../../.codex/hooks.json) führt
  allein den SessionStart-Injektor). Dann ist der Sensor ein Stolperdraht für einen Klienten und
  keine Repo-Zusage; die Lage gehört als Carveout nach Modul 7 aufgeschrieben. **Dieselbe
  Rückführung steht in [slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) §4** — sie
  betrifft den Träger, und der ist geteilt.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` ohne Befund,
Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7
mit Steering-Loop-Eintrag **und** der ausdrücklichen Feststellung, ob
[slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) den Träger nun übernehmen kann.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau **einen** Ausgang,
und kein Slice geht nach `done/`, während eines ohne Ausgang dasteht.

- **Der Name des Moduls verspricht mehr, als es hält.** `doc-commits` heißt in
  [`d-check.mk`](../../../../d-check.mk) *„Commit-Message-Traceability"*; geprüft wird die
  **Anwesenheit** eines Kennungs-Musters. Ein Ziel, das *„Commit-Message geprüft"* ausgibt,
  behauptet mehr als es misst — dieselbe Falle, die
  [slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) §6 für seinen eigenen Sensor benennt.
  Die Meldung muss die Eigenschaft nennen, nicht den Gegenstand.
  — **Ausgang: entfallen.** Das gelieferte Ziel heißt *„Commit-Message-Datei gegen
  Traceability-Kennung pruefen"*, der Block-Text des Hooks führt beide Ursachen eines Nicht-Null-Exits,
  und [`harness/README.md`](../../../../harness/README.md) setzt *Anwesenheit* ausdrücklich gegen
  *Wahrheit*. Das Risiko hat keinen Gegenstand mehr, weil kein Artefakt dieses Slice den Gegenstand
  statt der Eigenschaft nennt. **Benannter Rest, der nicht dazugehört:** Die Hilfetext-Zeile von
  `doc-commits` in [`d-check.mk`](../../../../d-check.mk) trägt weiter den weiteren Namen — die
  Datei ist tool-generiert
  ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)), und
  die Korrektur steht im Prosa-Absatz daneben, der das Ziel als *unbedienbar* führt.
- **Ein Vor-Commit-Sensor kann umgangen werden, und das ist keine Ausrede, sondern eine Grenze.**
  Wer ohne den Hook committet, wird nicht gesehen. Was der Sensor deckt, hängt am Klienten; was er
  nicht deckt, gehört in dieselbe Zeile wie das, was er deckt.
  — **Ausgang: eingetreten →
  [slice-215](../open/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md).** Es ist
  nicht bei der Möglichkeit geblieben: Der Hook sieht nur, was als Bash-Kommando wörtlich
  `git commit …` enthält, und ein Commit aus einem Repo-Werkzeug heraus erreicht ihn strukturell nie
  (`git log --format='%s' | grep -c '^slice-mv:'` gegen `git log --format='%s' | wc -l`, beide keine
  Erwartungswerte). Die Grenze **steht** in derselben Zeile wie die Deckung — das war die Auflage
  dieses Risikos und ist eingelöst; was der Slice nicht entschieden hat, ist der **Träger-Tausch**,
  und der hat mit dem Folge-Slice jetzt eine Adresse.
- **Zwei Läufe über denselben Gegenstand driften.** Läuft der Check vor dem Commit **und** über
  eine Range in CI, müssen beide dieselbe Config lesen — sonst ist grün vor dem Commit und rot in
  CI möglich, und die Ursache liegt in der Konfiguration statt im Befund.
  — **Ausgang: entfallen.** Es gibt keinen zweiten Lauf: DoD (2) hat den Range-Lauf **entschieden
  ausgeschlossen**, gemessen und nicht aus Vorsicht — am gepinnten Stand bricht er unter jeder
  nicht-leeren `id-patterns`-Liste ab und prüft ohne sie nichts. Ein Gegenstand, den nur ein Lauf
  liest, kann nicht zwischen zwei Läufen driften. Die Bedingung kehrt zurück, sobald ein zweiter
  Lauf entsteht; sie steht als Risiko im Plan von
  [slice-215](../open/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md), statt hier
  als erledigt zu verschwinden.
- **Der Cutoff ist der Punkt, an dem dieser Slice sich selbst entwerten kann.** Die zwei
  `commit-untraceable`-Befunde aus §1 stammen aus `HEAD~20..HEAD` — also aus dem **jüngsten**
  Bestand, nicht aus grauer Vorzeit. Ein Cutoff, der sie ausschließt, schließt genau die Fälle aus,
  für die der Sensor gebaut wird; einer, der sie einschließt, macht den Gate ab Tag eins rot. Diese
  Spannung ist echt und gehört in DoD (2) entschieden, nicht hier weggewunken.
  — **Ausgang: entfallen.** Die Spannung setzte einen **Maßstab über einem Bestand** voraus; der
  gelieferte Träger hat keinen. Er urteilt über den **werdenden** Commit, und seine erste Gelegenheit
  ist sein erster Aufruf — ein Cutoff-Datum in der Konfiguration gibt es nicht und kann es nicht
  geben. Die zwei Befunde aus `HEAD~20..HEAD` bleiben ungeprüft, und das ist die Folge derselben
  Entscheidung, nicht eine zweite: Wer die Historie prüfen will, braucht den Range-Lauf, der am
  gepinnten Stand nicht läuft.

## 7. Closure-Notiz (nach `done/`)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register
(vorhandene Kennungen **zitieren** statt neu formulieren) · `grundlagen-traceability.md`
§Herkunfts-Anker (das Feld `liegt in` steht **nur**, wenn wirklich etwas verkörpert wurde).

- **Was hat funktioniert: den Träger gemessen, statt ihn zu bauen.** Der Plan hielt einen
  Vor-Commit-Sensor für einen Eigenbau ohne Präzedenzfall; die Messung fand ihn fertig im gepinnten
  Werkzeug — `--commit-msg <datei>` nimmt eine Message entgegen, **bevor** ein Commit existiert, und
  urteilt gegen einen Pseudo-Commit. Weil dieses Repo ohnehin über `git commit -F <datei>` committet,
  war die Datei zum Prüfzeitpunkt schon da, und der ganze Slice reduzierte sich auf Config-Block,
  ein `make`-Ziel und einen Hook-Griff. Das Gegenstück dazu ist die zweite Messung, die den Slice
  **verkleinert** hat: Der Range-Lauf, den der Plan noch als offene Entscheidung führte, ist am
  gepinnten Stand gar nicht verfügbar — er bricht unter jeder nicht-leeren `id-patterns`-Liste ab
  und prüft ohne sie nichts. Aus einer Entscheidung wurde damit ein Befund, und der steht als
  Werkzeug-Anforderung an ein Nachbar-Repo, nicht als Vorsicht in diesem.
- **Was ging anders als geplant: alle blockierenden Befunde lagen in der Prosa, nicht im Wächter.**
  Zwei Review-Runden fanden zwei HIGH, sechs MEDIUM, zwei LOW und zwei INFO — kein einziger betraf
  die Frage, ob der Hook das Richtige tut. Getroffen haben sie den Kopf des Hooks (eine
  Geltungs-Zusage, die fünf Aufrufformen weiter war als der Matcher darunter), den Kommentar des
  bats-Falls (ein Selbstgespräch statt einer Kommentar-Klasse), die vier Zahlen des neuen
  README-Absatzes und — zweimal hintereinander, in demselben Satz — die Diagnose des
  Werkzeug-Defekts: Runde 1 fand die Ursache falsch benannt, Runde 2 die **Nebenklausel** derselben
  korrigierten Sätze falsch, nämlich einen Rückfallweg, der gemessen ein stilles Grün ist. Die
  Lehre ist dieselbe Asymmetrie, die schon die Vorgänger-Closure notiert hat, eine Stufe schärfer:
  Die Konfiguration war an einem Tag gemessen, ihre Begründung brauchte drei Runden — und die
  Begründung ist das, was der nächste Lauf liest.
- **Und eine dritte Bewegung lief neben dem Slice, außerhalb seiner Rollen-Grenze.** Aus diesem
  Slice ging eine Hard Rule `AGENTS.md` §3.12 hervor, die eine Träger-Wahl vor den Übergang
  `next` → `in-progress` band. Der Auftraggeber hat sie am selben Baum ersatzlos zurücknehmen
  lassen: Ein Falsch/Richtig-Paar widersprach seiner Entscheidung über den Umsetzungsplan, und der
  Absatz *Was sie nicht erweitert* stützte sich auf einen Baseline-Satz, der unter der Überschrift
  *Keine Mindestzahl, und kein Sensor darauf* gegen eine Mindestzahl argumentiert, nicht gegen die
  Existenz eines Abschnitts. Für diese Closure ist daran zweierlei tragend: Der Slice hat **keine**
  Norm geerbt, auf die er sich berufen könnte, und die Klasse ist gezählt statt erzählt — als
  Beleg in
  [`zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md).
- **Steering-Loop-Eintrag — neuer Sensor.** Die Traceability-Zusage aus
  [`AGENTS.md`](../../../../AGENTS.md) §5 und
  [`harness/README.md`](../../../../harness/README.md) §Traceability verlässt den
  Feedforward-Quadranten: `make commit-msg-check MSG=<datei>` prüft eine Message-Datei gegen den
  `commits:`-Block der [`.d-check.yml`](../../../../.d-check.yml), und der PreToolUse-Zusatz-Hook
  [`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../../../.claude/hooks/pretooluse-commit-msg-guard.sh)
  ruft ihn **vor** der Ausführung und blockt bei Exit ≠ 0. Was er deckt und was nicht, steht in
  derselben Sektion wie er selbst — **nicht** die Wahrheit einer Aussage, nur die Anwesenheit einer
  Kennung, und drei benannte blinde Flecken daneben. Der Eintrag trägt **kein** Feld
  `liegt in <Zielort>`: Ein Herkunfts-Anker `seit welle-13` wird gesetzt, wenn diese Welle schließt,
  nicht von einem ihrer Slices — die Anker-Paarung hat hier also keinen Gegenstand.
- **Beobachtungs-Register (`../observations/`):** **neun** Belege, alle unter demselben
  Vorgangs-Namen `slice-126` — zwei Review-Runden und eine Verifikation über *einem* Slice sind
  **eine** Gelegenheit, kein dreifaches Auftreten. **Acht** in bestehende Verzeichnisse ergänzt,
  **eines** neu angelegt. Zähler als Dateizahl abgelesen
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
  Erwartungswerte**):
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  **22×** ·
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  **12×** ·
  [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  **12×** ·
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  **12×** ·
  [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  **6×** ·
  [`zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md)
  **5×** ·
  [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  **5×** ·
  [`korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`](../observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/observation.md)
  **4×** · neu angelegt, **1×**:
  [`waechter-abdeckung-haengt-an-uninstruierter-konvention`](../observations/BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md).

  **Ein zehnter Eintrag ist berührt, ohne einen Beleg zu bekommen.** In
  [`commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md)
  ist die Aussage *„ein Wächter besteht nicht"* mit diesem Slice falsch geworden; seine `state.md`
  nennt jetzt den Wächter und die Teilmenge, die er deckt. Der **Zähler bewegt sich davon nicht** —
  ein Beleg zählt das *Auftreten* der Beobachtung, und in diesem Vorgang ist keine
  kennungslose Commit-Message aufgetreten.

  **Der Beleg zählt das Auftreten, nicht den Rest im Baum.** Die Mehrzahl dieser Klassen ist
  innerhalb des Vorgangs behoben worden; gezählt werden sie trotzdem, weil der Zähler Wiederholung
  über Vorgänge hinweg misst und eine Klasse, die nur zählt, wenn sie liegen bleibt, die
  Gründlichkeit des Reviews misst statt der Häufigkeit des Musters.
- **Der Lese-Schritt gehört nicht hierher, und das ist eine Messung, keine Bequemlichkeit.** Dieses
  Repo führt Wellen-Betrieb — `ls docs/plan/planning/welle-*.md` führt drei offene Wellen —, und
  das Kopf-Feld dieses Plans nennt [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md). Damit
  liegt der Lese-Schritt bei der **Welle-Closure** (Baseline-Regelwerk
  `modul-05-planning-harness.md` §Lifecycle als State Machine: *„vom Lese-Schritt (Welle-Closure; in
  einem Repo ohne Wellen-Betrieb löst ihn die Slice-Closure selbst aus)"*), und *wellenlos* ist dort
  ausdrücklich eine Eigenschaft des **Repos**, nicht des einzelnen Slice. Diese Closure **zählt**,
  sie **entscheidet nicht**. Mit ihr wird der Trigger der Welle beobachtbar: `slice-126` war ihr
  letzter offener Slice. Als Übergabe steht der Rückstand hier gemessen — **elf** Einträge bei ≥ 3×
  und weiterhin `offen`, der höchste bei **12×**:

  ```sh
  for d in docs/plan/planning/observations/BEO-ALL/*/; do
    n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l)
    s=$(grep -m1 '^\*\*Stand:\*\*' "$d"state.md | sed 's/\*\*Stand:\*\* //')
    [ "$n" -ge 3 ] && [ "$s" = "offen" ] && printf '%3s  %s\n' "$n" "$(basename "$d")"
  done | sort -rn
  ```
- **Trigger-Audit: ein Treffer, und er gehört ebenfalls der Welle-Closure.** Von den zwei aktiven
  Carveouts berührt dieser Slice
  [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md): Er legt mit `test/commit-msg-guard.bats`
  eine `.bats`-Datei an, die **eigene Hilfsfunktionen mit Verzweigung** trägt
  (`hook()` mit `if`/`else`) — wörtlich der Auflösungs-Trigger jenes Carveouts, der bereits als
  *eingetreten* geführt wird und dessen Ausgang bei
  [slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md) liegt. Der Bestand
  wächst damit um einen weiteren Fall statt zu schrumpfen. Die Zeile *Letzte Prüfung* bleibt
  ungeschrieben: Sie wird in diesem Repo vom Welle-Trigger-Audit geführt, und zwei Schreiber
  desselben Feldes wären zwei Chroniken derselben Sache.
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) ist unberührt (Token-Achse je Rolle).
  **Bootstrap-aware Gates:** keine — der Ausschluss von `commits` aus `modules:` ist eine
  Prüfbereichs-Entscheidung mit Begründung, keine Reifestufe mit Hochschalt-Trigger.
  **ADR-Re-Evaluierungs-Trigger:** keiner gefeuert.
  [`ADR-0004`](../../adr/0004-durchsetzungs-emission.md) fragt nach einem Ziel-Skelett, das
  `node`/`jq` mitbringt — unverändert nein;
  [`ADR-0019`](../../adr/0019-agent-guard-prueft-die-aufrufform.md) hängt an drei Annahmen über die
  Vordergrund-Form und die Zähler, von denen dieser Slice keine berührt, und seine Feststellung, die
  Konfiguration führe `PreToolUse` **zweimal**, hält weiter: Der neue Hook ist ein zweiter Eintrag
  im bestehenden `"Bash"`-Matcher, kein dritter Matcher-Block.
- **Folge-Slices: einer.**
  [slice-215](../open/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) — *Der
  Commit-Message-Wächter bekommt den Träger, der auch die Commits sieht, die kein Agent tippt*,
  angelegt als Datei in [`open/`](../open). Er fängt **zwei** Übergaben dieses Slice auf, die
  dieselbe Ursache haben: die strukturell unerreichbaren Werkzeug-Commits (Risiko 2) und die
  Abhängigkeit von einer Konvention, die vier von sechs `.claude/agents/*.md` und
  [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) nicht führen
  (Review-MEDIUM-4). Die **andere** Behebung jener zweiten Lücke — die Konvention in jene Dateien
  schreiben — ist kein liegengebliebener Punkt dieses Slice, sondern Eigentum der jeweils
  ausführenden Rolle
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md); für
  `.claude/agents/*.md` ist das Eigentum selbst noch offen,
  [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) und `slice-152`).
  Sie ist darum im Register benannt und in
  [slice-215](../open/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) §1
  ausdrücklich **ausgeschlossen**, statt dort mitgenommen zu werden.
  **Und [slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) kann den Träger jetzt
  übernehmen** — das ist die ausdrückliche Feststellung, die §5 verlangt: Dessen §3 führte den Ort
  als *offen* und §6 hielt fest, ein Vor-Commit-Sensor habe *„in diesem Repo keinen
  Präzedenzfall"*. Beides trifft nicht mehr zu; die Eigenschaft, die jener Slice prüft (bezeichnet
  dieses Hex-Token ein Objekt dieses Repos?), hängt sich an denselben Ort, statt einen zweiten zu
  erfinden. Sein Plan ist von dieser Closure **nicht** angefasst worden — er ist ein fremdes
  Plan-Artefakt, und die Feststellung gehört in diese Notiz, nicht in seine Datei.
- **Risiken aus §6:** vier Risiken, vier Ausgänge — **eines *eingetreten*** (der umgehbare
  Vor-Commit-Sensor → [slice-215](../open/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md))
  und **drei *entfallen* mit Begründung**; siehe §6. Dass drei entfallen, hat bei zweien dieselbe
  Ursache: Beide setzten einen **Range-Lauf** voraus, und DoD (2) hat ihn gemessen ausgeschlossen —
  ein Gegenstand, den nur ein Lauf liest, driftet nicht, und ein Träger ohne Bestand braucht kein
  Cutoff-Datum. Die Bedingungen kehren mit einem zweiten Lauf zurück und stehen darum im §6 des
  Folge-Slice, statt hier als erledigt zu verschwinden.
- **Vor dem `git mv` gemessen ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** **fünf** eingefrorene
  Artefakte nennen diese Datei als Pfad — drei Slice-Pläne unter `done/` und zwei Review-Reports —,
  außerhalb von Markdown **null**. `make slice-mv` nimmt keinen der beiden Bäume aus und schreibt
  sie im Nachzugs-Commit. Der Move ist trotzdem gefahren: Die Auflösung dieser Lage ist dem
  **Architect** zugewiesen, und bis dahin ist der bewegende Lauf der Träger — er hat hier gemessen
  und entschieden, statt es zu übersehen. Gezählt als zwölfter Beleg der Klasse.
- **Drei Paarungen:** **nicht dieser Closure geschuldet** — im Repo **mit** Wellen-Betrieb trägt sie
  die nächste Welle-Closure. Als Übergabe dennoch gefahren, mit Ergebnis: **(a) Anker** — der
  Steering-Loop-Eintrag trägt kein Feld `liegt in`, die Paarung hat keinen Gegenstand.
  **(b) Folge-Slice** — [slice-215](../open/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md)
  existiert als Datei im Planning-Lifecycle, in [`open/`](../open). **(c) Register** — jede hier
  zitierte Kennung löst als Verzeichnis auf; die zweite Hälfte *„jede Registerzeile trägt mindestens
  einen Beleg"* meldet unverändert **einen** Eintrag ohne `evidence/`,
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`. Das ist **kein** Rückstand und derselbe
  Fall, den die vorigen Closures benannt haben: Der Eintrag führt sein einziges Vorkommen unter
  *Benannt, nicht gezählt*, und ein Vorkommen ohne abgeschlossenen Vorgang bekommt nach
  Baseline-Regelwerk `modul-06-roadmap.md` ausdrücklich keinen Beleg.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Für einen
hermetischen Sensor mit `Makefile`-Ziel, bats-Fall und `test/mutations/`-Zahn ist
`make comment-claims` der Präzedenzfall; für den Hook-Ort ist es
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks).
