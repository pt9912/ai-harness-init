# Review — slice-193 (Der vendored Baum steht auf `v6.5.0` — Pins gezogen, Verweise nachgezogen)

**Rolle:** Reviewer (Modul 8) · **Datum:** 2026-09-07 · **Modell:** claude-opus-5[1m]

**Gegenstand:** die sieben Commits `697b7724` · `c606d642` · `b260839d` · `7e05dca8` ·
`3763a755` · `962c1722` · `a44b43f2`, Kopf `a44b43f2`.

**Baum beim Lauf:** `a44b43f2`, Arbeitsbaum vor und nach dem Review sauber
(`git status` → *nichts zu committen*). `make gates` → **rot**, Abbruch an `docs-check`:
`916 Datei(en) geprüft, 36 Befund(e)`, alle mit Grund-Code `target-missing`
(`make docs-check 2>&1 | awk -F'\t' 'NF>2{print $3}' | sort | uniq -c` → `36 target-missing`).
Die übrigen zehn Ziele der `record-gates`-Kette einzeln nachgefahren
(`make -k lint build test shell-lint ci-lint comment-claims host-bin span-check` → EXIT 0,
`grep -cE '^not ok|--- FAIL|^make.*Fehler'` → 0) und `make baseline-verify` →
`v6.5.0 OK — 54 Dateien`.

> **Zitier-Form** *(dieser Block bleibt stehen — Norm, kein Ausfüll-Hinweis).* Dieser Report
> friert ein; was er zitiert, bewegt sich weiter. Deshalb **Kennung statt Adresse** —
> `slice-193` statt seines Lifecycle-Pfads, `make <target>` statt eines Links auf ein Rezept,
> eine Baseline-Stelle als Tag **und** Pfad in Inline-Code statt als Link
> (`v6.5.0` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt genau einen Tag;
> der Sprung löscht den alten, und ein Link darauf färbt beim nächsten Bump ein Artefakt rot,
> das niemand mehr anfassen darf. Das `pfad`-Feld auf den geprüften Gegenstand hält den Stand
> des Laufs fest und darf ihn nennen.

**Eingangs-Kontext (Modul 10, fünf Pflicht-Punkte + Repo-Ergänzung):** Diff = die sieben Commits
oben · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) ·
aktive ADRs [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md),
[ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md),
[ADR-0023](../plan/adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md),
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
[ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md),
[ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) ·
Hard Rules [`AGENTS.md`](../../AGENTS.md) §3 (namentlich §3.3, §3.4, §3.8, §3.10, §3.11) ·
vorherige Findings am gleichen Modul: der Report zu ADR-0038 vom 2026-09-07 und die Reports zu
`slice-182` (dem Sprung davor) · Plan-Verweis: `slice-193`, `in-progress/`.

**Auflage dieses Laufs, festgehalten, weil sie vom Default abweicht:** eine Runde, Befunde in
den Report statt in die Artefakte. Das rote Gate gilt als erklärt, **es sei denn**, die Erklärung
trägt nicht — dieser Punkt ist geprüft und als MEDIUM-4 beantwortet.

---

## Findings

### HIGH-1 — Die Entscheidung, auf der die Start-Bedingung des Slice ruht, ist angenommen, ohne dass ihr eigener Acceptance-Trigger belegt ist

- `kategorie`: HIGH
- `quelle`: [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md)
  §Der Acceptance-Trigger; `v6.5.0` · `regelwerk/modul-08-agentenrollen.md` §Rollen-Regeln
- `pfad`: `docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md:3` (Status) gegen
  `:342`–`:348` (Trigger); `docs/reviews/2026-09-07-adr-0038-ziel-fassung-v650-review.md:307`
- `befund`: Der Trigger verlangt eine Reviewer-Runde, deren Report **ohne blockierenden Befund**
  in `docs/reviews/` liegt. Der einzige Report zu dieser ADR schließt mit *„Nicht annahmefähig in
  dieser Runde — zwei HIGH"* und stellt in seiner letzten Zeile selbst fest, er sei der verlangte
  Report nicht; ein zweiter existiert nicht (`grep -rl '0038' docs/reviews/` → diese eine Datei
  plus der Verify-Report zu `slice-190`). Zwischen dem Report und dem Accept-Commit `61372d47`
  liegt allein der Architect-Commit `ee8bca11` (*„zwei HIGH … aufgeloest"*): Die Rolle, deren
  Artefakt geprüft wurde, hat den Prüfbefund selbst für erledigt erklärt und danach angenommen.
  Seit `Accepted` ist die Datei nach [`AGENTS.md`](../../AGENTS.md) §3.4 eingefroren, der
  Widerspruch zwischen Statuszeile und Trigger-Abschnitt also in ihr nicht mehr behebbar.
  Start-Bedingung 1 von `slice-193` prüft den Statuswert und ist damit erfüllt; die Bedingung,
  die der Statuswert behaupten soll, ist unbelegt.
- `verifizierbar`: nein — kein Modul in `modules:` der `.d-check.yml`
  (`links, anchors, ids, matrix, codepaths, spans, planning`) liest Status-Übergänge oder
  Report-Verdikte; das Modul `reviews`, das die Report-**Deckung** prüfen könnte, ist nicht
  aktiviert. `make mutate` kennt keine Fehlschlag-Form dafür.
- `klasse`: Accept-Übergang ohne den Beleg, den der eigene Trigger nennt

### HIGH-2 — `harness/conventions.md` behauptet nach dem Tausch sechsmal einen Stand, den das Repo nicht mehr trägt

- `kategorie`: HIGH
- `quelle`: [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) §Konsequenzen
  (Architect-Folgepflicht, *„fällig mit dem Baum-Tausch"*); `MR-040` (drei Ausgänge für eine
  Präsens-Aussage über den vendored Baum); `MR-025` Setzung 1
- `pfad`: `harness/conventions.md:11`, `:13`, `:15`, `:39`, `:43`, `:68`, `:72`, `:78`–`:79`,
  `:96`
- `befund`: Der Baum steht seit `697b7724` auf `v6.5.0` und alle fünf Pin-Stellen mit ihm; die
  Datei sagt weiterhin (a) `**Stand:** v6.0.0` (`:11`), (b) *„committet vendored unter
  `.harness/baseline/v6.0.0/`"* (`:13`) samt *„Regelwerks-Stand … Kurs-Welle 116 · 2026-09-03"*
  neben einem `sed`-Kommando, dessen Pfad nicht mehr existiert (`:15`) — der Baum meldet
  `sed -n '3p' .harness/baseline/v6.5.0/regelwerk/README.md` → `**Stand:** Kurs-Welle 128 ·
  2026-09-06.` —, (c) *„Ihr Vollzug steht aus: Der Baum trägt `v6.0.0`"* (`:39`), (d) ADR-0038
  stehe auf `Proposed` (`:43`), (e) die kanonische externe Quelle sei auf `tree/v6.0.0` gepinnt
  (`:68`) und `make baseline-verify` melde `v6.0.0 OK — 53 Dateien` (`:72`), während der Lauf
  `v6.5.0 OK — 54 Dateien` ausgibt, und (f) *„Fünf Stellen pinnen `v6.0.0`"* (`:78`–`:79`).
  Die Datei ist Rang 9 der Source Precedence und der Ort, den
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2
  für die Zielstand-Buchung vorschreibt; der Commit `7e05dca8` hat sie bearbeitet und drei der
  Stellen ausdrücklich zurückgestellt, die drei unter (e)/(f) gar nicht erfasst (s. MEDIUM-1).
- `verifizierbar`: nein — und das ist gemessen, nicht angenommen: `make docs-check` meldet in
  dieser Datei keinen Befund, weil `scan.ignore` `.harness/baseline/**` führt und `codepaths`
  Inline-Pfade dorthin überspringt. Sonde über einer Kopie außerhalb des Repos mit dem Pin aus
  `d-check.mk`: ein frei erfundener Pfad (`docs/gibt-es-nicht/probe.md`) meldet
  `codepath-missing`, ein ebenso nicht existierender Pfad im Baseline-Baum
  (`.harness/baseline/v6.0.0/regelwerk/README.md`) meldet nichts. Die Datei selbst nennt in
  §*Was das Feld `Stand:` trägt*, dass kein `versions`-Modul läuft.
- `klasse`: Präsens-Aussage über den vendored Baum ohne `MR-040`-Ausgang

### HIGH-3 — Der Adress-Nachzug schreibt in eine ab Anlage unveränderliche `observation.md`

- `kategorie`: HIGH
- `quelle`: `v6.5.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register (*„`observation.md`
  (unveränderlich ab Anlage: Bezeichnung und Sub-Area)"*) und `v6.5.0` ·
  `templates/docs/plan/planning/observation.template.md`, Bedienhinweis
  (`grep -n 'unveraenderlich ab Anlage'` → `21: observation.md unveraenderlich ab Anlage`);
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
- `pfad`: `docs/plan/planning/observations/BEO-ALL/beleg-nach-dem-ausgang-findet-keinen-leser/observation.md:6`
  (in `c606d642`)
- `befund`: Der Commit ändert eine Zeile in einer Datei, die die Ziel-Fassung und ihre Vorlage
  als ab Anlage unveränderlich führen; die Commit-Message listet sie unter *„Gezogen"*, ohne die
  Eigentums- oder Einfrier-Frage zu stellen. Im selben Lauf blieb
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md` stehen und ist
  einer der 36 `docs-check`-Befunde; [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
  zählt sie als *„1 in einer `observation.md`"* und begründet das Einfrieren mit derselben
  Vorlage. Zwei Dateien derselben Klasse, zwei Behandlungen — dass die eine gezogen und die
  andere gehalten wurde, unterscheidet nur, ob die Adresse in einer Link-Klammer stand.
- `verifizierbar`: nein — kein Modul liest Commits, und der Schreibvorgang macht `docs-check`
  grüner statt röter (ohne ihn wären es 37 statt 36 Befunde).
- `klasse`: `verweis-nachzug-schreibt-in-eingefrorenes-artefakt`

### HIGH-4 — Zwei Artefakte fremder Rollen im Implementations-Kontext geschrieben, eines davon nur zur Hälfte

- `kategorie`: HIGH
- `quelle`: [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  Festlegung 1 (`Accepted`; die Tabelle weist `.harness/skills/reviewer.md` dem **Reviewer** und
  `.claude/commands/close-welle.md` dem **Planner** namentlich zu)
- `pfad`: `.harness/skills/reviewer.md:67` und `.claude/commands/close-welle.md:25`, `:46`
  (beide in `c606d642`); der offene Rest in `.harness/skills/reviewer.md:4`
- `befund`: Derselbe Commit nimmt `harness/conventions.md` nach [`AGENTS.md`](../../AGENTS.md)
  §3.8 ausdrücklich aus und übergibt sie an den Architect, stellt die Eigentumsfrage für diese
  zwei Dateien aber nicht — obwohl eine `Accepted`-ADR sie namentlich zuweist. Die Skill-Datei
  bleibt dabei halb gezogen: ihr Rumpf zeigt jetzt in den `v6.5.0`-Baum, ihr Kopf führt weiter
  `**Baseline:** Agents-Regelwerk v6.0.0 (Kurs-Welle 116)`, und der Versionierungs-Block der
  Datei, der zu jedem der fünf vorigen Re-Pins einen Eintrag trägt (1.2.0–1.7.0), hat für diesen
  Sprung keinen. Die Klasse ist im Register geführt und stand vor diesem Lauf bei 5
  (`ls docs/plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence/*.md | wc -l`).
- `verifizierbar`: nein — kein Modul des Doku-Gates liest Commits; [`AGENTS.md`](../../AGENTS.md)
  §3.8 und §3.10 benennen dieselbe Lücke für ihre eigenen Fälle.
- `klasse`: `fremdes-rollen-artefakt-im-implementations-kontext`

### MEDIUM-1 — Das Mess-Instrument des Nachzugs ist enger als die Klasse, die DoD 2 zusagt

- `kategorie`: MEDIUM
- `quelle`: `slice-193` §2 Liefer-Punkt 2 (*„Kein lebender Verweis zeigt auf den alten Tag, und
  der Nachzug hat seine Bezugsmenge gemessen statt behauptet"*); `MR-040`
- `pfad`: `harness/conventions.md:68`, `:72`, `:78`–`:79`; `docs/user/benutzerhandbuch.md:174`
- `befund`: Die Bezugsmenge des Plans und beider Nachzugs-Commits ist
  `git grep -l '\.harness/baseline/v6\.0\.0'`. Der Tag wird in lebenden Artefakten aber auch
  **ohne** Pfad-Präfix genannt, und diese Nennungen sieht das Muster nicht. Gemessen am Kopf:
  `git grep -n 'v6\.0\.0' -- '*.md' '*.go' '*.sh' '*.yml' 'Makefile' ':!docs/plan/planning/done'
  ':!docs/reviews' ':!harness/conventions/done' ':!docs/plan/adr' ':!.harness/baseline' | grep -v
  '\.harness/baseline/v6\.0\.0'` liefert 17 Zeilen in 17 Dateien; die meisten sind zulässige
  historische Aussagen (*„`v6.0.0` ersetzt die Tabellen-Datei …"*), aber vier davon sind
  Präsens-Aussagen über den heutigen Zustand: drei in `harness/conventions.md` (s. HIGH-2 (e)/(f))
  und `docs/user/benutzerhandbuch.md:174`, das die Abschluss-Zeile des Werkzeugs mit
  `Baseline v6.0.0 vendored` zitiert, während `cmd/ai-harness-init/main.go:392` sie aus
  `DefaultTag` bildet und dieser jetzt `v6.5.0` ist. Keine der vier steht in einer der drei
  Nicht-Zieh-Klassen, die `c606d642` ausweist; sie sind dem Instrument entgangen, nicht der
  Entscheidung.
- `verifizierbar`: nein — `make docs-check` sieht keine dieser vier Stellen (keine trägt eine
  Link-Klammer, `docs/user/**` und `harness/**` liegen im `codepaths`-Prüfbereich, aber es sind
  keine Pfade).
- `klasse`: `vollstaendigkeits-zusage-misst-falsche-ebene`

### MEDIUM-2 — Der Architect-Commit sagt „keine Aussage ist gebrochen" zu und misst eine andere Achse

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel);
  `MR-040`; `MR-025` Setzung 1
- `pfad`: Commit-Message `7e05dca8` (*„KEINE Aussage ist gebrochen, und das ist gemessen statt
  angenommen"*) gegen `harness/conventions/MR-007-baseline-committet-vendored-statt-gefetchter-cache.md:20`
- `befund`: Die Messung des Commits deckt Link-Ziele, Anker und wortgleiche Zitate ab — nicht die
  Präsens-Zahlen in den Rümpfen. Gegenbeispiel im selben Prüfbereich: `MR-007` §Adaption sagt
  *„`.harness/baseline/<tag>/{regelwerk,templates}/` + `SHA256SUMS` (42 Dateien: 21 + 21)"*,
  während der Baum 54 trägt (`find .harness/baseline/v6.5.0/regelwerk -type f | wc -l` → 26,
  dieselbe Zählung über `templates` → 28). Der Commit hat genau diese Datei angefasst (zwei
  Zeilen, beide Link-Ziele) und die Zahl passiert lassen; die Zusage ist damit weiter als ihre
  Messung.
- `verifizierbar`: nein — kein Sensor hält eine Zahl in einem Markdown-Rumpf gegen ihr Kommando;
  `make comment-claims` hat keine Markdown-Datei im Prüfbereich (`56 Datei(en) geprueft`).
- `klasse`: `vollstaendigkeits-zusage-misst-falsche-ebene`

### MEDIUM-3 — Die Grenze zwischen gezogen und stehengelassen verläuft am Gate, nicht an der erklärten Klasse

- `kategorie`: MEDIUM
- `quelle`: `slice-193` §2 Liefer-Punkt 2 (*„Der Beleg ist darum das `git grep` oben, nicht das
  Gate"*)
- `pfad`: Commit-Message `c606d642` Klasse 4 gegen Commit `a44b43f2`;
  `docs/plan/planning/open/slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md:58`, `:64`,
  `:263` und `docs/plan/planning/open/slice-196-spec-traegt-keine-liefer-aussage.md:71`
- `befund`: `c606d642` erklärt `slice-114`, `slice-195` und `slice-196` als **eine** Klasse, die
  nicht gezogen wird (*„dieser Sprung zieht nur `slice-193` selbst nach"*). `a44b43f2` zieht dann
  `slice-114` und begründet es mit dem Befundbild von `docs-check`; 195 und 196 bleiben stehen,
  weil ihre Nennungen in Code-Blöcken statt in Link-Klammern stehen und das Gate sie nicht sieht.
  Deren Kommandos laufen jetzt ins Leere — etwa
  `ls .harness/baseline/v6.0.0/templates/.harness/skills/ | wc -l # 2` — und die zwei Pläne sind
  lebende `open/`-Artefakte, die als nächstes ausgeführt werden. Die gelieferte Trennlinie ist
  *rot im Gate / grün im Gate*, also genau das Kriterium, das der Liefer-Punkt ausschließt.
- `verifizierbar`: teilweise — `make docs-check` bestätigt, dass 195/196 keinen Befund erzeugen;
  dass ihre Kommandos tot sind, zeigt nur das `git grep`.
- `klasse`: `vollstaendigkeits-zusage-misst-falsche-ebene`

### MEDIUM-4 — Das rote Gate hat eine Diagnose, aber keinen Träger

- `kategorie`: MEDIUM
- `quelle`: `v6.5.0` · `regelwerk/modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln
  (*„Ein Slice darf bei rotem Gate nur mit dokumentiertem Carveout … in `done/` landen, der den
  roten Gate-Status auf Trigger schaltet"*); `slice-193` §4 Rückführung `in-progress → open`
- `pfad`: `docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md:3`;
  `ls docs/plan/carveouts/*.md` → `CO-001`, `CO-002`, `README.md`
- `befund`: Die **Diagnose** trägt und ist nachgeprüft: alle 36 Befunde sind `target-missing`,
  16 Dateien, verteilt auf 32 in `docs/reviews/`, 3 in einem geschlossenen Slice unter
  `docs/plan/planning/done/` und 1 in einer `observation.md` — deckungsgleich mit der Aufstellung
  in ADR-0039 §Der Bestand. Der **Träger** fehlt: ADR-0039 steht auf `Proposed` und bindet damit
  nicht (dieselbe Lesart, mit der `slice-193` §4 die Annahme von ADR-0038 zur Start-Bedingung
  macht), und das Instrument, das dieses Repo für *„roten Gate-Status auf Trigger schalten"*
  führt — der Carveout —, existiert für diesen Fall nicht. Damit steht ein rotes `make gates`
  ohne ein angenommenes Artefakt, das es hält; `slice-193` §2 führt `make gates` grün als
  Liefer-Punkt und §5 als Closure-Kriterium 1.
- `verifizierbar`: ja — `make gates` bleibt rot (`docs-check`: `916 Datei(en) geprüft, 36
  Befund(e)`), und der Stop-Hook gibt keinen Abschluss über einem Baum frei, den kein
  aufgezeichneter `make gates`-Lauf deckt.
- `klasse`: Rotes Gate mit Diagnose, aber ohne angenommenen Träger

### MEDIUM-5 — Die Baseline-Aussage in `AGENTS.md` §1 hat keinen der drei `MR-040`-Ausgänge genommen

- `kategorie`: MEDIUM
- `quelle`: `MR-040` (drei Ausgänge, *„die alte Zahl unter neuem Pfad ist keiner der drei"*);
  `MR-033` Setzung 1
- `pfad`: `AGENTS.md:21`–`:22`
- `befund`: Der Satz sagt, der `regelwerk/`-Baum messe *„am adoptierten Stand `v6.0.0`"* 351125
  Zeichen, und stellt das Kommando `cat .harness/baseline/v6.0.0/regelwerk/*.md | wc -c` daneben.
  Nach dem Tausch ist `v6.0.0` nicht mehr der adoptierte Stand, und das Kommando läuft ins Leere;
  dieselbe Zählung über den Baum ergibt 351468. `c606d642` ordnet die Stelle der Klasse *„datierte
  Mess-Aussage nach `MR-033`"* zu — das erfüllt `MR-033` Setzung 1 (*„Ein Kommando, dessen Pfad
  den Tag enthält, erfüllt die Setzung"*), ist aber keiner der drei `MR-040`-Ausgänge: Ausgang 2
  verlangt die Tree-Operand-Form (`git show <ref>:.harness/baseline/<alt>/…`), hier steht ein
  Arbeitsbaum-Pfad. Die tragende Folgerung — mehr als das Doppelte von 150k — überlebt; ihr Beleg
  nicht. `AGENTS.md` §1 fällt nicht unter das Architect-Schreibrecht aus §3.8, das nur §3 und den
  Adaptions-Block bindet.
- `verifizierbar`: nein — die Zahl steht in keinem Link und in keinem Prüfbereich eines aktiven
  Moduls.
- `klasse`: `zahl-neben-nie-gefahrenem-kommando`

### MEDIUM-6 — Die an den Architect übergebenen Stellen in `AGENTS.md` §3 sind offen, und eine davon ist eine Präsens-Aussage

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.8 (Übergabe korrekt erklärt); `MR-040`
- `pfad`: `AGENTS.md:229`, `:232`, `:234`, `:239`, `:382`
- `befund`: `c606d642` weist §3 zu Recht dem Architect zu; der Architect-Commit `7e05dca8` hat
  `AGENTS.md` nicht angefasst (`git show --name-only 7e05dca8` → nur `harness/conventions.md`
  und Einträge unter `harness/conventions/`). Offen bleiben vier Kommando-Pfade in den gefallenen
  Baum und, in §3.7, der Satz *„die adoptierte Baseline `v6.0.0` **führt** diese Regel"* (`:229`)
  — eine Präsens-Aussage, die nach dem Tausch nicht mehr zutrifft. Die vier **Aussagen** selbst
  halten: gegen den neuen Baum nachgemessen ergeben alle vier Kommandos weiterhin `1`
  (`grep -c '^### 3\.7 Ein Kommentar beschreibt, was da ist$'` in
  `templates/AGENTS.template.md`; `grep -c '^### Was ein Kommentar trägt — Code, Konfiguration,
  Skripte$'` und `grep -c 'nennt sie als \*\*ein\*\* auflösbares Feld'` in
  `regelwerk/grundlagen-harness-dateien.md`; `grep -c 'P->>P: Closure in done/ + Lerneintrag'` in
  `regelwerk/modul-08-agentenrollen.md`). Tot sind allein die Adressen und die Stand-Aussage.
- `verifizierbar`: nein — dieselbe Blindstelle wie in HIGH-2: Inline-Pfade in den Baseline-Baum
  liegen außerhalb dessen, was `codepaths` prüft.
- `klasse`: Präsens-Aussage über den vendored Baum ohne `MR-040`-Ausgang

### LOW-1 — Ein Rollen-Anweisungssatz verdrahtet den Tag hart, seine zwei Geschwister nicht

- `kategorie`: LOW
- `quelle`: Maintainability; [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `pfad`: `.claude/commands/close-welle.md:25`, `:46` gegen
  `.claude/commands/implement-slice.md:12`, `:35`, `:46` und `.claude/commands/plan-welle.md:12`,
  `:19`, `:35`, `:69`
- `befund`: Zwei der drei Commands adressieren den vendored Baum durchgängig als
  `.harness/baseline/<tag>/…` und brauchen bei keinem Bump einen Nachzug; `close-welle.md` nennt
  den Tag an zwei Stellen literal und musste in `c606d642` gezogen werden. Der Unterschied ist
  weder erklärt noch irgendwo deklariert.
- `verifizierbar`: nein
- `klasse`: Adress-Form eines Artefakts weicht von seinen Geschwistern ohne Grund ab

### INFO-1 — `.claude/rules/` steht bei 7, `AGENTS.md` §1 nennt 4 — Vorbestand, nicht dieser Diff

- `kategorie`: INFO
- `quelle`: `MR-035`; `MR-025` Setzung 2
- `pfad`: `AGENTS.md:33`–`:34`
- `befund`: Der Satz führt *„die Module unter `.claude/rules/`, die als Symlink in den vendored
  Baum zeigen"* mit `ls .claude/rules/*.md | wc -l` → **4** als geschlossene Menge; das Kommando
  gibt heute **7** aus. Die drei zusätzlichen Einträge (`AGENTS.md`, `conventions.md`,
  `harness-README.md`) zeigen **nicht** in den Baum und stammen aus `8ed69524` vom 2026-09-06,
  also aus der Zeit **vor** diesem Diff. Die vier Baseline-Symlinks sind von `c606d642` korrekt
  und vollständig gezogen (`readlink .claude/rules/*.md | grep -c 'baseline/v6\.0\.0'` → 0). Kein
  Befund gegen `slice-193`; hier notiert, weil die Prüfung der Aussage in diesen Lauf fiel.
- `verifizierbar`: nein
- `klasse`: `zahl-neben-nie-gefahrenem-kommando`

### INFO-2 — Der Plan widerspricht sich in der Wellen-Frage

- `kategorie`: INFO
- `quelle`: `v6.5.0` · `regelwerk/modul-06-roadmap.md` §Wann Arbeit eine Welle braucht
- `pfad`: `docs/plan/planning/in-progress/slice-193-baum-tausch-v650-pins-ziehen.md:8`,
  `:250`, `:530`–`:531`
- `befund`: Der Kopf sagt *„**Welle:** ohne Welle"*, DoD-Punkt 10 sagt *„im Repo **ohne**
  Wellen-Betrieb hier geprüft"*, und §7 sagt *„dieses Repo führt Wellen-Betrieb; sie prüft die
  nächste Welle-Closure"*. Die drei Paarungen bekommen damit je nach gelesener Stelle einen
  anderen Träger. Plan-Artefakt, Planner-Eigentum; für die Umsetzung ohne Wirkung.
- `verifizierbar`: nein
- `klasse`: Träger einer Closure-Pflicht im selben Plan zweimal verschieden benannt

### INFO-3 — Ein Commit-Hash der Auftrags-Liste existiert nicht

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: Auftrags-Liste dieses Laufs
- `befund`: Der Asset-Re-Vendor ist als `2c1ff4a3` benannt; `git cat-file -t 2c1ff4a3` meldet
  `Not a valid object name`. Der Commit mit diesem Inhalt ist `962c1722`. Geprüft wurde
  `962c1722`.
- `verifizierbar`: nein
- `klasse`: Übergabe nennt eine nicht auflösbare Vorgangs-Adresse

---

## Nachprüfung der drei vorgelegten Befunde

Sie sind nachgefahren, nicht übernommen.

**Vorgelegt 1 — der vendored Baum kam aus dem `git`-Baum statt aus dem Release-Asset;
`962c1722` behebt es. → Behebung trägt, bestätigt.** Das Asset des gepinnten Tags bezogen und
gehasht: `sha256sum` → `80684c17b958d2bc0c25eef1bdff25342b9c7b90254431ade9c29ee2add18865`,
identisch mit `BASELINE_ZIP_SHA256` im `Makefile`, dem `sources`-`sha256` in `.d-check.yml` und
`DefaultBaselineSHA256` in `internal/fetch/baseline.go` (`git grep -ln` auf den Hash → genau diese
drei Dateien). Entpackt und gegen den Arbeitsbaum gehalten: `diff -r <asset> .harness/baseline/v6.5.0`
meldet als einzigen Unterschied *„Nur in … : SHA256SUMS"* — genau die Ausnahme, die
`internal/fetch/baseline.go` Setzung 2 vorsieht (*„die Datei selbst ausgenommen"*). Die
`SHA256SUMS`-Regel ist an beiden übrigen Achsen erfüllt: 54 Zeilen für 54 Dateien, Pfade relativ
zu `<tag>/`, und `diff <(cut -d' ' -f3- SHA256SUMS) <(cut -d' ' -f3- SHA256SUMS | LC_ALL=C sort)`
ist leer. `make baseline-verify` → `v6.5.0 OK — 54 Dateien`. Und die Ursache ist weg: die 29
Dateien mit `../../kurs/de/…`-Verweisen tragen jetzt absolute, tag-gepinnte URLs
(`grep -rl '](\.\./\.\./kurs' .harness/baseline/` → 0 Dateien).

**Vorgelegt 2 — `fetch.Baseline` wird für den eigenen Baum nie gerufen. → Bestätigt.**
`grep -rn 'fetch\.Baseline\|fetch\.DownloadBaseline' --include='*.go' . | grep -v _test.go`
liefert genau zwei Zeilen, beide in `cmd/ai-harness-init/main.go` (`:370`, `:563`) und beide im
Init-Pfad für Zielrepos; `grep -nE '^(baseline|regelwerk)[a-z-]*:' Makefile` nennt drei Ziele, von
denen keines vendort. Der Dogfood-Baum entsteht damit weiter von Hand, und die Kette
Asset → Baum hängt an dieser Hand — was `harness/conventions.md` §Adoptierte Konventions-Quellen
als unbewachte Hälfte auch benennt.

**Vorgelegt 3 — der alte Baum ist möglicherweise zu früh gefallen. → Widerlegt, mit Beleg.**
Der Satz der regierenden Fassung ist wortgleich der, den `MR-007` in seinem Pflichtfeld
`Ersetzt-Baseline-Regel` **zitiert und ablöst**:

> An ihre Stelle tritt Setzung 4 unten: **ein Tag zur Zeit**, Historie in `git`, und mehr als ein
> `<tag>`-Verzeichnis ist ein Fehler, den `baseline-verify` und der Injektor erzwingen. Die alte
> Form bleibt damit erreichbar, aber als Tree-Operand statt als zweites Verzeichnis.

Dass es derselbe Satz ist, ist gemessen und nicht angenommen: der zitierte Wortlaut steht
whitespace-normalisiert genau einmal in `v6.5.0` · `regelwerk/modul-02-harness-bootstrap.md`
(`tr '\n' ' ' < … | tr -s ' ' | grep -c '<Zitat>'` → 1). Die Koexistenz ist im Repo zudem nicht
nur unerwünscht, sondern gesperrt: `harness/tools/baseline-verify.sh` bricht bei mehr als einem
`<tag>`-Verzeichnis ab, und der SessionStart-Injektor injiziert dann nichts. Der Fall des alten
Baums im selben Commit ist damit die deklarierte Abweichung, nicht ihr Bruch — und der Ersatz
(`git show <ref>:…`) ist im Eintrag benannt. Der Punkt bleibt für den **Adaptions-Durchgang**
relevant, weil dessen Form-Vergleich jetzt über Tree-Operanden statt über `diff -r` läuft; das
ist eine Methoden-Auflage an jenen Slice, kein Befund gegen diesen.

## Negativbefunde

- geprüft, ohne Befund: **die fünf Pin-Stellen.** `BASELINE_TAG`/`BASELINE_ZIP_SHA256` im
  `Makefile`, das `sources`-Paar in `.d-check.yml`, `DefaultTag`/`DefaultBaselineSHA256` in
  `internal/fetch/baseline.go` tragen alle `v6.5.0` bzw. den Asset-Hash; der alte Hash kommt
  außerhalb der eingefrorenen Bestände nirgends mehr vor
  (`git grep -n 'ed617e382560793ddd805650a7a0e1e421d68d4ff' -- ':!docs/reviews'
  ':!docs/plan/planning/done'` → leer). `test/sources-pin.bats` (Fälle 222/223) und die zwei
  Go-Kopplungstests sind in `make test` grün. Eine sechste Pin-Stelle habe ich nicht gefunden:
  `.github/` und `internal/emit/` führen keinen Tag-Literal.
- geprüft, ohne Befund: **Anker und Links im lebenden Bestand.** Der `docs-check`-Lauf meldet
  ausschließlich `target-missing`, keinen einzigen `anchor-missing` und keinen
  `codepath-missing` — die 13 nachgezogenen Zitat-Anker in `spec/spezifikation.md` lösen im neuen
  Baum auf. Die zwei dort adressierten Module haben im Sprung nur Tabellen-Form geändert
  (`git show 697b7724 -- '*modul-15-observability.md' '*modul-08-agentenrollen.md' | grep -E
  '^[+-][^+-]'` zeigt ausschließlich `|---|` → `| --- |`), die zitierten Sätze sind also
  unberührt.
- geprüft, ohne Befund: **Commit-Zuschnitt.** Tausch und Nachzug liegen getrennt
  ([`AGENTS.md`](../../AGENTS.md) §3.3), und die vier Rollen-Commits berühren je nur Artefakte
  ihrer Rolle: `7e05dca8` nur `harness/conventions.md` + `harness/conventions/`, `3763a755` nur
  `docs/plan/adr/`, `a44b43f2` nur `docs/plan/planning/open/`, `b260839d` nur `internal/emit/` +
  `test/`. Jeder nennt die Rolle in seiner Message.
- geprüft, ohne Befund: **die Klassifikation von `gate.template.md`** (`b260839d`). Der
  Template-Hinweis der neuen Vorlage trägt einen Kopiere-Satz mit Platzhalter im Ziel
  (`harness/sensors/<target>.md`), was `emit.isRecurring` nach seiner eigenen Definition erfüllt;
  der Eintrag steht in der ersten `case`-Liste, die letzte Zeile bleibt für die Mutations-Fälle
  215/216/218 unverändert; die drei Zählungen in `test/courseset-fixture.bats` sind untereinander
  konsistent (11 Singletons + 2 derivative + 10 wiederkehrende in-scope + 1 modus-gebunden = 24),
  und `courseSet()` ist um dieselbe Datei ergänzt. `make test` EXIT 0.
- geprüft, ohne Befund: **`harness/conventions/`** (48 aktive Einträge). Stichprobe über die
  Link-Ziele: `make docs-check` meldet in keinem Eintrag einen Befund, und `conventions/done/`
  trägt keinen Verweis in den Baum. Der Rumpf-Befund gegen `MR-007` (MEDIUM-2) betrifft eine Zahl,
  keinen Verweis.
- geprüft, ohne Befund: **Emissions-Ebene über den Pin hinaus.** `internal/emit/templates/`
  adressiert den Baum durchgängig als `.harness/baseline/<tag>/…`; kein emittiertes Artefakt
  trägt einen Tag-Literal, der mit dem Sprung hätte wandern müssen.
- geprüft, ohne Befund: **die 36 Gate-Befunde als Bestand.** Alle 36 liegen in Artefakten, die
  [`AGENTS.md`](../../AGENTS.md) §3.4 bzw. die Ziel-Fassung als einfrierend führen; keiner liegt
  in einem lebenden Artefakt. Der Träger dafür ist der offene Punkt (MEDIUM-4), die Zuordnung
  nicht.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 4 |
| MEDIUM | 6 |
| LOW | 1 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:** `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` ·
`fremdes-rollen-artefakt-im-implementations-kontext` ·
`vollstaendigkeits-zusage-misst-falsche-ebene` (3×) · `zahl-neben-nie-gefahrenem-kommando` (2×) ·
Präsens-Aussage über den vendored Baum ohne `MR-040`-Ausgang (2×) · Accept-Übergang ohne den
Beleg, den der eigene Trigger nennt · Rotes Gate mit Diagnose, aber ohne angenommenen Träger ·
Adress-Form eines Artefakts weicht von seinen Geschwistern ohne Grund ab · Träger einer
Closure-Pflicht im selben Plan zweimal verschieden benannt · Übergabe nennt eine nicht auflösbare
Vorgangs-Adresse

**Kontext-Eskalation:** `vollstaendigkeits-zusage-misst-falsche-ebene` tritt in diesem Lauf
**dreimal** auf (MEDIUM-1, MEDIUM-2, MEDIUM-3) — drei verschiedene Läufe, drei verschiedene
Artefakte, dieselbe Bauart: eine Vollständigkeits-Zusage über den Nachzug, deren Messung eine
engere Achse trifft als ihr Gegenstand. Nach dem Reviewer-Skill §Kontext-Eskalation ist die
dritte Wiederholung derselben Klasse in einer Sitzung ein **Steering-Loop-Signal**, kein reines
Melden. Der Eintrag steht im Register bei 1 und erreicht mit diesem Slice die Schwelle.

## Verdikt

**Merge-blockierend: ja.** Vier HIGH und sechs MEDIUM.

Der **Kern der Arbeit trägt**: Der Baum ist byte-identisch mit dem Asset, dessen Hash die fünf
Pins nennen; die Provenienz-Lücke aus dem vorigen Sprung ist geschlossen; die
Klassifikations-Kopplung der neuen Vorlage ist rot gesehen und nachgezogen; die Anker der
nachgezogenen Zitate lösen auf; der Commit-Zuschnitt hält die Rollen-Grenzen. Auch die
Zurückstellungen sind überwiegend begründet und einzeln ausgewiesen statt still.

Blockierend ist nicht der Tausch, sondern **was um ihn herum offen geblieben ist**: die
normative Quelle des Vorgangs ist angenommen, ohne dass ihr eigener Trigger belegt wäre (HIGH-1);
das Rang-9-Artefakt, das den adoptierten Stand führt, widerspricht seit dem Tausch dem Baum und
allen fünf Pins (HIGH-2); der Nachzug hat in ein unveränderliches Register-Artefakt geschrieben
(HIGH-3) und in zwei Artefakte fremder Rollen (HIGH-4); und das Mess-Instrument, das die
Vollständigkeit belegen soll, ist an drei Stellen enger als die Zusage (MEDIUM-1/2/3). HIGH-2 ist
zugleich die fällige, offene Architect-Folgepflicht aus ADR-0038 und der dritte Liefer-Punkt des
Slice.

**Übergabe:** HIGH-1 und MEDIUM-4 gehen an den **Architect** (Accept-Übergang, Träger des roten
Gates); HIGH-2 und MEDIUM-6 an den **Architect** als Eigentümer der betroffenen Artefakte;
HIGH-3, HIGH-4, MEDIUM-1, MEDIUM-2, MEDIUM-3 und MEDIUM-5 an den **Implementer**, wobei die
Rückkante bei HIGH-4 zum **Reviewer** bzw. **Planner** als Eigentümern führt; INFO-2 an den
**Planner**. Die Finding-Klassen gehen zusätzlich in die Slice-Closure §7 und von dort in den
Zähler. Dieser Report ist ein **Lauf-Beleg** und ersetzt keine Verifikation — DoD- und
Spec-Konformität prüft der Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer
Eingabe-Kontext).
