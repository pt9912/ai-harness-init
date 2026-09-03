# Review — ADR-0028, vierte Konsistenzrunde (Nachprüfung der Korrektur `c520331`)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Architektur, Planung und Implementation |
| **Review-Art** | **Plan-/Design-Review** gegen aktive ADRs, Hard Rules, den Konventionsspeicher und die adoptierte Baseline. **Nicht** DoD-Abhakung (Verifier, Modul 11), **keine** inhaltliche Neubewertung der Entscheidung |
| **Gegenstand** | `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`, Status `Proposed` |
| **Diff dieser Runde** | `c520331` *„Rolle Architect: ADR-0028 -- der Report-Beleg traegt ein Zitat statt einer Schritt-Nummer"* (2026-09-03 13:07:08 +0200), **eine** Datei, 43 Einfügungen / 27 Löschungen (`git show c520331 --stat --format=`) |
| **Auftrag** | Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"*. Dieser Lauf ist die vierte ADR-Review-Runde; wer die Korrektur geschrieben hat, prüft sie nicht |
| **Plan** | `slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md` (in `next/`), DoD (1) |
| **Bindende ADRs** | `ADR-0015`, `ADR-0016`, `ADR-0024` (alle `Accepted` — je `grep -m1 '^\*\*Status:\*\*'`) · zur Kohärenz mitgelesen, **nicht bindend**: `ADR-0025`, `ADR-0029` (beide `Proposed`) |
| **Anforderungen / Normen** | `AGENTS.md` §3.1, §3.4, §3.6, §3.7, §3.8, §3.9 · `MR-000`, `MR-007`, `MR-025`, `MR-040` · `LH-QA-01`, `LH-QA-02` |
| **Vorherige Findings am gleichen Modul** | Runde 3, Report `2026-09-03-adr-0028-konsistenz-review-runde-3.md` (1 HIGH, 1 MEDIUM, 2 LOW, 1 INFO); Runde 2, Report `2026-09-03-adr-0028-konsistenz-review-runde-2.md`; Runde 1, Report `2026-09-02-adr-0028-konsistenz-review.md`. Davor `2026-08-31-slice-144-review.md` HIGH-1, der Auslöser der ADR. Die fünf Befunde der Runde 3 sind unten einzeln nachgemessen. **Alle Reports sind hier bei ihrer Kennung genannt, nicht unter ihrer Adresse** — dieselbe Trennung, die der Gegenstand selbst zieht |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 (Baseline `v5.18.0`) |
| **Modell** | Claude Opus 5 (1M context) |
| **Mess-Basis** | Arbeitsbaum-`HEAD` = `c520331` (der Korrektur-Commit selbst), Baum sauber (`git status -sb` → nur *voraus 1*). Adoptierte Baseline **`v5.18.0`** (`ls .harness/baseline/` → ein Eintrag). Jede Zahl unten in dieser Sitzung selbst gefahren; **keine Zahl aus der Korrektur oder aus einem Vorgänger-Report übernommen**. Dieses Dokument ist ein **Zeitdokument** und wird nicht nachgezogen |
| **Kontext frisch** | ja — die elf Verbatim-Proben, jede Abschnitts-Verortung, die vier `git log`-Werte, der `BEO-007`-Stand an beiden Refs, jedes Repo-Zitat und der Inhalt der zwei behaupteten Fundstellen sind gegen die Quelle gefahren, nicht gegen die zitierende Stelle |

**Was in diesem Lauf gefahren wurde.** `make docs-check` (**564 Datei(en) geprüft, 0 Befund(e)**,
Exit 0 — der Gegenstand ist ein Dokument); die **elf** Proben aus §Verbatim-Proben **wie
abgedruckt**; die Verortung jedes der elf Zitate über die Überschriften-Liste seiner Quelldatei
statt über die Behauptung der ADR; die zwei `v5.12.0`-Zitate der Geschichte-Zeile vom 2026-08-31
gegen den Baum vor der Re-Baseline (`db83415^`); die vier `git log`-Werte an `7485be3` **und** an
`HEAD`; `BEO-007` an beiden Refs samt Bezeichnungs-Zitat; `git ls-tree` an `7485be3`; die drei
Command-Eröffnungssätze, die zwei Typkarten-Sätze und der Gründungs-Commit `e30e0fd`; die drei
`ADR-0015`- und die zwei `ADR-0024`-Zitate; `ADR-0016` Festlegung 2/3/4 im Volltext; die
`MR-018`/`MR-021`/`MR-030`-Kette; die sechs kanonischen Namen in `spec/spezifikation.md` §5 und
`roleFromAgentType`; `20a3e33` und `b39d4ff` im `--stat`; die `.d-check.yml`-Modulliste und die
zwei `mutate`-Fehlschlag-Formen; die Struktur gegen die ADR-Vorlage von `v5.18.0`; **und der
Ist-Inhalt der Schritte 9 und 23 in `.claude/commands/implement-slice.md` an drei Refs** (MEDIUM-1).
Der Arbeitsbaum wurde nicht verändert; das einzige Schreibprodukt dieses Laufs ist diese Datei.
Ein repo-weiter `make gates`-Lauf gehört zur Verifikation (Modul 11) und ist hier nicht gefahren.

---

## Vorfrage aus dem Auftrag: hat sich der Baum seit `c520331` bewegt?

**Nein — `c520331` *ist* `HEAD`.** `git log --oneline c520331..HEAD` → leer. Zwischen Korrektur
und diesem Lauf liegt **kein** Commit; die Konstellation aus Runde 2 (Re-Baseline zwischen
Schreiben und Prüfen) wiederholt sich nicht. `ls .harness/baseline/` nennt genau `v5.18.0`.
`BEO-007` steht an `HEAD` bei **4×** mit den Belegen `slice-137, slice-144, slice-147, slice-148`
— zeichengleich zu dem, was das in der ADR abgedruckte Kommando an ihrer Mess-Basis `7485be3`
ausgibt (beide `awk`-Läufe → ` 4×   slice-137, slice-144, slice-147, slice-148`).

**Eine Bewegung liegt trotzdem vor, und sie ist älter als die ADR selbst** — sie betrifft
`.claude/commands/implement-slice.md` und ist Gegenstand von MEDIUM-1.

## Nachprüfung der fünf Befunde aus Runde 3

| Befund (Runde 3) | Status | Beleg dieses Laufs |
|---|---|---|
| **HIGH-1** — der neu eingeführte Beleg trug Tag, Datei und Abschnitt, statt des Zitats aber die Ordnungszahl *Schritt 4* | **behoben, und die Form ist vollständig** | Der Satz lautet jetzt: *„`v5.18.0`, `modul-06-roadmap.md` §Wellen-Closure-Prozedur sagt für die Archivierung ausdrücklich: „Review-Reports bekommen keinen Stub; sie haben keine Identität jenseits ihres Slice.""* — **Tag** · **Dateiname** · **Abschnittsname** · **Zitat verbatim**, die vier Teile aus `ADR-0016` Festlegung 2. Keine Ordnungszahl mehr: `grep -n 'Schritt [0-9]' <ADR>` findet nur noch Zeile 50 (die Schritte des Commands, nicht der Closure) und die Geschichte-Zeile, die den Befund protokolliert. Das Zitat löst auf: die elfte Probe **wie abgedruckt** gefahren → **1**. Verortung geprüft, nicht übernommen: die Fundstelle liegt in `modul-06-roadmap.md:248`, zwischen `### Wellen-Closure-Prozedur` (139) und `### Regeln gegen typische Fehlannahmen` (300), also im genannten Abschnitt — und im Volltext gelesen steht sie in Schritt 4 *„Zeitdokumente der Welle archivieren"*, worauf sich das Wort *Archivierung* im ADR-Satz bezieht. Der Absatz gibt die Aussage **nicht** verkürzt wieder: die Quelle sagt, Slice-Dateien und Welle-Plan blieben als Stub, Review-Reports nicht |
| **HIGH-1, Zähl-Hälfte** — §Verbatim-Proben führt den neuen Beleg | **behoben** | Der Kopf sagt *„zehn Baseline-Aussagen … darum sind es **elf** Kommandos"*; `awk '/^## Verbatim-Proben/,/^## Geschichte/' <ADR> \| grep -c '^tr '` → **11**. Die Differenz ist erklärt und stimmt: Probe 1 und 2 belegen **eine** Aussage (§Konflikt-Pfad über zwei Fragmente), die übrigen neun je eine eigene — von Hand gegen die neun Belegstellen im Text gezählt. **Alle elf geben 1** |
| **MEDIUM-1** — Präsens-Zitat aus der `Stand`-Zelle von `BEO-007`, das an keinem genannten Ref stand | **behoben, und die Ersetzung ist nicht zirkulär** | `grep -n 'Umgangen' <ADR>` trifft nur noch die Geschichte-Zeile, die den Befund protokolliert (Vergangenheitsform, *„stand an keinem der zwei Refs"*) — im Fließtext **null**. Übernommen ist jetzt allein die **Bezeichnung** der Zeile, und die löst an **beiden** Refs auf (`grep -cF 'Wer die Anweisungssätze unter' …` → **1** an `7485be3`, **1** an `HEAD`), dazu Zähler und Belege über das abgedruckte `awk`. Die neue Mess-Basis-Klausel sagt das ausdrücklich: *„Übernommen sind Bezeichnung, Zähler und Belege der Zeile; die `Stand`-Zelle … ist darum weder zitiert noch als Beleg geführt."* **Nicht zirkulär:** die `Stand`-Zelle nennt heute `ADR-0028` als entscheidende Quelle — genau der Wortlaut, den die ADR jetzt nicht mehr anfasst; Bezeichnung, Zähler und Belege nennen sie nicht. Und die Wahl trifft die stabile Hälfte: `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln verlangt *„die Bezeichnung ist stabil zu halten, damit die Zuordnung gelingt"* (**1** Treffer an `v5.18.0`) |
| **MEDIUM-1, Prämissen-Hälfte** — die Aussage *„die Praxis gilt bereits"* braucht einen anderen Träger | **behoben** | §Kontext trägt sie jetzt auf dem Gründungs-Commit und den vier lebenden Dateien: *„Was `BEO-007` beiträgt, ist die Frage — nicht der Befund."* Der Block aus `git log -1 --format=%B e30e0fd` steht dort Zeile für Zeile so (Zeilen 6–9 der Message, am Satzende abgeschnitten); `.claude/agents/implementer.md` und `planner.md` sowie die drei Command-Eröffnungssätze je **1** Treffer nach Entfernen der Auszeichnung. Der zweite Positiv-Punkt spricht jetzt von **drei** offenen Teilen; das deckt sich mit dem dreigeteilten Ausgang, den die Registerzeile an `HEAD` führt |
| **LOW-1** — `Bezug:`-Zeile schrieb `ADR-0016` Festlegung 4 die falsche Richtung zu | **behoben** | Die Zeile sagt jetzt: *„ihre Festlegung 4 regelt die **Gegenrichtung** — den Verweis *in* einem Zeitdokument, nicht den *auf* eines."* Gegen das Original gehalten (`sed -n '318,325p' docs/plan/adr/0016-*.md`): *„**4.** Ein Verweis **in** einem Zeitdokument verliert seine Adresse, nicht seinen Text."* Kopf-Zeile und Fließtext sagen jetzt dasselbe |
| **LOW-2** — Mess-Basis-Klausel galt für *jede* Zahl, drei konnten sie nicht tragen | **behoben, beide Hälften** | Die Klausel ist auf *„jede Zahl … **über den wandernden Repo-Bestand**"* verengt und nimmt die zwei selbstbezüglichen ausdrücklich aus (*„die Proben-Zählung und die Link-Zählung … messen **diese Datei**"*). Die dritte, der Eröffnungssatz-Fund, läuft jetzt gegen die Ref: `git grep -n 'Dieser Command führt die' 7485be3 -- .claude/commands/` → **je `:5`** in allen drei Dateien, selbst gefahren. Ich habe **alle** Kommandos der Datei aufgezählt (`grep -noE` über Backtick-Kommandos, 10 Stück plus der Proben-Block): jedes nennt entweder `7485be3`, einen festen Commit (`e30e0fd`, `20a3e33`, `b39d4ff`), den Tag `v5.18.0` oder misst diese Datei selbst. Keine Lücke mehr |
| **INFO-1** — `ADR-0029` trägt nur den abgelösten Tag | **unverändert** | Kein Vorwurf an ADR-0028; siehe INFO-2 unten |
| **MEDIUM-2 der Runde 3** — der Slice rechnet mit `BEO-007` bei 1× | **unverändert offen — Adressat Planner** | siehe MEDIUM-2 unten |

**Keiner der fünf ist oberflächlich abgehakt.** Die vier `git log`-Werte sind an der gepinnten
Mess-Basis **und** an `HEAD` nachgefahren (`13 · 1 · 4 · 0` an `7485be3` — genau die abgedruckten
Werte; an `HEAD` inzwischen `14 · 2 · 4 · 0`, was die Pinnung nachträglich rechtfertigt und die
Kennzeichnung als *keine Erwartungswerte* trägt). `git ls-tree -r --name-only 7485be3 --
.claude/commands .harness/skills` liefert exakt die vier Dateien der Anwendungs-Tabelle;
`20a3e33` berührt tatsächlich `close-welle.md` **und** `.harness/skills/reviewer.md`; `b39d4ff`
genau die zwei Typkarten mit den abgedruckten Zeilenzahlen (`8 ++++++++` / `8 +++++++-`).

**Was den Statuswechsel jetzt noch blockiert, ist eine einzige Stelle** — und sie entsteht aus
demselben Mechanismus wie die HIGHs der Runden 1 bis 3, an einem Satz, den keine der drei
Korrekturen angefasst hat.

---

## Findings

### MEDIUM-1 — Die zwei Sätze, mit denen §Kontext den Anlass beschreibt, sind an `HEAD` und an der eigenen Mess-Basis der ADR falsch: die Zeile *wurde* geliefert, 25 Minuten nach dem Anlege-Commit

- **kategorie:** MEDIUM
- **quelle:** die Mess-Basis-Klausel der ADR selbst (Zeile 30) · `AGENTS.md` §3.4 ·
  `LH-QA-02` (Reproduzierbarkeit einer abgedruckten Messung) · interne Widerspruchsfreiheit
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:49-51`
- **befund:** §Der Anlass, gemessen eröffnet so: *„`slice-144` führte
  `.claude/commands/implement-slice.md` in seiner §3-Plan-Tabelle als Liefergegenstand — Schritt 9
  und 23 **dort verweisen** auf den blanken `git mv`, den der Slice ersetzt. **Geliefert wurde die
  Zeile nicht.**"* Beide Aussagen treffen den heutigen Bestand nicht mehr, und sie treffen auch den
  Stand nicht, den die ADR selbst als Mess-Basis pinnt. Gemessen, nicht vermutet — dieselbe Datei
  an drei Refs, `git show <ref>:.claude/commands/implement-slice.md | grep -c 'slice-mv'`:
  **`2dc505a`** (der Anlege-Commit der ADR, 2026-08-31 09:46:40) → **0** · **`7485be3`** (die in
  Zeile 30 deklarierte Mess-Basis, 2026-09-02 18:50:55) → **3** · **`HEAD`** → **3**. Der
  Übergang liegt bei `fc1fc54` (2026-08-31 **10:11:46**, *„slice-144: Nacharbeit -- fehlender
  Liefergegenstand nachgezogen"*), also **25 Minuten nach** dem Anlege-Commit der ADR und zwei
  Tage vor ihrer Mess-Basis: `git log -S'make slice-mv' -- .claude/commands/implement-slice.md`
  nennt genau diesen einen Commit. Im Ist-Text schicken beide Schritte heute zum Werkzeug, nicht
  zum blanken Move — Schritt 9: *„Jeder Übergang läuft über `make slice-mv SLICE=<slice-NNN>
  TO=<next|in-progress>`"*, Schritt 23: *„den Slice `in-progress → done` per `make slice-mv
  SLICE=<slice-NNN> TO=done` verschieben"*.
  **Die Plan-Datei, aus der die Aussage stammt, führt den Zeitbezug mit; die ADR hat ihn beim
  Übernehmen verloren.** `slice-144` §3 schreibt in derselben Tabellenzeile: *„Schritt 9 und
  Schritt 23 schicken **heute** zum blanken `git mv`"* — ein ausdrücklich datierter Satz. In der
  ADR steht er ohne dieses *heute*, im Präsens, und die zweite Hälfte (*„Geliefert wurde die Zeile
  nicht"*) ist eine abgeschlossene Zustandsaussage, die zum Zeitpunkt des Schreibens stimmte und
  seither nicht mehr stimmt.
  **Failure-Szenario:** Mit `**Status:** Accepted` friert `AGENTS.md` §3.4 beide Sätze ein. Der
  nächste Lauf, der den Anlass dieser ADR nachvollzieht — der naheliegendste Griff, weil §Kontext
  die Begründung für Option C trägt —, öffnet `.claude/commands/implement-slice.md`, findet in
  Schritt 9 und 23 `make slice-mv` und kann nicht entscheiden, ob die ADR ihren eigenen Auslöser
  falsch beschrieben hat oder ob die Datei seither weiterlief. Die Antwort steht nur in
  `git log -S`, und die ADR gibt keinen Anhaltspunkt, dort zu suchen — anders als bei jeder
  anderen Repo-Aussage der Datei, die entweder eine Ref oder einen festen Commit nennt. Die
  Reparatur kostet **jetzt** ein Wort (*heute*, wie im Plan) oder eine Ref und **nach** der
  Annahme eine Folge-ADR; `ADR-0016` beziffert diesen Preis für die verwandte Baseline-Klasse
  selbst.
  **Fundmenge, nicht nur Fundort:** Ich bin den Volltext auf Präsens-Aussagen über repo-eigene
  lebende Artefakte durchgegangen. Dies ist die **einzige** Stelle, die keine Ref, keinen festen
  Commit und keinen Zeitbezug trägt. Alle übrigen tragen einen: die Datei-Menge und die
  Eröffnungssätze laufen gegen `7485be3`; die Typkarten-Aussage steht als *„Stand des Commits"*;
  `20a3e33` und `b39d4ff` sind feste Commits; *„AGENTS.md §3.8 zeigt **heute** auf ADR-0024"* und
  *„Die heute lebenden Dateien"* tragen das Zeitwort; die Register-Übernahme ist in §Mess-Basis
  ausdrücklich geregelt. Beide `AGENTS.md`-Aussagen habe ich zusätzlich nachgemessen
  (`grep -c 'ADR-0024' AGENTS.md` → **1**, `grep -c 'ADR-0028' AGENTS.md` → **0**) — sie stimmen.
  **Abgrenzung, damit der Befund nicht überzogen wird:** Die **Entscheidung fällt dadurch nicht.**
  Der Kern des Anlasses ist der Satz, den die ADR selbst hervorhebt — *„Der Kern des Befunds ist
  nicht, dass der Implementer falsch entschieden hätte — sondern dass er allein entschieden hat,
  wo keine Quelle die Rolle benennt"* —, und der ist von der späteren Nachlieferung unberührt;
  der auslösende Review (`2026-08-31-slice-144-review.md`, HIGH-1) existiert und sagt, was die ADR
  ihm zuschreibt (das `AGENTS.md`-§3.8-Zitat steht dort **1** mal). Betroffen ist die
  Anlass-Erzählung, nicht die Prämisse und nicht eine der drei Festlegungen.
- **verifizierbar:** ja, aber **nicht durch ein Gate** — `grep -m1 '^modules:' .d-check.yml` →
  `modules: [links, anchors, ids, matrix, codepaths, spans]`; keines hält einen Satz gegen die
  Datei, über die er spricht. `MR-040` verlangt Ausgänge für Präsens-Aussagen über den **vendored
  Baum** und erreicht diese Klasse nicht; `MR-025` bindet **Zahlen**. Bestätigt wird der Befund
  durch die drei `git show <ref>:… | grep -c 'slice-mv'`-Läufe (**0 · 3 · 3**) und
  `git log -S'make slice-mv' -- .claude/commands/implement-slice.md` → **`fc1fc54`**.
- **klasse:** „Präsens-Aussage über ein repo-eigenes lebendes Artefakt ohne Ref und ohne
  Zeitbezug, in einem Artefakt, das eingefroren wird"

### MEDIUM-2 — Der Slice, der die Annahme trägt, rechnet unverändert mit `BEO-007` bei 1×; die Zeile steht bei 4× und führt einen dreigeteilten Ausgang

- **kategorie:** MEDIUM
- **quelle:** `MR-025` Setzung 1; Modul 6 §Das Beobachtungs-Register (Sichtungs-Schritt)
- **pfad:** `docs/plan/planning/done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md:110-113`
  und `:230`
- **befund:** Der Plan sagt in §2 DoD *„der Zähler bleibt bei 1×"* und in §8
  *„`BEO-007` steht im Register (Sub-Area `*`, 1×, …)"*. Gemessen steht die Zeile an `HEAD` **und**
  an `7485be3` bei **4×** mit vier Belegen und führt ihren Ausgang bereits dreigeteilt
  (Command-Artefakte → `ADR-0028` · `.claude/agents/*.md` → `ADR-0029` · Spec-Straten →
  `slice-151`). Der Plan ist seit Runde 2 inhaltlich nicht angefasst worden — sein letzter Commit
  ist ein `welle-mv`-Verweis-Nachzug (`git log --oneline -1 -- <plan>` → `0146108`).
  **Failure-Szenario:** Der Closure-Lauf des Slice schreibt die `Stand`-Zelle gegen einen
  Zähler-Stand, den er falsch annimmt, und setzt die Zeile auf *verkörpert*, obwohl zwei ihrer
  drei Teile offen bleiben — genau das, wovor der zweite Positiv-Punkt der ADR warnt.
  **Abgrenzung:** Hängt **nicht** am ADR-Text. Der ADR-Text ist an dieser Stelle korrekt: er nennt
  4×, trennt die drei Teile und sagt ausdrücklich *„Welchen Ausgang die Registerzeile am Ende
  trägt, entscheidet die Closure, die sie schreibt — nicht diese ADR."* Adressat ist der
  **Planner**, nicht der Architect.
- **verifizierbar:** ja — `grep -n '1×' <plan>` gegen
  `awk -F'|' '$2 ~ /BEO-007/{print $5, $6}' docs/plan/planning/observations.md`. Kein Gate.
- **klasse:** „Slice-Plan rechnet mit einem Register-Zähler, den das Register nicht mehr trägt"
  (**vierter** Lauf mit demselben Befund)

### INFO-1 — Die Klasse, die die ADR regelt, ist seit ihrer Mess-Basis ein weiteres Mal aufgetreten; der Cutoff deckt sie, und Re-Evaluierungs-Trigger 4 zählt sie nicht

- **kategorie:** INFO
- **quelle:** Maintainability; ADR-0028 §Cutoff und Re-Evaluierungs-Trigger 4
- **pfad:** `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:171-175`
- **befund:** §Kontext sagt an der gepinnten Basis korrekt: *„Der eine Treffer ist `20a3e33`"*.
  An `HEAD` sind es zwei — `git log --format='%s' HEAD -- .claude/commands/ | grep -c '^Rolle '`
  → **2**. Der zweite ist `ba0c5bb` *„Rolle Planner: slice-165 …"* (2026-09-03), und er berührt
  `.claude/commands/close-welle.md` **und** `.harness/skills/reviewer.md`
  (`git show ba0c5bb --stat --format=`) — nach Festlegung 1 Planner- **und** Reviewer-Territorium,
  also derselbe Cross-Role-Zuschnitt wie beim genannten `20a3e33`. **Kein Vorwurf an die ADR:**
  ihr Wert ist gepinnt, als *kein Erwartungswert* gekennzeichnet und an seiner Basis exakt, und
  der Cutoff (*„geprüft wird ab dem Commit, der diese ADR annimmt"*) deckt den Fall ausdrücklich.
  Die Beobachtung ist für den Planner: Re-Evaluierungs-Trigger 4 (*„wenn die Klasse ein weiteres
  Mal ohne Träger auftritt, **obwohl der Träger jetzt steht**"*) beginnt erst mit dem
  Annahme-Commit zu zählen, dieser Fall bleibt also ungezählt — und er zeigt zugleich, dass die
  Lücke, die die ADR schließt, zwischen Entwurf und Annahme weiter wirkt.
- **verifizierbar:** ja — die zwei `git log`-Läufe und `git show ba0c5bb --stat --format=`.
- **klasse:** „Regelungsbedürftige Klasse tritt zwischen Entwurf und Annahme erneut auf"

### INFO-2 — `ADR-0029` steht unverändert mit dem abgelösten Tag da

- **kategorie:** INFO
- **quelle:** Maintainability; `ADR-0016` Festlegung 3 (a)
- **pfad:** `docs/plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md`
- **befund:** Wortgleich zu INFO-1 der Vorrunde und hier nur als *weiterhin offen* geführt: die
  zweite `Proposed`-ADR derselben Familie nennt im ganzen Dokument **einen** Tag, und es ist
  `v5.12.0` (`grep -o 'v5\.[0-9]*\.[0-9]*' docs/plan/adr/0029-*.md | sort | uniq -c` → `1 v5.12.0`;
  kein Erwartungswert). Sie stützt sich in Festlegung 1 auf ADR-0028 und steht vor demselben
  Übergang und derselben Vorbedingung. Seit `5cee53e` ist sie nicht angefasst worden. Kein
  Vorwurf an ADR-0028; Gegenstand des Laufs, der `slice-152` trägt.
- **verifizierbar:** ja — das `grep -o | sort | uniq -c` oben und
  `git log --oneline -- docs/plan/adr/0029-*.md`.
- **klasse:** „Baseline-Beleg gegen einen abgelösten Stand in einem Artefakt, das eingefroren
  werden soll" (Wiederholung im Geschwister-Artefakt)

## Negativbefunde

- **Prüfpunkt 1 — die elf Verbatim-Proben, wie abgedruckt:** geprüft, **kein Befund**. Alle elf
  geben **1**. Verortung jeder Fundstelle über die Überschriften-Liste ihrer Datei geprüft, nicht
  über die Behauptung der ADR: §Konflikt-Pfad als Rollen-Sequenz (Proben 1+2, `modul-08:230-232`),
  §Welche Rolle braucht welche Artefaktklasse (Probe 3, `:166`), die **zweite Zeile** der
  Verdikt-Tabelle desselben Abschnitts (Probe 4, `:212` — die Reihenfolge nachgezählt, sie ist die
  zweite), §Rollen-Sequenz für eine Welle (Probe 5, `:69`); §Wellen-Closure-Prozedur (Proben 6 und
  11, `modul-06:173` und `:248`) und §Das Beobachtungs-Register (Probe 7, `:112`); §Reviewer
  berichtet auch, was er nicht gefunden hat (Probe 8, `modul-10:114-115`); §Vier Trigger-Klassen
  (Probe 9, `grundlagen-bootstrap:196`); §Hard Rule für Accepted-ADRs (Probe 10, `modul-04:45`).
  Die **Vollzeile** der Verdikt-Tabelle, die die ADR als Codeblock abdruckt, ist zeichengleich mit
  `modul-08:212`. **Methodischer Hinweis:** ein erster Lauf gab bei Probe 10 **0** aus — Ursache
  war meine eigene Shell-Quotierung der Backticks im Zitat, nicht die ADR; roh nachgefahren gibt
  sie **1**. Das ist genau `BEO-021` im Register (*„ein `grep` auf einen zitierten Baseline-Satz
  gibt 0 aus, obwohl der Satz wörtlich am geprüften Stand steht"*), und die Fehlerrichtung ist die
  dort beschriebene.
- **Prüfpunkt 2 — die zwei `v5.12.0`-Zitate der Geschichte-Zeile vom 2026-08-31:** geprüft, **kein
  Befund**. Die einzige `v5.12.0`-Nennung der Datei steht in der Zeile, die ihre **eigene** Runde
  datiert. Beide Wortlaute standen an jenem Stand so — gemessen am Baum vor der Re-Baseline
  (`db83415^`): der Konflikt-Pfad-Satz in `modul-08-agentenrollen.md` → **1**, der
  Acceptance-Trigger in `grundlagen-bootstrap.md` → **1**, und beide genannten Abschnitte
  (`### Konflikt-Pfad als Rollen-Sequenz`, `#### Vier Trigger-Klassen`) existierten dort ebenfalls.
- **Prüfpunkt 3a — Widerspruch zu `ADR-0015` (Accepted):** geprüft, **kein Befund**. Festlegung 2
  weist den ausgenommenen Teil keiner Rolle zu (*„Über diesen Teil sagt diese ADR nichts, und sie
  weist ihn auch keiner Rolle zu"*) und §Was hier NICHT entschieden ist führt ihn auf. Alle drei
  `ADR-0015`-Zitate treffen nach Whitespace-Normalisierung je **1** mal. ADR-0028 besetzt
  ausschließlich Artefakte, für die `ADR-0015` die Frage offen ließ; kein `Supersedes` nötig,
  keiner behauptet.
- **Prüfpunkt 3b — Widerspruch zu `ADR-0024` (Accepted):** geprüft, kein Befund. Verschiedene
  Gegenstände (derivatives **Register** ↔ **Anweisungssatz**). Beide übernommenen Zitate treffen
  je **1** mal; das Mess-Basis-Zitat, sobald die Auszeichnung der Quelle entfernt ist — genau die
  Normalisierung, die `ADR-0016` Festlegung 2 als *verbatim* definiert. Die
  Artefaktklassen-Tabelle aus Modul 8 wird in §Kontext ausdrücklich **nicht** als
  Eigentums-Aussage gelesen, mit dem `ADR-0015`-Zitat daneben.
- **Prüfpunkt 3c — Widerspruch zu `ADR-0016` (Accepted):** geprüft, kein Befund **nach der
  Korrektur**. Festlegung 2 im Volltext gelesen: drei Teile je Beleg, und *„**Nicht** dazu gehören
  der lokale Präfix `.harness/baseline/<tag>/` und die Zeilennummer als alleiniger Locator."*
  Gemessen trägt die ADR **null** Markdown-Links in den vendored Baum
  (`grep -c ']([^)]*\.harness/baseline/' <ADR>` → **0**); die fünf lokalen Pfade stehen als
  Shell-Variablen im Proben-Block und einer als `grep`-Operand in Re-Evaluierungs-Trigger 1 — also
  als **Gegenstand** einer Messung, nicht als Adresse eines Belegs. Dass diese Unterscheidung
  zulässig ist, sagt `ADR-0016` §Geschichte für sich selbst (*„die zwei verbliebenen Nennungen
  benennen das Verzeichnis als **Gegenstand der Sonde**, nicht als Adresse eines Belegs"*, **1**
  Treffer). Keine Zeilennummer als alleiniger Locator mehr, seit HIGH-1 behoben ist.
- **Prüfpunkt 3d — `ADR-0025` und `ADR-0029` (beide `Proposed`, nicht bindend):** geprüft, kein
  Befund über INFO-2 hinaus. Eine Annahme von ADR-0028 nimmt `ADR-0029` nichts vorweg; deren
  Gegenstand ist genau die Frage, die Festlegung 3 offenlässt.
- **Prüfpunkt 4 — Report-Verweise:** geprüft, kein Befund. `grep -c 'docs/reviews' <ADR>` → **0**;
  kein Markdown-Link zeigt dorthin; alle **fünf** Report-Nennungen (Zeilen 54, 443, 444, 445, 446)
  sind blanke Kennungen in Backticks. Der Begründungs-Absatz am Ende von §Verbatim-Proben ist gegen
  beide Quellen gehalten, und beide Verortungen stimmen (Prüfpunkt 1).
- **Prüfpunkt 5 — Festlegung 3, Zirkularität und Cross-Check-Orte:** geprüft, kein Befund. Die
  Ausnahme ruht auf gemessenen Eigenschaften, nicht auf ihrem Ergebnis: `ls .claude/agents/*.md |
  wc -l` → **6**; `b39d4ff` ändert real `reviewer.md` (8 Zeilen) und `verifier.md` (8 Zeilen) in
  einem Commit; die sechs kanonischen Namen stehen in `spec/spezifikation.md` §5
  (`architect, implementer, planner, reviewer, validator, verifier`); `roleFromAgentType` existiert
  in `internal/span/emit.go:182`. Die `MR-018`/`MR-021`/`MR-030`-Kette gibt die ADR korrekt wieder
  — `MR-021` hebt `MR-018` *„**vollständig** auf"* und verlagert die Feldtabelle nach
  `spec/spezifikation.md` §5, `MR-030` verlagert nichts und löst allein die Abweichung
  *„`implementer` statt Implementation"* auf. Re-Evaluierungs-Trigger 3 benennt die Bedingung,
  unter der die Begründung fällt.
- **Prüfpunkt 6 — Festlegung 1, die Planner-Zuordnung der Wellen-Closure:** geprüft, kein Befund.
  Die Träger-Spalte der Tabelle in `modul-08` §Rollen-Sequenz für eine Welle führt für **3a, 3c,
  4, 5 und 6** je **Planner**; die Closure-Prozedur in `modul-06` hat gemessen **sechs**
  nummerierte Schritte. Die Folgerung der ADR (*„Der Planner ist also die Rolle, die den Ablauf
  **hält** und die anderen anruft"*) gibt die Tabelle zutreffend wieder, einschließlich der
  Rollenwechsel in 1, 2 und 3b.
- **Prüfpunkt 7 — die tragende Negativ-Prämisse gegen den heute bindenden Stand:** geprüft, **sie
  trägt**. `grep -rl 'claude/commands' .harness/baseline/v5.18.0/` → **eine** Datei,
  `grundlagen-durchsetzungsschicht.md`; die Fundstelle im Volltext gelesen (Zeile 96) ist ein
  Listenpunkt der Durchsetzungsschicht — *„`.claude/commands/*.md` — Workflow-Skelett als
  Slash-Command"* —, **ohne jede Rollen-Aussage**. Re-Evaluierungs-Trigger 1 hat **nicht** gefeuert.
- **Prüfpunkt 8 — Prämisse von Folgepflicht 1:** geprüft, kein Befund. `grep -c 'ADR-0024'
  AGENTS.md` → **1**, `grep -c 'ADR-0028' AGENTS.md` → **0**; §3.8 zeigt weiterhin nur auf
  `ADR-0024`, und die ADR schreibt `AGENTS.md` erklärtermaßen nicht — am Diff eingehalten,
  `c520331` berührt genau **eine** Datei.
- **Prüfpunkt 9 — `LH-QA-01` (keine halluzinierten Gates):** geprüft, kein Befund. §Fitness
  Function behauptet ausdrücklich **kein** Gate; die aufgezählten Module sind deckungsgleich mit
  `grep -m1 '^modules:' .d-check.yml` → `[links, anchors, ids, matrix, codepaths, spans]`, und
  beide genannten `mutate`-Fehlschlag-Formen stehen im Werkzeug (`grep -c -- '--- FAIL:'
  harness/tools/mutate.sh` → **2**, `grep -c 'not ok'` → **2**). Der `LH-QA-01`-Anker existiert
  (`spec/lastenheft.md:320`).
- **Prüfpunkt 10 — die Spec-Straten-Abgrenzung:** geprüft, kein Befund. Die ADR sagt, zwei der
  vier Belege lägen außerhalb von `.claude/commands/` und beträfen die Spec-Straten. Gemessen:
  `slice-147` heißt *„`spec/spezifikation.md` trägt ihr `SPEC-<NNN>`-Pflichtfeld"*, `slice-148`
  *„`spec/architecture.md` trägt ihr `ARC-<NNN>`-Pflichtfeld"*; beide liegen in `done/` und tragen
  ihren `BEO-007`-Ausgang *weiter offen*. Die Abgrenzung stimmt.
- **Prüfpunkt 11 — Ziel-Form der ADR-Vorlage (`v5.18.0`):** geprüft, kein Befund. Kopf (`Status`,
  `Datum`, `Autor`, `Bezug`, `Schärft`) und alle sieben Pflicht-Abschnitte stehen in der
  Vorlagen-Reihenfolge; §Verbatim-Proben ist ein **Anhang vor** §Geschichte, kein Ersatz. Der
  Immutabilitäts-Schlusssatz steht und nennt `v5.18.0`. Der ADR-Index führt die Zeile mit Status
  `Proposed` (`docs/plan/adr/README.md:35`).
- **Prüfpunkt 12 — `AGENTS.md` §3.7 (Zustandsfeld trägt keine Chronik):** geprüft, kein Befund.
  Das `**Status:**`-Feld trägt den Zustand und sonst nichts; die Geschichte-Tabelle ist der von der
  Vorlage vorgesehene Provenienz-Ort, kein Zustandsfeld und kein lebendes Register — die dortige
  Nennung des entfernten `Umgangen`-Zitats steht im Präteritum und beschreibt den Befund, nicht die
  heutige Datei.
- **Prüfpunkt 13 — `AGENTS.md` §3.9 (Docker-only):** eingehalten. Der einzige Toolchain-Lauf dieses
  Reviews ist `make docs-check`; alles Übrige sind `git`, `grep`, `awk`, `sed`, `tr`.
- **Prüfpunkt 14 — Doku-Gate nach der Korrektur:** geprüft, **grün**. `make docs-check` →
  `d-check: 564 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Alle 15 Link-Ziele der ADR lösen auf,
  einschließlich der vier `MR-018`-Anker, die auf einen aufgehobenen Eintrag zeigen (Kopf und
  Zeiger bleiben, wie `MR-021` es festlegt).
- **Nicht geprüft (bewusst außerhalb dieses Laufs):** der **Inhalt** der drei Commands, der
  Skill-Datei und der sechs Typkarten; die DoD-Abhakung und der repo-weite Gate-Lauf von
  `slice-145` (Verifier, Modul 11); die innere Konsistenz von `ADR-0029` (eigener Gegenstand,
  eigener Lauf); die **Form** der `Stand`-Zelle von `BEO-007` (Planner-Artefakt — hier nur auf
  Bezeichnung, Zähler und Belege gelesen); `make gates` als Ganzes.

## Kategorie-Summary

- HIGH: 0
- MEDIUM: 2 (davon **einer** am ADR-Text, **einer** am Planner-Artefakt)
- LOW: 0
- INFO: 2

**Finding-Klassen dieses Laufs (für die Slice-Closure §7 und den Zähler):**
„Präsens-Aussage über ein repo-eigenes lebendes Artefakt ohne Ref und ohne Zeitbezug, in einem
Artefakt, das eingefroren wird" · „Slice-Plan rechnet mit einem Register-Zähler, den das Register
nicht mehr trägt" · „Regelungsbedürftige Klasse tritt zwischen Entwurf und Annahme erneut auf" ·
„Baseline-Beleg gegen einen abgelösten Stand in einem Artefakt, das eingefroren werden soll"
(Wiederholung im Geschwister-Artefakt).

**Das ist die vierte Runde mit derselben Klammer, und sie bricht jedes Mal enger.** Runde 1: den
acht Baseline-Belegen fehlte der Tag. Runde 2: der Tag war ein anderer geworden. Runde 3: ein
Beleg trug eine Ordnungszahl statt des Zitats, und ein Register-Zitat hatte gar keine Basis.
Runde 4: die letzte Aussage der Datei ohne Ref und ohne Zeitwort ist falsch. Dieselbe Ursache
trägt alle vier — *eine Aussage über einen wandernden Bestand wird in dem Moment eingefroren, in
dem niemand sie mehr korrigieren darf* —, und die Trägerschaft fehlt weiterhin für genau die
Hälfte, die diesmal traf: `ADR-0016` Festlegung 2 bindet **Baseline**-Belege, `MR-040` bindet
Präsens-Aussagen über den **vendored Baum**, `MR-025` bindet **Zahlen**. Für eine Präsens-Aussage
über eine **repo-eigene lebende Datei** benennt keine Quelle eine Form. Runde 3 hat das benannt;
ein Registereintrag dafür existiert weiterhin nicht — `BEO-017` erfasst die verwandte, aber andere
Klasse (tote **Adresse** durch einen vorgeschriebenen Ortswechsel, 2×), `BEO-009` die Zusage neben
einer korrigierten Ableitung (7×). Wohin der Eintrag gehört, entscheidet nicht dieser Report;
**dass** er fällig ist, ist nach dem vierten Auftreten keine Notiz mehr. Bemerkenswert dabei: die
Korrektur `c520331` hat die Form der Baseline-Belege vollständig hergestellt — die Klasse ist
nicht ungelöst, sie ist nur auf der repo-eigenen Seite unbewacht geblieben.

## Verdikt

**Inhaltlicher Einwand: nein — zum dritten Mal in Folge. Konsistenz: NICHT bestätigt; der
Statuswechsel bleibt blockiert. ADR-0028 bleibt `Proposed`.**

Die Prüfung trennt dieselben zwei Dinge wie die Runden davor, und die erste Hälfte ist jetzt
vollständig:

1. **Die Entscheidung trägt, und sie trägt gegen den heute bindenden Stand — die Beleg-Form
   ebenfalls.** Beide Befunde der Runde 3 sind an der ADR **behoben**, einzeln nachgemessen statt
   abgehakt: der neue Beleg trägt Tag, Dateiname, Abschnittsname und Zitat, das Zitat löst an
   `v5.18.0` genau einmal auf und liegt im genannten Abschnitt; das tote Register-Zitat ist fort
   und durch Bezeichnung, Zähler und Belege ersetzt, die an **beiden** Refs auflösen und die
   `ADR-0028` nicht zurückzitieren — nicht zirkulär. Auch beide LOWs sind behoben. **Alle elf**
   Verbatim-Proben geben 1, jede Verortung ist gegen die Überschriften-Liste ihrer Quelldatei
   geprüft, alle gepinnten Zahlen stimmen an ihrer Basis, ein Widerspruch zu `ADR-0015`,
   `ADR-0016` oder `ADR-0024` besteht nicht, Festlegung 3 ist nicht zirkulär, die tragende
   Negativ-Prämisse hält, `LH-QA-01` ist gewahrt, `make docs-check` ist grün. Der Baum hat sich
   seit `c520331` **nicht** bewegt. Die Rückführungen aus Slice-Plan §4 sind **nicht** ausgelöst.

2. **Ein Satz steht dem Übergang noch entgegen, und er ist neu gemessen, nicht neu erfunden.**
   MEDIUM-1 friert die Anlass-Erzählung in einem Zustand ein, den die Datei seit dem 2026-08-31
   um 10:11 nicht mehr hat — falsch an `HEAD` **und** an der Mess-Basis, die die ADR selbst
   deklariert, und ohne das Zeitwort, das die Plan-Datei an derselben Aussage führt. Kein aktives
   Norm-Artefakt verbietet die Form (das ist der Steering-Loop-Befund oben), aber `AGENTS.md`
   §3.4 friert sie ein: **jetzt** ist es ein Wort, **nach** der Annahme eine Folge-ADR. Das ist
   dieselbe Klasse und dieselbe Kategorie, mit der Runde 3 blockiert hat; sie hier durchzulassen,
   hieße den Maßstab zwischen zwei Runden zu senken, statt ihn zu halten.

**Ich sage das ausdrücklich, weil der Auftrag den Freigabe-Punkt benennt: Freigabe erteile ich
nicht.** Es fehlt eine Ein-Satz-Korrektur, keine Überarbeitung. Kommt sie, sehe ich nach heutigem
Stand nichts mehr, was einer Annahme entgegensteht — die Entscheidung selbst, ihre Baseline-Belege,
ihre Repo-Belege, ihre Struktur und ihr Verhältnis zu den drei bindenden ADRs sind geprüft und
tragen.

**Übergabe.** Der Weg steht im Plan: §6 Risiko 1, Ausgang *eingetreten* — *„die ADR wird vor der
Annahme korrigiert (sie ist noch `Proposed`, keine Folge-ADR nötig) — Beleg in der
Geschichte-Tabelle."* Adressat ist der **Architect** als Rolleninhaber von DoD (1); dieser Report
ist das Übergabe-Artefakt. Zu klären ist **MEDIUM-1**; MEDIUM-2, INFO-1 und INFO-2 blockieren
nicht. Nach der Korrektur ist eine fünfte Runde fällig (neue Datei; dieser Report wird nicht
überschrieben) — sie hat gemessen einen Gegenstand: den korrigierten Satz.

**Zwei Posten adressieren den Planner, nicht den Architect:** MEDIUM-2 (der Plan rechnet mit
`BEO-007` bei 1×, vierter Lauf mit demselben Befund) und der Steering-Loop-Befund der
Kategorie-Summary (vierte Instanz derselben Klammer, ohne Registerzeile und ohne Träger für die
repo-eigene Hälfte). Beide hängen nicht am ADR-Text.

**Kein Rollen-Konflikt.** Kein Finding dieses Laufs widerspricht einer Position, die der
Architect-Lauf vertreten hätte — MEDIUM-1 betrifft einen Satz, den keine der drei Korrekturen
angefasst hat, und die Korrektur `c520331` selbst ist in beiden Befunden bestätigt worden. Der
Konflikt-Pfad aus Modul 8 §Konflikt-Pfad als Rollen-Sequenz ist **nicht** auszulösen.

**Dieser Report ersetzt keine Verifikation** — DoD-Abhakung und repo-weiter Gate-Lauf prüft der
Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
