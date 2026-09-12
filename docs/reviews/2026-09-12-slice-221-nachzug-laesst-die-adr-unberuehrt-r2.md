# Review slice-221 — Runde 2: Der Verweis-Nachzug lässt die `Accepted`-ADR unberührt

**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Runde:** 2 (frischer Kontext, Runde 1 als
Eingang gelesen, kein Befund ungeprüft übernommen) · **Commit:** `67a1784b` (5 Dateien,
+103/−4), Kontext `3fb64279` · **Plan:** `slice-221` (Kennung statt Pfad,
[`AGENTS.md`](../../AGENTS.md) §3.11) · **Runde 1:**
`docs/reviews/2026-09-12-slice-221-nachzug-laesst-die-adr-unberuehrt.md` (1 HIGH · 1 MEDIUM ·
1 LOW, blockierend) · **Constraint:**
[`ADR-0042`](../plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2/5,
Folgepflicht 1 · [`ADR-0033`](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
Abnahme-Kriterium 1 · **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.4, §3.6, §3.7, §3.9 ·
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Alle Zahlen unten stehen neben dem Kommando, das sie liefert; keine ist ein Erwartungswert.**
Was ich **nicht** geprüft habe, steht am Ende in einem eigenen Abschnitt.

## Ausgang der Runde-1-Befunde

| Runde 1 | Stand nach `67a1784b` | belegt durch |
|---|---|---|
| HIGH-1 — Trennung der zwei Suchräume ohne Wächter | **geschlossen** | 5 eigene Mutationen an 5 Stellen der Trennung, alle rot am neuen Test |
| MEDIUM-1 — Shell-Zahn misst die Funktion; Ersatz-Beleg deckt die neue Hälfte nicht | **halb geschlossen** | zweite Hälfte belegt und von mir nachgestellt; die Verdrahtung bleibt unbewacht → MEDIUM-1 unten |
| LOW-1 — Punkt 6 erzählt den Übergang | **geschlossen** | `harness/sensors/archive-welle.md` Punkt 6 steht im Indikativ Präsens über den Zustand |

## Findings

### MEDIUM-1 — Die Verdrahtung des Shell-Trägers bleibt unbewacht, und die Begründung ihrer Unbewachtbarkeit misst ein Bild statt des Werkzeugkastens

`quelle` [`ADR-0042`](../plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
Folgepflicht 1 (*„beide brauchen `docs/plan/adr/` daneben, **samt Test**"*),
[`AGENTS.md`](../../AGENTS.md) §3.6 · `pfad` `harness/tools/slice-mv.sh:243`
(Kopf-Block *ZWEITE MESSUNG*, Zeilen 62–74) · `verifizierbar` ja · `klasse` Verdrahtung
unbewacht, und die Unbewachtbarkeits-Aussage misst ein Bild statt des Werkzeugkastens

`befund` Ersetzt man in `main()` die gelesene Liste durch eine harte Pathspec **ohne** den
ADR-Ausschluss — `-- ':!.harness/baseline'` statt `-- "${in_pathspec[@]}"` —, bleibt der
Gate-Satz grün: `make test-bats` EXIT 0 mit `1..272`, **272** Zeilen `^ok ` und **0** Zeilen
`^not ok`, `make shell-lint` ohne Ausgabe, `make comment-claims` → *„58 Datei(en) geprueft, 0
Befund(e)"*. Der bats-Fall (`test/slice-mv.bats:116`) und `test/mutations/313-…` prüfen weiter
die reine Liste, nicht ihre Benutzung; die Zusage aus Festlegung 2 hängt für diesen Träger
allein am Prosa-Beleg im Skriptkopf. Die dafür gegebene Begründung — das gepinnte `BATS_IMAGE`
führe kein `git` — ist wahr (`docker run --rm --network none --entrypoint sh $(BATS_IMAGE) -c
'command -v git'` → *„KEIN git im PATH"*), trägt aber nur über bats: In diesem Repo laufen
bereits **zwei** andere Träger gegen ein echtes `git`-Repo, beide mutations-adressiert —
`cmd/ai-harness-init/archive_welle_echt_test.go` startet `git` als Prozess **innerhalb von
`make test-go`** (`grep -n 'Skip\|LookPath'` auf die Datei → leer, also kein Übersprung; die
Fälle `test/mutations/249`–`252` hängen daran), und `harness/tools/full-smoke.sh` ruft **4**
Mal `git init -q` (`grep -c 'git init -q' harness/tools/full-smoke.sh`) für **8** Fälle mit
`# verify: full-smoke` (`grep -lE '^# verify: full-smoke' test/mutations/*.sh | wc -l`). Die
Entscheidung ist damit gegen eine Optionsmenge gefallen, die zwei im Repo laufende
Träger-Klassen nicht enthielt.

### LOW-1 — Der neue Mutations-Fall adressiert als einziger per Zeilennummer, und die Adresse ist in diesem Slice schon einmal um 12 Zeilen gewandert

`quelle` Maintainability (latente Wartungsfalle, hart verdrahteter Wert) · `pfad`
`test/mutations/314-archive-welle-go-haenger-nachzug-suchraum.sh:15` · `verifizierbar` ja ·
`klasse` Mutations-Fall an Zeilennummer statt an Muster verankert

`befund` `sed -i '180s/Suchraum(/SuchraumNachzug(/'` ist der einzige Fall von **300**, der eine
Zeilennummer trägt (`grep -lE "sed -i '[0-9]+s" test/mutations/*.sh` → eine Datei,
`ls test/mutations/*.sh | wc -l` → 300), obwohl ein eindeutiger Anker in derselben Datei
vorliegt (`grep -c 'range Suchraum(dateien)' internal/archive/scan.go` → **1**). Wie
beweglich die Adresse ist, zeigt dieser Slice selbst: Runde 1 traf dieselbe Code-Zeile noch
mit `sed -i '168s/…'`; die **12** Kommentarzeilen der Nacharbeit haben sie auf 180 geschoben.
Fail-closed bleibt der Fall in beiden Verschiebungs-Richtungen — gemessen an einer Kopie
außerhalb des Baums: eine Verschiebung um 1 Zeile macht das `sed` zum No-op (Inhalt
unverändert → Bedingung 2 des Treibers, *„Mutation hat nicht gegriffen … Patch veraltet?"*),
eine Verschiebung um genau 12 Zeilen trifft die Kommentarzeile
`// SUCHRAUM: hier steht Suchraum(dateien), NICHT …` und lässt den Code unberührt (Bedingung 3,
*„make test-go blieb GRUEN — … hat keine Zaehne mehr"*). Der zweite Ausgang meldet also rot mit
einem Grund, der auf diesen Treffer nicht zutrifft: nicht der Wächter hat Zähne verloren,
sondern der Patch ist veraltet.

### LOW-2 — Der neue Kopf-Beleg nennt eine Fixture, die das Repo nicht führt, und ein Kommando mit Platzhalter

`quelle` [`AGENTS.md`](../../AGENTS.md) §3.7 · `pfad` `harness/tools/slice-mv.sh:62–74` ·
`verifizierbar` nein · `klasse` Kommentar trägt das Protokoll eines Laufs ohne Weg, ihn zu
wiederholen

`befund` Der Block *ZWEITE MESSUNG* führt zwei Ergebnisse (*„eingehend: 1 Datei(en)"* /
*„eingehend: 2 Datei(en)"*) über einer Fixture, die außerhalb des Repos lag, und nennt als
Kommando `make slice-mv SLICE=<probe> TO=next` mit Platzhalter. Der BELEG-Block direkt darüber
setzt den Maßstab, den dieser verfehlt: Er endet mit *„Reproduzierbar auf jedem sauberen
Checkout mit `make slice-mv SLICE=slice-069 TO=next`"*, und `slice-069` liegt im Baum
(`ls docs/plan/planning/*/slice-069-*.md` → eine Datei in `open/`). Inhaltlich hält der neue
Block: Ich habe ihn aus seiner Beschreibung in einem Scratch-Repo mit vier Dateien nachgebaut
und beide Hälften exakt reproduziert (Belege unten). Wiederholbar ist er dennoch nur, wer die
Fixture erneut ableitet.

### LOW-3 — Der neue Test-Kommentar beschreibt den Vorgang, der die Stelle erzeugt hat

`quelle` [`AGENTS.md`](../../AGENTS.md) §3.7 · `pfad` `internal/archive/scan_test.go:154` ·
`verifizierbar` nein · `klasse` Kommentar nennt seine Herkunft als Erzählung statt als
auflösbares Feld

`befund` *„haelt die Trennung, fuer die dieser Slice existiert"* nennt den Vorgang, aus dem die
Stelle hervorging, und zwar ohne auflösbaren Anker: „dieser Slice" trägt keine Kennung und
zeigt nach der Closure auf nichts. §3.7 lässt Herkunft als **ein** auflösbares Feld zu
(`· seit slice-<NNN>`) und sonst nicht. Der Rest desselben Kommentars ist regelkonform — er
nennt Eigenschaft, Sensor und Gegenbeispiel im Indikativ.

## Was ich real rot bzw. grün gesehen habe

**Die Zusage des neuen Wächters, an fünf Stellen der Trennung geprüft — nicht nur an der einen,
die der Mutations-Fall anfasst.** Ausgangspunkt: `make test-go` auf sauberem Baum → **8**
Pakete `ok`. Danach je eine Mutation, `make test-go`, `git checkout --` zurück:

| # | Mutation (Kommando) | Ergebnis |
|---|---|---|
| 1 | `bash test/mutations/314-archive-welle-go-haenger-nachzug-suchraum.sh` (Aufrufstelle `Haenger`) | **rot**, genau `--- FAIL: TestHaengerFindetVerweisAusADRTrotzNachzugAusnahme` |
| 2 | `sed -i '70s/Ausgenommen(rel)/AusgenommenNachzug(rel)/' internal/archive/scan.go` (Rumpf `Suchraum`) | **rot**, derselbe Test |
| 3 | `sed -i '41s|".harness/baseline"}|".harness/baseline", "docs/plan/adr"}|' internal/archive/scan.go` (der Ausschluss landet in der **geteilten** Liste — das Risiko aus §6 des Plans) | **rot**, derselbe Test |
| 4 | `sed -i '92s/SuchraumNachzug(dateien)/Suchraum(dateien)/' internal/archive/refs.go` (Aufrufstelle `VerweisFund`) | **rot**, neuer Test **und** `TestVerweisFundUndNachziehenUebergehenAcceptedADR` |
| 5 | `sed -i '230s/SuchraumNachzug(dateien)/Suchraum(dateien)/' internal/archive/refs.go` (Aufrufstelle `Nachziehen`) | **rot**, `TestVerweisFundUndNachziehenUebergehenAcceptedADR` + `TestZuStagenNenntNurArchivStubsUndNachgezogene` |
| 6 | `sed -i '103s/AusgenommenePfadeNachzug()/AusgenommenePfade()/' internal/archive/scan.go` | **rot**, drei Tests |
| 7 | `sed -i '120s/AusgenommenNachzug(rel)/Ausgenommen(rel)/' internal/archive/scan.go` | **rot**, drei Tests |

**Eine grün bleibende Mutation an dieser Trennung habe ich nicht gefunden.** Damit misst der
neue Test die Eigenschaft und nicht die heutige Schreibweise: Er wird an vier verschiedenen
Code-Stellen rot, von denen nur eine der Mutations-Fall anfasst. Die vom Auftrag genannte
Gegenprobe — `AusgenommenePfadeNachzug()` so ändern, dass `docs/plan/adr` wieder im
Nachzugs-Suchraum liegt — ist Fall 6 bzw. der vorhandene `312`; sie färbt **drei** Wächter rot,
nicht nur einen.

**Die zwei Nachbar-Fälle sind unverändert wirksam** (`bash test/mutations/<fall>.sh &&
make test-go`, danach zurückgesetzt): `312-…` → `--- FAIL:
TestVerweisFundUndNachziehenUebergehenAcceptedADR` (plus zwei weitere); `233-…` → `--- FAIL:
TestHaengerFindetVerweisAusReviewReport` (plus neun weitere). Beide nennen ihren erwarteten
Wächter in einer `--- FAIL:`-Zeile, und das ist die Form, die der Treiber für `test-go` verlangt
(`failure_form()` in `harness/tools/mutate.sh:540`) — Fall `314` erfüllt die vier Bedingungen
des Treibers damit ebenfalls (Mutation greift · rot · richtige Form · erwarteter Name);
gemessen habe ich sie einzeln, nicht über einen Treiber-Lauf.

**Der zweite Kopf-Beleg, unabhängig nachgestellt.** Scratch-Repo außerhalb des Baums, vier
Dateien (Slice-Datei in `open/`, eine ADR und ein Review-Report, die beide per Präfix-Form auf
sie zeigen), `git init` + ein Commit, dann `bash harness/tools/slice-mv.sh slice-900 next`:

- **mit** Pathspec-Übergabe → *„eingehend: 1 Datei(en) mit Verweisen nachgezogen"*; die ADR
  trägt unverändert `../planning/open/…`, der Report trägt `../plan/planning/next/…`.
- **ohne** sie (`-- "${in_pathspec[@]}"` aus dem `git grep`-Aufruf entfernt) → *„eingehend: 2
  Datei(en)"*; die ADR trägt danach `../planning/next/…`.

Beide Hälften decken sich mit dem Skriptkopf. Die Zahlen wandern mit der Fixture und sind kein
Erwartungswert; tragend ist die Trennung.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Sitz der Ausnahme gegen Festlegung 2** | ohne Befund — `VerweisFund`/`Nachziehen` fragen `SuchraumNachzug` (`refs.go:92,230`), `Haenger` fragt `Suchraum` (`scan.go:180`); die geteilte `AusgenommenePfade()` ist unverändert `{".git", ".harness/baseline"}`. Festlegung 2 spricht von *„ihrer Ersetzung"* — die Vorprüfung ersetzt nichts und gehört richtigerweise nicht dazu |
| **Aufrufer-Ebene** | ohne Befund — `vorschau.go:45,48` und `anwenden.go:164` geben **dieselbe** Liste an beide Leser; `gitLsFiles` (`cmd/ai-harness-init/archive_welle.go:286`) filtert nichts, und sein Kommentar sagt genau das im Indikativ |
| **Dritter Träger** (Risiko 3 in §6 des Plans) | ohne Befund — schreibende Stellen: `refs.go:243` (Nachzug), `anwenden.go:233,285` (Stubs/Zip); `ErsetzePraefix`/`ErsetzeGeschwister`/`ErsetzeAufsteigend` haben außerhalb von `refs.go` keinen Nicht-Test-Aufrufer (`grep -rln … --include='*.go' \| grep -v _test` → eine Datei) |
| **Aliasing in `AusgenommenePfadeNachzug`** | ohne Befund — `AusgenommenePfade()` liefert je Aufruf ein frisches Literal mit `len == cap == 2`; das `append` legt neu an und kann die geteilte Liste nicht verändern |
| **Neue Go-Kommentare gegen §3.7** | ohne Befund bis auf LOW-3 — `scan.go:89–94` und `scan.go:168–173` stehen im Indikativ Präsens über den Zustand, nennen den Sensor namentlich, und die Zusage stimmt (Belege oben). Kein abwesender Text, keine verworfene Alternative, kein abgebrochener Satz |
| **`harness/sensors/archive-welle.md` Punkt 6** | ohne Befund — *„bindet … ; beide Träger führen den Ausschluss …, diese Bedingung ist damit erfüllt"* ist Zustand im Präsens; die Aussage stimmt gegen den Code und gegen Punkt 3 derselben Datei |
| **Mutations-Nummer `314`** | ohne Befund — eindeutig und lückenlos anschließend (`ls test/mutations/*.sh \| sed 's#.*/##' \| cut -d- -f1 \| sort -n \| uniq -d` → nur 47–50 aus dem Altbestand, nicht 314; höchste Nummern 312, 313, 314) |
| **`ADR-0042` unberührt (§3.4)** | ohne Befund — `git show --stat 67a1784b` nennt fünf Dateien, keine unter `docs/plan/adr/` |
| **Hard Rule §3.9 (Docker-only)** | ohne Befund — der neue Beleg beschreibt `make slice-mv` in einem Scratch-Clone; `git` und `make` sind die erlaubten Host-Werkzeuge, eine Host-Toolchain kommt nicht vor |
| **Hard Rule §3.2 / §3.8** | ohne Befund — keine Inline-Suppression, keine Architect-Artefakte im Diff |

## Was ich nicht geprüft habe

- **`make gates` als Ganzes** und die Einzelziele `docs-check`, `lint`, `build`, `span-check`,
  `baseline-verify` — Gate-Lauf-Bestätigung ist Verifier-Arbeit. Gefahren habe ich nur
  `test-go`, `test-bats`, `shell-lint`, `comment-claims`, und die als **Messinstrument** für die
  Befunde oben, nicht als Abnahme.
- **`make mutate` als Volllauf** (300 Fälle). Geprüft habe ich `314`, `312`, `233` einzeln plus
  sieben eigene Sonden; über die übrigen 297 sage ich nichts.
- **`make full-smoke` / `make smoke`.**
- **Den Vorschau-Lauf** `archive-welle --vorschau altbestand` (DoD-Kriterium (b)) — Runde 1 hat
  ihn gemessen, ich habe ihn nicht wiederholt.
- **Die DoD-Abhakung** und den Abgleich Plan-gegen-Code auf Vollständigkeit — Verifier.
- **`harness/sensors/slice-mv.md`** — von `67a1784b` nicht berührt; Runde 1 hat es geprüft.
- **Ob mein eigener Report das Doku-Gate hält** — ich habe `make docs-check` nach dem Schreiben
  laufen lassen; das Ergebnis steht im Übergabe-Text, nicht als Abnahme hier.

## Kategorie-Summary

0 HIGH · 1 MEDIUM · 3 LOW · 0 INFO.

Wiederkehrende Klasse, dieselbe wie in Runde 1, nur noch an **einem** Träger: **Zusage ohne
Wächter an der Stelle, die die Zusage trägt.** Für den Go-Träger ist sie geschlossen, für den
Shell-Träger nicht — Kandidat für
`BEO-ALL/neuer-waechter-ohne-mutations-fall` bei der Closure. Die drei LOW teilen keine Klasse.

## Verdikt

**Die Sperre aus Runde 1 ist gehoben.** HIGH-1 ist nicht nur beantwortet, sondern über die
gelieferte Mutation hinaus geprüft: Der neue Wächter wird an vier verschiedenen Code-Stellen
rot, darunter an genau der, die §6 des Plans als *„und der Lauf bliebe grün"* benannt hatte.
Eine grün bleibende Mutation an dieser Trennung habe ich nicht gefunden.

**MEDIUM-1 bleibt offen und ist vor Merge zu klären** — der Skill lässt MEDIUM typischerweise
blockieren, und ich weiche davon nicht ab. Zu klären ist keine Code-Frage, sondern eine
Entscheidung: ob die Wahl *Skriptkopf-BELEG statt Sensor* dieselbe bleibt, wenn die Prämisse
berichtigt ist. Sie lautete *„kein `git` im `BATS_IMAGE`"* — das stimmt; sie wurde aber als
*„der Shell-Träger ist heute unbewachtbar"* gelesen, und das stimmt nicht: `make test-go` und
`make full-smoke` fahren in diesem Repo bereits echte `git`-Repos, mit zusammen zwölf
Mutations-Fällen daran. Solange die Frage offen ist, hängt die Zusage aus
[`ADR-0042`](../plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 für
diesen Träger an Prosa, und ihr Bruch färbt keinen Gate rot — gemessen, nicht vermutet.

**Kein Befund berührt die Festlegungen selbst.** Beide Ausschlüsse sitzen an der richtigen
Stelle, die Vorprüfung behält ihren vollen Suchraum, `docs/reviews/**` bleibt in beiden
Suchräumen, und die ADR ist nicht angefasst.
