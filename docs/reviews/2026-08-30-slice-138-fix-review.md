# Review — slice-138, Fix-Runde (Der Gate-Nachweis entsteht nicht über einem roten Lauf)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Code-Review — Diff gegen Plan, aktive ADRs und Hard Rules. **Nicht** DoD-Abhakung (Verifier, Modul 11) |
| **Gegenstand** | `git show 5a75f97` — fünf Dateien, `114/18` (`git show --stat 5a75f97`); Vorlauf `07dc762` → Review `a25e33c` → Fix `5a75f97` |
| **Plan** | `docs/plan/planning/done/slice-138-nachweis-entsteht-nicht-ueber-rot.md` |
| **Bindende ADRs** | keine — der Diff nennt keine ADR-ID, `docs/plan/adr/` ist nicht berührt (`git show --name-only --format='' 5a75f97 \| grep -cE '^docs/plan/adr/'` → **0**) |
| **Anforderungen** | keine `LH-*`-Kennung (der Plan prüft `LH-QA-01` und verwirft sie: dort geht es um den **emittierten** Gate-Target). Berührt sind `AGENTS.md` §3.2 · §3.3 · §3.5 · §3.6 · §3.7 · §3.8 · §3.9 und `MR-002` · `MR-003` · `MR-025` |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-29-slice-138-review.md` (0 HIGH / 3 MEDIUM / 2 LOW / 3 INFO), davor `docs/reviews/2026-08-29-slice-133-review.md` |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.4.0; Output-Schema nach dem adoptierten Modul `.harness/baseline/v5.12.0/regelwerk/modul-10-review-harness.md` §Ziel-Form (sechstes Feld `klasse`) |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — keine Einschätzung des Implementers und keine des Vorgänger-Reports übernommen. Auch die **Schließung** der drei Vorgänger-MEDIUM ist in dieser Sitzung neu gemessen, nicht aus `a25e33c` fortgeschrieben |

**Was in diesem Lauf gefahren wurde.** `make -k gates` (Exit 2, Protokoll unten) · **zwölf** synthetische
`make`-Läufe über Wegwerf-`Makefile`n (ohne Flag, `-k`, `-i`, `-o`, `-W`, `-j4`, `-j4 -k`, `MAKEFLAGS=i`,
`MAKEFLAGS=k`, `.IGNORE:`-Zeile, `-@`-Rezept-Präfix, `@-`-Rezept-Präfix), je mit Exit-Code ·
**sechs** bats-Läufe im gepinnten Image (`bats/bats@sha256:e8f18e0a…`) über Voll-Kopien aller **846**
getrackten Dateien außerhalb des Arbeitsbaums (unmutiert · 210 · 211 · 212 · 213 · 214) ·
`diff <(make -n gates) <(make -n record-gates)` · `make -n` über der 214-Kopie gegen die Basis-Kopie.
**Nicht** gefahren: `make mutate` — der Grün-Vorlauf bricht fail-closed ab, solange `CO-004`
`make test-bats` rot hält.

---

## Findings

### MEDIUM-1 — Der Grenz-Block benennt einen Beleg-Ort, und für den `-j`-Punkt steht dort kein Kommando; die `-W`-Gleichsetzung steht ganz ohne Messung

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist — Klassen
  *Grenze* und *Rang-Zeiger*); Baseline-Regelwerk `grundlagen-durchsetzungsschicht.md` §Grenzen —
  ehrlich benannt, vom Plan selbst als Maßstab gesetzt (§1 *Wie weit gehört gehärtet*)
- **pfad:** `Makefile:305-307` (die Aussage), betroffen `Makefile:317-318` (`-W`) und
  `Makefile:320-322` (`-j`); Gegenstand `test/gate-nachweis-kante.bats:45-51`
- **befund:** Der Block sagt: *„Die Aufzählung führt die Wege, die GEMESSEN sind (je einzeln an einem
  synthetischen Makefile derselben Kantenform; **die Kommandos stehen im Kopf von
  test/gate-nachweis-kante.bats**)."* Der genannte Kopf misst ohne Flag, `-k`, `-i` und `-o rot`
  (→ `0 0 1 1`), dazu `.IGNORE:`, `-@`-Präfix, `MAKEFLAGS=i` und `MAKEFLAGS=k`. **`-j` steht dort
  nicht** (`sed -n '1,58p' test/gate-nachweis-kante.bats | grep -n -- '-j'` → genau **eine** Zeile,
  `:29`, und die trägt kein Kommando, sondern selbst einen Verweis). Sein Punkt behauptet aber ein
  Messergebnis — *„Der Nachweis bleibt gedeckt"* — über genau die Eigenschaft, für die dieser Slice
  existiert. Für `-W` ist der Fall schwächer, aber derselbe: gemessen ist `-o`, `-W` hängt an einer
  **Gleichsetzung** (*„gleichbedeutend"*), die für zwei GNU-make-Optionen mit entgegengesetzter
  Semantik (`--assume-old` gegen `--assume-new`) nicht selbstverständlich ist und im genannten Kopf
  gar nicht vorkommt (`sed -n '1,58p' test/gate-nachweis-kante.bats | grep -c -- '-W'` → **0**).
  **Beide Aussagen treffen in der Sache zu** — hier nachgemessen an der Kantenform
  `gates: record-gates` / `record-gates: gruen rot`:
  `make -C "$d" -W rot gates 2>&1 | grep -c STEMPEL` → **1** (Exit **0**), und
  `for f in "-j4" "-j4 -k"; do make -C "$d" $f gates 2>&1 | grep -c STEMPEL; done` → **0**, **0**.
  Die `-j`-Messung existiert im Repo nur in `docs/reviews/2026-08-29-slice-138-review.md`, einem
  Zeitdokument, das [`AGENTS.md`](../../AGENTS.md) §3.7 ausdrücklich **nicht** zu den lebenden
  Registern zählt.
- **verifizierbar:** nein — kein Modul des Doku-Gates liest Kommentar-Belege
  (`grep -n '^modules:' .d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`).
  Reproduzierbar über die drei Kommandos oben.
- **klasse:** Beleg-Zeiger-weiter-als-der-Beleg

### LOW-1 — „heute steht dort keines von beiden" ruht auf einem Muster, das eine Schreibweise desselben Mechanismus nicht sieht

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (die Zusage auf das einschränken, was gemessen ist);
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  als Maßstab des Repos für *Zahl aus ihrem Kommando* (der Eintrag selbst bindet Markdown, nicht den `Makefile`)
- **pfad:** `Makefile:313-315`
- **befund:** Der Block sagt zu `.IGNORE:` und zum `-`-Rezept-Präfix: *„heute steht dort keines von
  beiden"*, belegt mit `sed -n '/^\.IGNORE/p' …` → **0** und `sed -n '/^\t-/p' …` → **0**. Das zweite
  Muster sieht nur die Form, in der das `-` **zuerst** steht. GNU make erlaubt jede Reihenfolge der
  Rezept-Präfixe, und die Wirkung ist dieselbe: mit `\t@-exit 1` statt `\t@exit 1` schreibt derselbe
  synthetische Lauf den Stempel (`… | grep -c STEMPEL` → **1**, Exit **0**), während
  `sed -n '/^\t-/p'` diese Zeile nicht ausgibt. **Heute ist die Aussage trotzdem wahr** — über alle
  Präfix-Formen gemessen: `grep -cP '^\t[@+-]*-' Makefile d-check.mk` → **0**. Sie hält damit an
  einem Muster, das enger ist als sie: wer später eine Zeile `\t@-docker …` in ein Check-Rezept
  setzt, bekommt vom dokumentierten Kommando weiterhin **0** und aus `make gates` einen Stempel über
  rotem Check.
- **verifizierbar:** nein — kein Sensor liest die Rezept-Präfixe des eigenen `Makefile`.
- **klasse:** Muster-enger-als-die-Aussage

### LOW-2 — Der Skript-Kopf sagt „kein zweiter Bestand" und führt im selben Satz genau denselben Bestand; die Nicht-Abschluss-Aussage reist nicht mit

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7;
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die Mechanik,
  auf die beide Köpfe zeigen)
- **pfad:** `harness/tools/record-gates.sh:12-20` gegen `Makefile:305-322`
- **befund:** Der Kopf sagt *„Hier steht die Kurzform und **kein zweiter Bestand**: zwei gepflegte
  Listen derselben Sache driften"* — und führt unmittelbar danach beide Familien mit **allen sechs**
  Mechanismen: `-i`, `MAKEFLAGS=i`, `.IGNORE:`, `-` vor einer Rezept-Zeile, `-o`/`-W`. Das ist
  mengengleich mit der Aufzählung im `Makefile`; was fehlt, sind nur die Messungen. Ein zweiter
  Bestand ist damit vorhanden, und der Satz, der ihn bestreitet, weist den nächsten Lauf an, ihn
  nicht mitzupflegen — genau die Drift, die er benennt. Dazu fehlt hier die Einschränkung, die im
  `Makefile` die tragende Korrektur dieser Fix-Runde ist (*„Dass es keinen weiteren gibt, steht hier
  NICHT"*): der Kopf spricht durchgehend von *„den Wegen"* und liest sich abgeschlossen.
- **verifizierbar:** nein — kein Sensor hält die zwei Köpfe gegeneinander.
- **klasse:** Zwei-Fassungen-einer-Aussage-driften

### LOW-3 — Die Grenz-Sektion des Wächters führt zwei Wege als „VERHALTEN von make", die Struktur in der Datei sind, die er liest

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Grenze*); Reviewer-Anker *Harness-Lüge*
  (`.harness/skills/reviewer.md` §Repo-spezifische Anker)
- **pfad:** `test/gate-nachweis-kante.bats:41-51`
- **befund:** Die Sektion überschreibt ihre Blindstelle mit *„das VERHALTEN von make. Ob ein Lauf den
  Stempel schreibt, entscheidet make, nicht die Struktur"* und führt darunter die Wege auf. Zwei von
  ihnen — eine `.IGNORE:`-Zeile und ein `-` im Rezept-Präfix — sind **statischer Text im `Makefile`**,
  also in genau der Datei, die dieser Wächter ohnehin parst; beide sind hier rot gesehen (je
  `grep -c STEMPEL` → **1**). Der `Makefile` benennt diese strukturelle Hälfte korrekt
  (`Makefile:315-316`: *„der Wächter über der Kante liest nur Voraussetzungen, keine Rezept-Zeilen und
  keine Sonderziele"*) — im Wächter selbst steht sie nicht. Wer ihn erweitert, liest seine Grenze als
  *nur Laufzeit* und lässt eine Lücke offen, die strukturell prüfbar wäre.
- **verifizierbar:** nein.
- **klasse:** Grenz-Inventar-in-der-falschen-Kategorie

### LOW-4 — Zusage 5 verweist für `-j` auf „(Grenze unten)", und die Grenz-Sektion nennt `-j` seit diesem Commit nicht mehr

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Rang-Zeiger*)
- **pfad:** `test/gate-nachweis-kante.bats:29` gegen `:41-58`
- **befund:** Zusage 5 schließt mit *„unter `-j` faellt die Zusage (Grenze unten)"*. Die Sektion
  darunter führt `-j` nicht mehr: die Vorfassung nannte es (*„`make -i`, `make -j` und ein Aufruf des
  Skripts an make vorbei sind an der Struktur nicht sichtbar"*, `git show 07dc762:test/gate-nachweis-kante.bats`),
  dieser Commit hat den Satz ersetzt und den Verweis neu gesetzt. Der Zeiger löst nur über zwei Hops
  auf — Sektion → *„stehen im Makefile neben der Kante"* → `Makefile:320-322`.
- **verifizierbar:** nein — kein Doku-Gate-Modul liest Verweise innerhalb einer `.bats`-Datei
  (`grep -n '^modules:' .d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`; ein
  Prosa-Verweis in einem Skript-Kommentar liegt in keinem davon).
- **klasse:** Verweis-ohne-Ziel

### INFO-1 — Der neue Härtungs-Kandidat hat außer der Commit-Message keinen Träger

- **kategorie:** INFO
- **quelle:** Plan §1 (*„Baut ein Lauf sie trotzdem, ist das eine Härtung mit eigenem Auslöser und
  gehört in einen eigenen Zug"*), Plan §6 (jedes Risiko trägt einen Ausgang) — Rollen-Verweis:
  **Planner**
- **pfad:** Commit-Message `5a75f97`, Absatz *„.IGNORE und das '-'-Praefix waeren strukturell
  schliessbar … Geht als Kandidat an den Planner"*; Gegenstand `docs/plan/planning/done/slice-138-nachweis-entsteht-nicht-ueber-rot.md` §6
- **befund:** Die Fix-Runde hat zwei Mechanismen gefunden, die **im `Makefile` selbst** leben und
  darum strukturell schließbar wären. Sie **nicht** zu bauen ist plan-konform (§1 schneidet das
  ausdrücklich weg). Der Kandidat steht damit heute nur in einer Commit-Message; §6 des Plans führt
  fünf Risiken, keines davon ihn, und die Closure-Notiz (§7) ist noch leer. Ein Posten, den kein §6
  führt, bekommt bei der Closure auch keinen Ausgang.
- **verifizierbar:** nein.
- **klasse:** Übergabe-ohne-Träger

### INFO-2 — Der Plan führt `make record-gates` als offenen Weg, die Umsetzung weist ihn als geschlossen aus — begründet

- **kategorie:** INFO
- **quelle:** Plan DoD (2) (*„Jeder der drei in §1 gemessenen, **nicht** geschlossenen Wege — `-i`,
  direkter `make record-gates`, `-j` — steht danach als Grenze neben der Zusage … entweder ein Weg ist
  geschlossen, oder er steht da"*)
- **pfad:** `Makefile:326-328`
- **befund:** Der Block führt `make record-gates` unter *„GESCHLOSSEN, gemessen"* statt als Grenze.
  Das ist die andere Hälfte der Plan-Disjunktion und hier selbst nachgemessen:
  `diff <(make -n gates) <(make -n record-gates)` → leer, Exit **0**; beide Ziele stehen in `.PHONY`,
  kein Rezept fällt aus Aktualitätsgründen weg. Die Zusage ist zudem bewacht — wandert ein Check von
  der Kante neben sie, färbt Zusage 2 rot (Mutation 211, hier rot gesehen).
- **verifizierbar:** ja — `make test-bats`, Fall 211.
- **klasse:** Plan-Disjunktion-anders-eingelöst

### INFO-3 — Steering-Loop-Signal: dieselbe Klasse zum zweiten Mal auf demselben Slice, und der Zähler dafür existiert nicht

- **kategorie:** INFO
- **quelle:** `.harness/skills/reviewer.md` §Kontext-Eskalation; Baseline-Regelwerk
  `modul-10-review-harness.md` §Ziel-Form, Absatz *Pflege (Steering-Loop)* (*„gezählt wird über
  Finding-Klasse → Slice-Closure §7 → Eintrag ins Beobachtungs-Register"*)
- **pfad:** `Makefile:305-307` · `Makefile:313-315` · `harness/tools/record-gates.sh:12-20` ·
  `test/gate-nachweis-kante.bats:41-51`
- **befund:** MEDIUM-1, LOW-1, LOW-2 und LOW-3 sind vier Instanzen derselben Klasse, die `a25e33c`
  als INFO-3 geführt hat: **eine Grenz-, Beleg- oder Vollständigkeitsaussage, die weiter reicht als
  das, was an ihrer Stelle gemessen oder vorhanden ist.** Die drei Instanzen der Vorrunde sind
  geschlossen (Negativbefunde 4–6); die Klasse selbst ist mit dem Umschreiben mitgewandert — von der
  gezählten Wege-Liste zum Beleg-Zeiger, vom Blindstellen-Inventar zur Kategorie-Überschrift. Der
  Mechanismus, der das zählen soll, steht im adoptierten Modul (Finding-Klasse → §7 →
  Beobachtungs-Register); das Register existiert im Repo nicht
  (`find docs/plan -iname '*observation*' | wc -l` → **0**, `ls docs/plan/*.md | wc -l` → **0** —
  `docs/plan` trägt nur `adr/`, `carveouts/` und `planning/`; der einzige Namens-Treffer auf
  *beobachtung* ist der Slice, der es erst anlegen soll), sein Träger ist
  [slice-137](../plan/planning/done/slice-137-beobachtungs-register-bekommt-seinen-ort.md).
- **verifizierbar:** nein.
- **klasse:** Steering-Loop-Signal

### Instrument-Prüfung

Die Lehre aus `slice-133` (zwei HIGH waren derselbe Defekt in zwei Ansichten) und aus dieser Sitzung
selbst: prüfen, ob ein Befund das **Instrument** eines anderen betrifft, bevor beide getrennt laufen.

- **MEDIUM-1 gegen LOW-1.** Beide sitzen im selben Grenz-Block und lauten beide „die Belege sind
  enger als die Aussage". Verschiedene Instrumente: MEDIUM-1 ist über den **Inhalt der genannten
  Beleg-Stelle** gemessen (`sed -n '1,58p' … | grep -- '-j'`) plus zwei synthetische Läufe; LOW-1 über
  den **echten Baum** (`grep -cP '^\t[@+-]*-'`) plus einen synthetischen Lauf. Keiner misst mit dem
  Instrument des anderen, und keiner bestimmt das Ranking des anderen: wäre LOW-1 behoben, bliebe der
  `-j`-Punkt ohne Kommando; wäre MEDIUM-1 behoben, bliebe das `sed`-Muster enger als sein Satz.
- **MEDIUM-1 gegen LOW-2.** Verschiedene Artefakte (`Makefile` gegen `record-gates.sh`) und
  verschiedene Defekte (fehlender Beleg gegen doppelter Bestand). LOW-2 bliebe stehen, wenn MEDIUM-1
  fiele.
- **LOW-3 gegen LOW-4.** Dieselbe Sektion, verschiedene Instrumente: LOW-3 ist über die synthetischen
  Läufe zu `.IGNORE:`/`-`-Präfix gemessen, LOW-4 über `git show 07dc762:` gegen den Endstand. Ein
  gemeinsamer Text-Zug behöbe beide; als Beobachtung sind es zwei.
- **Nichts hängt an `a25e33c`.** Jede Schließungs-Aussage dieses Reports ist neu gemessen — die fünf
  Mutationen einzeln über Voll-Kopien, die sechs Mechanismen einzeln synthetisch, der Gate-Lauf
  eigenständig. Der Vorgänger-Report ist als **Eingang** benutzt (welche Fragen zu stellen sind), nie
  als **Beleg**.

---

## Negativbefunde — geprüft, ohne Befund

1. **Die Kern-Eigenschaft hält, in dieser Sitzung selbst gefahren.** `make -k gates` über dem
   ausgelieferten Baum: Exit **2**; `.harness/state/gates-passed.diffsha` vor und nach dem Lauf
   byte-identisch (`sha256sum` → `c3d00e388f5607d56108357b903d744daac49c2b5bfa189a56199f2d7f2e58ff`,
   Inhalt `a8b28b4ee4acda9a5bb0730a4dec908f5c1acfc734fc602a8e56e6a29ffdf7af`);
   `grep -c 'record-gates.sh' <log>` → **0**.
2. **`-k` verliert seine Sicht nicht, und die Reihenfolge steht.** Derselbe Lauf meldet **beide**
   roten Ziele (`grep -nE '^make(\[[0-9]+\])?: \*\*\*' <log>` → `d-check.mk:66: docs-check` und
   `Makefile:55: test-bats`), alle **zehn** Checks liefen (`baseline-verify: v5.12.0 OK` ·
   `d-check: 458 Datei(en) geprüft` · `--target lint` · `--target build` · `--target test` ·
   `shellcheck` · `actionlint` · `comment-claims: 46 Datei(en) geprueft, 0 Befund(e)` ·
   `naming to docker.io/library/ai-harness-init:host` · `span-check: Traeger vorhanden`), und
   `baseline-verify` steht als **erste** Zeile des Protokolls.
3. **Die fünf Wächter laufen im Gate.** `ok 74`–`ok 78` von `1..195`, alle grün.
4. **MEDIUM-2 der Vorrunde ist geschlossen.** Die dort rot gesehene Lücke — Kante auf einen Eintrag
   gekürzt, alle Wächter bleiben grün — färbt jetzt: Fall `213` über einer Voll-Kopie außerhalb des
   Arbeitsbaums → genau **`not ok 4`**, Diagnose `ist: [baseline-verify]`, die übrigen vier grün.
   Genau **1** geänderte Zeile gegen die Basis-Kopie.
5. **MEDIUM-3 der Vorrunde ist geschlossen, und die Mutation ändert wirklich den Lauf.** Fall `214`
   → genau **`not ok 5`**, Diagnose `erste Voraussetzung von record-gates: [docs-check]`. Dass die
   Umsortierung nicht bloß Text ist, ist hier nachgemessen: `make -n gates` über der mutierten Kopie
   führt `bash harness/tools/baseline-verify.sh` als **16.** Rezeptzeile, über der Basis-Kopie als
   **2.**
6. **MEDIUM-1 der Vorrunde ist in der Sache geschlossen.** Das Zählwort ist getilgt (im Block
   `Makefile:293-329` kein `vier`), die Nicht-Abschluss-Aussage steht ausdrücklich
   (`Makefile:307-308`), die Ergebnis-Kanal-Sache ist aus der Wege-Zählung heraus (`Makefile:323`),
   und **jeder** der sechs geführten Mechanismen ist hier einzeln nachgemessen — je
   `… | grep -c STEMPEL`: `-i` → **1** (Exit 0) · `MAKEFLAGS=i` → **1** · `.IGNORE: rot` → **1**
   (Exit 0) · `-@exit 1` → **1** (Exit 0) · `-o rot` → **1** (Exit 0) · `-W rot` → **1** (Exit 0);
   Gegenprobe ohne Flag → **0**, `-k` → **0**, `MAKEFLAGS=k` → **0**, `-j4` → **0**, `-j4 -k` → **0**.
   Was offen bleibt, ist der Beleg-**Ort** (MEDIUM-1 dieses Reports), nicht der Beleg.
7. **Die Blindstellen-Erklärung zu Zusage 4 trifft — sie unter- noch übertreibt nicht.**
   *„eine zweite Buchführung, kein unabhängiger Beleg … wer beide Stellen zugleich ändert, kommt an
   ihm vorbei"* (`test/gate-nachweis-kante.bats:36-39`): der Test hält `prereqs record-gates | sort`
   gegen eine hart stehende Liste, liest also nirgends, welche Checks es geben **sollte** — zutreffend.
   Er fängt Kürzung **und** Zuwachs (Zeichenketten-Gleichheit, `[ "$ist" = "$erwartet" ]`), also
   *„zwingt jeden neuen Gate durch zwei Stellen"* — zutreffend. Eine Übertreibung wäre *„der Inhalt
   der Kante ist bewacht"*; das steht dort nicht.
8. **Die Subsumtion bei Fall 210 kostet keinen Zahn.** Bedingung 4 des Treibers ist
   **Mitgliedschaft**, nicht Ausschließlichkeit (`harness/tools/mutate.sh:584`:
   `grep -E -- "$form" "$out" | grep -qF -- "$expect"`), drei rote Tests statt einem sind für ihn
   also kein Befund. Und die Einordnung ist fail-closed: verlöre Zusage 1 ihre Zähne, erschiene ihr
   Titel unter `210` **nicht** in einer `not ok`-Zeile und der Treiber meldete
   *„rot, aber '…' faellt nicht — falscher Grund"*. Hier rot gesehen: `210` → `not ok 1`, `4`, `5`;
   `211` → nur `2`; `212` → nur `3`.
9. **Die zwei neuen Fälle sind gegen ihr eigenes Veralten fail-closed.** Beide `sed`-Muster kommen
   ohne Check-Namen aus; bei einelementiger Liste oder einer über `\` umgebrochenen Kante greifen sie
   nicht, und Bedingung 2 des Treibers meldet *„Mutation hat nicht gegriffen"* statt still grün zu
   bleiben. Heute greifen beide: je genau **1** geänderte Zeile.
10. **Die Zähne treffen die gelebte Verdrahtung.** Jede Mutation ändert den `Makefile` der Kopie —
    die Datei, die `make gates` fährt —, und der Wächter liest dieselbe (`MK="$REPO/Makefile"`,
    `test/gate-nachweis-kante.bats:62`). Keine Nachbildung.
11. **LOW-2 der Vorrunde: alle drei Teilaussagen der korrigierten Übergabe treffen zu.** (a) `MR-002`
    §Adaption *„`record-gates` als letzter `gates`-Prerequisite"* bleibt wahr —
    `sed -n 's/^gates: \(.*\) ##.*/\1/p' Makefile` → `record-gates`, einziger und damit letzter.
    (b) Das **dritte** Element des Geltungsbereichs ist wörtlich `make record-gates`
    (`harness/conventions.md:103`), und genau dessen Verhalten hat sich geändert (Negativbefund 16).
    (c) Zeiger auf `MR-002` gibt es in genau dem Geltungsbereich, den der Eintrag nennt, **drei**:
    `git grep -n 'MR-002' -- 'harness/tools' '.claude'` → `pretooluse-command-guard.sh:5`,
    `stop-require-gates.sh:5`, `record-gates.sh:4`.
12. **LOW-1 der Vorrunde ist geschlossen.** Der Widerspruch über `-j` ist weg: beide Köpfe sagen jetzt
    dasselbe (`record-gates.sh:19-20` *„dort bleibt der Nachweis gedeckt und nur die
    Reihenfolgen-Zusage fällt"* gegen `Makefile:320-322`), und die Zählüberschrift *„GRENZE, drei
    Wege"* ist getilgt.
13. **INFO-1 und INFO-2 der Vorrunde sind mit tragfähigem Grund verworfen.** Die zwei verbliebenen
    Fundorte der zurückgenommenen Formulierung liegen in emittierten Vorlagen
    (`internal/emit/templates/enforce/enforce.mk:7`, `…/record-gates.sh:4`), und Plan §3 hält
    `internal/emit/**` ausdrücklich draußen. Die emittierte Ebene ist über **beide** Commits
    unberührt: `git diff --stat 07dc762^ HEAD -- internal/ harness/tools/full-smoke.sh
    harness/tools/smoke.sh test/mutations/38-gen-aggregator-order-edge.sh` → leer.
14. **Die Kopf-Zahlen des Wächters stimmen, jede einzeln nachgefahren.** `0 0 1 1` reproduziert
    (auch die Exit-Codes: 2, 2, 0, 0) · Doppelpunkt-Regeln `grep -cE '^[A-Za-z_.-]+::' Makefile
    d-check.mk` → je **0** · `grep -cE '^[[:space:]]*[-s]?include' Makefile` → **1** ·
    `grep -cE '^(gates|record-gates):' d-check.mk` → **0** · *„DIE FUENF ZUSAGEN"* gegen
    `grep -c '^@test' test/gate-nachweis-kante.bats` → **5** · die Versionsangabe *(GNU Make 4.3)*
    gegen `make --version | head -1` → `GNU Make 4.3`.
15. **`-o` und `-W` sind in GNU make keine Synonyme, in dieser Kantenform aber wirkungsgleich.**
    `--assume-old` gegen `--assume-new` — hier beide gemessen: je **1** Stempel, Exit **0**. Die
    Sach-Aussage des Blocks stimmt also; was ihr fehlt, ist der Beleg (MEDIUM-1).
16. **Der Hilfetext und die Deckungsgleichheit stimmen überein.** `record-gates` sagt *„Checks +
    Gate-Nachweis"*, und `diff <(make -n gates) <(make -n record-gates)` ist leer (Exit **0**) — wer
    `make help` liest, sieht, dass der direkte Aufruf zehn Gates fährt.
17. **§3.2.** Keine Inline-Suppression im Diff (`git show 5a75f97 | grep -cE
    '^\+.*(nolint|shellcheck disable)'` → **0**); `shell-lint` lief im Gate-Lauf ohne Befund, und die
    zwei neuen `test/mutations/*.sh` liegen in seinem Prüfbereich.
18. **§3.3.** Keine Umbenennung und keine Verschiebung im Commit — Move und Rewrite können nicht
    kollidieren.
19. **§3.4 / §3.5 / §3.8.** Keine ADR berührt, keine Schwelle gesenkt, kein Norm-Artefakt geschrieben:
    `git show --name-only --format='' 5a75f97 | grep -cE '^(AGENTS\.md|harness/conventions\.md|docs/plan/adr/)'`
    → **0**. Die Norm-Arbeit bleibt als Übergabe an den Architect benannt.
20. **§3.9.** Kein Host-Paketmanager und keine Host-Toolchain im Diff. Die Grenz-Messung im
    Wächter-Kopf ruft Host-`make` — das ist die Host-Voraussetzung, die §3.9 selbst nennt
    (*„der Host braucht `git`, `docker` und GNU `make`"*), kein Toolchain-Leak; und sie gibt sich
    nicht als Gate-Messung aus: kein gepinntes Image trägt `make`, was der Kopf in Zeile 5-6 selbst
    zum Anlass für *Struktur statt Lauf* nimmt.
21. **Beide neuen Mutations-Fälle liegen mit Ausführungsbit im Index.** `git ls-files -s
    test/mutations/21{3,4}*.sh` → je `100755` (der Gruppen-Schreibbit im Arbeitsbaum ist `umask`,
    nicht Inhalt).
22. **Erwartetes Rot ist genau das erwartete.** `docs-check` **458 geprüft / 1 Befund**, und der
    Befund ist `CO-005` (`harness/conventions.md:1019 … target-missing`); bats `not ok 40` und
    `not ok 41` = `CO-004`. `grep -cE '^not ok ' <log>` → **2** — keine weitere rote Zeile im Lauf.
23. **Der Plan-Zuschnitt ist eingehalten.** Berührt sind genau die vier Positionen aus Plan §3
    (`Makefile`, `harness/tools/record-gates.sh`, der bats-Fall, `test/mutations/`), plus ein zweiter
    Mutations-Fall derselben Zeile der Tabelle. Keine der vier ausdrücklich ausgeschlossenen Stellen
    (`harness/conventions.md`, `internal/emit/**`, `.claude/hooks/stop-require-gates.sh`) ist im Diff.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | Beleg-Zeiger-weiter-als-der-Beleg |
| LOW | 4 | Muster-enger-als-die-Aussage · Zwei-Fassungen-einer-Aussage-driften · Grenz-Inventar-in-der-falschen-Kategorie · Verweis-ohne-Ziel |
| INFO | 3 | Übergabe-ohne-Träger · Plan-Disjunktion-anders-eingelöst · Steering-Loop-Signal |

**Vorrunde (`a25e33c`):** MEDIUM-1, MEDIUM-2, MEDIUM-3, LOW-1 und LOW-2 sind **alle geschlossen**,
jeweils in dieser Sitzung neu gemessen (Negativbefunde 4, 5, 6, 11, 12). INFO-1 und INFO-2 sind mit
tragfähigem Grund verworfen (Negativbefund 13).

**Wiederholte Klasse:** *Grenz-/Beleg-/Vollständigkeitsaussage weiter als das, was an ihrer Stelle
steht* — viermal in diesem Lauf, nach dreimal im Vorlauf. Siehe INFO-3.

## Verdikt

**NICHT KONFORM — blockiert, und der Ausschlag ist deutlich kleiner als in der Vorrunde.**

Die Mechanik ist vollständig und sie ist bewacht. Alle drei blockierenden MEDIUM der Vorrunde sind
geschlossen, und zwar an der Eigenschaft, nicht an einer Formulierung: der Inhalt der Kante hat mit
Zusage 4 und Fall `213` einen Zahn, der genau das Szenario rot färbt, das vorher stumm blieb; die
Reihenfolgen-Zusage hat mit Zusage 5 und Fall `214` ein Gegenbeispiel, das nachweislich den **Lauf**
verschiebt und nicht nur den Text; und die Wege-Liste hat ihre Abschluss-Behauptung verloren und
dafür sechs Mechanismen gewonnen, die hier einzeln nachgemessen sind. Der Gate-Lauf bestätigt die
Kern-Eigenschaft unabhängig: Exit 2, Stempel byte-identisch, Stempel-Rezept null Mal, zehn Checks
gelaufen, beide roten Ziele gemeldet. Die Subsumtion bei Fall `210` ist richtig eingeordnet und
kostet keinen Zahn — der Treiber prüft Mitgliedschaft, und ein zahnloser Wächter fiele ihm auf.

Was blockiert, ist die **Klasse, die diesen Slice seit zwei Runden begleitet**: eine Aussage, die
weiter reicht als das, was an ihrer Stelle steht. Sie ist milder geworden — keine falsche
Abschluss-Behauptung mehr, keine unbewachte Zusage —, aber sie ist nicht weg. Der Grenz-Block sagt,
wo seine Belege liegen, und für den `-j`-Punkt liegt dort keiner; seine `-W`-Gleichsetzung stellt zwei
GNU-make-Optionen mit entgegengesetzter Bedeutung gleich, ohne die Gleichsetzung zu messen. **Beide
Aussagen stimmen** — in diesem Lauf nachgemessen —, und genau das ist der Grund, warum es ein MEDIUM
ist und kein HIGH: es fehlt kein Loch in der Deckung, es fehlt der Beleg an der Stelle, die der Block
selbst als Beleg-Ort benennt. Dass die Aussage im Gate-Nachweis-Pfad sitzt statt in beliebiger Doku,
hebt sie von LOW auf MEDIUM (`.harness/skills/reviewer.md` §Kontext-Eskalation).

Die vier LOW sind dieselbe Klasse in kleinerer Münze und in drei weiteren Artefakten; zusammen mit dem
MEDIUM ergibt das vier Instanzen in einem Lauf. Der Zähler, den das adoptierte Modul dafür vorsieht,
existiert im Repo nicht (INFO-3) — das ist kein Befund gegen diesen Slice, aber der Grund, warum die
Klasse zum zweiten Mal ohne Gedächtnis wiederkehrt.

**Für den Verifier:** der Slice sollte **nicht** in dieser Fassung weitergereicht werden, aber die
Distanz ist gering. MEDIUM-1 und alle vier LOW sind Kommentar-Arbeit an drei Dateien, die dieser
Slice ohnehin besitzt (`Makefile`, `harness/tools/record-gates.sh`, `test/gate-nachweis-kante.bats`);
keiner verlangt eine Änderung an der Mechanik, keiner einen weiteren Sensor, keiner eine Rückführung
nach `next`, keiner berührt ein fremdes Rollen-Artefakt. Was mein Ranking kippen würde: ein Beleg für
`-j` und für die `-o`/`-W`-Gleichsetzung an der Stelle, die der Block als Beleg-Ort nennt — dann
bliebe nur LOW. INFO-1 (der Härtungs-Kandidat ohne Träger in §6) gehört an den **Planner**, nicht in
diesen Slice.
