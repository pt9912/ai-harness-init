# Review — slice-138, zweite Fix-Runde (Der Gate-Nachweis entsteht nicht über einem roten Lauf)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Code-Review — Diff gegen Plan, aktive ADRs und Hard Rules. **Nicht** DoD-Abhakung (Verifier, Modul 11) |
| **Gegenstand** | `git show f275092` — drei Dateien, `70/32` (`git show --stat f275092`); Kette `07dc762` → `a25e33c` → `5a75f97` → `02d3637` → `f275092` |
| **Plan** | `docs/plan/planning/done/slice-138-nachweis-entsteht-nicht-ueber-rot.md` |
| **Bindende ADRs** | keine — der Diff nennt keine ADR-ID, `docs/plan/adr/` ist nicht berührt (`git show --name-only --format='' f275092 \| grep -cE '^docs/plan/adr/'` → **0**) |
| **Anforderungen** | keine `LH-*`-Kennung (Plan §1 prüft `LH-QA-01` und verwirft sie: dort geht es um den **emittierten** Gate-Target). Berührt sind `AGENTS.md` §3.2 · §3.3 · §3.6 · §3.7 · §3.8 · §3.9 und `MR-002` · `MR-025` |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-29-slice-138-review.md` (0/3/2/3) · `docs/reviews/2026-08-30-slice-138-fix-review.md` (0/1/4/3) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.4.0; Output-Schema nach dem adoptierten `modul-10-review-harness.md` §Ziel-Form (sechstes Feld `klasse`) |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — keine Einschätzung des Implementers und keine der zwei Vorgänger-Reports übernommen. Auch die **Schließung** von MEDIUM-1 aus `02d3637` ist hier neu gemessen, nicht fortgeschrieben |

**Was in diesem Lauf gefahren wurde.** `make -k gates` (Exit 2, Protokoll unten) · die **fünf**
Mess-Blöcke aus dem Kopf von `test/gate-nachweis-kante.bats` **wörtlich extrahiert** und gefahren
(`sed -n '48,51p;61,62p;69,71p;80p' … | sed 's/^#   //'`), nicht abgetippt · **acht** Wiederholungen
der `-j2`-Reihenfolgen-Messung plus drei serielle · **sieben** eigene synthetische `make`-Läufe über
Schreibweisen, die im Diff **nicht** vorkommen (`\t -`, `\t- `, `\t @-`, `\t\t-`, `\t.IGNORE`,
`.IGNORE : `, `.IGNORE:` global) · die **flache** Kantenform als Gegenprobe · die drei
`Makefile`-eigenen Kommandos (`sed`×2, `diff <(make -n gates) <(make -n record-gates)`) ·
`bash harness/tools/comment-claims.sh` über zwei präparierten Kopien im Scratch.
**Nicht** gefahren: `make mutate` (Grün-Vorlauf bricht an `CO-004` ab, Vorgabe des Laufs).

---

## Findings

### MEDIUM-1 — „heute steht dort keines von beiden" ist eine Aussage über den Mechanismus, und beide Belege messen enger als der Mechanismus; drei Schreibweisen, die `make` gleich behandelt, sehen sie nicht

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (die Zusage auf das einschränken, was der Code
  hält) und §3.7 (Klasse *Grenze*); Reviewer-Anker **MEDIUM** *„Spec-Treue-Lücke einer
  Messmethode"* (`.harness/skills/reviewer.md` §Repo-spezifische Anker); Plan §1 *Wie weit gehört
  gehärtet* mit dem geliehenen Maßstab `grundlagen-durchsetzungsschicht.md` §Grenzen — ehrlich benannt
- **pfad:** `Makefile:314-317` (die Aussage samt ihren zwei Kommandos), Gegenstand
  `test/gate-nachweis-kante.bats:74-84`
- **befund:** Der Satz lautet *„Die zwei letzteren brauchen kein Flag am Aufruf — ihr Ort ist diese
  Datei; **heute steht dort keines von beiden**"* und benennt als Beleg
  `sed -n '/^ *\.IGNORE/p' … | wc -l` → **0** und `sed -n '/^\t[@+-]*-/p' … | wc -l` → **0** (beide
  hier nachgefahren, beide **0**). Subjekt des Satzes sind die **zwei Mechanismen** (`.IGNORE:`-Zeile,
  `-` im Rezept-Präfix), nicht die vier Schreibweisen, auf die das zweite Muster eingestellt ist.
  Zwischen beiden liegen mindestens **drei** Schreibweisen, die `make` genau wie die gemessenen
  behandelt und die das Muster nicht ausgibt — Leerzeichen zwischen Tabulator und Präfix-Bündel, in
  beiden Reihenfolgen, sowie ein zweiter Tabulator:

  ```
  d=$(mktemp -d)
  printf '.PHONY: gates record-gates gruen rot\ngates: record-gates\nrecord-gates: gruen rot\n\t@echo STEMPEL\ngruen:\n\t@echo g\nrot:\n\t@exit 1\n' > "$d/Makefile"
  for s in 's/^\t@exit 1$/\t -exit 1/' 's/^\t@exit 1$/\t @-exit 1/' 's/^\t@exit 1$/\t\t-exit 1/'; do e=$(mktemp -d); sed "$s" "$d/Makefile" > "$e/Makefile"; out=$(make -C "$e" gates 2>&1); rc=$?; printf '%s/%s:%s ' "$(grep -c STEMPEL <<<"$out")" "$rc" "$(sed -n '/^\t[@+-]*-/p' "$e/Makefile" | wc -l)"; done
  ```
  → `1/0:0 1/0:0 1/0:0` (2026-08-30, GNU Make 4.3) — gelesen als *STEMPEL-Treffer / Exit /
  Muster-Treffer*: jede der drei schreibt den Stempel über rotem Check und endet mit **0**, und das
  dokumentierte Muster gibt für jede **0** aus. **Die Aussage ist heute wahr** — über ein deutlich
  weiteres Instrument gemessen: `sed -e :a -e '/\\$/N; s/\\\n//; ta' Makefile | grep -cP '^\t[[:space:]@+-]*-'`
  → **0**, dasselbe über `d-check.mk` → **0**. Sie ruht damit auf einem Beleg, der die
  Wieder-Öffnung genau des Lochs nicht sieht, für das dieser Slice existiert: eine Zeile
  `\t @-docker …` in einem Check-Rezept gäbe dem dokumentierten Kommando weiterhin **0**, während
  `make gates` den Stempel über rotem Check schriebe und der Stop-Hook ihn akzeptierte. Der
  Grenz-Block trägt seinen Nicht-Abschluss-Vorbehalt (*„Dass es keinen weiteren gibt, steht hier
  NICHT"*, `Makefile:308-310`) auf der Ebene der **Wege**; auf der Ebene der **Schreibweisen** eines
  Weges steht er nicht, und der Kopf des Wächters führt die vier als *„die vier Schreibweisen"*
  (`test/gate-nachweis-kante.bats:81`), ohne dass irgendwo im Repo steht, dass es weitere gibt.
- **verifizierbar:** nein — kein Modul des Doku-Gates liest Kommentar-Belege
  (`grep -n '^modules:' .d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`), und
  kein Sensor liest die Rezept-Präfixe des eigenen `Makefile` (`test/gate-nachweis-kante.bats:110-119`
  greppt ausschließlich `^${ziel}:`). Reproduzierbar über die zwei Kommandos oben.
- **klasse:** Instrument-enger-als-die-Aussage

### LOW-1 — Der Grenz-Text steht an zwei Orten; genau die Doppelung, die derselbe Commit in `record-gates.sh` mit Begründung entfernt hat, ist zwischen `Makefile` und Wächter-Kopf gewachsen

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7; [`AGENTS.md`](../../AGENTS.md) §4
  (*„Sie steht dort und nicht hier: Eine Aussage hat einen Ort"*); die Begründung des Commits selbst
  (`harness/tools/record-gates.sh:16-17`: *„Eine Kurzform hier wäre eine zweite gepflegte Liste
  derselben Sache, und zwei Listen driften"*)
- **pfad:** `Makefile:293-332` gegen `test/gate-nachweis-kante.bats:11-91`
- **befund:** Sieben Aussagen stehen nach diesem Commit an zwei (eine an drei) Orten, jeweils in
  eigener Formulierung — also als zwei gepflegte Fassungen, nicht als Zitat:
  (1) `-o`/`-W` *bedeuten Verschiedenes, wirken an dieser Kantenform gleich* — `Makefile:322-325`
  ↔ `bats:53-55`; (2) *eine Kante sagt „hängt ab von", nicht „läuft danach"* — `Makefile:326`
  ↔ `bats:66-67`; (3) *der Wächter liest nur Voraussetzungen, keine Rezept-Zeilen und keine
  Sonderziele* — `Makefile:320-321` ↔ `bats:77-78`; (4) *`.IGNORE:` und `-`-Präfix brauchen kein
  Flag* — `Makefile:313-315` ↔ `bats:74-76`; (5) die `baseline-verify`-Begründung *„…ist jede
  Aussage der Folge-Gates über sie wertlos"* — `Makefile:299-300` ↔ `bats:27-28` ↔ `bats:166`;
  (6) *`make` gibt dem Rezept keinen Ergebnis-Kanal* — `Makefile:330-331` ↔ `record-gates.sh:6-7`;
  (7) die flache Kantenform schriebe den Stempel — `Makefile:296-297` ↔ `bats:11-14`. Dieselbe
  Beobachtung war in `02d3637` als LOW-2 gegen `record-gates.sh` geführt; dort ist sie in diesem
  Commit geschlossen (Negativbefund 5), während der `Makefile`-Block im selben Commit von **36** auf
  **43** und der Wächter-Kopf von **58** auf **91** Kommentarzeilen gewachsen ist (Kommandos in
  §Bewertung). Die **eine** Stelle, die die Doppelung als Zitat kennzeichnet und damit ausnimmt, ist
  `bats:58-59` (*„Die zwei Klassen, die der Makefile neben der Kante fuehrt"*). Ein Beispiel für den
  Schaden liegt in derselben Datei: (3) ist eine Aussage über den **Wächter**, steht aber auch im
  `Makefile`; wer den Wächter erweitert, ändert seine Grenze an einer Stelle und lässt die andere
  stehen.
- **verifizierbar:** nein — kein Sensor hält die zwei Köpfe gegeneinander.
- **klasse:** Zwei-Fassungen-einer-Aussage-driften

### LOW-2 — Der Zeiger in `record-gates.sh` benennt den `Makefile` als Ort der Messungen; dort steht die Aufzählung und ein weiterer Zeiger, die Messungen zu den Aufrufen stehen eine Datei weiter

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Rang-Zeiger*);
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
- **pfad:** `harness/tools/record-gates.sh:15-16` gegen `Makefile:305-308`
- **befund:** Der neue Text sagt: *„WELCHE Aufrufe und Schreibweisen das sind, steht hier nicht,
  sondern **gemessen im Makefile neben der Kante**."* Der `Makefile` trägt an dieser Stelle die
  Aufzählung und drei eigene Kommandos (zwei `sed`, ein `diff`), aber für **keinen** der sieben
  Aufruf-Mechanismen ein Kommando mit Ausgabe; er sagt selbst, wo die stehen (`Makefile:306-308`:
  *„Kommando wie Ausgabe stehen im Kopf von test/gate-nachweis-kante.bats"*). Der Zeiger löst also
  über zwei Hops auf, und das Wort *gemessen* hängt an der Datei, die weiterzeigt. Dazu führt der
  `Makefile` einen der in `record-gates.sh:13-14` genannten Wege nicht — den Aufruf an `make` vorbei
  (`bash harness/tools/record-gates.sh`) —, obwohl der Satz den `Makefile` als Ort für *„WELCHE
  Aufrufe"* benennt.
- **verifizierbar:** nein — kein Doku-Gate-Modul liest Prosa-Verweise in Skript-Kommentaren.
- **klasse:** Verweis-mit-Zwischenstation

### INFO-1 — Die Gegenprobe, die den ganzen Slice trägt, ist im Repo nur im Slice-Plan gemessen, und der wird bei Closure zum Zeitdokument

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6; §3.7 §Geltungsbereich (*„ein Zeitdokument
  (`docs/reviews/**`, `docs/plan/planning/done/**`) ist Chronik von Beruf"*)
- **pfad:** `Makefile:296-297` und `test/gate-nachweis-kante.bats:11-14`; Messung heute in
  `docs/plan/planning/done/slice-138-nachweis-entsteht-nicht-ueber-rot.md` §1
- **befund:** Beide Stellen tragen die Aussage *„Stünden die Checks daneben (`gates: <checks>
  record-gates`), schriebe `make -k gates` den Stempel über rotem Stand"*. Der Kopf des Wächters
  misst die **Form mit Kante** (`"" -k` → `0/2 0/2`), die **flache** Gegenprobe misst er nicht; im
  `Makefile` steht zu ihr kein Kommando. Hier nachgemessen und **zutreffend**:
  `d=$(mktemp -d); printf '.PHONY: gates record-gates gruen rot\ngates: gruen rot record-gates\nrecord-gates:\n\t@echo STEMPEL\ngruen:\n\t@echo g\nrot:\n\t@exit 1\n' > "$d/Makefile"; make -C "$d" -k gates 2>&1 | grep -c STEMPEL`
  → **1** (Exit **2**), ohne `-k` → **0**. Die einzige Fassung dieser Messung im Repo steht in §1 des
  Slice-Plans; der wandert bei Closure nach `docs/plan/planning/done/`. Der **Mechanismus** bleibt
  bewacht (Zusagen 1/4/5 plus Fall `210`), die **Begründung** verliert ihren Beleg. Kein Befund
  gegen diesen Commit — die Stellen sind älter (`07dc762`) und beide Vorgänger-Reports haben sie
  nicht beanstandet.
- **verifizierbar:** nein.
- **klasse:** Beleg-im-Zeitdokument

### INFO-2 — Der Schutz, den `make comment-claims` über der `verhindert`-Zusage in `record-gates.sh` scheinbar liefert, hängt an Prosa: „make dieses" erfüllt sein Sensor-Muster

- **kategorie:** INFO
- **quelle:** Reviewer-Anker *Harness-Lüge* (`.harness/skills/reviewer.md` §Repo-spezifische Anker);
  [`AGENTS.md`](../../AGENTS.md) §3.6 · §4 (`make comment-claims`)
- **pfad:** `harness/tools/comment-claims.sh:36` (`SENSOR='…|make [a-z][a-z-]*|…'`); Gegenstand
  `harness/tools/record-gates.sh:6-10`
- **befund:** Der Kopf des Skripts behauptet Abdeckung (*„sie **verhindert**, dass make dieses Ziel
  nach einem gefallenen Check noch baut"*, `:8-9`) und nennt den Sensor (*„Wächter über der Kante:
  test/gate-nachweis-kante.bats"*, `:9-10`) — der Gate ist grün, und die Nennung ist inhaltlich
  korrekt. Der Gate misst diese Nennung aber nicht: sein `SENSOR`-Muster enthält
  `make [a-z][a-z-]*` und wird schon von der deutschen Prosa desselben Blocks erfüllt. Hier gemessen
  über zwei Kopien im Scratch — `bash harness/tools/comment-claims.sh <kopie>`: Original → *0
  Befund(e)*, Kopie **ohne** die Wächter-Zeile (`sed '10d'`) → ebenfalls *0 Befund(e)*. Minimalprobe:
  ein Block aus `# die Kante verhindert, dass der Stempel entsteht` + `# weil make dieses Ziel nicht
  baut` → *0 Befund(e)*; derselbe Block mit `das Werkzeug` statt `make dieses` → *1 Befund*, Exit
  **1**. **Nicht diesem Commit zuzurechnen**: das Muster ist älter, und die Prosa-Treffer
  (`make lässt`, `make vorbei`) standen schon in `5a75f97`. Ein Träger fehlt: `slice-070` betrifft
  den **Prüfbereich** (*„`comment-claims` meldet Vollständigkeit über einen dreifach verengten
  Prüfbereich"*), nicht das Sensor-Muster.
- **verifizierbar:** ja, in der Gegenrichtung — `make comment-claims` bleibt grün, wenn man die
  Sensor-Nennung entfernt; das ist die Beobachtung.
- **klasse:** Wächter-ohne-Zähne (fremdes Artefakt)

### INFO-3 — Der Härtungs-Kandidat aus der ersten Fix-Runde hat weiterhin keinen Träger in §6

- **kategorie:** INFO
- **quelle:** Plan §6 (jedes Risiko trägt einen Ausgang) und Plan §1 (*„Baut ein Lauf sie trotzdem,
  ist das eine Härtung mit eigenem Auslöser und gehört in einen eigenen Zug"*) — Rollen-Verweis:
  **Planner**
- **pfad:** `docs/plan/planning/done/slice-138-nachweis-entsteht-nicht-ueber-rot.md` §6 (sechs
  Risiken, keines davon dieses) und §7 (leer)
- **befund:** Dass `.IGNORE:` und das `-`-Rezept-Präfix **strukturell** prüfbar wären, steht seit
  diesem Commit dauerhaft im Code (`test/gate-nachweis-kante.bats:74-79`) statt nur in einer
  Commit-Message — das ist die Verbesserung gegenüber `5a75f97`. Ein **Ausgang** entsteht daraus
  nicht: §6 führt den Posten nicht, und ein Posten ohne §6-Zeile bekommt bei der Closure keinen.
  Der Plan ist Artefakt des **Planners**; dass dieser Commit ihn nicht anfasst, ist korrekt
  (Rollen-Trennung, Plan §3 führt ihn nicht in der Änderungs-Liste). Übernommen aus `02d3637`
  INFO-1, hier neu am Ist-Stand geprüft.
- **verifizierbar:** nein.
- **klasse:** Übergabe-ohne-Träger

### INFO-4 — Steering-Loop: dritte Runde derselben Klasse, und sie ist jeweils eine Ebene tiefer gewandert; der Zähler dafür existiert weiterhin nicht

- **kategorie:** INFO
- **quelle:** `.harness/skills/reviewer.md` §Kontext-Eskalation (*„die dritte Wiederholung derselben
  Klasse in einer Sitzung ist ein Steering-Loop-Signal"*); adoptiertes
  `modul-10-review-harness.md` §Ziel-Form, Absatz *Pflege (Steering-Loop)*
- **pfad:** `Makefile:314-317` · `harness/tools/record-gates.sh:15-16` · die zwei
  Vorgänger-Reports
- **befund:** Die Klasse ist über drei Runden nicht verschwunden, sondern jeweils **eine
  Verschachtelungs-Ebene tiefer** gerückt, und zwar genau an der Kante, bis zu der der letzte Befund
  gezeigt hat: `a25e33c` MEDIUM-1 traf die **gezählte Wege-Liste** („vier Wege") → gefixt, worauf
  `02d3637` MEDIUM-1 den **Beleg-Zeiger** traf (der genannte Ort trug für `-j`/`-W` nichts) →
  gefixt, worauf jetzt das **Instrument innerhalb eines Weges** trifft (das Muster ist enger als der
  Mechanismus, den sein Satz benennt). In allen drei Runden lautete die Korrektur *Messung
  danebenstellen*; in allen drei Runden erbte die nächstinnere Ebene die fehlende Einschränkung.
  Der Mechanismus, der so etwas zählen soll, steht im adoptierten Modul (Finding-Klasse → Closure §7
  → Beobachtungs-Register) und existiert im Repo nicht:
  `find docs/plan -iname '*beobacht*' -o -iname '*observation*'` → genau **1** Treffer, und der ist
  `docs/plan/planning/open/slice-137-beobachtungs-register-bekommt-seinen-ort.md`, also der Slice,
  der es erst anlegt.
- **verifizierbar:** nein.
- **klasse:** Steering-Loop-Signal

### Entscheidung zum offengelegten Punkt — „Die zwei Muster decken die vier Schreibweisen" (`Makefile:317-318`)

**REFUTED als eigener Befund, mit Beleg.** Die Einordnung des Implementers trägt für den Satz, den
er nennt:

1. Der Satz ist eine **bounded** Aussage über eine Menge, die eine Zeile weiter **literal
   aufgezählt** ist (*„`.IGNORE:` mit und ohne führendes Leerzeichen, das `-` an beiden Stellen des
   Präfix-Bündels (`@-` wie `-@`)"*), und die vier Formen stehen als `sed`-Ausdrücke literal in
   `test/gate-nachweis-kante.bats:80`. Muster und Menge sind beide sichtbar; ein Leser prüft ihn
   durch Lesen.
2. Er ist trotzdem hier gemessen und **hält**: eine Probe mit genau den vier Formen
   (`printf '.IGNORE: a\n .IGNORE: b\nx:\n\t@-exit 1\ny:\n\t-@exit 1\n'`) gibt für die zwei neuen
   Muster **2** und **2**, für die zwei alten aus `5a75f97` **1** und **1**.
3. [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   bindet Zahlen in **lebenden Markdown-Artefakten**; der `Makefile` ist keines, und die zwei Zahlen,
   die im selben Absatz stehen (`-> 0`, `-> 0`), tragen ihr Kommando ohnehin.
4. Der Wächter-Kopf schränkt an seiner Stelle sogar korrekt ein: *„seine zwei Muster sind auf diese
   vier eingestellt"* (`test/gate-nachweis-kante.bats:83-84`) — das ist die ehrliche Form, kein
   Abdeckungs-Versprechen.

**Was die Einordnung nicht deckt, ist der Satz eine Zeile davor.** *„heute steht dort keines von
beiden"* spricht über die zwei **Mechanismen**, nicht über die vier Schreibweisen, und ihm fehlt die
Einschränkung, die der Wächter-Kopf mitbringt. Der Befund sitzt dort (MEDIUM-1), nicht bei der Satz-
Zeile, die der Implementer zur Entscheidung gestellt hat.

### Instrument-Prüfung

Lehre aus `slice-133` und aus beiden Vorrunden: prüfen, ob ein Befund das **Instrument** eines
anderen betrifft, bevor beide getrennt laufen.

- **MEDIUM-1 gegen LOW-1.** Beide sitzen im `Makefile`-Grenz-Block. Verschiedene Instrumente:
  MEDIUM-1 ist über **synthetische `make`-Läufe** gemessen (schreibt make den Stempel? sieht das
  Muster die Zeile?), LOW-1 über einen **Text-Abgleich zweier Dateien** plus Zeilen-/Zeichenzählung.
  Keiner bestimmt das Ranking des anderen: bliebe der Grenz-Text an nur einem Ort, wäre das Muster
  weiterhin enger als sein Satz; wäre der Satz eingeschränkt, stünden die sieben Aussagen weiterhin
  doppelt.
- **MEDIUM-1 gegen INFO-2.** Berührung geprüft und **verneint**: `make comment-claims` ist an
  **keiner** Messung dieses Reports beteiligt. MEDIUM-1 hängt an `make`-Läufen und `sed`, INFO-2 an
  Läufen von `comment-claims.sh` über Scratch-Kopien. INFO-2 erklärt allerdings, **warum** die
  Klasse in `record-gates.sh` unbemerkt überleben kann — es ist der Kontext von LOW-2, nicht dessen
  Instrument.
- **LOW-1 gegen LOW-2.** Gegenläufig, und das ist der Punkt: LOW-2 beanstandet einen **Zeiger**, den
  der Commit an die Stelle einer entfernten Doppelung gesetzt hat, LOW-1 die **verbliebene**
  Doppelung an einem anderen Paar. Beide zusammen zeigen dieselbe Achse (wo eine Aussage wohnt) von
  zwei Seiten; getrennt geführt, weil sie verschiedene Dateipaare betreffen und einzeln bestehen
  bleiben.
- **INFO-1 gegen MEDIUM-1.** Verschiedene Sätze, verschiedene Läufe (flache Form gegen
  Präfix-Schreibweisen). INFO-1 fällt nicht, wenn MEDIUM-1 fällt.
- **Nichts hängt an `a25e33c` oder `02d3637`.** Jede Schließungs-Aussage unten ist in dieser Sitzung
  neu gemessen; die Vorgänger-Reports sind als **Eingang** benutzt (welche Fragen zu stellen sind),
  nie als **Beleg**. Die fünf Mess-Blöcke des Wächter-Kopfs sind aus der Datei extrahiert und
  gefahren, nicht abgetippt — ein Tippfehler im Kopf wäre so sichtbar geworden.

---

## Negativbefunde — geprüft, ohne Befund

1. **Die Kern-Eigenschaft hält, in dieser Sitzung selbst gefahren.** `make -k gates` über dem
   ausgelieferten Baum: Exit **2**; `.harness/state/gates-passed.diffsha` vor und nach dem Lauf
   byte-identisch (`sha256sum` → `c3d00e388f5607d56108357b903d744daac49c2b5bfa189a56199f2d7f2e58ff`);
   `grep -c 'record-gates.sh' <log>` → **0**.
2. **`-k` verliert seine Sicht nicht, und die Reihenfolge steht.** Derselbe Lauf meldet **beide**
   roten Ziele (`grep -nE '^make(\[[0-9]+\])?: \*\*\*' <log>` → `d-check.mk:66: docs-check` und
   `Makefile:55: test-bats`), `baseline-verify: v5.12.0 OK` ist die **erste** Protokollzeile, und
   alle zehn Checks liefen.
3. **Die fünf Wächter laufen im Gate.** `ok 74`–`ok 78` von `1..195`, alle grün.
4. **Erwartetes Rot ist genau das erwartete.** `d-check: 459 Datei(en) geprüft, 1 Befund(e)`, und der
   Befund ist `CO-005` (`harness/conventions.md:1019 … target-missing`); bats `not ok 40` und
   `not ok 41` = `CO-004`. `grep -cE '^not ok ' <log>` → **2**, keine weitere rote Zeile.
   `comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`.
5. **MEDIUM-1 der Vorrunde ist geschlossen, und zwar vollständig.** Jeder Mechanismus, den der
   `Makefile` als gemessen führt, hat am selbst benannten Ort **Kommando und Ausgabe**: `-i` ·
   `MAKEFLAGS=i` · `.IGNORE:` · `-`-Präfix · `-o` · `-W` · `-j` (Deckung **und** Reihenfolge). Die
   Blöcke sind wörtlich aus der Datei extrahiert und gefahren; **alle** Ausgaben reproduzieren
   bitgenau: Flag-Reihe → `0/2 0/2 1/0 1/0 1/0 0/2 0/2`, MAKEFLAGS → `1/0 0/2`, Klassentrennung →
   `1 0 0`, vier Schreibweisen → `1/0 1/0 1/0 1/0`, `-j`-Reihenfolge → seriell `ERST ZWEIT STEMPEL`,
   unter `-j2` `ZWEIT ERST STEMPEL`. Die `-W`-Gleichsetzung ist getilgt und durch eine getrennte
   Messung ersetzt; `make --help` bestätigt die Namen (`-o … --old-file`, `-W … --what-if`).
6. **LOW-2 der Vorrunde ist geschlossen.** `record-gates.sh:12-18` führt keinen zweiten Bestand mehr
   (`grep -c 'MAKEFLAGS\|IGNORE\|\-o/\-W' harness/tools/record-gates.sh` → **0**), und die
   Nicht-Abschluss-Aussage reist mit (*„Dass jene Liste abgeschlossen wäre, steht auch dort nicht"*).
   Der Satz ist **ersetzt**, nicht ergänzt — der Kopf ist von **20** auf **18** Kommentarzeilen
   geschrumpft.
7. **LOW-3 der Vorrunde ist geschlossen.** Die Blindstelle heißt nicht mehr *„das VERHALTEN von
   make"*, sondern zerfällt in `(a) LAUFZEIT` (`bats:45`) und `(b) STRUKTUR IN DIESER DATEI`
   (`bats:74`); die zwei strukturellen Wege stehen in (b) mit dem Satz, dass sie prüfbar **wären**
   und dieser Wächter sie nicht liest. Der Satz stimmt: `prereqs()` (`bats:110-119`) greppt
   ausschließlich `^${ziel}:`, liest also weder Rezept-Zeilen noch Sonderziele.
8. **LOW-4 der Vorrunde ist geschlossen.** Zusage 5 verweist jetzt auf *„die Grenze unten, Haelfte
   (a)"* (`bats:29-30`), und die Marke existiert dort (`bats:45`); die `-j`-Messung steht innerhalb
   von (a) (`bats:66-72`, vor der `(b)`-Marke bei `:74`). Ein Hop, auflösbar.
9. **Die `-j2`-Reihenfolgen-Messung ist stabil, nicht rennabhängig.** Acht Wiederholungen → acht Mal
   `ZWEIT ERST STEMPEL`; drei serielle Wiederholungen → drei Mal `ERST ZWEIT STEMPEL`. Kein
   Reproduzierbarkeits-Risiko nach
   [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
10. **Die drei `Makefile`-eigenen Kommandos stimmen.** `sed -n '/^ *\.IGNORE/p' Makefile d-check.mk | wc -l`
    → **0** · `sed -n '/^\t[@+-]*-/p' Makefile d-check.mk | wc -l` → **0** ·
    `diff <(make -n gates) <(make -n record-gates)` leer, Exit **0**.
11. **Die übrigen Kopf-Zahlen des Wächters stimmen.** *„DIE FUENF ZUSAGEN"* gegen
    `grep -c '^@test' test/gate-nachweis-kante.bats` → **5** · Doppelpunkt-Regeln
    `grep -cE '^[A-Za-z_.-]+::' Makefile` und `… d-check.mk` → je **0** ·
    `grep -cE '^[[:space:]]*[-s]?include' Makefile` → **1** (`include d-check.mk`) ·
    `grep -cE '^(gates|record-gates):' d-check.mk` → **0** · `make --version | head -1` → `GNU Make 4.3`.
12. **Keine Zusage über Abdeckung ist geändert.** Der Diff der `.bats`-Datei enthält **0**
    Nicht-Kommentarzeilen (`git show f275092 -- test/gate-nachweis-kante.bats | grep -E '^[+-]' |
    grep -vE '^(\+\+\+|---)' | grep -vE '^[+-][[:space:]]*#' | wc -l` → **0**), und ab `setup()` ist
    die Datei gegen `5a75f97` identisch (`diff` leer). `test/mutations/` ist unberührt
    (`git diff --stat 5a75f97 f275092 -- test/mutations/` leer).
13. **Die `.IGNORE:`-Hälfte des Musters hat keine gemessene Lücke.** Vier weitere Schreibweisen
    geprüft: `.IGNORE : rot` (Leerzeichen vor dem Doppelpunkt) → Stempel **1**, Muster **1**;
    `.IGNORE:` global ohne Voraussetzung → **1**/**1**; `\t.IGNORE: rot` (Tabulator davor) → `make`
    honoriert es **nicht** (Stempel **0**, Exit **2**), also keine Lücke. Der Befund in MEDIUM-1
    betrifft ausschließlich die Präfix-Hälfte.
14. **Ein naives Verbreitern des Musters wäre keine Lösung, sondern falsch-positiv.**
    `grep -cP '^\t[[:space:]@+-]*-' Makefile` → **4**, und alle vier (`Makefile:98,99,243,244`) sind
    **Fortsetzungszeilen** eines `docker build`-Rezepts: `awk 'NR>=96 && NR<=99 {print ($0 ~ /\\$/)}'`
    → durchgehend wahr, und nach dem Zusammenziehen
    (`sed -e :a -e '/\\$/N; s/\\\n//; ta' Makefile | grep -cP '^\t[[:space:]@+-]*-'`) → **0**.
    Der Befund ist eine Aussage über die Reichweite des Belegs, keine über die richtige Regex.
15. **Plan-Zuschnitt eingehalten.** Berührt sind genau drei der vier Positionen aus Plan §3
    (`Makefile`, `harness/tools/record-gates.sh`, der bats-Fall); keine der drei ausdrücklich
    ausgeschlossenen Stellen (`harness/conventions.md`, `internal/emit/**`,
    `.claude/hooks/stop-require-gates.sh`) ist im Diff.
16. **Der Ausgang des `-j`-Risikos aus Plan §6 ist textlich vorbereitet.** Die dortige Bedingung
    (*„entfallen, wenn die gewählte Form die Reihenfolge unter seriellem `make` erhält **und** die
    Zusage genau das sagt"*) findet ihre zweite Hälfte in `Makefile:301` (*„Serielles `make` baut sie
    in dieser Reihenfolge ab; `-j` tut es nicht"*). Das **Abhaken** ist Sache des Verifiers.
17. **§3.2.** Keine Inline-Suppression im Diff
    (`git show f275092 | grep -cE '^\+.*(nolint|shellcheck disable)'` → **0**); `shell-lint` lief im
    Gate-Lauf ohne Befund.
18. **§3.3.** Keine Umbenennung, keine Verschiebung — `git show --name-status --format='' f275092`
    → drei Mal `M`.
19. **§3.4 / §3.5 / §3.8.** Kein Norm-Artefakt berührt:
    `git show --name-only --format='' f275092 | grep -cE '^(AGENTS\.md|harness/conventions\.md|docs/plan/adr/)'`
    → **0**. Der Slice-Plan (Artefakt des Planners) ist ebenfalls unberührt — korrekt, siehe INFO-3.
20. **§3.9.** Keine Host-Toolchain und kein Paketmanager im Diff. Die dokumentierten Mess-Kommandos
    rufen Host-`make`, `sed`, `printf`, `mktemp`, `sleep` — `make` ist die Host-Voraussetzung, die
    §3.9 selbst nennt, die übrigen sind Basis-Utilities; der Wächter-Kopf begründet in `:5-8` selbst,
    warum die Messung nicht im gepinnten Image läuft (der bats-Container trägt weder Docker noch
    `make`).
21. **`make comment-claims` bleibt in der Sache korrekt.** Die `verhindert`-Zusage in
    `record-gates.sh:8` nennt einen Sensor, den es gibt, und es ist der richtige. Dass der Gate diese
    Nennung nicht misst, ist INFO-2 und trifft `comment-claims.sh`, nicht diesen Slice.

---

## Bewertung: ist der Kommentar-Bestand noch angemessen?

**Was gemessen ist (Kommandos in derselben Zeile wie ihre Zahl).**

| Ort | `07dc762` | `5a75f97` | `f275092` | Kommando |
|---|---|---|---|---|
| `Makefile`, Kante-Block | 22 | 36 | **43** | `git show <c>:Makefile \| awk '/^# ORDNUNGSKANTE/,/^record-gates:/' \| grep -c '^#'` |
| `test/gate-nachweis-kante.bats`, Kopf | 32 | 58 | **91** | `git show <c>:test/gate-nachweis-kante.bats \| awk '/^setup\(\)/{exit} {print}' \| grep -c '^#'` |
| `harness/tools/record-gates.sh`, Kopf | 16 | 20 | **18** | `git show <c>:harness/tools/record-gates.sh \| awk '/^set -euo/{exit} {print}' \| grep -c '^#'` |

Zeichen über alle drei zusammen: **4775** → **11173**, also **2,34×** in zwei Fix-Runden
(dieselben drei `awk`-Ausschnitte, zusammen durch `wc -c`). Beschrieben wird davon: **1**
Kante-Zeile plus **1** Rezept-Zeile im `Makefile`, **4** Rumpfzeilen in `record-gates.sh`
(`grep -vcE '^\s*(#|$)' harness/tools/record-gates.sh`) und **58** Code-Zeilen im Wächter
(`awk 'NR>=93' test/gate-nachweis-kante.bats | grep -vcE '^\s*(#|$)'`). Der Kopf der `.bats`-Datei
ist damit **länger als ihr Code** (92 zu 58 Zeilen bei 168 gesamt).

**Was ich urteile — dreiteilig, weil die drei Orte nicht dasselbe Problem haben.**

1. **Der Wächter-Kopf ist angemessen, auch mit 91 Zeilen.** Er ist der **einzige** dauerhafte Ort
   von sieben reproduzierbaren Messungen zu einer Eigenschaft, die kein Gate misst; er sitzt in der
   Datei, die anfasst, wer den Wächter ändert; und die `(a)`/`(b)`-Zweiteilung hat aus einer
   Kategorie-Behauptung eine benutzbare Landkarte gemacht. Genau das verlangt der Maßstab, den der
   Plan sich geliehen hat (*„Ein Gate, das so tut, als decke es mehr ab, als es tut, ist selbst eine
   Harness-Lüge"*). Hier zu kürzen hieße, den Beleg wieder in Commit-Messages und Reports zu
   verschieben — dorthin, wo `02d3637` MEDIUM-1 ihn zu Recht nicht akzeptiert hat.
2. **Der `Makefile`-Block ist es nicht mehr.** 43 Kommentarzeilen über **einer** Kante-Zeile, und
   fünf seiner Aussagen stehen wörtlich sinngleich im Wächter-Kopf (LOW-1). Was hier ortsgebunden
   ist, ist klein und benennbar: die Kante und ihr Warum, der Zeiger auf den Wächter, die zwei
   `sed`-Kommandos (sie messen **diese** Datei) und der `diff`-Beleg. Der Rest ist eine zweite,
   prosaische Fassung des Kopfes. *„Eine Aussage hat einen Ort"* ([`AGENTS.md`](../../AGENTS.md) §4)
   ist hier nicht eingelöst, und der Commit selbst hat das Prinzip in derselben Stunde auf
   `record-gates.sh` angewandt.
3. **Das eigentliche Risiko ist nicht die Masse, sondern der Wachstums-Mechanismus.** Über drei
   Runden lautete die Antwort auf *„Aussage weiter als ihr Beleg"* jedes Mal **Messung
   danebenstellen**, nie **Aussage einschränken** — und jedes Mal erbte die nächstinnere Ebene die
   fehlende Einschränkung (INFO-4). Setzte sich das fort, ergäbe MEDIUM-1 dieser Runde einen vierten
   Mess-Block; die billigere und von [`AGENTS.md`](../../AGENTS.md) §3.6 gleichermaßen gedeckte Form
   ist ein Nebensatz, der den Satz auf das einschränkt, was sein Kommando sieht. Ich sage
   ausdrücklich **nicht**, welche Form gewählt werden soll — nur, dass „mehr Text" nicht die einzige
   ist und dass die Zahlen oben zeigen, was drei Runden davon kosten.

**Doppelt steht, gemessen:** die sieben Aussagenpaare aus LOW-1. **An den falschen Ort geraten
ist**, gemessen: die Aussage über das Leseverhalten des Wächters (`Makefile:320-321`) — sie
beschreibt ein Artefakt, das der `Makefile` nicht ist.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | Instrument-enger-als-die-Aussage |
| LOW | 2 | Zwei-Fassungen-einer-Aussage-driften · Verweis-mit-Zwischenstation |
| INFO | 4 | Beleg-im-Zeitdokument · Wächter-ohne-Zähne (fremdes Artefakt) · Übergabe-ohne-Träger · Steering-Loop-Signal |

**Vorrunde (`02d3637`):** MEDIUM-1, LOW-2, LOW-3 und LOW-4 sind **geschlossen**, jeweils in dieser
Sitzung neu gemessen (Negativbefunde 5–8). LOW-1 der Vorrunde (Muster sah `@-` nicht) ist **für die
gemeldete Schreibweise geschlossen** und für drei weitere offen — das ist MEDIUM-1 dieses Reports,
nicht ein stehengebliebener LOW. INFO-1 der Vorrunde steht unverändert (hier INFO-3), INFO-2 und
INFO-3 sind erledigt bzw. fortgeschrieben.

**Bewegung der Klasse:** `a25e33c` 3 Instanzen (MEDIUM) → `02d3637` 4 Instanzen (1 MEDIUM, 3 LOW) →
`f275092` 2 Instanzen (1 MEDIUM, 1 LOW). Der Ausschlag sinkt, die Klasse endet **nicht**: sie ist
jedes Mal eine Ebene tiefer gewandert (Liste → Zeiger → Instrument).

## Verdikt

**NICHT KONFORM — blockiert, und der Ausschlag ist erneut kleiner als in der Vorrunde.**

Die Mechanik ist vollständig, bewacht und in diesem Lauf unabhängig bestätigt: `make -k gates`
endet mit Exit 2, der Stempel ist byte-identisch, das Stempel-Rezept läuft null Mal, alle zehn
Checks laufen, `baseline-verify` steht als erste Protokollzeile, und die fünf Wächter sind `ok 74`
bis `ok 78`. Der Diff ändert **keine** Zusage über Abdeckung — null Nicht-Kommentarzeilen, ab
`setup()` byte-identisch, `test/mutations/` unberührt. Und die tragende Korrektur dieser Runde hält:
jeder Mechanismus, den der `Makefile` als gemessen führt, hat am selbst benannten Ort Kommando
**und** Ausgabe, und alle Ausgaben reproduzieren bitgenau, wörtlich aus der Datei extrahiert.

Was blockiert, ist eine **neue Instanz derselben Klasse**, und sie ist diesmal nicht nur ein
fehlender Beleg: der Satz *„heute steht dort keines von beiden"* spricht über zwei Mechanismen, und
sein Beleg-Muster sieht drei Schreibweisen nicht, mit denen `make` denselben Stempel über rotem
Check schreibt — hier je einzeln rot gesehen (`1/0`, Muster-Treffer `0`). Die Aussage ist **heute
wahr**, gemessen über ein weiteres Instrument; was fehlt, ist die Einschränkung auf das, was ihr
Kommando sieht. Das ist die MEDIUM-Definition des Skills wörtlich (*Spec-Treue-Lücke einer
Messmethode*), und es sitzt im Gate-Nachweis-Pfad, also an der Stelle, für die dieser Slice
existiert.

**Die Bewegung endet nicht.** Sie schrumpft — drei, vier, zwei Instanzen —, aber sie wandert: von
der gezählten Liste zum Beleg-Zeiger zum Instrument innerhalb eines Weges. Der Grund ist in allen
drei Runden derselbe: die Korrektur setzt eine Messung neben die Aussage, statt die Aussage auf ihre
Messung einzuschränken, und die nächstinnere Ebene erbt die fehlende Einschränkung. Solange kein
Register die Klasse führt (INFO-4, Träger `slice-137`), beginnt jede Runde ohne dieses Gedächtnis.

**Zur Angemessenheit:** der Wächter-Kopf verdient seine 91 Zeilen — er ist der einzige dauerhafte
Ort von sieben Messungen. Der `Makefile`-Block verdient seine 43 nicht: fünf seiner Aussagen stehen
sinngleich im Kopf, eine beschreibt ein fremdes Artefakt, und der Commit hat das Prinzip *eine
Aussage hat einen Ort* in derselben Stunde auf `record-gates.sh` angewandt und hier nicht.

**Für den Verifier:** in dieser Fassung **nicht** weiterreichen, aber die Distanz ist die kleinste
der drei Runden. MEDIUM-1 und beide LOW sind Kommentar-Arbeit an zwei Dateien, die dieser Slice
besitzt (`Makefile`, `harness/tools/record-gates.sh`); keiner verlangt eine Änderung an der Mechanik,
an einem `@test`-Körper, an der Erwartungsliste oder an `test/mutations/`, keiner eine Rückführung
nach `next`, keiner ein fremdes Rollen-Artefakt. Was mein Ranking kippt: eine Einschränkung des
Satzes `Makefile:314-315` auf die Reichweite seiner zwei Kommandos — dann bleiben nur LOW. INFO-2
(`comment-claims` misst seine eigene Sensor-Nennung nicht) und INFO-3 (Härtungs-Kandidat ohne
§6-Zeile) gehören **nicht** in diesen Slice: INFO-2 braucht einen Träger, den es noch nicht gibt
(`slice-070` deckt es nicht), INFO-3 gehört dem **Planner**.
