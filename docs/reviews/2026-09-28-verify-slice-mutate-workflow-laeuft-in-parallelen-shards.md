# Verifikations-Report: slice-mutate-workflow-laeuft-in-parallelen-shards — 2026-09-28

**Rolle:** Verifier (Modul 11) — DoD-/ADR-Konformität und Plan-vs-Code-Diff an den Planner.
Frischer Kontext, kein Selbst-Verifizieren. Nicht der Reviewer-Maßstab (Diff gegen Plan/ADR/Hard
Rules).

**Gegenstand:** Slice `slice-mutate-workflow-laeuft-in-parallelen-shards`
(`docs/plan/planning/in-progress/slice-mutate-workflow-laeuft-in-parallelen-shards.md`, §1–§8
vollständig gelesen). Commits `33bdd5ff` (slice-mv, reiner Move) und `e46ba9e9` (Implementierung:
`.github/workflows/mutate.yml` Matrix mit 5 Shards, `harness/sensors/mutate.md` Nachzug).
Review-Report `docs/reviews/2026-09-28-slice-mutate-workflow-laeuft-in-parallelen-shards.md`
gelesen (0 HIGH, 0 MEDIUM, 1 LOW F-1, 1 INFO F-2) — keine seiner Zahlen ungeprüft übernommen; jede
unten berichtete Messung ist selbst gefahren.

**Maßstab:** DoD (§2 des Slice-Plans, zwei Liefer-Punkte), `AGENTS.md` §3.2/§3.3/§3.5/§3.6/§3.7,
`MR-014`, Baseline-Regelwerk Modul 11 (Bewusstes Brechen für DoD-Testbehauptungen), Modul 5
(Offene Risiken werden bei Closure aufgelöst).

## Ergebnis

| Punkt | Verdikt |
|---|---|
| DoD-Liefer-Punkt 1 — Matrix, deterministische Zuteilung, Konstante, `fail-fast: false`, `ci-lint` | **bestätigt, unabhängig reproduziert — bis auf den real ausstehenden `workflow_dispatch`-Lauf** |
| DoD-Liefer-Punkt 2 — Doku-Nachzug `harness/sensors/mutate.md` / `harness/README.md` | **bestätigt, unabhängig geprüft** |
| `make ci-lint` | **selbst gefahren: EXIT 0** |
| Code-Stand seit `e46ba9e9` inhaltlich unverändert | **bestätigt (`git diff` leer)** |
| Gates-Stempel veraltet | **bestätigt als reines Reihenfolge-Artefakt, kein inhaltlicher Mangel** |
| F-1 (LOW, Reviewer) — `strategy.job-total`-Kopplung | **kein Korrektheitsrisiko für diesen Slice — eigenständig eingeordnet; kein Verifier-Nachtrag nötig** |
| AGENTS.md §3.6 (rot-vor/grün-nach) für den Fehlkonfigurations-Guard | **erfüllt — dreifach reproduziert (Implementer, Reviewer, ich)** |
| Realer CI-Beleg (`workflow_dispatch`) | **explizit auf „nach Push" verschoben (Plan §5), kein Verifier-Blocker, aber Closure-Vorbedingung** |
| §6-Risiko 1 (ungleiche Fall-Kosten) | Empfehlung: **weiter offen** — eigene Messung bestätigt eine reale, aktuell schon sichtbare Schieflage |
| §6-Risiken 2–4 | Empfehlung: **weiter offen** (Details unten) |

## DoD-Liefer-Punkt 1 — Matrix, Zuteilung, Konstante, `fail-fast`, `ci-lint`

**Bricht, wenn:** die Vereinigung der fünf Shards nicht exakt die 484 Fall-Dateien deckt (Lücke
oder Dopplung), die Zuteilung von `nproc`/Laufzeit abhinge, `fail-fast` fehlte, oder
`make ci-lint` die Matrix-Syntax nicht sauber fände.

**Eigene, unabhängige Nachrechnung** (nicht die Implementer- oder Reviewer-Zahlen übernommen):

```
ls test/mutations/*.sh | wc -l                     → 484
```

Ich habe die im Workflow verwendete Formel `(NR - 1) % n == i` selbst für `i=0..4, n=5` gegen die
sortierte Namensliste unter `test/mutations/*.sh` gefahren (eigenes Skript, nicht kopiert aus
Commit-Message oder Review-Report):

```
shard 0: 97 · shard 1: 97 · shard 2: 97 · shard 3: 97 · shard 4: 96   Σ = 484
Vereinigung sortiert == vollständige sortierte Namensliste (diff leer)
sort shard_*.txt | uniq -d   → 0 Zeilen (keine Dopplung über Shards hinweg)
```

Keine Lücke, keine Dopplung, keine Abweichung von der vollständigen Liste — bestätigt.

**Reproduzibilität/Determinismus:** Die Formel hängt an `sort` über Basenamen und der statischen
Liste `[0,1,2,3,4]`, kein `nproc`- oder Zeitbezug — geprüft am Code selbst (`.github/workflows/mutate.yml`),
keine Abhängigkeit auf Runner-Eigenschaften außer der (im INFO-Finding F-2 benannten,
unkritischen) Sortierreihenfolge.

**`fail-fast: false`** steht im YAML (`strategy.fail-fast: false`), mit Begründung analog
`release.yml` `start-smoke` — Wortlaut geprüft, Analogie trägt.

**Benannte Konstante:** Die Shard-Zahl (5) ist ausschließlich die Länge von `matrix.shard`, im
Kopf- und Step-Kommentar begründet (Zielkorridor ~20–25 min), kein zweiter Ort hält denselben
Wert, kein Bezug auf `nproc`/Laufzeit — geprüft, trägt.

**Fehlkonfigurations-Guard, selbst reproduziert (nicht nur Reviewer-Reproduktion übernommen):**
Ich habe die Formel mit einer um eins verschobenen Range `idx=1..5` (`job-total` weiterhin 5)
gefahren:

```
idx=1: 97 · idx=2: 97 · idx=3: 97 · idx=4: 96 · idx=5: 0
```

Shard-Index 5 bekommt **0 Fälle** — der Guard `[ -z "$cases" ]` im Workflow-Step hätte hier real
mit `exit 1` abgebrochen. Das ist die dritte unabhängige Reproduktion dieses Rot-Belegs
(Implementer-Commit-Message, Reviewer-Report, jetzt ich) — dieselbe Ursache, dieselbe Meldung.

**`select_cases()` gegen die real berechnete Shard-0-Teilmenge:** Ich habe die Funktion aus
`harness/tools/mutate.sh` isoliert extrahiert und mit dem real per Formel berechneten
Shard-0-String (97 Namen) aufgerufen: `exit=0`, Ausgabe **97** Zeilen — akzeptiert, unverändert,
eigenständig nachvollzogen (nicht die Reviewer-Aussage übernommen).

**`make ci-lint` — selbst gefahren:**

```
$ make ci-lint
docker run --rm -v "…":/repo:ro -w /repo rhysd/actionlint@sha256:b1934ee5…
EXIT: 0
```

Kein Befund gegen `.github/workflows/mutate.yml` — bestätigt.

**Offener Rest von Punkt 1:** Der letzte Teilsatz des DoD-Punkts („Real geprüft: ein
`workflow_dispatch`-Lauf zeigt N parallele Jobs …") ist noch **nicht** erfüllt — dazu unten
gesondert (Abschnitt „Ausstehender realer CI-Beleg").

**Verdikt: bestätigt für alles, was vor dem realen CI-Lauf prüfbar ist; der reale Lauf selbst
steht noch aus (siehe unten).**

## DoD-Liefer-Punkt 2 — Doku-Nachzug

**Bricht, wenn:** `harness/sensors/mutate.md` oder `harness/README.md` weiterhin den
Einzel-Job-Zustand behaupten, oder die neue Formulierung etwas behauptet, was der Code nicht hält.

Eigenständig gelesen (vollständige Datei, nicht nur den Diff):

- `harness/sensors/mutate.md` §Bindung sagt jetzt: „Nacht-**Workflow** … der den Fall-Satz als
  **Matrix aus parallelen Shard-Jobs** fährt (deterministische, index-basierte Zuteilung über
  `MUTATE_CASES`, `fail-fast: false`)" — das deckt sich exakt mit dem, was ich im YAML selbst
  gelesen und nachgerechnet habe. Kein Übertreiben, keine Untertreibung.
- Die `49m54s`-Zahl steht weiterhin da, jetzt korrekt als „stammt aus der Zeit vor der Matrix"
  eingeordnet und begründet weiterhin die Nacht-Platzierung (Post-integration-Stufe) — nicht als
  aktuelle Matrix-Laufzeit ausgegeben. Die reale Matrix-Wall-Clock-Zeit ist explizit als
  „eigener, noch ausstehender Beleg" benannt, nicht fabriziert (`AGENTS.md` §3.6-konform: keine
  Zusage über eine Zahl, die noch nicht gemessen wurde).
- `harness/README.md`: eigener `grep -n 'Nacht-Job\|Job ' harness/README.md` → **0 Treffer** in
  der §Werkzeuge-Zeile zu `make mutate` (Zeile 77) — sie trug nie einen Job-Zustand, nur den
  Vertrag, also war hier kein Nachzug nötig; die Einschätzung des Plans/Implementers ist zutreffend.
  Die historische `49m54s`-Erwähnung in §Safety and scope boundaries (Zeile 226) steht im
  Präteritum („der Preis war gemessen") und bleibt davon unberührt — sachlich korrekt, nicht durch
  die Matrix verfälscht.

**Verdikt: bestätigt.**

## Code-Stand seit `e46ba9e9` — Diff-Prüfung (Reihenfolge-Frage)

```
git diff e46ba9e9 HEAD -- .github/workflows/mutate.yml harness/sensors/mutate.md
→ leer (kein Output, Exit 0)
git log --oneline e46ba9e9..HEAD
→ nur c06c6a01 (Reviewer: Review-Report-Commit, docs/reviews/ — keine Code-/Doku-Berührung)
```

Der Code- und Doku-Stand der zwei geänderten Dateien ist seit der Implementierung **byte-identisch**
geblieben. Der vom Reviewer genannte fremde Commit `2bfc9355` liegt **vor** `e46ba9e9` in der
History (bestätigt: `git log --oneline` zeigt ihn als Vorgänger-Commit auf demselben Zweig, nicht
als nachträglich eingeschobenen); der Stempel-Unterschied entsteht, weil der
Arbeitsbaum-Hash den **gesamten** Baum deckt und seither weitere, thematisch fremde Commits
gelandet sind (inklusive des Review-Report-Commits `c06c6a01` selbst).

**Eigene Stempel-Kontrolle:**

```
.harness/state/gates-passed.diffsha   → d5ab5380…
bash harness/tools/working-tree-hash.sh → b843857f…   (wieder ein anderer Wert als der vom
                                                         Reviewer notierte b7931172…, weil seither
                                                         zusätzlich der Review-Report-Commit
                                                         gelandet ist)
```

**Verdikt: bestätigt — der veraltete Stempel ist ein reines Reihenfolge-Artefakt** (jeder weitere
Commit auf dem Baum bewegt den Gesamt-Hash, unabhängig vom Inhalt dieses Slice). Kein inhaltlicher
Mangel dieses Slice. Der Orchestrator fährt `make gates`/`record-gates` nach diesem Bericht frisch
— dazu kein weiterer Handlungsbedarf an diesem Slice.

## F-1 (LOW, Reviewer) — `strategy.job-total`-Kopplung: eigene Einordnung

Frage laut Auftrag: sicherheits-/korrektheitskritisch genug für einen Verifier-Nachtrag (Modul 11),
oder genügt „weiter offen"?

**Eigene Prüfung, in drei Teilen:**

1. **Betrifft F-1 den heutigen Code?** Nein — der Bug-Mechanismus, den F-1 beschreibt (`job-total`
   verdoppelt sich durch eine künftige zweite Matrix-Achse, `matrix.shard` bleibt bei 0–4, obere
   Hälfte der Fälle fällt still durch), setzt eine zweite Achse voraus, die **nicht existiert**.
   Die aktuelle Matrix hat genau eine Achse (`shard: [0,1,2,3,4]`), und für genau diesen Zustand
   habe ich oben die Vollständigkeit (484 = Vereinigung, keine Lücke, keine Dopplung) selbst
   nachgerechnet. Es gibt heute keine Korrektheitslücke.
2. **Ist die zugrundeliegende Schutzmechanik (`select_cases()`-Fail-Closed bei unbekanntem Namen,
   leerer Menge) neu und ungetestet?** Nein — ich habe verifiziert, dass `select_cases()`
   **unverändert** und **bereits permanent regressionsgetestet** ist
   (`test/mutate-driver.bats`, Zeilen 1159–1296: „MUTATE_CASES mit unbekanntem Namen …", „…gesetzt,
   aber leer …", „…mit doppeltem Namen …" — alle vorhanden, alle vor diesem Slice existent, vom
   Diff nicht berührt). Die einzige *neue* Guard-Logik dieses Slice ist der einzeilige
   `[ -z "$cases" ]`-Check im Workflow-Step — dessen einziger Fehlschlagsmodus (leere Zuteilung)
   habe ich oben dreifach reproduziert.
3. **Ist F-1 damit eine `§3.6`-Lücke (Zusage ohne rot gesehenes Gegenbeispiel)?** Nein — die
   Kommentare im Code behaupten nirgends Robustheit gegen eine künftige zweite Matrix-Achse; sie
   beschreiben akkurat den *heutigen* Zustand („`matrix.shard` … und `strategy.job-total` … sind
   beide strukturell aus der Matrix-Deklaration abgeleitet"). Es liegt keine Zusage vor, die
   breiter ist als ihr Sensor — F-1 beschreibt eine **künftige** Wartungsfalle, keine heute
   unbelegte Behauptung.

Zusätzlich: Der eingebaute Fail-Closed-Guard läuft bei **jedem** realen Workflow-Lauf automatisch
mit — das ist eine stärkere, permanente Absicherung als ein statischer bats-Test es für eine
YAML-Matrix-Expression leisten könnte (GH-Actions-Ausdrücke wie `${{ strategy.job-total }}` lassen
sich nicht ohne echten Workflow-Lauf oder aufwändige Nachbildung unit-testen; das Repo hat dafür
mit `test/release-matrix.bats` bereits ein Präzedenzmuster — dort wird die Kopplung im Makefile
geprüft, nicht eingebettetes YAML-Shell direkt ausgeführt). Der Rückführungs-Test aus Plan §4
("wird die Zuteilungs-Logik ein eigenständiges, selbst zu testendes Skript?") ist hier nicht
erreicht — die Logik ist eine Sortier-plus-Awk-Zeile plus ein Leer-Check, deutlich einfacher als
die bereits extrahierten Skripte (`start-smoke.sh`, `artifact-copy.sh`, `release-sums.sh`), die
mehrstufige Fehlerbehandlung/Cleanup-Semantik tragen.

**Einordnung:** F-1 ist eine legitime, korrekt klassifizierte **Maintainability-LOW**-Beobachtung
über eine künftige, heute nicht existierende Code-Änderung — kein sicherheits-/
korrektheitskritischer DoD-Punkt im Sinne von Modul 11. Ich trage **keinen** eigenen Test nach
(das wäre ohnehin erst nötig, wenn die zweite Matrix-Achse real hinzukäme — dann würde der
DoD-Vollständigkeits-Nachweis „Vereinigung deckt alle Fälle genau einmal" beim nächsten Slice die
Lücke sofort zeigen, wie der Reviewer selbst notiert). „Weiter offen" genügt bei der Closure.

**Empfehlung:** F-1 nicht als §6-Risiko dieses Slice-Plans nachtragen (kein Plan-Risiko dieser
Form war vorab benannt), sondern als **neue Beobachtung im Beobachtungs-Register** (Sub-Area
`ALL`, da `.github/workflows/` keine eigene Sub-Area führt) mit Zähler-Stand 1× eintragen, falls
der Planner den Finding-Typ „Matrix-Achsen-Kopplung ungeprüft gegen künftige Erweiterung" für
wiederholungswürdig hält. Zwingend ist das nicht (Modul 5: nur *wiederkehrende* Review-Finding-Klassen
speisen den Closure-Eintrag verpflichtend) — aber es ist billig und hält den Steering Loop
lückenlos, falls ein ähnlicher Fund an anderer Stelle je auftritt.

## Ausstehender realer CI-Beleg — Einordnung

Plan §2 (DoD-Liefer-Punkt 1, letzter Satz) und Plan §5 (Closure-Trigger) verlangen explizit einen
**realen** `workflow_dispatch`- oder `schedule`-Lauf mit N grünen parallelen Jobs, deren
Job-Log-Vereinigung alle 484 Fälle genau einmal abdeckt, **bevor** die Closure-Notiz geschrieben
wird — Plan §5 wörtlich: „DoD vollständig **und** ein realer, beobachteter Matrix-Lauf … **und**
Closure-Notiz mit Lerneintrag geschrieben." Das ist keine informelle Erwartung, sondern der vom
Slice-Plan selbst gesetzte Closure-Trigger.

**Bestätigt:** Dieser Lauf ist im Plan selbst ausdrücklich als Post-Implementierungs-Schritt
vorgesehen ("Ein realer `workflow_dispatch`- oder `schedule`-Lauf … steht noch aus", Commit-Message
`e46ba9e9`), und der Reviewer hat ihn korrekt als „kein Review-Blocker" eingeordnet. Ich bestätige
dieselbe Einordnung für die Verifikation: **kein Verifier-Blocker** — ich kann und soll diesen
Beleg nicht selbst herstellen (er braucht einen echten Push/Trigger, den der Orchestrator fährt).

**Aber:** Es ist damit auch **kein abschließbarer Zustand**. Solange dieser Lauf nicht erfolgt
ist, ist DoD-Liefer-Punkt 1 nicht vollständig erfüllt (der Teilsatz „real geprüft" steht noch aus),
und nach Plan §5 darf die Closure-Notiz erst **danach** geschrieben werden. Der Slice bleibt bis
dahin korrekt in `in-progress/` — kein `git mv` nach `done/`, bevor dieser Lauf beobachtet und die
`harness/sensors/mutate.md`-Wall-Clock-Zahl real nachgezogen ist.

## Plan-vs-Code-Diff

Scope-Treue geprüft: `git show e46ba9e9 --stat` zeigt exakt die zwei in Plan §3 genannten Dateien
(`.github/workflows/mutate.yml`, `harness/sensors/mutate.md`) — keine dritte Datei, kein
Gebautes-aber-nicht-Geplantes.

Die im Plan §3 skizzierte Beispielformel (`awk -v n=$SHARD_COUNT -v i=${{ matrix.shard }}
'NR % n == i % n'`) und die tatsächlich implementierte (`(NR - 1) % n == i`) unterscheiden sich in
der Index-Konvention (1-basiert vs. 0-basiert), sind aber funktional äquivalent — der Plan hat
diese Freiheit dem Implementer ausdrücklich überlassen ("der Implementer wählt die konkrete
Realisierung, die Zusicherung ist: jeder Fall genau einer Gruppe, keine Gruppe leer"). Keine
Abweichung von einer bindenden Plan-Zusage.

Keine Änderung an `harness/tools/mutate.sh` (bestätigt über den Diff-Umfang oben) — die im Plan §1
zugesagte Abgrenzung „ändert nicht die Prüf-Semantik von `harness/tools/mutate.sh`" hält.

## §6-Risiken — Ausgangs-Empfehlung

**Risiko 1** (ungleiche Fall-Kosten pro `# verify:`-Klasse): Ich habe die Verteilung der teuersten
Klasse (`full-smoke`, laut `harness/tools/mutate.sh` mit doppeltem Voll-Bootstrap-Kosten die
teuerste) selbst über die fünf real berechneten Shards ausgezählt:

```
shard 0: 6 full-smoke · shard 1: 4 · shard 2: 5 · shard 3: 2 · shard 4: 2
```

Das ist eine **reale, schon heute messbare Schieflage** (Shard 0 trägt dreimal so viele
`full-smoke`-Fälle wie Shard 3/4) — das im Plan benannte Risiko ist kein bloß hypothetisches,
sondern durch die Fall-Verteilung selbst schon angelegt. Empfehlung: **weiter offen**, bis der
reale Matrix-Lauf Wall-Clock-Zahlen pro Shard liefert; zeigt sich dort eine relevante Schieflage
(> grober Zielkorridor-Toleranz), ist das ein Kandidat für einen Folge-Slice mit
kostengewichteter statt reiner Index-Modulo-Zuteilung.

**Risiko 2** (Startwert 5 trifft Zielkorridor evtl. nicht): Empfehlung: **weiter offen**, direkt
abhängig vom noch ausstehenden realen Lauf — nicht vorab entscheidbar.

**Risiko 3** (Actions-Minuten bei künftigem privatem Repo): Empfehlung: **weiter offen** wie im
Plan vorgesehen — nicht heute relevant (Repo ist `PUBLIC`), keine Blockade, nichts an diesem Slice
zu prüfen.

**Risiko 4** (Zuteilungs-Berechnung liest Fall-Liste zum Checkout-Zeitpunkt jedes Jobs): Der Plan
selbst benennt bereits, dass dies **kein** Risiko für die Vollständigkeits-Zusicherung *innerhalb*
eines Laufs ist (derselbe Checkout für alle Shards), nur für die Interpretation historischer
Laufzeiten über mehrere Läufe hinweg. Empfehlung: **entfallen** wäre vertretbar (kein aktiver
Risiko-Gegenstand, sondern eine Verhaltensbeschreibung), aber da der Plan es selbst als
"erwähnenswert" führt statt es auszuschließen, überlasse ich dem Planner die Wahl zwischen
**entfallen** (mit Begründung "gewolltes, beschriebenes Verhalten, kein Fehlerpotenzial") und
**weiter offen** (falls die Interpretations-Warnung dauerhaft an einer Stelle stehen soll).

## Was nur gelesen, nicht gemessen ist

- Der volle `make mutate`-Docker-Lauf (auch nicht in Teilen) — nicht gefahren; ersetzt durch die
  bash-native Extraktion/Reproduktion von `select_cases()` und der Zuteilungsformel, was denselben
  Mechanismus auf Shell-Ebene prüft (kein Docker-/Isolationsaspekt betroffen).
- Der reale `workflow_dispatch`-Lauf selbst — nicht ausgelöst (Auftrag: kein `make gates`,
  Orchestrator übernimmt Push/Trigger danach).
- `harness/tools/mutate.sh` als Ganzes — nur der unveränderte `select_cases()`-Teil isoliert
  geprüft; der Rest der Datei nur gelesen (Diff bestätigt: keine Änderung).

## Übergabe an den Planner

**DoD erfüllt: mit Einschränkung.** Alle Code- und Doku-seitigen DoD-Teilaussagen sind von mir
unabhängig nachgerechnet und bestätigt (Shard-Vollständigkeit, Determinismus, `fail-fast`,
benannte Konstante, `select_cases()`-Kompatibilität, Fehlkonfigurations-Guard dreifach
reproduziert, `make ci-lint` selbst gefahren, Doku-Nachzug akkurat). Der Gates-Stempel ist
lediglich ein Reihenfolge-Artefakt (Code seit `e46ba9e9` unverändert, `git diff` leer) und kein
Mangel dieses Slice.

**Die Einschränkung:** Der Slice-Plan setzt selbst (§2, §5) einen realen `workflow_dispatch`- oder
`schedule`-Lauf mit N grünen parallelen Jobs als Closure-Vorbedingung. Dieser Lauf ist noch nicht
erfolgt — er ist explizit kein Verifier- oder Review-Blocker, aber er ist eine **Closure-Blockade
nach der eigenen Definition des Plans**. Der Slice bleibt bis dahin korrekt in `in-progress/`.

**Empfehlung an den Planner:**

1. Slice **nicht** nach `done/` verschieben, bis (a) der reale Matrix-Lauf beobachtet wurde
   (N grüne Jobs, Job-Log-Vereinigung deckt alle 484 Fälle genau einmal) und (b) die
   Wall-Clock-Zeit in `harness/sensors/mutate.md` real nachgezogen ist (statt „ausstehender
   Beleg").
2. §6-Risiken: Risiko 1 und 2 bleiben **weiter offen** bis zu diesem realen Lauf (Risiko 1 mit dem
   Zusatzbefund, dass die Schieflage bereits an der Fall-Verteilung ablesbar ist — siehe oben);
   Risiko 3 bleibt **weiter offen** wie geplant; Risiko 4 liegt an der Planner-Wahl zwischen
   **entfallen** und **weiter offen**.
3. F-1 (Reviewer, LOW) ist kein Korrektheits-, sondern ein Wartungsfalle-Finding über eine heute
   nicht existierende künftige Matrix-Erweiterung — kein Verifier-Nachtrag nötig, „weiter offen"
   bzw. optionaler Register-Eintrag (Sub-Area `ALL`, 1×) genügt.
4. F-2 (Reviewer, INFO, Cross-Runner-Sortierkonsistenz) — keine Aktion nötig; der DoD-eigene
   Vollständigkeits-Nachweis (Vereinigung = alle 484 Fälle genau einmal, aus den realen Job-Logs)
   deckt einen etwaigen Drift sofort ab, sollte er je auftreten.
5. Nach dem realen Lauf: Closure-Notiz mit Lerneintrag schreiben, Beobachtungs-Register
   fortschreiben (mindestens „keine Beobachtung angefallen" oder die F-1-Beobachtung, falls der
   Planner sie aufnimmt), die drei Paarungen prüfen — erst dann `git mv` nach `done/`.
