# Review — ADR-0028, dritte Konsistenzrunde (Nachprüfung der Korrektur `f91ad18`)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Architektur, Planung und Implementation |
| **Review-Art** | **Plan-/Design-Review** gegen aktive ADRs, Hard Rules, den Adaptions-Speicher und die adoptierte Baseline. **Nicht** DoD-Abhakung (Verifier, Modul 11), **keine** inhaltliche Neubewertung der Entscheidung |
| **Gegenstand** | `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`, Status `Proposed` |
| **Diff dieser Runde** | `f91ad18` *„Rolle Architect: ADR-0028 gegen v5.18.0 nachgemessen — Belege, ein Zitat und die Report-Verweise"* (2026-09-03 11:07:42 +0200), **eine** Datei, 58 Einfügungen / 31 Löschungen (`git show f91ad18 --stat --format=`) |
| **Auftrag** | Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. Dieser Lauf ist die dritte ADR-Review-Runde; wer die Korrektur geschrieben hat, prüft sie nicht |
| **Plan** | `docs/plan/planning/done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md`, DoD (1) |
| **Bindende ADRs** | `ADR-0015`, `ADR-0016`, `ADR-0024` (alle `Accepted` — je `grep -m1 '^\*\*Status:\*\*'`) · zur Kohärenz mitgelesen, **nicht bindend**: `ADR-0025`, `ADR-0029` (beide `Proposed`) |
| **Anforderungen / Normen** | `AGENTS.md` §3.1, §3.4, §3.6, §3.7, §3.8 · `MR-000`, `MR-007`, `MR-025`, `MR-033`, `MR-040`, `MR-045` · `LH-QA-01` |
| **Vorherige Findings am gleichen Modul** | Runde 2, Report `2026-09-03-adr-0028-konsistenz-review-runde-2.md` (1 HIGH, 2 MEDIUM, 2 LOW, 1 INFO); Runde 1, Report `2026-09-02-adr-0028-konsistenz-review.md` (1 HIGH, 3 MEDIUM, 1 LOW, 1 INFO). Alle sechs der zweiten Runde sind unten einzeln nachgemessen. Davor `2026-08-31-slice-144-review.md` HIGH-1, der Auslöser der ADR. **Beide Vorgänger-Reports sind hier bei ihrer Kennung genannt, nicht unter ihrer Adresse** — dieselbe Trennung, die der Gegenstand selbst jetzt zieht |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.5.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Mess-Basis** | Arbeitsbaum-`HEAD` = `f91ad18` (der Korrektur-Commit selbst), Baum sauber (`git status -sb` → nur *voraus 17*). Adoptierte Baseline **`v5.18.0`** (`ls .harness/baseline/` → ein Eintrag). Jede Zahl unten in dieser Sitzung selbst gefahren; **keine Zahl aus der Korrektur oder aus einem Vorgänger-Report übernommen**. Dieses Dokument ist ein **Zeitdokument** und wird nicht nachgezogen |
| **Kontext frisch** | ja — die zehn Verbatim-Proben, die vier `git log`-Werte, der `BEO-007`-Stand, jedes Repo-Zitat und jede Abschnitts-Verortung sind gegen die Quelle gefahren, nicht gegen die zitierende Stelle |

**Was in diesem Lauf gefahren wurde.** `make docs-check` (**558 Datei(en) geprüft, 0 Befund(e)**,
Exit 0 — der Gegenstand ist ein Dokument, und die Korrektur hat Links entfernt); die zehn Proben
aus §Verbatim-Proben **wie abgedruckt**; die Verortung jedes Zitats über die Überschriften-Liste
seiner Quelldatei statt über die Behauptung der ADR; die vier `git log`-Werte an `7485be3` **und**
an `HEAD`; der `BEO-007`-Registerwert an beiden Refs **und** seine Wortlaut-Historie
(`git log -S`); der `git ls-tree`-Bestand an beiden Refs; alle fünf Repo-Zitate (drei
Command-Eröffnungssätze, zwei Typkarten-Sätze) und das Commit-Zitat aus `e30e0fd`, jeweils nach
Entfernen von Link- und Auszeichnungs-Syntax; die zwei `ADR-0015`-Zitate, das `ADR-0024`-Zitat und
die zwei `AGENTS.md`-Zitate; `ADR-0016` Festlegung 2/3/4 im Volltext; die Schritt-Nummerierung der
Wellen-Closure bei `v5.12.0` **und** `v5.18.0`; die einzige `claude/commands`-Fundstelle im
vendored Baum im Volltext; die Struktur gegen die ADR-Vorlage von `v5.18.0`. Der Arbeitsbaum wurde
nicht verändert; das einzige Schreibprodukt dieses Laufs ist diese Datei.

---

## Vorfrage aus dem Auftrag: hat sich der Baum seit `f91ad18` bewegt?

**Nein — `f91ad18` *ist* `HEAD`.** `git log --oneline f91ad18..HEAD` → leer, ebenso mit dem
Pathspec `-- .harness/baseline docs/plan/planning/observations.md`. Zwischen Korrektur und diesem
Lauf liegt **kein** Commit; die Konstellation aus Runde 2 (Re-Baseline zwischen Schreiben und
Prüfen) wiederholt sich nicht. `ls .harness/baseline/` nennt genau `v5.18.0`, `BEO-007` steht an
`HEAD` bei **4×** mit den Belegen `slice-137, slice-144, slice-147, slice-148` — identisch zum
Wert, den die ADR an ihrer eigenen Mess-Basis `7485be3` abdruckt
(`git show 7485be3:docs/plan/planning/observations.md | awk -F'|' '$2 ~ /BEO-007/{print $5, $6}'`
gegen dasselbe `awk` auf die Arbeitskopie → beide ` 4×   slice-137, slice-144, slice-147, slice-148`).

**Eine Bewegung liegt trotzdem vor, nur älter als `f91ad18`** — sie betrifft den *Wortlaut* der
Registerzeile und ist Gegenstand von MEDIUM-1.

## Nachprüfung der sechs Befunde aus Runde 2

| Befund (Runde 2) | Status | Beleg dieses Laufs |
|---|---|---|
| **HIGH-1** — Belege gegen den abgelösten Stand gemessen, drei Präsens-Aussagen falsch, ein Zitat trug nach dem Tag-Tausch nicht mehr | **behoben** | `grep -c 'v5\.18\.0' <ADR>` → **20**, `grep -c 'v5\.12\.0' <ADR>` → **1**, und diese eine steht in Zeile 428 — der Geschichte-Zeile vom 2026-08-31, die ihre **eigene** Runde datiert (dort zweimal, für den Konflikt-Pfad und den Acceptance-Trigger). Beide Wortlaute standen bei `v5.12.0` tatsächlich so: `git show b902b60:.harness/baseline/v5.12.0/regelwerk/grundlagen-bootstrap.md \| tr '\n' ' ' \| tr -s ' ' \| grep -cF 'ADR-Review-Runde abgeschlossen → bindend'` → **1**, dasselbe für den Konflikt-Pfad-Satz in `modul-08-agentenrollen.md` → **1**. Die zehn Proben **wie abgedruckt** gefahren: **je 1** (vorher neunmal 0) |
| **HIGH-1, zweite Hälfte** — das Sechs-statt-fünf-Zitat | **behoben, wortgetreu** | `v5.18.0`, `modul-08-agentenrollen.md:69` lautet *„Nur 1, 2 und 3b tragen einen Rollenwechsel; 3a, 3c, 4, 5 und 6 laufen im Planner-Kontext."* — die ADR druckt genau das (Zeile 230–231). Verortung geprüft, nicht übernommen: die Zeile liegt zwischen `### Rollen-Sequenz für eine Welle` und `### Die neun Übergaben` (Überschriften-Liste der Datei), also im von der ADR genannten Abschnitt. Der Kopf desselben Abschnitts sagt *„drei Eröffnungs- und sechs Closure-Schritte"* und *„Die Schritt-Nummern sind die der Closure-Prozedur, alle sechs"* — die **Planner-Zuordnung**, die die ADR aus dem Zitat zieht, trägt am neuen Stand unverändert (Schritte 3a, 3c, 4, 5, 6 tragen **Planner** in der Träger-Spalte) |
| **MEDIUM-1** — zwei Markdown-Links auf Review-Reports plus eine Pfad-Nennung | **behoben** | `grep -no '\]([^)]*reviews[^)]*)' <ADR>` → **keine Ausgabe** (Exit 1). Vier Report-Nennungen, alle als blanke Kennung in Backticks: Zeile 41 (§Kontext), 428, 429, 430 (Geschichte). Der Begründungs-Absatz am Ende von §Verbatim-Proben ist gegen beide Quellen gehalten und **beide Verortungen stimmen**: das Zitat *„Die Aussage gehört an den zitierenden Ort, die Report-Kennung bleibt im Text"* steht in `modul-10-review-harness.md` Zeile 115, und die Überschriften-Liste der Datei setzt es unter `### Reviewer berichtet auch, was er nicht gefunden hat` (Zeile 93) — genau der Abschnitt, den die ADR nennt. Der Verweis auf `ADR-0016` Festlegung 4 liest die Gegenrichtung korrekt (siehe aber LOW-1 zur Kopf-Zeile) |
| **MEDIUM-2** — der Slice rechnet mit `BEO-007` bei 1× | **unverändert offen — Adressat Planner** | Der Plan ist seit Runde 2 nicht angefasst; `grep -n '1×' docs/plan/planning/next/slice-145-*.md` → Zeile **113** (*„der Zähler bleibt bei 1×"*) und Zeile **230** (*„`BEO-007` steht im Register (Sub-Area `*`, 1×, …)"*), während die Registerzeile bei **4×** steht und ihren Ausgang bereits **dreigeteilt** führt (Command-Artefakte → `ADR-0028` · `.claude/agents/*.md` → `ADR-0029` · Spec-Straten → `slice-151`). Hängt nicht am ADR-Text und blockiert den Statuswechsel nicht |
| **LOW-1** — Kopf zählte sieben Aussagen bei neun Kommandos | **behoben** | Der Kopf sagt jetzt *„neun Baseline-Aussagen … darum sind es zehn Kommandos"*; `awk '/^## Verbatim-Proben/,/^## Geschichte/' <ADR> \| grep -c '^tr '` → **10**. Die Differenz ist erklärt und stimmt: die Proben 1 und 2 belegen **eine** Aussage (§Konflikt-Pfad über zwei Fragmente), die übrigen acht je eine eigene — von Hand gegen die acht Belegstellen im Text gezählt |
| **LOW-2** — *„erste Zeile"* statt Eröffnungssatz | **behoben** | Die Anwendungs-Tabelle sagt *„Eröffnungssatz"*, der Absatz darunter nennt die Stelle jetzt ausdrücklich (*„nach der Überschrift und der `Argument:`-Zeile, nicht in Zeile 1"*). Gemessen: `grep -n 'Dieser Command führt die' .claude/commands/*.md` → je `:5`; Zeile 1 ist die H1, Zeile 3 die `Argument:`-Zeile in allen drei Dateien |
| **INFO-1** — `ADR-0029` in derselben Tag-Lage | **unverändert** | `for f in 0015 0016 0024 0025 0028 0029; do grep -c 'v[0-9]\+\.[0-9]\+\.[0-9]\+' docs/plan/adr/$f-*.md; done` → **20 · 25 · 7 · 9 · 21 · 1**; der eine Tag in `ADR-0029` ist `v5.12.0`, also der abgelöste Stand. Kein Vorwurf an ADR-0028; Gegenstand des Laufs, der `slice-152` trägt |

**Keiner der sechs ist oberflächlich abgehakt.** Die vier `git log`-Werte sind an der gepinnten
Mess-Basis **und** an `HEAD` nachgefahren (`13 · 1 · 4 · 0` an beiden Refs, also genau die
abgedruckten Werte); `git ls-tree -r --name-only 7485be3 -- .claude/commands .harness/skills`
liefert exakt die vier Dateien der Anwendungs-Tabelle, an `HEAD` identisch; `20a3e33` berührt
tatsächlich `close-welle.md` **und** `.harness/skills/reviewer.md`, `b39d4ff` genau die zwei
Typkarten mit den abgedruckten Zeilenzahlen.

**Was den Statuswechsel weiterhin blockiert, sind zwei Stellen, die keine Vorrunde erfasst hat** —
beide entstehen aus demselben Mechanismus wie die HIGHs der Runden 1 und 2 und stehen unten.

---

## Findings

### HIGH-1 — Der Beleg, den die Korrektur neu einführt, trägt drei der vier Teile aus `ADR-0016` Festlegung 2; es fehlt das Zitat, und der verbleibende Locator ist eine Schritt-Nummer, die genau ein Baseline-Sprung her ihre Bedeutung gewechselt hat

- **kategorie:** HIGH
- **quelle:** `ADR-0016` (Accepted) Festlegung 2 und Festlegung 3 (a)
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:419-421`
- **befund:** Der Absatz, mit dem die Korrektur MEDIUM-1 der Vorrunde schließt, belegt seine
  tragende Aussage so: *„die Adresse verfällt (Wellen-Closure archiviert Review-Reports **ohne**
  Stub, `v5.18.0`, `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 4), die Aussage nicht"*.
  Das ist eine **Paraphrase**, kein Zitat. `ADR-0016` Festlegung 2 verlangt für ein Artefakt, das
  unveränderlich wird, drei Teile je Beleg — **Tag** · **Regelwerks-Dateiname und Abschnittsname** ·
  **Zitat verbatim** —, und Festlegung 3 (a) bindet genau den Übergang, der hier ansteht
  (*„Bevor der Status eines ADR auf Accepted wechselt, werden seine Baseline-Belege in die Form aus
  Festlegung 2 gebracht"*). Die ADR erklärt die Form für ihre übrigen Belege selbst als erfüllt
  (Zeile 408: *„Die Belege oben tragen Tag, Dateiname, Abschnittsname und Zitat"*); dieser eine,
  dreizehn Zeilen darunter, trägt das Zitat nicht — obwohl es kürzer wäre als die Paraphrase:
  `v5.18.0`, `modul-06-roadmap.md:248` sagt *„Review-Reports bekommen keinen Stub"*.
  **Was die Paraphrase stattdessen trägt, ist eine Adresse.** Der einzige verbliebene Locator
  neben dem Abschnittsnamen ist die Ordnungszahl *Schritt 4*, und die hat zwischen den zwei
  Baseline-Ständen, die dieses Repo kennt, ihren Gegenstand gewechselt — gemessen, nicht vermutet:
  `git show b902b60:.harness/baseline/v5.12.0/regelwerk/modul-06-roadmap.md | grep -n '^[0-9]\. \*\*'`
  → `4. **Wave-Self-Close-Commit.**`, dieselbe Zählung an `v5.18.0`
  (`grep -n '^[0-9]\. \*\*' .harness/baseline/v5.18.0/regelwerk/modul-06-roadmap.md`) →
  `4. **Zeitdokumente der Welle archivieren.**`. Ein Leser, der die eingefrorene ADR gegen einen
  künftigen Stand hält, liest also eine Zahl, die schon einmal auf etwas anderes zeigte.
  **Failure-Szenario:** Mit `**Status:** Accepted` friert `AGENTS.md` §3.4 den Satz ein. Schiebt
  der nächste Re-Baseline die Closure-Schritte erneut (die letzte tat es), zeigt der Beleg auf
  einen Schritt, der die Aussage nicht mehr trägt, und niemand kann entscheiden, ob die ADR die
  Regel falsch wiedergab oder die Nummer wanderte — genau der Fall, den `ADR-0016` §Kontext an
  ihrer Zeile-129-Messung misst (*„Ein mechanischer Tausch des Tag-Strings ist damit keine
  Pfad-Reparatur, sondern eine Inhaltsänderung"*). Die Reparatur kostet **jetzt** vier Wörter und
  **nach** der Annahme eine Folge-ADR; `ADR-0016` beziffert diesen Preis selbst.
  **Abgrenzung, damit der Befund nicht überzogen wird:** Die Paraphrase ist **inhaltlich richtig**
  (gegen `modul-06-roadmap.md:248` gehalten), der Tag steht da, der Abschnittsname steht da, und
  die Aussage, die der Absatz stützt, trägt unabhängig davon. Der Befund ist die **Form** an dem
  Übergang, den Festlegung 3 (a) bindet — dieselbe Regel, aus der Runde 1 ihr HIGH-1 zog, nur an
  einer Stelle statt an acht.
- **verifizierbar:** ja, aber **nicht durch ein Gate** — `grep -m1 '^modules:' .d-check.yml` →
  `modules: [links, anchors, ids, matrix, codepaths, spans]`; keines liest die Form eines Belegs,
  und `ADR-0016` Festlegung 3 führt den Sensor ausdrücklich als *mechanisierbar, aber nicht
  gebaut*. Bestätigt wird der Befund durch die zwei `grep -n '^[0-9]\. \*\*'`-Läufe über die zwei
  Baseline-Stände und den Blick auf `modul-06-roadmap.md:248`.
- **klasse:** „Baseline-Beleg mit Ordnungszahl statt Zitat in einem Artefakt, das eingefroren wird"

### MEDIUM-1 — Die ADR zitiert `BEO-007` im Präsens mit einem Wortlaut, den die Registerzeile weder heute noch an der gepinnten Mess-Basis dieser ADR trägt

- **kategorie:** MEDIUM
- **quelle:** `MR-025` Setzung 1 (sinngemäß: wer eine Aussage über einen wandernden Bestand
  abdruckt, hat sie über dem Baum gefahren, von dem sie spricht) · `AGENTS.md` §3.4 · die
  Mess-Basis-Klausel der ADR selbst (Zeile 28)
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:137-140` und
  `:292-293`
- **befund:** §Kontext sagt: *„`BEO-007` selbst hält fest, dass dieses Muster in der Praxis schon
  gilt, ohne je entschieden worden zu sein: *„Umgangen, nicht gelöst: geschrieben wurde nur in
  Abschnitten, die die Planner-Rolle bereits im Titel führen."* Genau das ist die informelle
  Fassung der Regel, die diese ADR jetzt formalisiert."* Der zweite Positiv-Punkt in §Konsequenzen
  greift denselben Wortlaut auf: *„einen Ausgang, der nicht bloß „umgangen" (die eigene
  Formulierung der Beobachtung) bleibt"*. Beide Sätze stehen im **Präsens** über ein **lebendes**
  Register. Gemessen trägt das Register diesen Wortlaut nicht — und zwar an keinem der zwei Refs,
  die die ADR selbst benennt: `git grep -n 'Umgangen, nicht gelöst' -- .` findet **genau eine**
  Fundstelle im ganzen Repo, nämlich die ADR-Zeile 138 selbst;
  `git show 7485be3:docs/plan/planning/observations.md | grep -c 'Umgangen'` → **0** (das ist die
  in Zeile 28 gepinnte Mess-Basis dieses Dokuments);
  `grep -c 'Umgangen' docs/plan/planning/observations.md` → **0** an `HEAD`. Die Historie ist
  eindeutig: `git log --oneline -S'Umgangen, nicht gelöst' -- docs/plan/planning/observations.md`
  nennt zwei Commits — `7913330` (2026-08-30 19:27, slice-137-Closure, Einführung) und `ec1eb9a`
  (2026-08-31 12:54, *„Rolle Planner: slice-144 Closure — Risiko-Ausgaenge, Lerneintrag,
  Register"*, Entfernung). Die ADR entstand um **09:46** desselben Tages (`2dc505a`), also **drei
  Stunden vor** der Umschrift; am Anlege-Commit war das Zitat wahr
  (`git show 2dc505a:docs/plan/planning/observations.md | grep -c 'Umgangen'` → **1**). Es ist
  seither zweimal überarbeitet worden (`88fb255`, `f91ad18`), ohne dass diese Stelle mitzog.
  **Und es fehlt nicht nur der Wortlaut, sondern die Aussage:** die heutige `Stand`-Zelle sagt
  *„**Schwelle erreicht**, weiter offen"* und führt einen dreigeteilten Ausgang; einen Satz, der
  das Muster als *schon gelebte, nur umgangene Praxis* festhält, enthält sie nicht mehr.
  **Failure-Szenario:** Mit `Accepted` friert `AGENTS.md` §3.4 beide Sätze ein. Der nächste Lauf,
  der die Prämisse *„die Praxis gilt bereits"* nachschlägt, greppt `observations.md`, findet
  nichts, greppt an der in Zeile 28 gepinnten Mess-Basis, findet wieder nichts — und kann nicht
  entscheiden, ob die ADR ein Zitat erfunden oder das Register es verloren hat. Die Antwort steht
  nur in `git log -S`, und die ADR gibt keinen Anhaltspunkt, dort zu suchen. Das ist dieselbe
  Klammer, die die HIGHs beider Vorrunden gebrochen haben: eine Aussage über einen wandernden
  Bestand wird in dem Moment eingefroren, in dem niemand sie mehr korrigieren darf — beim ersten
  Mal fehlte der Tag, beim zweiten war der Tag ein anderer, hier fehlt die Mess-Basis für ein
  **Zitat**, weil die Klausel in Zeile 28 nur *Zahlen* und *Baseline-Zitate* deckt.
  **Abgrenzung:** Die **Entscheidung** fällt dadurch nicht. Dass die Praxis schon gilt, ist
  unabhängig belegt — durch den Gründungs-Commit `e30e0fd` (verbatim geprüft) und durch die vier
  heute lebenden Dateien, deren Zitate ich einzeln nachgemessen habe (alle korrekt, siehe
  Negativbefunde). Betroffen ist ein Beleg, nicht die Prämisse.
- **verifizierbar:** ja — die drei `grep -c`-Läufe (`HEAD`, `7485be3`, `2dc505a`) und
  `git log -S` oben. Kein Gate: kein Modul aus `grep -m1 '^modules:' .d-check.yml` hält einen
  zitierten Satz gegen die Datei, aus der er stammen soll.
- **klasse:** „Zitat aus einem lebenden Register im Präsens, ohne Mess-Basis, in einem Artefakt,
  das eingefroren wird"

### LOW-1 — Die `Bezug:`-Zeile schreibt `ADR-0016` Festlegung 4 eine Richtung zu, die deren Text nicht hat; der Fließtext derselben ADR zieht sie richtig

- **kategorie:** LOW
- **quelle:** `ADR-0016` (Accepted) Festlegung 4; interne Widerspruchsfreiheit
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:16` gegen `:416-418`
- **befund:** Die `Bezug:`-Zeile sagt über `ADR-0016`: *„ihre Festlegung 4 trägt zusätzlich die
  Verweis-Form **auf** Zeitdokumente"*. Festlegung 4 lautet im Original: *„Ein Verweis **in** einem
  Zeitdokument verliert seine Adresse, nicht seinen Text"* — sie regelt den Verweis, der **aus**
  einem Zeitdokument **in** den vendored Baum zeigt, nicht den Verweis **auf** ein Zeitdokument.
  Der Fließtext der ADR selbst sagt das an der Stelle, an der es zählt, korrekt: *„Das ist dieselbe
  Trennung, die `ADR-0016` Festlegung 4 für die **Gegenrichtung** zieht — dort verliert ein Verweis
  *in* einem Zeitdokument seine Adresse und behält seinen Text, hier ein Verweis *auf* eines."*
  Die tatsächliche Quelle für die eigene Praxis der ADR ist damit nicht `ADR-0016` Festlegung 4,
  sondern `v5.18.0`, `modul-10-review-harness.md` — und die nennt sie im selben Absatz.
  **Failure-Szenario:** Ein künftiger Lauf zitiert die eingefrorene Kopf-Zeile als Beleg dafür,
  `ADR-0016` habe die Verweis-Form **auf** Zeitdokumente bereits entschieden, und stützt darauf
  eine Regel, die keine angenommene Quelle setzt. Das ist der Klassen-Zwilling von MEDIUM-2 der
  ersten Runde (*„Eine ADR schreibt einer Vorgänger-ADR eine Zuordnung zu, die deren eigene
  Verengung ausschließt"*), nur eine Stufe schwächer, weil derselbe Text sie zwölf Bildschirmseiten
  später selbst korrigiert.
- **verifizierbar:** ja — `sed -n '318,325p' docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md`
  gegen die zwei ADR-0028-Stellen. Kein Gate.
- **klasse:** „Kopf-Zeile fasst eine fremde Festlegung weiter als ihr eigener Fließtext"

### LOW-2 — Die Mess-Basis-Klausel gilt für „jede Zahl unten"; drei Zahlen können sie nicht erfüllen, und eine davon liefert an der gepinnten Basis einen anderen Wert

- **kategorie:** LOW
- **quelle:** `MR-025` Setzung 1 (als Maßstab, nicht als verletzte Regel); interne
  Widerspruchsfreiheit
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:28` gegen `:226`,
  `:384-385`, `:410`
- **befund:** §Mess-Basis sagt: *„Jede Zahl unten ist gegen den Commit **`7485be3`** gefahren und
  nennt ihn im Kommando."* Drei Zahlen tun das nicht und können es nicht: der Eröffnungssatz-Fund
  (`grep -n 'Dieser Command führt die' .claude/commands/*.md` → je `:5`, Zeile 226), die
  Proben-Zählung (`awk … | grep -c '^tr '` → **10**, Zeile 384–385) und die Link-Zählung
  (`grep -c ']([^)]*\.harness/baseline/' <ADR>` → **0**, Zeile 410). Die zwei letzten sind
  **selbstbezüglich** — sie messen die ADR-Datei, die sich seit `7485be3` zweimal geändert hat.
  Wer die Klausel wörtlich nimmt und die Proben-Zählung an der gepinnten Basis fährt, bekommt einen
  Widerspruch:
  `git show 7485be3:docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md | awk '/^## Verbatim-Proben/,/^## Geschichte/' | grep -c '^tr '`
  → **0** statt der abgedruckten **10** (§Verbatim-Proben entstand erst mit `88fb255`, 81 Minuten
  nach `7485be3`). **Kein `MR-025`-Verstoß:** alle drei Zahlen stehen neben dem Kommando, das genau
  sie liefert, sind über dem Baum gefahren, von dem sie sprechen (an `HEAD` selbst nachgemessen:
  `:5` · **10** · **0**), und die mitwandernde ist als *kein Erwartungswert* gekennzeichnet, wie
  Setzung 2 es verlangt. Der Defekt liegt allein in der **Reichweite** der eigenen Klausel.
  **Failure-Szenario:** Ein Lauf, der die Messungen nachzählt — genau die Tugend, die `MR-025`
  schützen will —, findet an der deklarierten Basis drei Fehlschläge und gewöhnt sich ab,
  nachzuzählen.
- **verifizierbar:** ja — das `git show | awk | grep -c` oben gegen die abgedruckte **10**.
- **klasse:** „Blanket-Klausel über eine Mess-Basis, die drei ihrer eigenen Zahlen nicht tragen kann"

### INFO-1 — `ADR-0029` steht unverändert mit dem abgelösten Tag da

- **kategorie:** INFO
- **quelle:** Maintainability; `ADR-0016` Festlegung 3 (a)
- **pfad:** `docs/plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md`
- **befund:** Kein Vorwurf an ADR-0028 — eine Beobachtung für die Runde, die `slice-152` trägt.
  Die zweite `Proposed`-ADR derselben Familie nennt im ganzen Dokument **einen** Tag, und es ist
  `v5.12.0` (`grep -o 'v5\.[0-9]*\.[0-9]*' docs/plan/adr/0029-*.md | sort | uniq -c` → `1 v5.12.0`;
  kein Erwartungswert). Sie stützt sich in Festlegung 1 auf ADR-0028 und steht damit vor demselben
  Übergang, derselben Vorbedingung und demselben Stand-Wechsel, den HIGH-1 der Vorrunde hier
  ausgelöst hat. Seit ihrem Anlege-Commit `5cee53e` ist sie nicht angefasst worden.
- **verifizierbar:** ja — das `grep -o | sort | uniq -c` oben und
  `git log --oneline -- docs/plan/adr/0029-*.md`.
- **klasse:** „Baseline-Beleg gegen einen abgelösten Stand in einem Artefakt, das eingefroren
  werden soll" (Wiederholung in einem Geschwister-Artefakt)

## Negativbefunde

- **Prüfpunkt 1a — Widerspruch zu `ADR-0015` (Accepted):** geprüft, **kein Befund**. Festlegung 2
  weist den ausgenommenen Teil keiner Rolle zu (*„Über diesen Teil sagt diese ADR nichts, und sie
  weist ihn auch keiner Rolle zu"*), und §Was hier NICHT entschieden ist führt ihn auf. Beide
  `ADR-0015`-Zitate sind verbatim — *„Über die übrigen Norm-Artefakte trifft diese ADR **keine**
  Aussage …"* und *„eine Eigentums-Aussage über irgendein drittes Artefakt"*, je **1** Treffer
  nach Whitespace-Normalisierung; das dritte (*„sie als Eigentums-Aussage zu lesen kehrte die Frage
  genau um"*, `ADR-0015` §Kontext Zeile 38–39) trifft **1** mal, sobald die satzeröffnende
  Großschreibung der Quelle berücksichtigt ist — eine zulässige Einbettung, keine Änderung des
  Wortlauts. ADR-0028 besetzt ausschließlich Artefakte, für die `ADR-0015` die Frage offen ließ;
  Cutoff und Folgepflicht 2 (kein Adaptions-Eintrag, `MR-000`) sind die von `ADR-0015`. Kein
  `Supersedes` nötig, keiner behauptet.
- **Prüfpunkt 1b — Widerspruch zu `ADR-0024` (Accepted):** geprüft, kein Befund. Verschiedene
  Gegenstände (derivatives **Register** ↔ **Anweisungssatz**), verschiedene Vorfragen. Das
  übernommene `ADR-0024`-Zitat (*„die Rolle für eine bindende Aussage ohne Original, falls eine in
  ein Register gerät"*) steht dort **1** mal; das Mess-Basis-Zitat aus `ADR-0024` §Geschichte
  (*„bewegen sich mit jedem Commit … statt im selben Zug zu veralten, in dem §3.4 sie einfriert"*)
  ebenfalls **1** mal, sobald die Auszeichnung der Quelle (`mit **jedem** Commit`) entfernt ist —
  genau die Normalisierung, die `ADR-0016` Festlegung 2 als *verbatim* definiert (*„der Wortlaut
  ohne Auszeichnung, Whitespace normalisiert"*, **1** Treffer). Die Artefaktklassen-Tabelle aus
  Modul 8 wird in §Kontext ausdrücklich **nicht** als Eigentums-Aussage gelesen.
- **Prüfpunkt 1c — `ADR-0025` und `ADR-0029` (beide `Proposed`, nicht bindend):** geprüft, kein
  Befund über INFO-1 hinaus. `ADR-0029` sagt selbst *„Diese ADR ersetzt seine Festlegung 3 [nicht]"*
  und behandelt `.claude/agents/*.md` als eigene Klasse — genau die Frage, die ADR-0028
  Festlegung 3 offenlässt. Eine Annahme von ADR-0028 nimmt ihr nichts vorweg; ihre Festlegung 1
  stünde danach auf einer angenommenen statt einer vorgeschlagenen Quelle.
- **Prüfpunkt 2 — die zehn Verbatim-Proben, wie abgedruckt:** geprüft, **kein Befund**. Alle zehn
  geben **1**. Verortung jeder Fundstelle über die Überschriften-Liste ihrer Datei geprüft, nicht
  über die Behauptung der ADR: §Konflikt-Pfad (2 Fragmente), §Welche Rolle braucht welche
  Artefaktklasse, die Verdikt-Tabelle des Konflikt-Pfads, §Rollen-Sequenz für eine Welle
  (`modul-08`); §Wellen-Closure-Prozedur und §Das Beobachtungs-Register (`modul-06`); §Reviewer
  berichtet auch, was er nicht gefunden hat (`modul-10`); §Vier Trigger-Klassen
  (`grundlagen-bootstrap`); die Accepted-Hard-Rule (`modul-04`). Zusätzlich die **nicht** in den
  Proben geführte Vollzeile der Verdikt-Tabelle, die die ADR als Codeblock abdruckt: `grep -cF`
  über die ganze Zeile → **1**.
- **Prüfpunkt 3 — die tragende Negativ-Prämisse gegen den heute bindenden Stand:** geprüft, **sie
  trägt**. `grep -rl 'claude/commands' .harness/baseline/v5.18.0/` → **eine** Datei,
  `grundlagen-durchsetzungsschicht.md`; die Fundstelle im Volltext gelesen (Zeile 96) ist ein
  Listenpunkt in der Fünfer-Aufzählung der Durchsetzungsschicht — *„`.claude/commands/*.md` —
  Workflow-Skelett als Slash-Command"* —, **ohne jede Rollen-Aussage**. Die
  Artefaktklassen-Tabelle nennt für `Briefing` den Implementer und für die Skill-Datei den
  Reviewer, sonst nichts. Re-Evaluierungs-Trigger 1 hat also **nicht** gefeuert.
- **Prüfpunkt 4 — Repo-Zitate:** geprüft, kein Befund. Nach Entfernen von Link- und
  Auszeichnungs-Syntax je **1** Treffer: *„Dein Anweisungssatz steht in
  `.claude/commands/implement-slice.md` — lies ihn als Erstes und folge ihm."* · *„Diese Datei
  wiederholt ihn nicht, sie zeigt darauf."* · *„Deine Anweisungssätze stehen in
  `.claude/commands/plan-welle.md` (Schnitt) und `.claude/commands/close-welle.md` (Abschluss)"* ·
  die drei Command-Eröffnungssätze. Der Blockzitat-Auszug aus `git log -1 --format=%B e30e0fd`
  (*„DIE DATEIEN SIND ABSICHTLICH DUENN …"*) steht dort Zeile für Zeile so; ebenso *„DIE NAMEN SIND
  GEGENGEPRUEFT"* und *„Drei Stellen, dieselbe Menge"*.
- **Prüfpunkt 5 — Festlegung 3, Zirkularität und Cross-Check-Orte:** geprüft, kein Befund. Die
  Ausnahme ruht auf gemessenen Eigenschaften, nicht auf ihrem Ergebnis; `b39d4ff` ändert real
  `.claude/agents/reviewer.md` (8 Zeilen) und `verifier.md` (8 Zeilen) in einem Commit, exakt wie
  abgedruckt; die sechs kanonischen Namen stehen in `spec/spezifikation.md` §5; die
  `MR-018`/`MR-021`/`MR-030`-Kette gibt die ADR korrekt wieder (`MR-021` hebt *vollständig* auf,
  `MR-030` verlagert nichts). Re-Evaluierungs-Trigger 3 benennt die Bedingung, unter der die
  Begründung fällt.
- **Prüfpunkt 6 — Folgepflicht 4 gegen den Slice, den sie betrifft:** geprüft, kein Befund. Die
  zitierte Rückführungs-Bedingung steht wörtlich in `slice-144` §4 (**1** Treffer nach
  Normalisierung), und dessen §6 trägt den Ausgang *entfallen* mit derselben Begründung, die die
  ADR nennt — der Slice liegt bereits in `done/`. Die Zusage der ADR (*„diese ADR schreibt keine
  Plan-Datei"*) ist am Diff eingehalten: `f91ad18` berührt genau **eine** Datei.
- **Prüfpunkt 7 — Prämisse von Folgepflicht 1:** geprüft, kein Befund. `grep -c 'ADR-0024'
  AGENTS.md` → **1**, `grep -c 'ADR-0028' AGENTS.md` → **0**; §3.8 zeigt weiterhin nur auf
  `ADR-0024`. Die Beschreibung *„zwei benannte Artefakte (Hard Rules dieser Datei §3,
  Adaptions-Block in `harness/conventions.md`)"* trägt auch nach `MR-045`: §3.8 nennt heute die
  Index-Datei **und** das Eintrags-Verzeichnis daneben, aber weiterhin **einen** Adaptions-Block —
  die Zahl *zwei* bleibt richtig, nur die Ablage hat zwei Pfade.
- **Prüfpunkt 8 — `LH-QA-01` (keine halluzinierten Gates):** geprüft, kein Befund. §Fitness
  Function behauptet ausdrücklich **kein** Gate; die aufgezählten Module sind deckungsgleich mit
  `grep -m1 '^modules:' .d-check.yml`, und beide genannten `mutate`-Fehlschlag-Formen stehen im
  Werkzeug (`grep -c -- '--- FAIL:' harness/tools/mutate.sh` → **2**, `grep -c 'not ok'` → **2**).
- **Prüfpunkt 9 — Ziel-Form der ADR-Vorlage (`v5.18.0`):** geprüft, kein Befund. Kopf (`Status`,
  `Datum`, `Autor`, `Bezug`, `Schärft`) und alle sieben Pflicht-Abschnitte stehen in der
  Vorlagen-Reihenfolge; §Verbatim-Proben ist ein **Anhang vor** §Geschichte, kein Ersatz. Das
  `**Regeln:**`-Feld der Vorlage gehört zu deren Anleitungs-Block, nicht zum Kopf — im ganzen
  Bestand trägt es **1** von **33** ADRs. Der Immutabilitäts-Schlusssatz steht und nennt jetzt
  `v5.18.0`. Der ADR-Index führt die Zeile mit Status `Proposed` (`grep -n '0028'
  docs/plan/adr/README.md` → Zeile 35).
- **Prüfpunkt 10 — Doku-Gate nach der Korrektur:** geprüft, **grün**. `make docs-check` →
  `d-check: 558 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Die entfernten Report-Links haben nichts
  hinterlassen, und die verbliebenen 15 Link-Ziele der ADR lösen auf.
- **Prüfpunkt 11 — die Formulierung *„einen sechsten Schritt (Zeitdokumente archivieren)"* in der
  Geschichte-Zeile vom 2026-09-03:** geprüft, **kein Finding**. Gemessen ist *Zeitdokumente
  archivieren* der **vierte** Schritt und *Roadmap fortschreiben* der sechste; der Satz sagt aber,
  die Prozedur **habe einen sechsten Schritt bekommen**, und der hinzugekommene ist tatsächlich die
  Archivierung (Diff der Schritt-Listen `v5.12.0` → `v5.18.0`). Die Aussage ist damit richtig, die
  Ordinalzahl bezeichnet die neue Anzahl und nicht die Position. Ein Failure-Szenario, das nicht
  schon HIGH-1 trägt, lässt sich daraus nicht erzählen.
- **Prüfpunkt 12 — `AGENTS.md` §3.7 (Kommentar / Zustandsfeld trägt keine Chronik):** geprüft,
  kein Befund **in der ADR**. Die Geschichte-Tabelle ist der von der Vorlage vorgesehene
  Provenienz-Ort; §Kontext erzählt den Anlass, was die Aufgabe des Abschnitts ist.
- **Nicht geprüft (bewusst außerhalb dieses Laufs):** der **Inhalt** der drei Commands, der
  Skill-Datei und der sechs Typkarten; die DoD-Abhakung und der Gate-Lauf von `slice-145`
  (Verifier, Modul 11); die innere Konsistenz von `ADR-0029` (eigener Gegenstand, eigener Lauf);
  die **Form** der `Stand`-Zelle von `BEO-007` (Planner-Artefakt — hier nur auf ihren Wert und
  ihren Wortlaut gelesen, nicht auf §3.7-Konformität); `make gates` als Ganzes (nur `docs-check`
  gefahren, weil der Gegenstand ein Dokument ist).

## Kategorie-Summary

- HIGH: 1
- MEDIUM: 1
- LOW: 2
- INFO: 1

**Finding-Klassen dieses Laufs (für die Slice-Closure §7 und den Zähler):**
„Baseline-Beleg mit Ordnungszahl statt Zitat in einem Artefakt, das eingefroren wird" ·
„Zitat aus einem lebenden Register im Präsens, ohne Mess-Basis, in einem Artefakt, das eingefroren
wird" · „Kopf-Zeile fasst eine fremde Festlegung weiter als ihr eigener Fließtext" ·
„Blanket-Klausel über eine Mess-Basis, die drei ihrer eigenen Zahlen nicht tragen kann" ·
„Baseline-Beleg gegen einen abgelösten Stand in einem Artefakt, das eingefroren werden soll"
(Wiederholung im Geschwister-Artefakt).

**HIGH-1 und MEDIUM-1 teilen den Mechanismus der beiden Vorrunden-HIGHs, und das ist jetzt die
dritte Wiederholung.** Dieselbe Klammer bricht jedes Mal an derselben Stelle: *eine Aussage über
einen wandernden Bestand wird in dem Moment eingefroren, in dem niemand sie mehr korrigieren darf.*
Runde 1: der Tag fehlte. Runde 2: der Tag war ein anderer geworden. Runde 3: der eine Beleg hat
statt des Zitats eine Ordnungszahl, und ein Register-Zitat hat gar keine Basis. Nach
`grundlagen-klassifikation.md` §Steering Loop ist 3× die Schwelle — der Befund ist damit nicht mehr
die einzelne Stelle, sondern die **fehlende Trägerschaft**: `ADR-0016` Festlegung 3 nennt ihren
Sensor selbst *mechanisierbar, aber nicht gebaut*, und für Zitate aus **repo-eigenen lebenden
Artefakten** (Register, Plandateien, Commands) benennt bisher **keine** Regel überhaupt eine
Beleg-Form. Wohin das gehört, entscheidet nicht dieser Report; dass es einen Eintrag im
Beobachtungs-Register verdient, ist die Beobachtung.

## Verdikt

**Inhaltlicher Einwand: nein. Konsistenz: NICHT bestätigt — der Statuswechsel bleibt blockiert.
ADR-0028 bleibt `Proposed`.**

Die Prüfung trennt dieselben zwei Dinge wie die Runden davor:

1. **Die Entscheidung trägt, und sie trägt gegen den heute bindenden Stand.** Alle sechs Befunde
   der zweiten Runde sind an der ADR behoben oder liegen ausdrücklich außerhalb ihres Textes —
   einzeln nachgemessen statt abgehakt (Tabelle oben). Das Sechs-statt-fünf-Zitat ist **wortgetreu**
   und im richtigen Abschnitt verortet; die drei Report-Verweise sind blanke Kennungen, **null**
   Markdown-Links zeigen nach `docs/reviews/`; ein Widerspruch zu `ADR-0015`, `ADR-0016` oder
   `ADR-0024` besteht nicht; die innere Kette Kontext → Entscheidung → Konsequenzen ist geschlossen,
   Festlegung 3 ist nicht zirkulär; die tragende Negativ-Prämisse habe ich gegen `v5.18.0` selbst
   nachgemessen — sie hält, Re-Evaluierungs-Trigger 1 hat **nicht** gefeuert. Der Baum hat sich
   seit `f91ad18` **nicht** bewegt. Die Rückführungen aus Slice-Plan §4 sind damit **nicht**
   ausgelöst.

2. **Der Statuswechsel darf trotzdem noch nicht stattfinden.** HIGH-1 verletzt `ADR-0016`
   Festlegung 2 an genau dem Übergang, den deren Festlegung 3 (a) bindet — und zwar an dem Beleg,
   den die letzte Korrektur **neu eingeführt** hat; die verbliebene Ordnungszahl hat zwischen den
   zwei Baseline-Ständen dieses Repos ihren Gegenstand schon einmal gewechselt. MEDIUM-1 friert
   ein Zitat ein, dessen Quelle es seit dem 2026-08-31 nicht mehr enthält, an zwei Stellen und im
   Präsens. Beides ist **jetzt** eine Textänderung an einem `Proposed`-Artefakt und **nach** der
   Annahme eine Folge-ADR (`AGENTS.md` §3.4; `ADR-0016` beziffert den Preis selbst).

**Übergabe.** Der Weg steht im Plan: §6 Risiko 1, Ausgang *eingetreten* — *„die ADR wird vor der
Annahme korrigiert (sie ist noch `Proposed`, keine Folge-ADR nötig) — Beleg in der
Geschichte-Tabelle."* Adressat ist der **Architect** als Rolleninhaber von DoD (1); dieser Report
ist das Übergabe-Artefakt. Zu klären sind HIGH-1 und MEDIUM-1; LOW-1, LOW-2 und INFO-1 blockieren
nicht. Nach der Korrektur ist eine vierte Runde fällig (neue Datei; dieser Report wird nicht
überschrieben).

**Ein Posten adressiert den Planner, nicht den Architect:** die Register-Zusage in `slice-145` §2
und §8 rechnet unverändert mit `BEO-007` bei **1×**, während die Zeile bei **4×** steht und ihren
Ausgang dreigeteilt führt. Das ist der dritte Lauf mit demselben Befund; er hängt nicht am ADR-Text
und blockiert den Statuswechsel nicht.

**Kein Rollen-Konflikt.** Kein Finding dieses Laufs widerspricht einer Position, die der
Architect-Lauf vertreten hätte — HIGH-1 und MEDIUM-1 betreffen Stellen, zu denen sich keine der
Korrekturen geäußert hat. Der Konflikt-Pfad aus Modul 8 §Konflikt-Pfad als Rollen-Sequenz ist
**nicht** auszulösen.

**Dieser Report ersetzt keine Verifikation** — DoD-Abhakung und repo-weiter Gate-Lauf prüft der
Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
