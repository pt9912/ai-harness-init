# ADR-0021 (Proposed) — Bestätigungsrunde 2 vor der Annahme

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-22. **Lauf:** frischer Kontext, Subagent
`reviewer`, **zweite** Runde zu dieser ADR.

**Review-Art:** Design-Review — geprüft wird die überarbeitete ADR **gegen die ADR-Lage, gegen das
Regelwerk und gegen die Findings der ersten Runde**, vor dem Statuswechsel, den
[`AGENTS.md`](../../AGENTS.md) §3.4 unumkehrbar macht.

**Gegenstand:** `7d04e3d` — ein Commit, zwei Dateien,
`docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md` (+276/−58, jetzt 639 Zeilen, fünf
Festlegungen, sieben Folgepflichten) und die Index-Zeile `docs/plan/adr/README.md:29`. Gegenlage:
`061e74b` (Runde-1-Report). HEAD `7d04e3d`, Arbeitsbaum vor und nach dem Lauf sauber.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-22

**Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan-Bezug, Modul 10 §Eingangs-Kontext):**

- **Diff/Range:** `061e74b..7d04e3d`, beschränkt auf die zwei genannten Dateien (selbst am
  `--name-only` geprüft).
- **Betroffene `LH-*`:** `LH-QA-01`, `LH-QA-02`, `LH-QA-03`.
- **Referenzierte aktive ADRs (Status je selbst geprüft):** `ADR-0011`, `ADR-0012`, `ADR-0016`,
  `ADR-0017`, `ADR-0019`, `ADR-0020` (alle **Accepted**); dazu
  `docs/plan/carveouts/CO-002-token-achse-je-rolle.md` und `CO-001-bats-shell-lint.md` (beide
  *Aktiv*), `docs/plan/carveouts/README.md`, `spec/spezifikation.md` §5,
  `docs/plan/planning/welle-09-modul-15-konformitaet.md` §3, `.d-check.yml`,
  `harness/conventions.md` §MR-025.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.1–§3.8.
- **Vorherige Findings am gleichen Modul:**
  [`2026-08-22-adr-0021-bestaetigungsrunde.md`](2026-08-22-adr-0021-bestaetigungsrunde.md)
  (3 HIGH / 3 MEDIUM / 2 LOW / 2 INFO — jedes unten mit Status und Beleg), dazu
  `2026-08-16-adr-0020-bestaetigungsrunde.md` und
  `2026-08-15-adr-0019-bestaetigungsrunde{,-runde-2}.md`. Wiederkehrende Klassen, hier gezielt
  gesucht: *Zusage weiter als ihr Sensor* (Runde 1 HIGH-3 — behoben), *Status-Schnappschuss, den
  ein Accept falsch macht* (traf nicht, trifft wieder nicht), *Zahl ohne ihr Kommando* (traf als
  INFO, trifft jetzt als MEDIUM).
- **Plan-Bezug:** `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md` — er trägt den
  Vollzug und ist von der Ort-Entscheidung substanziell betroffen (nicht mein Prüfgegenstand;
  Zuordnung unten).

**Nicht meine Rolle:** DoD-Abhakung, Gate-Lauf als Erfolgsmeldung, Lösungsvorschläge, Änderungen an
der ADR (Modul 10 §Anti-Pattern). **Nichts committet, außer diesem Report nichts geschrieben.**
Alle Sonden liefen in Wegwerf-Kopien **außerhalb** des Repos; die Kopien sind nach dem Lauf
entfernt.

**Dieselbe Selbstbeschränkung wie in Runde 1, und sie ist jetzt ausdrücklich gedeckt:** Ich habe
den Span-Bestand nicht geöffnet. Festlegung 3 dritter Punkt sagt in der neuen Fassung selbst, dass
das der richtige Weg ist (*„Ein Reviewer muss den Bestand dafür nicht öffnen"*). Wo eine Zahl aus
dem Bestand nötig war, habe ich `make span-report` gefahren — nach
[`AGENTS.md`](../../AGENTS.md) §4 ein **Bericht, kein Sensor** — und die Berichtszeile zitiert.

**Selbst gefahren — Kommando und Ergebnis, nichts davon übernommen:**

| Kommando | Ergebnis |
|---|---|
| `make docs-check` (Ist-Stand `7d04e3d`) | `338 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| **Sonde A** — Wegwerf-Kopie, `git mv docs/plan/carveouts/CO-002-*.md docs/plan/carveouts/done/`, dann derselbe digest-gepinnte d-check wie in `make docs-check` | **`81 Befund(e)`**, Exit 1, alle `target-missing`. Verteilung: `done/CO-002…` 13 · **`ADR-0019` 13** · `slice-071` 10 · `slice-086` 8 · **`ADR-0021` 8** · `slice-062` 6 · `spec/spezifikation.md` 5 · **`ADR-0020` 5** · `welle-09` 4 · `slice-089` 3 · `adr/README.md` 3 · `slice-074` 1 · `roadmap.md` 1 · `carveouts/README.md` 1 |
| **Sonde B** — dieselbe Kopie, `links.resolve-from` mit `dirs: [docs/plan/carveouts, docs/plan/carveouts/done]` | **`84 Befund(e)`**, Exit 1 — 81 `target-missing` **plus drei neue `link-position-dependent`**, und die drei treffen [`CO-001`](../plan/carveouts/CO-001-bats-shell-lint.md) (2) und `docs/plan/carveouts/README.md` (1), nicht CO-002 |
| **Sonde B′** — dieselbe Option **mit** `fixed-dirs: [docs/plan/adr]` (die Variante, die für den Lifecycle-Fall gebaut ist) | ebenfalls `84`; die **18** Befunde in den zwei eingefrorenen ADRs bleiben **unverändert** stehen (selbst gezählt) |
| **Sonde C** — dieselbe Kopie, `codepaths.ignore-refs: [docs/plan/carveouts/**]` | **`81 Befund(e)`**, Exit 1 — **unverändert** gegenüber Sonde A; die Befunde entstehen im Modul `links` |
| `docker run … d-check@sha256:3996a59… --print-config` | `links` trägt **genau eine** Options-Sektion, `resolve-from` (mit `dirs` und `fixed-dirs`), und sie ist **verschärfend** formuliert: *„Dateien hier muessen von JEDEM Ort der Gruppe aufloesen (>= 2)"*. Ein referenz- oder datei-weiter Ausschluss **innerhalb** `links` existiert nicht; `codepaths.ignore-refs` ist referenz-weit, aber modul-lokal |
| **Sonde D** — Wegwerf-Kopie, die zwei Cache-Zähler aus `responseKeys()` in `internal/span/response.go` entfernt (der `sed` aus der ADR), dann `make test-go` | **`--- FAIL: TestNoResponseFreetextReachesSpan`**; `TestOnlyAgentToolGetsResponseValues` bleibt **grün** — genau wie die ADR es sagt |
| **Sonde E** — Wegwerf-Kopie, **Weg 3**: Status-Zeile im Stub (`Permanent — übergeführt in ADR-0021`, als Link) und eigener Index-Abschnitt in `docs/plan/carveouts/README.md`, **kein** Move | **`0 Befund(e)`**, Exit 0 — die gewählte Form ist grün |
| `grep -oE '\]\([^)]+\)' <F> \| wc -l` u. a. über `ADR-0019` / `ADR-0020` / `ADR-0013` | 49 / 66 / **27** Link-Vorkommen · 18 / 23 / 12 eindeutige Ziele · 21 / 56 / 18 Kennungen · 6 / 6 / 4 Inline-Code-Pfade — **alle sechs Zahlen der ADR und die 27 aus [ADR-0017](../plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) exakt getroffen** |
| dasselbe Kommando über **alle** ADRs, absteigend | `0021` 99 · `0020` 66 · `0019` 49 · `0012` 43 — *„zwei der größten ADRs"* trifft zu (ADR-0021 selbst steht nicht zur Wahl) |
| `grep -ln 'responseKeys' test/mutations/*.sh` | **leer, Exit 1** — die Behauptung der dritten Fitness-Zeile trägt |
| `head`/`tail` über `test/mutations/123` und `127` | 123 **fügt** `content` in die Positiv-Liste ein, 127 negiert die **Grenze** — die Richtungs-Aussage der ADR trägt |
| `grep -n 'done/' docs/plan/adr/0021-*.md` | 9 Treffer, **alle** entweder Modul-/ADR-Zitat, Sonden-Kommando, die Negativ-Aussage selbst, `CO-001` oder der Re-Evaluierungs-Trigger — **keine Rest-Sprache aus Runde 1** |
| `grep -n 'slice-[0-9]' docs/plan/adr/0021-*.md` | **leer, Exit 1** — keine Slice-Adresse |
| `grep -n 'd-check:ignore' docs/plan/adr/0021-*.md` | **leer, Exit 1** — die Direktive aus Runde 1 ist entfallen |
| `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` | weiterhin **sechs Zeilen in zwei Dateien** — die Vorbedingung des neuen Prüfkommandos aus Folgepflicht 2 |
| `make span-report` (zweimal an diesem Tag) | `Abdeckung: **90** von **159**` (früher Lauf) und `Abdeckung: **90** von **160**` (später Lauf); `Bestand: 8 Sitzung(en), 2026-07-29T08:01:32Z bis 2026-08-22T12:08:19Z` — der Zähler steht, der Nenner wächst |
| `git show --pretty=format: --name-only 7d04e3d` | genau die zwei Architect-Artefakte; Message beginnt mit *„Rolle Architect:"* (§3.8) |
| `git log -1 --format=%ad --date=iso` für `04067d7` / `7d04e3d` | `12:16:43` / `14:42:15` — **`MR-025` war beim Schreiben dieser Überarbeitung in Kraft** |

**Gelesen, nicht gefahren:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md` §Ziel-Form /
§Werkzeug-Wahl bei Diskrepanz / §Carveout-Audit-Slice (je verbatim gegen die ADR gehalten) ·
`docs/plan/adr/0011-…:148-175` · `0012-…:184-215` · `0016-…:220-280` ·
`0017-…:95-130`, `:132-160`, `:190-205` · `0019-…:212-262`, `:388-453` ·
`0020-…:430-455` · `docs/plan/carveouts/CO-002-…` ganz, besonders `:113` und `:142` ·
`docs/plan/carveouts/README.md` · `spec/spezifikation.md:109`, `:150-260`, `:355-395`, `:460-540` ·
`harness/conventions.md` §MR-025 ganz · `internal/span/response_test.go:65-190` ·
`internal/span/response.go:47-80` · `docs/reviews/2026-08-21-updatedinput-messung.md` §5–§8 ·
`docs/plan/planning/open/slice-089-…`.

---

## Status der Findings aus Runde 1

| Runde 1 | Status | Beleg |
|---|---|---|
| **HIGH-1** — der Move erzeugt 79 tote Verweise, 24 in §3.4-eingefrorenen Dateien | **behoben** | Festlegung 5 ordnet **keinen** Move mehr an (`:369-386`); Folgepflicht 1 sagt ausdrücklich *„Auszuführen ist hier **kein `git mv`**"* und lässt mit ihm die Zwei-Commit-Auflage entfallen. Sonde E: die gewählte Form ist **`0 Befund(e)`**. Der Satz aus Runde 1, `.d-check.yml` bewerte diesen Datei-Zustand nicht, ist ersetzt — die vierte Fitness-Zeile führt `links` jetzt als **Wächter** der Ortsfestigkeit, mit dem Move als Gegenbeispiel |
| **HIGH-2** — *„die Stellen … ziehen auf diese ADR"* war in beiden Formen gate-rot | **behoben** | Festlegung 5 `:391-395` und Folgepflicht 2 `:493-511` kehren die Anweisung um: **Adresse bleibt, Aussage wird nachgezogen**; die Konsequenz `:430-437` sagt jetzt ausdrücklich *„**Das Verdikt selbst steht dort nicht**"* und nennt die `matrix`-Regel als Grund. Meine zwei Sonden aus Runde 1 stehen jetzt in der ADR selbst, mit Befund-Kennung und Exit-Code |
| **HIGH-3** — die Fitness Function belegte Festlegung 2 mit einem Wächter, der vier der neun hält | **behoben** | Die Tabelle nennt jetzt `TestNoResponseFreetextReachesSpan` mit dem verbatim zitierten `mustContain`-Kommentar und führt `TestOnlyAgentToolGetsResponseValues` **daneben** mit dem, was er *nicht* hält. Sonde D bestätigt beide Richtungen exakt |
| **MEDIUM-1** — *„kein Review-Gegenstand"* blieb unaufgelöst | **behoben** | Festlegung 3 hat einen **dritten** Punkt (`:336-342`), der die Klasse benennt: geprüft wird die **Erklärung** der ADR, nicht der Bestand; ADR-0011s dritter Satz *„verbietet nicht, eine Annahme am Span **abzulesen**, sondern den Span zum **Prüfstück** zu machen"*. Die Lesart trägt am Wortlaut, und dieser Lauf konnte danach arbeiten |
| **MEDIUM-2** — Annahme (d) nannte den Ablese-Ort, nicht das Kommando | **teilweise behoben → N-3** | Das Kommando steht jetzt im ADR-Text (`:290`), und Festlegung 3 macht *„im eigenen Text … nicht über einen Verweis auf ein Zeitdokument"* zur Bedingung; die Grenze *„auf einem fremden Checkout gibt dasselbe Kommando nichts aus"* ist ausgesprochen. **Offen bleibt**, dass das genannte Kommando nicht die Zeile auswählt, von der der Satz spricht — Finding **N-3** |
| **MEDIUM-3** — *„die erste Zahl bleibt 0"* war am Tag der Annahme falsch | **behoben, vorbildlich** | Die Konsequenz nennt jetzt **keinen Wert** mehr, sagt *„die erste Zahl **wächst nicht mehr**"*, begründet die Auslassung mit §5 **Abweichung 4** (verbatim) und mit [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2, und sagt sogar voraus, was ich messe: *„`make span-report` gibt auf einer gewachsenen Maschine eine erste Zahl **über null** aus"*. Zwei Läufe an diesem Tag: `90 von 159` und `90 von 160` — Zähler fest, Nenner wandernd. Genau die Vorsicht, die `spec/spezifikation.md:109` für `total_tokens` vormacht |
| **LOW-1** — Regelwerks-Belege ohne Tag/Dateiname | **behoben** | `:120`, `:128`, `:370`, `:421`, `:479` tragen jetzt alle `Regelwerk v3.5.2, modul-07-carveouts.md §<Abschnitt>`; `:105` ist eine Rückreferenz im selben Listenpunkt-Paar. ADR-0016 Festlegung 2 ist damit an allen in Runde 1 benannten Stellen erfüllt |
| **LOW-2** — eingefrorene `d-check:ignore`-Direktive | **behoben** | `grep -n 'd-check:ignore'` über die ADR ist leer — mit dem Move entfiel ihr Anlass |
| **INFO-1** — Zahlen ohne Kommando (Cutoff-geschützt) | **überholt → N-1** | `MR-025` war beim Schreiben in Kraft (12:16 vs. 14:42). Der neue Mess-Block trägt sein Kommando vorbildlich — aber es liefert die genannte Zahl nicht mehr. Finding **N-1** |
| **INFO-2** — DoD-Punkt für den fälligen Mutations-Fall | **behoben** | Folgepflicht 5 verlangt ihn jetzt selbst und zitiert ADR-0012 Folgepflicht 4 dafür verbatim |

**Keine Regression:** kein behobener Punkt ist an anderer Stelle wieder aufgetaucht; die
Ort-Entscheidung hat keinen der acht behobenen Punkte rückgängig gemacht.

---

## Findings

### N-1 — Die tragende Messung der neuen Festlegung ist 81, nicht 79, und der Anteil „in dieser ADR" ist 8, nicht 6 — gemessen mit dem Kommando, das die ADR selbst danebenstellt

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (*„Eine Zahl, die als Messwert auftritt … trägt im selben Absatz das Kommando, das
  **genau sie** ausgibt, und wer sie schreibt, hat es über dem Baum gefahren, von dem sie
  spricht"*) und Setzung 2 (*„die Vorkommen-Zahl in einer Datei, deren Kopf noch bearbeitet wird
  … taugt nicht als Erwartungswert"*); [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:153-157` (Mess-Block),
  `:167-169` (Sonde B/C), `:377-378` (Festlegung 5), `:638` (Geschichte-Zeile) und
  `docs/plan/adr/README.md:29` (zweimal)
- **befund:** Der Mess-Block nennt sein Kommando vollständig und korrekt (Wegwerf-Kopie, `git mv`,
  derselbe Digest). Über `7d04e3d` gefahren liefert dasselbe Kommando **81 Befunde**, nicht 79 —
  und die daraus abgeleitete Aufteilung *„**6 in dieser ADR**"* ist **8**. Die Ursache ist
  mechanisch und die ADR beschreibt sie zwei Bildschirme weiter selbst: die Zahl zählt **auch die
  Verweise in ADR-0021**, und die Überarbeitung hat davon zwei hinzugefügt. Dieselbe Verschiebung
  trifft Sonde B (**84** statt der genannten 82) und Sonde C (81 statt 79). **Die tragenden Zahlen
  stehen dagegen exakt:** 13 in ADR-0019, 5 in ADR-0020, die **18** unbehebbaren, und sogar die
  55 in lebenden Artefakten (81 − 18 − 8 = 55, wie 79 − 18 − 6 = 55). **Und die Einsicht war zur
  Hand:** Folgepflicht 1 kennzeichnet die Datei-Zahl derselben d-check-Ausgabezeile ausdrücklich
  als **kein** Erwartungswert und zitiert dafür `MR-025` Setzung 2 — der Absatz, der es nicht tut,
  steht 300 Zeilen davor.
- **gegenbeispiel:** Der vierte Re-Evaluierungs-Trigger lädt ausdrücklich dazu ein, diesen Stand
  neu zu messen, sobald `links` einen referenz-weiten Ausschluss bekommt. Wer dann das Kommando
  der eingefrorenen ADR fährt und 81 statt 79 liest, hat zwei Möglichkeiten: er hält die
  Entscheidungsgrundlage für überholt und rollt die Ortsfestigkeit auf — oder er gewöhnt sich an,
  ausgewiesene Messungen nicht nachzuzählen. `MR-025` benennt genau die zweite Wirkung als die
  teurere: *„sie entwertet jede Zahl im Repo, auch die richtigen."* Korrigierbar ist der Satz nach
  dem Accept nicht mehr (§3.4).
- **verifizierbar:** ja, gefahren — Sonde A/B/C oben, je mit dem Kommando aus der ADR selbst.
  **Maschinell nicht bewacht:** `MR-025` sagt es selbst — kein Modul von `.d-check.yml` und kein
  `make comment-claims` liest Markdown-Zahlen; die Setzung liegt im Feedforward-Quadranten.

### N-2 — Festlegung 5 stützt sich auf eine Bedingung, die Modul 7 nicht für den Move aufstellt — und die ADR hat drei Absätze zuvor selbst gezeigt, warum sie hier nicht greift

- **kategorie:** MEDIUM
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form (*„**Auflösung ist ein `git mv`
  nach `done/`** (plus Gate-Ausnahme entfernen, `make gates` grün ohne Ausnahmen). Auflösen ohne
  Verschiebung ist eine zweite Lüge …"*); [`AGENTS.md`](../../AGENTS.md) §3.6 (*„benennen, was
  wirklich deckt"*)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:159-161` und `:379-381`
  gegen `:132-140` derselben Datei; dieselbe Aussage in `docs/plan/adr/README.md:29`
- **befund:** Der Kontext-Abschnitt arbeitet zuerst korrekt heraus, dass §Ziel-Form den `git mv` an
  die **Auflösung** bindet und dass *„dieser Carveout keiner der beiden Fälle"* ist — *„er wird
  nicht **aufgelöst** — sein Trigger tritt nie ein"*. Zwanzig Zeilen später wird dieselbe
  Klammer zur *„Bedingung, unter der §Ziel-Form den Move **überhaupt** verlangt"*, und Festlegung 5
  wiederholt das ohne Konjunktiv; die Index-Zeile verdichtet es zu *„die Bedingung, unter der
  Modul 7 den Move verlangt … ist damit nicht erfüllbar"*. Beides zusammen geht nicht: greift der
  Satz hier nicht, kann seine Klammer auch keine Bedingung für diesen Move sein. Hinzu kommt, dass
  die Klammer hier gar keinen Gegenstand hat — [`CO-002`](../plan/carveouts/CO-002-token-achse-je-rolle.md)
  führt als betroffenes Gate ausdrücklich *„keines"*, es gibt also keine *„Gate-Ausnahme zu
  entfernen"*. **Das zweite Bein der Begründung trägt dagegen allein:** die **einzige**
  Modul-Stelle, die für den *übergeführten* Carveout ein Verzeichnis nennt, spricht vom **leeren**
  Stub, und dieser ist keiner — das ist am Wortlaut belegt und von mir nachgelesen.
- **gegenbeispiel:** Ein späterer Carveout wird wirklich **aufgelöst**, während `make gates` aus
  einem unabhängigen Grund rot steht. Jemand zitiert die dann eingefrorene ADR-0021 (oder ihre
  Index-Zeile) für die Regel *„Modul 7 verlangt den `git mv` nur, wenn `make gates` grün ohne
  Ausnahmen bleibt"* und lässt die Datei im aktiven Verzeichnis liegen. Genau das nennt dasselbe
  Modul im selben Satz *„eine zweite Lüge"*. Die Regel steht dann als ADR-Präzedenz im Repo, ohne
  je im Regelwerk gestanden zu haben.
- **verifizierbar:** nein, nicht maschinell — kein `.d-check.yml`-Modul liest, ob eine Ableitung
  trägt. Am Text belegbar:
  `sed -n '/^- \*\*Auflösung ist ein/,+3p' .harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`
  gegen `sed -n '132,140p;159,161p'` der ADR, und
  `grep -n 'Betroffenes Gate' docs/plan/carveouts/CO-002-token-achse-je-rolle.md`.

### N-3 — Annahme (d) nennt jetzt ein Kommando, und es wählt nicht die Zeile aus, von der der Satz spricht

- **kategorie:** MEDIUM
- **quelle:** ADR-0021 Festlegung 3 zweite Bedingung (*„den Ablese-Ort samt dem Kommando, **das ihn
  ausliest**, im eigenen Text"*);
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (*„ein ungefähr passendes Kommando danebenzustellen ist der Fehler, nicht die Lücke"*);
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:284-294` gegen
  `docs/reviews/2026-08-21-updatedinput-messung.md:176-247` und `spec/spezifikation.md` §5
  Abweichung 4
- **befund:** Annahme (d) führt als Kommando
  `grep -h '"tool":"Agent"' .harness/state/spans/*.jsonl | tail -1` und sagt dazu, *„die Zeile des
  Laufs trägt weder `spawned_role` noch einen der vier Zähler"*. Das Kommando gibt die letzte
  `Agent`-Zeile des **gesamten**, nie aufgeräumten Bestands zurück — nach Datei-Reihenfolge, nicht
  nach Zeit —, nicht die Zeile jenes Laufs. Drei Belege ohne Öffnen des Bestands: (1) die ADR sagt
  selbst, das Kommando *„ist am 2026-08-21 über den Bestand **jener Sitzung** gefahren"*, also
  über einen engeren Gegenstand als den, den sie druckt; (2) das Zeitdokument liest die Zeile mit
  `grep -h '"tool":"Agent"' .harness/state/spans/d3ef8106_….jsonl` und hält fest, dass der
  eindeutige Fundschlüssel `tool_use_id` ist, weil `seq` je Strom vergeben wird; (3)
  `spec/spezifikation.md` §5 **Abweichung 4** — von der ADR an anderer Stelle selbst zitiert — sagt,
  dass Altbestände nicht entfernt werden, und `make span-report` weist heute
  `Bestand: 8 Sitzung(en), 2026-07-29 … 2026-08-22` und **160** `Agent`-Läufe aus. `tail -1`
  wählt aus 160 Kandidaten einen aus, ohne Bezug zu dem einen gemeinten.
- **gegenbeispiel:** Ein Reviewer einer künftigen ADR nimmt Annahme (d) als **Muster** für die
  zweite Bedingung von Festlegung 3 — dafür ist sie geschrieben. Er übernimmt die Form
  *„Glob über den Bestand plus `tail -1`"*, und die Bedingung, die die Ablesung nachvollziehbar
  machen soll, benennt fortan eine beliebige Zeile. Damit ist die einzige der drei Bedingungen,
  die überhaupt etwas Konkretes verlangt, entwertet — und der erste Anwendungsfall steht als
  Präzedenz in einer §3.4-immutablen ADR.
- **verifizierbar:** nein, nicht maschinell (kein Modul liest Kommando-Semantik). Ohne Öffnen des
  Bestands belegbar mit `make span-report` (Nenner und Sitzungszahl) und mit
  `sed -n '176,200p;221,247p' docs/reviews/2026-08-21-updatedinput-messung.md`.

### N-4 — Festlegung 5 hebt zwei Anweisungen auf, die im Carveout selbst stehen; weder das Quellen-Inventar noch Folgepflicht 1 nennt sie, und kein Prüfkommando der ADR sieht sie

- **kategorie:** MEDIUM
- **quelle:** [ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) Folgepflicht 1
  (*„Ein zweiter Ort driftet"*, hier als Drift **innerhalb** des benannten Trägers);
  [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code hält"* —
  hier: was der Vollzug erfasst)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:126-140` (das Inventar der
  Ort-Aussagen), `:478-492` (Folgepflicht 1), `:508-511` (Prüfkommandos) gegen
  `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:113` und `:142`
- **befund:** Die ADR inventarisiert sorgfältig, wo **Modul 7** über den Ort spricht — §Ziel-Form,
  §Werkzeug-Wahl, §Carveout-Audit-Slice — und übergeht die vierte Stelle, an der eine
  Ort-Anweisung steht: den Carveout selbst. `CO-002:113` ordnet für genau diesen Ausgang an,
  ihn *„in eine Folge-ADR zu überführen … **und nach `done/` zu verschieben**"*; `CO-002:142` führt
  in der Verifikations-Checkliste *„[ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner
  `git mv`)"* samt der `d-check:ignore`-Direktive, die dieselbe Runde aus der ADR entfernt hat.
  Der Kontext-Abschnitt zitiert aus `CO-002:113` die Sätze **davor und danach** und lässt den
  dazwischen aus. Folgepflicht 1 zählt die Inhaltsänderungen abschließend auf — Status, `Letzte
  Prüfung`, Geschichte-Zeile, Index — und nennt keine der beiden Stellen; Festlegung 5 sagt zur
  Checkliste nur allgemein, es blieben *„die Architektur-Folgen"*. Beide Prüfkommandos von
  Folgepflicht 2 (`grep -n 'CO-002' …` über Spec und Guard; `make docs-check`) können den
  Widerspruch nicht sehen — er liegt in einer dritten Datei und bricht keinen Link.
- **gegenbeispiel:** Der Implementer führt Folgepflicht 1 wörtlich aus. Danach trägt das eine
  Artefakt, das die ADR ausdrücklich zur **Weiche** erklärt (*„keine zweite Fassung"*), im Kopf
  `Permanent — übergeführt in ADR-0021` und im Rumpf zwei unerledigte Anweisungen, sich nach
  `done/` zu bewegen. Beide Prüfkommandos sind grün, `make docs-check` ist grün, der Verifier hakt
  Folgepflicht 1 ab. Der nächste Lauf, der die Weiche liest, findet die Anweisung, die Festlegung 5
  gerade verboten hat — und die ADR, die es entschieden hat, ist nicht mehr änderbar.
- **verifizierbar:** ja, ohne Gate —
  `grep -n 'done/' docs/plan/carveouts/CO-002-token-achse-je-rolle.md` gegen
  `sed -n '478,492p' docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md`. **Kein Gate
  deckt es:** `make docs-check` bleibt in beiden Zuständen grün (Sonde E), weil keine Adresse sich
  bewegt.

### N-5 — Die Sonde zum fehlenden d-check-Knopf berichtet ihren Zahlen-Delta, nicht den strukturellen Grund, der über eine Werkzeug-Version hinaus trägt

- **kategorie:** LOW
- **quelle:** Maintainability; [`AGENTS.md`](../../AGENTS.md) §3.6 (*„benennen, was wirklich deckt"*)
- **pfad:** `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:163-171`
- **befund:** Der Absatz begründet das Fehlen eines präzisen Knopfes mit einer Zahl (*„steigt der
  Stand von 79 auf 82"*). Gemessen ist der Effekt qualitativ und stärker, als der Absatz sagt:
  `resolve-from` erzeugt eine **neue Befundart** (`link-position-dependent`), und die drei neuen
  Befunde treffen [`CO-001`](../plan/carveouts/CO-001-bats-shell-lint.md) und den Carveout-Index —
  ein Carveout, der mit dieser Entscheidung nichts zu tun hat. Vor allem: `resolve-from` ist
  **quellenseitig** und kann die **18** eingehenden Befunde in den zwei eingefrorenen ADRs
  konstruktiv nicht erreichen; Sonde B′ mit `fixed-dirs` lässt sie unverändert stehen. Das ist der
  Grund, der auch nach einem Werkzeug-Sprung noch gilt — die Zahl ist es nicht.
- **gegenbeispiel:** Der vierte Re-Evaluierungs-Trigger feuert, jemand liest den Absatz und prüft
  die neue Werkzeug-Version nur gegen *„mehr oder weniger als 82"*. Er übersieht, dass die Frage
  nicht *Verschärfung vs. Ausnahme* lautet, sondern *quellenseitig vs. zielseitig*, und aktiviert
  eine Option, die den Fall wieder nicht löst.
- **verifizierbar:** ja, gefahren — Sonde B und B′ oben, beide `84 Befund(e)`, davon 18 unverändert
  in `docs/plan/adr/0019-…` und `0020-…`.

---

## Negativbefunde

- **geprüft, ohne Befund — die Kernfrage des Auftrags, ob Modul 7 den Move *bedingt* verlangt:**
  am Wortlaut nachgelesen. §Ziel-Form spricht nur von der **Auflösung**; §Carveout-Audit-Slice
  nennt für *permanent* nur das Ziel-Artefakt (*„permanent (Trigger nie → ADR)"*), kein
  Verzeichnis; §Werkzeug-Wahl nennt `done/` ausschließlich für den **leeren** Stub, und die
  Leere ist dort kausal begründet (*„Inhalt ganz aufgegangen"*). **Es gibt im Modul keinen Satz,
  der für einen gelebten, übergeführten Carveout ein Verzeichnis vorschreibt.** Die
  Ort-Entscheidung ist damit an der Quelle gedeckt — allein über dieses Bein; das zweite trägt
  nicht (N-2).
- **geprüft, ohne Befund — die drei Sonden zum Move:** Verteilung 13 (`ADR-0019`) / 5 (`ADR-0020`)
  exakt getroffen, die **18** unbehebbaren exakt, `resolve-from` verschärft wie behauptet,
  `codepaths.ignore-refs` ist wirkungslos wie behauptet, und `d-check --print-config` gegen den
  gepinnten Digest bestätigt: `links` trägt genau eine Options-Sektion, und sie nimmt nichts aus.
  Beanstandet sind allein die zwei Summen (N-1) und die fehlende strukturelle Begründung (N-5).
- **geprüft, ohne Befund — der Preis-Vergleich zu ADR-0017 kehrt dessen Maßstab NICHT um.** Alle
  acht Zahlen selbst nachgezählt und exakt bestätigt (49/66/27 Link-Vorkommen, 18/23/12 Ziele,
  21/56/18 Kennungen, 6/6/4 Inline-Pfade). Der Maßstab *„kleinstmöglicher Prüfbereichs-Verlust für
  das Problem"* ist verbatim aus ADR-0017 Option D, und **ADR-0017 rechnet in ihrer eigenen
  Alternative C mit genau derselben Größe** (*„gemessen siebenmal teurer: die drei Dateien führen
  zusammen 185 Link-Vorkommen … gegenüber 27 der einen Datei"*) — die Methode ist importiert, nicht
  erfunden. Auch *„zwei der größten"* trägt: 66 und 49 sind Platz 2 und 3 über alle ADRs, und
  Platz 1 ist ADR-0021 selbst. Das Kriterium *„unvermeidbar vs. wählbar"* steht **nicht** in
  ADR-0017 (`grep` leer) und wird dort auch nicht als Zitat ausgegeben — es ist die eigene
  Einordnung dieser ADR, und die Gefahr, dass daraus eine Gattungs-Regel wird, ist durch die
  extensionale Schließung (`:408-415`) ausdrücklich abgeschnitten.
- **geprüft, ohne Befund — die überholte Prämisse von ADR-0020.** ADR-0020 Festlegung 3 hängt
  **nicht** an *„beide Ausgänge enden in `done/`"*. Ihr Operativsatz — die zwei Zellen tragen
  *ADR-Verdikt*, `CO-002` ist **Vorbedingung** des Zähler-Glieds und **kein** Auflösungs-Trigger —
  ruht auf der **Konjunktion** mit dem Erfassungs-Glied, das ihre eigene Festlegung 1 permanent
  schließt. Der `done/`-Satz stützt nur die Begründung, warum keine Zelle auf den Carveout als
  offenen Trigger zeigt, und dieser Schaden (*„ein Verweis auf ein abgeschlossenes Artefakt"*)
  wird durch die Ortsfestigkeit **kleiner**, nicht größer. Ihre Lese-Anweisung bleibt benutzbar:
  von den *„drei Formen"* ist die zweite — *„die Folge-ADR, die ihn überführt"* — ortsunabhängig
  und tritt ein. ADR-0021 spricht das offen aus, korrigiert nichts und bleibt damit auf der
  richtigen Seite von §3.4. **Kein HIGH.**
- **geprüft, ohne Befund — HIGH-2s Nachfolge erzeugt keinen zweiten Ort.** Die fünf Spec-Stellen
  behalten ihren Link auf den Stub, der Stub zeigt auf die ADR, das Verdikt steht nur in der ADR;
  die Konsequenz sagt das ausdrücklich und nennt die `matrix`-Regel als Grund. Sonde E zeigt, dass
  ein Link vom Stub auf die ADR gate-konform ist (`carveouts/` ist keine `matrix`-Klasse). Die fünf
  Stellen enthalten keinen Satz, der `CO-002` als *temporär* bezeichnet — der Nachzug ist
  ausführbar, und das neue Prüfkommando (*sechs Zeilen müssen bleiben*) ist heute erfüllt.
- **geprüft, ohne Befund — die Fitness Function.** Vier Zeilen: drei vorhandene Wächter, ein
  fälliger Fall — die Zahl im `Bezug`-Kopf stimmt. Zeile 1 zitiert den `mustContain`-Kommentar
  verbatim; Zeile 2 sagt in der Zeile selbst, was sie *nicht* hält (vier von neun, die zwei
  Cache-Zähler ausdrücklich); Zeile 3 nennt, warum 123–126 und 127 diese Richtung nicht decken, mit
  Kommando (`grep -ln 'responseKeys' …` → leer, selbst gefahren); Zeile 4s Nicht-Deckung steht im
  Absatz darunter (*„bindet die **Adresse** des Stubs, nicht seinen **Status**"*). Sonde D
  reproduziert die zugesagte Rot-Grün-Paarung exakt. **Der Bestand ist damit ehrlich beschrieben.**
- **geprüft, ohne Befund — Status-Schnappschüsse.** Kein Satz nennt einen Status, den der eigene
  Accept falsch macht. Die vier `Accepted`-Angaben im Bezugs-Block sind selbst geprüft und richtig;
  `ls docs/plan/carveouts/CO-*.md | wc -l` → **2** trägt jetzt den ausdrücklichen Zusatz
  *„Diese Zahl bewegt sich mit der Umsetzung nicht"* und den Zeiger auf Folgepflicht 4. Die einzige
  Aussage, die der **Vollzug** (nicht der Accept) verschiebt — *„als temporäre Ausnahme geführt"* —
  steht unter der Überschrift *„Was offen war"* und ist damit als Rückblick markiert. **Die
  ADR-0020-Klasse trifft nicht.**
- **geprüft, ohne Befund — Slices als Adresse:** `grep -n 'slice-[0-9]'` über die ADR ist leer.
  Folge-Slice, Mutations-Fall, Folgepflichten und Re-Evaluierungs-Trigger sind durchgängig als
  Eigenschaft formuliert (*„der Slice, der das Werkzeug hebt"*, *„ein Fall in `test/mutations/`,
  der …"*). Auch die Index-Zeile nennt keinen.
- **geprüft, ohne Befund — Rest-Sprache aus Runde 1.** Alle neun `done/`-Treffer sind erklärt:
  drei Modul-Zitate, ein ADR-0020-Zitat, ein Sonden-Kommando, die Negativ-Aussage selbst, die
  CO-001-Abgrenzung, der Re-Evaluierungs-Trigger und die Geschichte-Zeile. Der Text ist auf die
  neue Entscheidung durchgezogen; es gibt keine Stelle mehr, die den Move anordnet.
- **geprüft, ohne Befund — die neuen Sätze im Einzelnen.** **Folgepflicht 7** (Adaptions-Eintrag,
  eigener Architect-Lauf, eigener Commit) entspricht §3.8 und sagt richtig, dass eine ADR den
  Adaptions-Block nicht ersetzt. **Der vierte Re-Evaluierungs-Trigger** ist korrekt als
  feedforward gekennzeichnet, nennt sein *Wer*, zitiert ADR-0017s Ziel-Zustand verbatim
  (*„dann ist der datei-weite Eintrag durch den präzisen zu ersetzen"*) und sagt ausdrücklich, dass
  **keine Annahme** fällt — er ist kein Auflösungs-Trigger in Trigger-Form. **Die extensionale
  Schließung** zitiert ADR-0017 verbatim und schneidet die Gattungs-Regel sauber ab.
  **Folgepflicht 4** ist inhaltlich korrigiert und trifft `welle-09` §3 genau: der Closure-Trigger
  nennt dort *„`CO-001` **und** `CO-002` geprüft"*, und die Datei-Zählung bleibt bei zwei.
- **geprüft, ohne Befund — ADR-0012-Konformität:** kein Auflösungs-Trigger, kein Folge-Slice; alle
  fünf Re-Evaluierungs-Trigger nennen *woran* und vier davon zusätzlich *wer*; keiner behauptet,
  dass jemand es tun wird. Die Quadranten-Kennzeichnung ist durchgängig.
- **geprüft, ohne Befund — `LH-QA-01` und die Ziel-Form:** kein Gate wird behauptet; alle genannten
  Targets existieren und sind richtig eingeordnet (`make test`/`make docs-check` in `make gates`,
  `make mutate` nicht). Alle sieben Template-Abschnitte stehen in der Reihenfolge der Vorlage.
  §3.8 ist am Commit-Zuschnitt erfüllt (zwei Architect-Artefakte, Rolle in der Message).
- **geprüft, ohne Befund — Index-Zeile `docs/plan/adr/README.md:29`:** Status *Proposed*
  deckungsgleich; die Ort-Entscheidung, die Wächter-Zuordnung, die Klassen-Unterscheidung samt
  drittem Punkt und der Preis der Alternative sind mit dem Fließtext deckungsgleich. **Sie erbt
  N-1** (zweimal „79") **und N-2** (die Bedingungs-Formulierung) und wird mit denselben Befunden
  ungenau.
- **geprüft, ohne Befund — Zitat-Treue:** alle in dieser Runde neu gesetzten Zitate sind verbatim
  gegen ihre Quelle — Modul 7 §Ziel-Form / §Werkzeug-Wahl / §Carveout-Audit-Slice · ADR-0017
  Option D, §Re-Evaluierungs-Trigger und die extensionale Begründung · ADR-0020 §Festlegung 3 ·
  ADR-0012 Folgepflicht 1 und Folgepflicht 4 · `spec/spezifikation.md` §5 Abweichung 4 ·
  der `mustContain`-Kommentar aus `internal/span/response_test.go`. **Kein Zitat ist kondensiert
  oder umformuliert;** beanstandet ist eine Auslassung *zwischen* zwei Zitaten (N-4), nicht ein
  Zitat.
- **geprüft, nicht bewertet (fremde Rolle):** `slice-089` — seine DoD-Punkte (1) und (2) und seine
  Datei-Tabelle beschreiben durchgängig den **Move** und den Zeiger-Abbau und sind damit nach
  dieser Überarbeitung überholt; das gehört in ein Plan-Review, nicht hierher. Ebenso außerhalb:
  dass `CO-001` keinen Folge-Slice führt, und der Wortlaut des `welle-09`-Closure-Kriteriums.
- **geprüft, ohne Befund, mit einer Nuance:** die erste Fitness-Zeile spricht von *„der gemessenen
  Vordergrund-Payload"*; die Fixture ist ausweislich ihres eigenen Kommentars die gemessene
  Vordergrund-Gestalt **vereinigt** mit zwei Freitext-Feldern des Hintergrund-Laufs. Die neun Werte
  stammen sämtlich aus dem gemessenen Teil — die Aussage der Zeile bleibt richtig, ein
  Failure-Szenario gibt es nicht.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 4 |
| LOW | 1 |
| INFO | 0 |

Runde 1 → Runde 2: **HIGH 3 → 0**, MEDIUM 3 → 4 (davon eins, N-3, als Teil-Rest aus Runde 1),
LOW 2 → 1, INFO 2 → 0. Acht von zehn Runde-1-Findings sind belegt behoben.

## Verdikt

**Noch nicht frei für die Annahme — blockiert, aber nicht mehr an der Sache.**

**Die Ort-Entscheidung selbst trägt.** Das ist der neue Gegenstand dieser Runde, und er ist
geprüft, nicht geglaubt: es gibt im Regelwerk **keinen** Satz, der für einen gelebten,
übergeführten Carveout ein Verzeichnis vorschreibt — die einzige `done/`-Anweisung für den
Überführungs-Pfad gilt dem **leeren** Stub. Die drei Wege sind ehrlich verglichen, der Preis des
zweiten ist mit ADR-0017s **eigenem** Maßstab und dessen **eigener** Methode beziffert (alle acht
Zahlen selbst nachgezählt, alle exakt), die gewählte Form ist grün gemessen, und die überholte
Prämisse von ADR-0020 ist offen benannt, ohne eine eingefrorene ADR anzufassen. Die drei HIGH aus
Runde 1 sind belegt behoben, zwei davon vorbildlich.

**Was blockiert, ist der Nachweis, nicht die Entscheidung.** Vier MEDIUM, und alle vier liegen in
Text, der in **dieser** Überarbeitung entstanden ist — also ohne Cutoff-Schutz und mit `MR-025`
seit zweieinhalb Stunden in Kraft:

- **N-1** friert eine Messung ein, die ihr eigenes Kommando nicht mehr liefert (81 statt 79, 8
  statt 6, 84 statt 82) — und zwar aus genau dem Grund, den `MR-025` Setzung 2 beschreibt und den
  dieselbe ADR eine Folgepflicht weiter richtig anwendet.
- **N-2** schreibt eine Regel ins Register, die Modul 7 nicht enthält, und widerspricht dabei der
  eigenen Analyse drei Absätze zuvor.
- **N-3** ist der zweite Anlauf derselben Klasse: die Bedingung, die Festlegung 3 zur
  Zulässigkeits-Voraussetzung macht, ist an ihrem ersten Anwendungsfall wieder nur der Form nach
  erfüllt.
- **N-4** lässt im einzigen Artefakt, das die ADR als **Weiche** bestimmt, zwei Anweisungen
  stehen, die Festlegung 5 gerade verboten hat — unsichtbar für beide Prüfkommandos und für
  `make docs-check`.

Jeder der vier ist ein Satz oder eine Zahl, solange die ADR *Proposed* steht; nach dem Accept ist
jeder nur noch über eine weitere ADR mit *Supersedes* zu bewegen (§3.4). Das ist der einzige
Grund, warum ich bei vier MEDIUM und null HIGH blockiere und nicht durchwinke — die
Reviewer-Regel *„HIGH und MEDIUM blockieren typischerweise"* trifft hier auf ein Artefakt, dessen
Korrektur-Fenster sich mit dem Verdikt schließt.

**Steering-Loop-Signal, ausdrücklich gemeldet statt nur gezählt** (Modul 10 §Kontext-Eskalation):
Die Klasse *„eine Zahl im Fließtext, die ihr danebenstehendes Kommando nicht liefert"* hat seit
`04067d7` einen Träger — `MR-025`, geschrieben aus zehn Fundstellen über zwei Slices und sechs
Review-Runden. Das **nächste** Artefakt, das unter dieser Regel entstand, bricht sie zweimal
(N-1, N-3). `MR-025` sagt selbst, dass sie im Feedforward-Quadranten liegt und keinen Sensor hat;
diese Runde ist die erste Messung dazu, und sie ist negativ. Das gehört an die Rolle, die den
Adaptions-Block führt — nicht als Wiederholungs-Meldung, sondern als Beobachtung zur
**Trägerschaft**, die `MR-025` in ihrer eigenen Begründung als den eigentlichen Befund benennt.

**Übergabe:** Die Findings gehen an den **Architect** (ADR und Index sind Architect-Artefakte,
§3.8 / [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)); N-4 berührt zusätzlich
den Inhalt von `CO-002`, den Folgepflicht 1 dem **Implementer** zuweist. Der **Planner** ist
unabhängig von diesen Findings betroffen: `slice-089` beschreibt in DoD (1)/(2) und in seiner
Datei-Tabelle den Move und den Zeiger-Abbau und ist durch die neue Festlegung 5 überholt. Dieser
Report ersetzt keine Verifikation (Modul 11). Der Eintritts-Trigger von `slice-089` —
*ADR-0021 ist Accepted* — ist nach diesem Verdikt **nicht** erfüllt.
