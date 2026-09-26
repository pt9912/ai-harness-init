# Architect-Verdikt: Korrektur ADR-0035, ADR-0068, ADR-0069 nach dem Konsistenz-Review — 2026-09-26

**Rolle:** Architect (Modul 8). Frage: *Wie ist der Konsistenz-Review `2026-09-26-review-adr-0035-0068-0069-konsistenz` (kein HIGH; je ADR ein bis zwei MEDIUM, Accept-Empfehlung je ADR „ja nach Korrektur") in die drei `Proposed`-ADRs zu ziehen — und wo ändert eine Entscheidung den Code?* Kein Review und keine Verifikation; das Verdikt ist das **Übergabe-Artefakt** an den Auftraggeber (Accept) und, wo genannt, an Planner und Implementer.

**Eingang:** `AGENTS.md` §3.4 bis §3.8 und §3.11; der Review-Report komplett mit seinen Messbelegen; die zwei Architect-Verdikte des Tages (Sammelauftrag, Tap-Nachzug); die drei ADRs; `harness/tools/mutate.sh` (Kopf, `main`, `clear_belief`, `finalize_belief`); `harness/tools/tap-nachzug-nutzlast.sh` (`beende`, `fehler`, `nicht_lesbar`, `gleich`, `vergleiche`, `schreibe`, `sync_lauf`); `docs/user/releasing.md` Schritt 7; `.d-check.yml` (`modules:`, Block `planning:`); `harness/sensors/docs-check.md` (Module `planning`, `targets`); Baseline `modul-06-roadmap.md` §Das Beobachtungs-Register und Closure-Schritt 3, `observation.template.md`; das Register (die vier beleglosen Verzeichnisse). HEAD `1a90c69b` bei Beginn.

**Ausgang:** drei geänderte ADRs im Status `Proposed` (`ADR-0035`, `ADR-0068`, `ADR-0069`), die Titel-Zeile von `ADR-0068` im ADR-Index, dieses Verdikt. **Keine** `Accepted`-ADR geändert (`AGENTS.md` §3.4), kein Code, kein Test, kein Sensor-Dokument, keine Slice- und keine Register-Datei, kein Accept. Die Verdikte und der Review-Report vom selben Tag bleiben unverändert (Zeitdokumente).

**Eigene Läufe** (ausschließlich in Kopien des Baums außerhalb des Repos, netzlos, Mount `:ro`, gepinnte Bilder): (1) Teillauf-Fälle `test/mutate-driver.bats --filter Teillauf` unverändert `1..5` grün; mit der Bedingung des Übersprungs ohne `[ -z "$partial" ] &&` (Zeile 1629, genau eine Zeile) färbt sich *„…faehrt trotz stehendem Beleg zum aktuellen Schluessel"* rot (`Kein Fall-Lauf` in der Ausgabe), die anderen vier bleiben grün — der dritte Zahn von Festlegung 5, den der Review (R-35-3) als ungenannt fand, ist damit selbst gesehen. (2) `d-check` im Digest-Pin des Makefiles gegen eine Kopie von `git archive HEAD` **mit** einem fünften Register-Verzeichnis (`observation.md` und `state.md`, kein `evidence/`): `0 Befund(e)`; gegen den unveränderten Baum ebenso (zwei Dateien weniger) — die zweite Hälfte der Paarung (c) hält heute keine aktivierte Regel. (3) `awk` über den Block `planning:` der `.d-check.yml` auf `observations`: 0 Zeilen. (4) Die Mess-Kommandos aus R-35-2 (Gate- und Werkzeug-Tabelle von `harness/README.md`, `record-gates`, Fall-Zahl, Modulliste) neu gefahren; die Ausgaben stehen in `ADR-0035` §Kontext und §Fitness Function.

---

## ADR-0035

### R-35-1 (MEDIUM) — Rest aus Festlegung 5: **gezogen, Entscheidung bleibt, Begründung und Einordnung ersetzt, Trigger 4 neu**

**Entscheidung.** Der Rest bleibt: ein Teillauf mit Befund lässt den Slot stehen (Alternative G, bisher *(iii)*). Geändert ist, **was die Festlegung darüber sagt.**

1. **Der Reviewer hat recht, der Grund war falsch.** *„Ein Befund an der Infrastruktur ist von einem Befund des Falls nicht zu unterscheiden"* gilt für den vollen Lauf ebenso, und der volle Lauf löscht. Der Unterscheider ist **der Preis**: der volle Lauf entwertet den Slot vor dem ersten Fall, weil er ihn ohnehin neu verdienen muss — die Entwertung kostet ihn nichts; ein Teillauf kann ihn nicht neu verdienen, löschte er bei einem Befund, kostete jedes rote Nachsehen über unverändertem Prüfgegenstand einen vollen Lauf. Festlegung 5 sagt das jetzt so.
2. **Einordnung des Rests: der Rest aus Festlegung 4 in der Form, in der er sich zeigt** — nicht Festlegung 1 und nicht Festlegung 2. Ein grüner voller Lauf und ein roter Teillauf über **demselben** Schlüssel sind bei einem deterministischen Sensor über einer vom Schlüssel gedeckten Eingabe nicht zugleich möglich; gibt es sie doch, variiert etwas außerhalb des Schlüssels (Docker-Cache-Zustand, Host-Werkzeuge) oder der Fall flackert. Das ist der benannte Rest mit demselben Träger, `MUTATE_FORCE`. Festlegung 1 (Verdikt-Funktion) bleibt unberührt — jeder gefahrene Fall urteilt wie zuvor; Festlegung 2 (Deckung der **Menge** gezeigt) ist erfüllt — was der Menge fehlt, steht in Festlegung 4.
3. **Ist er eine Lockerung nach §3.5? Ja, gegenüber der Alternative E (Teillauf löscht), und bewusst.** `AGENTS.md` §3.5 verlangt dafür eine ADR mit Begründung; Festlegung 5 ist sie, mit dem **Preis der Gegenwahl** (ein voller Lauf je rotem Nachsehen), der **Grenze** (der Rest entsteht nur über unverändertem Schlüssel — jede Baumänderung entwertet den Slot ohnehin — und der Bediener hat den Befund des Teillaufs vor sich) und einem **Trigger**.
4. **Warum nicht das Gegenteil (E) jetzt.** Kosten von E: eine Bedingung in `main()`, ein Fall wechselt seine Aussage, das Sensor-Dokument und der Kopf von `mutate.sh` folgen — und ein voller Lauf je rotem Nachsehen. Nutzen: schließt den sichtbaren Fall, nicht das Flackern ohne Teillauf. Der Rest entsteht nur, wenn jemand einen Befund ignoriert, den er selbst vor sich hat; der Preis von E fällt dagegen bei jedem legitimen Nachsehen an. Solange der Rest nicht als **echt** beobachtet ist, trägt die billigere Wahl; ist er es, kippt die Rechnung — das ist Trigger 4.

**Akzeptierte Negative, mit Grund (nicht nur hier, sondern in der ADR):** (a) die Übersprung-Meldung nennt den roten Teillauf nicht — dafür müsste ein Teillauf einen Merker neben dem Slot schreiben, einen zweiten Zustand, den die ADR nicht einführt und der nur den sichtbaren Fall träfe; (b) der Beobachter von Trigger 4 ist kein Sensor, sondern der Verifier, der beide Berichte liest (dieselbe Lage wie bei der Vereinigungsregel).

**Code-Folge: keine.** Die ADR benennt den Ist-Zustand richtig. Bedingte Folge nur bei Trigger 4 (dort mit Wortlaut: eine Bedingung in `main()`, der Fall *„…laesst einen stehenden Beleg byte-gleich stehen"* wechselt die Aussage); sie ist kein Auftrag heute.

### R-35-2 (LOW) — stale Kommando-Ausgaben: **gezogen**

`ADR-0035` §Kontext führt die Lage jetzt mit den Kommandos, die am 2026-09-26 stimmen: `mutate` ist in der Gate-Tabelle von `harness/README.md` 0-mal, in der Werkzeug-Tabelle (Marke `kein Gate`) 1-mal, in `record-gates` 0-mal. Die `AGENTS.md`-Zeile *„außerhalb von `make gates` stehen"* existiert nicht mehr (`grep -c` → 0) und ist ersetzt, nicht fortgeschrieben. Die Modulliste ist der Ist-Stand (`links, anchors, ids, matrix, codepaths, spans, planning, targets, structure`), und der Schluss ist richtig gefasst: kein Modul prüft, was ein Shell-Skript oder Rezept **tut**; `targets` hält die Rezepte gegen die Gate-Tabellen der Doku (Sensor-Dokument §Modul `targets`). Die Beträge der Mengen-Messung tragen den Vermerk *Stand des Entscheids am 2026-09-04*; die Fall-Zahlen in Festlegung 4 sind auf 19 von 446 (Stand 2026-09-26) gezogen, mit dem alten Stand daneben.

### R-35-3 (LOW) — dritter Zahn *„übergeht nie"*: **gezogen**

Die Fitness-Zeile des Teillaufs nennt jetzt drei Fälle (*übergeht* · *schreibt nie* · *lässt bei Befund stehen*) mit je der Schwächung, unter der sie rot werden; *Rot gesehen* führt die Schwächung für *übergeht* (Eigene Läufe (1)).

### R-35-4 (LOW) — Abwägung gehört in die Alternativen: **gezogen**

Die drei Alternativen zu Festlegung 5 stehen als Zeilen E, F, G in §Verglichene Alternativen (mit einem Satz darüber, welche Zeilen zu welchen Festlegungen gehören); Festlegung 5 verweist dorthin.

### R-35-5 (INFO) — Wortlaut *„hinter der Bedingung, unter der `main()` seinen Exit-Status bildet"*: **gezogen** (billig)

Die Fitness-Zeile sagt jetzt, was der Code tut: `finalize_belief` schreibt nur bei `fail_count` 0 und löscht sonst, und `fail_count` ist der Zähler, aus dem `main()` auch seinen Exit-Status bildet. R-35-6 und R-35-7 sind Bestätigungen; nichts zu tun.

---

## ADR-0068

### R-68-1 (MEDIUM) — Reichweite von *„jede Meldung"*: **gezogen, Variante (a): die Norm folgt dem Code; Rest benannt, Trigger 3**

**Entscheidung: (a), die Festlegung auf das einschränken, was der Code hält.** `AGENTS.md` §3.6 sagt es wörtlich: *„die Zusage auf das einschränken, was der Code hält."* Titel, Grundsatz und Festlegung 3 gelten für die Nachkontrolle bei **unlesbarem Tap** (`nicht_lesbar()`; Lesen endet mit jedem Status außer 200 oder ohne Antwort) und für die Meldungen, die der Code aus der Antwort der Schnittstelle bildet. Die **drei Wege nach dem Schreiben, die das nicht sind** — `cmp` Exit ≥ 2 in `gleich()`, der `*)`-Zweig von `beende` (interner Fehler der Nutzlast), ein Signal (`trap 'exit 2' HUP INT TERM`, keine Meldung) —, stehen in `ADR-0068` als **benannter Rest** (Kontext, Festlegung 3, Grenze, Fitness-Zeile 4, Trigger 3). Der Index-Titel ist mitgezogen.

**Kosten der Wahl (b) — Norm bleibt, Code zieht nach — und warum sie nicht gewählt ist.** (b) ist die Alternative F der ADR: eine Änderung an `fehler()`, an `beende` und am Signal-Pfad (der Zustand `geschrieben` muss in jedem Ausgang nach dem Schreiben die Meldung tragen), dazu drei Fälle — `cmp` und Nutzlast-Fehler über einen `PATH`-Stub, das Signal hermetisch kaum. Der Gewinn gilt Wegen, die im Betrieb nicht beobachtet sind (ein Kommando des Bild-Bestands muss nach einem erfolgreichen `curl` scheitern) und deren Folge **gefahrarm** ist: kein Ausgang sagt *„unverändert"*, der Exit bleibt 2 (nie Grün), und ein weiterer Lauf liest und vergleicht **vor** jedem Schreiben (`sync_lauf`: `lese_tap` und `gleich` stehen vor `schreibe`), meldet bei geschriebenen Bytes *„gleich"* und schreibt nichts erneut — wer *„nichts verglichen"* als *„nichts geschehen"* liest, wiederholt den Lauf und bekommt den Vollzug genannt. Die kleinere Handlung, die real trägt, ist (a); der Trigger (ein solcher Weg im realen Betrieb, mit nachfolgendem `make tap-check`, das das Tap als geschrieben zeigt) holt (b) nach.

**Akzeptiertes Negativ, mit Grund:** die drei Wege bleiben ungebunden (kein Fall). Ein Fall würde einen Ist-Zustand festschreiben, den ein Trigger-Eintritt ohnehin ändert; die ADR nennt ihn als Ist-Zustand ohne Versprechen (Fitness-Zeile 4: *„kein Fall"*).

**Code-Folge: keine, bedingt Trigger 3.** *Übergabe an den Implementer, nur bei Eintritt oder wenn er `fehler()`/`beende` ohnehin anfasst:* der Zustand `geschrieben=ja` trägt die Meldung an **einer** Stelle — in `fehler()` und im `*)`-Zweig von `beende` (Wortlaut sinngemäß wie in `nicht_lesbar()`: *„… das Schreiben ist bereits erfolgt (HTTP 200); ob das Tap die Bytes des Assets trägt, ist unbekannt — Ergebnis mit make tap-check TAG=<tag> prüfen"*), der Signal-Pfad meldet nach dem Schreiben dasselbe; `nicht_lesbar()` verliert dann seinen Sonderzweig. Je Weg ein Fall (`cmp`-Stub, Nutzlast-Fehler-Stub, Signal soweit hermetisch bindbar), einmal rot gesehen. Die Prozedur (`docs/user/releasing.md` Schritt 7) trägt den Wortlaut nach, wenn er sich ändert.

### R-68-2 (LOW) — *„401 ist der häufigste Ausgang"*: **gezogen**

Alternative C trägt die Häufigkeitsbehauptung nicht mehr; sie sagt: 401 trägt die belastbare Aussage, dass es im Betrieb eine naheliegende Ursache ist, ist eine Annahme, ihre Häufigkeit ungemessen wie die Menge.

### R-68-3 (LOW) — *„nie eine falsche Zustandsaussage"*: **gezogen**

Der Satz im Trigger-Absatz nennt seine Reichweite: der Fehlgriff außerhalb der Menge ist ein überflüssiger lesender Aufruf und nie ein Grün; **innerhalb** der Menge bricht die Annahme aus Festlegung 2 die Zusage. §Grenze führt das im ersten Punkt (*„bricht sie, ist ‚Tap unverändert' für den betroffenen Status falsch — die Zusage gilt für die Menge unter dieser Annahme, nicht für ihren Rand"*), und §Was die Wahl trägt beschränkt die Asymmetrie auf Status **außerhalb** der Menge.

R-68-4 und R-68-5 sind Bestätigungen (Rot-Belege reproduziert, Konsistenz mit `ADR-0064` und `ADR-0066`); nichts zu tun.

---

## ADR-0069

### R-69-1 (MEDIUM) — Umfang des Closure-Schritts: **gezogen; die Paarung im Closure-Schritt ist universal und nennt jedes beleglose Verzeichnis namentlich**

**Neu gelesen, Modul 6 wörtlich.** Die Baseline führt die zweite Hälfte von (c) an beiden Stellen universal: *„jede Registerzeile trägt mindestens einen Beleg"* (Closure-Schritt 3) und *„ob **jedes** Verzeichnis ein nicht leeres `evidence/` hat"* (§Das Beobachtungs-Register). Der Satz *„erst jetzt, weil sie die gerade entstandenen Einträge prüfen; in Schritt 2 gäbe es sie noch nicht"* begründet den **Zeitpunkt** der Paarungen — nach den Schritten, die die Einträge erzeugen —, nicht den Umfang der zweiten Hälfte. Gebunden an die Closure ist die **erste** Hälfte (die *„in einer Closure-Notiz oder einem Risiko-Ausgang genannte"* Beobachtung). Die Lesart der ADR — der Closure-Schritt prüfe nur berührte Einträge — war eine **Einschränkung, die die Baseline nicht trägt**, und sie hätte die *„Ausnahme in der Closure-Notiz"* unter anderem Namen erhalten.

**Festlegung 2 ist umgeschrieben:** ein Maßstab statt zwei. Die Paarung prüft die zweite Hälfte im Closure-Schritt wie in der Bestandsprüfung über das **ganze Register** und nennt **jedes** Verzeichnis ohne Beleg namentlich — nicht *„getragen, mit Ausnahme"*, nicht *„formal rot"* ohne Namen, nicht nur die von der Closure berührten. Der Satz *„die Baseline gilt wörtlich"* ist damit wahr (die Lesart (a) liest den universalen Wortlaut universal). Eine Alternative F (nur die *„gerade entstandenen Einträge"*) steht mit Grund abgelehnt in der Tabelle. **Preis, in der ADR benannt:** jede Closure trägt bis zur Tilgung des Bestands eine Zeile mit den Namen (heute vier); das ist die Zusage, die die Ausnahme ersetzt.

**Übergabe an den Planner (nach dem Accept, mit der Register-Ablage aus Folgepflicht 1).** Die Zeile in der Closure-Notiz: *„Register-Paarung (c), zweite Hälfte: N Verzeichnisse ohne Beleg, namentlich <Liste>; nicht als getragen behauptet."* Sie gilt für jede Closure, unabhängig davon, welche Verzeichnisse sie berührt hat; die Namen liefert die Schleife aus `ADR-0069` §Kontext. Das Nennen ist keine Tilgung (Cutoff).

### R-69-2 (MEDIUM) — Beleg *„kein Modul liest das Register"*: **gezogen; gemessen und die Aussage auf das gefasst, was das Kommando trägt**

**Gemessen** (Eigene Läufe (2) und (3)): `make docs-check`-Werkzeug bleibt über einem Register mit einem fünften Verzeichnis ohne `evidence/` grün; der Block `planning:` führt keinen `observations`-Schlüssel; die Fähigkeit steht als verfügbar und nicht aktiviert im Sensor-Dokument. Die Aussage *„kein Modul liest das Register"* war falsch als Modul-Aussage — `links`, `anchors` und `ids` lesen jede Markdown-Datei, auch die des Registers —; richtig ist: **keine aktivierte Regel hält die zweite Hälfte der Paarung.** So steht es jetzt in §Kontext (mit der Sonde als Kommando) und in der Fitness Function. Die veraltete Modulliste ist aus dem Beleg entfernt.

**Bleibt ungemessen (akzeptiertes Negativ):** ob die Fähigkeit `planning.observations`, **aktiviert**, ein leeres `evidence/` meldet. Grund: die Frage gehört dem Wächter-Slice (*„der Implementer misst es mit Sonde und rotem Gegenbeispiel"*); das Schema der Fähigkeit ist aus `--print-config` nicht ablesbar, und ein geratener Schlüssel wäre eine Messung ohne Deckung. Die ADR sagt es (§Was hier nicht entschieden ist).

### R-69-3 (LOW) — *„jedes nennt … und sagt selbst, dass die Paarung rot ist"*: **gezogen**

Der Satz sagt: alle vier nennen ihr Vorkommen unter *„Benannt, nicht gezählt"*, **zwei** sagen selbst, dass die Paarung für sie rot ist — mit Kommando (`grep -rl 'Paarung'` über die vier Verzeichnisse → 2, beide `state.md`).

### R-69-4 (LOW) — Template-Satz fehlt bei Alternative C: **gezogen**

Der Satz *„Erfinde keine Belege: Ein Verzeichnis entsteht beim ERSTauftreten einer echten Beobachtung"* steht in §Kontext als Stütze von (a) und in Alternative C mit ihrer Antwort: das Erfinde-Verbot trifft den **Beleg** (Festlegung 3), nicht das Verzeichnis; das Template führt den Abschnitt im Rumpf **jeder** `observation.md`, es verlangt einen Ort für das Vorkommen und verbietet ihn nicht.

### R-69-5 (LOW) — Rumpf von `planungs-bestand-waechst-schneller-als-er-abgebaut-wird` widerspricht Festlegung 4: **gezogen**

Festlegung 4 nennt den Eintrag: sein unveränderlicher Rumpf begründet den fehlenden Beleg wörtlich mit dem Einwand, den die Festlegung verwirft; der Rumpf bleibt, ab dem Accept gilt für die Ablage die Festlegung. **Trigger 1 löst für ihn nicht aus** (er verlangt das Urteil *„keinen Vorgang"*, der Rumpf sagt *„nahezu jede Closure"*) — für ihn gilt der Weg über Belege. Damit liest die Trigger-Audit der nächsten Closure keinen offenen Fall mehr.

R-69-6 bis R-69-8 sind Bestätigungen (Zahlen, `MR-000`-Lesart, Wächter-Kopplung); nichts zu tun. `MR-000`: Lesart, keine Abweichung, bleibt.

---

## Empfehlung zum Accept (Entscheidung des Auftraggebers)

| ADR | Empfehlung | Hinweis |
|---|---|---|
| `ADR-0035` | **ja** | Der Auftraggeber nimmt mit dem Accept die **benannte Lockerung** aus Festlegung 5 an (Rest über unverändertem Schlüssel, Preis der Gegenwahl, Trigger 4). Wer den Rest nicht will, kippt auf Alternative E — dann ist das ein Code-Slice (eine Bedingung in `main()`, ein Fall wechselt die Aussage), vor dem Accept zu entscheiden. |
| `ADR-0068` | **ja** | Die Norm reicht jetzt nicht weiter als der Code; die drei Wege nach dem Schreiben sind benannt, mit Trigger. |
| `ADR-0069` | **ja** | Festlegung 2 hat sich in der Substanz geändert (ein Maßstab, Closure-Zeile mit Namen). Der Acceptance-Trigger verlangt keinen zweiten Report; wer die geänderten Sätze (`ADR-0069` Festlegung 2, `ADR-0035` Festlegung 5) nachprüfen lassen will, ist mit einem kurzen Reviewer-Lauf über genau diese Stellen bedient — Wahl des Auftraggebers. |

## Übergaben

| An | Was | Wann |
|---|---|---|
| Auftraggeber | Accept je ADR (`Proposed` → `Accepted`, Beleg als **Kennung** in der Accept-Zeile: der Review `2026-09-26-review-adr-0035-0068-0069-konsistenz`) | nach Belieben |
| Planner | Closure-Zeile der Register-Paarung (c), zweite Hälfte (Wortlaut oben); Register-README-Wortlaut aus dem Verdikt `2026-09-26-architect-verdikt-sammelauftrag-register-und-adr-0035` um *„im Closure-Schritt über das ganze Register"* ergänzen | nach dem Accept von `ADR-0069` |
| Implementer | **keine** Code-Folge heute. Bedingt: `ADR-0068` Trigger 3 (Nutzlast, Wortlaut oben), `ADR-0035` Trigger 4 (Bedingung in `main()`) | nur bei Eintritt des Triggers |
| Reviewer / Verifier | Beobachter der zwei Trigger (ein Lauf, der die Ausgabe sieht); der Verifier liest bei der Vereinigung zweier Läufe auch einen Teillauf mit Befund bei stehendem Beleg | laufend, kein Sensor |

**Nicht getan, mit Grund:** kein Accept (Entscheidung des Auftraggebers), kein Push, kein voller `make mutate` (ein Teillauf-Filter in einer Kopie genügte für die eine Messung), keine Änderung an Code, Tests, Sensor-Dokumenten, Slices und Register (keine Rolle des Architect-Kontexts, `AGENTS.md` §3.8; die Wortlaute stehen oben als Übergabe), keine Änderung der zwei Verdikte und des Review-Reports vom selben Tag (Zeitdokumente).
