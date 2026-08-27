# welle-12-erfassungsschicht-emittieren — Results-Notiz

**Welle:** [welle-12 — Erfassungsschicht emittieren](welle-12-erfassungsschicht-emittieren.md).
**Abschluss-Beleg statt Datum:** alle sechs Slices in `done/`, `make gates` Exit 0, `make mutate`
**179 ok / 0**, `make full-smoke` Exit 0 über beide Bootstrap-Varianten, der Carveout-Audit unten
mit **einem** eingetretenen Trigger, dieser Beleg-Text. Die Zahlen stehen mit ihren Kommandos in
§7; jede wandert mit ihrem Bestand und ist **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Meilenstein M6 fällt mit dieser Welle** — mit **zwei** benannten Grenzen des Belegs, die in §7
stehen und nicht hier.

---

## 1. Geliefert

Ein frisch gebootstrapptes Zielrepo **belegt seine eigenen Läufe**. Es bekommt den Träger, den
Wrapper, den Hook-Eintrag, sechs Rollen-Typen, eine lesbare Feldliste und einen Leser samt
Aufräum-Kommando — oder es legt begründet **nichts** davon ab und bleibt out-of-the-box grün. Der
Gegenstand ist [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren),
der Weg [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md).

- **[slice-094](slice-094-ein-programm-ein-einstiegspunkt.md) — ein Programm, ein Einstiegspunkt.**
  Schreiber und Auswertung sind Unterkommandos des Produkt-Binärs; die zwei getrennten Bau-Stufen
  und ihr Bau-Ziel sind fort, an ihrer Stelle steht `make host-bin`. Der Hook **dieses** Repos ruft
  denselben Einstiegspunkt, den ein Zielrepo später bekommt — die Bedingung, ohne die die Emission
  einen ungefahrenen Pfad ausliefern würde.
- **[slice-095](slice-095-hook-aufschlag-gemessen.md) — der Preis ist gemessen, nicht geschätzt.**
  Median **2,7 bis 2,8 ms** je Tool-Call gegen eine Schwelle von **50 ms**
  ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md)); über alle unabhängigen Läufe
  **2,6 bis 3,6 ms**. Damit ist Annahme (c) der Entscheidung belegt und Alternative F — ein
  **anderer** Träger — nicht herbeigeführt. Die Messung lief **vor** der Emission, weil ihr
  negativer Ausgang den Bauplan gekippt hätte statt ihn zu bestätigen.
- **[slice-096](slice-096-traeger-liegt-im-ziel.md) — der Träger liegt im Ziel, oder begründet
  nichts.** Drei Dinge entstehen zusammen oder gar nicht: das Binär unter `.harness/state/bin/`,
  der committete Wrapper `.claude/hooks/span-emit.sh`, der Hook-Eintrag in
  `.claude/settings.json`. Die Kopplung ist eine Code-Zeile (`captured := captureErr == nil`), kein
  Vorsatz. Scheitert die Ablage, liegt **keines** der drei, der Grund steht auf `stderr`, und der
  Bootstrap endet erfolgreich.
- **[slice-097](slice-097-rollen-typen-gehen-mit.md) — die Rollen-Achse bekommt ihre
  Voraussetzung.** Sechs generische Rollen-Typen unter `.claude/agents/`, je mit ihrem Namen im
  Frontmatter; `skip-if-present` über **eine** Mechanik, nicht über eine zweite Ausfertigung.
- **[slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md) — das Ziel sagt lesbar, was es
  erfasst.** Ein werkzeug-erzeugtes `harness/erfassung-feldliste.md` **im geprüften Doku-Bereich** <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
  des Adopters, ohne eine einzige Kennung und ohne einen Markdown-Verweis, der nur hier auflöst —
  ein toter Link darin färbte das Doku-Gate des Adopters rot, und heilen könnte er ihn nicht. Drei
  Grenzen stehen stehend darin, nicht als Fußnote.
- **[slice-099](slice-099-leser-und-aufraeum-kommando.md) — Leser und Aufräum-Kommando.** Der
  Bericht nennt **zuerst** seine Abdeckung, meldet Leere als Leere, und der Bestand hat ein
  Kommando ohne Automatik. Beides hängt in **keiner** Gate-Kette: ein Gate über einem Bericht wäre
  eines über leerem Prüfbereich.

**Der Umfang, mit seinen Kommandos.** Über die Spanne `de536bc..3f2da7e` (die Welle von ihrer
Aktivierung bis zum letzten Slice-Move): `git rev-list --count de536bc..3f2da7e` → **90** Commits,
`git diff --shortstat de536bc 3f2da7e` → **129** Dateien, **17433** Einfügungen, **1620**
Löschungen. Davon **9** neue Vorlagen unter `internal/emit/templates/`
(`git diff --diff-filter=A --name-only de536bc 3f2da7e -- internal/emit/templates/ | wc -l`) und
**33** neue Mutations-Fälle
(`… -- test/mutations/ | wc -l`) auf heute
`ls -1 test/mutations/*.sh | wc -l` → **179**.

## 2. Was funktionierte

- **Den Preis vor der Emission messen.** [slice-095](slice-095-hook-aufschlag-gemessen.md) stand
  **vor** [slice-096](slice-096-traeger-liegt-im-ziel.md), weil derselbe Messwert nach der Emission
  ein Abriss-Trigger gewesen wäre statt einer Konstruktions-Eingabe. Die Reihenfolge war eine
  Entscheidung des Schnitts, keine Bequemlichkeit — und sie hat sich nicht ausgezahlt, weil die
  Zahl gut war, sondern weil sie überhaupt vorlag, bevor jemand darauf baute.
- **Der Fehlerzweig war Gegenstand des Plans, nicht sein Rand.** Das Welle-Ziel trägt seinen
  Oder-Zweig im ersten Satz. Drei der vier Teilzusagen dieses Zweigs haben ihr Rot gesehen; die
  vierte steht als ausgesprochene Grenze in §7. Eine Welle, die nur den Gelingens-Zweig beschrieben
  hätte, hätte die Hälfte des Vertrags unbewacht gelassen.
- **Schnitt nach Liefergegenstand, nicht nach Schicht.** Sechs Slices, weil sechs Dinge geliefert
  wurden — ein Programm, eine Zahl, ein abgelegtes Binär, ein Satz Textdateien, ein erzeugtes
  Dokument, ein Leser. Ein Schnitt nach `…-emit` / `…-test` / `…-doku` hätte einzeln nutzlose
  Zwischenstände erzeugt; ein einziger Slice hätte alle slice-eigenen DoD-Punkte der sechs getragen
  — `grep -hE '^- \[[ x]\] \*\*\(' docs/plan/planning/done/slice-09[4-9]*.md | wc -l` → **17**,
  mehr als das Fünffache dessen, was Modul 5 §Ziel-Form einem Schnitt zugesteht (≤ 3). Die sechs
  hielten die Grenze einzeln ein: keiner trug mehr als drei.
- **Die Grenze wurde gesagt, wo sie nicht bewacht werden kann.** Kein Wächter über die Aufrufform
  des Agenten-Werkzeugs, keiner über die Rollennamen des Adopters, keiner über die Anwesenheit des
  Trägers in einem frischen Klon. Jede dieser drei Auslassungen steht mit ihrem Grund im
  Welle-Plan §6 und ist im Lauf **nicht** versehentlich mitgeschnitten worden.

## 3. Was anders lief als geplant

- **Der erste Slice wurde blockiert, und der Befund traf eine Hard Rule.** Das Code-Review zu
  [slice-094](slice-094-ein-programm-ein-einstiegspunkt.md) war **blockierend** mit einem HIGH an
  [`AGENTS.md`](../../../../AGENTS.md) §3.3: Umzug und Umschreiben von `span_report.go` lagen in
  demselben Commit, die Ähnlichkeit fiel unter die Rename-Schwelle, und die Herkunft ist über
  `git log --follow` nicht mehr auffindbar. Der Commit war veröffentlicht; repariert wurde die
  **Auffindbarkeit** durch die Adresse in der Closure-Notiz, nicht die Historie durch einen Force-Push.
- **Ein Wächter hatte recht und seine Begründung nicht.** In
  [slice-097](slice-097-rollen-typen-gehen-mit.md) begründete eine neue Fehlermeldung ihren Treffer
  mit einer Aussage über das Zielrepo, die dort nicht gilt. Gefunden hat es kein Gate, sondern der
  Blick auf die Ausgabe eines absichtlich roten Laufs. Daraus wurde der Steering-Loop-Eintrag jenes
  Tages — und [slice-099](slice-099-leser-und-aufraeum-kommando.md) hat ihn zwei Tage später
  gemessen **geweitet**: von drei Begründungs-Befunden jenes Laufs lag nur **einer** im roten Pfad.
- **Eine Zusage des Plans blieb konstruktiv statt gefahren.** *„`make gates` des Ziels ist grün"*
  im **Fehlerzweig** ist in [slice-096](slice-096-traeger-liegt-im-ziel.md) argumentiert, nicht
  gelaufen: im Fehlerzweig ist das Ziel dateigleich mit einem Ziel vor dieser Welle. Die drei
  Prämissen sind einzeln geprüft, das Argument trägt — ein **Lauf** ist es nicht, und es steht als
  Grenze da statt als Messung.
- **Ein Mutations-Fall lief einzeln statt im Verbund.** Der 165. Fall aus
  [slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md) wurde auf einer Kopie gefahren, mit
  ausgeschriebener Begründung, welche Treiber-Bedingung das deckt und welche offenblieb. Der volle
  Lauf war an dieser Closure fällig und ist gefahren (§7).
- **Die Welle hat mehr Slices erzeugt als sie enthielt.** Elf neue `open/`-Einträge über die Spanne
  (`git diff --diff-filter=A --name-only de536bc 3f2da7e -- docs/plan/planning/open/ | wc -l` →
  **11**) gegen sechs Mitglieder. Das ist kein Fehler des Schnitts — es ist die Bilanz in §5, und
  sie gehört gelesen, bevor jemand die Welle als abgeräumt liest.

## 4. Steering-Loop-Einträge

Sechs Slices, sechs Einträge — **fünf geschärfte Regeln, ein neuer Sensor**. Sie stehen einzeln in
den Slice-Notizen; hier steht, was sie **als Reihe** zeigen, und der eigene Eintrag dieser Closure.

- **Das Muster der Welle: alle sechs Einträge handeln vom Beleg, nicht vom Gebauten.** Wer trägt
  einen Rot-Beleg ([slice-094](slice-094-ein-programm-ein-einstiegspunkt.md): *ein Rot-Kommando
  deckt die Zusage, an der es steht — oder die Hälfte, die es nicht erreicht, wird ausgesprochen*) ·
  wie belegt man, wo es **kein** Rot geben kann ([slice-095](slice-095-hook-aufschlag-gemessen.md):
  *wo der Gegenstand eine Zahl ist, tritt an die Stelle des Gegenbeispiels die Frage nach der
  **Richtung**, welche Vereinfachung die Zahl auf die stützende Seite verschöbe*) · wo der Beleg
  **mechanisch** prüfbar wäre ([slice-096](slice-096-traeger-liegt-im-ziel.md), der einzige
  Sensor-Eintrag: *nennt ein Kommentar einen Mutations-Fall, muss dessen `# expect:`-Kopf die
  Funktion nennen, über der der Kommentar steht*) · und dreimal: was ein Wächter **sagt**
  ([slice-097](slice-097-rollen-typen-gehen-mit.md): *der Begründungstext wird nur im Rot gelesen* ·
  [slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md): *ein Kopplungs-Kommentar ist eine
  stehende Anweisung an den, der die Menge erweitert — kein Gate stellt ihn zu* ·
  [slice-099](slice-099-leser-und-aufraeum-kommando.md): *ein Wächter über der **Anwesenheit** einer
  Begründung belegt die Zeichenkette, nicht die Ursache*). **Sechs von sechs betreffen die
  Sichtbarkeit eines Textes, den ein grüner Lauf nie liest.** Das ist kein Zufall dieser Welle: sie
  hat zum ersten Mal Text **in ein fremdes Repo** geschrieben, und dort liest ihn niemand von uns.
- **Der Ausgang der sechs ist gebündelt, nicht verstreut.** Fünf der neun Postens in
  [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) stammen aus dieser Welle
  (`grep -coE '^\*\*Und ein (fünfter|sechster|siebter|achter|neunter)' docs/plan/planning/open/slice-101-norm-postens-bekommen-einen-termin.md`
  → **5**). Damit hat diese Welle die Lehre aus
  [„Lehre braucht Träger"](slice-100-vorlauf-nennt-den-grund.md) selbst angewandt: eine Regel ohne
  Träger ist ein Satz, den der Prozess nie wieder liest.
- **Der eigene Eintrag dieser Closure — geschärfte Regel: ein Audit fragt über den Bestand, den
  seine Bedingung nennt, nicht über die Neuzugänge der Welle, die ihn führt.** Der Auflösungs-Trigger
  von [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) lautet *„sobald **eine einzelne**
  `.bats`-Datei eigene Hilfsfunktionen mit Verzweigung oder Schleifen trägt"* — eine Aussage über
  den **Bestand**. Drei aufeinanderfolgende Audits haben stattdessen gefragt, was **ihre Welle**
  hinzugefügt hat. Der gemessene Schaden: der Trigger ist am **2026-07-25 17:17:58** eingetreten
  (`git log --diff-filter=A --format='%h %ad' --date=iso -- test/release-matrix.bats | tail -1`),
  der Audit vom **2026-07-27 13:24:04** (`git log -1 --format=%ad --date=iso 392093f`) hat ihn
  übersehen, und die auslösende Datei kam aus einem **wellenlosen** Slice — sie fällt durch jede
  Wellen-Frage hindurch. **Warum das eine Regel ist und keine Ermahnung:** die Welle-Frage ist
  billiger (ein `git diff` gegen den Wellen-Anfang), die Bestands-Frage braucht einen Sensor über
  die Eigenschaft. Wer die billige Frage stellt, bekommt bei wellenloser Arbeit systematisch das
  falsche Nein. **Träger:** [slice-113](../open/slice-113-co-001-ist-faellig.md) fährt die Auflösung
  und trägt den Sensor-Text; die Regel selbst hat keinen Wächter — sie liegt im
  Feedforward-Quadranten und ist hier benannt, nicht geschlossen.
- **Und eine benannte Spec-Lücke: Modul 6 Schritt 1 nennt einen Sensor, den dieses Repo nicht hat.**
  *„Alle Slices der Welle liegen in `done/`, `make gates` und der Replay-Lauf sind grün."* Gemessen
  über fünf Achsen gibt es hier keinen Replay-Lauf — kein `make`-Ziel, kein `evals/`-Layout, kein
  Modul-12-Vokabular außerhalb des vendored Baums, keine der acht bisherigen Closure-Notizen und
  keine Welle-Plan-Datei nennt ihn (Kommandos in
  [slice-112](../open/slice-112-replay-schritt-hat-keinen-referenten.md) §1). Getragen wird der
  Schritt hier von den Sensoren, die [`harness/README.md`](../../../../harness/README.md)
  §Nicht-Gate-Verify ausdrücklich der **Wellen-Closure** zuweist — `make full-smoke` und
  `make mutate` neben `make gates` — plus den welle-eigenen Kriterien aus §3 der Plan-Datei. Diese
  Fassung wird gelebt, ist in **zwei** Anleitungen geschrieben und **eine davon wird emittiert** —
  und sie ist im Adaptions-Block nirgends deklariert. **Träger:**
  [slice-112](../open/slice-112-replay-schritt-hat-keinen-referenten.md); der Text gehört dem
  Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
  [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1), diese Closure
  liefert die Messung und den Termin.

## 5. Was die Welle nicht geliefert hat

Eine Bilanz, die nur Erfolge führt, ist ein Werbetext. Die Welle hat ihre
`sed -n '/^### .* — Erfassungsschicht emittieren$/,/^## 4\./p' spec/lastenheft.md | grep -c '^- \*\*'`
→ **10** Akzeptanzkriterien erfüllt und dabei **elf** neue `open/`-Slices und **fünf** Postens in
einem bestehenden erzeugt. Was offen bleibt, in Klassen statt als Liste:

- **Wächter ohne Fall — die größte Klasse.** Acht der fünfzehn neuen Go-Wächter aus
  [slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md) haben keinen `test/mutations/`-Fall
  (dort gemessen); vier davon hat erst die Verifikation rot gesehen, vier keiner. Dazu die
  Träger-Abwesenheit im Fehlerzweig und die sha256-Identität aus
  [slice-096](slice-096-traeger-liegt-im-ziel.md), der neue `full-smoke`-Wächter aus
  [slice-097](slice-097-rollen-typen-gehen-mit.md) (streicht man eine Rolle aus seiner Schleife,
  bleibt jeder Sensor grün) und die Befund-Reihe aus
  [slice-099](slice-099-leser-und-aufraeum-kommando.md), deren Delta-Tabelle
  `grep -c 'slice-110-erfassungs-waechter-fall-meldung-grenze' docs/plan/planning/done/slice-099-leser-und-aufraeum-kommando.md`
  → **8** Nennungen an einen einzigen Träger reicht. Nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 gilt: wer keinen Fall hat, ist unbewacht. Träger:
  [slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md),
  [slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md),
  [slice-108](../open/slice-108-feldlisten-waechter-tragen-ihren-fall.md),
  [slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md).
- **Texte, die mehr sagen als sie halten — im emittierten Produkt.** Die Feldliste behauptet
  Lesbarkeit für *„wer dieses Arbeitsverzeichnis lesen kann"* gegen gemessene Rechte; ihre
  Ortszusage gilt der emittierten `.d-check.yml` und wird von einer eigenen Adopter-Config
  aufgehoben, ohne dass das Dokument es sagt; `span.SchemaNotes()` ist eine zweite, von Hand
  gepflegte Ausfertigung dessen, was
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  schon trägt. Träger: [slice-109](../open/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md).
- **Eine Entscheidung, die der Code nicht kennt.** Die geschriebene Span-Zeile trägt `sha256_16`,
  während [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 6 *„ohne Inhalts-Hash"* sagt. ADRs sind ab *Accepted* immutabel
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4) — die Korrektur ist eine **neue** Entscheidung und
  gehört dem Architect. Träger:
  [slice-107](../open/slice-107-inhalts-hash-traegt-eine-entscheidung.md).
- **Vier Produktions-Fundorte für sechs Rollen-Namen, und der vierte geht als erster ins Ziel.**
  Die Kopplung, die [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 3 *„benannt, nicht geschlossen"* lässt, ist von dieser Welle **vergrößert** worden,
  nicht geschlossen. Träger: [slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md).
- **Der eigene Messwert der Welle nennt seine Grenzen nur zur Hälfte.** Der Kopf des Mess-Skripts
  führt zwei von drei Grenzen, seine Median-Spanne ist enger als seine eigenen Bedingungen
  hergeben, und kein Artefakt nennt einen Anlass, die Messung erneut zu fahren. Träger:
  [slice-102](../open/slice-102-messung-nennt-grenzen-und-anlass.md).
- **Das Werkzeug, das die Belege liefert, ist teurer geworden — an dieser Closure gemessen.**
  `make mutate` fuhr mitten in der Welle **157** Fälle in **1166** Sekunden (Messung der
  [slice-097-Verifikation](../../../reviews/2026-08-25-slice-097-verify.md) §1.1, fremdbelegt) und
  schließt sie mit **179** Fällen in **1306,92** Sekunden ab
  (`/usr/bin/time -f 'MUTATE_SECONDS=%e' make mutate`, eigener Lauf dieser Closure). Je Fall sind
  das **7,30** statt **7,43** Sekunden
  (`awk 'BEGIN{printf "%.2f %.2f\n", 1166/157, 1306.92/179}'`) — die Zeit wächst mit der
  Fall-Zahl, nicht je Fall, und **das** ist der Befund: 22 Fälle mehr kosten gut zwei Minuten mehr,
  und die Welle hat **33** hinzugefügt
  (`git diff --diff-filter=A --name-only de536bc 3f2da7e -- test/mutations/ | wc -l`). Dazu wirft
  der Grün-Vorlauf sein Protokoll bei Erfolg weg; ein
  grüner Lauf belegt also nicht, dass die neuen Zähne im `full-smoke` gelaufen sind. Träger:
  [slice-105](../in-progress/slice-105-mutate-messen-dann-teilen.md) — **erst messen, dann teilen** — und
  [slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md) für das Rot der CI, das heute
  keinen Ausgang trägt.
- **Fünf Norm-Postens ohne Termin, aus dieser Welle.** Sie liegen in
  [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) (§4). Sie sind **nicht**
  geliefert; geliefert ist, dass sie einen Ort haben, an dem der nächste Lauf sie findet.
- **Und eine Schuld an [welle-09](../welle-09-modul-15-konformitaet.md), die der Plan vorab benannt
  hat.** Diese Welle legt ein Init-invariantes Gate-Fragment und neue emittierte `make`-Ziele ab;
  nach [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 4 gehören sie in den `targets:`-Satz aus
  [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4. Der Satz existiert nicht
  (`grep -c 'targets' .d-check.yml` → **0**); wer ihn baut, wendet das Kriterium auf den dann
  vorliegenden Bestand an und findet die neuen Ziele von selbst.

**Was ausdrücklich kein Rückstand ist:** die Grenzen aus §6 der Plan-Datei — kein
Anwesenheits-Wächter im Ziel, keine Verdrahtung der Auswertung, keine Rotation, keine Token-Bilanz
im Ziel, kein Wächter über die Aufrufform. Sie sind entschieden, nicht vergessen, und ihr Grund
steht dort.

## 6. Carveout-Audit (Modul 7, Schritt 2)

Gelesen wurde der `Status:`-Kopf, nicht das Verzeichnis
(`grep -h '^\*\*Status:' docs/plan/carveouts/CO-*.md | wc -l` → **2**, bei
`ls -1 docs/plan/carveouts/CO-*.md | wc -l` → **2** Dateien; kein Carveout ohne Kopf).

| Carveout | Status | Ergebnis dieses Audits |
|---|---|---|
| [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) — `shell-lint` deckt die bats-Dateien nicht ab | Aktiv | **Auflösungs-Trigger EINGETRETEN.** Siehe unten. `Letzte Prüfung` nachgetragen, Folge-Slice eingetragen, die Zahl im Geltungsbereich an ihr Kommando gesetzt |
| [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) — der `Agent`-Span trägt keine Token-Achse je Rolle | Permanent — übergeführt in [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) | **Keine Aktion.** Modul 7 §Carveout-Audit-Slice bindet nur *aktive* Carveouts; ein permanenter ist über seine ADR entschieden, nicht über ein Prüfdatum. Diese Welle hat seinen Geltungsbereich nicht berührt |

**Neue Carveouts aus dieser Welle: keine.**
`git diff --diff-filter=A --name-only de536bc 3f2da7e -- docs/plan/carveouts/ | wc -l` → **0**.

**`CO-001`: der Trigger ist eingetreten, und der vorige Audit hat ihn übersehen.** Der Trigger
fragt über den **Bestand** — *„sobald eine einzelne `.bats`-Datei eigene Hilfsfunktionen mit
Verzweigung oder Schleifen trägt"*. Gemessen über alle `git ls-files 'test/*.bats' | wc -l` → **16**
Dateien mit einem awk-Sensor, der Verzweigungs-Zeilen im Rumpf einer **benannten Funktion** von
denen in einem `@test`-Rumpf trennt (Programm-Text in
[slice-113](../open/slice-113-co-001-ist-faellig.md) §1): **zwei** Zeilen, beide in
`test/release-matrix.bats`, Funktion `lh_platforms()`, Zeilen 47 und 51 — zwei verschachtelte
`for`-Schleifen über zwei aus dem Lastenheft gelesene Mengen. Untergrenze, mit Absicht: zwei
`[ … ] || return 1`-Wächter derselben Funktion sind Steuerfluss ohne Schlüsselwort und fallen durch
das Muster.

**Was welle-12 selbst dazu beigetragen hat: nichts.** Ihre einzige neue `.bats`-Datei ist
`test/span-emit-wrapper.bats` mit
`grep -cE '^\s*(if|for|while|case) ' test/span-emit-wrapper.bats` → **0**. Die auslösende Datei
kam aus **slice-048**, wellenlos, am 2026-07-25 — acht Stunden **nach** dem welle-07-Audit und
zwei Tage **vor** dem welle-08-Audit, der sie hätte sehen müssen.

**Der Ausgang, und warum er nicht *aufgelöst* heißt.** Modul 7 kennt drei Übergänge; *aufgelöst*
verlangt `git mv` **plus** entfernte Gate-Ausnahme **plus** `make gates` grün ohne sie. Diese
Closure liefert keinen Produktionscode. Der ehrliche Zustand ist damit: **Trigger eingetreten,
Auflösung fällig, Folge-Slice geschnitten** —
[slice-113](../open/slice-113-co-001-ist-faellig.md), eingetragen im `Folge-Slice`-Feld, das bis
heute *„noch keiner angelegt"* trug. Genau davor warnt Modul 7 §Fehlannahmen: *„Wenn der Trigger
eintritt, lösen wir den Carveout auf — Realität: er bleibt liegen. Deshalb braucht jeder temporäre
Carveout einen Folge-Slice mit ID."*

**Ein dritter Befund am selben Carveout, hier benannt statt nebenan vergessen.** Seine
§Geltungs-Konfiguration sagt zu, das `shell-lint`-Rezept trage den *„Verweis ‚CO-001'"*. Gemessen:
`grep -c 'CO-001' Makefile` → **0** (Exit 1), und
`git grep -c 'CO-00' -- Makefile .d-check.yml d-check.mk .github/` findet in **keiner**
Gate-Konfiguration eine Carveout-Kennung (Exit 1). Modul 7 §Ziel-Form verlangt sie — *„sonst ist
die Pfad-Ausnahme im `make gates`-Output eine stille Senkung ohne Begründung"*. Der Nachtrag ist
kein Doku-Zug, sondern eine Änderung am `Makefile`, und er hängt am selben Ausgang wie die
Auflösung: [slice-113](../open/slice-113-co-001-ist-faellig.md) DoD (3) bindet beide Äste.

## 7. Verifikation (die Belege aus Schritt 1)

| Beleg | Ergebnis |
|---|---|
| Alle sechs Slices in `done/` | `ls -1 docs/plan/planning/done/slice-09[4-9]*.md \| wc -l` → **6**; `ls -1 docs/plan/planning/in-progress/` → nur `roadmap.md` |
| `make gates` | Exit 0 — `baseline-verify: v3.5.2 OK — 42 Dateien`, `d-check: 406 Datei(en) geprüft, 0 Befund(e)`, golangci-lint `0 issues.`, bats `grep -c '^ok '` → **153** und `grep -c '^not ok'` → **0**, `comment-claims: 45 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün; danach sind `bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha` byte-gleich |
| `make mutate` | **179 ok, 0 Befund(e)** in **1306,92 s** (`/usr/bin/time -f 'MUTATE_SECONDS=%e' make mutate`) — der volle Lauf, den [slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md) §5 der Wellen-Closure zugewiesen hatte. Sein Grün-Vorlauf fährt `make test`, `ci-lint`, `full-smoke`, `smoke`, `test-bats`, `test-go` je einmal grün, **bevor** die erste Mutation greift |
| `make full-smoke` | Exit 0 in **94,57 s**; `grep -c 'full-smoke: FEHLER' <log>` → **0** |
| Welle-eigenes Kriterium: Gelingens-Zweig | `grep -c 'Traeger + Wrapper + Hook-Eintrag liegen im Ziel' <full-smoke-log>` → **2**, je einmal `--lang go` und sprachlos; ebenso zweimal *„Leser + Aufraeum-Kommando im Ziel"*, *„ROLLEN-TYPEN"* und *„FELDLISTE"*. Die Feldliste liegt im **geprüften** Doku-Bereich — ein toter Verweis darin färbt das `docs-check` des Ziels rot (im Lauf rot gesehen, danach zurückgenommen) |
| Welle-eigenes Kriterium: Fehlerzweig | rot gesehen unter `test/mutations/155` und `156`: kein Hook-Eintrag, kein Wrapper, Grund auf `stderr`, Bootstrap endet erfolgreich. **Benannte Grenze:** *„und `make gates` des Ziels ist grün"* ist konstruktiv belegt, nicht gelaufen ([slice-096](slice-096-traeger-liegt-im-ziel.md)) |
| Welle-eigenes Kriterium: Trennungs-Trigger scharf | Median **2,7 bis 2,8 ms** gegen **50 ms**; der schlechteste gesehene Median liegt um Faktor **13,9** darunter (`awk 'BEGIN{printf "%.3f\n", 50/3.6}'`) |
| Carveout-Audit | §6 — **einer** von zwei Carveouts mit eingetretenem Trigger, Folge-Slice geschnitten; **keine** neuen aus dieser Welle |
| Closure-Notiz mit Steering-Loop-Eintrag | diese Notiz, §4 |
| **Replay-Lauf grün** (Modul 6 Schritt 1) | **Nicht erhoben — es gibt ihn hier nicht.** Gemessen über fünf Achsen (§4, Kommandos in [slice-112](../open/slice-112-replay-schritt-hat-keinen-referenten.md) §1). Getragen wird der Schritt von `make gates` · `make full-smoke` · `make mutate` plus den welle-eigenen Kriterien; deklariert ist diese Fassung nirgends, und genau das ist der Gegenstand von [slice-112](../open/slice-112-replay-schritt-hat-keinen-referenten.md) |

**Der erste `make gates`-Lauf dieser Closure war rot**, und das gehört genannt: `d-check` meldete
**zwei** `codepath-missing`-Befunde. Der erste galt der Feldliste des **Zielrepos**, die in diesem <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
Repo keinen Pfad hat; der zweite dem Carveout-`done/`-Verzeichnis, das erst bei der ersten <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
Auflösung entsteht. Beide sind dieselbe Klasse, die
[slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md) und
[slice-099](slice-099-leser-und-aufraeum-kommando.md) schon getroffen hat; die Meldung war in
beiden Fällen zutreffend, und `d-check:ignore`-Marken mit ihrem Grund haben sie geschlossen —
**einmal an der Fundstelle, einmal an dieser Zeile**, weil eine Fehler-Beschreibung denselben Pfad
noch einmal nennt und damit denselben Befund erzeugt. Die Dateizahl des Doku-Gates wandert
mit dem Markdown-Bestand und ist **kein** Erwartungswert.

**Die Wanduhr von `make gates` steht hier nicht als Zahl**, und das ist kein Auslassen: sie
schwankt zwischen zwei Läufen desselben Baums mit dem Docker-Cache, und ein abgedruckter Wert
verschöbe zugleich den Stempel über genau dem Baum, den er beschreibt. Wer sie will, fährt
`/usr/bin/time -f 'SECONDS=%e' make gates`. Bei `make mutate` und `make full-smoke` steht sie
oben, weil sie dort **der Gegenstand** eines offenen Slice ist und nicht das Umfeld eines Stempels.

**Meilenstein M6 — erreicht, mit zwei benannten Grenzen des Belegs.** Ein Meilenstein, dessen
Grenzen niemand nennt, wirkt beim nächsten Lesen breiter als er ist; deshalb stehen sie hier und
nicht nur im Kopf dieser Notiz.

- **(a) Die Rollen-Achse ist in ihrer Voraussetzung belegt, nicht in ihrer Besetzung.** Der
  M6-Trigger verlangt, dass ein frisch gebootstrapptes Ziel *„bei einem Werkzeug-Aufruf einen Span
  mit besetzter Rollen-Achse"* schreibt. Gemessen ist im `full-smoke` das **Schreiben** des Spans
  mit voller Pflicht-Spalte und die **Voraussetzung** der Achse — sechs Rollen-Typen, je mit ihrem
  Namen im Frontmatter, den die Erfassung als Vertrag liest. **Nicht** gemessen ist die Besetzung
  selbst: sie geschieht, wenn im Ziel ein Agent **unter** einem dieser Typen läuft, und kein
  Voll-E2E-Smoke startet einen Agenten. Der Sensor sagt es über sich selbst
  (`sed -n '39,42p' harness/tools/full-smoke.sh`).
- **(b) Der Fehlerzweig ist zu drei Vierteln gemessen und zu einem Viertel argumentiert.** Die
  Teilzusage *„und `make gates` des Ziels ist grün"* ist in
  [slice-096](slice-096-traeger-liegt-im-ziel.md) konstruktiv belegt, nicht gelaufen; die drei
  Prämissen sind einzeln geprüft, ein **Lauf** ist es nicht.

Beide Grenzen betreffen den **Beleg**, nicht die Sache — und beide sind an ihrer Stelle
ausgesprochen, statt in einer Erfolgsmeldung zu verschwinden.

## 8. Folge-Slices

**Elf aus der Welle, zwei aus dieser Closure.** Die elf entstanden zwischen ihrer Aktivierung und
dem letzten Slice-Move
(`git diff --diff-filter=A --name-only de536bc 3f2da7e -- docs/plan/planning/open/ | wc -l` →
**11**), alle wellenlos nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 und darum **nicht** in der Roadmap (Setzung 2):

| Slice | Gegenstand |
|---|---|
| [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) | die offenen Norm-Postens bekommen einen Termin — fünf der neun kommen aus dieser Welle |
| [slice-102](../open/slice-102-messung-nennt-grenzen-und-anlass.md) | die Messung nennt ihre Grenzen und ihren Anlass |
| [slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md) | die Träger-Wächter decken, was sie sagen |
| [slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md) | die Rollen-Namen haben eine Quelle statt vier Fundorte |
| [slice-105](../in-progress/slice-105-mutate-messen-dann-teilen.md) | `make mutate` wird erst gemessen, dann geteilt |
| [slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md) | jedes Rot der CI trägt einen Ausgang |
| [slice-107](../open/slice-107-inhalts-hash-traegt-eine-entscheidung.md) | der Inhalts-Hash bekommt seine Entscheidung |
| [slice-108](../open/slice-108-feldlisten-waechter-tragen-ihren-fall.md) | die Feldlisten-Wächter tragen ihren Fall oder ihre Grenze |
| [slice-109](../open/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md) | jede Aussage der Feldliste hat ihre Quelle |
| [slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md) | die Wächter der Erfassungs-Ausgabe tragen Fall, Meldung und Grenze |
| [slice-111](../open/slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md) | was ein Bootstrap anlegt, steht in der Nutzer-Doku |

Aus **dieser Closure** kommen zwei:

- [slice-112](../open/slice-112-replay-schritt-hat-keinen-referenten.md) — Modul 6 Schritt 1 nennt
  einen Sensor, den dieses Repo nicht hat; die gelebte Fassung bekommt ihren Ort. Der Adaptions-Text
  gehört dem Architect; der Slice liefert Messung und Termin.
- [slice-113](../open/slice-113-co-001-ist-faellig.md) — der Auflösungs-Trigger von
  [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) ist eingetreten; `shell-lint` erreicht die
  bats-Rümpfe, oder der Carveout wird mit gemessenem Grund neu gefasst.

**Nicht geschnitten, und das ist eine Entscheidung:** die Frage, ob **weitere** vendored Module
adoptiert-aber-nicht-umgesetzt sind. Modul 15 war der erste gemessene Fall
([welle-09](../welle-09-modul-15-konformitaet.md), 2026-07-28), Modul 12 ist der zweite. Zwei
Instanzen derselben Klasse sind in diesem Repo der Anlass, den Gegenstand zu benennen — sie sind
**nicht** der Anlass, eine Inventur über fünfzehn weitere Module in eine Closure zu hängen. Der
Befund steht in [slice-112](../open/slice-112-replay-schritt-hat-keinen-referenten.md) §1, und §6
jenes Slice führt die Rückführung, falls sein Lauf sich in die Inventur ausdehnt; wer sie schneidet,
schneidet sie mit eigener Abwägung.
