# Review — slice-138, dritte Fix-Runde (Der Gate-Nachweis entsteht nicht über einem roten Lauf)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Code-Review — Diff gegen Plan, aktive ADRs und Hard Rules. **Nicht** DoD-Abhakung (Verifier, Modul 11) |
| **Gegenstand** | `git show 434d4fa` — zwei Dateien, `22/37` (`git show --stat 434d4fa`); Kette `07dc762` → `a25e33c` → `5a75f97` → `02d3637` → `f275092` → `d949090` → `434d4fa` |
| **Plan** | `docs/plan/planning/done/slice-138-nachweis-entsteht-nicht-ueber-rot.md` |
| **Bindende ADRs** | keine — der Diff nennt keine ADR-ID, `docs/plan/adr/` ist unberührt (`git show --name-only --format='' 434d4fa \| grep -cE '^docs/plan/adr/'` → **0**) |
| **Anforderungen** | keine `LH-*`-Kennung (Plan §1 prüft `LH-QA-01` und verwirft sie — dort geht es um den **emittierten** Gate-Target). Berührt: [`AGENTS.md`](../../AGENTS.md) §3.2 · §3.3 · §3.6 · §3.7 · §3.8 · §3.9, `MR-002`, `MR-025` |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-29-slice-138-review.md` (0/3/2/3) · `docs/reviews/2026-08-30-slice-138-fix-review.md` (0/1/4/3) · `docs/reviews/2026-08-30-slice-138-fix2-review.md` (0/1/2/4) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.4.0; Output-Schema um das Feld `klasse` erweitert (wie in den drei Vorrunden) |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — keine Einschätzung des Implementers übernommen und keine der drei Vorgänger-Reports als Beleg. Wo ich einen Vorgänger-Befund benutze, ist er hier neu gemessen; **eine** seiner Zahlen habe ich dabei korrigiert (Instrument-Prüfung) |

**Was in diesem Lauf gefahren wurde.** `make -k gates` über dem ausgelieferten Baum (Exit **2**) ·
**drei** eigene synthetische `make`-Läufe zur Ort-Achse (eingebundenes Fragment, `-`-Präfix im
Fragment, `MAKEFILES` aus der Umgebung) · **drei** Wiederholungen der Schreibweisen-Messung aus der
Vorrunde, frisch gebaut statt abgeschrieben · Text-Abgleich `Makefile`-Block ↔ Wächter-Kopf über
vier Muster-Greps · Zeilen- und Zeichen-Zählung über vier Commits · Verweis-Suche über den ganzen
Baum ohne Zeitdokumente. **Nicht** gefahren: `make mutate` (ausdrücklich ausgeschlossen).

---

## Die eine Frage dieses Laufs: endet die Bewegung?

**Nein — aber der Prüfstein des Implementers hält auf genau den Achsen, die er aufzählt.** Beides
gehört in einen Satz, sonst wird aus dem Befund eine Pauschale.

**Was hält, gemessen.** Zwei Sonden, die den Text hätten falsifizieren müssen, **bestätigen** ihn:

1. *Weitere Schreibweise desselben Weges.* Die drei Schreibweisen aus `d949090` MEDIUM-1
   (`\t -exit 1`, `\t @-exit 1`, `\t\t-exit 1`) — hier frisch gebaut und gefahren, je
   `STEMPEL/Exit:Muster` = **`1/0:0`**. Genau das sagt der neue Nebensatz zu: *„über jede weitere
   Schreibweise desselben Weges sagen sie nichts"* (`Makefile:314-315`). Der Fund bestätigt den
   Text.
2. *Weiterer Weg.* `MAKEFILES` aus der Umgebung zieht eine Datei mit `.IGNORE:` hinzu, die in keiner
   Repo-Datei steht:
   `g=$(mktemp -d); cp <synth>/Makefile "$g/"; printf '.IGNORE: rot\n' > "$g/extra.mk"; env MAKEFILES="$g/extra.mk" make -C "$g" gates` → **STEMPEL=1, Exit=0**. Auch das ist gedeckt:
   *„Dass es keinen weiteren Weg gibt, steht hier NICHT"* (`Makefile:311-312`).

**Was nicht hält: eine vierte Gestalt, und sie liegt nicht *unter* der dritten, sondern *quer* zu
allen dreien.** Die drei Vorbehalte (Wege · Beleg · Schreibweisen) liegen auf einer Achse:
*welcher Mechanismus, wie belegt, in welcher Notation*. Unbenannt bleibt der **Ort** — über
**welche Dateien** die zwei Kommandos messen. Dieselbe Schreibweise desselben Weges in einer
weiteren Datei, die `make` liest, ist weder ein weiterer Weg noch eine weitere Schreibweise; kein
Vorbehalt des Textes reicht dorthin. Das ist MEDIUM-1.

**Und das Argument, das den Schluss tragen soll, trägt nicht.** Der Implementer begründet das Ende
der Bewegung damit, ein rein subtraktiver Diff habe *„keine Ebene, an die er eine fehlende
Einschränkung weiterreichen könnte"*. Das ist als Struktur-Aussage falsch: eine Ebene braucht es
nicht, ein **Träger** genügt — und der Träger dieser Runde ist die **Commit-Message**, die
[`AGENTS.md`](../../AGENTS.md) §3.6 ausdrücklich als Zusage bindet (*„Doc-Kommentar, Test-Name,
DoD-Punkt, **Commit-Message**"*). Dort stehen zwei neue Vollständigkeitsaussagen, und beide sind um
genau eins zu weit: *„zu allen drei Klassen Kommando und Ausgabe"* (2 von 3) und *„alle sieben
doppelt gefuehrten Aussagen sind im Makefile verschwunden"* (6 von 7). Das ist MEDIUM-2 und LOW-1.

---

## Findings

### MEDIUM-1 — Die vierte Gestalt: über **welche Dateien** die zwei Kommandos messen, sagt der Text das Gegenteil dessen, was sie tun — und kein Vorbehalt deckt eine weitere eingebundene Datei

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code
  hält"*) · §3.7 (Klasse *Grenze*, und *„Ein Kommentar beschreibt, was da ist"*); Reviewer-Anker
  **MEDIUM** *„Spec-Treue-Lücke einer Messmethode"*; Plan §1 §*Wie weit gehört gehärtet* mit dem
  geliehenen Maßstab `grundlagen-durchsetzungsschicht.md` §Grenzen — ehrlich benannt
- **pfad:** `Makefile:310-315` (die Sätze) gegen `Makefile:316-317` (die zwei Kommandos)
- **befund:** Der Text begründet, warum Hälfte (b) die zwei flaglosen Wege führt, mit
  *„weil ihr Ort **DIESE** Datei ist"* (`:310-311`), und sagt eine Zeile später
  *„ob heute eine von ihnen **hier** steht, messen diese zwei Kommandos"* (`:313`). Die zwei
  Kommandos lesen aber **zwei** Dateien (`… Makefile d-check.mk …`, `:316-317`) — der Satz ist enger
  als sein eigenes Instrument, und die Begründung ist als Aussage über den Ort schlicht unzutreffend:
  `make` honoriert beide Mechanismen in **jeder** Datei, die es liest. Hier je einzeln gemessen an
  einer Kante derselben Form, mit einem Fragment per `include`:

  ```
  e=$(mktemp -d)
  printf 'include frag.mk\n.PHONY: gates record-gates gruen rot\ngates: record-gates\nrecord-gates: gruen rot\n\t@echo STEMPEL\ngruen:\n\t@echo g\nrot:\n\t@echo ROT; exit 1\n' > "$e/Makefile"
  printf '.IGNORE: rot\n' > "$e/frag.mk"
  make -C "$e" gates            # -> STEMPEL=1, Exit=0, ROT=1
  sed -n '/^ *\.IGNORE/p' "$e/Makefile" | wc -l   # -> 0
  ```
  → `.IGNORE:` im Fragment: **STEMPEL=1, Exit=0**, Muster über die Wurzel-Datei **0**. Dasselbe mit
  `-`-Präfix im Fragment (`rot:\n\t@-echo ROT; exit 1`): **STEMPEL=1, Exit=0**, Muster über die
  Wurzel-Datei **0**.

  **Heute ist die Messung trotzdem vollständig** — und das ist der Punkt: sie ist es durch eine
  **hart aufgezählte Dateiliste**, nicht durch eine gemessene Menge. Der Bestand:
  `grep -nE '^[[:space:]]*[-s]?include' Makefile d-check.mk` → genau **1** (`Makefile:5: include
  d-check.mk`), `git ls-files '*.mk'` → **3**, davon zwei unter `internal/emit/templates/` (emittierte
  Ebene, von `make` hier nicht gelesen). Also deckt `Makefile d-check.mk` heute alles ab. Nirgends
  steht, dass das **gemessen** ist, und keiner der drei Vorbehalte reicht dorthin: eine
  `.IGNORE:`-Zeile in einem zweiten Fragment ist weder ein *weiterer Weg* (der Weg ist aufgezählt)
  noch eine *weitere Schreibweise* (die Schreibweise ist eine der vier).
  **Versagens-Erzählung:** ein zweites `include` — die Zahl stand schon einmal bei 0 und steht jetzt
  bei 1 — bringt ein Fragment mit `\t@-…` in einem Check-Rezept mit. Die zwei dokumentierten
  Kommandos geben weiter **0** aus, der Kommentar sagt weiter, der Ort dieser Mechanismen sei
  *DIESE* Datei, und `make gates` schreibt den Stempel über rotem Check mit Exit 0 — das Loch, für
  das dieser Slice existiert.
- **verifizierbar:** nein — kein Modul des Doku-Gates liest Kommentar-Belege (`.d-check.yml` führt
  `links, anchors, ids, matrix, codepaths, spans`), und der Wächter liest ausschließlich
  Voraussetzungs-Listen des Wurzel-`Makefile` (`test/gate-nachweis-kante.bats:95`, `:110-119`).
  Reproduzierbar über die Kommandos oben.
- **klasse:** Aussage-und-Instrument-treffen-den-Ort-nicht (vierte Achse: **Ort**)

**Zur Einstufung, offen:** ein anderer Reviewer könnte hier LOW vergeben, weil die Messung **heute**
vollständig ist und das Gegenbeispiel ein neues `include` braucht. Ich vergebe MEDIUM aus zwei
Gründen: der Satz *„weil ihr Ort DIESE Datei ist"* ist **heute schon** unzutreffend (er wird von
seinem eigenen Kommando eine Zeile darunter widerlegt), und die Beobachtung sitzt im
Gate-Nachweis-Pfad — Kontext-Eskalation nach `.harness/skills/reviewer.md`.

### MEDIUM-2 — Die Commit-Message sagt „zu allen drei Klassen Kommando und Ausgabe"; für eine der drei steht am genannten Ort ein Satz und kein Kommando

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (bindet die **Commit-Message** ausdrücklich als
  Zusage); Reviewer-Anker **MEDIUM** *„Spec-Treue-Lücke einer Messmethode"*
- **pfad:** Commit-Message `434d4fa`, Absatz *LOW-2*; Gegenstand `harness/tools/record-gates.sh:15-16`
  und `test/gate-nachweis-kante.bats:42-91`
- **befund:** Die Message sagt: *„jetzt zeigt es direkt auf den Waechter-Kopf, wo **zu allen drei
  Klassen** Kommando und Ausgabe stehen — **einschliesslich des Aufrufs an make vorbei**, den der
  Makefile nie fuehrte."* Für den Aufruf an `make` vorbei steht im Wächter-Kopf **kein** Kommando und
  **keine** Ausgabe, sondern ein Satz: *„Ein Aufruf des Skripts an make vorbei kennt ohnehin keinen
  Check."* (`test/gate-nachweis-kante.bats:55-56`). Gemessen:
  `awk '/^setup\(\)/{exit} {print}' test/gate-nachweis-kante.bats | grep -n -iE 'vorbei|record-gates\.sh|bash harness'`
  → **zwei** Treffer, `:40` (über den Wächter selbst) und `:55` (der Satz) — keiner davon in einer
  Mess-Zeile; der Kopf führt **30** Mess-Zeilen (`… | grep -cE '^#   '`), keine davon zu diesem Weg.
  Das ist **wörtlich** der Befund aus `02d3637` MEDIUM-1 (*„der genannte Ort trug für `-j`/`-W`
  nichts"*), eine Runde später und in einem anderen Träger. **Der Kommentar selbst ist die
  schwächere Stelle:** `record-gates.sh:15` sagt *„WELCHE **Aufrufe und Schreibweisen** das sind"* —
  das lässt sich eng lesen (die Flag-Wege und die vier Notationen), und eng gelesen stimmt es; der
  Bypass ist zwei Zeilen darüber konkret benannt und braucht kein „welche". Die Message löst genau
  diese Mehrdeutigkeit in die falsche Richtung auf und macht daraus eine Abdeckungs-Aussage.
- **verifizierbar:** nein — kein Gate liest Commit-Messages (`.d-check.yml` führt sechs Module,
  keines davon; `make mutate` kennt `--- FAIL:` und `not ok N`, keine Form, in der eine
  Message rot wird).
- **klasse:** Beleg-Zeiger-behauptet-mehr-als-am-Ort-steht (Wiederholung, neuer Träger)

### LOW-1 — „alle sieben doppelt gefuehrten Aussagen sind im Makefile verschwunden": es sind sechs von sieben, und mindestens drei weitere Paare standen nie auf der Liste

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6; [`AGENTS.md`](../../AGENTS.md) §4 (*„Eine Aussage
  hat einen Ort"*)
- **pfad:** Commit-Message `434d4fa`, Absatz *LOW-1*; Gegenstand `Makefile:293-320` ↔
  `test/gate-nachweis-kante.bats:2-91`
- **befund:** Von den sieben Paaren, die `d949090` LOW-1 aufzählt, sind sechs im `Makefile` getilgt —
  nachgeprüft, und die Streichung ist real. **Paar (4) steht weiter**, in beiden Dateien in eigener
  Formulierung: `Makefile:310` (*„die zwei, die ohne Flag auskommen"*) ↔
  `test/gate-nachweis-kante.bats:76` (*„schreiben den Stempel ueber rotem Stand OHNE Flag am
  Aufruf"*) — `grep -n 'ohne Flag\|OHNE Flag\|kein Flag' Makefile test/gate-nachweis-kante.bats` →
  genau diese zwei Zeilen. Dazu, nach demselben Kriterium der Vorrunde (*eigene Formulierung, kein
  Zitat*), **drei Paare, die die Sieben nie enthielt** und die schon in `f275092` standen:
  *serielles `make` baut in Listen-Reihenfolge ab, `-j` nicht* (`Makefile:299-300` ↔ `bats:28-29`),
  *die Menge ist nicht abgeschlossen* (`Makefile:311-312` ↔ `bats:42-43`), *die zwei Muster sind auf
  die vier Schreibweisen eingestellt* (`Makefile:313-314` ↔ `bats:81,84`). Die Aussage der Message
  ist damit auf zwei Weisen zu weit: sie zählt eines der sieben falsch und übernimmt eine
  Gesamt-Zahl, die selbst eine Untermenge war.
- **verifizierbar:** nein — kein Sensor hält die zwei Köpfe gegeneinander.
- **klasse:** Vollständigkeitsaussage-über-eine-fremde-Zählung

### LOW-2 — „Bewacht sind beide Hälften dieser Liste" trägt keinen Vorbehalt; der Wächter erklärt an seiner eigenen Stelle, dass er nur einseitige Änderungen fängt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · §3.7 (Klasse *Zusage*); Reviewer-Anker
  *Maintainability*
- **pfad:** `Makefile:300-302` gegen `test/gate-nachweis-kante.bats:37-40`
- **befund:** Der `Makefile` sagt unbedingt: *„**Bewacht** sind beide Hälften dieser Liste — ihr
  Bestand und ihr erster Eintrag — in derselben bats-Datei"*. Der Wächter sagt über dieselbe
  Erwartungsliste: *„DIE ERWARTUNGSLISTE IN ZUSAGE 4 IST EINE ZWEITE BUCHFUEHRUNG, kein
  unabhaengiger Beleg: welche Checks es geben SOLLTE, liest dieser Waechter nirgends. … wer beide
  zugleich aendert, kommt an ihm vorbei."* Im Code steht das direkt: `erwartet` ist ein String-Literal
  (`bats:155`), `ist` kommt aus `prereqs record-gates` (`bats:156`) — wer den `Makefile` und das
  Literal in einem Zug ändert, sieht Grün. Der `Makefile` führt daneben eine **Handlungsanweisung**
  (*„wer hier einen Check einträgt oder streicht, trägt ihn dort mit"*), die den Fall adressiert, aber
  die Zusage nicht einschränkt. **Nicht diesem Commit zuzurechnen:** der Satz ist byte-unverändert
  seit `5a75f97`. Er ist hier aufgeführt, weil er eine **fünfte** unbewachte Achse belegt —
  *was der Wächter leistet* — die in der Aufzählung „drei Ebenen, alle mit Vorbehalt" ebenfalls nicht
  vorkommt.
- **verifizierbar:** nein — der Fall ist per Konstruktion der, den der Wächter nicht sieht.
- **klasse:** Unbedingte-Abdeckungs-Zusage-über-einen-Wächter

### INFO-1 — Was das Streichen kostet: die Struktur-Grenze der Kante („bindet die Reihenfolge, nicht den Ausgang") hat in einem lebenden Artefakt kein Zuhause mehr

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 §Geltungsbereich (*„ein Zeitdokument
  (`docs/reviews/**`, `docs/plan/planning/done/**`) ist Chronik von Beruf"*)
- **pfad:** gestrichen aus `Makefile` (`git show 434d4fa -- Makefile`, Zeilen `-KEIN WEG, sondern die
  Struktur-Grenze der Kante …`); Rest-Vorkommen: `harness/tools/record-gates.sh:6-7` und
  `docs/plan/planning/done/slice-138-…md:167-168`, `:329-331`, `:373`
- **befund:** Der gestrichene Absatz sagte, dass die Kante **die Reihenfolge bindet, nicht den
  Ausgang**, und dass ein Ergebnis-Nachweis eine Quittung je Check verlangte. Die **Mechanik**-Hälfte
  überlebt in `record-gates.sh:6-7` (*„`make` gibt dem Rezept keinen Ergebnis-Kanal"*); die
  **Folgerung** für die Kante steht nach diesem Commit nur noch im Slice-Plan, und der wandert bei
  Closure nach `docs/plan/planning/done/`. Gemessen:
  `git grep -n -iE 'Quittung|bindet die Reihenfolge|nicht den Ausgang' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline'`
  → **4** Treffer, alle vier im Slice-Plan. Ein **Träger** existiert (Plan §6 führt den Posten mit
  Ausgang *weiter offen → Folge-Slice*), ein **lebender Ort für den Satz** nicht. Die Streichung ist
  vertretbar — unter normalem `make` ist der Erfolg der Voraussetzung der Ausgang, die Unterscheidung
  trägt nur in den Umgehungsfällen —, aber sie ist ein realer Verlust und keine reine Doppelung.
- **verifizierbar:** nein.
- **klasse:** Aussage-verliert-ihren-lebenden-Ort

### INFO-2 — DoD (2) bindet **drei** Namen, nicht sieben; die Begründung fürs Stehenlassen liest den Plan weiter, als er steht

- **kategorie:** INFO
- **quelle:** Plan §2 DoD (2) — Rollen-Verweis: **Verifier** (Abhaken) bzw. **Planner** (Zuschnitt)
- **pfad:** `docs/plan/planning/done/slice-138-…md` §2 DoD (2) gegen Commit-Message `434d4fa`,
  Absatz *LOW-1*
- **befund:** Die Message begründet das Stehenlassen aller sieben Weg-Namen damit, *„DoD (2) woertlich
  verlangt, dass jeder nicht geschlossene Weg als Grenze danebensteht"*. DoD (2) bindet wörtlich:
  *„Jeder der **drei** in §1 gemessenen, **nicht** geschlossenen Wege — `-i`, direkter `make
  record-gates`, `-j` —"*. `MAKEFLAGS=i`, `.IGNORE:`, das `-`-Rezept-Präfix, `-o` und `-W` sind
  Zugaben späterer Runden, nicht Plan-Forderungen; und der dritte Plan-Weg (direkter `make
  record-gates`) ist im `Makefile` als **GESCHLOSSEN** mit Kommando geführt (`:318-320`), was DoD (2)
  ausdrücklich zulässt. Die Begründung trägt also für drei von sieben Namen; die übrigen vier stehen
  aus eigener Wahl. Kein Befund gegen den Text — der Plan verbietet Zugaben nicht —, aber die
  Angemessenheits-Frage unten hängt daran.
- **verifizierbar:** nein.
- **klasse:** Plan-Begründung-weiter-als-der-Plan

### INFO-3 — Der Härtungs-Kandidat hat weiterhin keinen Träger in §6, und die Übergabe steht nur in der Commit-Message

- **kategorie:** INFO
- **quelle:** Plan §6 (jedes Risiko trägt einen Ausgang) und Plan §1 (*„Baut ein Lauf sie trotzdem,
  ist das eine Härtung mit eigenem Auslöser und gehört in einen eigenen Zug"*) — Rollen-Verweis:
  **Planner**
- **pfad:** `docs/plan/planning/done/slice-138-…md` §6 (sechs Risiken, keines davon dieses),
  §7 (leer); Commit-Message `434d4fa`, Absatz *Uebergaben*
- **befund:** Die Message übergibt zwei Posten an den Planner (`comment-claims` misst seine eigene
  Sensor-Nennung nicht; `.IGNORE:`/`-`-Präfix als Härtungs-Kandidat). Beide Übergaben existieren
  ausschließlich in der Commit-Message: `git show --name-only --format='' 434d4fa | grep -cE '^docs/'`
  → **0**. Dass dieser Commit den Plan nicht anfasst, ist **korrekt** (Rollen-Trennung; Plan §3 führt
  ihn nicht in der Änderungs-Liste). Ein Posten ohne §6-Zeile bekommt bei der Closure aber keinen
  Ausgang. Fortgeschrieben aus `02d3637` INFO-1 / `d949090` INFO-3, hier am Ist-Stand geprüft.
- **verifizierbar:** nein.
- **klasse:** Übergabe-ohne-Träger

### INFO-4 — Steering-Loop, vierte Runde: die Klasse hat den Code verlassen und ist in die Commit-Message gewandert

- **kategorie:** INFO
- **quelle:** `.harness/skills/reviewer.md` §Kontext-Eskalation; adoptiertes
  `modul-10-review-harness.md` §Ziel-Form, Absatz *Pflege (Steering-Loop)*
- **pfad:** die vier Reports unter `docs/reviews/` zu diesem Slice; Träger für das Register:
  `docs/plan/planning/next/slice-137-beobachtungs-register-bekommt-seinen-ort.md`
- **befund:** Die Wanderung geht weiter, und sie hat diesmal das Medium gewechselt: gezählte Liste
  (`a25e33c`) → Beleg-Zeiger (`02d3637`) → Instrument innerhalb eines Weges (`d949090`) → **Ort der
  Messung + zwei Vollständigkeitsaussagen in der Commit-Message** (hier). Der Richtungswechsel der
  Korrektur — *einschränken statt danebenstellen* — hat im **Code** funktioniert: zwei Sonden, die
  drei Runden lang Befunde erzeugt hätten, bestätigen den Text jetzt. Was nicht mitgewechselt hat,
  ist die Gewohnheit, über die eigene Korrektur eine **Menge** zu behaupten (*alle drei*, *alle
  sieben*). Der Mechanismus, der so etwas über Runden hinweg zählen soll, existiert im Repo weiterhin
  nicht: `find docs/plan -iname '*beobacht*' -o -iname '*observation*'` → **1** Treffer, und das ist
  der Slice, der das Register erst anlegt.
- **verifizierbar:** nein.
- **klasse:** Steering-Loop-Signal

---

## Instrument-Prüfung

Lehre aus `slice-133` und aus den drei Vorrunden: prüfen, ob ein Befund das **Instrument** eines
anderen betrifft, bevor beide getrennt laufen.

- **MEDIUM-1 gegen MEDIUM-2.** Verschiedene Instrumente: MEDIUM-1 hängt an synthetischen
  `make`-Läufen mit `include`-Fragment und an `git ls-files '*.mk'`; MEDIUM-2 an einem Grep über den
  Wächter-Kopf. Keiner bestimmt den anderen: fiele die Ort-Lücke weg, fehlte dem Bypass weiterhin
  Kommando und Ausgabe; stünde für den Bypass eine Messung, blieben die zwei `sed`-Kommandos an eine
  hart aufgezählte Dateiliste gebunden.
- **MEDIUM-2 gegen LOW-1.** **Berührung, und sie ist benannt.** Beide betreffen Vollständigkeits-
  Aussagen derselben Commit-Message; sie stehen aber in verschiedenen Absätzen, haben verschiedene
  Gegenstände (Wächter-Kopf gegen `Makefile`↔`bats`-Abgleich) und fallen einzeln. Sie werden nicht
  zusammengezogen, weil MEDIUM-2 den **Beleg-Ort** falsch benennt (dieselbe Klasse wie `02d3637`),
  LOW-1 nur eine **Zahl** zu weit fasst.
- **LOW-1 gegen den Vorgänger-Report.** LOW-1 benutzt die Sieben aus `d949090` als **Bezugsmenge der
  Commit-Message**, nicht als Beleg: Paar (4) ist hier direkt am Ist-Stand nachgemessen
  (`grep -n 'ohne Flag\|OHNE Flag\|kein Flag' …`), und die drei zusätzlichen Paare sind ebenfalls am
  Ist-Stand gefunden, nicht aus dem Report übernommen. **Der Vorgänger-Report ist dabei korrigiert
  worden:** seine Sieben waren eine Untermenge, keine Zählung — mindestens zehn Paare standen in
  `f275092`. Das ändert das Verdikt der Vorrunde nicht (LOW bleibt LOW), aber es ändert die
  Bezugsgröße, mit der diese Runde ihren Erfolg misst.
- **MEDIUM-1 gegen LOW-2.** Gleiche Familie (unbewachte Achse), verschiedene Instrumente:
  `make`-Läufe gegen das Lesen von `bats:155-156`. LOW-2 ist zudem älter als dieser Commit und fällt
  nicht mit MEDIUM-1.
- **INFO-1 gegen MEDIUM-1.** Verschiedene Sätze, verschiedene Läufe (Verweis-Suche über den Baum
  gegen synthetische `make`-Läufe). Unabhängig.
- **Nichts hängt an `a25e33c`, `02d3637` oder `d949090`.** Jede Schließungs-Aussage unten ist in
  dieser Sitzung neu gemessen. Die drei Schreibweisen aus der Vorrunde sind **neu gebaut** und
  gefahren, nicht aus dem Report übernommen — hätte der Report sie falsch notiert, wäre es hier
  sichtbar geworden (sie reproduzieren: `1/0:0` je).

---

## Negativbefunde — geprüft, ohne Befund

1. **Die Kern-Eigenschaft hält, in dieser Sitzung selbst gefahren.** `make -k gates` über dem
   ausgelieferten Baum: Exit **2**; `.harness/state/gates-passed.diffsha` vor und nach dem Lauf
   byte-identisch (`sha256sum` → `c3d00e388f5607d56108357b903d744daac49c2b5bfa189a56199f2d7f2e58ff`);
   `grep -c 'record-gates.sh' <log>` → **0**. Das Stempel-Rezept läuft null Mal.
2. **`-k` verliert seine Sicht nicht, und die Reihenfolge steht.** Derselbe Lauf meldet **beide**
   roten Ziele (`grep -nE '^make(\[[0-9]+\])?: \*\*\*' <log>` → `d-check.mk:66: docs-check` und
   `Makefile:55: test-bats`), `baseline-verify: v5.12.0 OK — 51 Dateien` ist die **erste**
   Protokollzeile, und alle zehn Checks laufen.
3. **Die fünf Wächter laufen im Gate.** `ok 74`–`ok 78` von `1..195`, alle grün — genau die vom
   Auftrag erwarteten Nummern.
4. **Erwartetes Rot ist genau das erwartete.** `d-check: 460 Datei(en) geprüft, 1 Befund(e)`, und der
   Befund ist `CO-005` (`harness/conventions.md:1019 … target-missing`); bats `not ok 40` und
   `not ok 41` = `CO-004`. `grep -cE '^not ok ' <log>` → **2**. `comment-claims: 46 Datei(en)
   geprueft, 0 Befund(e)`.
5. **Der Diff ist rein subtraktiv und ändert keine Zusage über Abdeckung.** `22/37`
   (`git show --stat 434d4fa`), **0** Nicht-Kommentarzeilen
   (`git show 434d4fa | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -vE '^[+-][[:space:]]*#' | wc -l`),
   und `test/gate-nachweis-kante.bats` samt `test/mutations/` ist unberührt
   (`git diff f275092 434d4fa -- test/gate-nachweis-kante.bats test/mutations/ | wc -l` → **0**).
   Der Wächter-Kopf ist byte-unverändert, wie behauptet.
6. **Die Zahlen der Commit-Message stimmen — bis auf die zwei Mengen-Aussagen oben.** `Makefile`-Block
   **43** → **28** Kommentarzeilen; Zeichen über die drei Blöcke **11173** → **9872** (−**1301**);
   nur der `Makefile`-Block **3329** → **2016** (−**39,4** %). Kommandos wörtlich aus der Message
   übernommen und je Commit gefahren; alle drei reproduzieren.
7. **Die eine Streichung, die ein wörtliches Zitat gebrochen hätte, ist unterblieben — die Begründung
   des Implementers hält exakt.** `test/gate-nachweis-kante.bats:58-59` zitiert
   *„Die zwei Klassen, die der Makefile neben der Kante fuehrt — ein gefallener Check gilt als
   GELUNGEN gegen der Check laeuft GAR NICHT"*; beide Klassennamen stehen weiter im `Makefile`
   (`:305-307`: *„ein gefallener Check gilt make als GELUNGEN"*, *„oder der Check läuft GAR NICHT"*).
   Das Zitat löst auf.
8. **Kein weiterer Verweis ist gebrochen.** Alle Stellen, die auf den Block zeigen, wurden einzeln
   geprüft: `test/gate-nachweis-kante.bats:27` (*„die Reihenfolgen-Zusage, die im Makefile neben der
   Kante steht"* — die **Zusage** steht dort weiter, `Makefile:298-299`), `:83` (*„misst das Kommando
   dort neben der Kante"* — die zwei Kommandos stehen dort, `:316-317`),
   `test/mutations/210-…sh` und `214-…sh` (beide greifen die `record-gates:`-Zeile per `sed`, nicht
   den Kommentar; die Zeile ist unverändert), `harness/tools/record-gates.sh:8` (*„die Ordnungskante
   im Makefile (`record-gates: <checks>`)"* — steht), `harness/README.md`, `MR-002`,
   `spec/architecture.md`, `docs/plan/adr/0007-…md`, `internal/emit/**` (alle über die **emittierte**
   Ebene bzw. den Ziel-Namen, nicht über den Kommentar-Text).
   `git grep -n 'Grenze unten' -- ':!docs/reviews' ':!.harness/baseline'` → **0**: der einzige
   gestrichene Binnen-Zeiger wird nirgends zitiert.
9. **`docs-check` bestätigt es maschinell.** Das `codepaths`-Modul liest Code-Verweise aus der Doku;
   der Lauf meldet **1** Befund, und der ist `CO-005`. Keine Zeile im Baum zeigt auf eine
   verschwundene `Makefile`-Zeile.
10. **Der neue Zeiger in `record-gates.sh` löst in einem Hop auf.** *„im Kopf jenes Wächters"*
    bezieht sich auf *„Wächter über der Kante: test/gate-nachweis-kante.bats"* zwei Zeilen darüber
    (`:9-10`) — die Zwei-Hop-Kette aus `d949090` LOW-2 ist geschlossen; ein zweiter Bestand steht dort
    nicht (`grep -c 'MAKEFLAGS\|IGNORE\|\-o/\-W' harness/tools/record-gates.sh` → **0**).
11. **Der neue Vorbehalt auf der Schreibweisen-Ebene hält, gegenprobiert.** Die drei Schreibweisen aus
    `d949090` MEDIUM-1 schreiben weiterhin den Stempel (`1/0` je) und werden vom Muster weiterhin
    nicht gesehen (`0` je) — und genau das sagt der Text jetzt zu. Der Befund der Vorrunde ist
    **geschlossen**, nicht überdeckt: sein Gegenstand war die fehlende Einschränkung, nicht das
    Muster.
12. **Hälfte (b) misst wirklich vier Schreibweisen.** `sed -n '80p' test/gate-nachweis-kante.bats |
    grep -o "'[^']*'"` → **5** Treffer, davon vier `sed`-Ausdrücke (`1i.IGNORE: rot`,
    `1i\ .IGNORE: rot`, `\t@-exit 1`, `\t-@exit 1`) und ein `printf`-Format. Die Zahl *vier* im
    `Makefile` stimmt.
13. **Die zwei `sed`-Kommandos im `Makefile` geben aus, was danebensteht.**
    `sed -n '/^ *\.IGNORE/p' Makefile d-check.mk | wc -l` → **0** ·
    `sed -n '/^\t[@+-]*-/p' Makefile d-check.mk | wc -l` → **0**.
14. **Das `GESCHLOSSEN`-Argument steht unverändert und ist der einzige Ort seiner Messung.**
    `Makefile:318-320` mit `diff <(make -n gates) <(make -n record-gates)`.
15. **Plan-Zuschnitt eingehalten.** Berührt sind zwei der vier Positionen aus Plan §3 (`Makefile`,
    `harness/tools/record-gates.sh`); keine der ausdrücklich ausgeschlossenen Stellen
    (`harness/conventions.md`, `internal/emit/**`, `.claude/hooks/stop-require-gates.sh`) ist im Diff.
16. **§3.2.** Keine Inline-Suppression
    (`git show 434d4fa | grep -cE '^\+.*(nolint|shellcheck disable)'` → **0**); `shell-lint` lief im
    Gate-Lauf ohne Befund.
17. **§3.3.** Keine Umbenennung, keine Verschiebung — `git show --name-status --format='' 434d4fa`
    → zwei Mal `M`.
18. **§3.4 / §3.5 / §3.8.** Kein Norm-Artefakt berührt:
    `git show --name-only --format='' 434d4fa | grep -cE '^(AGENTS\.md|harness/conventions\.md|docs/plan/adr/)'`
    → **0**. Kein Gate gelockert, keine Schwelle gesenkt. Der Slice-Plan (Planner-Artefakt) ist
    unberührt — korrekt.
19. **§3.9.** Keine Host-Toolchain und kein Paketmanager im Diff, keiner in einem dokumentierten
    Kommando. Die Mess-Kommandos rufen Host-`make`, `sed`, `printf`, `mktemp` — `make` ist die
    Host-Voraussetzung, die §3.9 selbst nennt.
20. **`MR-025` bindet hier nicht.** Der Diff berührt kein lebendes Markdown-Artefakt
    (`git show --name-only --format='' 434d4fa` → `Makefile`, `harness/tools/record-gates.sh`); die
    Zahlen im Kommentar tragen ihr Kommando trotzdem.
21. **`make mutate` nicht gefahren, und die Begründung des Implementers trägt.** Der Diff enthält
    **0** Nicht-Kommentarzeilen und lässt `test/mutations/` unberührt; es gibt keinen neuen Zahn zu
    prüfen. (Der Auftrag schließt den Lauf ohnehin aus.)

---

## Bewertung: ist der Kommentar-Bestand jetzt angemessen?

**Was gemessen ist (Kommando in derselben Zeile wie seine Zahl).**

| Ort | `07dc762` | `5a75f97` | `f275092` | `434d4fa` | Kommando |
|---|---|---|---|---|---|
| `Makefile`, Kante-Block (Zeilen) | 22 | 36 | 43 | **28** | `git show <c>:Makefile \| awk '/^# ORDNUNGSKANTE/,/^record-gates:/' \| grep -c '^#'` |
| `Makefile`, Kante-Block (Zeichen) | 1579 | 2771 | 3329 | **2016** | dasselbe `awk`, dann `grep '^#' \| wc -c` |
| alle drei Blöcke (Zeichen) | 4775 | 8295 | 11173 | **9872** | die drei `awk`-Ausschnitte aus der Commit-Message, zusammen durch `wc -c` |

**Mein Urteil, dreiteilig.**

1. **Der `Makefile`-Block erfüllt das Kriterium jetzt.** Mein Maßstab ist derselbe wie in der
   Vorrunde: eine Aussage gehört dorthin, wo sie liest, wer *diese* Stelle ändert. Ortsgebunden sind:
   die Kante und ihr Mechanismus, der Zeiger auf den Wächter, die Namen der Wege (DoD (2) für drei
   davon, s. INFO-2), die zwei `sed`-Kommandos samt ihrem Schreibweisen-Vorbehalt — sie messen
   **diese** Datei —, und der `diff`-Beleg für den geschlossenen Weg. Das ist im Wesentlichen der
   verbliebene Bestand. **2016** Zeichen über einer Kante-Zeile sind viel, aber sie tragen sieben
   benannte Umgehungen und zwei laufende Messungen; die **43 Zeilen, die ich beanstandet habe, sind
   weg**, und was blieb, hat einen Grund an dieser Stelle. Der Block liegt damit **27,7 %** über
   seinem Ausgangswert (2016 gegen 1579) und **39,4 %** unter dem beanstandeten Stand.
2. **Der Wächter-Kopf bleibt angemessen — mit einer neuen Einschränkung.** Er ist weiterhin der
   einzige dauerhafte Ort von sieben reproduzierbaren Messungen zu einer Eigenschaft, die kein Gate
   misst. Neu ist, dass er seit diesem Commit auch die **Begründung einer `Makefile`-Entscheidung**
   trägt (warum `baseline-verify` zuerst hängt): wer die Voraussetzungs-Reihenfolge im `Makefile`
   ändert, muss dafür in eine `.bats`-Datei springen. Der Zeiger ist präzise (*„Zusage 5 im Kopf des
   Wächters"*) und der Wächter fällt bei genau dieser Änderung mit einer Diagnose, die den Grund
   ausgibt (`bats:166`) — deshalb kein Finding, aber es ist die Grenze dessen, was ein Test-Kopf
   tragen sollte.
3. **Am falschen Ort steht noch genau eine Sache, und sie ist zugleich MEDIUM-1:** die Begründung
   *„weil ihr Ort DIESE Datei ist"*. Sie beschreibt nicht, was da ist (§3.7), und sie steht neben
   einem Kommando, das zwei Dateien liest.

**Was die Subtraktion insgesamt bewirkt hat:** zum ersten Mal in vier Commits ist der Bestand
gefallen (11173 → 9872), und zwar ohne dass eine Zusage schwächer geworden wäre — der Wächter-Kopf
ist byte-identisch, der Diff enthält null Nicht-Kommentarzeilen. Der Ratschen-Mechanismus, den ich
in der Vorrunde als das eigentliche Risiko benannt habe, ist damit **einmal gebrochen**. Das ist das
Ergebnis dieser Runde, und es ist ein echtes.

---

## Antwort auf die Prozess-Frage

**Gefragt:** sind die verbleibenden Befunde eine vierte Fix-Runde wert, oder gehören sie als
Folge-Posten hinaus?

**Meine Bewertung — geteilt, mit Begründung je Posten:**

- **Eine vierte Runde ist gerechtfertigt, aber nur für MEDIUM-1**, und nur in der Form, die diese
  Runde vorgemacht hat: *einschränken*, nicht *danebenstellen*. Der Grund ist nicht die Schwere,
  sondern der **Ort**: MEDIUM-1 sitzt in einem lebenden Artefakt, im Gate-Nachweis-Pfad, und der
  beanstandete Satz ist **heute schon** unzutreffend. Ein Folge-Slice über eine falsche
  Kommentar-Zeile wäre teurer als die Zeile.
- **MEDIUM-2 und LOW-1 gehören *nicht* in eine Fix-Runde.** Ihr Träger ist die Commit-Message eines
  bereits geschriebenen Commits; sie lässt sich ohne Historien-Umschrift nicht korrigieren. Der
  richtige Ort ist die **Closure-Notiz** (Plan §7), die ohnehin ansteht und in der der Lerneintrag
  sitzt: dort werden die zwei Mengen richtiggestellt (2 von 3, 6 von 7). Das kostet zwei Sätze und
  erzeugt keinen weiteren Implementer-Lauf.
- **LOW-2 gehört hinaus.** Der Satz ist älter als dieser Slice (byte-unverändert seit `5a75f97`), und
  sein Gegenstand — die Erwartungsliste als zweite Buchführung — ist eine eigene Frage mit eigenem
  Zuschnitt.
- **INFO-1 bis INFO-4 gehören an den Planner**, wie schon in den Vorrunden: §6-Ausgänge für die zwei
  Übergaben, und das Beobachtungs-Register (`slice-137`), ohne das jede Runde ohne Gedächtnis
  beginnt.

**Und eine Warnung zum eigenen Rat:** eine vierte Runde für MEDIUM-1 ist genau die Bewegung, die
INFO-4 beschreibt. Ich empfehle sie trotzdem, weil der Fix diesmal **subtraktiv-restriktiv** ist
(einen Halbsatz streichen, einen Vorbehalt anfügen) und nicht additiv-belegend. Bringt die Runde
statt dessen einen fünften Mess-Block hervor, ist **das** das Signal, den Slice ohne weitere Runde
an den Verifier zu geben und den Rest zu Folge-Posten zu machen.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 2 | Aussage-und-Instrument-treffen-den-Ort-nicht · Beleg-Zeiger-behauptet-mehr-als-am-Ort-steht |
| LOW | 2 | Vollständigkeitsaussage-über-eine-fremde-Zählung · Unbedingte-Abdeckungs-Zusage-über-einen-Wächter |
| INFO | 4 | Aussage-verliert-ihren-lebenden-Ort · Plan-Begründung-weiter-als-der-Plan · Übergabe-ohne-Träger · Steering-Loop-Signal |

**Vorrunde (`d949090`):** MEDIUM-1 ist **geschlossen** (Negativbefund 11, gegenprobiert), LOW-2 ist
**geschlossen** (Negativbefund 10), LOW-1 ist **zu 6 von 7 geschlossen** (LOW-1 dieses Reports).
INFO-1 bis INFO-4 stehen fort bzw. sind hier neu gefasst.

**Bewegung der Klasse:** `a25e33c` 3 Instanzen → `02d3637` 4 → `d949090` 2 → `434d4fa` **3**, davon
**zwei in der Commit-Message** und **eine** im Code. Im **Code** ist die Bewegung erstmals fast zum
Stehen gekommen; im **Träger** hat sie gewechselt.

---

## Verdikt

**NICHT KONFORM — blockiert, und zum ersten Mal ist der Hauptbefund nicht mehr im Code.**

Die Mechanik ist vollständig, bewacht und in diesem Lauf unabhängig bestätigt: `make -k gates` endet
mit Exit 2, der Stempel ist byte-identisch (`c3d00e38…`), das Stempel-Rezept läuft null Mal, alle
zehn Checks laufen, `baseline-verify` steht als erste Protokollzeile, und die fünf Wächter sind
`ok 74` bis `ok 78` von `1..195`. Der Diff ist rein subtraktiv — `22/37`, **0**
Nicht-Kommentarzeilen, `test/gate-nachweis-kante.bats` und `test/mutations/` byte-unberührt —, alle
sechs Zahlen der Commit-Message reproduzieren, und **keine Streichung hat einen Verweis, ein Zitat
oder eine Zusage gebrochen**: die eine Stelle, die den `Makefile` wörtlich zitiert
(`test/gate-nachweis-kante.bats:58-59`), löst weiterhin auf, weil beide Klassennamen stehen blieben —
die Begründung des Implementers hält exakt.

**Zur Kernfrage: die Bewegung endet nicht, aber sie endet auf den Achsen, die der Text aufzählt.**
Zwei Sonden, die drei Runden lang Befunde erzeugt hätten — eine weitere Schreibweise, ein weiterer
Weg —, **bestätigen** den Text jetzt; der Prüfstein des Implementers hält dort, wo er gilt. Was er
nicht sieht, liegt nicht *unter* der Schreibweisen-Ebene, sondern **quer** dazu: der **Ort** der
Messung. `.IGNORE:` und das `-`-Rezept-Präfix wirken in **jeder** Datei, die `make` liest — hier je
einzeln rot gesehen (`STEMPEL=1, Exit=0` aus einem `include`-Fragment, Muster über die Wurzel-Datei
`0`) —, während der Kommentar sagt, ihr Ort sei *DIESE* Datei, und sein eigenes Kommando eine Zeile
tiefer zwei Dateien liest. Heute ist die Messung dennoch vollständig, aber durch eine hart
aufgezählte Dateiliste, nicht durch eine gemessene Menge.

**Und das Argument, das den Schluss trägt, ist falsch.** Ein rein subtraktiver Diff braucht keine
Ebene, um eine fehlende Einschränkung weiterzureichen — er braucht einen Träger, und diese Runde hat
ihn: die Commit-Message behauptet *„zu allen drei Klassen Kommando und Ausgabe"* (für den Aufruf an
`make` vorbei steht dort ein Satz und kein Kommando) und *„alle sieben doppelt gefuehrten Aussagen
sind im Makefile verschwunden"* (es sind sechs; und die Sieben war selbst eine Untermenge). Beides
bindet [`AGENTS.md`](../../AGENTS.md) §3.6 ausdrücklich.

**Zur Angemessenheit:** das Kriterium der Vorrunde ist **erfüllt**. Der `Makefile`-Block trägt nach
28 Zeilen / 2016 Zeichen im Wesentlichen nur noch, was an dieser Stelle einen Grund hat; die 43
Zeilen sind weg, und der Gesamt-Bestand ist zum ersten Mal in vier Commits gefallen (11173 → 9872),
ohne dass eine Zusage schwächer geworden wäre. Am falschen Ort steht noch genau eine Sache, und sie
ist MEDIUM-1.

**Zum Verifier:** noch nicht — aber nur eine Zeile weit. Ich empfehle **eine** letzte, eng
geschnittene Runde für MEDIUM-1 (streichen und einschränken, nicht messen und danebenstellen) und
alles übrige als Folge-Posten: MEDIUM-2 und LOW-1 in die Closure-Notiz, LOW-2 in einen eigenen
Zuschnitt, INFO-1 bis INFO-4 an den Planner. Erzeugt diese Runde statt dessen einen fünften
Mess-Block, geht der Slice **ohne weitere Runde** an den Verifier — dann ist die Wiederholung selbst
der Befund und gehört ins Register, nicht in einen fünften Commit.
