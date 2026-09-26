# Verifikations-Report: slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt — 2026-09-26

**Rolle:** Verifier (Modul 11) — DoD-/ADR-Konformität und Plan-vs-Code-Diff an den Planner. Frischer Kontext, kein Selbst-Verifizieren. Nicht der Reviewer-Maßstab (Diff gegen Plan, ADR, Hard Rules) und nicht der Validator.

**Gegenstand:** Slice `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt` (Kennung, nicht Pfad: die Datei wandert mit dem Lifecycle, `AGENTS.md` §3.11), Stand HEAD `85643b3b`, Baum sauber. Diff-Basis `6125fe55~1..HEAD`: der Claim-Move `6125fe55`, der Ruhe-Marker `e2d433e7`, der bats-Fall `908c6e88`, Fall 474 `c3e274d9`, Reviewer-Commit `e12b112b`, Nachrunde `22d24bfa` (Fall 475) und `85643b3b` (Formgrenze, Meldung, Kommentar am Filter).

**Maßstab:** DoD und Plan des Slice (Ziel, §1 Abgrenzung, §2 Liefer-Punkte samt „Bricht, wenn", §3, §4, §5 Closure-Trigger, §6 Risiken, §8), `ADR-0070` (Folgepflicht 4, Fitness-Zeile 6, Re-Evaluierungs-Trigger 1), `AGENTS.md` §3.6, §3.7, §3.10, §3.11, `MR-071`, Baseline-Regelwerk Modul 11 §Bewusstes Brechen.

**Eingang:** DoD-Bestätigung und Sensor-Belege des Implementers (Behauptungen, unten je einzeln nachgefahren); der Review-Report zum Slice (`e12b112b`: 0 HIGH · 1 MEDIUM R-1 · 1 LOW R-2 · 1 INFO R-3), nur gelesen — keine Zahl von dort übernommen.

**Eigene Läufe** (Scratchpad-Kopien von `git archive HEAD`, nie im Repo-Baum; kein `go`, kein `python3` auf dem Host; nur der eine bats-Fall im gepinnten bats-Bild, `--network none`, Aufruf-Form aus `make test-bats` mit einer Datei statt `test/`):

- über 20 bats-Läufe über Kopien (Mutationen der `.d-check.yml` und Schwächungen des Tests, Tabelle unten);
- **Teillauf im Repo** `make mutate MUTATE_JOBS=1 MUTATE_CASES='474-codepaths-reviews-ausnahme-entfaellt 475-codepaths-reviews-ausnahme-wandert-in-einen-nachbar-block'`: `2 ok, 0 Befund(e)`, `TEILLAUF 2 von 463 — kein Beleg`; **kein** voller `make mutate`;
- zwei Gegenproben unter `make mutate` in Kopien mit `git init` (Test geschwächt, je ein Fall);
- `make docs-check` und `make gates` am Ende (Ergebnis unten).

**Beleg-Slot** `.harness/state/mutate-passed.key`: **vorher nicht vorhanden, nachher nicht vorhanden** (`ls` beide Male „Datei oder Verzeichnis nicht gefunden"); der Teillauf hat ihn nicht berührt.

## Ergebnis

| Punkt | Verdikt |
|---|---|
| Liefer-Punkt 1 — der Kopplungs-Test | **bestätigt** |
| Liefer-Punkt 2 — der Mutations-Fall, der ihn bindet (Fall 474; dazu Fall 475 aus der Nachrunde) | **bestätigt** |
| `make gates` grün | **bestätigt** (Lauf unten, Stempel deckt den Baum) |
| Review durchgeführt, Report liegt vor | **bestätigt mit Vorbehalt** (V-2: die zwei Nachrunden-Commits sind nach dem Review entstanden und von keinem Reviewer-Lauf gesehen) |
| Closure-Trigger 1 und 2 | **bestätigt** (Rot einmal gesehen, Meldung gelesen; Fall färbt genau diesen Test rot) |
| §1 Abgrenzung, Größe (zwei Liefer-Punkte, eine Schicht) | **bestätigt** |
| Review-Findings R-1, R-2 gezogen und gemessen; R-3 als Übergabe stehen gelassen | **bestätigt** |
| Closure-Pflichten (Notiz §7, Risiko-Ausgänge §6, DoD-Häkchen, Register, Paarungen) | **offen, Planner-Arbeit** (`AGENTS.md` §3.10; §7 steht leer, kein Häkchen gesetzt — richtig so) |

0 HIGH · 0 MEDIUM · 0 LOW · 3 INFO (V-1 bis V-3). Kein Befund ist eine DoD-Verletzung.

## Liefer-Punkt 1 — der Kopplungs-Test: bestätigt

**Zusage** (Slice §2): ein bats-Fall hält die Zeile `exempt-paths: ["docs/reviews/**"]` **unter `codepaths:`**; andere Blöcke tragen `docs/reviews/**` in eigenen `exempt-paths`-Zeilen, gebunden ist allein die unter `codepaths:`. Bricht, wenn die Zeile entfällt und die Form-Regel bleibt: Rot, und die Meldung nennt die Zeile **und** den Re-Evaluierungs-Trigger 1. Andere Zeile entfernen, Kommentarzeile im Block entfernen oder ändern: grün. Die Zeile als Kommentar setzen: rot.

**Gelesen:** `test/codepaths-reviews-ausnahme.bats`, ein Fall. Ein `awk` (`block`) liefert die Nicht-Kommentar-Zeilen des Top-Level-Blocks `codepaths:` (Start bei `^codepaths:`, Ende beim nächsten Schlüssel in Spalte 0, Kommentarzeilen fallen vorher heraus); die Zusicherung ist ein **Positiv-`grep`** über diese Ausgabe — der leere Block ist damit rot, kein stilles Grün. Der Test-Kopf trägt Zusage (Kopplung an `ADR-0070`), Abgrenzung (Zeile, nicht Wahrheit der Gate-Begründung; Bedingung, nicht Implikation Regel ⇒ Zeile), Rang-Zeiger und die Formgrenze; Indikativ, keine Befund-Kennung, kein Lauf-Protokoll (`AGENTS.md` §3.7).

**Gemessen** (jede Zeile ein eigener Lauf; „rot" = der Test färbt, „grün" = er bleibt grün):

| Kopie | Ergebnis |
|---|---|
| HEAD unverändert | grün |
| Fall-474-Mutation: Zeile unter `codepaths:` entfernt | **rot**, Meldung gelesen: *„Im Block codepaths: der .d-check.yml steht die Zeile exempt-paths: ["docs/reviews/**"] (einzeilige Liste, doppelte Anfuehrungszeichen) nicht. Die Form-Regel des Verweis-Nachzugs (ADR-0070) setzt die Ausnahme voraus: ohne sie prueft codepaths jeden Pfad-Span in docs/reviews/**. Fehlt die Ausnahme, ist das Re-Evaluierungs-Trigger 1 der ADR — die Regel ist zu streichen (Folge-ADR), die Zeile nicht still zu entfernen. Steht sie in anderer Schreibform, ist die Zeile in diesem Test mitzuziehen."* — nennt Zeile, `ADR-0070`, Trigger 1 und (neu gegenüber dem Review-Stand) die Schreibform-Ursache |
| Fall-475-Mutation: Zeile aus `codepaths:` entfernt, wortgleich unter `vcs:` neu gesetzt (Diff der Mutation gelesen: eine Zeile weg, eine hinter `vcs:` dazu) | **rot**, dieselbe Meldung |
| die vier `exempt-paths`-Zeilen mit `docs/reviews/**` unter `ids` und `matrix` (drei mit `CHANGELOG.md`, eine mit eigener Liste) von `docs/reviews/**` befreit, `codepaths`-Zeile bleibt | **grün** (DoD: „andere Zeile entfernen lässt ihn grün") |
| Kommentarzeilen im Block `codepaths:` entfernt (Zeilen 375 bis 379 der Ausgangsdatei) | **grün** |
| Kommentarzeile im Block, die beide Wörter nennt, umformuliert (`docs/reviews/**` → `Reports`) | **grün** |
| Zeile als Kommentar in Spalte 0 | **rot** |
| Zeile als eingerückter Kommentar | **rot** |
| `codepaths:` umbenannt (Zeile bleibt stehen) — die im Review genannte Klasse „Zusicherung über einer Menge, die leer sein kann" | **rot** (der Block wird nicht gefunden, die Positiv-Zusicherung fällt) |
| legitime Erweiterung `["x/**", "docs/reviews/**"]` | **grün** |
| äquivalentes YAML als Block-Liste (`exempt-paths:` + `- "docs/reviews/**"`) | **rot**, dieselbe Meldung, die jetzt die Schreibform als zweite Ursache nennt |

**Bestätigt:** jede „Bricht, wenn"-Aussage des Liefer-Punkts 1 ist einzeln gefahren und trifft zu; Meldung nennt Zeile und Trigger 1. Die Klasse „Zusicherung über einer Menge, die leer sein kann" ist belegt: der umbenannte Block färbt rot statt still grün.

**Nur gelesen, nicht gefahren:** die Formen mit einfachen Anführungszeichen, ohne Anführungszeichen und mehrzeilige Flow-Liste (der Reviewer hat sie als rot gemessen; im Muster `\[[^]#]*"docs/reviews/\*\*"` gelesen, dass sie nicht treffen können) — der Test-Kopf nennt seit `85643b3b` die Formgrenze ausdrücklich.

## Liefer-Punkt 2 — die Mutations-Fälle: bestätigt

**Zusage** (Slice §2): ein Fall entfernt die Zeile unter `codepaths:` in einer Kopie und erwartet genau diesen Test rot; *Bricht, wenn* der Fall auch bei einer Mutation rot bliebe, die eine **andere** Zeile trifft; Anker gegen den Quell-Bestand gemessen (`MR-071`).

**Gelesen:** `test/mutations/474-codepaths-reviews-ausnahme-entfaellt.sh` (Kopf `files:`, `expect:` = voller Test-Name, `verify: test-bats`; ein `sed -i … d` auf die Zeile) und, aus der Nachrunde, `test/mutations/475-codepaths-reviews-ausnahme-wandert-in-einen-nachbar-block.sh` (Zeile weg, wortgleich hinter `vcs:`). Beide Modi `100644` wie 470 bis 473. **Anker gegen den Quell-Bestand** (`MR-071`): `grep -c '^  exempt-paths: \["docs/reviews/\*\*"\]$' .d-check.yml` → **1**; das `sed`-Muster des Falls (`\~…~p`) trifft **1** Zeile; `grep -c '^vcs:$' .d-check.yml` → **1**. Die in den Fall-Köpfen genannten Zahlen tragen ihr Kommando im selben Absatz (`MR-025`).

**Teillauf im Repo:** `2 ok, 0 Befund(e)`, `TEILLAUF 2 von 463 — kein Beleg`. Der Treiber prüft, dass die Mutation die Datei ändert, der Sensor rot wird **und** der erwartete Test in der Fehlschlag-Ausgabe steht (`failure_form()`).

**Gegenproben — die Polarität ausgeschrieben** (bei einer Schwächung des **Tests** heißt „grün": der Test bleibt bei der Mutation grün, die geschwächte Stelle ist also **die Bindung, die das Rot getragen hat** — der Zahn bindet; „rot" hieße: ein anderer Zweig deckt den Fall, der Zahn ist unbewacht):

| Schwächung des Tests | Fall | bats-Lauf | unter `make mutate` (Kopie mit `git init`) |
|---|---|---|---|
| Muster über die **ganze Datei** statt über den Block (`cat "$YML" | grep`) | 474 (Zeile entfernt) | **grün** = bindet | `BEFUND … make test-bats blieb GRUEN — '…' hat keine Zaehne mehr` |
| **Block-Ende** aus `block()` gestrichen (Zeile `inblk && /^[^[:space:]]/ { inblk = 0 }`) | 475 (Zeile nach `vcs:`) | **grün** = bindet | `BEFUND … blieb GRUEN … keine Zaehne mehr` |
| Block-Ende gestrichen | 474 (Zeile ersatzlos entfernt) | **rot** — Fall 474 bindet das Block-Ende **nicht** (deshalb Fall 475) | nicht gefahren (aus dem bats-Lauf abgeleitet) |
| Block-Ende gestrichen | HEAD-Datei unverändert | grün — der ungeschwächte Bestand bleibt still | — |
| Kommentar-Filter (`/^[[:space:]]*#/ { next }`) gestrichen | 474, 475 | **rot** — kein Fall bindet den Filter | — |
| Kommentar-Filter gestrichen | HEAD unverändert | grün | — |

**Bestätigt:** Der Fall 474 bindet die Start-Grenze (Ganze-Datei-Schwächung → `BEFUND`), der Fall 475 das Block-Ende (Schwächung → `BEFUND`); beide Gegenproben unter `make mutate` selbst gefahren, die Meldung gelesen, der Grund ist die behauptete Ursache (der Test bleibt bei genau der Mutation grün, die er rot färben soll). Der Fall ist nicht rot bei einer Mutation einer anderen Zeile: die vier `exempt-paths`-Zeilen unter `ids` und `matrix` decken den Test nicht (Tabelle oben, „grün" bei ihrer Entfernung).

**Der Kommentar-Filter bleibt ohne Fall** — und der Test sagt es (`fuer den Filter besteht kein Fall`); das ist die Einschränkung der Zusage auf das Gehaltene, die `AGENTS.md` §3.6 verlangt (V-1).

## Plan-vs-Code-Diff

**Plan → Code (geplant, gebaut):** §3 nennt zwei Artefakte: eine bats-Datei unter `test/` (gebaut: `test/codepaths-reviews-ausnahme.bats`, netzlos, läuft in `make test-bats`, damit in `make gates`) und einen Fall unter `test/mutations/` (gebaut: 474). Die Abschnitts-Erkennung, deren Werkzeug §3 dem Implementer überlässt, ist ein `awk`, das die gebundene Form liefert: nur Zeilen unter dem Top-Level-Schlüssel `codepaths:` bis zum nächsten Top-Level-Schlüssel, Kommentarzeilen ausgenommen. Der Rückführungs-Trigger („nicht ohne Parser bindbar") ist nicht eingetreten.

**Code → Plan (gebaut, nicht geplant):** Fall 475 (Nachrunde) — ein dritter Artefakt-Punkt gegenüber §3, der auf das Reviewer-Finding R-1 zurückgeht und den §2-Wortlaut *Ein Fall … der die Zeile unter `codepaths:` entfernt* nicht verlangt. Das ist keine Ausweitung der Abnahme, sondern Bindung einer im Test-Kommentar zugesagten Eigenschaft (Block-Ende); die Größe bleibt: zwei Liefer-Punkte im Sinn des Slice (Test, Fall), ein zweiter Fall gleicher Art, eine Schicht (Test gegen Config). Zusätzlich im Diff: der Claim-Move (`make slice-mv`, reiner Move, eigener Commit) und die Entfernung des Ruhe-Markers in der Roadmap (drei Zeilen) — beides der Übergang `next` → `in-progress` und keine Slice-Arbeit.

**Nicht berührt, wie §1 verlangt:** `git diff --stat 6125fe55~1..HEAD` nennt Roadmap, Slice-Datei (Rename, 0 Zeilen), den Review-Report, den bats-Fall und die Fälle 474 und 475 — sonst nichts. `.d-check.yml`, `internal/`, `harness/`, `Makefile`, `harness/sensors/`, das Beobachtungs-Register und der Slice-Inhalt (DoD-Häkchen, §7) sind unberührt; die Träger-Seite (`harness/tools/slice-mv.sh`, `internal/archive`) und die emittierte Fassung (`internal/emit`) ebenso. Der Test hält die **Zeile**, nicht die Implikation Regel ⇒ Zeile: fällt die Zeile, färbt er rot, gleichgültig ob die Träger die Regel noch führen — die Meldung nennt deshalb Zeile **und** Trigger 1. Kein Fall für Trigger 2 der ADR. Der Start-Trigger (beide Träger in `done/`) besteht (Kommando aus §4 gibt **2**).

## Review-Findings

| Finding | Stand | Beleg |
|---|---|---|
| R-1 (MEDIUM) — Block-Ende und Kommentar-Filter ohne Fall | **gezogen, gemessen.** Block-Ende: Fall 475, Gegenprobe `BEFUND` unter `make mutate` (Tabelle oben). Kommentar-Filter: Zusage im Kommentar auf das Gehaltene eingeschränkt (*„Dass eine Kommentarzeile mit dem Zielwert keine Zeile vortaeuscht, haelt das Muster der Zusicherung, nicht dieser Filter; fuer den Filter besteht kein Fall"*), die Grenze steht statt einer zugesagten Bindung. Der Filter selbst bleibt ohne Fall (Filter gestrichen: 474 und 475 weiter rot, unverändert grün). | eigene Läufe |
| R-2 (LOW) — Formbindung, Meldung nennt bei äquivalentem YAML Trigger 1 | **gezogen.** Der Test-Kopf nennt die Formgrenze (*einzeilige Flow-Liste mit doppelten Anführungszeichen; Block-Liste, mehrzeilige Liste, einfache oder fehlende Anführungszeichen färben rot*), die Meldung nennt beide Ursachen (Zeile fehlt **oder** andere Schreibform, dann ist die Zeile im Test mitzuziehen). Block-Liste rot gefahren, Meldung gelesen. Das Muster selbst blieb einzeilig — gewählt wurde die Benennung, nicht die Lockerung. | eigener Lauf |
| R-3 (INFO) — Bindung reicht über die geforderte Schärfe hinaus (Unterschlüssel in `codepaths:`, `#`-Ausschluss in der Klammer) | **korrekt als Übergabe stehen gelassen**; der Nachrunden-Diff fasst den Muster-Teil nicht an, der Test-Kopf führt keine Zusage darüber. Nicht neu gemessen. | Diff gelesen |

## Befunde

### V-1 — INFO — zwei Zusagen ohne eigenen Fall: „Zeile als Kommentar → rot" und der Kommentar-Filter

- `Zusage`: Slice §2 Liefer-Punkt 1 (*„die Zeile als Kommentar zu setzen statt zu entfernen färbt ihn rot"*) und der Filter im `block()`-Kommentar.
- `Gemessen`: Zeile als Kommentar (Spalte 0 und eingerückt) → **rot**, also die DoD-Aussage stimmt. Aber es gibt zwei redundante Mechanismen — der Filter wirft die Kommentarzeile heraus, das Muster `^[[:space:]]+exempt-paths:` trifft sie ohnehin nicht —, und **jede einzelne** Schwächung bleibt rot (Filter gestrichen: rot; Muster mit `#?` gelockert, Filter intakt: rot). Ein Mutations-Fall, der eine der beiden Hälften bindet, ist unmöglich, solange die andere greift.
- `Wirkung`: Die DoD verlangt für diese Aussage „rot gesehen", nicht einen Fall (Liefer-Punkt 2 nennt nur den Entfernen-Fall); der Rot-Beleg ist hier von mir gefahren. Der Test-Kommentar sagt ehrlich, dass für den Filter kein Fall besteht. Keine DoD-Verletzung. Für den Fall, dass der Planner die Klasse zählt: *Zusage durch zwei redundante Mechanismen gedeckt, einzeln nicht bindbar* — ein Nachbar von `regel-rand-ohne-benannte-luecke`.

### V-2 — INFO — die Nachrunde ist von keinem Reviewer-Lauf gesehen

- `Befund`: Der Review-Report bezieht sich auf `6125fe55~1..c3e274d9` (den Test und Fall 474). Fall 475 (`22d24bfa`) und die Änderung von Test-Kopf, Meldung und Filter-Kommentar (`85643b3b`) sind **nach** dem Review entstanden; ihre Konformität mit R-1 und R-2 ist hier vom Verifier gemessen (Tabellen oben), nicht von einem zweiten Reviewer-Lauf gelesen. Beide Commits fassen weder Hard Rules noch Adaptions-Block noch ADR noch Sensor-Doku noch Slice noch Register an (Diff gelesen); die Messages beginnen mit `Rolle Implementer:` und tragen `ADR-0070`, `ADR-0042`, `AGENTS.md` §3.6.
- `Wirkung`: Die DoD „Review durchgeführt, Report liegt vor" ist erfüllt (Report `e12b112b` liegt vor, er ist der Review dieses Slice); ob der Planner für die Nachrunde eine erneute Reviewer-Runde will, ist seine Abnahme-Entscheidung. Der Verifier hält die Nachrunde für gemessen und konsistent.

### V-3 — INFO — der Bestand hat nach `codepaths:` keine `exempt-paths`-Zeile: die Kopplung ist gegen einen Nachbarn nur konstruiert gefahren

- `Befund`: Die Fall-475-Situation (Zeile in einem Block **nach** `codepaths:`) tritt im Bestand nicht auf; sie ist eine konstruierte Mutation. Das ist der Sinn eines Mutations-Falls; benannt sei nur, dass der Zahn eine **latente** Lage bewacht (im Bestand ist der Unterschied zwischen Block-Ende und keinem Block-Ende nicht beobachtbar). Der Test färbt auf dem unveränderten Bestand nicht (Zeile „HEAD unverändert", grün; Block-Ende gestrichen, HEAD-Datei: grün).

## Übergaben an den Planner

**Zustandsaussagen, die durch den Abschluss falsch werden und beim Closure nachzuziehen sind** (`git grep`, Zeitdokumente ausgenommen; ADRs sind `Accepted` und bleiben unangetastet, `AGENTS.md` §3.4):

1. `harness/sensors/slice-mv.md` — der Satz *„… ein Kopplungs-Test dafür führt dieses Werkzeug noch nicht."* (Absatz zur Regel unter `docs/reviews/`, endet mit Trigger 1). Nach dem Closure trägt `test/codepaths-reviews-ausnahme.bats` die Kopplung; „noch nicht" ist dann falsch. Zustandsform: der Test und Fall 474/475 als Sensor-Name, die Grenze (Zeile, nicht Wahrheit der Gate-Begründung) bleibt.
2. `harness/sensors/archive-welle.md` — der Satz *„… ein Kopplungs-Test dafür führt dieses Werkzeug nicht."* (Regel unter `docs/reviews/`, Trigger 1). Formal noch wahr (der Test gehört keinem der beiden Werkzeuge), aber neben dem Test ohne Zeiger eine Lücke; zusammen mit 1. nachzuziehen.
3. `docs/plan/planning/observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/state.md` — zwei Stellen: *„… führt ihre Kopplung an `codepaths.exempt-paths` als Gegenstand und hat sie nicht geliefert (er liegt nicht in `done/`)"* und *„ein Wächter für diese Kopplung existiert nicht, bis der Kopplungs-Slice geschlossen ist — Träger ist bis dahin die Rolle, die den Move plant"*. Beides beschreibt den Zustand vor dem Closure; danach: der Wächter existiert (Test und beide Fälle als auflösbarer Anker), die Grenze bleibt (Zeile, nicht Gate-Wahrheit; einzeilige Flow-Liste). Der Zähler ist eine Ableitung: `ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/evidence/*.md | wc -l` → **6** (gemessen am HEAD, keine Erwartungswerte); §8 des Slice nennt dieselbe **6**, die Sichtung gilt noch.
4. `ADR-0070` §Fitness Function (*„Noch nicht gebaut — sie ist die Abnahme von Folgepflicht 1 und 4"*) ist eine Aussage der `Accepted`-ADR und bleibt unangetastet; sie beschreibt die Abnahme, nicht den Stand. Kein Nachzug — nur benannt, damit ein späterer Leser die Zustandsaussage aus 1. bis 3. nicht gegen sie hält.

**§6-Risiken-Ausgänge** (Vorschau des Slice, gesetzt vom Planner): (a) *„Der Test greift die falsche Zeile"* — **entfallen**, die Bedingungen des Ausgangs sind erfüllt: die Gegenprobe (Zeile unter `codepaths:` entfernt) färbt rot, eine andere Zeile entfernt lässt grün, die Kommentarzeile im Block ändert nichts, und der geschwächte Test (Muster über die ganze Datei) bleibt bei entfernter Zeile grün, `make mutate` meldet an dieser Kopie `BEFUND` (beide Gegenproben oben, Polarität ausgeschrieben). (b) *„Der Anker des Mutations-Falls liegt verschoben"* — **entfallen**: Anker gegen den Quell-Bestand je 1, Fall an genau der behaupteten Mutation rot gesehen (Teillauf `2 ok`, Meldung gelesen). (c) *„Der Test bewacht eine Regel, die kein Träger führt"* — **entfallen**, der Start-Trigger verlangte beide Träger, sie liegen in `done/` (Kommando aus §4 → 2).

**Register-Kandidaten** (die Entscheidung, ob ein Zähler steigt, liegt bei der Closure): (1) V-1 als Evidence für `regel-rand-ohne-benannte-luecke` (Zähler 2 am Stand des Slice-§8) — *Zusage von zwei redundanten Mechanismen gedeckt, einzeln nicht bindbar*; Vorgang: dieser Slice. (2) Der Klassen-Nachbar des Reviewers (R-1: *eine Hälfte einer Erkennung ohne Fall*; hier durch Fall 475 in derselben Runde geschlossen — für `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` (Zähler 4, verkörpert) spricht: ein Fall je Erkennungs-Hälfte hat gegriffen, der Reviewer hat die Lücke gefunden, bevor der Verifier sie fand). (3) R-2 und R-3 des Reviewers als `regel-rand-ohne-benannte-luecke`, wie der Reviewer es vorschlägt.

**Lerneintrag-Vorschlag** (Planner schreibt): *geschärfte Regel* — ein Test, der eine Zeile an einen Abschnitt bindet, trägt für die Abschnitts-Erkennung **je Grenze** (Start, Ende) einen Mutations-Fall; die Gegenprobe zum Ende ist eine Verschiebung in den Nachbar-Abschnitt, nicht das ersatzlose Entfernen (das färbt auch ohne Ende rot).

**Kein Befund geht zurück an den Implementer.** Keine Änderung der Abnahme (DoD, Closure-Trigger, Out-of-Scope) ist nötig.

## Was gelesen und was gemessen ist

**Gemessen** (selbst gefahren): der Test grün auf HEAD; rot bei den Mutationen 474 und 475 mit gelesener Meldung; grün bei Entfernen der vier anderen `exempt-paths`-Zeilen und der Kommentarzeilen im Block; rot bei Zeile als Kommentar (zwei Formen), bei umbenanntem `codepaths:` und bei Block-Liste; grün bei legitimer Erweiterung; die Schwächungen Ganze-Datei, Block-Ende und Kommentar-Filter (bats-Läufe); die zwei Gegenproben unter `make mutate` (`BEFUND`, Meldung gelesen); der Teillauf im Repo (`2 ok, 0 Befund(e)`); Anker gegen den Quell-Bestand; Beleg-Slot vorher und nachher; Modi der Fälle.

**Nur gelesen, nicht gemessen:** einfache Anführungszeichen, unquotierter Wert und mehrzeilige Flow-Liste (das Muster kann sie nicht treffen; der Reviewer hat sie gefahren); Unterschlüssel in `codepaths:` und `#`-Ausschluss in der Klammer (R-3, unverändert stehen gelassen); die Gegenprobe „Block-Ende gestrichen, Fall 474" nicht unter `make mutate`, nur im bats-Lauf; die Wahrheit der Gate-Begründung (dass `codepaths` einen Pfad-Span in einem Report tatsächlich nicht prüft) — bewusst nicht Gegenstand (Slice §1, `ADR-0070` als Messung geführt, kein Sensor); der Träger-Seite-Wächter (`test/slice-mv.bats`, `internal/archive`) — Bestand, nicht Gegenstand.

**Nicht gefahren:** ein voller `make mutate` (kein Beleg-Slot, Vorgabe des Auftrags); die emittierte Fassung.

## Gate-Lauf

`make docs-check` und `make gates` am Ende dieses Laufs — die Ergebnisse stehen in der Übergabe-Nachricht an den Aufrufer (Exit-Code und Stempel-Vergleich nach dem Commit des Reports), nicht in diesem Zeitdokument: der Report ist Teil des Prüfgegenstands, und ein Lauf-Protokoll darin wäre ein Stand, den der nächste Commit überholt.
