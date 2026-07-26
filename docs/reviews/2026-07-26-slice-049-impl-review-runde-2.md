# Review-Report: slice-049 — Runde 2 — 2026-07-26

**Review-Art:** Code — geprüft wird der Diff gegen **Plan + aktive ADRs + Hard Rules +
Konventionen** (Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung
(Modul 11, getrennter Kontext, anderes Prüf-Artefakt).

**Gegenstand:** slice-049, **zweite Runde**. Runde 1
([`2026-07-26-slice-049-impl-review.md`](2026-07-26-slice-049-impl-review.md)) endete
**NICHT KONFORM** (1 HIGH, 2 MEDIUM, 2 LOW, 1 INFO); die Implementation hat mit dem
Auflösungs-Commit `d38db74` reagiert. Runde 2 prüft **zwei Fragen**: (a) sind die
Runde-1-Findings real aufgelöst — am Diff, nicht an der Behauptung; (b) hat der
Auflösungs-Commit **neue** Befunde eingeführt. Gesamt-Range `80eec58..HEAD`
(`9cfa1f3` Move · `ce4b611` Impl · `d38db74` Fix), 55 Dateien.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-26 · **Frischer Kontext**, getrennt
von Implementation und Verifikation.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan: `in-progress/slice-049-baseline-bump-v3.5.2.md` (§2 DoD, §3 Plan, §5 Closure-Trigger, §6 Risiken)
- **Vorherige Findings am gleichen Modul (Pflicht-Punkt 5):** Runde 1 F-1…F-6 **im Wortlaut**, samt
  [Nachtrag der Implementation](2026-07-26-slice-049-impl-review.md#nachtrag-der-implementation-2026-07-26--auflösung-der-findings)
- **Verifier-Report** [`2026-07-26-slice-049-verification.md`](2026-07-26-slice-049-verification.md)
  (DoD BESTÄTIGT; Abweichungen A-1 Zählung, A-2 stehender Review-Verdikt)
- aktive ADRs: keine im Diff geändert; mittelbar berührt [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- berührte `LH-*`-IDs: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules 3.1–3.6) — **verbatim gelesen**, nicht aus Runde 1 übernommen
- Konventionen: [`harness/conventions.md`](../../harness/conventions.md) — `MR-007`, `MR-013`, `MR-015`
- Rollen-Vertrag: `.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad,
  `.harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md`

**Prüfumfang / Grenze:** Runde 2 misst die Behauptungen des Auflösungs-Commits **selbst nach**
(`git log`, `git show --stat`, `git reflog show origin/main`, `git grep -o`), statt sie zu
übernehmen. Das Vendoring-Verfahren (`MR-007` Setzungen 1–4, `MR-013`, `SHA256SUMS`-Form,
Pin-Kette) ist in Runde 1 geprüft und vom Verifier unabhängig bis zum Upstream-Asset
durchgezogen worden; `d38db74` fasst es nicht an (`git show --name-only d38db74` = drei
Doku-Dateien) — es wird hier **nicht erneut** aufgerollt, sondern als Negativbefund geführt.
Eigene Sensor-Läufe: `make docs-check`, `make baseline-verify` (lesend). **Nicht** gefahren:
`make mutate`, `make gates` (mutierend bzw. verifizierende Rolle, läuft getrennt).

---

## Status der Runde-1-Findings

Jede Zeile ist am Diff bzw. an einer eigenen Messung geprüft, nicht am Nachtrag.

| # | Kat. R1 | Status Runde 2 | eigener Beleg |
|---|---|---|---|
| F-1 | HIGH | **aufgelöst** | s. u. „F-1 im Detail" |
| F-2 | MEDIUM | **aufgelöst** | `git show c615da7 -- spec/lastenheft.md` gelesen: ändert **nur** die Link-Form der Historie-Zeile 0.2.0. `MR-015` führt `c615da7` jetzt gleichrangig neben `7b717f4` ([`conventions.md`](../../harness/conventions.md):693–695). |
| F-3 | MEDIUM | **nicht behoben; blockierende Wirkung von mir REFUTED — mit eigenem Beleg, nicht wegen des Widerspruchs** | s. u. „F-3 im Detail" |
| F-4 | LOW | **NICHT aufgelöst** | Die Korrektur ist selbst falsch und liegt nicht dort, wo der Nachtrag sie verortet — s. N-3. |
| F-5 | LOW | **aufgelöst** | `git grep -n "blob/v3\.5\.1"` über aktive Pfade: einziger Treffer ist die §6-**Prosa** des Slice („Ein `.../blob/v3.5.1/...`→`v3.5.2`-Bump", Zeile 162) — eine Beschreibung des Musters, kein Verweis. Beide Definitions-URLs (Zeile 6, 181) stehen auf `v3.5.2`. |
| INFO-1 | INFO | **aufgelöst** | [`conventions.md`](../../harness/conventions.md):643–646 nennt `AGENTS.md` nicht mehr als berührt, sagt ausdrücklich „MR-Adaption, **keine** neue Hard Rule"; `git diff --stat 80eec58..HEAD -- AGENTS.md` ist leer — Geltungsbereich und Ist-Stand decken sich jetzt. |

### F-1 im Detail — echte Reparatur, keine Umgehung

**Ist-Messung selbst nachgefahren**, mit genau dem Verfahren, das `MR-015` als Beweismittel
benennt (`git log --follow -- spec/lastenheft.md`, dann je Treffer `git show --name-only`):

- **16** Commits berühren die Datei — trifft zu.
- **6** ändern sie allein — trifft zu, und die Hash-Menge ist **identisch** mit der im Eintrag
  (`5c4930b`, `9ce4721`, `af0d454`, `2c8227b`, `2879429`, `27628b5`), je genau 1 Datei.
- **10** bündeln sie — trifft zu. Die Klassifikation stimmt Commit für Commit: fünf mit
  tragendem ADR (`43f1eda` 2, `65f4bcf` 2, `ec3af11` 4, `a0e74f1` 2, `bc447fe` 3 ADR-Dateien),
  `beec837` mit `harness/conventions.md` (2 Dateien, 0 ADR), `4b0d0d5` mit einer Slice-Datei
  (2 Dateien, 0 ADR) = **sieben Entscheidungs-Bündel**; `d30db38` **21** Dateien = Bootstrap;
  `c615da7` (15 Dateien) und `7b717f4` (11 Dateien) = **zwei redaktionelle**. 7+1+2 = 10.
- Die Teil-Aussage „keine **Anforderung** wurde je in einem **Slice-Implementierungs-Commit**
  inhaltlich geändert" hält: die einzigen zwei Commits ohne `spec:`/`plan:`/Entscheidungs-Charakter
  sind `c615da7` und `7b717f4`, und beide Diffs (von mir gelesen) ändern in `spec/lastenheft.md`
  ausschließlich Link-Form bzw. Zeilenreihenfolge.

**Ist die Umdeutung zu „neue Disziplin ab diesem Eintrag + Cutoff" eine Umgehung? Nein.**
Drei Prüfungen, alle drei bestanden: (1) Der **normative Gehalt** von Setzung 2 ist unverändert
— eigener Commit, ausschließlich `spec/lastenheft.md`, vor dem `open → in-progress`-Move; nichts
gelockert, `AGENTS.md` §3.5 nicht berührt. (2) Der widerlegte Satz ist **benannt statt geglättet**
([`conventions.md`](../../harness/conventions.md):683–687, mit ausdrücklichem §3.6-Verweis) — die
Historie der Aussage bleibt lesbar, genau das, was eine Umgehung vermieden hätte. (3) Der Cutoff
schafft **keinen Stillen-Grün-Pfad**: es existiert überhaupt kein Sensor, und §Durchsetzung weist
die Lücke weiterhin ehrlich als „benannt, nicht geschlossen" aus (`LH-QA-01` gewahrt). Die
Begründung des Cutoffs ist zudem gemessen, nicht behauptet: ein Sensor über die Historie wäre
10 von 16 rot.

### F-3 im Detail — die drei Belege der Ablehnung, einzeln nachgeprüft

| Beleg der Implementation | eigene Prüfung | Urteil |
|---|---|---|
| „`14e3455` sagt im Betreff ausdrücklich ‚keine Inbound-Links zu ziehen'" | `git log -1 14e3455`: trifft zu, 1 Datei / 0 Insertions | **hält** |
| „`ec16f77` behauptet ‚+ Inbound-Links im selben Commit', zeigt aber 1 Datei / 0 Insertions" | `git show --stat ec16f77`: trifft zu. Ergänzend: die verbliebenen `in-progress/slice-048`-Nennungen sind Code-Spans in Review-Reports, keine Links — es gab dort nichts zu ziehen | **hält** |
| **„die Praxis wurde nie ausgeübt"** | **falsch** — `08410bc` (in Runde 1 F-3 mit-zitiert) ist ein Lifecycle-Move `in-progress → done`, der **im selben Commit** 5 verweisende Dateien mit 7 Link-Reparaturen zieht (`roadmap.md`, `welle-07-results.md`, `slice-045b`, zwei Review-Reports) | **hält nicht** → N-1 |
| „keine adoptierte Konvention verlangt gate-grüne Zwischen-Commits" | [`AGENTS.md`](../../AGENTS.md) §3.1 **verbatim** gelesen: „Jeder in AGENTS.md, harness/README.md oder im Makefile **genannte Gate** muss auf frischem Checkout laufen" — das ist die Anti-Halluzinations-Regel über *Gates*, keine Aussage über *jeden Commit*. `grep -rniE "zwischen-?commit\|jeder commit\|pro commit"` über `AGENTS.md`, `harness/`, `docs/plan/`, `CLAUDE.md`: **0 Treffer**. Slice-Plan §5 verlangt die Link-Reparatur „im selben Zug" nur für den **`done/`-Move**, nicht für `open → in-progress` | **hält** |
| „beide Commits liegen auf `origin/main`; Abhilfe wäre ein Force-Push für einen Zustand, den kein Gate je auswertet" | `git reflog show origin/main`: `80eec58` → **`ce4b611`** → `d38db74`. `9cfa1f3` war **nie** gepushter Head; [`ci.yml`](../../.github/workflows/ci.yml) triggert auf `push`/`pull_request` (Head-SHA) — es existiert kein CI-Lauf, der `9cfa1f3` je ausgewertet hat oder auswerten wird | **hält** |

**Mein Urteil zu F-3 (eigenständig, nicht aus dem Nachtrag übernommen):** die *Substanz* steht —
auf dem Checkout `9cfa1f3` zeigen zwei Roadmap-Links ins Leere. Die *Einstufung als
merge-blockierendes MEDIUM* trägt jedoch nicht: ihre beiden Anker sind bei Nachprüfung leer
(Hard Rule 3.1 sagt etwas anderes; Slice-Plan §5 regelt den `done/`-Move) und die „etablierte
Repo-Praxis" ist **eine** ausgeübte Instanz (`08410bc`) neben einer ausdrücklich abgelehnten
(`14e3455`), während die Konvention selbst in [`roadmap.md`](../plan/planning/in-progress/roadmap.md):36
als **offener Kandidat** geführt wird — also gerade **nicht** adoptiert. Nach den Kategorien-Ankern
des Skills bleibt eine **LOW**-Beobachtung (Doku-Drift in einem Zwischenzustand). F-3 ist damit in
seiner blockierenden Wirkung **REFUTED — mit Beleg** (Skill §Anti-Pattern: „REFUTED nur mit Beleg"),
nicht wegen des Widerspruchs der Implementation und nicht durch Übernahme des milderen Ergebnisses
(Modul 10 §Regeln). Was offen bleibt, ist nicht die Kategorie, sondern die **Verortung**: s. N-2.

**Zur Zulässigkeit der Form (Modul 8 §Konflikt-Pfad).** Der verbotene vierte Pfad ist „Reviewer-Finding
**herabstufen**, weil Implementer widerspricht" — das ist hier **nicht** geschehen: F-3 behält im
Nachtrag seine Kategorie und bekommt eine Beleg-gestützte Antwort. Modul 8 macht die volle
Rollen-Sequenz zudem erst „ab **HIGH** mit Rollen-Widerspruch oder ab dem dritten gleichen
Konflikttyp" zur Pflicht; F-3 ist MEDIUM, ein *begründeter* Widerspruch der Implementation ist
also ein zulässiges **Übergabe-Artefakt** (schriftlich, benannt, additiv — kein „mündliche
Klärung", keine Überschreibung des Reports). Was die Implementation **nicht** durfte, ist das
Finding damit zu **schließen**: das Verwerfen ist ein Reviewer-Akt (neue Runde, „REFUTED nur mit
Beleg") oder ein Architect-Verdikt nach einer der drei Modul-8-Zeilen. Der Verifier hält in A-2
dasselbe fest. Dieser Report liefert den fehlenden Akt.

---

## Neue Findings (aus dem Auflösungs-Commit `d38db74`)

### N-1 — Der tragende Beleg der F-3-Ablehnung ist eine Zusage ohne Abdeckung

- `kategorie`: HIGH
- `quelle`: Hard Rule 3.6 ([`AGENTS.md`](../../AGENTS.md) §3.6, „Keine Zusage ohne rot gesehenes
  Gegenbeispiel" — nennt die **Commit-Message** ausdrücklich als Zusage-Träger) · Modul 8 §Konflikt-Pfad
- `pfad`: Commit-Message `d38db74` (F-3-Absatz, „die Praxis wurde nie ausgeuebt") und
  [`2026-07-26-slice-049-impl-review.md`](2026-07-26-slice-049-impl-review.md):273–276
- `befund`: Der Satz „die Praxis wurde nie ausgeübt" ist ein universelles Negativ, das aus der
  Prüfung von **einem** der **zwei** in Runde 1 zitierten Commits gezogen wurde: geprüft wurde
  `ec16f77` (dort korrekt: 1 Datei / 0 Insertions), **nicht geprüft** wurde `08410bc`, das im selben
  Zitat der F-3-Befundzeile steht und die Praxis real ausübt — ein reiner Rename plus 5 verweisende
  Dateien mit 7 Link-Reparaturen im selben Commit. Das Gegenbeispiel war der Implementation im
  Finding übergeben und wurde nicht ausgewertet; damit trägt der einzige Beleg, mit dem ein offenes
  MEDIUM abgelehnt wurde, dieselbe Klasse, die F-1 in derselben Sitzung als HIGH getroffen hat.
- `verifizierbar`: ja — `git show --stat 08410bc` (6 Dateien, 7 Insertions/7 Deletions, davon der
  Slice-Move mit `similarity index 100%`) gegen den Satz in `git log -1 --format=%B d38db74`.

### N-2 — Das abgelehnte F-3 ist nirgends verortet: der Roadmap-Kandidat wurde nicht angefasst

- `kategorie`: MEDIUM
- `quelle`: Modul 8 §Konflikt-Pfad („Kein Pfeil ohne benennbares Artefakt"; „Slice nicht still
  abschließen") · Maintainability
- `pfad`: [`docs/plan/planning/in-progress/roadmap.md`](../plan/planning/in-progress/roadmap.md):36
  (Kandidat „Doku- und Sensor-Wartung", Teil-Punkt 4 „Lifecycle-Move-Konvention")
- `befund`: Der Nachtrag verortet F-3 mit „Dieser Befund ist dessen **zweite gemessene Instanz** und
  **schärft seinen Trigger**"; `git show --name-only d38db74` listet jedoch nur drei Dateien, und
  `roadmap.md` ist keine davon (`git log 80eec58..HEAD -- .../roadmap.md` = nur `ce4b611`). Die
  Trigger-Zelle trägt unverändert den Stand „Trigger **beobachtet** 2026-07-25 … ein Lifecycle-Move
  machte CI auf `main` rot"; die neue Instanz existiert ausschließlich in einem Review-Report und
  einer Commit-Message. Ein abgelehntes Finding, dessen einzige Auflösungs-Form der Verweis auf
  einen Backlog-Eintrag ist, verlässt den Slice damit ohne das Artefakt, auf das der Verweis zeigt.
- `verifizierbar`: nein für ein Gate (kein Sensor prüft Roadmap-Trigger-Aktualität); statisch
  belegt per `git show --name-only d38db74` und `git diff 80eec58..HEAD -- docs/plan/planning/in-progress/roadmap.md`.

### N-3 — Die F-4-Korrektur ist selbst falsch und steht nicht in der Notiz, die sie nennt

- `kategorie`: LOW
- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Zahl ist als
  Checkliste für den nächsten Re-Vendor gedacht) · Hard Rule 3.6 · Maintainability
- `pfad`: [`2026-07-26-slice-049-impl-review.md`](2026-07-26-slice-049-impl-review.md):287–290 und
  Commit-Message `d38db74` (F-4-Absatz); `in-progress/slice-049-baseline-bump-v3.5.2.md`:80
- `befund`: Die Korrektur „**13** Vorkommen, davon **11** gezogen und **2** behalten" ist in zwei von
  drei Zahlen falsch. Eigene Zählung (`git grep -o -e "v3\.5\.1"` je Datei, Vorkommen statt Zeilen)
  über die vier genannten Dateien: `80eec58` trägt **15** (`conventions.md` 6, `benutzerhandbuch.md` 3,
  `reviewer.md` 3, **`roadmap.md` 3** — die slice-049-Zeile trägt zwei weitere), HEAD trägt **6**,
  davon **4** bewusst behalten (`conventions.md` 1 Re-Baseline-Historie, `reviewer.md` 1
  1.3.0-Historie, `roadmap.md` 2 beschreibend) plus 2 neu geschriebene im 1.4.0-Historieneintrag;
  gezogen wurden **11**. Das deckt sich mit der unabhängigen Zählung des Verifiers (A-1: 15/11/4)
  und nicht mit dem Nachtrag. Zusätzlich: der Nachtrag sagt „in die **Closure-Notiz** übernommen" —
  §7 des Slice besteht bei HEAD unverändert aus dem Template-Kommentar, und §3 Zeile 80 trägt die
  ursprüngliche Angabe „13 Vorkommen in 4 Dateien" unkorrigiert weiter.
- `verifizierbar`: ja — `git grep -o -e "v3\.5\.1" 80eec58 -- <die vier Dateien> | wc -l` (= 15)
  gegen dieselbe Messung auf `HEAD` (= 6); `sed -n '/^## 7/,$p'` auf der Slice-Datei zeigt die leere
  Closure-Notiz.

### N-4 — Die Auflösung liegt als Fremd-Rollen-Nachtrag unter einem stehenden Reviewer-Verdikt

- `kategorie`: INFO
- `quelle`: Modul 10 §Ablage (ein Report pro Lauf, Folgeläufe als neue Datei) · Modul 8 §Übergabe-Artefakt
- `pfad`: [`2026-07-26-slice-049-impl-review.md`](2026-07-26-slice-049-impl-review.md):251–296
- `befund`: Die Auflösung der Implementation ist als Abschnitt **in den Report der Runde 1**
  geschrieben, dessen §Verdikt zwei Bildschirmseiten darüber unverändert „NICHT KONFORM,
  merge-blockierend" lautet. Die Ablage-Regel ist formal gewahrt (additiv, nichts überschrieben, der
  Abschnitt ist als „Nachtrag der Implementation" ausgewiesen), aber die Datei trägt jetzt zwei
  Rollen-Stimmen unter einer Kopf-Metadaten-Zeile, die nur den Reviewer nennt — ein späterer Leser
  kann Auflösungs-Behauptungen der Implementation nicht ohne Textlektüre von reviewer-geprüften
  Aussagen trennen. (Nur Beobachtung; keine Aktion aus diesem Report erwartet.)
- `verifizierbar`: nein — kein Gate deckt Rollen-Zuordnung in `docs/reviews/**`; belegbar per
  Lektüre der Datei.

---

## Negativbefunde

- geprüft, ohne Befund: **Umfang von `d38db74`.** `git show --name-only d38db74` = genau drei
  Dateien (Slice-Doku, Review-Report, `conventions.md`). Kein Code, kein Gate, kein Makefile, kein
  Test, kein Baseline-Baum berührt — die Auflösung greift nicht über die Findings hinaus.
- geprüft, ohne Befund: **`spec/lastenheft.md` über die ganze Range.**
  `git diff --stat 80eec58..HEAD -- spec/` ist leer, auch pro Commit. `MR-015` verlangt genau das
  und widerlegt sich im Vollzug nicht.
- geprüft, ohne Befund: **Hard Rule 3.4 (ADRs immutable).**
  `git diff 80eec58..HEAD -- docs/plan/adr/` ist leer; `d38db74` fasst keinen ADR an.
- geprüft, ohne Befund: **Hard Rule 3.5 / `MR-001` (kein ADR nötig).** `MR-015` verschärft
  (zusätzliche Commit-Disziplin, engere Verweis-Form) und senkt keine Schwelle; die neue Setzung-2-
  Fassung mit Cutoff ändert daran nichts — sie fügt eine Disziplin hinzu, entfernt keine.
- geprüft, ohne Befund: **`LH-QA-01` (kein halluziniertes Gate) im neuen Text.** Der umgeschriebene
  Block behauptet weiterhin **keinen** Sensor; §Durchsetzung führt die Lücke unverändert als
  „benannt, nicht geschlossen" und verweist sie auf die Roadmap. Der Cutoff wird nicht als
  Durchsetzung ausgegeben.
- geprüft, ohne Befund: **`MR-015`-Zitat verbatim.** Der als „verbatim aus dem vendored Baum"
  ausgewiesene Block ist von `d38db74` nicht angefasst worden (Diff zeigt nur Geltungsbereich und
  Setzung-2-Umfeld); die in Runde 1 festgestellte Zeichengleichheit mit
  `.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md` §Spec-Stratifizierung gilt fort.
- geprüft, ohne Befund: **innere Konsistenz von `MR-015` nach dem Umbau.** Die drei Achsen der
  Ist-Messung, Setzung 1/3, „Die bestehenden 13 Zeilen werden NICHT umgeschrieben", Auflösungs-Trigger
  und die neue Setzung-2-Fassung widersprechen einander nicht; die Angabe „13 Zeilen 0.1.0…0.13.0"
  ist am Ist-Stand geprüft (`spec/lastenheft.md` §7 trägt **13** Historie-Zeilen) — sie ist von der
  in N-3 behandelten Referenz-Zählung unabhängig und korrekt.
- geprüft, ohne Befund: **Vendoring-Verfahren (`MR-007` Setzungen 1–4, `MR-013`).** Von `d38db74`
  nicht berührt; `make baseline-verify` in dieser Runde selbst gefahren:
  `v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)`. `.harness/baseline/` enthält
  ausschließlich `v3.5.2/` (Setzung 4).
- geprüft, ohne Befund: **`make docs-check` selbst gefahren:** `d-check: 183 Datei(en) geprüft,
  0 Befund(e)` (183 statt 182: der Verifier-Report liegt als neue Datei im Baum). Der `MR-015`-Anker
  löst nach dem Umbau weiter auf.
- geprüft, ohne Befund: **`ADR-0003` (Docker-only).** `d38db74` führt keine Host-Toolchain und keine
  Abhängigkeit ein; beide Sensor-Läufe dieser Runde liefen über `make`-Targets in gepinnten Images.
- geprüft, ohne Befund: **Wiederkehr der Runde-1-Muster in der Textform.** Der neue Setzung-2-Block
  paraphrasiert keine Quelle als Zitat, kondensiert keinen Digest und erfindet keine Fundstelle;
  alle acht dort genannten Commit-Hashes existieren und tragen die zugeschriebene Datei-Menge.
- geprüft, ohne Befund: **DoD-Abhakung und Closure-Notiz** — bewusst **nicht** bewertet
  (Modul 11, andere Rolle). Der Hinweis in N-3 betrifft die Fundstelle einer Zahl, nicht den
  Abhak-Zustand.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

**Steering-Loop-Signal (Modul 10 §Kontext-Eskalation).** Die Klasse „Zusage weiter als Abdeckung"
(`AGENTS.md` §3.6) tritt in dieser Sitzung zum **dritten** Mal auf: F-1 (Ist-Messung in `MR-015`),
N-1 („nie ausgeübt" aus einem von zwei geprüften Commits), N-3 („in die Closure-Notiz übernommen"
bei leerer Closure-Notiz, mit selbst falscher Zahl). Ab der dritten Wiederholung verlangt der Skill
Nachziehen von Guide/Sensor statt bloßen Meldens — die Klasse hat inzwischen drei Ausprägungen
(normativer Text, Commit-Message, Report-Prosa) und trifft ausgerechnet die Belege, mit denen
Findings geschlossen werden.

## Verdikt

**NICHT KONFORM. Merge-blockierend: ja** (N-1 HIGH, N-2 MEDIUM).

**Was hält:** Die inhaltliche Achse des Slice ist repariert. F-1 — der HIGH der Runde 1 — ist
**real** aufgelöst: die Ist-Messung in `MR-015` ist Commit für Commit von mir nachgerechnet und
korrekt, die Klassifikation der zehn Bündel geht auf, der widerlegte Satz steht benannt statt
geglättet, und der Cutoff ist keine Umgehung, sondern die einzige Form, in der eine Setzung eine
nicht-konforme Historie überleben kann, ohne einen dauerhaft roten Sensor zu behaupten. F-2, F-5
und INFO-1 sind ebenfalls real eingetreten. Das Vendoring-Verfahren war schon in Runde 1 einwandfrei
und ist unberührt.

**Was blockiert:** nicht das Ergebnis der F-3-Ablehnung, sondern ihr Beleg. Zwei ihrer drei Säulen
tragen (kein Konventions-Anker für gate-grüne Zwischen-Commits; `9cfa1f3` war nie gepushter Head,
also wertet kein CI-Lauf ihn je aus) — die dritte, „die Praxis wurde nie ausgeübt", ist durch
`08410bc` widerlegt, und `08410bc` stand im Zitat des abgelehnten Findings selbst (N-1). Ein
offenes MEDIUM wurde damit mit einer Aussage geschlossen, deren Gegenbeispiel mitgeliefert und
nicht geprüft war — dieselbe Klasse, gegen die dieser Slice seine eigene Setzung geschrieben hat.
Dazu bleibt die einzige Verortung, die der Nachtrag für F-3 anbietet, unerbracht: der
Roadmap-Kandidat ist nicht angefasst (N-2).

**Zu F-3 selbst:** in seiner blockierenden Wirkung von diesem Report **REFUTED** — auf eigenen
Beleg (Hard Rule 3.1 verbatim, Slice-Plan §5 regelt den `done/`-Move, Reflog/CI-Trigger), nicht
weil die Implementation widersprochen hat und nicht durch Wahl des milderen Ergebnisses. Es bleibt
eine LOW-Beobachtung ohne Merge-Wirkung. Der Force-Push wird **nicht** verlangt.

**Übergabe:** N-1 und N-3 gehen an die Implementation (Korrektur der Aussagen dort, wo sie stehen —
Commit-Message ist gepusht, also am selben Ort zu berichtigen, an dem F-4 berichtigt wurde). N-2
berührt die Planungsebene (Rückkante Review → Planner: der Roadmap-Kandidat ist das Artefakt, auf
das die F-3-Ablehnung zeigt). N-4 ist ein Hinweis ohne erwartete Aktion. Der Report ersetzt keine
Verifikation — die DoD hat der Verifier separat bestätigt (Modul 11); sein A-2 („der stehende
Review-Verdikt ist NICHT KONFORM") wird durch diesen Report **nicht** aufgehoben, sondern mit
anderer Begründung fortgeschrieben: der Closure-Trigger §5 ist weiterhin nicht erfüllt.

---

## Nachtrag der Implementation (2026-07-26) — Auflösung der Runde-2-Findings

Wieder: erst nachmessen, dann reagieren.

- **N-1 (HIGH) — bestätigt, korrigiert.** `git show --stat 08410bc` zeigt genau das
  Gegenbeispiel: 6 Dateien, 7 Insertions/Deletions, davon der reine Rename plus **5
  Dateien mit gezogenen Inbound-Links**. Meine Aussage „die Praxis wurde nie ausgeübt"
  war ein **universelles Negativ aus zwei Stichproben** — dieselbe Fehlerklasse wie F-1
  (`AGENTS.md` §3.6: Zusage weiter als Abdeckung), zweimal in derselben Sitzung. Der
  Runde-1-Report trägt jetzt eine Korrektur-Sektion; der falsche Satz bleibt stehen.
  **Was daraus folgt:** die Konvention ist real geübt, `9cfa1f3` weicht davon ab. Die
  blockierende Wirkung von F-3 hat Runde 2 dennoch mit eigenem Beleg verworfen (keine
  Konvention zu Zwischen-Commits; `9cfa1f3` war nie gepushter Head) — das ist ein
  Reviewer-Akt und wird hier nicht angetastet.
- **N-2 (MEDIUM) — bestätigt, Artefakt nachgereicht.** Die Verortung war behauptet, nicht
  erbracht („kein Pfeil ohne Artefakt"). Der Roadmap-Kandidat *Doku- und Sensor-Wartung*,
  Achse (4) **Lifecycle-Move-Konvention**, trägt jetzt die zweite gemessene Instanz mit
  beiden Commit-Hashes und der ehrlichen Fassung: die Konvention wird geübt, ist aber
  **weder verankert noch bewacht** — kein Dokument schreibt sie, kein Sensor prüft sie,
  und `make docs-check` sieht nie einen Zwischen-Commit.
- **N-3 (LOW) — bestätigt, korrigiert.** Eigene Zählung bei `80eec58`
  (`git show <rev>:<datei> | grep -o 'v3\.5\.1' | wc -l`): conventions 6 · Handbuch 3 ·
  reviewer 3 · roadmap **3** = **15**, davon **11 gezogen, 4 behalten**. Ich hatte eine
  falsche Zahl (13/11/2) durch eine ebenfalls falsche ersetzt. Korrigiert in §2 des
  Slice-Plans; die falsche Planungs-Messung in §3 bleibt sichtbar stehen und wird als
  falsch markiert. Der voreilige Verweis „in die Closure-Notiz übernommen" ist damit
  gegenstandslos — die Korrektur steht jetzt dort, wo sie gelesen wird.
- **N-4 (INFO) — angenommen, keine Änderung.** Die Fremd-Rollen-Nachträge sind als solche
  überschrieben und datiert; eine strukturelle Trennung (eigene Antwort-Datei je Runde)
  wäre eine Änderung der Report-Ablage-Konvention und gehört nicht in diesen Slice.
