# Slice slice-121: Eine Commit-Message, die einen Commit nennt, den es nicht gibt, wird vor dem Commit rot

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Neubau, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — ein Sensor, ein Prüfbereich. **(2) Gemeinsames
Closure-Kriterium?** Nein. **(3) Auslöser reaktiv oder gewollt?** Reaktiv: der
Steering-Loop-Eintrag aus [slice-120](../in-progress/slice-120-co-003-wird-vollzogen.md) §7. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Warum das nicht [slice-119](slice-119-zusage-ohne-fall-wird-sichtbar.md) ist.** Beide entstehen
aus einem Steering-Loop-Eintrag der Form *„die Regel steht, ihr Träger fehlt"*, und beide zählen
eine Menge, bevor sie einen Maßstab darüber setzen. Der **Gegenstand** ist ein anderer:
[slice-119](slice-119-zusage-ohne-fall-wird-sichtbar.md) misst Wächter im Test-Bestand gegen
`test/mutations/`, also **Dateien im Baum**; dieser Slice misst Behauptungen in **Commit-Messages**,
also Objekte, die kein Baum trägt. Daraus folgt der zweite Unterschied: eine Testdatei ohne Fall
kann man morgen nachziehen, eine gepushte Message nicht — der Sensor muss deshalb **vor** dem
Commit greifen und nicht in `make gates`. Zusammengelegt hätten die zwei Sätze zu je drei
slice-eigenen DoD-Punkten sechs ergeben, und Modul 5 §Ziel-Form nennt das nicht *„eine längere
DoD"*, sondern *„der Schnitt ist falsch"* (≤ 3).

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Commit-Messages **dieses** Repos. Was ein
emittiertes Repo an Message-Regeln bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet —
nicht dieser; im Emissions-Baum kommt der Gegenstand nicht vor
(`git grep -lni 'commit-msg\|COMMIT_EDITMSG' -- internal/emit/templates/ | wc -l` → **0**).

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (der Gegenstand: die Regel führt **Commit-Message**
ausdrücklich als Zusage-Träger und verlangt zu jeder Zusage ihr rot gesehenes Gegenbeispiel),
[`AGENTS.md`](../../../../AGENTS.md) §3.9 (der Sensor darf `git` fahren — es ist eines der drei
Werkzeuge, die der Host haben darf; alles andere geht durch `make` ins gepinnte Image),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Gate über einem dauerhaft roten Prüfbereich senkt seine eigene Aussage — daraus folgt DoD (2)),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Sensor kommt
mit `git`, `bash` und `awk` aus oder er kommt nicht),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Hook- und Nachweis-Mechanik dieses Repos — sie entscheidet, wo ein Vor-Commit-Sensor hängt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(die nächstliegende Regel — ihr Geltungsbereich sind **lebende Markdown-Artefakte**, und eine
Commit-Message ist keines; ob das so bleibt, ist eine Architect-Frage und nicht die dieses Slice).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Eine Commit-Message, die einen Commit-Hash nennt, den die Historie nicht kennt, färbt rot —
bevor der Commit steht, mit Token und Fundstelle in der Meldung.**

### Der gemessene Anlass

[slice-120](../in-progress/slice-120-co-003-wird-vollzogen.md) hat in **einer** Message drei
Tatsachenbehauptungen getragen, die jede ein einziges Kommando widerlegt hätte: einen Commit-Verweis
auf `0f8d1a1`, den es nicht gibt (der Move ist `dbe5e50`); eine Aussage über den eigenen Diff, die
das `--stat` desselben Commits widerlegt; und eine Rechnung über einen Bestand, den
`grep -c` am Eltern-Commit anders zählt. Zwei weitere derselben Klasse standen in einer zweiten
Message. **Gefunden hat sie eine zweite Rolle, nie der schreibende Lauf** — und gepusht sind sie
nicht mehr änderbar.

**Kein Sensor dieses Repos liest eine Commit-Message.** Gemessen, nicht angenommen:
`git grep -lnE 'git (log|show|cat-file).*(%B|--format=.%s)|commit-msg|COMMIT_EDITMSG' -- Makefile d-check.mk .d-check.yml harness/tools/ .claude/hooks/ .codex/ .github/ test/`
→ **kein Treffer** (Exit 1). [`.d-check.yml`](../../../../.d-check.yml) führt sechs Module
(`links, anchors, ids, matrix, codepaths, spans`), und keines davon nimmt einen Commit entgegen.

### Warum der Sensor vor den Commit gehört und nicht in `make gates`

[`AGENTS.md`](../../../../AGENTS.md) §3.6 nennt vier Zusage-Träger — Doc-Kommentar, Test-Name,
DoD-Punkt, Commit-Message. Die ersten drei liegen im Baum und lassen sich morgen nachziehen; die
vierte ist nach dem Push **eingefroren**. Ein Gate, das nach dem Commit läuft, meldet an einem
Gegenstand rot, den niemand mehr grün machen kann — es erzeugt einen dauerhaft roten Prüfbereich
und fällt damit unter
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6). Der
nützliche Ort ist die **Message-Datei vor dem Commit**: dieses Repo committet über
`git commit -F <datei>`, und diese Datei existiert, bevor der Commit existiert.

### Die Fläche, mit ihrer Eigenschaft vor der Zahl

Die Eigenschaft: *ein Token in einer Commit-Message, das wie ein Kurz-Hash aussieht und keinen
Commit bezeichnet*. Über die ganze Historie gezählt — Kandidaten je Message aus
`git log -1 --format='%B' <c> | grep -oE '\b[0-9a-f]{7,40}\b'`, jeder gegen
`git cat-file -e <t>^{commit}`:

| Menge | Kommando | Stand |
|---|---|---|
| Commits gesamt | `git rev-list --count HEAD` | **1060** |
| davon mit mindestens einem Hex-Token in der Message | Schleife über `git log --format=%H`, je `grep -qoE '\b[0-9a-f]{7,40}\b'` | **217** |
| nicht auflösbare Token, roh | dieselbe Schleife, je Token `git cat-file -e "$t^{commit}"` | **55** über **46** Commits |
| dieselben, ohne reine Dezimalzahlen | zusätzlich `grep -qE '^[0-9]+$'` ausgeschlossen | **46** über **39** Commits |
| **davon genau 7-stellig** | dieselbe Liste, `awk 'length($2)==7'` | **6** über **5** Commits, **4** eindeutige Token |

**Die Verteilung nach Länge entscheidet den Schnitt, und sie ist eindeutig**
(`cut -d' ' -f2 <miss-liste> | awk '{print length($0)}' | sort -n | uniq -c`): **6**× siebenstellig,
**37**× achtstellig, je **1**× zehn-, siebzehn- und vierzigstellig. Die 37 achtstelligen sind
**Digest-Fragmente** — Bild- und Asset-Hashes aus Pin-Commits (`3996a593`, `fede3d02`, `2af45aad`
und Geschwister), keine Commit-Verweise. Ein Sensor über `[0-9a-f]{7,40}` sähe also **40** von
**46** Token an, die er nicht meint. **Siebenstellig ist die Kurzform, die dieses Repo schreibt**
(`git log --oneline -1 | cut -d' ' -f1` → `75ba487`), und in dieser Achse ist die Fläche klein und
benennbar: **4** tote Token in **5** Commits, davon **3** ursprüngliche Fehler (`48c2063`,
`37a263f`, `9326b2a`) und **2** Läufe, die einen davon als **Befund zitieren** (`ba619d6`,
`75ba487`). Alle Zahlen wandern mit der Historie und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); die Historie wächst nur vorne, der gemessene Teil steht fest.

### Was dieser Slice nicht liefert, und warum das kein Rest ist

**Die anderen vier Fehler der Anlass-Runde sind nicht mechanisierbar**, und das ist gemessen an
ihnen selbst: eine Aussage über den eigenen Diff (*„die zwei Berichte bleiben unberührt"*), eine
Rechnung im Fließtext (*„vier offene, zwei gehakt, einer offen"*), eine Berufung auf den falschen
Normabschnitt und eine Zählung über eine Commit-Menge. Jede von ihnen braucht ein Urteil darüber,
**worüber** der Satz spricht — und ein Muster, das das behauptet, wäre genau der Wächter, der unter
keiner Mutation rot wird ([`AGENTS.md`](../../../../AGENTS.md) §3.6 Falsch-Beispiel 1). Dieser
Slice nimmt die **eine** Achse, die ein Kommando entscheidet, und sagt an der Meldung selbst, was
er nicht sieht. Die restliche Klasse trägt kein Sensor, sondern die Norm — und die schreibt der
Architect, nicht dieser Slice.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Ein Ziel prüft eine Message-Datei gegen die Historie und benennt beim Rot Token und
      Zeile.** Es ist hermetisch (`git`, `bash`, `awk` — keine Docker-Stufe, wie
      `make comment-claims`) und nennt in seiner Meldung, **welche** Achse es prüft und welche
      nicht.
      **Rot:** eine Message-Datei mit `0f8d1a1` → Exit ≠ 0, Ausgabe nennt `0f8d1a1` und seine
      Zeile; dieselbe Datei mit `dbe5e50` statt dessen → Exit 0. Beide Läufe gehören in den
      Umsetzungs-Commit, nicht in die Zusage.
- [ ] **(2) Der Prüfbereich ist entschieden, und die Entscheidung trägt ihre Zahl.** Zu
      entscheiden ist die **Token-Achse** (siebenstellig gegen `{7,40}`) und der **Cutoff** — ob
      der Sensor nur die zu prüfende Message-Datei liest oder eine Commit-Spanne, und ab wo. Ein
      Maßstab über der ganzen Historie wäre an **5** Commits dauerhaft rot, darunter **2**, die
      einen Befund korrekt zitieren.
      **Rot:** der Sensor meldet über einem Bestand, den er nicht ändern kann, einen Befund — oder
      er lässt die 37 Digest-Fragmente durch, weil er sie gar nicht erst ansieht, ohne dass die
      Meldung das sagt. Beide Male senkt er seine eigene Aussage
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] **(3) Der Wächter hat seinen Zahn.** Ein `test/mutations/`-Fall entfernt die
      Auflösungs-Prüfung und färbt den benannten Test rot.
      **Rot:** `make mutate` meldet **BEFUND** auf genau diesen Fall, solange der Zahn die Stelle
      nicht trifft, die der Aufrufer benutzt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/` — ein neues Skript | neu | der Sensor; hermetisch wie `harness/tools/comment-claims.sh`, das dafür das Muster liefert |
| [`Makefile`](../../../../Makefile) | update | das Ziel. **Ob es in `gates` läuft, entscheidet DoD (2)** — ein Vor-Commit-Sensor gehört möglicherweise nicht dorthin |
| [`.claude/hooks/`](../../../../.claude/hooks) | offen | falls der Ort ein PreToolUse-Griff auf `git commit -F` ist; dann berührt der Slice [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) und die Grenze des Guards, die dieser selbst benennt |
| `test/` | neu | der bats-Fall, den DoD (3) mit einem `test/mutations/`-Fall belegt |
| [`harness/README.md`](../../../../harness/README.md) | update | was das Ziel prüft und was **nicht** — der Harness-Einstieg ist der Ort dieser Aussage, nicht [`AGENTS.md`](../../../../AGENTS.md) |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | Hard Rules und Adaptions-Block schreibt der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8); die Norm-Frage ist als Übergabe gestellt |
| `internal/emit/` | **unverändert** | Ebene Dogfood (Kopfzeile) |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): das WIP-Limit ist frei und die Norm-Frage ist nicht
Voraussetzung.** Der Slice wartet **nicht** auf die Architect-Entscheidung über den Geltungsbereich
von [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert):
der Sensor prüft eine Auflösbarkeit, keine Regel-Zugehörigkeit, und er ist auch dann nützlich, wenn
die Norm unverändert bleibt. Entscheidet der Architect **gegen** eine Ausweitung, ändert das an DoD
(1)–(3) nichts; entscheidet er **dafür**, bekommt der Sensor eine Quelle und keine neue Aufgabe.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: DoD (2) endet ohne Entscheidung — der Cutoff ist offen, oder der Ort des
  Sensors (Ziel gegen Hook) ist es. Dann ist der Schnitt eine Entscheidungs-Landung und der Bau
  eine zweite, nicht ein vierter DoD-Punkt.
- `in-progress` → `open`: der einzige tragfähige Ort erweist sich als agenten-gebunden — ein
  PreToolUse-Griff, den nur ein Agent fährt (`.codex/hooks.json` führt allein den
  SessionStart-Injektor). Dann ist der Sensor kein Sensor, sondern ein Stolperdraht für **einen**
  Klienten, und die Lage gehört als Carveout nach Modul 7 aufgeschrieben statt als Zusage in ein
  `make`-Ziel.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` ohne Befund,
Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7
mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Sensor kann die Sprache nicht von der Sache trennen.** Ein Lauf, der einen toten Hash
  korrekt **als Befund zitiert**, sieht für ihn aus wie einer, der ihn begeht — in der gemessenen
  Fläche sind das **2** von **5** Commits. Wer das mit einer Ausnahme-Liste löst, baut die
  Suppression, deren Grund als Nächstes veraltet; wer es mit einem Muster löst
  (*„in Anführungszeichen zählt nicht"*), baut einen Wächter ohne Zähne. Die Frage gehört in DoD
  (2) und ist dort mit ihrer Zahl gestellt, nicht hier weggewunken.
- **Ein Vor-Commit-Sensor hat in diesem Repo keinen Präzedenzfall.** `make gates` läuft **nach**
  der Änderung, der Stop-Hook prüft einen Baum-Hash, der PreToolUse-Guard prüft eine
  Befehlszeile — keiner davon nimmt eine Datei entgegen, die noch kein Commit ist. Der Ort ist
  darum eine echte Wahl und nicht eine Formalie.
- **Der Sensor deckt eine von fünf gemessenen Instanzen der Klasse.** Das steht so in §1 und muss
  auch in der Meldung stehen: ein Ziel, das *„Commit-Message geprüft"* ausgibt, behauptet mehr, als
  es hält. Was es prüft, ist eine Auflösbarkeit.
- **`git` in der Befehlsposition ist erlaubt, aber die Grenze ist dünn.**
  [`AGENTS.md`](../../../../AGENTS.md) §3.9 nennt `git` als eines von drei Host-Werkzeugen; jede
  Erweiterung des Sensors, die mehr braucht, ist ein Docker-Schritt oder sie entfällt
  ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
Harness-Werkzeuge unter `harness/tools/` sind konventionell dicht — `make comment-claims` ist der
Präzedenzfall für einen hermetischen Sensor mit `Makefile`-Ziel, bats-Fall und
`test/mutations/`-Zahn, und dieser Slice folgt ihm.
