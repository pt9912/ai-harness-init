# ADR-0022 (Proposed) — Bestätigungsrunde auf die Erweiterungsrunde

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-23. **Lauf:** frischer Subagent, eigener
Kontext.

**Anlass.** Die Erweiterungsrunde (`2026-08-23-adr-0022-erweiterungsrunde.md`, Diff
`4fcc141..bb65edd`) fand 0 HIGH · 4 MEDIUM · 1 LOW · 1 INFO, Verdikt *blockiert*. Der schreibende
Kontext — wieder der Haupt-Kontext, nicht ein frischer Architect-Subagent — hat die sechs Findings
in zwei getrennten Commits nachgezogen. Diese Runde prüft, ob die Behebung trägt: **kein
Voll-Review**, die sechs Vorrunden vor der Erweiterungsrunde werden nicht neu aufgerollt.

**Gegenstand:** `4302b5b..eaf5d0f`, zwei Commits:

- `d1f7c36` — Nachzug MEDIUM-1 bis MEDIUM-4 (`docs/plan/adr/0022-…md` + `docs/plan/adr/README.md`,
  +30/−18, selbst gemessen: `git show --stat d1f7c36` → genau diese Zahlen, genau diese zwei
  Dateien)
- `eaf5d0f` — Nachzug LOW-1 und INFO-1 (`docs/plan/adr/0022-…md`, +2/−2, selbst gemessen: `git show
  --stat eaf5d0f` → genau diese Zahlen, genau diese eine Datei)

`git diff --name-status 4302b5b..eaf5d0f` → `M` auf genau `docs/plan/adr/0022-…md` und
`docs/plan/adr/README.md`. `git status --porcelain` → leer. Status im ADR-Kopf weiter *Proposed*.
Beide Commit-Messages beginnen mit *„Rolle Architect:"* (§3.8).

## Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan-Bezug)

1. **Diff/Commit-Range:** `4302b5b..eaf5d0f`, zwei Commits, zwei berührte Dateien insgesamt (oben
   gemessen).
2. **Betroffene Anforderungen:** `LH-FA-10` (Rang 1), `LH-FA-01`, `LH-QA-01`, `LH-QA-02`,
   `LH-QA-03`, `LH-QA-04` — unverändert gegenüber der Erweiterungsrunde.
3. **Referenzierte aktive ADRs:** `ADR-0003`, `ADR-0007`, `ADR-0011`, `ADR-0016`, `ADR-0020`,
   `ADR-0021` — alle *Accepted*; `ADR-0020`/`ADR-0021` byte-identisch zum Vorzustand geprüft
   (`git diff --stat 4302b5b..eaf5d0f -- docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` → leer,
   Exit 0).
4. **Hard Rules:** `AGENTS.md` §3.4 (Immutabilität), §3.6 (kein Halluzinat), §3.7 (keine
   Review-Geschichte im Artefakt), §3.8 (Architect-Commit); `MR-025`.
5. **Vorherige Findings am gleichen Modul:** die Erweiterungsrunde (0 HIGH/4 MEDIUM/1 LOW/1 INFO,
   *blockiert*) ist der unmittelbare Auftrag dieser Runde. Die vier Vorrunden davor (1 HIGH/2
   MEDIUM/5 LOW/4 INFO → 0/0/0/0 in der Schlussrunde) werden nicht neu aufgerollt.
6. **Plan-Bezug:** keiner — Entscheidung, kein Slice.

## Selbst gefahren — Kommando und Ergebnis

| Kommando | Ergebnis |
|---|---|
| `git show --stat d1f7c36` / `git show --stat eaf5d0f` | +30/−18 (zwei Dateien) bzw. +2/−2 (eine Datei) — deckt die Auftrags-Angabe |
| `git diff --stat 4302b5b..eaf5d0f -- docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` | leer, Exit 0 — §3.4 hält |
| `git diff --name-status 4302b5b..eaf5d0f` | `M` auf genau zwei Dateien, beide im ADR-Stratum — §3.8 |
| `grep -n "löst Annahme" docs/plan/adr/0022-…md` | genau **ein** Treffer, negiert ("löst Annahme (a) **nicht** von selbst") — die zwei alten Positiv-Behauptungen (Zeilen 206, 598 alt) sind weg |
| `grep -n "der Weg, der sie ohne diese Annahme beantwortet, ist Alternative H" docs/plan/adr/0022-…md` gegen `git show 4302b5b:…` an derselben Zeile | **byte-identisch**, Zeile 341 in beiden Ständen — **nicht** vom Nachzug berührt (siehe MEDIUM-A) |
| `grep -rnE 'GOOS\|GOARCH\|runtime\.\|platform' internal/fetch/baseline.go` | leer, Exit 1 — MEDIUM-2 hält |
| `awk`/`sed`-Zeilenzählung der Abzählungs- und der Alternativen-Tabelle | je 13 Zeilen (Header+Trenner+**11** Datenzeilen) — deckt die neu in den Index übernommene "elf Wege"-Behauptung |
| Klassen-Spalte der Abzählungstabelle gelesen | vier Werte: `liegt vor`, `entsteht im Ziel`, `wird geholt`, (`keines` für K) — deckt "vier Herkunfts-Klassen" |
| `grep -n "LH-QA-03\|LH-FA-01" docs/plan/adr/0022-…md` um die J-Zeile und um Festlegung 1 | J zitiert jetzt denselben Anker (`LH-QA-03`) wie Festlegung 1 für dieselbe Aussagenklasse — MEDIUM-3 hält |
| `sed -n '330,332p' spec/lastenheft.md` (LH-QA-03 Wortlaut) | "Laufzeit beim Bootstrap braucht nur git+docker … Ziel-Repos bleiben make/docker-getrieben" — trägt die Paraphrase "das Ziel netzlos hält" |
| `grep -qF` als Here-String: `„Spans liegen außerhalb des versionierten Baums, und das ist Korrektheit"` gegen `docs/plan/adr/0011-…md` | `FOUND` — INFO-1s Zitat ist verbatim |
| `grep -qF "ginge in den Gate-Hash ein"` gegen dieselbe Quelle | `MISSING` — dieser Halbsatz steht in der ADR-0022-Zeile **außerhalb** der Anführungszeichen, ist also als eigene Paraphrase markiert, nicht als Zitat; die zugrundeliegende ADR-0011-Aussage ("Ein Span-File im Arbeitsbaum ginge in diesen Hash ein") deckt sie inhaltlich |
| `grep -n "Aufschlag je Tool-Call\|Folgepflicht 9" docs/plan/adr/0022-…md` | J nennt jetzt "ungemessen" + Verweis auf denselben Nachbarn (G, Folgepflicht 9) — LOW-1 hält |
| `git show eaf5d0f -- docs/plan/adr/0022-…md` | reine Zeilen-Ersetzung (I- und J-Zeile), keine Duplikate, kein Wachstum neben dem Alten |
| `grep -niE 'runde\|HIGH-[0-9]\|MEDIUM-[0-9]\|LOW-[0-9]\|INFO-[0-9]\|hier stand\|erweiterungsrunde\|bestätigungsrunde' docs/plan/adr/0022-…md` | ein Treffer, Wortbestandteil "reviewer" in der kanonischen Sechser-Rollenliste (`emit.go`-Zitat) — kein Review-Geschichte-Leck |
| `grep -niE 'slice-[0-9]\|welle-[0-9]' docs/plan/adr/0022-…md docs/plan/adr/README.md` | ein Treffer, ein Dateipfad innerhalb eines Kommandos (unverändert seit Erweiterungsrunde), keine neue Slice-ID als Anker |
| `grep -n "kein neuer Mechanismus\|keine neue Abhängigkeit"` | leer — keine der beiden alten Überzeichnungen ist irgendwo stehengeblieben |
| `make docs-check` | `d-check: 356 Datei(en) geprüft, 0 Befund(e)` — deckt beide Commit-Messages |
| `make gates` | Exit 0; `grep -c '^ok '` → **143**; `grep -c '^not ok '` → **0**; letzte Zeile `span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert`; `grep -n comment-claims` im Log → `comment-claims: 40 Datei(en) geprueft, 0 Befund(e)` — deckt die "comment-claims 40/0"-Behauptung aus `d1f7c36` |

---

## Findings

### MEDIUM-A — die Fixierung von MEDIUM-1 (Vorrunde) traf drei von vier Fundorten; der vierte widerspricht jetzt der neuen Aussage

**Quelle:** dieselbe Kern-Behauptung wie MEDIUM-1 der Erweiterungsrunde ("H löst Annahme (a) auf"),
an einer vierten Stelle, die der Nachzug nicht berührt hat.

**Pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:341` (Satz
unverändert seit `4302b5b`, byte-identisch geprüft) gegen `:351` (drei Zeilen tiefer, aus `d1f7c36`
neu).

**Befund:** Zeile 341 lautet unverändert: *„Der Trigger unten sagt darum nicht 'dann F', sondern
stellt die Plattform-Frage neu; **der Weg, der sie ohne diese Annahme beantwortet, ist Alternative
H**."* Drei Zeilen später, im selben Absatz-Block, sagt der neu gefasste Text (aus `d1f7c36`) das
Gegenteil: *„H verschiebt die Frage von 'läuft das Bild hier?' zu 'wer sagt, wofür es abgelegt
wird?' — sie wird damit **stellbar, nicht beantwortet**."* Beide Sätze stehen jetzt nebeneinander
im Dokument und behaupten Gegensätzliches über denselben Sachverhalt: der eine, dass H die
Plattform-Frage **beantwortet**, der andere, dass H sie ausdrücklich **nicht** beantwortet, nur
stellbar macht. Der Nachzug hat die drei von der Vorrunde explizit zitierten Stellen (Members-Zeile
:206, den Abwägungsabsatz "Warum G und nicht H" :343ff., die Trigger-Zeile in den Konsequenzen
:754ff.) korrekt und konsistent auf "stellbar, nicht beantwortet" umgestellt — aber der
vorgelagerte Absatz "Was Annahme (a) trägt und was nicht" (:338–341), der dieselbe Formulierung
("beantwortet") in seinem Schlusssatz führt, blieb unangetastet. Das Ergebnis ist kein bloß
unvollständiger Fix mehr, sondern ein **neuer, durch den Fix selbst erzeugter** Widerspruch: vor der
Korrektur behaupteten alle vier Stellen konsistent dasselbe (überzeichnet); nach der Korrektur
behaupten drei Stellen das Richtige und eine das Gegenteil, direkt benachbart.

**Verifizierbar:** nein (Text-Konsistenzprüfung, kein Gate). Prüfbar durch Gegenlesen von Zeile
341 gegen Zeile 351 — beide sprechen über dasselbe Subjekt ("der Weg, der die Annahme
[be]antwortet, ist H") mit entgegengesetztem Prädikat.

---

## Bestätigte Behebungen (die sechs Punkte des Auftrags)

- **MEDIUM-1 (Erweiterungsrunde) — teilweise behoben, siehe MEDIUM-A.** Die drei explizit
  zitierten Fundorte (Members-Zeile, Abwägungsabsatz, Trigger-Zeile) tragen jetzt konsistent
  "stellbar, nicht beantwortet" und benennen `LH-FA-01` korrekt als die Stelle, die eine
  Plattform-Angabe "in keinem seiner Akzeptanzkriterien" kennt — das trägt: `LH-FA-01`s drei
  Akzeptanzkriterien (Happy Path Init, Happy Path One-Shot, Idempotenz) sprechen tatsächlich an
  keiner Stelle über eine explizite Ziel-Plattform-Eingabe. Ein **vierter**, nicht zitierter
  Fundort blieb offen und widerspricht der Korrektur jetzt direkt (MEDIUM-A).
- **MEDIUM-2 — behoben und gehalten.** `grep -rnE 'GOOS|GOARCH|runtime\.|platform'
  internal/fetch/baseline.go` → leer, Exit 1, selbst gefahren; die Formulierung trennt jetzt sauber
  zwischen der vorhandenen Fetch-/Entpack-Sequenz und der fehlenden Auswahl-Logik. "Kein neuer
  Mechanismus" kommt an keiner Stelle des Dokuments mehr vor.
- **MEDIUM-3 — behoben und gehalten.** Die J-Zeile zitiert jetzt `LH-QA-03`, denselben Anker, den
  Festlegung 1 desselben Dokuments für dieselbe Aussagenklasse führt ("Kein Netz … zur
  Bootstrap-Zeit … Das Ziel bleibt über `bash + git + docker` geschlossen"). `LH-FA-01` kommt in
  der J-Zeile nicht mehr vor.
- **MEDIUM-4 — behoben und gehalten.** Die Index-Zeile in `docs/plan/adr/README.md` sagt jetzt
  "der Trigger [macht] … H … der nächstliegende Weg, weil er sie stellbar macht" — deckungsgleich
  mit der Trigger-Zeile im ADR-Text — und übernimmt die neue Abzählungs-Form ("elf Wege in vier
  Herkunfts-Klassen, Zeitpunkt als zweite Achse"), die gegen die Ist-Tabellen (je 11 Datenzeilen,
  vier Klassenwerte) selbst nachgezählt zutrifft.
- **LOW-1 — behoben.** Die J-Zeile trägt jetzt "plausibel und hier ungemessen" und nennt den
  Nachbarn unter derselben Schwelle (G, Folgepflicht 9) — konsistent mit dem sonst im Dokument
  durchgehaltenen `ungemessen`-Etikett.
- **INFO-1 — behoben.** Die I-Zeile zitiert jetzt verbatim aus `ADR-0011` Festlegung 3
  ("Spans liegen außerhalb des versionierten Baums, und das ist Korrektheit") — Verbatim-Gegenprobe
  mit `grep -qF` als Here-String bestätigt (`FOUND`). Der zweite Halbsatz ("ein Artefakt im
  Arbeitsbaum ginge in den Gate-Hash ein") steht korrekt außerhalb der Anführungszeichen als eigene
  Paraphrase, nicht als weiteres Zitat.

---

## Negativbefunde (geprüft, ohne Befund)

- **Wachstum statt Ersatz (Punkt 6 des Auftrags).** Beide Commits ersetzen Sätze an Ort und
  Stelle. `d1f7c36` teilt den alten Einzelabsatz "Warum G und nicht H" in zwei Absätze (einen für
  die Annahme-(a)-Frage, einen für die Mechanik-Frage) — das ist Neugliederung des ersetzten
  Inhalts, kein Nebeneinanderstellen von altem und neuem Text; nichts vom alten Wortlaut ist als
  Neben-Rest liegen geblieben (außer dem in MEDIUM-A benannten, unberührten Absatz). `eaf5d0f`
  ersetzt die I- und J-Zeile 1:1, Zeile für Zeile, ohne Rest.
- **Review-Geschichte im Artefakt (§3.7).** `grep -niE 'runde|HIGH-[0-9]|MEDIUM-[0-9]|LOW-[0-9]
  |INFO-[0-9]|hier stand|erweiterungsrunde|bestätigungsrunde'` über die ADR-Datei → ein Treffer,
  Teilstring "reviewer" innerhalb der zitierten Sechser-Rollenliste aus `internal/span/emit.go`
  (`planner, architect, implementer, reviewer, …`) — kein Bezug auf diese oder eine vorherige
  Review-Runde.
- **§3.4 — `ADR-0020`/`ADR-0021` byte-identisch.** `git diff --stat 4302b5b..eaf5d0f --
  docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` → leer.
- **§3.8 — nur Architect-Artefakte.** Beide Commits: `M` auf ADR-0022 und/oder den ADR-Index,
  Commit-Message-Präfix `Rolle Architect:`.
- **Keine Slice-/Wellen-IDs als normativer Anker** — unverändert gegenüber der Erweiterungsrunde
  (ein Dateipfad-Treffer innerhalb eines Kommandos).
- **`MR-025`.** Keine neu eingeführte nackte Zahl ohne begleitendes Kommando/Etikett gefunden; die
  einzige neu in den Index übernommene Zahl ("elf Wege") ist Restatement einer bereits im ADR-Text
  gemessenen und dort mit Kommando belegten Zahl.
- **Keine lokalen `.harness/baseline/<tag>/`-Präfixe** — von diesem Diff nicht berührt, weiterhin
  leer (`ADR-0016`).
- **`make gates`/`make docs-check` — selbst gefahren, beide grün, nichts aus den Commit-Messages
  übernommen.** `make docs-check` → 356/0. `make gates` → Exit 0, 143 `ok`, 0 `not ok`,
  `comment-claims: 40 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 0 |

## Verdikt

**Blockiert.** Fünf der sechs geprüften Punkte tragen die Behebung vollständig (MEDIUM-2,
MEDIUM-3, MEDIUM-4, LOW-1, INFO-1) — Kommandos selbst gefahren, Zitate verbatim gegengeprobt,
`make gates`/`make docs-check` grün. Der sechste (MEDIUM-1) ist nur **teilweise** behoben: drei der
vier Stellen, die die überzeichnete Kern-Behauptung trugen, sind konsistent auf "stellbar, nicht
beantwortet" umgestellt; eine vierte, im selben Absatz-Block liegende Stelle (Zeile 341) blieb
unangetastet und behauptet weiterhin das Gegenteil der drei Zeilen darunter — ein durch den Fix
selbst neu entstandener, unmittelbarer Text-Widerspruch (MEDIUM-A).

**Übergabe:** Die Behebung gehört dem Architect und berührt voraussichtlich nur den Schlusssatz des
Absatzes "Was Annahme (a) trägt und was nicht" (Zeile 341) — er müsste dieselbe Unterscheidung
("stellbar, nicht beantwortet") tragen wie die drei bereits korrigierten Nachbarstellen. Alle
anderen fünf Punkte dieser Bestätigungsrunde sind aus meiner Sicht frei; nur MEDIUM-A steht der
Annahme noch entgegen. Dieser Report ersetzt keine Verifikation — DoD-Abhakung und
Gate-Lauf-Bestätigung bleiben Sache des Verifiers (Modul 11, getrennter Kontext).
