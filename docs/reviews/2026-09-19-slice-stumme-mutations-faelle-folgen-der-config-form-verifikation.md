# Verifikations-Report: slice-stumme-mutations-faelle-folgen-der-config-form — 2026-09-19 (Verifier)

**Verifikations-Art:** Modul 11 — DoD-Konformität gegen den Slice-Plan
`slice-stumme-mutations-faelle-folgen-der-config-form` plus Plan-vs-Code-Diff,
frischer Kontext; **nicht** gegen den Review geprüft.

**Gegenstand:** `cc22df18` — genau ein Implementer-Commit, 4 Dateien (+25/−19):
`internal/gen/archgate_test.go` (Zahn-Kommentar), `test/mutations/68-archconfig-kopplung.sh`,
`71-archgate-kante-auf-vorrat.sh`, `96-cpp-archgate-adapterport-kante.sh`.

**Eingangs-Kontext:**

- Slice-Plan `slice-stumme-mutations-faelle-folgen-der-config-form` (Kennung — die
  Plandatei wandert zur Closure; Adresse bewusst nicht verlinkt)
- `ADR-0060` (Accepted) — die `direction:`-getragene Config-Form, auf die die
  drei sed-Muster gezogen sind
- Review-Report Runde 1
  (`docs/reviews/2026-09-19-slice-stumme-mutations-faelle-folgen-der-config-form-runde-1.md`)
  — nicht wiederholt; F-1/F-2 als Übergaben gelesen
- `make gates` grün am Kopf `c4d3154b` — **nicht wiederholt**, am Stempel gelesen

**Sensor-Basis dieses Laufs (selbst gefahren):**

- `make mutate` über alle 365 Fälle, real (365 Fälle, 6 Worker, ~50 min) →
  Bilanz **362 ok, 3 Befund(e)**, `MUTATE-EXIT=2` (Log `mutate: 362 ok, 3 Befund(e)`;
  die Exit-2-Ursache sind exakt die drei F-1-Fälle, s. u.)
- die drei umgeschnittenen Zähne je real im Wegwerf-Klon
  (`git archive HEAD | tar -x` nach `/tmp`, Mutation ansetzen → `make test-go` →
  Meldung lesen → Datei aus `HEAD` zurückgenommen, je `cmp`-geprüft)
- Zensus über alle 365 Fälle in der Wegwerf-Kopien-Form (je Fall: `# files:`-
  Auflösung, Fall-Skript in der Spiegel-Kopie angewendet, `cmp` vor/nach,
  Pristin-Rest) → **GRIP=362 · SILENT=3 · UNRESOLVED=0**
- statische Muster-Kontrolle je Fall (`grep -c`, Neuform/Altform) und an den
  F-1-Fundstellen (`grep -cF`)

---

## DoD — Punkt für Punkt

Regeln: `v6.9.0` · `regelwerk/modul-11-verification.md` §Begriffe (Behauptung
ohne Bestätigung ist die häufigste Verifier-Lücke); Zahlen mit Kommando
(`MR-025`, Setzung 2: keine Erwartungswerte).

| DoD-Punkt (Plan §2) | Status | Beleg |
|---|---|---|
| **Liefer-Punkt 1 — die drei Fälle fahren wieder rot** | **erfüllt** | Statisch: je Fall Neuform genau 1 Treffer, Altform 0 — `grep -c 'greet/ports/inbound/\*\*' internal/gen/golang.go` → **1**, `grep -c 'greet/ports/\*\*' …` → **0** (Fall 68); `grep -c '  - {from: driven_adapters,  to: domain}' internal/gen/golang.go` → **1**, `grep -c 'from: ports,    to: domain' …` → **0** (Fall 71); `grep -c '{from: driven_adapters,  to: ports_outbound}' internal/gen/cpp.go` → **1**, `grep -c '{from: adapters, to: ports}' …` → **0** (Fall 96). Dynamisch im Wegwerf-Klon: je Fall `MUT-RC=0`, `TEST-GO-RC=2`, zurückgenommen ja; Meldung trägt die mutierte Form als Ursache — Fall 68 `Glob "…greet/nirgends/inbound/**" ist fuer KEINE generierte Datei der spezifischste (Gate ueber leerem Bereich, LH-QA-01)`, Fall 71 `Kante driven_adapters->ports_outbound ist deklariert, wird aber von keinem Import des Skeletts gebraucht (Erlaubnis auf Vorrat)`, Fall 96 `cpp-Config ohne driven_adapters->ports_outbound-Kante: der erbende getriebene Adapter faerbt a-check rot`. Realer Treiber: `make mutate` → `mutate: ok 68-archconfig-kopplung → TestArchGateConfig_MatchesSkeleton rot`, `mutate: ok 71-archgate-kante-auf-vorrat → TestArchGateConfig_EdgesMatchSkeleton rot`, `mutate: ok 96-cpp-archgate-adapterport-kante → TestArchGateConfig_CppAllowsAdapterToPorts rot` — je Fall exakt der benannte expect-Wächter. Rote Gegenprobe (Polarität): die Alt-Formen liegen mit 0 Treffern am re-geschnittenen Baum — die Vorgänger-Muster hätten ihre Fälle stumm gemacht (V-1, statisch gemessen); der Umschnitt dreht die Meldung um. |
| **Liefer-Punkt 2 — der Zahn-Kommentar trägt den Beleg, den es gibt** | **erfüllt, mit stehendem Rest** | `git show cc22df18 -- internal/gen/archgate_test.go`: die Falsch-Listung `Rot-Gegenbeispiel: test/mutations setzt den Pin auf die Vorgaenger-Fassung.` ist entfernt — kein Fall von 365 setzt den Pin (V-4). Der Kommentar trägt die Zustandsform (Kopplung/Zusage des Pins an die Fassung, Grenze: `Einen Mutations-Fall dafuer traegt der kuratierte Satz nicht`) und keinen Lauf-Protokoll-Satz. **Rest:** der Runde-1 F-2-Rest steht unverändert an `internal/gen/archgate_test.go:233-234` — `der Gegenbeispiel-Nachweis liegt als Hand-Messung vor.` behauptet Beleg-Existenz ohne auflösbaren Ort (§3.7, LOW, nicht gate-gebunden, nicht merge-blockierend). Der Beleg selbst ist belegt: Vorgänger-Verifikations-Report V-4 — Runde 2, Rot-Probe (c), „der einmalige Nachweis ist erbracht"; kein Nachbeleg dieses Laufs. |
| `make gates` grün | **erfüllt** | nicht wiederholt — Stempel deckt den Kopf: `cat .harness/state/gates-passed.diffsha` = `bash harness/tools/working-tree-hash.sh` → beide `3b764d40444bd591b1cf254a1110f5d1623933f714e45cf5b3b8282e69df7138` über `c4d3154b` (inhaltsbasiert, commit-übergreifend — `.claude/hooks/stop-require-gates.sh` Kopfbegründung). |
| Review durchgeführt, Report unter `docs/reviews/` | **erfüllt** | `docs/reviews/2026-09-19-slice-stumme-mutations-faelle-folgen-der-config-form-runde-1.md` liegt vor (Runde 1, Verdikt: nicht merge-blockierend; F-1/F-2 als Übergaben deklariert). Kein Self-Review — der Report trägt eine andere Rolle und einen anderen Kontext als dieser Lauf. |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **ausstehend — Planner-Closure** | Plan §7 trägt noch die Vorlagen-Platzhalter; der Übergang nach `done/` ist Planner-Arbeit nach diesem Bericht (`AGENTS.md` §3.10) — der Abschluss läuft nicht in diesem Kontext. |
| Reconciliation-Register entfällt | **erfüllt** | per Plan — dieses Repo führt keine Register-Datei (kein Brownfield-Bootstrap). |
| Beobachtungs-Register fortgeschritten — oder „keine Beobachtung" in §7 | **ausstehend — Planner-Closure** | gehört zur Closure-Notiz (§3.10); der Plan hat den Sichtungs-Schritt bei der Anlage geführt (§8: keine Treffer für die Mutations-Zahnpflege-Klasse, notiert). |
| Jedes Risiko aus §6 trägt einen Ausgang; drei Paarungen | **ausstehend — Planner-Closure; Beleg geliefert** | §6-Risiko 1 (die statische Messung deckt die Muster, nicht den Lauf): der **reale `make mutate`-Lauf dieses Verifikations-Laufs** ist der Bestätigungs-Beleg — die drei Fälle melden **OK**, keinen BEFUND. Welcher der drei Ausgänge (eingetreten · entfallen · weiter offen) es ist, weist die Closure zu — nicht dieser Lauf. |

**§5 Closure-Trigger** — „`make mutate` meldet keinen BEFUND auf den drei Fällen":
**erfüllt** für die drei umgeschnittenen Fälle (alle drei OK). **Nicht erfüllt für
den Lauf als Ganzes:** `MUTATE-EXIT=2` — die drei BEFUNDs sind `29-roadmap-nicht-neutralisiert`,
`114-span-lock-verzeichnis`, `275-planning-readme-carveouts-done-ref-nicht-neutralisiert`
(Bedingung 2: `Mutation hat nicht gegriffen bei: internal/emit/templates.go — Patch veraltet?` /
`… bei: internal/span/emit.go — Patch veraltet?`) — exakt die F-1-Klasse des Reviews,
vom Umschnitt nach Plan-Abgrenzung nicht getragen, als Übergabe deklariert.

## Completeness-Check — der Zensus

- `ls test/mutations/*.sh | wc -l` → **365**
- Wegwerf-Kopien-Form (je Fall Mutation ansetzen, `cmp` vor/nach, Pristin-Rest):
  **GRIP=362 · SILENT=3 · UNRESOLVED=0** — die drei stummen Fälle sind
  **29 · 114 · 275**, exakt die F-1-Fundstellen; kein Defekt (kein unauflösbarer
  `# files:`-Kopf, kein Fall-Skript mit rc ≠ 0)
- **Kein vierter stummer Fall aus der Config-Klasse:** alle 22 Fälle auf die
  zwei emittierten Config-Quellen greifen — 22 von 22 Fälle mit
  `# files:` → `internal/gen/{golang,cpp}.go` tragen `g=1` (Liste im
  Zensus-Ausdruck: 61, 68, 71, 91, 92, 96, 99–106, 15, 16, 18, 20, 45, 55, 57,
  58, 152, 189). Die 362/3/0-Erwartung ist in beiden Zählungen getroffen
  (statisch-census und realer Lauf).
- Realer Lauf deckt den Zensus: `mutate: 362 ok, 3 Befund(e)`.

## Die F-1-Fundstellen — nicht still gefixt

Geprüft in beide Richtungen — der Defekt ist Bestand, der Commit berührt die
Stellen nicht, und die Übergabe benennt sie:

- Fall 29: die Quelle trägt die neue Form — `internal/emit/templates.go:414`
  liest `return NeutralizeRoadmap(body), nil`; das Fall-Muster
  `body = NeutralizeRoadmap(body)` → `grep -cF` → **0**
- Fall 275: `internal/emit/templates.go:428` liest
  `return NeutralizePlanningReadmeCarveoutsDoneRef(body), nil`; Fall-Muster → **0**
- Fall 114: kein `Rmdir` mehr in `internal/span/emit.go` (`grep -c Rmdir` → **0**,
  die Span-Sperre trägt je-OS-Dateien); Fall-Muster → **0**
- Der reale Lauf meldet alle drei mit Bedingung 2 („Patch veraltet?") — die
  Übergabe im Review-Report (F-1, mit den drei Fall-Pfaden und den Quell-Stellen)
  benennt sie; nichts davon ist still gefixt oder still gelassen.

## Plan-vs-Code-Diff

- **Plan §3 → Code:** die zwei Plan-Zeilen decken den Commit exakt —
  `test/mutations/` (Fälle 68, 71, 96) als `update` und
  `internal/gen/archgate_test.go` als `update`; `git show --stat cc22df18` →
  genau diese vier Dateien, +25/−19, nichts darüber hinaus. Der Commit ist der
  einzige Implementer-Commit des Slice (`0b6f53df..cc22df18`); der Arbeitsbaum
  ist davor und danach clean — nichts Geplantes fehlt.
- **Code → Plan (Gebautes-aber-nicht-Geplante):** nichts. Die Fall-Kommentare der
  drei umgeschnittenen Fälle sind Teil der `update`-Zeile (die Plan-Zeile nennt
  je Fall den Wächter, den er bewacht); sie tragen Kopplung/Konsequenz/Grenze in
  Zustandsform, keine Befund-Kennung, keine Slice-Nummer, keine Chronik
  (`grep -nE 'slice-[0-9]+|Review-Befund|BEO-'` über die drei Dateien → null).
- **Fremd-Kennungen:** `git show cc22df18 | grep -nE 'hexslice-architecture|/Development/|ai-harness-course|/home/'` → **null**.
- **Spec-Stellen:** der Plan führt `Berührte Spec-Stellen: —`; der Umschnitt
  ändert Test-Muster, keinen Emissions-Output — die `ARC-009`-Zelle ist von
  diesem Commit nicht berührt. Keine Spec-Lücke.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Zensus über alle 365 Fälle (Wegwerf-Kopien-Form) | geprüft — 362 greifen, 3 stumm (29/114/275), 0 unauflösbar/defekt; kein vierter stummer Fall, insbesondere keiner aus der Config-Klasse |
| Die drei umgeschnittenen Zähne — real gefahren | geprüft, ohne Befund — je Fall Mutation greift, `make test-go` fällt (exit 2), der benannte expect-Wächter steht in der Fehlschlag-Ausgabe **mit der mutierten Form als Ursache**, Datei aus `HEAD` zurückgenommen (`cmp`-ja); Polarität akkurat: Fall 96 exakt einzeln, Fälle 68/71 färben zusätzlich je einen zweiten, aus derselben Mutation folgenden Wächter desselben emittierten Config-Satzes |
| Realer `make mutate`-Lauf über 365 | geprüft — Bilanz 362 ok / 3 Befund; die drei umgeschnittenen Fälle OK am benannten Wächter, die drei BEFUNDs exakt die F-1-Fälle |
| Zahn-Kommentar — V-4-Kern | geprüft, ohne Befund — die Falsch-Listung ist entfernt; der Rest ist der stehende F-2 (oben) |
| Fall-Kommentare der drei Fälle (§3.7-Form) | geprüft, ohne Befund — Zustandsform, Klassen Kopplung/Konsequenz/Grenze, keine Befund-/Slice-Kennung, keine verworfene Alternative |
| Commit-Umfang und Rollen-Zuschnitt | geprüft, ohne Befund — genau vier Dateien in genau einem Implementer-Commit; Review-Report in eigenem Commit (`c4d3154b`) |
| Fremd-Kennungen | geprüft, ohne Befund — der Commit führt keine Referenz-Kennung des Nachbar-Repos ein |
| Arbeitsbaum-Integrität der Messung | geprüft, ohne Befund — Zensus und Zähne liefen in Wegwerf-Kopien außerhalb des Baums; `git status --porcelain` leer vor und nach allen Läufen |
| Gate-Stempel-Deckung | geprüft, ohne Befund — inhaltsbasierter Hash des Baums gleich dem Nachweis über `c4d3154b` |

## Befunde

Kein neuer Befund aus diesem Lauf. Die zwei Übergaben des Reviews stehen unverändert:

| ID | Kategorie | Stand | Übergabe |
|---|---|---|---|
| F-1 | MEDIUM | unverändert — die drei stummen Fälle 29/114/275 an `internal/emit/templates.go` und `internal/span/emit.go` sind Bestand; die Stellen tragen die neuen Formen, die Fall-Muster die alten; der reale Lauf meldet sie mit Bedingung 2 | eigener Umschnitt desselben Typs — als Folge-Slice oder als Erweiterung dieses Slices vor seiner Closure; Entscheidung beim Planner (`AGENTS.md` §3.10) |
| F-2 | LOW | unverändert — `internal/gen/archgate_test.go:233-234` trägt die Beleg-Existenz ohne auflösbaren Ort (`der Gegenbeispiel-Nachweis liegt als Hand-Messung vor.`) | Kommentar-Form am bestehenden Zahn, keinem Sensor unterworfen; Nachzug oder Rücknahme des Satzes beim nächsten Griff an die Stelle — Cutoff-Form (`AGENTS.md` §3.7: Bestand ist kein Arbeitsauftrag) |

## Spec-Lücken

Keine. Der Plan berührt keine Spec-Stelle; der Umschnitt ist Zahnpflege am
kuratierten Mutations-Satz (`AGENTS.md` §3.6) und ändert keinen
Emissions-Output. Die Zähne hängen an den Fitness-Zeilen von `ADR-0060`
(Kanten-Set, Richtung, Pin-Kopplung) — alle drei laufen im `make test`-Träger,
der in `make gates` steht.

## Übergabe an den Planner (`AGENTS.md` §3.10)

1. **F-1** (MEDIUM, drei weitere stumme Fälle 29/114/275) — eigener Umschnitt
   desselben Typs; der reale Lauf dieses Berichts ist der Beleg für die
   BEFUND-Klasse, nicht deren Behebung.
2. **F-2** (LOW, Kommentar-Form `:233-234`) — steht; Nachzug beim nächsten Griff
   an die Stelle oder still stehen lassen (Bestand ist kein Arbeitsauftrag).
3. **Risiko §6** — Ausgangs-Beleg liegt vor (realer Lauf, drei OK); Zuweisung
   des Ausgangs gehört in die Closure.
4. **Closure-Pflichten** — Closure-Notiz mit Lerneintrag (Finding-Klassen:
   stumme Mutations-Faelle nach Quell-Re-Schnitt · unauflösbarer Beleg-Anker im
   Zahn-Kommentar), Beobachtungs-Register-Fortschreibung, Risiko-Ausgänge, drei
   Paarungen, `git mv` nach `done/` — Planner-Kontext, nach diesem Bericht.

## Verdikt

**DoD-Konformität: erfüllt** für beide Liefer-Punkte und die laufbezogenen
DoD-Punkte (gates, Review-Report) — statisch, dynamisch im Wegwerf-Klon und am
realen 365-Fall-Lauf belegt. Die Closure-Pflichten sind ausstehend und laufen —
ihrem Charakter nach — nicht in diesem Kontext. Der reale `make mutate`-Lauf
trägt Exit 2 **nicht** aus den drei umgeschnittenen Fällen, sondern aus der
F-1-Übergabe; der §5-Trigger („keinen BEFUND auf den drei Fällen") ist erfüllt.
Dieser Report ist ein **Lauf-Beleg** — DoD-/Spec-Konformität ist hier geprüft
(Modul 11), nicht im Review nachgelesen.