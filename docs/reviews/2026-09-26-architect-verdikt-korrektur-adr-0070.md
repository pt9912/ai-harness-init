# Architect-Verdikt: Korrektur von ADR-0070 (Proposed) nach dem Konsistenz-Review — 2026-09-26

**Rolle:** Architect (Modul 8). Gegenstand: `ADR-0070`, Status `Proposed`, änderbar. Eingang: der Konsistenz-Report `2026-09-26-review-adr-0070-konsistenz` (0 HIGH, 2 MEDIUM, 6 LOW, 3 INFO; Empfehlung *„ja nach Korrektur"*), das Architect-Verdikt `2026-09-26-architect-verdikt-slice-mv-und-eingefrorene-adressen` (bleibt unverändert; Korrekturen stehen hier), `ADR-0042`, `ADR-0033`, `ADR-0030`, `ADR-0040`, `AGENTS.md` §3.4, §3.5, §3.6, §3.7, §3.11.

**Ausgang:** `ADR-0070` und der ADR-Index (Bezug-Spalte, Zeile von `ADR-0070`) korrigiert; **Status bleibt `Proposed`**. Kein Accept, keine Änderung an `ADR-0042`, an Code, Werkzeug, Tests, Sensor-Docs, Slices, Register, Skills, Anweisungssätzen oder `.d-check.yml`.

## Entscheidung über die Blockierung (ADR-0040 Festlegung 2)

**Beide MEDIUM sind blockierend im Sinne von `ADR-0040` Festlegung 2 — vor dem Accept ist eine erneute Reviewer-Kurzrunde zu `ADR-0070` nötig, und ich setze keinen Accept.** Der Maßstab ist der Zweck der Festlegung, nicht das Etikett: Sie verlangt die zweite Runde, wo der Kontext, der einen Befund auflöst, derselbe ist, der ihn übersehen hat. Drei Gründe:

1. Die Korrektur **ändert Zusagen**, sie glättet nicht nur Wortlaut: Die Gate-Zusage für `done/` ist auf eine Teilmenge zurückgezogen, die Form-Regel hat eine neue Erkennungs-Grenze (`](`, kontext-blind) und eine neue Festlegung (3, die Begründung des Baum-Unterschieds) ist hinzugekommen. Niemand außer mir hat diesen Text gelesen.
2. Die Skill-Definition der Rolle (`.harness/skills/reviewer.md`) nennt MEDIUM *„vor Merge zu klären"* und den Report selbst *„vor dem Accept zu korrigieren (nach dem Accept nicht mehr änderbar)"*; ein Befund, der eine Bedingung des Accepts ist, ist für den Accept blockierend.
3. Die ADR wird mit dem Accept immutabel (§3.4): Eine Zusage ohne zweiten Blick festzuschreiben, wäre genau die Nachmessung des auflösenden Kontexts, die Festlegung 2 verwirft. Dasselbe Vorgehen hat `ADR-0069` gehalten (zwei MEDIUM, danach Kurzrunde, danach Accept).

**Was die Kurzrunde prüfen soll** (Eingabe-Vorschlag): die drei Änderungen unter 1 oben, dazu ob die Tatsache-Begründung in Festlegung 3 trägt oder sich hinter dem Kostenargument versteckt. Die Accept-Zeile nennt beide Runden als Kennung.

## Je Finding

**Zeilenangaben:** *vorher* nach dem Report (Stand `149c8aa5`), *nachher* an der Datei nach dieser Korrektur (`grep -n` auf `ADR-0070`).

| Finding | Entscheidung | Vorher → nachher |
|---|---|---|
| MEDIUM-1 Gate-Zusage für `done/` zu weit | **gezogen** | Festlegung 1, letzter Satz, Z. 153–155 → Kontext ab Z. 71 (Messung), Festlegung 1 Z. 211 ff., **neue Festlegung 3** Z. 250; *„gate-notwendig"* Z. 186 → *„Sie ändert am Nachzug in `done/` nichts"*; Fitness-Zeile 4 Z. 241 → Zeile 5, Z. 386 |
| MEDIUM-2 Link-Syntax im Code-Span | **gezogen — Grenze benannt, nicht behoben** | Festlegung 1, Z. 147–152 → Z. 211 ff. (Erkennung an `](`, Zitat = Link-Form); Kontext ab Z. 147; Fitness Z. 236–241 → Zeilen 1 und 2, Z. 382–383; Trigger 6, Z. 413 |
| LOW-1 Referenz-Definition | **gezogen — benannte Lücke** | Z. 149–150 → Festlegung 1, dritter Punkt; Trigger 7, Z. 418 |
| LOW-2 Index-Marke nur im Verdikt | **gezogen** | §Konsequenzen ohne Punkt → Folgepflicht 3, Z. 363 |
| LOW-3 Baseline und `MR-000` | **gezogen** | Bezug ohne `MR-000` → Bezug ergänzt; Kontext §Baseline, Z. 167 |
| LOW-4 *„einziger Ausweg"* | **gezogen** | Z. 159–161 und 198 → Festlegung 2, Z. 237; Alternative B |
| LOW-5 Trigger und Kopplung | **gezogen** | Trigger 4 erweitert, Trigger 5 neu, Folgepflicht 4, Fitness-Zeile 6 |
| LOW-6 Fußzeile, Zahl ohne Kommando | **gezogen** | Ende Z. 274–278 → Fußzeile Z. 441 ff.; Politik-Tabelle mit Stand und Kommando am Ort |
| INFO-1 Pfad zum Verdikt | **gezogen als Aussage, Pfad bleibt** | §Konsequenzen, Z. 339 |
| INFO-2 Nebenwirkung auf Gegenform 2 | **gezogen** | Kopf (`Supersedes (Teil)`) und §Konsequenzen, Z. 334 |
| INFO-3 Restore `bd76d800` | **kein Änderungsbedarf** | die Lesart der ADR stimmt, der Report bestätigt sie |

### MEDIUM-1 — Gate-Zusage zurückgezogen, Begründung ehrlich getrennt

**Die Aussage des Reports stimmt, und ich habe sie gegen den Text nicht verteidigt:** Ich hatte im Verdikt selbst *„aus der Config gelesen, nicht gefahren"* geschrieben und die ADR trotzdem als Tatsache formuliert. Jetzt gilt: `codepaths` färbt in `done/` den **reinen Pfad-Span** rot (`codepath-missing`, konstruierte Probe des Reports, Kennung in der ADR), nicht den Operand im Kommando-Span und nicht den Code-Block. **Kein realer Move hat es gezeigt** (fünfter Lauf: kein `codepaths` rot), und kein Sensor hält es — beides steht in der ADR, in der Fitness-Zeile 5 als benannte Lücke.

**Trägt die Begründung des Baum-Unterschieds noch? Teilweise, und die ADR sagt jetzt, wo.** Ich habe zwei Begründungen getrennt:

- **Tatsache (baum-unabhängig):** Link = Zeiger, sein Nachzug nennt denselben Vorgang; Span, Operand, Block = Beleg des damaligen Orts, sein Nachzug nennt einen Ort, an dem der Vorgang nie war. Das gälte in `done/` ebenso.
- **Gate (nur für den reinen Pfad-Span in `done/`):** Nicht nachziehen hieße dort stumm schalten, also eine Senkung nach §3.5 — das Kostenargument aus `ADR-0042` Festlegung 1. In `docs/reviews/**` fehlt es, weil `exempt-paths` den Baum schon ausnimmt.

**Ehrliches Ergebnis:** Für den Operand im Kommando-Span und den Code-Block in `done/` trägt die Gate-Begründung **nicht**; dort bleibt der Nachzug, weil `ADR-0042` Gegenform 2 ihn nicht ausnimmt — **gegen** die Tatsache-Begründung. Ich habe **nicht** auf `done/` ausgedehnt, obwohl das folgerichtig wäre, und sage es: Die Trennung *reiner Span / Kommando-Span* ist eine Kontext-Erkennung im Träger (dieselbe, die ich für das Link-Zitat verwerfe, und die `ADR-0042` Alternative E als Urteil verwirft). Gemessen sind 42 Spans dieser Klasse in `done/` (Näherung: Leerzeichen im Span; 32 davon beginnen mit einem Kommandowort). **Das ist eine Ungleichbehandlung aus Kosten, nicht aus Prinzip**, benannt in Festlegung 3 und in den Negativen, mit Trigger 6 (kommt eine Kontext-Erkennung, ist die Operand-Form in `done/` in derselben Entscheidung neu zu bewerten). Der Auftraggeber kann sie anders schneiden; dann ist es eine andere ADR, und der Umbau ist der von D″.

### MEDIUM-2 — Entscheidung: Link-Syntax im Code-Span ist Link-Form (wird ersetzt)

**Gewählt:** Die Erkennung ist syntaktisch — Adresse unmittelbar hinter `](`. Link-Syntax als Zitat innerhalb eines Code-Spans oder -Blocks wird damit **mitersetzt**, wie es `harness/sensors/slice-mv.md` heute schon dokumentiert. **Gegenwahl D″ (Kontext-Erkennung, Zitat bleibt byte-gleich) als Alternative in die ADR aufgenommen und abgelehnt:** zwei Träger in zwei Sprachen (zeilenweises `sed`, Go-Regex), Span-Grenzen und Fence-Zustand, die `KERN`-Kopplung — für **9** Vorkommen, davon **0** in einem Block und **0**, die heute einen beweglichen Träger nennen (Kommandos in der ADR). Die Menge ist real und inert; ein Umbau, der größer wäre als die Regel, die er schützt, ist die schlechtere Wahl. Ein Link, dessen **Text** ein Code-Span ist, ist Link-Form (Politik D hat genau das gemessen).

**Die Byte-Gleich-Zusage ist damit eng, und trägt:** sie gilt für vier Nicht-Link-Formen (reiner Span, Operand, Block, Fließtext), die der Fitness-Fall 1 alle in **einer** Datei bindet. **Das verlangte Gegenbeispiel:** ein Träger, der nur den unmittelbaren Backtick-Kontext ausnimmt, besteht den reinen Span und bricht Operand, Block und Fließtext. Der Grenzfall (Zitat wird mitersetzt) ist ein eigener Fall (Zeile 2), damit die Grenze gemessen statt behauptet ist; kippt er, ist das Trigger 6 und eine Folge-ADR, kein stilles Umdrehen.

**Code-Folge, Umfang:** je Träger eine Regel mit dem Anker `](` und ein Pfad-Zweig für Dateien unter `docs/reviews/` (Lektüre von `slice-mv.sh` und `refs.go`, nicht gebaut) — **keine Kontext-Erkennung**. Folgepflicht 1 ist damit ohne den D″-Umbau erfüllbar, ein Slice von drei Liefer-Punkten bleibt es. Kommt der Kopplungs-Test (Folgepflicht 4) hinzu, sind es vier Punkte; der Planner schneidet nach dem Größen-Maß.

### LOW-1 bis LOW-6 und INFO

- **LOW-1:** Referenz-Definition **nicht** in die Regel aufgenommen, sondern als benannte Lücke geführt (Bestand `0`, kein Fall; eine Zusage ohne Gegenbeispiel wäre §3.6 verletzt) — Trigger 7 mit Kommando. Das ist die billigere der zwei Wege des Reports und die ehrlichere.
- **LOW-2:** Folgepflicht 3 in die ADR, **erst mit dem Accept** (die Marke steht in der Status-Zelle der `ADR-0042`-Zeile des Index, nicht in der Datei — §3.4).
- **LOW-3:** Baseline `v6.9.0` wörtlich zitiert (*„… in **beiden** Formen, mit Verzeichnis-Präfix und geschwister-relativ"*): zwei Schreibweisen eines Pfades, nicht Link gegen Code-Span. Keine Abweichung, **kein MR**; `MR-000` im Bezug. Eine Einschränkung genau benannt: Ob ein Pfad im Code-Span ein *Verweis* ist, lässt die Stelle offen; die ADR nimmt für diesen Baum die enge Lesart.
- **LOW-4:** korrigiert; namentliche `ignore-refs`-Paare (`ADR-0042` Festlegung 3) genannt und begründet, warum sie hier keine Wahl sind: eine Entscheidung je Move und Report, jedes weitere Paar ist eine Senkung nach §3.5 mit eigener ADR.
- **LOW-5:** (ii) hat **keinen eigenen Trigger**, mit Grund: der Schaden, den eine Schreiber-Pflicht verhinderte, ist ein Link-Nachzug, der eine Aussage verändert — das ist Trigger 4, jetzt darauf erweitert. Das ist die Abkürzung ohne neue Prüfrunde. (i) bekommt Trigger 5 (ein Lauf scheitert an einer toten Span-Adresse). (iii) ist baubar: **Folgepflicht 4** und Fitness-Zeile 6, im Stil von `test/sources-pin.bats`.
- **LOW-6:** Fußzeile ergänzt; die Politik-Tabelle nennt das Kommando am Ort (die Zeile `d-check: N Datei(en) geprüft` je Kopie) und den Stand `f8d33b38`. Der Report fuhr am HEAD `149c8aa5` **1966**; tragend ist die Gleichheit über die Politiken, die ADR trägt den Stand ausdrücklich mit.
- **INFO-1:** **Der Pfad zum Verdikt bleibt zulässig, und die ADR sagt es.** §3.11 bindet, was wandert. Ein Report wandert nur, wenn `Reviews` in `internal/archive/collect.go` ihn einsammelt, und das geschieht nach einer **Ziffern**-Slice-Nummer im Dateinamen (`SliceNummer`, `ReviewTrifft`); das Verdikt trägt keine (`slice-mv` ist keine Nummer), und `docs/reviews/` ist eine stehende Ablage. Träfe ein künftiger Schnitt es doch, bräche der Hänger-Wächter laut — sein Suchraum schließt `docs/plan/adr/` ein (`scan.go`, `Suchraum`). **Akzeptiertes Negativ, einmalig und laut, kein eigener Träger.** Das neue Verdikt und der Report stehen in der ADR nur als **Kennung**, ohne Pfad.
- **INFO-2:** Nebenwirkung auf `ADR-0042` Festlegung 4 in Kopf und §Konsequenzen: Gegenform 2 ist für `docs/reviews/**` als Nachzug-Fall gegenstandslos (der Operand steht nicht hinter `](`), für `done/` unverändert; Gegenform 1 und 3 sind Link-Formen und bleiben.

## Messbelege dieser Korrektur (nachgefahren, keine Erwartungswerte)

```sh
export LC_ALL=C
# Link-Syntax vollständig im Einzel-Backtick-Span / im Code-Block unter docs/reviews
git ls-files 'docs/reviews/*.md' | xargs awk '/^```/{f=!f;next} f{b+=gsub(/\]\([^)#]*\/(open|next|in-progress)\/[^)#]*\)/,"")} !f{n=split($0,p,"`");for(i=2;i<=n;i+=2)s+=gsub(/\]\([^)#]*\/(open|next|in-progress)\/[^)#]*\)/,"",p[i])} END{print "Span " s+0 " · Block " b+0}'   # Span 9 · Block 0
# davon mit heute beweglichem Ziel: 0 (Kommando in der ADR)
# Code-Spans in done/: reine Pfad-Spans gegen Spans mit Leerzeichen
git grep -ohE '`[^`]*(open|next|in-progress)/slice-[^`]*`' -- docs/plan/planning/done | awk '{ if ($0 ~ /^`[^ ]*`$/) r++; else o++ } END{print "rein " r+0 " · mit Leerzeichen " o+0}'   # rein 17 · mit Leerzeichen 42
# Referenz-Definitionen auf bewegliche Träger in Reports
git grep -nE '^\[[^]]+\]:[[:space:]]*\S*(open|next|in-progress)/' -- docs/reviews | wc -l   # 0
```

**Nicht nachgefahren, und der Grund:** Die konstruierte Probe zu `codepaths` in `done/` (`codepath-missing` für den reinen Pfad-Span) stammt vom Report und ist hier nicht wiederholt; ihr Ergebnis ist mit Quelle in die ADR übernommen, als Messung an einer konstruierten Probe und nicht als Sensor-Aussage. Die Umbau-Größe je Träger ist Lektüre, nicht gebaut.

## Empfehlung

**Accept: ja — nach einer erneuten Reviewer-Kurzrunde**, die die drei Änderungen aus der Blockierungs-Entscheidung prüft. Den Accept vollzieht der Auftraggeber; bei Vollzug zieht der Architect die Index-Marke bei der `ADR-0042`-Zeile nach (Folgepflicht 3), und die Accept-Zeile nennt beide Runden als Kennung (`ADR-0040` Festlegung 1).

**Übergaben:** Reviewer — Kurzrunde zu `ADR-0070` (nur die Änderungen, dazu die Konsistenz gegen `ADR-0042`, `ADR-0033`, `ADR-0030`). Planner — nach dem Accept die Register-Nachschreibung (Folgepflicht 2) und der Slice-Schnitt zu Folgepflicht 1 und 4 (Kennung, kein Pfad). Implementer — nichts vor dem Accept.
