# Review-Report: slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt — 2026-09-26

**Review-Art:** Test- und Mutations-Fall-Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 6125fe55~1..c3e274d9` (4 Commits, Baum sauber). `6125fe55` (`make slice-mv`, Claim-Move `next/` → `in-progress/`), `e2d433e7`
(Ruhe-Marker der Roadmap entfernt, drei Zeilen), `908c6e88` (`test/codepaths-reviews-ausnahme.bats`, ein Fall, 48 Zeilen), `c3e274d9`
(`test/mutations/474-codepaths-reviews-ausnahme-entfaellt.sh`, 19 Zeilen).

**Plan-Bezug:** Slice `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt` (§1 Ziel und Abgrenzung, §2, §3, §4, §6, §8) — Kennung, nicht Pfad: der Plan
wandert mit dem Lifecycle (`AGENTS.md` §3.11). **Constraint:** `ADR-0070` (`Accepted`; Folgepflicht 4, Fitness-Zeile 6, Re-Evaluierungs-Trigger 1 und 2), `ADR-0042`,
`MR-071`, `AGENTS.md` §3.3, §3.6, §3.7, §3.8, §3.9, §3.10, §3.11.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-26

**Eingangs-Kontext:** Diff · Slice-Plan vollständig · `ADR-0070` (Folgepflicht 4, Fitness, Trigger) · `.d-check.yml` (Blöcke `ids`, `matrix`, `codepaths`, `vcs`) ·
`failure_form()` in `harness/tools/mutate.sh` · Nachbar-Fälle 470 bis 473 · das Vorgänger-Review des zweiten Trägers (Form-Muster) · `AGENTS.md` §3. Der Implementer-Bericht
lag dem Lauf als Behauptung vor und ist nicht übernommen; jede Zeile davon ist unten gemessen.

**Eigene Sensor-Läufe dieses Laufs** — Scratchpad-Kopien von `git archive HEAD` (kein `.git`, außer einer, s. u.), nur der eine bats-Fall im gepinnten bats-Image
(`docker run --network none`, Aufruf-Form aus `make test-bats` mit einer Datei statt `test/`); ein Teillauf im Repo
(`make mutate MUTATE_JOBS=1 MUTATE_CASES='474-…'`), kein voller `make mutate`, kein Push, keine Host-Toolchain.

## Messbeleg

Polarität je Zeile ausgeschrieben: „rot" = der Test färbt, die Schwächung der **Datei** ist erkannt; bei einer Schwächung des **Tests** heißt „grün" = der Test bleibt bei entfernter
Zeile grün, die geschwächte Stelle ist also **die Bindung, die das Rot getragen hat** (Gegenprobe bindet).

| Lauf | Ergebnis |
|---|---|
| unverändert, Kopie von HEAD, nur der Fall | `ok`, Exit 0 |
| (a) Zeile unter `codepaths:` entfernt | rot; Meldung gelesen: *„Im Block codepaths: der .d-check.yml fehlt die Zeile exempt-paths: ["docs/reviews/**"]. … Re-Evaluierungs-Trigger 1 der ADR — die Regel ist zu streichen (Folge-ADR), die Zeile nicht still zu entfernen"* — nennt Zeile, ADR, Trigger 1 |
| (b1) Zeile als Kommentar in Spalte 0 | rot |
| (b2) Zeile als eingerückter Kommentar | rot |
| (c) Zeile aus `codepaths:` entfernt und in `vcs:` (anderer Block, **nach** `codepaths`) neu gesetzt; `ids` und `matrix` tragen ihre Zeilen weiter | rot |
| (c') dieselbe Datei wie (a): die vier `exempt-paths`-Zeilen mit `docs/reviews/**` unter `ids` und `matrix` stehen unverändert da | rot — sie decken den Test nicht |
| Gegenrichtung: die Zeilen unter `ids`/`matrix` von `docs/reviews/**` befreit, `codepaths`-Zeile bleibt | grün (DoD-Aussage „andere Zeile entfernen lässt grün" gilt) |
| (d1) `exempt-paths: ["other/**"]  # "docs/reviews/**"` | rot |
| (d2) `exempt-paths: ["other/**"]  # ["docs/reviews/**"]` | rot |
| (d3) `exempt-paths: ["x/**", "docs/reviews/**"]` (legitime Erweiterung) | grün |
| (e1) Block-Liste `exempt-paths:` + `- "docs/reviews/**"` (äquivalentes YAML) | **rot** — False Positive, R-2 |
| (e2) mehrzeilige Flow-Liste | **rot** — False Positive, R-2 |
| (f1) einfache Anführungszeichen | **rot** — False Positive, R-2 |
| (f2) ohne Anführungszeichen (`[docs/reviews/**]`) | **rot** — False Positive, R-2 |
| (f3) Leerzeichen in der Klammer | grün |
| Tabs als Einrückung | nicht gefahren: YAML lässt Tabs als Einrückung nicht zu; das Muster akzeptiert sie, ohne dass ein gültiges YAML sie trägt |
| (g1) `codepaths:` umbenannt, Zeile bleibt stehen | rot (leerer Block ist kein stilles Grün: die Zusicherung ist ein Positiv-Grep) |
| (g2) `codepaths:` auskommentiert | rot |
| (h) Zeile aus dem Block genommen und unter einen Unterschlüssel `sub:` **in** `codepaths:` gesetzt | **grün** — INFO R-3 |
| (i) Schlüssel `exempt-paths-alt:` mit demselben Wert | rot |
| W1 Test geschwächt: Muster über die **ganze Datei**, Datei unverändert | grün |
| W1 Test geschwächt, Zeile entfernt | **grün** — die Block-Bindung trägt das Rot: die Gegenprobe bindet |
| W1 unter `make mutate` (Kopie mit `git init`, Teillauf Fall 474) | `BEFUND … make test-bats blieb GRUEN — '…' hat keine Zaehne mehr` — der Fall bewacht die Block-Bindung |
| W2 Test geschwächt: Kommentar-Filter (`/^[[:space:]]*#/ { next }`) entfernt, Datei unverändert | grün |
| W2, Zeile entfernt | rot — der Fall 474 wird damit **nicht** grün, kein Fall bindet den Filter |
| W2, Zeile als eingerückter Kommentar gesetzt | rot — die Ausrichtung des Musters (`^[[:space:]]+exempt-paths:`), nicht der Filter, hält die Kommentarzeile heraus |
| W2, ein Kommentar in Spalte 0 mitten im Block, `codepaths`-Zeile intakt | rot (Filter fehlt: der Kommentar beendet den Block) |
| Kontrolle: derselbe Spalte-0-Kommentar, Test ungeschwächt | grün — der Filter hat eine Wirkung, aber nur in dieser Lage, und vor der Zeile führt der Bestand sie nicht (im Bereich der Block-Zeilen 373 bis 449 stehen Spalte-0-Kommentare nur **hinter** der Zeile, ab Zeile 422 vor `vcs:`; vor ihr keiner) |
| W3 Test geschwächt: Block-Ende (`inblk && /^[^[:space:]]/ { inblk = 0 }`) entfernt, Datei unverändert | grün |
| W3, Zeile entfernt | rot — Fall 474 bindet das Block-Ende nicht |
| W3, Zeile aus `codepaths:` entfernt und in `vcs:` gesetzt | **grün** (Kontrolle mit Block-Ende: rot) — R-1 |
| Teillauf im Repo `make mutate MUTATE_JOBS=1 MUTATE_CASES='474-codepaths-reviews-ausnahme-entfaellt'` | `1 ok, 0 Befund(e)`, `TEILLAUF 1 von 462 — kein Beleg`; Beleg-Slot `.harness/state/mutate-passed.key` **vorher nicht vorhanden, nachher nicht vorhanden**; Baum danach sauber |
| MR-071: Anker `grep -c '^  exempt-paths: \["docs/reviews/\*\*"\]$' .d-check.yml` und Treffer des `sed`-Musters (`\~…~p`) | je **1** |
| Modus im Index | 474: `100644`, wie 470 bis 473 |
| `git diff --stat 6125fe55~1..c3e274d9 -M` | Roadmap (3 Zeilen gelöscht), Slice-Datei (Rename, `0` Zeilen, 100 %), ein bats-Fall, Fall 474 — sonst nichts; `harness/sensors/`, `docs/plan/planning/observations/`, Slice-Inhalt (DoD, §7), `.d-check.yml` unberührt |
| Claim-Commit: Roadmap-Diff gegen den des Vorgänger-Claims (`cc5de0d9`) | Hunk und Blob-Hashes (`0ed25b08..c3c4d072`) identisch |

## Findings

### R-1 — MEDIUM — Block-Ende und Kommentar-Filter der Block-Erkennung sind im Kommentar zugesagt, aber von keinem Fall gehalten

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` §3.6 (Zusage ohne rot gesehenes Gegenbeispiel), Slice §1 und §3 (gebunden: „nur Zeilen unter `codepaths:` bis zum nächsten Top-Level-Schlüssel, Kommentarzeilen
  ausgenommen"), Beobachtung `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` (verkörpert in `AGENTS.md` §3.6)
- `pfad`: `test/codepaths-reviews-ausnahme.bats:26-30` (Kommentar „Ende beim naechsten Top-Level-Schluessel … ein Kommentar in Spalte 0 beendet den Block nicht, und eine
  Kommentarzeile im Block taeuscht keine Zeile vor"), `:31-36` (awk-Block)
- `befund`: Die **Start**-Grenze des Blocks trägt Fall 474 (W1: Muster über die ganze Datei, bei entfernter Zeile grün, und `make mutate` meldet an dieser Kopie `BEFUND`). Die zwei
  anderen Hälften der Block-Erkennung überleben jede gelieferte Prüfung: entfällt das Block-Ende (W3), bleibt der bats-Fall bei unveränderter Datei grün, bei entfernter Zeile rot,
  und Fall 474 meldet an dieser Kopie weiter `ok` (aus „W3, Zeile entfernt: rot“ abgeleitet, nicht unter `make mutate` gefahren) — nur eine Mutation, die die Zeile in einen späteren Block (hier `vcs:`) *verschiebt*, färbt Kontrolle rot und W3 grün, und
  eine solche Mutation steht in `test/mutations/` nicht. Der Kommentar-Filter (W2) ist ebenso ungebunden: das Rot entsteht am Muster (`^[[:space:]]+exempt-paths:`), das eine
  Kommentarzeile ohnehin nicht trifft; der Filter wirkt nur bei einem Kommentar in Spalte 0 mitten im Block, und den führt der Bestand nur hinter der Zeile (ab Zeile 422), nicht davor. Der Satz „eine Kommentarzeile im Block
  taeuscht keine Zeile vor" schreibt dem Filter zu, was die Muster-Verankerung hält.
- Failure-Szenario: `.d-check.yml` bekommt in einem Block **nach** `codepaths:` (`vcs`, `commits`, `sources`) eine eigene `exempt-paths`-Zeile mit `docs/reviews/**`, und die Zeile unter
  `codepaths:` entfällt. Der Test bleibt grün (W3, Zeile in `vcs:`), obwohl `codepaths` die Ausnahme verloren hat und Re-Evaluierungs-Trigger 1 gefeuert hat — das Stille-Grün, das
  die Bindung an den Block verhindern soll. Bestand heute: nach Zeile 384 trägt kein Block eine `exempt-paths`-Zeile (`grep -n 'exempt-paths' .d-check.yml`, keine Erwartungswerte),
  das Szenario ist latent; die Zusage steht trotzdem im Kommentar.
- `verifizierbar`: ja (W3 und der Spalte-0-Kommentar aus dem Messbeleg; ein Fall, der die Zeile in `vcs:` verschiebt, färbt die geschwächte Fassung grün und den Test rot)
- `klasse`: Zusage im Kommentar ohne Zahn — eine Hälfte einer Erkennung ohne Fall

### R-2 — LOW — der Test hält eine Schreibform, nicht die Aussage; äquivalentes YAML färbt ihn rot, und die Meldung nennt dann Trigger 1

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6 (Test-Name behauptet die Bedingung, die er misst), `ADR-0070` Trigger 1 (*„an `.d-check.yml` ablesbar"*: die Ausnahme fällt weg), Maintainability
- `pfad`: `test/codepaths-reviews-ausnahme.bats:42` (Muster `\[[^]#]*"docs/reviews/\*\*"`), `:44-48` (Meldung)
- `befund`: Das Muster kennt genau die einzeilige Flow-Liste mit doppelten Anführungszeichen. Block-Liste, mehrzeilige Liste, einfache Anführungszeichen und unquotierter Wert (e1, e2, f1, f2)
  sind dieselbe Ausnahme in gültigem YAML und färben den Test rot; die Meldung sagt dann *„fehlt die Zeile … Das ist Re-Evaluierungs-Trigger 1 der ADR — die Regel ist zu streichen"*,
  obwohl `codepaths` die Ausnahme behält. Weder Test-Kommentar noch Name nennen die Formgrenze; die DoD nennt „die Zeile", der Test-Kommentar an derselben Stelle ebenso, so dass die
  Grenze der Zusage („die Zeile in dieser Form") nirgends als solche steht. Die Richtung ist laut (rot), nicht still.
- Failure-Szenario: ein Rolleninhaber formatiert die Liste um (etwa in die Block-Form, weil sie länger wird — eine ergänzende Ausnahme wie `CHANGELOG.md` steht in `ids` bereits so). Der Test
  färbt rot, die Meldung schickt in ein Folge-ADR-Verfahren über eine Ausnahme, die nicht gefallen ist; der Leser muss das Muster lesen, um den Fehlalarm zu erkennen.
- `verifizierbar`: ja (e1, e2, f1, f2 aus dem Messbeleg)
- `klasse`: Regel-Rand ohne benannte Lücke (Formbindung einer Zusage über Semantik)

### R-3 — INFO — die Bindung reicht über die geforderte Schärfe hinaus, ohne dass ein Fall die Mehrschärfe hält

- `kategorie`: INFO
- `quelle`: Slice §1 (der Test hält die Zeile, nicht die Implikation), `AGENTS.md` §3.6
- `pfad`: `test/codepaths-reviews-ausnahme.bats:42`
- `befund`: (a) Das Muster verlangt jede Einrückungstiefe (`[[:space:]]+`): eine `exempt-paths`-Zeile unter einem **Unterschlüssel** von `codepaths:` (h) hält den Test grün. Ob `d-check` eine
  solche Zeile als datei-weite Ausnahme liest, ist hier nicht gemessen und nicht Gegenstand (Werkzeug-Aussage, nicht an dieser Stelle belegt). (b) Der Ausschluss von `#` in der Klammer
  färbt einen Zeilenende-Kommentar mit dem Zielwert rot (d1, d2); kein Mutations-Fall hält diese Strenge, sie überlebt jede Lockerung des Musters. Beides ist keine Zusage des Tests oder
  Slice; es steht hier, damit die Grenze benannt ist statt vermutet.
- `verifizierbar`: ja (h, d1, d2)
- `klasse`: Regel-Rand ohne benannte Lücke

## Geprüft, ohne Befund

- **Der Test selbst** — grün am unveränderten Stand, rot bei entfernter Zeile mit gelesener Meldung (Zeile, `ADR-0070`, Trigger 1, Aufforderung *„nicht still zu entfernen"*); die Meldung
  nennt die behauptete Ursache und ist für einen Leser ohne Kontext eindeutig; sie trägt keine wandernde Adresse (`AGENTS.md` §3.11: ADR-Kennung, `.d-check.yml` und der Glob `docs/reviews/**`
  sind ortsfest). Die Zusicherung ist ein Positiv-Grep über die Block-Ausgabe, kein `! grep` über einer Menge: der leere Block ist rot (g1, g2), die MEDIUM-Zeile „Zusicherung über
  einer Menge, die leer sein kann" trifft nicht.
- **Andere Blöcke decken den Test nicht** — die vier weiteren `exempt-paths`-Zeilen mit `docs/reviews/**` (unter `ids`, `matrix`) und die Kommentarzeile im Block halten ihn nicht grün (a, c, c');
  die Zeile als Kommentar (b1, b2) färbt ihn rot; ein legitimer Zusatzwert in der Liste (d3, f3) nicht.
- **Zusagen in Kommentar und Test-Name (§3.7, §3.6)** — Test-Kopf: Zusage (Kopplung an `ADR-0070`), Abgrenzung (*„Gehalten wird die ZEILE, nicht die Wahrheit der Gate-Begruendung"*,
  *„die BEDINGUNG, nicht die Implikation Regel ⇒ Zeile"*), Rang-Zeiger (`ADR-0070`, `ADR-0042`) und Kopplung an Fall 474; Indikativ über den Zustand, keine Befund-Kennung, keine
  Slice-Nummer als Erzählung, kein Lauf-Protokoll. Test-Name und Kommentar stehen auf derselben Linie wie Slice §1 (die Zeile, nicht die Implikation): der Name sagt *„fuehrt die Zeile … die
  Bedingung der Form-Regel"*, nicht „hält die Kopplung". Der Satz *„Faellt sie, prueft das Doku-Gate jeden Pfad-Span in den Reports"* steht als Aussage der ADR (dort als Messung geführt) und wird
  im Absatz danach eingeschränkt. Rest: R-1 (die zwei Erkennungs-Hälften), R-2 (Formgrenze).
- **Fall 474** — Kopf `# files:` / `# expect:` / `# verify: test-bats` vorhanden, Aufbau und Wortlaut wie 470 bis 473 (NIMMT … / WAS DAS MISST: …); `expect:` ist der volle Test-Name und trifft ihn
  genau (Teillauf: `ok … -> codepaths fuehrt die Zeile … rot`); `verify: test-bats` gegen `failure_form()` (`not ok [0-9]+`) gelesen; Anker gegen den Quell-Bestand **1** (MR-071),
  die im Kopf genannte Zahl trägt ihr Kommando im selben Absatz (`AGENTS.md`/`MR-025`); Modus `100644` wie die Nachbarn. Die Aussage *„Die Datei traegt `docs/reviews/**` in weiteren
  exempt-paths-Zeilen (unter ids und matrix)"* stimmt gegen `.d-check.yml` (Zeilen 324, 328, 340 unter `ids`, Zeile 371 unter `matrix`). Die Begründung *„ein Test, der die ganze Datei absucht, bliebe bei
  dieser Mutation gruen"* ist an W1 rot gesehen (`BEFUND` unter `make mutate`).
- **Claim-Commit `6125fe55`** — `make slice-mv`, reiner Move (`git show --stat --summary`: `rename … (100%)`, 0 Zeilen), eigener Commit (§3.3); `e2d433e7` entfernt genau den Ruhe-Marker (drei Zeilen,
  Hunk und Blob-Hashes identisch mit dem Vorgänger-Claim) und fasst sonst nichts an.
- **Rollen- und Commit-Zuschnitt (§3.8, §3.10)** — der Diff schreibt weder Hard Rules noch Adaptions-Block noch ADRs noch Sensor-Doku noch den Slice-Inhalt (DoD-Haken, §7) noch das Register;
  die Messages beginnen mit `Rolle Implementer:` und tragen `ADR-0070`, `ADR-0042`, `AGENTS.md` §3.6.
- **Abgrenzung §1** — `.d-check.yml` unberührt (Kopplung im Test), keine Träger-Änderung (`harness/tools/slice-mv.sh`, `internal/archive`, `internal/emit` nicht im Diff), keine emittierte Fassung,
  kein Fall für Trigger 2 der ADR; der Start-Trigger (beide Träger in `done/`) ist mit dem Slice-Plan gelesen.
- **HIGH-Liste des Skills** — kein Verstoß gegen eine aktive ADR oder Hard Rule (§3.9: nur Docker-Läufe, `make`-Targets im Repo; §3.7 s. o.); keine Gate-Lockerung; kein Stilles-Grün-Pfad in einem Gate
  — der Test färbt bei jeder gefahrenen Mutation der Zeile rot, R-1 ist die latente Klasse und deshalb MEDIUM; kein halluziniertes Gate (kein neues `make`-Ziel, der Fall läuft in `test-bats`);
  keine superseded ADR; keine Norm nur im Template-Kommentar; kein Zustandsfeld beschrieben (Roadmap: Marker entfernt, keine Chronik).
- **`make gates`-Deckung** — der Fall liegt unter `test/` und läuft in `make test-bats`; der Gate-Lauf steht unten.

## Summary

0 HIGH · 1 MEDIUM (R-1) · 1 LOW (R-2) · 1 INFO (R-3). Klassen für §7: R-1 *Zusage im Kommentar ohne Zahn — eine Hälfte einer Erkennung ohne Fall* (Nachbar der verkörperten Klasse
`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`: dort fehlt der Fall für die ganze Zusage, hier für zwei Teile einer sonst gebundenen), R-2 und R-3 *Regel-Rand ohne benannte Lücke*.
Die Kernzusage — die Bindung der Zeile an den Block `codepaths:` gegen die Zeilen anderer Blöcke — hält: W1 färbt den Fall 474 `BEFUND`.

## Übergaben

- **Implementer:** R-1 (ein Fall in `test/mutations/`, der die Zeile in einen **späteren** Block verschiebt, samt Gegenprobe wie bei 471 — oder die Zusage im Kommentar auf die Start-Grenze einschränken und
  Block-Ende und Spalte-0-Kommentar als ungebunden nennen; den Satz zum Kommentar-Filter dem Muster zuschreiben); R-2 (die Formgrenze im Kommentar nennen — *einzeilige Flow-Liste, doppelte
  Anführungszeichen* — und die Meldung so fassen, dass sie Trigger 1 nur für den Fall nennt, dass die Ausnahme fehlt, oder die Form-Varianten in das Muster nehmen); R-3 nur bei Bedarf.
- **Planner:** keine Änderung der Abnahme. Für §7: die Klassen R-1 und R-2/R-3 als Evidence-Kandidaten (`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`, `regel-rand-ohne-benannte-luecke`);
  ob der Zähler steigt, entscheidet die Closure.
- **Architect:** keine.
