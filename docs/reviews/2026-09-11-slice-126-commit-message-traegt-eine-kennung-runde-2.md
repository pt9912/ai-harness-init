# Review — slice-126: Eine Commit-Message ohne Kennung wird rot, vor dem Commit (Runde 2)

- **Rolle:** Reviewer · **Datum:** 2026-09-11 · **Runde:** 2
- **Prüfgegenstand:** `2c766a7b..1e5b6ad2` — 5 Dateien, 85 hinzugefügte Zeilen
  (`git diff --stat 2c766a7b..1e5b6ad2`). **Nicht** der ganze Slice; Runde 1 deckt ihn.
- **Plan:** [`slice-126`](../plan/planning/done/slice-126-commit-message-traegt-eine-kennung.md)
- **Vorrunde:** [`2026-09-11-…-kennung.md`](2026-09-11-slice-126-commit-message-traegt-eine-kennung.md)
  — 1 HIGH · 5 MEDIUM · 1 LOW · 1 INFO, dazu zehn tragende Negativbefunde. Die zehn sind
  hier nicht erneut geprüft.
- **Baum bei Review-Beginn:** `git status --porcelain` leer, HEAD `1e5b6ad2`.
- **Kanonische Bezüge:**
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`AGENTS.md`](../../AGENTS.md) §3.6, §3.7, §3.9,
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md),
  [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 3,
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
- **Werkzeug-Einsatz, offengelegt:** **5** `docker run` gegen den in
  [`d-check.mk`](../../d-check.mk) gepinnten Digest `sha256:e31a372b…4641`, netzlos
  (`--network none`), Mount `:ro` — vier gegen einen Klon **außerhalb** des Repos, einer
  (`make commit-msg-check`) gegen den Arbeitsbaum. Kein `make gates`, kein `make mutate`,
  kein `make test`.

---

## Vorbemerkung: drei Befunde der Vorrunde, die im Bericht des Implementers fehlen

MEDIUM-2, MEDIUM-5 und LOW-1 erscheinen in seinem Bericht weder als erledigt noch als
zurückgestellt. Am Diff gemessen sind **alle drei behoben** (Belege in N-2, N-3, N-4).
Der Befund ist damit kein offener Mangel, sondern eine **Lücke in der Übergabe**: Der
nächste Kontext hätte sie ohne eigene Messung für offen halten müssen.

---

## Findings

### HIGH-1 — Der dokumentierte Ausweg aus dem Werkzeug-Defekt ist ein stilles Grün, nicht ein engerer Prüfbereich

- **kategorie:** HIGH
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 3
- **pfad:** [`harness/README.md`](../../harness/README.md):441
- **befund:** Der korrigierte Satz sagt, der Abbruch *„verschwindet nur mit einer leeren
  (`id-patterns: []`) oder ganz weggelassenen `id-patterns`-Liste (**dann laufen die drei
  eingebauten Muster**, ohne `LH-*`/`MR-*` zu treffen)"*. Gemessen laufen dann **gar keine**
  Muster: Es gibt keine eingebauten Defaults — `--print-config` führt den gesamten
  `commits:`-Block auskommentiert als *Vorschlag*, und in der `--commit-msg`-Betriebsart
  sagt das Werkzeug es selbst (`--commit-msg braucht konfigurierte commits.id-patterns`,
  Exit 2). In der `--range`-Betriebsart bricht es dafür **nicht** ab, sondern meldet
  `0 Befund(e)`, Exit 0 — über zwei Commits, deren Betreff keines der drei Muster trägt.
  Der Satz beschreibt damit als funktionierenden Rückfallweg genau die Form, gegen die
  `MR-007` Setzung 3 und der `history-range-guard`-Absatz **zwei Absätze weiter oben**
  geschrieben sind: blind und grün, statt zu fallen. Operativ folgenlos heute
  (`commits` steht nicht in `modules:`, `doc-commits` ist ungenutzt) — tragend ist, dass
  der Satz den Weg für den künftigen CI-Range-Job benennt, den derselbe Absatz als
  *„eigene Abwägung"* offen lässt.
- **verifizierbar:** ja — die drei Sonden unten, je einzeln gegen den gepinnten Digest.
- **klasse:** Ausweg aus einem Werkzeug-Defekt beschrieben, ohne seine Abdeckung zu messen

```sh
D=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
git clone -q --local --no-hardlinks . <kopie> && cd <kopie>
git commit -q --allow-empty -m "voellig ohne jede kennung hier"
git commit -q --allow-empty -m "auch dieser traegt nichts"
# FLAGS = die doc-commits-Flags aus d-check.mk

# (1) id-patterns: []            -> --range ueber die zwei musterlosen Commits
#     d-check: 1125 Datei(en) geprüft, 0 Befund(e)   EXIT 0   commit-untraceable: 0
# (2) commits:-Block ganz entfernt -> dieselbe Range
#     d-check: 1125 Datei(en) geprüft, 0 Befund(e)   EXIT 0   commit-untraceable: 0
# (3) id-patterns: []            -> --commit-msg gegen eine Datei ohne Kennung
#     d-check: error: --commit-msg braucht konfigurierte commits.id-patterns   EXIT 2

docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$D" --print-config \
  | grep -n -A 6 '^# commits:'     # der ganze Block ist auskommentiert -> kein aktiver Default
```

**Sonde (3) ist die entscheidende:** Sie trennt *„die Range war blind"* von *„die leere
Liste prüft nichts"* — dieselbe leere Liste lässt dieselbe Prüfung in der anderen
Betriebsart **laut** abbrechen. Die Vorrunde konnte das nicht sehen: ihre Sonde E lief über
`HEAD~20..HEAD`, und dort trägt **jeder** Betreff eines der drei Muster
(`git log --format='%s' -20 | grep -vcE 'ADR-[0-9]{4}|DC-(FA-[A-Z]+|QA)-[0-9]+|slice-[0-9]+'`
→ **0**, kein Erwartungswert) — ein grüner Lauf war dort nicht unterscheidbar.

---

### MEDIUM-1 — `git commit -m` ist als „bewusst ausgenommen" deklariert, wird aber geblockt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage ohne rot gesehenes Gegenbeispiel),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `.claude/hooks/pretooluse-commit-msg-guard.sh:22` und
  [`harness/README.md`](../../harness/README.md):434
- **befund:** Beide Stellen sagen, `git commit -m "…"` entkomme dem Hook *bewusst*. Gemessen
  entkommt es nicht zuverlässig: Enthält der Message-**Text** eine Flag-Sequenz, die der
  Matcher zieht, und ist das folgende Wort ein existierender Pfad, läuft die Prüf-Instanz
  über eine Datei, die keine Commit-Message ist — und blockt. End-to-end mit der **realen**
  Prüf-Instanz nachgestellt (unten). Die Block-Begründung nennt dabei zwei Ursachen
  (fehlende Kennung · gescheiterte Prüf-Instanz); die tatsächliche — *der Matcher hat gar
  keine Message-Datei getroffen* — ist keine davon. Die Einschätzung des Implementers trägt
  nur zur Hälfte: **vorbestehend** gilt für die `-F`-Form, nicht für die Erweiterung —
  `--file`, `--file=`, `-qF` und quotierte Argumente im `-m`-Text sind **neue**
  Fehlauslöser dieses Diffs; **folgenlos** trägt nicht — die `[ -f "$abspath" ]`-Prüfung
  no-opt nur, solange der Token kein existierender Pfad ist.
- **verifizierbar:** ja — die zwei Läufe unten.
- **klasse:** Deklarierte Ausnahme wird von der Erkennungs-Regel verletzt

```sh
H=.claude/hooks/pretooluse-commit-msg-guard.sh
# alte Fassung (git show 2c766a7b:$H) gegen HEAD, je --match:
#   'git commit -m "siehe -F README.md"'        alt: README.md   neu: README.md   (vorbestehend)
#   'git commit -m "nutze --file README.md"'    alt: KEIN Match  neu: README.md   (NEU)
#   'git commit -m "kombiniert -qF README.md"'  alt: KEIN Match  neu: README.md   (NEU)

# end-to-end, REALE Pruef-Instanz (LICENSE traegt 0 Kennungen):
printf '%s' '{"tool_input":{"command":"git commit -m \"Details siehe --file LICENSE\""}}' | bash "$H"
#  -> {"decision":"block","reason":"Commit-Message-Datei LICENSE wurde ABGELEHNT
#      (Pruef-Instanz Exit 2): entweder traegt sie keine Traceability-Kennung …"}
```

**Fundmenge im gelebten Bestand: 0.** Kein einziger Betreff dieses Repos trüge die
Fehlauslösung, würde er per `-m` gesetzt —
`git log --format='%s' | grep -cE '[[:space:]](-[a-zA-Z]*F|--file)(=|[[:space:]])'` → **0**
von **2106** (`git log --format='%s' | wc -l`), beide kein Erwartungswert. Deshalb MEDIUM
und nicht HIGH: die Klasse ist **erreichbar und gemessen**, aber nicht eingetreten.

---

### LOW-1 — Der neue Mutations-Kommentar beschreibt einen abwesenden Text

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `test/mutations/308-commit-msg-guard-match-nur-schmales-f.sh:6`
- **befund:** *„Verengt den Flag-Teil der Match-Regex … zurueck auf die schmale, **alte**
  Form `-F`"* — das Adjektiv verweist auf den Stand vor diesem Diff, den `git` hält. Der
  Rest des Kommentars trägt saubere Abgrenzung. Fundmenge im Diff: **1** Wort
  (`grep -c 'alte Form' test/mutations/*.sh` → 1 Datei).
- **verifizierbar:** nein — `make comment-claims` erreicht `test/` nicht
  ([`AGENTS.md`](../../AGENTS.md) §4, Prüfbereich = vier Pfad-Muster).
- **klasse:** Kommentar beschreibt abwesenden Text
- **Nicht eskaliert, mit Grund:** Die HIGH-Anker meiner Skill-Datei treffen die Klasse, aber
  der Satz beschreibt primär die **Form, die die Mutation herstellt** (schmal); nur das
  Adjektiv greift zurück. Ein Leser wird über den geltenden Stand nicht getäuscht. Streichen
  des einen Wortes heilt es.

---

### INFO-1 — Der verbreiterte Matcher **erkennt** den Variablen-Pfad, **blockt** ihn aber weiterhin nicht

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `.claude/hooks/pretooluse-commit-msg-guard.sh:52-62` gegen `:86-90`
- **befund:** Der Fall, der die Vorrunde überführte — `git commit -F "$SCR/commitmsg.txt"` —
  matcht jetzt und liefert den Pfad **unexpandiert**. Damit scheitert die
  Existenz-Vorprüfung, und der Hook gibt still frei. Matchen und Blockieren sind zwei
  Stufen; nur die erste ist gewachsen. Die Grenze ist an beiden Orten benannt
  (Skriptkopf `:18-21` ausdrücklich mit der Folge *„die Existenz-Pruefung weiter unten
  greift dann nicht"*; [`harness/README.md`](../../harness/README.md):434 nur als
  *„bleibt unexpandiert"* plus *„Fehlt die Message-Datei (noch), greift der Hook nicht"*).
  Das „(noch)" liest sich als vorübergehender Zustand — beim Variablen-Pfad ist er
  dauerhaft. Kein Befund, weil die Grenze steht; benannt, weil die praktisch häufigste
  Aufrufform eines Agenten-Laufs weiterhin ungedeckt bleibt und die Über-Zusage der
  Vorrunde (MEDIUM-3) dadurch **wortwörtlich** geheilt, **in der Sache** aber nicht
  geschlossen ist.
- **verifizierbar:** ja.

```sh
H=.claude/hooks/pretooluse-commit-msg-guard.sh
bash "$H" --match 'git commit -F "$SCR/commitmsg.txt" -q'   # -> $SCR/commitmsg.txt, exit 0 (MATCH)
printf '%s' '{"tool_input":{"command":"git commit -F \"$SCR/commitmsg.txt\" -q"}}' \
  | PRETOOLUSE_COMMIT_MSG_CHECKER=<stub-exit-1> bash "$H"   # -> keine Ausgabe (KEIN Block)
```

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — HIGH-1 der Vorrunde ist gestrichen.** Der Selbstbezug in
  `test/commit-msg-guard.bats:13-16` ist durch einen Rang-Zeiger plus Abgrenzung ersetzt.
  Restliche Fundmenge repo-weit: `grep -rn '? nein:\|Skriptkopf-BELEG unten in dieser Datei' test/ .claude/ harness/ | wc -l` → **0**.
- **N-2 — MEDIUM-2 der Vorrunde ist behoben.** Die Block-Begründung nennt jetzt den
  Exit-Code und **beide** Ursachen. Gemessen mit einem Stub, der Exit 1 liefert: die
  Meldung trägt `Pruef-Instanz Exit 1` und `oder die Pruef-Instanz selbst ist gescheitert
  (Docker/Netz/Image)`. (Eine dritte Ursache fehlt weiterhin — MEDIUM-1.)
- **N-3 — MEDIUM-5 der Vorrunde ist behoben.**
  [`harness/README.md`](../../harness/README.md):436-441 führt jetzt **vier** Zahlen mit
  **vier** Kommandos und der Kennzeichnung *„alle vier kein Erwartungswert"* —
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 und 2 erfüllt. Heute nachgemessen: 239 (Text 239) · 2106 (Text 2105) ·
  2 (Text 3) · 0 (Text 0) — die Drift ist genau das, was die Kennzeichnung deckt.
- **N-4 — LOW-1 der Vorrunde ist behoben.** Der `history-range-guard`-Absatz
  ([`harness/README.md`](../../harness/README.md):317) sagt jetzt ausdrücklich
  *„`doc-commits` selbst ist heute unbedienbar, unabhängig von der Range"* und nennt
  Fehlerbild, Exit-Code und Messkommando; er grenzt ab, dass `doc-immutable` unberührt bleibt.
- **N-5 — Die fünf zuvor roten Formen sind grün, ohne Regress.** Eigenhändig nachgefahren
  (`--match`): `-F "$var"` · `-F '<pfad mit leerzeichen>'` · `--file=<pfad>` ·
  `--file <pfad>` · `-qF <pfad>` je rc=0 mit korrekter Extraktion. Unverändert: `-F <pfad>`,
  `-a -F <pfad>`, `… && echo ok` (rc=0), `-m "…"` (rc=1), `-F -` (rc=0, Wert `-`, im Hook
  vor der Prüfung abgefangen).
- **N-6 — Der volle Hook-Pfad blockt für die neuen Formen.** Mit existierender Datei und
  einem Stub, der Exit 1 liefert: `--file=<pfad>`, `-qF <pfad>` und der quotierte
  **literale** Pfad liefern je ein `{"decision":"block"}`. Matchen **und** Blockieren
  gemessen, nicht nur Matchen (Ausnahme: INFO-1).
- **N-7 — Mutations-Fall 308 sitzt richtig.** Er trifft die reale Hook-Datei, die
  [`.claude/settings.json`](../../.claude/settings.json) verdrahtet, und **genau eine**
  Zeile (`grep -c -- '(-\[a-zA-Z\]\*F|--file)' …` → **1**, Zeile 54; der Prosa-Kommentar auf
  Zeile 50 wird vom `sed`-Muster nicht getroffen). Angewandt in einer Wegwerf-Kopie fallen
  **genau drei** Fälle — `--file=`, `--file`, `-qF` —, die Quotierungs- und Basis-Fälle
  bleiben grün. `# expect: match: --file=<pfad> -> Datei auf stdout` löst exakt auf einen
  `@test`-Namen auf (`grep -nF … test/commit-msg-guard.bats` → Zeile 99) und wird von
  `narrow_sensor` (`harness/tools/mutate.sh:521-535`) auf `test-bats` verengt, dessen
  Fehlschlag-Form `not ok [0-9]+` die drei fallenden Fälle erzeugen.
- **N-8 — Keine Gate-Ausweitung, keine Schwellen-Senkung.** Die `.d-check.yml`-Änderung ist
  **ausschließlich** Kommentar:
  `git diff 2c766a7b..1e5b6ad2 -- .d-check.yml | grep -E '^[+-][^+-]' | grep -vcE '^[+-]#'`
  → **0**. `modules:` unverändert, kein `ignore-refs`-Paar, kein
  [`AGENTS.md`](../../AGENTS.md) §3.5-Fall.
- **N-9 — Die README-Aufzählung der erkannten Formen hält.** Jede dort genannte Form
  nachgemessen, alle rc=0: `-F "<pfad mit leerzeichen>"`, `--file='<…>'`, `--file="<…>"`,
  `-qF "<…>"`. Keine neue Über-Zusage in der Aufzählung selbst.
- **N-10 — Was `make mutate` entscheiden würde, und was nicht.** Er würde 307 und 308
  bestätigen (beide oben unabhängig nachgestellt: 307 unverändert, 308 färbt drei bats-Fälle
  rot). Er entscheidet **keinen** der vier Befunde oben: HIGH-1 und MEDIUM-1 sind
  Text-/Regex-Semantik ohne Fall, LOW-1 liegt in `test/`, und der **Quotierungs-Zweig** des
  Matchers (`case "$whole"`, `BASH_REMATCH[4-6]`) hat gar keinen Mutations-Fall
  (`grep -l 'BASH_REMATCH\|whole' test/mutations/*.sh | wc -l` → **0**) — 308 nimmt das
  im eigenen Kommentar ausdrücklich aus. Nach [`AGENTS.md`](../../AGENTS.md) §3.6 ist der
  Zweig damit **unbewacht**; das ist zulässig (mutate prüft Haltbarkeit, nicht Entstehung)
  und hier benannt statt behauptet.
- **N-11 — MEDIUM-4 der Vorrunde ist unberührt und ausdrücklich außerhalb der Grenzen
  erklärt** — nicht erneut geprüft, keine Aussage darüber in dieser Runde.
- **N-12 — Nicht geprüft, weil nicht meine Rolle:** DoD-Abhakung, Gate-Lauf-Nachweis
  (`gates` EXIT 0, bats 269/269, `docs-check` 1125/0, `comment-claims` 58/0,
  `shell-lint`/`full-smoke` EXIT 0) und `make mutate` — als Behauptung übernommen, keines
  davon gefahren. Das ist die Verifikation (Modul 11), getrennter Kontext.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | Ausweg aus einem Werkzeug-Defekt beschrieben, ohne seine Abdeckung zu messen |
| MEDIUM | 1 | Deklarierte Ausnahme wird von der Erkennungs-Regel verletzt |
| LOW | 1 | Kommentar beschreibt abwesenden Text |
| INFO | 1 | Erkennung gewachsen, Wirkung nicht — Matchen ≠ Blockieren |

**Wiederkehrende Klasse für die Closure-Notiz §7:** *Eine Aussage über eine gemessene
Werkzeug-Eigenschaft wird korrigiert, die Folge-Aussage im selben Satz aber nicht
nachgemessen* — Runde 1 (MEDIUM-1) fand die Ursache falsch benannt, Runde 2 findet die
Nebenklausel derselben Sätze falsch. Zweimal derselbe Satz, zweimal ein ungemessener
Halbsatz daneben.

---

## Verdikt

**Blockierender Befund: ja.**

Das Werkstück dieser Runde trägt: Der Matcher deckt jetzt alle fünf zuvor roten Formen ohne
Regress, blockt für sie auch wirklich, der neue Mutations-Fall 308 sitzt an der Stelle, die
der Aufrufer benutzt, trifft genau eine Zeile und nennt einen Sensor, der real fällt. Drei
Befunde der Vorrunde (MEDIUM-2, MEDIUM-5, LOW-1) sind behoben — nur im Bericht nicht
genannt. Die Config-Änderung weitet keinen Prüfbereich.

Blockierend ist **HIGH-1**: Die Korrektur der Werkzeug-Diagnose hat die falsche Ursache
richtig ersetzt, im selben Satz aber eine ungemessene Folge-Aussage stehen lassen — und die
beschreibt ausgerechnet ein stilles Grün als den gangbaren Rückfallweg. **MEDIUM-1** ist die
Kehrseite des verbreiterten Matchers: eine Ausnahme, die der Text als bewusst gesetzt
deklariert und die Regel verletzt; erreichbar und end-to-end gemessen, im Bestand mit
Fundmenge 0 nicht eingetreten.

**Übergabe an den Verifier: noch nicht.** HIGH-1 verlangt eine Textkorrektur an **einer**
Fundstelle, MEDIUM-1 eine Entscheidung an **zwei** (Skriptkopf und README) — Zusage
einschränken oder Regel verengen. Beide sind klein und ohne neue Messung nicht abschließbar;
danach genügt eine kurze dritte Runde über genau diesen Fundstellen. `make mutate` gehört,
wie vorgesehen, ans Ende.
