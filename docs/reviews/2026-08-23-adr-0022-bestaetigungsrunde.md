# ADR-0022 (Proposed) — Bestätigungsrunde nach dem Nachzug

- **Rolle:** Reviewer (Modul 10), frischer Kontext
- **Datum:** 2026-08-23
- **Gegenstand:** [`docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
  Status weiter *Proposed*, samt der ADR-0022-Zeile in [`docs/plan/adr/README.md`](../plan/adr/README.md)
- **Diff:** `caaa6a5..19dfe36` — selbst gemessen: `git diff --stat caaa6a5..19dfe36` →
  **2** Dateien, **172** Insertionen, **68** Deletionen (`git diff --numstat caaa6a5..19dfe36` →
  `171 67` ADR, `1 1` Index). `git status --porcelain` → leer; `git rev-parse HEAD` → `19dfe36…`.
- **Vorrunde:** [`2026-08-23-adr-0022-proposed-review.md`](2026-08-23-adr-0022-proposed-review.md)
  — 1 HIGH · 2 MEDIUM · 5 LOW · 4 INFO, Verdikt *blockiert*
- **Was diese Runde nicht ist:** keine DoD-Abhakung (Verifikation, getrennter Kontext) und keine
  Übernahme der Commit-Message. Die zwei Gate-Aussagen des Commits sind selbst nachgefahren.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10)

1. **Diff/Commit-Range:** `caaa6a5..19dfe36`, ein Commit, zwei Dateien (oben gemessen).
2. **Betroffene Anforderungen:** [`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
   (Rang 1), `LH-FA-01`, `LH-FA-06`, `LH-FA-08`, `LH-FA-09`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`,
   `LH-QA-04`.
3. **Referenzierte aktive ADRs:** `ADR-0003`, `ADR-0007`, `ADR-0011`, `ADR-0012`, `ADR-0013`,
   `ADR-0016`, `ADR-0020`, `ADR-0021` — alle *Accepted*, alle gelesen.
4. **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.4 (Immutabilität ab *Accepted*), §3.6 (kein
   Zusage ohne rot gesehenes Gegenbeispiel), §3.7, §3.8 (Architect-Commit).
5. **Vorherige Findings am gleichen Modul:** die zwölf der Vorrunde, einzeln an ihrem Gegenstand
   nachgeprüft (nicht an der Ankündigung).
6. **Plan:** kein Slice — der Gegenstand ist eine Entscheidung. Der Plan-Bezug läuft über
   Folgepflicht 5 der ADR, die den Wellen-Plan als nachzuziehen benennt.

---

## Findings

### MEDIUM-1 — Der neu gefasste tragende Grund unterscheidet den gewählten Weg nicht von Alternative F, und derselbe Absatz schickt den Trigger dorthin, wo F ebenso fällt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4 (ab *Accepted* unerreichbar); das Gegenbeispiel
  von MEDIUM-1 der Vorrunde, das ausdrücklich diesen Rest benannt hat
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:306-310`
  gegen `:284-287` (erste der vier Konstruktions-Eigenschaften), `:539` (Alternative F, Contra) und
  `:668-672` (Trigger zu Annahme (a)); dieselbe Aussage in der ADR-0022-Zeile von
  `docs/plan/adr/README.md`
- **befund:** Der neue Absatz sagt drei Dinge in Folge: (i) *„Der tragende Grund von Festlegung 1
  ist damit **keine Einzigkeit** — Alternative F teilt die vier Eigenschaften — … sondern die
  **Ersparnis**, die keiner anderen Herkunfts-Klasse offensteht: über den Bootstrap-Host verfügt
  das Werkzeug im Moment der Emission ohne Herleitung, ohne Rateschritt und ohne zweiten Kanal"*;
  (ii) diese Ersparnis **ist** wortgleich die erste der vier Eigenschaften (`:286-287`: *„Jeder
  andere Weg muss die Plattform des Ziels erst herleiten, raten oder über einen zweiten Kanal
  treffen; hier liegt sie vor"*), und F teilt sie nach `:539` (*„dieselben vier
  Konstruktions-Eigenschaften wie G"*); (iii) *„Wo diese Ersparnis nicht reicht, trägt
  Alternative F — und genau dorthin führt der Trigger zu Annahme (a)."*
  Aus (i)+(ii) folgt, dass der genannte tragende Grund **G nicht von F trennt** — er wählt die
  Herkunfts-Klasse, nicht das Mitglied. Aus (ii)+(iii) folgt ein Widerspruch im selben Absatz:
  fällt die Ersparnis, weil Bootstrap-Host und Hook-Plattform auseinanderfallen, fällt sie für F
  **ebenso**, denn F bettet ein zur Produkt-Bauzeit derselben Plattform gebautes Binär ein
  (`:539`: *„der Produkt-Bau hängt am Emitter-Bau derselben Plattform"*). Der Trigger selbst sagt
  auch etwas anderes als (iii): `:672` nennt *„die Wege D, E und F werden verfügbar"*, nicht F
  allein. Der **einzige** Unterschied, den die ADR zwischen G und F noch nennt, steht in der
  Alternativen-Tabelle als *„Gleiche Eigenschaften, höherer Preis"* — und die Index-Zeile verneint
  genau das als tragenden Grund: *„Der tragende Grund ist **kein Aufwandsvergleich**, sondern eine
  Ersparnis, die keiner anderen Herkunfts-Klasse offensteht"*.
- **gegenbeispiel:** Der Trigger zu Annahme (a) feuert; jemand nimmt `:309-310` beim Wort und
  wechselt auf F. F trägt dort nicht — sein eingebettetes Binär hat dieselbe Plattform-Bindung —,
  und der Wechsel löst nichts. Umgekehrt sucht, wer die Wahl G-gegen-F nachvollziehen will, in
  einem nach §3.4 eingefrorenen Text den tragenden Grund und findet einen, den beide teilen; der
  Preis, der die Wahl real trägt, ist im Index ausdrücklich als **nicht** tragend erklärt.
- **verifizierbar:** ja am Quellenabgleich — `sed -n '284,287p;306,310p;539p;668,672p'` über die
  ADR, alle vier Stellen gelesen; kein Gate (`modules: [links, anchors, ids, matrix, codepaths, spans]`,
  `grep -n '^modules:' .d-check.yml`, liest keine ADR-Semantik).

### MEDIUM-2 — Der Zahn, der die Einlösung von ADR-0021 Folgepflicht 6 an ihrem ersten Nenn-Ort trägt, hängt an einem Sensor, den `make mutate` nicht adressieren kann — und die ADR sagt es nicht

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„`make mutate` … meldet jeden **gelisteten**
  Wächter, der seine Zähne verloren hat — gelistet heißt: wer keinen Fall in `test/mutations/`
  hat, ist unbewacht"*), von der Zeile selbst als Maßstab angerufen
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:638`
  (Fitness-Zeile 6) gegen `harness/tools/mutate.sh:227-236` (`failure_form`) und den Ist-Bestand
  der Mutations-Köpfe
- **befund:** Zeile 6 der Fitness Function trägt die erste Hälfte der Einlösung — *„Die Auswertung
  meldet ihre Leere — und nennt die Grenze, nicht nur den Zustand"* — und macht ihr Rot selbst
  bindend: *„**Rot zu sehen ist:** den Grund-Satz aus der Ausgabe nehmen, dann muss der Wächter
  fallen; ohne dieses Rot ist die Einlösung von ADR-0021 Folgepflicht 6 eine Absicht
  ([`AGENTS.md`](../../AGENTS.md) §3.6)."* Ihr Make-Target ist ausschließlich `make full-smoke`.
  Der Mutations-Treiber dieses Repos kennt für `full-smoke` **kein** Fehlschlag-Muster: `failure_form`
  führt `test`, `test-go`, `test-bats`, `smoke`, `ci-lint` und sonst `return 1`, worauf `run_case`
  mit *„unbekanntes '# verify: …' — kein Fehlschlag-Muster definiert"* abbricht
  (`sed -n '227,236p;268,271p' harness/tools/mutate.sh`, gelesen). Im Bestand nutzt kein Fall
  `full-smoke`: `sed -n 's/^# verify: //p' test/mutations/*.sh | sort | uniq -c` → **1** `ci-lint`,
  **1** `smoke` (selbst gefahren). Für `make smoke` wurde genau diese Lücke einmal ausdrücklich
  geschlossen (`harness/tools/mutate.sh:257-258`: *„Wächter in `make smoke` waeren sonst
  bauartbedingt unbewacht"*); für `full-smoke` nicht. Die ADR nennt vergleichbare Lücken sonst mit
  Kommando (`:637`: *„ein Sensor darüber existiert nicht (`grep -rln 'Feldliste' internal/emit/*.go`
  → leer, Exit 1)"*) — hier nicht. Die Schwester-Zeile desselben Nenn-Ort-Paars (`:639`,
  Feldlisten-Dokument) hängt an `make test` · `make mutate` und ist damit erreichbar; die
  Asymmetrie zwischen beiden Hälften ist nicht ausgesprochen.
- **gegenbeispiel:** Der umsetzende Lauf baut die full-smoke-Behauptung, sieht das Rot einmal von
  Hand und legt keinen Mutations-Fall an — er kann keinen anlegen. Später fällt der Grund-Satz aus
  der Ausgabe (Refactor, Textkürzung). `make gates` bleibt grün (`full-smoke` steht ausdrücklich
  nicht darin, `sed -n '117,119p' Makefile`), `make mutate` meldet nichts, weil kein Fall
  gelistet ist. Die Auswertung meldet dann wieder nur einen **Zustand** — genau das, wovon `:514-522`
  die Grenze unterscheidet.
- **verifizierbar:** ja — die drei Kommandos oben, alle gefahren; `make gates` (Exit 0, selbst
  gefahren) belegt die Lücke nicht, es berührt `full-smoke` nicht.

### LOW-1 — Eine Regelwerks-Aussage trägt keinen der drei Formteile, an einer zweiten Stelle derselben ADR

- **kategorie:** LOW
- **quelle:** [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 (*Tag ·
  Regelwerks-Dateiname und Abschnittsname · Zitat verbatim*) und Festlegung 3(a) (der Accept-Übergang)
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:137`
- **befund:** Der Nachzug hat den in der Vorrunde genannten Fundort geheilt — `:347` führt jetzt
  `v3.5.2`, `modul-08-agentenrollen.md`, §Rollen-Regeln und ein verbatim geprüftes Zitat (Quelle:
  `.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md:62`, Abschnitt
  `### Rollen-Regeln (Modul 8)` ab `:60`, beides gelesen). Unbelegt bleibt die **Prämisse** der
  ganzen Entscheidung: `:137` behauptet *„Das Observability-Modul der adoptierten Baseline führt
  vier Regelblöcke"* und leitet daraus die vier Zeilen der Tool-Spalten-Tabelle ab — ohne Tag, ohne
  Dateinamen, ohne Abschnitt, ohne Zitat. Die Aussage stimmt heute (`grep -n '^### '
  .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` → vier Regel-Abschnitte
  *Span-/Audit-Attribut*, *Token-Attributions*, *Cache-Counter*, *Doku-Konsistenz-Drift*, selbst
  gefahren). Die abgelöste Entscheidung führt für denselben Gegenstand die volle Form an neun
  Stellen (`grep -nE 'v3\.5\.2' docs/plan/adr/0020-emittierte-modul-15-regeln.md | wc -l` → **9**,
  selbst gefahren) — der Maßstab ist also im Nachbardokument gesetzt.
- **gegenbeispiel:** Ein späterer Baseline-Bump teilt einen der vier Blöcke. Die eingefrorene ADR
  sagt weiter *„vier Regelblöcke"*, nennt aber keinen Tag, gegen den ein Leser das prüfen könnte —
  die Reproduzierbarkeits-Klammer, die ADR-0016 Festlegung 2 genau dafür verlangt, fehlt an der
  einzigen Stelle, an der die Vier-Zeilen-Tabelle ihren Grund hat.
- **verifizierbar:** ja — die zwei `grep` oben; kein Gate (`ids` prüft keine Regelwerks-Kennungen).

### LOW-2 — Die Abdeckungs-Zuschreibung an den bestehenden Abwesenheits-Wächter reicht weiter als der Wächter

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code
  hält"*)
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:317-319`
- **befund:** Der Absatz, der die Phasen-Ordnung aus [ADR-0007](../plan/adr/0007-bootstrap-phasen.md)
  hält, sagt: *„Nach dem Init hat das Ziel weiterhin kein Sprach-Fragment, kein Manifest und kein
  Skelett — die Eigenschaft, die der bestehende Abwesenheits-Wächter in
  `internal/emit/enforce_test.go` bereits hält."* Der Wächter hält das erste Drittel: er prüft, dass
  `EnforcePaths` kein `blocked/` trägt und dass `Enforce` sprachlos kein `tools/harness/blocked`
  anlegt (`sed -n '49,57p' internal/emit/enforce_test.go`, gelesen). Für *Manifest* und *Skelett*
  hält ihn nichts: `grep -rn 'go\.mod\|Skelett\|Manifest' internal/emit/*_test.go` → leer, Exit 1
  (selbst gefahren). Die Eigenschaft selbst ist konstruktiv wahr — bestritten ist nicht die Sache,
  sondern die Zuschreibung *„bereits hält"* über zwei von drei Gliedern.
- **gegenbeispiel:** Ein späterer Lauf legt in der Init-Phase ein Manifest ab (etwa als Beiwerk des
  Trägers). Kein Test färbt rot, und die eingefrorene ADR sagt, ein Wächter halte genau das — der
  Prüfer verlässt sich darauf und misst nicht nach.
- **verifizierbar:** ja — die zwei Kommandos oben.

### LOW-3 — Zwei Fitness-Zeilen beschreiben komplementäre Zweige, ohne den Zweig zu nennen

- **kategorie:** LOW
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
  [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:634`
  (Fitness-Zeile 2) gegen `:636` (Fitness-Zeile 4)
- **befund:** Zeile 2 hält den `LH-QA-01`-Fehlerzweig fest: *„Scheitert die Platzierung des Trägers,
  trägt die emittierte `.claude/settings.json` **keinen** Erfassungs-Hook, es liegt **kein** Wrapper,
  und der Bootstrap endet erfolgreich."* Zeile 4 hält den Anwesenheits-Zweig — unbedingt: *„Nach dem
  Bootstrap liegen im Ziel Träger, Wrapper, Rollen-Typen und die Feldliste."* Beide sind
  *„Geschuldet, nicht geliefert"*, beide sind als Wächter formuliert, und keine nennt ihre
  Bedingung. Im Zweig von Zeile 2 müsste der Wächter aus Zeile 4 rot werden. Offen bleibt
  zusätzlich, ob die **Feldliste** — seit dem Nachzug der *stehende* Nenn-Ort der Grenze aus
  [ADR-0021](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6 (`:519-521`) —
  in diesem Zweig entsteht: Festlegung 5(a) zählt Träger, Wrapper und Hook-Eintrag auf, die
  Feldliste nicht, und Festlegung 7 sagt, sie werde *„aus dem Träger erzeugt"*.
- **gegenbeispiel:** Der umsetzende Lauf schreibt den Anwesenheits-Wächter so, wie Zeile 4 ihn
  formuliert. Der `LH-QA-01`-Fall aus Zeile 2 färbt ihn rot; eine der beiden Zusagen wird darauf
  aufgeweicht. Wird es Zeile 2, verliert die `LH-QA-01`-Zusage genau das Gegenbeispiel, das die ADR
  für sie benennt.
- **verifizierbar:** ja — beide Zeilen und Festlegung 5(a) (`sed -n '400,407p'`) gelesen; kein Gate.

### LOW-4 — Folgepflicht 5 misst die Menge der falsch werdenden Plan-Stellen zu klein

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (die Zahl tritt als Bruch-Kriterium auf und trägt kein Kommando); Festlegung 3 dieser
  ADR, die eine der ungenannten Stellen selbst falsch macht
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:593-597` gegen
  `docs/plan/planning/welle-11-traeger-aussage.md:44`, `:46`, `:127` und `:261`
- **befund:** Folgepflicht 5 sagt, der Wellen-Plan werde *„an zwei Stellen falsch"* und beschreibt
  sie: die Träger-Tabelle *„für die Modul-15-Blöcke"* und das Out-of-Scope mit der
  CR-Bedingung *„solange er offen ist"*. Gemessen
  (`grep -niE 'permanent nicht emittiert|Solange er offen ist' docs/plan/planning/welle-11-traeger-aussage.md`,
  selbst gefahren) trägt der Plan die erste Aussage an **zwei** Zeilen — `:44` (Modul 15) und `:46`
  (**Modul 8**, Rollen-Trennung, *„entschieden, permanent nicht emittiert (ADR-0020 Festlegung 2)"*)
  — und die zweite an **zwei** Stellen, `:127` (§1) und `:261` (§6). Die Modul-8-Zeile ist von der
  Beschreibung ausdrücklich nicht erfasst (*„für die Modul-15-Blöcke"*), obwohl **Festlegung 3
  dieser ADR** die dort zitierte ADR-0020 Festlegung 2 vollständig revidiert. Dieselbe Klasse hat
  die Vorrunde an Folgepflicht 8 gemeldet; dort ist sie durch eine **Eigenschaft** statt einer
  Adresse geheilt (`:606-613`, *„Betroffen ist **jede** Stelle, die …"*) — hier nicht.
- **gegenbeispiel:** Der Planner arbeitet Folgepflicht 5 wörtlich ab, korrigiert die Modul-15-Zeile
  und den Out-of-Scope-Absatz. Stehen bleibt eine Plan-Zeile, die für `.claude/agents/` weiterhin
  *„permanent nicht emittiert"* behauptet und dafür eine revidierte Festlegung zitiert — genau die
  Aussage, deren Umkehrung Festlegung 3 beschlossen hat.
- **verifizierbar:** ja — das `grep` oben; kein Gate (das Doku-Gate liest keine Plan-Semantik).

### LOW-5 — Folgepflicht 7 nennt eine Index-Zeile; eine zweite Zeile desselben Index trägt eine Aussage, die diese Entscheidung falsch macht

- **kategorie:** LOW
- **quelle:** dieselbe Klasse wie LOW-4 und wie LOW-3 der Vorrunde — der Befund nennt einen
  Fundort, nicht die Fundmenge; Reviewer-Skill §Kontext-Eskalation (dritte Wiederholung derselben
  Klasse ⇒ Steering-Loop-Signal)
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:602-605` gegen
  die ADR-0021-Zeile in `docs/plan/adr/README.md`
- **befund:** Folgepflicht 7 ordnet bei der Annahme *„die Teil-Revisions-Annotation an der
  abgelösten Entscheidung"* an — also an der ADR-0020-Zeile. Die **ADR-0021**-Zeile desselben
  Index schließt mit *„**Die emittierte Ebene ist nicht berührt** (gemessen;
  `[ADR-0020](0020-emittierte-modul-15-regeln.md)` hat sie entschieden)"* und nennt Folgepflicht 6
  jener Entscheidung nirgends
  (`awk '/\| \[ADR-0021\]/' docs/plan/adr/README.md | grep -c 'Folgepflicht 6'` → **0**, selbst
  gefahren). Nach der Annahme zeigt diese Zusammenfassung auf eine in ihren Festlegungen 1–3
  revidierte Entscheidung und verschweigt genau den Satz, der den neuen Fall vorentschieden hat.
  Der Index ist ein **lebendes** Artefakt; ein Nachzug dort kostet eine Zeile, keine Folge-ADR — er
  ist nur von keiner Folgepflicht adressiert.
- **gegenbeispiel:** Der nächste Lauf, der die Kollisionsfrage zwischen ADR-0022 und ADR-0021 über
  den Index prüft, liest *„Die emittierte Ebene ist nicht berührt"*, findet keinen Hinweis auf
  Folgepflicht 6 und schließt, jene Entscheidung sage zum emittierten Fall nichts — dieselbe
  Fehlannahme, aus der der blockierende Befund der Vorrunde entstanden ist.
- **verifizierbar:** ja — das `awk`/`grep` oben; kein Gate.

### INFO-1 — Die Äquivalenz „und dann trägt er sie hier ebenso" ist enger als die Trigger-Bedingungen, auf die sie sich beruft

- **kategorie:** INFO
- **quelle:** [ADR-0021](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  §Re-Evaluierungs-Trigger 1 und 2
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:500-502` und
  `:652-657`
- **befund:** Festlegung 8 sagt: *„ein Adopter-Bestand trägt Verbrauchs-Zähler genau dann, wenn
  einer jener zwei fremden Wege trägt — und dann trägt er sie hier ebenso."* Die Rückrichtung ist
  in der Quelle an je eine **weitere** Bedingung geknüpft: Trigger 1 sagt über die
  Vordergrund-Form *„wirkt nur, wenn jemand sie liest"*, Trigger 2 nennt als Merkenden *„der Slice,
  der ein weiteres Ereignis verdrahtet — heute verdrahtet dieses Repo `SubagentStop` nicht"*.
  Trägt sie dennoch, dann über [ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md)
  Folgepflicht 1 (*„der Beleg emittiert nichts, was der Dogfood nicht selbst fährt"*), die die zwei
  Ebenen gekoppelt hält — die ADR nennt sie an anderer Stelle, an dieser nicht. Die **Richtung**,
  auf die es der Trigger ankommen lässt (Adopter-Zähler ⇒ fremder Weg trägt ⇒ Folge-ADR nötig),
  ist sauber, und der Quadrant *feedforward* deckt sich mit beiden Triggern der Quelle (dort je
  *feedforward*, gelesen).
- **verifizierbar:** ja — beide Trigger von ADR-0021 gelesen (`sed -n '757,768p'`).

### INFO-2 — Das Mess-Kommando der Vorrunde trug nicht; seine Aussage trägt

- **kategorie:** INFO
- **quelle:** eigener Report der Vorrunde, MEDIUM-2; Dogfood-gegen-emittiert-Trennung
- **pfad:** `docs/reviews/2026-08-23-adr-0022-proposed-review.md:141`
- **befund:** Die Vorrunde führte `grep -niE 'latenz|latency|median|bench' Makefile harness/mk/*.mk`
  und meldete *„leer"*. Nachgefahren: `ls -d harness/mk` → Exit 2, und das Kommando endet mit
  **Exit 2** samt `No such file or directory` auf stderr — ein fehlgeschlagener Glob, kein
  Negativbefund; stdout ist leer, weil `Makefile` keinen Treffer hat, nicht weil die Fläche geprüft
  wurde. Der Grund der Verwechslung ist ablesbar: `harness/mk/` ist ein **emittierter** Pfad, kein
  Pfad dieses Repos (`grep -n 'enforce.mk' internal/emit/enforce.go` →
  `{"templates/enforce/enforce.mk", "harness/mk/enforce.mk", 0o644}`). Die Make-Fläche dieses Repos
  ist `git ls-files '*.mk' 'Makefile'` → `Makefile`, `d-check.mk`,
  `internal/emit/templates/enforce/enforce.mk` (das dritte ist das Emissions-Template). Über beide
  repo-eigenen Dateien und über alle drei gefahren: `grep -niE 'latenz|latency|median|bench' …` →
  leer, **Exit 1**. Der einzige Ort, der die Frage je stellte, hält sie als **offen**
  (`docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:145`, Zeile *E* der Tabelle
  *„Weiterhin offen — vor dem ersten Code zu messen"*, ohne Zahl). **Die Aussage des Befundes trägt
  also**: ein Latenz-Sensor existiert nicht. Die ADR übernimmt die korrigierte Form an allen drei
  Fundorten (`:261`, `:621`, `:647`) und im Index.
- **verifizierbar:** ja — alle fünf Kommandos oben gefahren.

### INFO-3 — Der Auszeichnungs-Teil von INFO-1 der Vorrunde ist an der Quelle widerlegt

- **kategorie:** INFO (REFUTED, mit Beleg)
- **quelle:** [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2
- **pfad:** `docs/reviews/2026-08-23-adr-0022-proposed-review.md:259-260` gegen
  `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:270` ff.
- **befund:** Die Vorrunde zählte unter INFO-1 auch, dass das `LH-FA-10`-Zitat *„die Auszeichnung
  verschiebt"* (Quelle setzt einen Teilsatz fett, die ADR nicht). ADR-0016 Festlegung 2 entscheidet
  das ausdrücklich anders: *„**Was „verbatim" heißt: der Wortlaut ohne Auszeichnung, Whitespace
  normalisiert.** Nicht die Quell-Bytes."* Die Behandlung im Nachzug — Auszeichnung gestrippt,
  Zitat auf den vollen Satz erweitert — ist damit die von der Quelle vorgeschriebene. Die zwei
  übrigen Teile von INFO-1 (ADR-0012-Paraphrase, ADR-0020-Fitness-Zeile) sind sachlich behoben.
- **verifizierbar:** ja — ADR-0016 §Festlegung 2 vollständig gelesen.

---

## Negativbefunde (geprüft, ohne Befund)

- **HIGH-1 der Vorrunde — aufgelöst, auf Weg (a), und die Kollision ist nicht bloß umformuliert.**
  Die widerlegte Zuschreibung ist ersatzlos verschwunden:
  `grep -rn 'Berechtigungs-Lage' docs/ spec/ harness/ AGENTS.md` → **ein** Treffer, und der liegt in
  `spec/spezifikation.md:100` als Feldbeschreibung `permission_mode` (selbst gefahren) — in ADR und
  Index kommt der Ausdruck nicht mehr vor. An seine Stelle tritt der Grund, den ADR-0021 selbst
  führt (*„Kein Aufwand dieses Repos bringt eines von beiden herbei"*, `:111` dort, verbatim
  geprüft). Die Aussage steht jetzt an vier Orten deckungsgleich: Bezug (`:56-60`), ein eigener
  Absatz im Revidiert-Block (`:112-117`), Festlegung 8 (`:494-504`) und die Konsequenzen-Grenze
  (`:563-567`), dazu die Index-Zeile. Eine Gegen-Suche nach verbliebenen Widersprüchen —
  jede Aussage der ADR über Zähler auf der emittierten Ebene einzeln gegen ADR-0021 Festlegung 1,
  Festlegung 4, Folgepflicht 6 und die fünf Trigger gehalten — findet keine.
- **Reichweite der Einlösung — die zwei Nenn-Orte tragen, was Folgepflicht 6 verlangt.** Die
  Folgepflicht verlangt *„genannt, nicht stillschweigend mitgeliefert"*; Ort (ii), das
  Feldlisten-Dokument, ist **stehend** und liegt im geprüften Doku-Bereich des Ziels (Festlegung 7,
  Idempotenz-Klasse *konvergent*), trägt also auch dann, wenn niemand die Auswertung ruft. Der
  Zahn dafür (`:639`) ist konstruierbar und über `make test` · `make mutate` erreichbar. Die
  Unterscheidung *Zustand* gegen *Grenze* (`:514-522`) ist sachlich richtig gezogen.
- **Quadrant und Richtung der zwei neu gefassten Trigger.** Der Latenz-Trigger steht jetzt als
  *feedforward, bis ein Slice den Sensor baut* — wortgleich mit der Einordnung, die ADR-0011 für
  dieselbe Schwelle führt (`sed -n '/Wenn die Erfassung den Lauf bremst/,+6p'
  docs/plan/adr/0011-telemetrie-erfassung-policy.md`, gelesen). Der Zähler-Trigger steht als
  *feedforward*, wie die Trigger 1 und 2 von ADR-0021; seine Reihenfolge (zuerst Folge-ADR auf die
  *Accepted*-Entscheidung nach §3.4, dann Nachzug der zwei Nenn-Orte, dann die Sammelposten-Frage)
  ist mit §3.4 vereinbar.
- **MEDIUM-2 der Vorrunde — die Latenz-Schuld hat eine Adresse.** Folgepflicht 9 existiert, nennt
  den Gegenstand (Median des Hook-Aufschlags gegen die Schwelle, mit dem getrennten Emitter als
  Vergleichspunkt), verlangt das Kommando im Text (`MR-025`) und begründet die fehlende
  Fitness-Zeile mit `LH-QA-01`. **Die Form passt zu den vier anderen *„Geschuldet, nicht
  geliefert"*-Zeilen:** deren Targets existieren alle
  (`grep -nE '^(full-smoke|test|mutate):' Makefile` → `:49`, `:118`, `:121`, selbst gefahren) und
  ihnen fehlt nur der Sensor; für die Latenz existiert **kein** Target, und eine Zeile darüber
  wäre die Aussage über einen Gate, den es nicht gibt. Die Unterscheidung *Target existiert /
  Sensor fehlt* gegen *Target fehlt* ist tragfähig und ausgesprochen.
- **Verbatim-Gegenprobe, selbst gefahren, nicht übernommen.** **40** Zitate der ADR — die elf neu
  eingesetzten und alle übrigen, die ich beim Lesen fand — maschinell gegen ihre Quellen gehalten
  (Normalisierung: Zeilenumbruch → Leerzeichen, Mehrfach-Whitespace kollabiert, Auszeichnung
  gestrippt nach ADR-0016 Festlegung 2, `//`-Kommentar-Präfix gestrippt; Test mit `grep -qF` als
  **Here-String**, nie über eine Pipe). Ergebnis **40/40 verbatim**; Skript unter
  `…/scratchpad/verb.sh`, Kommando `bash …/verb.sh`. Zwei Fälle waren erst nach der zusätzlichen
  Normalisierung sauber (`internal/span/span.go` — Kommentar-Präfix; `spec/lastenheft.md` §Neu ist
  die Artefakt-Klasse — Kursiv-Marker), keiner wegen abweichenden Wortlauts.
- **ADR-0020 und ADR-0021 byte-identisch zum Vorzustand (§3.4 — gemessen, nicht angenommen).**
  `git diff --stat caaa6a5..19dfe36 -- docs/plan/adr/0020-….md docs/plan/adr/0021-….md` → leer;
  Blob-Hashes über beide Stände identisch (`git rev-parse caaa6a5:<pfad>` gegen
  `19dfe36:<pfad>`, je gleich).
- **§3.8 — nur Architect-Artefakte.** `git diff --name-status caaa6a5..19dfe36` → `M` auf genau
  zwei Dateien, beide im ADR-Stratum; die Commit-Message nennt die Rolle in der ersten Zeile.
- **Keine Slice-/Wellen-IDs.** `grep -niE 'slice-[0-9]|welle-[0-9]|slice [0-9]'` über die ADR →
  leer, Exit 1; über die ADR-0022-Zeile des Index ebenso. Folgepflicht 5 und Folgepflicht 8
  beschreiben ihre Gegenstände über Eigenschaften statt über Adressen.
- **Artefakt beschreibt die Sache.** Keine Befund-IDs, keine Runden-Verweise, kein *„hier stand
  bis …"*: `grep -niE 'runde|HIGH-[0-9]|MEDIUM-[0-9]|LOW-[0-9]|INFO-[0-9]|hier stand'` über die ADR
  → nur Treffer, die die **Sache** benennen (`Nachzug` je über den Dogfood-Einstiegspunkt,
  `reviewer` als einer der sechs Rollennamen). Die 68 Deletionen zeigen, dass ersetzt und nicht
  danebengestellt wurde; die zwei größten Zuwächse (Folgepflicht 9, der Zwei-Orte-Absatz) sind neue
  Sache, kein Kommentar über alten Text.
- **`MR-025` — jede Messwert-Zahl steht neben ihrem Kommando, und die Kommandos stimmen.** Selbst
  nachgefahren: `grep -nE '^FROM .* AS (span|report)$' Dockerfile` → `94:FROM deps AS span`,
  `110:FROM deps AS report` (zwei Zeilen) · `grep -c '^span-emit-build:' Makefile` → **1** ·
  `ls -1 .claude/agents/ | wc -l` → **6** · `grep -rn "claude/agents" --include=*.go . | wc -l` →
  **0** · `grep -n 'artifact-copy' Makefile` → drei Aufrufstellen (`:73`, `:100`, `:234`) ·
  `grep -n '^gates:' Makefile` → `:262`, die Kette trägt `span-emit-build` und `span-check` ·
  `grep -rln 'Feldliste' internal/emit/*.go` → leer, Exit 1. Der Ausreißer der Vorrunde (LOW-5) ist
  an allen drei Fundorten **und** im Index geheilt.
- **Zitierte Code-Locator stimmen.** `sed -n '182,189p' internal/span/emit.go` liefert
  `roleFromAgentType` mit genau den sechs Rollennamen; `sed -n '42,44p' harness/tools/artifact-copy.sh`
  liefert die drei zitierten Zeilen. Beide Locator tragen ihren Inhalt mit — ein Zeilen-Versatz
  fiele auf, statt still zu werden.
- **Weitere Ist-Behauptungen der ADR, stichprobenweise nachgemessen:**
  `grep -n 'gitignore' internal/emit/enforce.go` → `:47` legt `.harness/.gitignore` an,
  `cat internal/emit/templates/enforce/gitignore` → `state/` ·
  `grep -c 'CLAUDE_PROJECT_DIR' internal/emit/templates/enforce/settings.json` → **2** ·
  `grep -n 'roots:\|modules:\|ignore:' internal/emit/templates/d-check.yml` → `roots: ["."]`,
  `modules: [links, anchors]`, `ignore: [… ".harness/**"]` — alle drei Aussagen aus Festlegung 3
  und 7 treffen zu. Die zwei Dockerfile-Kommentare aus Folgepflicht 8 stehen so, wie die
  Folgepflicht sie beschreibt (`sed -n '84,110p' Dockerfile`), einschließlich des Satzes *„Ein
  Host-Binary waere ein Artefakt ohne Leser"* an der Auswertungs-Stufe.
- **LOW-1, LOW-3, LOW-4 und INFO-2 bis INFO-4 der Vorrunde — an ihrem Gegenstand geprüft, alle
  behoben.** Die Lastverteilung um ADR-0020 Festlegung 6 ist an **beiden** Fundorten korrigiert
  (ADR `:98-104`, Index-Zeile); Folgepflicht 8 beschreibt jetzt die Eigenschaft statt des
  Erkennungsmerkmals und trifft damit beide Dockerfile-Stellen; Fitness-Zeile 5 trägt den
  Schuld-Vermerk samt Sensor-Kommando; die ADR-0013-Adresse zeigt auf den Re-Evaluierungs-Trigger
  und zitiert Folgepflicht 3 korrekt; die neue Eigenschaft der konvergenten Klasse ist in der
  Idempotenz-Tabelle ausgesprochen; die Reihenfolge-Umkehr gegenüber ADR-0020 Folgepflicht 1 ist
  benannt.
- **Gate-Aussagen des Commits — selbst nachgefahren, beide bestätigt.** `make docs-check` →
  `d-check: 352 Datei(en) geprüft, 0 Befund(e)`, Exit 0 (die Dateizahl wandert mit dem Bestand und
  ist nach `MR-025` Setzung 2 kein Erwartungswert). `make gates` → Exit 0, letzter Schritt
  `span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert`.
- **Was kein Gate deckt, und das ist der Grund für diese Runde:** kein Modul von `.d-check.yml`
  liest ADR-Semantik (`grep -n '^modules:' .d-check.yml` → `[links, anchors, ids, matrix,
  codepaths, spans]`). Alle Findings oben stehen bei grünem `make gates`.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 5 |
| INFO | 3 |

Stand gegenüber der Vorrunde: HIGH 1 → **0**, MEDIUM 2 → 2 (beide neu bzw. Rest des alten
Gegenbeispiels), LOW 5 → 5 (alle fünf alten behoben, fünf neue), INFO 4 → 3.

## Verdikt

**Nicht frei für die Annahme — blockiert.**

**Das HIGH ist weg, und es ist wirklich weg, nicht umformuliert.** Der gewählte Weg (a) ist
durchgezogen: die Aussage über die emittierte Ebene ist an vier Orten auf
[ADR-0021](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6 ausgerichtet,
die widerlegte Zuschreibung ist ersatzlos verschwunden, der tragende Grund jener Entscheidung ist
verbatim übernommen, und der Trigger sagt jetzt, dass ein Adopter-Bestand mit Zählern sehr wohl
etwas widerspricht und **zuerst** eine Folge-ADR fällig macht. Die Einlösung selbst ist mehr als
eine Abdeckungs-Zeile: die Unterscheidung *Zustand* gegen *Grenze* trägt, und der stehende
Nenn-Ort im Feldlisten-Dokument leistet, was *„genannt, nicht stillschweigend mitgeliefert"*
verlangt — mit einem Zahn, der über `make test` · `make mutate` erreichbar ist.

**Was die Sperre hält, sind zwei MEDIUM, und beide sitzen im neu geschriebenen Text.**

1. **MEDIUM-1** ist der Rest des Gegenbeispiels der Vorrunde, nicht ein neuer Einwand: der
   Beweis-Anspruch ist gefallen, aber der an seine Stelle getretene Grund — die *Ersparnis* —
   trennt den gewählten Weg nach dem Wortlaut desselben Absatzes **nicht** von Alternative F, und
   derselbe Absatz schickt den Trigger zu Annahme (a) auf F, wo F aus demselben Grund ebenso fällt
   (der Trigger selbst nennt D, E **und** F). Der einzige verbliebene Unterschied steht als *„höherer
   Preis"* in der Alternativen-Tabelle — und die Index-Zeile erklärt einen Aufwandsvergleich
   ausdrücklich zum Nicht-Grund. Ab *Accepted* kostet jede dieser drei Stellen eine Folge-ADR
   ([`AGENTS.md`](../../AGENTS.md) §3.4).
2. **MEDIUM-2** betrifft den Zahn, der die Einlösung an ihrem **ersten** Nenn-Ort trägt: die Zeile
   ruft §3.6 selbst an (*„ohne dieses Rot ist die Einlösung … eine Absicht"*), hängt aber allein an
   `make full-smoke` — einem Sensor, für den der Mutations-Treiber dieses Repos kein
   Fehlschlag-Muster kennt und den kein Fall in `test/mutations/` benennen kann. Für `make smoke`
   wurde genau diese Lücke einmal ausdrücklich geschlossen; hier ist sie weder geschlossen noch
   genannt, während die ADR vergleichbare Lücken sonst mit Kommando ausweist. Die Schwester-Zeile
   des zweiten Nenn-Orts zeigt, dass es anders geht.

**Die fünf LOW blockieren nicht.** LOW-1 sollte trotzdem vor dem Accept fallen, weil
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3(a) genau diesen Übergang
bindet und der Preis danach von einer Zeile auf eine Folge-ADR steigt. LOW-4 und LOW-5 sind
zusammen mit LOW-3 der Vorrunde die **dritte** Wiederholung derselben Klasse an diesem Artefakt —
*eine Folgepflicht nennt einen Fundort statt einer Fundmenge*. Nach dem Reviewer-Skill ist das ein
Steering-Loop-Signal: die Heilung, die der Nachzug an Folgepflicht 8 vorgemacht hat (Eigenschaft
statt Adresse), ist an den beiden übrigen Folgepflichten nicht angewandt worden, und ein Sensor
über dieser Klasse existiert nicht.

**Die drei INFO tragen keine Sperre.** INFO-2 hält den eigenen Fehler der Vorrunde fest: das dort
geführte Mess-Kommando lief in einen fehlgeschlagenen Glob über einen **emittierten** Pfad und
endete mit Exit 2 statt Exit 1 — kein Negativbefund. Über die reale Make-Fläche dieses Repos
nachgemessen bleibt die **Aussage** des Befundes richtig: ein Latenz-Sensor existiert nicht.
