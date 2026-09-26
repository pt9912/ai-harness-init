# Review-Report: Kurzrunde ADR-0035 Festlegung 5 und ADR-0069 Festlegung 2 — 2026-09-26

**Review-Art:** Kurzrunde vor dem Accept (Modul 8 §Rollen-Regeln: *„Architect schreibt; Reviewer prüft auf Konsistenz"*). Geprüft wird **nur**, ob die Korrekturen des Architect-Laufs `2026-09-26-architect-verdikt-korrektur-adr-0035-0068-0069` die Findings R-35-1, R-69-1 und R-69-2 des Konsistenz-Reviews `2026-09-26-review-adr-0035-0068-0069-konsistenz` tragen und keine neue Inkonsistenz einführen. Kein Neu-Review der ADRs, keine DoD (Verifier).

**Gegenstand:** `ADR-0069` Festlegung 2 samt Alternative F, Kontext-Messungen und Fitness Function · `ADR-0035` Festlegung 5, Trigger 4, Alternativen E bis G, Fitness-Zeile des Teillaufs · ADR-Index-Zeilen von `ADR-0035`, `ADR-0068`, `ADR-0069`. HEAD `b99eebd8`, Baum sauber bei Beginn; kein Code, Test oder Sensor seit dem ersten Review geändert (`git diff --stat 7e17bd0a HEAD -- harness test` leer; seit dann nur der Architect-Commit `1751a10d` unter `docs/plan/adr`).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13) · **Modell:** Sonnet 5 · **Datum:** 2026-09-26

**Eigene Läufe** — ausschließlich in Scratchpad-Kopien außerhalb des Repos (`git clone --no-hardlinks` des HEAD bzw. `git archive`), `bats` und d-check im gepinnten Bild des Makefiles (`--network none`, Mount `:ro`); kein voller `make mutate`, kein Tap-Zugriff, keine Host-Toolchain, kein Schreibzugriff im Repo-Baum außer diesem Report.

| Lauf | Ergebnis |
|---|---|
| **Echter Teillauf** `make mutate MUTATE_JOBS=1 MUTATE_CASES=10-ci-workflow-syntax`, Slot `.harness/state/mutate-passed.key` **vorher** von Hand angelegt (`fake-key-A` + zweite Zeile, 24 Byte) | `1 ok, 0 Befund(e)`, `TEILLAUF 1 von 446 — kein Beleg (der Beleg-Slot bleibt unberuehrt)`, Exit 0, Fall-Zeit 0,61 s. Slot **nachher**: vorhanden, `cmp` byte-gleich. Der Slot im Repo selbst: nicht vorhanden, nie angelegt |
| **Teillauf mit Befund** über **unverändertem** Schlüssel: derselbe Aufruf, Slot = der ausgegebene Schlüssel (`82ebe15c…`), ein `docker`-Ersatz im `PATH` (Shim, Exit 125) als Stellvertreter für einen Zustand außerhalb des Schlüssels | `0 ok, 4 Befund(e)` (Grün-Vorlauf `make ci-lint` rot), `TEILLAUF 1 von 446 — kein Beleg`, Schlüssel unverändert, Exit ≠ 0. Slot nachher: `cmp` byte-gleich |
| danach ein **unerzwungener voller** `make mutate` (Slot = derselbe Schlüssel) | `Beleg fuer Pruefgegenstand 82ebe15c… liegt vor … Kein Fall-Lauf.`, Exit 0; die Meldung nennt den roten Teillauf nicht — **der Rest aus Festlegung 5 ist gefahren, mit einem echten Befund, nicht nur mit grünem Teillauf** |
| `test/mutate-driver.bats --filter Teillauf`, unverändert | `1..5`, alle `ok` |
| M1: Zeile 1649 `[ -n "$partial" ] \|\| clear_belief` → `clear_belief` (genau eine Zeile) | `not ok 4` (*„… laesst einen stehenden Beleg byte-gleich stehen"*), 1, 2, 3, 5 `ok`. Meldung gelesen: `cmp … failed with status 2 — mutate-passed.key: No such file or directory` — rot, **weil der Slot gelöscht wurde**, nicht aus anderem Grund |
| M3: `[ -z "$partial" ] &&` aus der Bedingung des Übersprungs (Zeile 1629) | `not ok 2` (*„… faehrt trotz stehendem Beleg zum aktuellen Schluessel"*), Rest `ok` |
| Register-Schleife aus `ADR-0069` §Kontext gegen HEAD | `4` Verzeichnisse ohne `evidence/*.md` (`ci-rennt-gegen-die-publikation-des-gepinnten-releases`, `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`, `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`, `planungs-bestand-waechst-schneller-als-er-abgebaut-wird`), `180` Verzeichnisse, `abschnitt=62 mit_beleg=58`, `Paarung` in `2` Dateien der vier — alle Zahlen **stimmen** |
| `awk '/^planning:/…' .d-check.yml \| grep -c observations` · `grep -m1 '^modules:' .d-check.yml` | `0` · `[links, anchors, ids, matrix, codepaths, spans, planning, targets, structure]` |
| Sonde aus `ADR-0069` §Kontext (Kopie des Baums, mit/ohne Verzeichnis `sonde` ohne `evidence/`), d-check im gepinnten Bild | ohne Sonde `1962 Datei(en) geprüft, 0 Befund(e)`, mit Sonde `1964 Datei(en) geprüft, 0 Befund(e)` — die Aussage *„bleibt grün über einem fünften beleglosen Verzeichnis"* gilt |
| `ls test/mutations/*.sh \| wc -l` · `grep -l '^# verify: full-smoke' … \| wc -l` | `446` · `19` (ADR-0035 Festlegung 4) |
| Lage-Kommandos `ADR-0035` §Kontext | Gate-Tabelle `0`, Werkzeug-Tabelle `1`, `record-gates` `0`; `grep -c 'MUTATE_' spec/spezifikation.md` `0`; `@sha256:` Makefile `3`/d-check.mk `1`, Dockerfile `FROM … @sha256:` `2` — stimmen |
| Baseline-Wortlaut `modul-06-roadmap.md` | Zitate der ADR an vier Stellen wörtlich gefunden (siehe ADR-0069, Punkt (a)) |

---

## Findings

Kein HIGH, kein MEDIUM. Die Korrekturen tragen R-35-1, R-69-1 und R-69-2 (Einzelbelege je ADR unten).

## ADR-0035 — Festlegung 5, Trigger 4, Alternativen E bis G

### LOW

**K35-1** — `kategorie`: LOW · `quelle`: `ADR-0035` (Darstellung), `AGENTS.md` §3.4 (Immutabilität nach dem Accept) · `pfad`: `docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md:183` · `befund`: Festlegung 5 nennt den Rest *„eine Lockerung der Strenge gegenüber der Alternative (i) unten"*; §Verglichene Alternativen führt die Zeilen A bis G, keine `(i)`. Die Alternative, gegen die die Lockerung gemessen ist, heißt dort **E** (Trigger 4 nennt sie so). Der Verweis löst nicht auf (`grep -n '(i)\|(ii)\|(iii)'` → ein Treffer, dieser). Nach dem Accept ist er eingefroren. · `verifizierbar`: ja (das Kommando). · `klasse`: *Bezeichner einer Alternative nach Umbenennung in einer Festlegung stehen geblieben*

**K35-2** — `kategorie`: LOW · `quelle`: `ADR-0035` Festlegung 5 (Grenze), Trigger 4, `AGENTS.md` §3.6 · `pfad`: `0035-…md:184-187` und `:299-306` · `befund`: Die Grenze des Rests — *„der Bediener hat den Befund des Teillaufs vor sich"* — gilt nur, solange derselbe Kontext den Teillauf und den nachfolgenden vollen Aufruf fährt. Dieses Repo trennt Kontexte (Implementer, Verifier): ein Teillauf mit Befund in einem Kontext und ein `make mutate` über unverändertem Schlüssel im nächsten gibt `Kein Fall-Lauf`, Exit 0 aus (gefahren, oben), ohne dass der zweite Kontext den Befund sieht. Trigger 4 hängt an *„zwei Läufen, die der Verifier liest"*; dass der Verifier den roten Teillauf liest, ist nicht gesichert — er beobachtet nur, was ein Bediener ihm zeigt oder selbst erzwingt. Der Rest ist als benannt, nicht geschlossen ausgewiesen; die Grenze trägt damit über die Kontext-Grenze weniger, als der Satz zusagt. · `verifizierbar`: nein (Prozess-Aussage). · `klasse`: *Grenze einer Lockerung setzt einen Beobachter voraus, den die Rollen-Trennung nicht garantiert*

### INFO

**K35-3** — Einordnung des Rests: **trägt.** Festlegung 5 sagt, der Rest falle weder unter Festlegung 1 (die Verdikt-Funktion bleibt unberührt: jeder gefahrene Fall urteilt wie zuvor) noch unter Festlegung 2 (die Deckung der **Menge** ist gezeigt, was ihr fehlt, steht in Festlegung 4), sei aber eine §3.5-Lockerung gegenüber E — mit Preis der Gegenwahl (ein voller Lauf je rotem Nachsehen), Grenze und Trigger 4. Das ist in sich schlüssig und beantwortet R-35-1. Der Preis-Grund (nicht die Unterscheidbarkeit) hält gegen den Lauf: derselbe Docker-Zustand färbt einen Teillauf rot, ohne dass Exit oder Ausgabe die Infrastruktur vom Fall trennen (`0 ok, 4 Befund(e)` über einem Fall, der unter normalem Docker grün ist). Kein Widerspruch zu den Festlegungen 1 und 2 im Wortlaut; die Überschrift von Festlegung 1 (*„Ein Beleg-Übersprung ist keine Schwellen-Senkung"*) ist unbedingt formuliert und wird durch Festlegung 5 für den Rest ergänzt, nicht widerrufen — wer nur Festlegung 1 liest, übersieht das.

**K35-4** — *„… oder der Fall flackert"* (Festlegung 5) und *„nicht für Flackern ohne Teillauf (Festlegung 4)"* (Alternative E): Festlegung 4 nennt zwei Eingaben außerhalb des Schlüssels (Docker-Cache-Zustand, Host-Werkzeuge), **kein** Flackern. Der Rest hat damit eine dritte Ursache, die die Festlegung als *„der Rest aus Festlegung 4 in der Form, in der er sich zeigt"* nur teils deckt; Trigger 4 fängt sie (ein Befund, der sich im vollen Lauf als echt erweist, ist der Nicht-Flacker-Fall). Wortlaut.

**K35-5** — Die Aussage *„ein unerzwungener voller Aufruf gibt … aus"* hat keinen bats-Fall und das *Rot gesehen* der ADR nennt keinen Lauf dazu; sie steht dort als *„kein Fehlschlag"*, und das ist konsistent. Sie ist mit diesem Lauf gefahren belegt (Tabelle oben).

**K35-6** — Rot-Belege der Fitness-Zeile: die zwei hier gefahrenen Schwächungen (M1 für *löscht nie*, M3 für *übergeht nie*) färben genau die genannten Fälle, M1 aus dem behaupteten Grund (gelöschter Slot). Die Schwächung zu *schreibt nie* (`report_partial` ruft `finalize_belief`) wurde im ersten Review reproduziert; Code seitdem unverändert.

### Geprüft, ohne Befund

Festlegung 5 gegen den Code (`main()` Zeilen 1629, 1649, 1824-1828; Kopf `mutate.sh` Zeilen 93-95) · Trigger 4 (Zählung *„Vier"*, Code-Folge *„eine Bedingung in `main()`"* trifft Zeile 1649) · Alternativen E, F, G: Contra/Pro nachvollziehbar, G ist die gewählte, E und F sind nicht als Gegenwahl verkleidet · Fitness-Zeile des Teillaufs nennt drei Fälle mit je einer rot färbenden Schwächung · Lage-Messungen (Tabelle) · Bezug-Liste gegen Index-Zeile (10 von 10) und Titel gegen Index · Acceptance-Trigger (Kennung, kein Pfad-Link, `ADR-0040`) · `AGENTS.md` §3.11: Verdikte als Kennung, `slice-180` ist Bestand mit dem Vermerk *„Kennung ohne Adresse"*, kein Pfad eines beweglichen Artefakts.

**Accept-Empfehlung ADR-0035: ja nach Korrektur.** Die Substanz der fünf Festlegungen trägt, R-35-1 ist beantwortet, Rest und Rot-Belege sind gefahren. K35-1 ist ein toter Bezeichner in einer Datei, die mit dem Accept immutabel wird — ein Token (`(i)` → `E`), nach dem Trigger eine Darstellung und für sich nicht blockierend, vor dem Accept aber billiger als danach. K35-2 ist eine benannte Grenze; ob der Satz enger zu fassen ist, entscheidet der Architect.

---

## ADR-0069 — Festlegung 2 (Umfang der Paarung im Closure-Schritt)

### Prüfung gegen den Baseline-Wortlaut, wörtlich

| Zitat der ADR | Fundstelle Baseline `modul-06-roadmap.md` | Befund |
|---|---|---|
| *„jede Registerzeile trägt mindestens einen Beleg"* | Closure-Schritt 3, Paarung (c), Zeile 248 | wörtlich vorhanden |
| *„ob jedes Verzeichnis ein nicht leeres `evidence/` hat"* | §Das Beobachtungs-Register, Zeile 115 | vorhanden; die Baseline setzt den ganzen Satzteil fett, die ADR nur *jedes* — Hervorhebung ohne Kennzeichnung, Sinn unverändert |
| *„erst jetzt, weil sie die gerade entstandenen Einträge prüfen; in Schritt 2 gäbe es sie noch nicht"* | Closure-Schritt 3, Zeilen 229-231 (Zeilenumbruch mitten im Zitat) | wörtlich vorhanden |
| *„benannt, nicht gezählt"* / *„gehört trotzdem in den Eintrag"* | §Das Beobachtungs-Register, Absatz *„Ein Vorgang zählt einmal"* | wörtlich vorhanden |

### Trägt die Lesart, ohne dass eine Closure die vier Verzeichnisse überspringen kann?

Ja. Festlegung 2 liest den Satz *„erst jetzt, weil sie die gerade entstandenen Einträge prüfen"* als Grund für den **Zeitpunkt** der Paarungen und die zweite Hälfte von (c) an ihren zwei universalen Sätzen; die erste Hälfte von (c) (*„in einer Closure-Notiz oder einem Risiko-Ausgang genannte Beobachtung"*) ist die closure-gebundene. Der Wortlaut trägt das: der spezifischere, universale Satz für die zweite Hälfte gegen den allgemeinen Satz über *alle drei* Paarungen. Die Folge ist an einer Form zu erkennen — die Closure nennt **jedes** beleglose Verzeichnis namentlich, *„nicht ‚getragen, mit Ausnahme'"* — und damit kann eine Closure die Hälfte nicht abhaken, ohne die vier Namen zu schreiben; ein Wächter, der es erzwingt, existiert nicht (die ADR sagt das). Die Lesart ist strenger als die Gegenlesart, nicht laxer; eine Abweichung von der Baseline nach `MR-000` liegt nicht vor.

**Alternative F fair abgelehnt?** Ja, im Kern: Die Contra-Spalte trägt die Kernaussage (Zeitpunkt-Grund als Umfang gelesen; die *„Ausnahme in der Closure-Notiz"* unter anderem Namen). Die Pro-Spalte nennt nur *„die Closure-Notiz bliebe kurz"*, nicht die stärkste Textstütze von F — dass der Baseline-Satz *„… weil sie die gerade entstandenen Einträge prüfen"* grammatisch die **Paarungen** zum Subjekt hat und ihren Prüfgegenstand nennt. Die Ablehnung hält trotzdem, weil die universalen Sätze der zweiten Hälfte spezifischer sind; das Zugeständnis steht nicht in der Tabelle (K69-1).

### Aktualität der Messungen

Alle Zahlen in §Kontext und Fitness Function stimmen am HEAD (Tabelle oben: `4`, `180`, `62`/`58`, `2`, `0`, Sonde grün mit fünftem Verzeichnis). Die Aussage *„kein Modul liest das Register"* kommt in der ADR **nicht mehr** vor (`grep -n 'kein Modul' 0069-…md` ohne Treffer); an ihrer Stelle steht *„keine aktivierte Regel der Doku-Gate-Konfiguration hält die zweite Hälfte"* mit der Sonde als Beleg, und die Modulliste ist der Ist-Stand. Die Aussage zur Fähigkeit `planning.observations` (verfügbar, nicht aktiviert, Wirkung ungemessen) steht in §Kontext und in §Was hier nicht entschieden ist widerspruchsfrei. R-69-2 ist damit getragen.

### LOW

**K69-1** — `kategorie`: LOW · `quelle`: `ADR-0069` Alternative F, `AGENTS.md` §3.6 (Vergleich ohne die stärkste Gegenposition) · `pfad`: `docs/plan/adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md:197` · `befund`: Die Pro-Spalte von F nennt die Kürze der Closure-Notiz, nicht die grammatische Stütze im Baseline-Satz (Subjekt *„sie"* = die Paarungen, Objekt *„die gerade entstandenen Einträge"*). Ein späterer Leser, der F für die Baseline-treuere Lesart hält, findet die Gegenposition in der Tabelle nicht in ihrer stärksten Form. Die Ablehnung selbst trägt (s. o.). · `verifizierbar`: ja (Baseline Zeilen 229-231). · `klasse`: *Alternative im Vergleich schwächer dargestellt als ihre stärkste Begründung*

### INFO

**K69-2** — Zitate in Anführungszeichen, die keine wörtlichen sind: *„nahezu jede Closure"* und *„ein Beleg je Closure zählte Closures statt Wiederholungen"* (Festlegung 4) stehen im Rumpf des Eintrags `planungs-bestand-waechst-schneller-als-er-abgebaut-wird` als *„… tritt in nahezu jeder Closure auf, der Zähler zählte damit Closures statt Wiederholungen"* — sinngleich, aber flektiert und gekürzt. Der Befund *„begründet ihren fehlenden Beleg wörtlich damit"* stimmt in der Sache (`observation.md` Zeilen 39-40).

**K69-3** — Reihenfolge der Tabelle: Zeile F steht vor Zeile E; die gewählte Option ist E. Kein Inhalts-, nur ein Leseweg-Hinweis.

**K69-4** — `AGENTS.md` §3.11 (künftig eingefroren, ADR ab Accept): **kein Befund.** Verdikte als Kennung, `harness/conventions.md` und `harness/sensors/docs-check.md` ortsfest, `docs/plan/planning/observations/BEO-ALL/…` stehende Ablage (`ADR-0034` Festlegung 5), keine Slice-Adresse (`grep -n 'slice-'` nur der Sonden-Dateiname `slice-x.md`). Der Verweis auf `.harness/baseline/v6.9.0/templates/…` (Zeile 113) trägt den Tag im Pfad und steht als datierte Messung (`gelesen gegen v6.9.0`), nicht als Adresse eines beweglichen Artefakts — bei einem Baseline-Sprung löst er dann nicht mehr auf; das ist der Bestandsfall aller ADRs mit Baseline-Kommandos und hier nicht neu.

### Geprüft, ohne Befund

Festlegung 2 gegen Festlegungen 1, 3 und 4 (*„ein Maßstab, kein Doppelmaßstab"*, kein Widerspruch; Festlegung 4 nennt den Bestandseintrag mit widersprechendem Rumpf und verweist ihn auf den Weg über Belege, Trigger 1 löst für ihn nicht aus, wie sein Rumpf sagt) · Folgepflicht 1 (Register-Ablage trägt die Lesart, *„erstreckt sich im Closure-Schritt auf das ganze Register"*) und Folgepflicht 2 (Dateien statt Verzeichnis) gegen Festlegung 2 · Cutoff (*„das Nennen der Namen in der Closure ist keine Tilgung"*) · Fitness Function (*rot gesehen* der Schleife im ersten Review reproduziert: Sonde `5`, leeres `evidence/` `5`, `.gitkeep` `5`, `slice-x.md` `4`; Code und Register seitdem ohne Bezug geändert) · Bezug-Liste gegen Index-Zeile (7 von 7) und Titel gegen Index · Zuständigkeit (`AGENTS.md` §3.8: die ADR schreibt keine Hard Rule und keinen `MR`) · Acceptance-Trigger (Kennung, kein Pfad-Link).

**Accept-Empfehlung ADR-0069: ja.** Festlegung 2 trägt den Baseline-Wortlaut, ohne dass eine Closure die vier Verzeichnisse überspringen kann; R-69-1 und R-69-2 sind getragen, keine neue Inkonsistenz. K69-1 ist eine Darstellung der Alternative und blockiert die Annahme nicht.

---

## Index `docs/plan/adr/README.md`

Zeilen für `ADR-0035` (Bezug 10 von 10, Titel gleich der Überschrift), `ADR-0068` (Titel, Status `Proposed`, Bezug 6 von 6 gegenüber dem ersten Review unverändert) und `ADR-0069` (Bezug 7 von 7, Titel gleich der Überschrift, Status `Proposed`) stimmen mit den Dateien. Kein Befund.

## Summary

| ADR | HIGH | MEDIUM | LOW | INFO | Accept-Empfehlung |
|---|---|---|---|---|---|
| ADR-0035 (Festlegung 5, Trigger 4, E bis G) | 0 | 0 | 2 (K35-1, K35-2) | 4 | ja nach Korrektur (K35-1, ein Token) |
| ADR-0068 | — | — | — | — | ja (unverändert gegenüber dem ersten Review; nicht neu geprüft) |
| ADR-0069 (Festlegung 2) | 0 | 0 | 1 (K69-1) | 3 | ja |

Die Ersteinstufungen R-35-1, R-69-1 und R-69-2 sind aufgelöst: R-35-1 durch die Einordnung des Rests (Festlegung 5, K35-3), R-69-1 durch den universalen Umfang im Closure-Schritt, R-69-2 durch die korrigierte Aussage und die gemessene Sonde.

## Übergaben

| An | Was | Artefakt |
|---|---|---|
| Architect | `ADR-0035` K35-1 (Bezeichner `(i)` → `E`, vor dem Accept), K35-2 (Grenze des Rests über die Kontext-Grenze), K35-4 (Wortlaut *Flackern*); `ADR-0069` K69-1 (Pro-Zelle von F) | dieser Report |
| Auftraggeber | Accept je ADR — die Empfehlung steht oben; die Entscheidung ist seine | dieser Report |
| Planner (nach Accept, Slice-Closure §7) | Finding-Klassen dieser Runde ins Beobachtungs-Register einordnen, soweit ein Vorgang sie trägt | dieser Report |

## Negativbefund-Zeilen (Skill: pro betrachtetem Bereich)

- **Verstoß gegen aktive ADR / Hard Rule** — geprüft, ohne Befund (`ADR-0034`, `0049`, `0040`, `0015` nicht berührt; `AGENTS.md` §3.4: keine `Accepted`-Datei geändert).
- **Gate-Lockerung ohne ADR** — geprüft, ohne Befund: die einzige Lockerung (Rest aus Festlegung 5) steht als benannte §3.5-Lockerung in der ADR selbst.
- **Stilles-Grün-Pfad** — der Rest aus Festlegung 5 (K35-2) ist benannt und mit Ausschalter und Trigger versehen; sonst ohne Befund.
- **Halluziniertes Gate** — geprüft, ohne Befund (`make mutate`, `MUTATE_CASES`, `MUTATE_FORCE`, `MUTATE_JOBS` existieren).
- **Referenz auf superseded ADR** — geprüft, ohne Befund.
- **Norm nur im Template-Kommentar** — nicht einschlägig.
- **Kommentar trägt keine Klasse** — nicht einschlägig (kein Code, keine Konfiguration geändert).
- **Zustandsfeld trägt Chronik** — geprüft, ohne Befund (Index-Statuszellen `Proposed`; Geschichte-Tabellen sind das Ereignis-Register der ADRs).
- **Eigenschaft statt Adresse in eingefrorenen Artefakten (`AGENTS.md` §3.11)** — geprüft, ohne Befund (K69-4).
- **Zusicherung über einer Menge, die leer sein kann** — geprüft, ohne Befund: die Register-Schleife ist mit Nicht-Null-Basis (`4` von `180`) und mit der Gegenprobe (fünftes Verzeichnis `5`, mit Beleg wieder `4`) belegt.
