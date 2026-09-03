# Review — ADR-0028, fünfte Konsistenzrunde (Nachprüfung der Korrektur `8d28777`)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Architektur, Planung und Implementation |
| **Review-Art** | **Plan-/Design-Review** gegen aktive ADRs, Hard Rules, den Konventionsspeicher und die adoptierte Baseline. **Nicht** DoD-Abhakung (Verifier, Modul 11), **keine** inhaltliche Neubewertung der Entscheidung |
| **Gegenstand** | `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`, Status `Proposed` |
| **Diff dieser Runde** | `8d28777` *„Rolle Architect: ADR-0028 -- die Anlass-Stelle nennt den Nacharbeits-Commit statt einer Praesens-Behauptung"* (2026-09-03 13:29:42 +0200), **eine** Datei, 23 Einfügungen / 2 Löschungen (`git show 8d28777 --stat --format=`) |
| **Auftrag** | Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. Dieser Lauf ist die fünfte ADR-Review-Runde; wer die Korrektur geschrieben hat, prüft sie nicht |
| **Plan** | `slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md` (in `next/`), DoD (1) |
| **Bindende ADRs** | `ADR-0015`, `ADR-0016`, `ADR-0024` (alle `Accepted` — je `grep -m1 '^\*\*Status:\*\*'`) · zur Kohärenz mitgelesen, **nicht bindend**: `ADR-0025`, `ADR-0029` (beide `Proposed`) |
| **Anforderungen / Normen** | `AGENTS.md` §3.1, §3.4, §3.6, §3.7, §3.9 · `MR-025`, `MR-040` · `LH-QA-01`, `LH-QA-02` |
| **Vorherige Findings am gleichen Modul** | Runde 4, Report `2026-09-03-adr-0028-konsistenz-review-runde-4.md` (0 HIGH, 2 MEDIUM, 0 LOW, 2 INFO) — sein **einziger** Befund am ADR-Text war MEDIUM-1 und ist unten einzeln nachgemessen; davor Runde 3, Runde 2, Runde 1 und `2026-08-31-slice-144-review.md` HIGH-1 (der Auslöser). **Alle Reports sind hier bei ihrer Kennung genannt, nicht unter ihrer Adresse** — dieselbe Trennung, die der Gegenstand selbst zieht |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 (Baseline `v5.18.0`) |
| **Modell** | Claude Opus 5 (1M context) |
| **Mess-Basis** | Arbeitsbaum-`HEAD` = `c00006a` (der Report der Vorrunde), Baum sauber (`git status -sb` → nur *voraus 3*). Adoptierte Baseline **`v5.18.0`** (`ls .harness/baseline/` → ein Eintrag). Jede Zahl unten in dieser Sitzung selbst gefahren; **keine Zahl aus der Korrektur oder aus einem Vorgänger-Report übernommen**. Dieses Dokument ist ein **Zeitdokument** und wird nicht nachgezogen |
| **Kontext frisch** | ja — die drei `grep -c 'slice-mv'`-Werte, der `git log -S`-Fund, die Schritt-Grenzen an drei Refs, die elf Verbatim-Proben, die vier `git log`-Werte, der `BEO-007`-Stand, jedes Repo-Zitat und die Struktur sind gegen die Quelle gefahren, nicht gegen die zitierende Stelle |

**Was in diesem Lauf gefahren wurde.** `make docs-check` (**565 Datei(en) geprüft, 0 Befund(e)**,
Exit 0); **jeder in der ADR abgedruckte `sh`-Block wie abgedruckt** (aus der Datei extrahiert und
unverändert ausgeführt, um die eigene Quotierung als Fehlerquelle auszuschließen — die Falle, die
`BEO-021` beschreibt); die Schritt-Grenzen von `implement-slice.md` an `2dc505a`, `7485be3` und
`HEAD`; die §3-Tabellenzeile von `slice-144` an `fc1fc54^`; die Commit-Message von `fc1fc54` und
die Commit-Historie der ADR-Datei; die drei `ADR-0015`- und die zwei `ADR-0024`-Zitate nach
Entfernung der Auszeichnung; `ADR-0016` §Entscheidung im Volltext; das `AGENTS.md`-§3.8-Zitat und
der Auslöser-Report; die Struktur gegen die ADR-Vorlage von `v5.18.0`; die fünf Report-Kennungen
gegen `docs/reviews/`; `BEO-007` und `slice-145`; `ADR-0029`s Tag.
Der Arbeitsbaum wurde nicht verändert; das einzige Schreibprodukt dieses Laufs ist diese Datei.
Ein repo-weiter `make gates`-Lauf gehört zur Verifikation (Modul 11) und ist hier nicht gefahren.

---

## Vorfrage aus dem Auftrag: hat sich seit `8d28777` etwas bewegt, das die ADR zitiert?

**Ein Commit, und er bestätigt die ADR, statt sie zu überholen.** `git log --oneline 8d28777..HEAD`
→ genau `c00006a` *„Rolle Reviewer: ADR-0028 Konsistenz-Review Runde 4 …"*, und er berührt genau
**eine** Datei: den Report der Vorrunde (`git show c00006a --stat --format=`). Kein Artefakt, das
die ADR zitiert, hat sich bewegt: die Baseline steht bei `v5.18.0` (ein Eintrag unter
`.harness/baseline/`), `BEO-007` steht an `HEAD` unverändert bei **4×** mit
`slice-137, slice-144, slice-147, slice-148`, `implement-slice.md` gibt an `HEAD` denselben Wert
wie an der gepinnten Mess-Basis (**3**), und die fünf in der ADR bei ihrer Kennung genannten
Reports existieren jetzt **alle fünf** als Datei — einschließlich des Runde-4-Reports, den die
neue Geschichte-Zeile nennt und der erst mit `c00006a` entstand.

## Nachprüfung: trägt die Korrektur?

**MEDIUM-1 der Runde 4 — behoben, und die Ersetzung ist an drei Ständen nachgefahren.**
Der Vorwurf war eine Präsens-Aussage ohne Ref (*„Schritt 9 und 23 dort verweisen auf den blanken
`git mv`"* / *„Geliefert wurde die Zeile nicht"*). Der Ist-Text sagt jetzt: *„Schritt 9 und 23
**schickten** dort zum blanken `git mv` …, und **am Anlege-Commit dieser ADR** war die Zeile nicht
geliefert. **Nachgetragen hat sie die Nacharbeit `fc1fc54`** …; seither schicken beide Schritte
zum Werkzeug, **an der Mess-Basis oben ebenso**."* Vier Prüfungen, alle selbst gefahren:

| Prüfung | Kommando | Ergebnis |
|---|---|---|
| die drei Werte, **wie abgedruckt** | der `for r in 2dc505a fc1fc54 7485be3`-Block der ADR | **0 · 3 · 3** — zeichengleich zu den drei `#`-Kommentaren |
| an `HEAD` mitgemessen (steht nicht in der ADR) | `git show HEAD:.claude/commands/implement-slice.md \| grep -c 'slice-mv'` | **3** — die Aussage *„seither"* trägt bis heute |
| der Übergang | `git log --format='%h %ai' -S'make slice-mv' 7485be3 -- .claude/commands/implement-slice.md` | **`fc1fc54 2026-08-31 10:11:46 +0200`** — genau die abgedruckte Zeile; an `HEAD` gefahren derselbe einzige Treffer |
| `2dc505a` **ist** der Anlege-Commit | `git log --reverse --format='%h %ai %s' -- <ADR>` | erste Zeile `2dc505a 2026-08-31 09:46:40` — 25 Minuten vor `fc1fc54` |

**Die Zählung ist nicht das Argument, die Verortung ist es — und sie stimmt an allen drei
Ständen.** `grep -c` zählt Zeilen, nicht Schritte; ich habe deshalb die Schritt-Grenzen selbst
gelegt (`grep -nE '^(9|10|23|24)\. '`): An `2dc505a` liegt Schritt 9 bei Zeile 55 (Schritt 10 bei
59) und trägt in Zeile 57 *„Jedes `git mv` ist ein **reiner Move**"*; Schritt 23 liegt bei 126
(Schritt 24 bei 132) und trägt in 129 *„den Slice `in-progress → done` verschieben (`git mv`, …)"*
— die Vergangenheitsform der ADR trifft. An `7485be3` **und** an `HEAD` liegen die `slice-mv`-
Zeilen bei 58 und 142, also in denselben zwei Schritten (Grenzen 55/71 und 138/148) — die
Gegenwartsform trifft ebenfalls, und zwar an beiden Ständen.

**Die Quelle der Aussage trägt sie auch.** `slice-144` §3 führt die Zeile
*„`.claude/commands/implement-slice.md` | update | Schritt 9 und Schritt 23 schicken heute zum
blanken `git mv` …"* (an `fc1fc54^` gelesen); die Commit-Message von `fc1fc54` nennt denselben
Gegenstand als Punkt (1). Der Zeitbezug, den die ADR beim Übernehmen verloren hatte, ist jetzt
nicht als Wort, sondern als **Commit** zurück — das strengere der zwei Mittel, die Runde 4
angeboten hatte.

**Was die Korrektur nicht angetastet hat, und das ist richtig so:** der Kern des Anlasses
(*„… sondern dass er allein entschieden hat, wo keine Quelle die Rolle benennt"*), die drei
Festlegungen, die Alternativen-Tabelle und die Konsequenzen sind byte-gleich geblieben
(`git diff 8d28777^ 8d28777` berührt §Der Anlass und **eine** neue Geschichte-Zeile, sonst nichts).
Eine Korrektur, die den Befund behebt und den Rest anfasst, wäre der teurere Weg gewesen.

---

## Findings

### MEDIUM-1 — Der Slice, der die Annahme trägt, rechnet unverändert mit `BEO-007` bei 1×; die Zeile steht bei 4× und führt einen dreigeteilten Ausgang

- **kategorie:** MEDIUM
- **quelle:** `MR-025` Setzung 1; Modul 6 §Das Beobachtungs-Register (Sichtungs-Schritt)
- **pfad:** `docs/plan/planning/done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md:113`
  und `:230`
- **befund:** Der Plan sagt in §2 DoD *„…1×)"* und in §8 *„`BEO-007` steht im Register
  (Sub-Area `*`, 1×, …)"*. Gemessen steht die Zeile an `HEAD` bei **4×** mit vier Belegen
  (`awk -F'|' '$2 ~ /BEO-007/{print $5, $6}' docs/plan/planning/observations.md` →
  ` 4×   slice-137, slice-144, slice-147, slice-148`) und führt ihren Ausgang bereits
  **dreigeteilt**: Command-Artefakte → `ADR-0028` (Annahme trägt `slice-145`) ·
  `.claude/agents/*.md` → `ADR-0029` (Annahme trägt `slice-152`) · Spec-Straten → `slice-151`.
  Der Plan ist seit der Vorrunde inhaltlich nicht angefasst worden
  (`git log --oneline -1 -- <plan>` → `0146108`, ein `welle-mv`-Verweis-Nachzug).
  **Failure-Szenario:** Der Closure-Lauf des Slice schreibt die `Stand`-Zelle gegen einen
  Zähler-Stand, den er falsch annimmt, und setzt die Zeile auf *verkörpert*, obwohl zwei ihrer
  drei Teile offen bleiben — genau das, wovor der zweite Positiv-Punkt der ADR warnt.
  **Abgrenzung:** Hängt **nicht** am ADR-Text und blockiert den Statuswechsel nicht. Der ADR-Text
  ist an dieser Stelle korrekt: er nennt 4×, trennt die drei Teile und sagt ausdrücklich
  *„Welchen Ausgang die Registerzeile am Ende trägt, entscheidet die Closure, die sie schreibt —
  nicht diese ADR."* Adressat ist der **Planner**.
- **verifizierbar:** ja — `grep -n '1×' <plan>` gegen das `awk` oben. Kein Gate.
- **klasse:** „Slice-Plan rechnet mit einem Register-Zähler, den das Register nicht mehr trägt"
  (**fünfter** Lauf mit demselben Befund)

### LOW-1 — Die neue Geschichte-Zelle sagt, die fünf Befunde der Vorrunde seien „behoben"; behoben sind vier, und den fünften führt dieselbe Zelle drei Zeilen später als offen

- **kategorie:** LOW
- **quelle:** interne Widerspruchsfreiheit; `AGENTS.md` §3.4 (die Zelle wird mit `Accepted` eingefroren)
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:467`
- **befund:** Die Zeile vom 2026-09-03 (Runde 4) eröffnet mit *„die fünf Befunde der Vorrunde sind
  einzeln nachgemessen und **behoben**"*. Runde 3 hatte gemessen fünf Befunde
  (`grep -n '^### ' <report-runde-3>` → HIGH-1, MEDIUM-1, LOW-1, LOW-2, INFO-1; Kategorie-Summary
  1/1/2/1). **Vier** davon sind behoben; der fünfte — INFO-1, der abgelöste Tag in `ADR-0029` —
  ist es nicht: er betrifft eine andere Datei, wurde von Runde 4 als *unverändert* geführt und
  kehrt dort als INFO-2 wieder. Dieselbe Zelle sagt drei Zeilen weiter über eben diesen Punkt
  *„**INFO-2** [ADR-0029]; keiner ist hier behoben"*. Gemessen steht `ADR-0029` weiterhin allein
  auf dem abgelösten Stand (`grep -o 'v5\.[0-9]*\.[0-9]*' docs/plan/adr/0029-*.md | sort | uniq -c`
  → `1 v5.12.0`).
  **Failure-Szenario:** Mit `Accepted` friert §3.4 die Zelle ein. Ein späterer Lauf, der Runde 3
  gegen diese Zeile hält, liest *fünf behoben*, findet in `ADR-0029` den abgelösten Tag und kann
  nicht entscheiden, ob der Punkt behoben und wieder aufgebrochen ist oder ob die Zelle
  überzählt. Die drei Vorgänger-Zeilen derselben Tabelle lösen genau diesen Fall sauber — sie
  schließen die nicht behobenen ausdrücklich aus (*„**INFO-1** betrifft ADR-0029 …; beide sind
  hier nicht behoben"*); die neue Zeile bricht mit dieser Praxis. Die Reparatur ist **jetzt** ein
  Wort und **nach** der Annahme eine Folge-ADR.
  **Abgrenzung:** Trifft weder eine Festlegung noch einen Beleg noch eine Prämisse; die Zelle ist
  Provenienz, kein Zustandsfeld (`AGENTS.md` §3.7 ist nicht berührt — das `**Status:**`-Feld trägt
  den Zustand und sonst nichts).
- **verifizierbar:** ja, **nicht durch ein Gate** — `grep -m1 '^modules:' .d-check.yml` →
  `modules: [links, anchors, ids, matrix, codepaths, spans]`; keines zählt Befunde eines Reports.
  Bestätigt durch `grep -n '^### ' docs/reviews/2026-09-03-adr-0028-konsistenz-review-runde-3.md`
  (fünf Überschriften) gegen die Nachprüfungs-Tabelle der Runde 4 (INFO-1 → *unverändert*).
- **klasse:** „Provenienz-Zelle fasst das Ergebnis einer Prüfrunde weiter, als die Prüfrunde es
  ausweist"

### LOW-2 — Das neu aufgenommene Commit-Subject ist in Anführungszeichen gekürzt, ohne die Auslassung zu markieren, die dasselbe Dokument zwei Absätze weiter setzt

- **kategorie:** LOW
- **quelle:** interne Widerspruchsfreiheit (die eigene Zitier-Praxis derselben Datei);
  `AGENTS.md` §3.4
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:52`
- **befund:** Die Stelle zitiert *„slice-144: Nacharbeit -- fehlender Liefergegenstand
  nachgezogen"*. Das reale Subject ist länger: `git log -1 --format=%s fc1fc54` →
  `slice-144: Nacharbeit -- fehlender Liefergegenstand nachgezogen, Selbsttest-Name korrigiert`.
  Die Kürzung ist inhaltlich harmlos — der weggelassene Teil betrifft einen zweiten Gegenstand
  desselben Commits —, aber sie ist nicht markiert, während dieselbe Datei für denselben Fall die
  Ellipse führt: `20a3e33` *„Rolle Architect: …"* (Zeile 191).
  **Failure-Szenario:** Ein späterer Lauf hält das Zitat gegen `%s` und bekommt Ungleichheit; er
  kann nicht unterscheiden, ob der Commit umgeschrieben (`rebase`/`amend`) oder das Zitat gekürzt
  wurde. Nach `Accepted` ist ein Zeichen — die Ellipse — nur noch über eine Folge-ADR erreichbar.
  **Abgrenzung, damit der Befund nicht überzogen wird:** `ADR-0016` Festlegung 2 bindet den Beleg
  einer **Regelwerks-Aussage** (Tag · Dateiname/Abschnittsname · Zitat verbatim) — ein
  Commit-Subject ist keiner, und die Festlegung wird hier **nicht** verletzt. Der Anker ist die
  Praxis der Datei selbst, nicht eine Norm.
- **verifizierbar:** ja, kein Gate — `git log -1 --format=%s fc1fc54` gegen die zitierte
  Zeichenkette; `grep -n 'Rolle Architect: …' <ADR>` zeigt die abweichende Praxis derselben Datei.
- **klasse:** „Zitat gekürzt ohne Auslassungszeichen, in einem Artefakt, das eingefroren wird"

### INFO-1 — Die Mess-Basis-Klausel nennt eine **geschlossene** Ausnahmen-Menge („zwei Zahlen"); gepinnt sind inzwischen mehr Zahlen als sie führt, nur nicht alle an `7485be3`

- **kategorie:** INFO
- **quelle:** Maintainability; `MR-025` Setzung 2
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:30-37`
- **befund:** Die Klausel sagt *„Jede Zahl unten über den wandernden Repo-Bestand ist gegen den
  Commit `7485be3` gefahren und nennt ihn im Kommando"* und nimmt **zwei** Zahlen namentlich aus.
  Der neue Block bringt zwei weitere Werte, die nicht an `7485be3` gemessen sind (**0** an
  `2dc505a`, **3** an `fc1fc54`) und nicht zu den zwei genannten Ausnahmen zählen. Dieselbe
  Eigenschaft hat der ältere `git show b39d4ff --stat --format=`-Block (Werte **8** und **8**) —
  die Klausel war also schon vor der Korrektur enger als die Praxis der Datei; **die Korrektur
  hat die Klasse nicht eingeführt**, nur ihre Instanzenzahl erhöht.
  **Warum das kein Befund höherer Ordnung ist:** Der Zweck der Klausel — kein Wert, der nach
  `Accepted` mitwandert — ist vollständig erfüllt. Jeder der Werte ist an einen **festen Commit**
  gebunden, der im Kommando oder im Kommentar daneben steht, und jeder ist in diesem Lauf
  zeichengleich reproduziert worden. Was fehlt, ist die Aussage, dass *ein* fester Commit genügt
  und `7485be3` nur der Regelfall ist — eine undokumentierte Annahme, kein Widerspruch.
- **verifizierbar:** ja, kein Gate — die extrahierten `sh`-Blöcke der Datei, wie abgedruckt
  gefahren; jeder Wert reproduziert.
- **klasse:** „Blanket-Klausel mit geschlossener Ausnahmen-Menge, die die eigene Praxis der Datei
  überholt hat"

### INFO-2 — `ADR-0029` steht unverändert mit dem abgelösten Tag da

- **kategorie:** INFO
- **quelle:** Maintainability; `ADR-0016` Festlegung 3 (a)
- **pfad:** `docs/plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md`
- **befund:** Dritter Lauf mit demselben Posten, hier nur als *weiterhin offen* geführt: die
  zweite `Proposed`-ADR derselben Familie nennt im ganzen Dokument **einen** Tag, und es ist
  `v5.12.0` (`grep -o 'v5\.[0-9]*\.[0-9]*' docs/plan/adr/0029-*.md | sort | uniq -c` →
  `1 v5.12.0`; kein Erwartungswert). Sie stützt sich in Festlegung 1 auf `ADR-0028` und steht vor
  demselben Übergang und derselben Vorbedingung. Kein Vorwurf an `ADR-0028`; Gegenstand des Laufs,
  der `slice-152` trägt.
- **verifizierbar:** ja — das `grep -o | sort | uniq -c` oben.
- **klasse:** „Baseline-Beleg gegen einen abgelösten Stand in einem Artefakt, das eingefroren
  werden soll" (Wiederholung im Geschwister-Artefakt)

### INFO-3 — Die geregelte Klasse ist seit der Mess-Basis erneut aufgetreten; der Cutoff deckt sie, Re-Evaluierungs-Trigger 4 zählt sie nicht

- **kategorie:** INFO
- **quelle:** Maintainability; `ADR-0028` §Cutoff und Re-Evaluierungs-Trigger 4
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:185-194`
- **befund:** §Kontext sagt an der gepinnten Basis korrekt *„Der eine Treffer ist `20a3e33`"*
  (`git log --format='%s' 7485be3 -- .claude/commands/ | wc -l` → **13**, `| grep -c '^Rolle '`
  → **1** — beide selbst gefahren, beide zeichengleich). An `HEAD` stehen dieselben zwei
  Kommandos bei **14** und **2**. **Kein Vorwurf an die ADR:** ihre Werte sind gepinnt, als *keine
  Erwartungswerte* gekennzeichnet und an ihrer Basis exakt; der Cutoff (*„geprüft wird ab dem
  Commit, der diese ADR annimmt"*) deckt den Fall ausdrücklich. Die Beobachtung ist für den
  Planner: die Lücke, die die ADR schließt, wirkt zwischen Entwurf und Annahme weiter.
- **verifizierbar:** ja — die vier `git log`-Läufe an `7485be3` und an `HEAD`.
- **klasse:** „Regelungsbedürftige Klasse tritt zwischen Entwurf und Annahme erneut auf"

## Negativbefunde

- **Prüfpunkt 1 — der korrigierte Absatz, an drei Ständen:** geprüft, **kein Befund**. Siehe
  §Nachprüfung: `0 · 3 · 3` wie abgedruckt, `fc1fc54 2026-08-31 10:11:46 +0200` wie abgedruckt,
  `2dc505a` als erster Commit der ADR-Datei bestätigt, und die Schritt-Grenzen an allen drei Refs
  selbst gelegt statt aus der Zeilenzahl gefolgert. Die Aussage *„seither …"* ist zusätzlich an
  `HEAD` mitgemessen (**3**) und trägt.
- **Prüfpunkt 2 — Fundmenge statt Fundort: gibt es eine zweite Stelle derselben Klasse?**
  geprüft, **kein Befund**. Ich bin den Volltext auf Präsens-Aussagen über repo-eigene *lebende*
  Artefakte durchgegangen. Jede trägt eine Ref, einen festen Commit oder ein Zeitwort: die
  Datei-Menge und die drei Eröffnungssätze laufen gegen `7485be3` (`git ls-tree -r --name-only
  7485be3 -- .claude/commands .harness/skills` → genau die vier Dateien der Anwendungs-Tabelle;
  `git grep -n 'Dieser Command führt die' 7485be3 -- .claude/commands/` → **je `:5`**); die
  Typkarten-Aussage steht als *„Stand des Commits"*; `20a3e33` und `b39d4ff` sind feste Commits
  (`git show b39d4ff --stat --format=` gibt die zwei abgedruckten Zeilen zeichengleich); die
  `MR-018`/`MR-021`/`MR-030`-Kette steht unter *„ist **heute** überholt"*; *„AGENTS.md §3.8 zeigt
  **heute** auf ADR-0024"* und *„Die **heute** lebenden Dateien"* tragen das Zeitwort — beide
  `AGENTS.md`-Aussagen nachgemessen (`grep -c 'ADR-0024' AGENTS.md` → **1**,
  `grep -c 'ADR-0028' AGENTS.md` → **0**); die Register-Übernahme ist in §Mess-Basis geregelt.
  **Die Klasse, die vier Runden lang blockiert hat, ist damit geschlossen.**
- **Prüfpunkt 3 — die elf Verbatim-Proben, wie abgedruckt:** geprüft, **kein Befund**. Der
  `sh`-Block wurde aus der Datei extrahiert und unverändert ausgeführt; **alle elf geben 1**.
  Die Kopf-Zählung stimmt: `awk '/^## Verbatim-Proben/,/^## Geschichte/' <ADR> | grep -c '^tr '`
  → **11** bei zehn belegten Aussagen (Probe 1+2 belegen dieselbe, von Hand gegen die
  Belegstellen gezählt). Kein Markdown-Link zeigt in den vendored Baum
  (`grep -c ']([^)]*\.harness/baseline/' <ADR>` → **0**).
- **Prüfpunkt 4 — Widerspruch zu `ADR-0015`, `ADR-0016`, `ADR-0024` (alle `Accepted`):** geprüft,
  **kein Befund**. Festlegung 2 weist den ausgenommenen Teil keiner Rolle zu und deckt sich mit
  `ADR-0015`s Selbstverengung (beide Zitate treffen je **1**). `ADR-0024` hat einen anderen
  Gegenstand (Register ↔ Anweisungssatz); sein Mess-Basis-Zitat trifft nach Entfernen der
  Auszeichnung in beiden Fragmenten je **1**, und es steht tatsächlich in dessen §Geschichte
  (`awk '/^## Geschichte/{f=1} f' <ADR-0024> | grep -c 'statt im selben Zug zu veralten'` → **1**).
  `ADR-0016` Festlegung 2/3 sind eingehalten (Prüfpunkt 3), Festlegung 4 ist in der `Bezug:`-Zeile
  richtig als Gegenrichtung bezeichnet. Kein `Supersedes` nötig, keiner behauptet.
  **Methodischer Hinweis:** zwei dieser Zitate gaben mir im ersten Lauf **0** — Ursache war meine
  eigene Prüfung (Auszeichnung der Quelle nicht entfernt, Initial-Großschreibung), nicht die ADR.
  Genau die Fehlerrichtung, die `BEO-021` beschreibt; roh nachgefahren geben beide **1**.
- **Prüfpunkt 5 — die zwei Prämissen des Anlasses:** geprüft, kein Befund. Das
  `AGENTS.md`-§3.8-Zitat steht dort in beiden Teilen je **1** mal, und der auslösende Report
  (`2026-08-31-slice-144-review.md`) existiert, führt ein HIGH-1 und trägt dasselbe Zitat.
- **Prüfpunkt 6 — Report-Verweise:** geprüft, kein Befund. `grep -c 'docs/reviews' <ADR>` → **0**;
  alle **fünf** genannten Kennungen lösen gegen `docs/reviews/` auf, einschließlich der neu
  genannten Runde-4-Kennung.
- **Prüfpunkt 7 — die tragende Negativ-Prämisse gegen den heute bindenden Stand:** geprüft, **sie
  trägt**. `grep -rl 'claude/commands' .harness/baseline/v5.18.0/` → **eine** Datei,
  `grundlagen-durchsetzungsschicht.md`. Re-Evaluierungs-Trigger 1 hat **nicht** gefeuert.
- **Prüfpunkt 8 — `LH-QA-01` (keine halluzinierten Gates):** geprüft, kein Befund. §Fitness
  Function behauptet ausdrücklich **kein** Gate; die aufgezählten Module sind deckungsgleich mit
  `grep -m1 '^modules:' .d-check.yml` → `[links, anchors, ids, matrix, codepaths, spans]`, und
  beide genannten `mutate`-Fehlschlag-Formen stehen im Werkzeug (`grep -c -- '--- FAIL:'
  harness/tools/mutate.sh` → **2**, `grep -c 'not ok'` → **2**). Der `LH-QA-01`-Anker existiert
  (`spec/lastenheft.md:320`).
- **Prüfpunkt 9 — Ziel-Form der ADR-Vorlage (`v5.18.0`):** geprüft, kein Befund. Kopf (`Status`,
  `Datum`, `Autor`, `Bezug`, `Schärft`) und alle sieben Pflicht-Abschnitte stehen in der
  Vorlagen-Reihenfolge; §Verbatim-Proben ist ein **Anhang vor** §Geschichte, kein Ersatz. Der
  Immutabilitäts-Schlusssatz steht und nennt `v5.18.0`. Der ADR-Index führt die Zeile mit Status
  `Proposed` (`docs/plan/adr/README.md:35`) — er ist nach dem Statuswechsel nachzuziehen.
- **Prüfpunkt 10 — `AGENTS.md` §3.7 (Zustandsfeld trägt keine Chronik):** geprüft, kein Befund.
  Das `**Status:**`-Feld trägt den Zustand und sonst nichts; die Geschichte-Tabelle ist der von
  der Vorlage vorgesehene Provenienz-Ort, kein Zustandsfeld und kein lebendes Register.
- **Prüfpunkt 11 — `AGENTS.md` §3.9 (Docker-only):** eingehalten. Der einzige Toolchain-Lauf
  dieses Reviews ist `make docs-check`; alles Übrige sind `git`, `grep`, `awk`, `sed`, `tr`.
- **Prüfpunkt 12 — Doku-Gate nach der Korrektur:** geprüft, **grün**. `make docs-check` →
  `d-check: 565 Datei(en) geprüft, 0 Befund(e)`, Exit 0.
- **Prüfpunkt 13 — Rollen-Konflikt:** geprüft, keiner. Kein Finding dieses Laufs widerspricht
  einer Position, die der Architect-Lauf vertreten hätte; die Korrektur `8d28777` ist in der
  Sache bestätigt. Der Konflikt-Pfad aus Modul 8 ist **nicht** auszulösen.
- **Nicht geprüft (bewusst außerhalb dieses Laufs):** der **Inhalt** der drei Commands, der
  Skill-Datei und der sechs Typkarten; die DoD-Abhakung und der repo-weite Gate-Lauf von
  `slice-145` (Verifier, Modul 11); die innere Konsistenz von `ADR-0029` (eigener Gegenstand,
  eigener Lauf); die **Form** der `Stand`-Zelle von `BEO-007` (Planner-Artefakt — hier nur auf
  Zähler und Belege gelesen); `make gates` als Ganzes.

## Kategorie-Summary

- HIGH: 0
- MEDIUM: 1 — **am Planner-Artefakt, nicht am ADR-Text**
- LOW: 2 (beide am ADR-Text, beide nicht-blockierend)
- INFO: 3

**Finding-Klassen dieses Laufs (für die Slice-Closure §7 und den Zähler):**
„Slice-Plan rechnet mit einem Register-Zähler, den das Register nicht mehr trägt" (5×) ·
„Provenienz-Zelle fasst das Ergebnis einer Prüfrunde weiter, als die Prüfrunde es ausweist" ·
„Zitat gekürzt ohne Auslassungszeichen, in einem Artefakt, das eingefroren wird" ·
„Blanket-Klausel mit geschlossener Ausnahmen-Menge, die die eigene Praxis der Datei überholt hat" ·
„Baseline-Beleg gegen einen abgelösten Stand in einem Artefakt, das eingefroren werden soll" ·
„Regelungsbedürftige Klasse tritt zwischen Entwurf und Annahme erneut auf".

**Die Klammer der vier Vorrunden ist geschlossen.** Runde 1: den Baseline-Belegen fehlte der Tag.
Runde 2: der Tag war ein anderer geworden. Runde 3: ein Beleg trug eine Ordnungszahl statt des
Zitats, ein Register-Zitat hatte keine Basis. Runde 4: die letzte Aussage ohne Ref und ohne
Zeitwort war falsch. Alle vier trugen dieselbe Ursache — *eine Aussage über einen wandernden
Bestand wird in dem Moment eingefroren, in dem niemand sie mehr korrigieren darf.* In diesem Lauf
findet sich **keine** Instanz dieser Klasse mehr: Prüfpunkt 2 ist die Fundmengen-Prüfung, nicht
eine Stichprobe. Die zwei LOWs sind **nicht** dieselbe Klasse — sie treffen die Zitier- und
Zähl-Form der Datei, nicht die Haltbarkeit einer Aussage über einen wandernden Bestand.
**Der Steering-Loop-Posten der Vorrunde bleibt gleichwohl fällig und gehört dem Planner:** für die
Präsens-Aussage über eine **repo-eigene lebende** Datei benennt weiterhin keine Quelle eine Form
(`ADR-0016` bindet Baseline-Belege, `MR-040` den vendored Baum, `MR-025` Zahlen), und eine
Registerzeile dafür existiert nicht. Dass die ADR die Klasse jetzt vermeidet, ist eine Eigenschaft
dieser Datei, kein Träger.

## Verdikt

**Konsistenz BESTÄTIGT. Kein inhaltlicher Einwand, kein Befund am ADR-Text, der den Übergang
blockiert. Der Statuswechsel `Proposed` → `Accepted` ist aus Reviewer-Sicht freigegeben.**

Das ist der Freigabe-Punkt, und ich sage ihn ausdrücklich, weil der Auftrag ihn benennt.
Begründung in drei Teilen:

1. **Die Korrektur trägt, selbst nachgemessen statt abgehakt.** Der einzige Befund der Vorrunde am
   ADR-Text ist behoben, und zwar mit dem strengeren der zwei angebotenen Mittel: statt eines
   Zeitworts stehen drei feste Commits und zwei nachfahrbare Kommandos. Alle drei Werte
   reproduzieren zeichengleich (`0 · 3 · 3`), der `git log -S`-Fund ebenso, `2dc505a` ist als
   Anlege-Commit bestätigt, und die tragende Verortung — *Schritt 9 und 23* — ist an allen drei
   Ständen über die Schritt-Grenzen geprüft, nicht aus einer Zeilenzahl gefolgert. Die Aussage
   hält zusätzlich an `HEAD`.
2. **Nichts hat sich bewegt, das die ADR zitiert.** Zwischen `8d28777` und `HEAD` liegt genau ein
   Commit, und er legt den Report der Vorrunde ab — die einzige von der ADR genannte Kennung, die
   vorher keine Datei hatte. Baseline, Register-Stand und `implement-slice.md` stehen unverändert.
3. **Der Rest der Prüfung hält gegen den heute bindenden Stand.** Elf Verbatim-Proben je **1**,
   alle gepinnten Zahlen an ihrer Basis exakt, kein Widerspruch zu `ADR-0015`, `ADR-0016` oder
   `ADR-0024`, Festlegung 3 nicht zirkulär, die tragende Negativ-Prämisse gehalten, `LH-QA-01`
   gewahrt, Struktur vollständig, `make docs-check` grün.

**Was ich empfehle, ohne es zur Bedingung zu machen:** Die zwei LOWs kosten im `Proposed`-Fenster
je ein bis zwei Zeichen und nach `Accepted` je eine Folge-ADR (`AGENTS.md` §3.4) — LOW-1 ein Wort
in der neuen Geschichte-Zelle, LOW-2 eine Ellipse. Wer sie zieht, tut es in einem eigenen
Architect-Commit; der Gegenstand einer Nachprüfung wären dann genau diese zwei Zellen, keine
sechste Vollrunde. Wer sie stehen lässt, nimmt zwei benannte, nicht-tragende Ungenauigkeiten in
Kauf — beide berühren weder eine Festlegung noch einen Beleg noch eine Prämisse.

**Ein Posten adressiert den Planner, nicht den Architect:** MEDIUM-1 (`slice-145` rechnet mit
`BEO-007` bei 1×, fünfter Lauf mit demselben Befund). Er blockiert die Annahme **nicht**, aber er
blockiert die *Closure*: Der Slice, der die Annahme trägt, schreibt bei unverändertem Plan eine
`Stand`-Zelle gegen einen Zähler-Stand, den das Register nicht mehr trägt. Dazu der
Steering-Loop-Posten aus der Kategorie-Summary.

**Übergabe.** Adressat der Freigabe ist der **Architect** als Rolleninhaber von DoD (1) des
`slice-145`; dieser Report ist das Übergabe-Artefakt. Mit dem Statuswechsel werden die
Folgepflichten der ADR fällig — Folgepflicht 1 (der `AGENTS.md`-§3.8-Zeiger, heute gemessen
**nicht** gesetzt) und der ADR-Index, der die Zeile weiterhin als `Proposed` führt.

**Dieser Report ersetzt keine Verifikation** — DoD-Abhakung und repo-weiter Gate-Lauf prüft der
Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
