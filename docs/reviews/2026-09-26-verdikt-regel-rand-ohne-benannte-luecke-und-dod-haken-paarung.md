# Architect-Verdikt: Ausgang der Beobachtung `regel-rand-ohne-benannte-luecke` und das Kästchen der Paarungs-Zeile — 2026-09-26

**Rolle:** Architect (Modul 8), Zug „Planner → Architect → Planner" (Lese-Schritt / Verkörperung). Frage 1: *Ist der Übertritt auf 3× ein echter, und welchen Ausgang trägt er?* Frage 2: *Ist das Kästchen „Die drei Paarungen … getragen" bei roter zweiter Hälfte von Paarung (c) mit `ADR-0069` und dem Regelwerk vereinbar?* Kein Review, keine Verifikation; das Verdikt ist das **Übergabe-Artefakt** an Planner und Reviewer.

**Gegenstand:** Beobachtung `BEO-ALL/regel-rand-ohne-benannte-luecke` (Stand `offen`, „Schwelle erreicht, Ausgang steht aus"); HEAD `273b755b` bei Beginn des Laufs, Baum sauber.

**Ausgang:** **kein** Norm-Text geschrieben — weder `AGENTS.md` noch ein `MR` noch eine ADR noch der Reviewer-Skill noch der Register-Zustand. Frage 1: Ausgang *verkörpert* im Reviewer-Skill (Textvorschlag unten, schreibt der Reviewer nach `ADR-0028`). Frage 2: **keine Norm-Änderung**; das Verfahren trägt als benanntes Interim, die Heilung ist Planner-Arbeit im Register. Beides braucht **keine** Zustimmung des Auftraggebers, siehe §Zustimmung.

**Gelesen (nicht nur die Belege):** `observation.md`, `state.md` und die drei `evidence/`-Dateien der Beobachtung; die Reviewer- und Verifier-Reports der drei belegenden Slices (Befunde R-2 / R-5 / V-5 / R-2, R-3 mit den Fundstellen, nicht die Zusammenfassungen); `harness/sensors/slice-mv.md` und `harness/sensors/archive-welle.md` am HEAD; `.harness/skills/reviewer.md` vollständig; `AGENTS.md` §3.6; die Nachbar-Beobachtungen; `ADR-0069`; die Slice-Vorlage, Modul 5 und 6 der Baseline; der Kommentar zur `structure`-Regel in `.d-check.yml`.

---

## Frage 1 (a) — Sind die drei Belege dieselbe Klasse? **Ja — zwei exakt, einer mit Vorbehalt; der Übertritt steht**

Die Klasse ist in `observation.md` über den **Mechanismus** definiert: eine Regel, die syntaktisch statt semantisch erkennt, ist an ihren Rändern enger als die Sprache, über die sie spricht, und die Aufzählung ihrer Grenzen nennt einen Teil der Ränder, nicht alle.

| Beleg | Erkennende Regel | Was nicht genannt war | Wer fand es | Passt? |
|---|---|---|---|---|
| Shell-Träger | Link-Regel des Nachzugs in `slice-mv.sh` | Titel-Link und Spitzklammer-Ziel — die Sensor-Doku zählte „fünf gemessene Grenzen" | Reviewer (R-2, INFO) | **ja, exakt**: Zählung als Liste, Form der Sprache fehlt |
| Go-Träger | dieselbe Regel in `internal/archive/refs.go` | Ziel mit Klammern **vor** dem Segment; Ziel hinter dem Zeilenumbruch — Punkt 8 zählte „vier Ränder" | Reviewer (R-5) und, unabhängig, Verifier (V-5, Klammern gefahren) | **ja, exakt**; anderer Träger, andere Implementierung, andere zwei Formen — kein Doppelzählen des Shell-Belegs |
| Kopplungs-Slice | Muster im Test `test/codepaths-reviews-ausnahme.bats` über YAML | R-2: Block-Liste, mehrzeilige Liste, einfache/fehlende Anführungszeichen (äquivalentes YAML färbt rot); R-3: Unterschlüssel in `codepaths:` grün, `#`-Ausschluss färbt Zeilenende-Kommentar rot | Reviewer (R-2 LOW, R-3 INFO) | **mit Vorbehalt** (unten) |

**Der Vorbehalt zum dritten Beleg, gemessen an den Reports.** Mechanismus und Ergebnis passen: ein Muster, das syntaktisch statt semantisch erkennt (YAML), Ränder, die weder Test-Kopf noch DoD nannten, vom Review gefunden. Die **Fehlerrichtung** der Beobachtung — *die genannte Grenze ist vollständig* — trifft nur zum Teil: der Test-Kopf nannte gar keine Grenze, statt eine unvollständige zu nennen, und R-2 ist zugleich ein Fall von `AGENTS.md` §3.6 in eigenem Recht (*„ein Test … muss die Eigenschaft messen, nicht ihre heutige Implementierung"*; der Reviewer nennt §3.6 dort als Quelle). Wer die Klasse enger zieht und den dritten Beleg abweist, liest 2× und hat keinen Übertritt. Ich lese weit — die Beobachtung nennt sich *Regel-Rand ohne benannte Lücke*, nicht *Aufzählung ohne Vollständigkeit* — und **der Ausgang unten trägt bei beiden Lesarten**: er kostet eine Zeile, und die zwei exakten Belege begründen ihn allein. Der Planner behält das Urteil, ob der Zähler bei 3 stehen bleibt.

**Der Träger hat getroffen — und das ist der Befund, der den Ausgang klein hält.** Alle drei Vorgänge trugen den Fund als **Review-Befund** (INFO, INFO, LOW/INFO), keiner ist ins Produkt oder ins Gate gelaufen; die zwei Formen des Shell-Belegs sind **laut**, nicht still — ein unterbliebener Nachzug färbt `make docs-check` mit `target-missing` (Shell-Review R-2, Go-Verifikation gefahren). Wer fehlt, ist der **Autor**: er schreibt die Aufzählung ohne die Formen der Sprache gefahren zu haben, dreimal in einer Sitzung, obwohl `AGENTS.md` §3.6 in allen dreien galt.

### Abgrenzung zu den drei Nachbarn — gemessen, nicht erinnert

| Nachbar | Zähler | Warum nicht dieselbe Klasse |
|---|---|---|
| `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` (verkörpert, `AGENTS.md` §3.6) | 4 | dort steht eine Zusage mit vorhandener `bats`-Assertion, und der **Mutations-Fall** fehlt. Hier fehlt die **Nennung** des Rands (Prosa, Test-Kopf); ob ein Fall existiert, ist die andere Achse. Ein genannter Rand ohne Fall wäre Instanz jener Klasse, ein ungenannter ist diese |
| `zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel` | 2 | dort **sagt** ein Kommentar eine Grenze zu, und eine Hälfte hat keinen Fall (Kopplungs-Slice R-1, nicht R-2/R-3). Hier ist der Rand gar nicht zugesagt. Ein Vorgang darf beide Klassen belegen — R-1 dort, R-2/R-3 hier sind verschiedene Befunde desselben Vorgangs |
| `nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung` | 1 | dort ist die Form **benannt** (Referenz-Definition) und die Wirkung am Gate offen, oder die Wirkung ist eine der Archiv-Form. Hier ist die Form **nicht benannt** |

**Deckt `AGENTS.md` §3.6 den Fall bereits?** Teilweise, und die Teilung ist der Grund für den Ausgang.

```sh
sed -n '/^### 3\.6/,/^### 3\.7/p' AGENTS.md | grep -c -E 'Grenzen|Ränder|Aufzählung'   # 0
grep -c -i -E 'Formen-Probe|Grenzen' .harness/skills/reviewer.md                        # 0
```

Keine der beiden Quellen nennt eine Grenzen-Aufzählung oder eine Formen-Probe. §3.6 trägt den Fall **nur analog**: eine Aufzählung *„es gibt fünf Grenzen"* ist eine universelle Zusage, deren Gegenbeispiel — eine sechste Form — niemand benannt und gesehen hat, dieselbe Struktur wie das `MkdirAll`-Beispiel der Falsch/Richtig-Zeilen; und der Kopplungs-Test R-2 fällt unter den Test-Namen-Satz. Das reicht, um den Fund als §3.6-Verstoß zu **lesen**, nicht, um den Autor zu einer Formen-Probe zu **führen**. Ein Reviewer, der die Formen der Sprache fährt, hat das jeweils aus eigener Gewohnheit getan; der Skill sagt es nicht.

```sh
grep -c -i -E 'Zeilenumbruch|Klammern vor|Klammern im' harness/sensors/slice-mv.md harness/sensors/archive-welle.md   # 0, 0
grep -c 'Spitzklammer' harness/sensors/slice-mv.md harness/sensors/archive-welle.md                                    # 1, 1 (Gegenprobe: die Suche unterscheidet)
```

Die Klasse ist am HEAD **noch lebend**: zwei der fünf gefundenen Formen (Ziel hinter dem Zeilenumbruch, Klammern im Ziel) stehen in keiner der beiden Sensor-Docs. Das ist die Instanz-Reparatur, nicht der Ausgang der Klasse.

---

## Frage 1 (b) — Ausgang: **verkörpert, im Reviewer-Skill; keine Hard Rule**

**Gewählt:** *verkörpert.* Zielort: `.harness/skills/reviewer.md`, eine Zeile in den Kategorien-Regeln. Der Anweisungssatz gehört der Rolle, die ihn ausführt (`ADR-0028`), die Zeile schreibt der **Reviewer**; ich liefere den Wortlaut als Übergabe-Artefakt. Form und Weg stehen im Präzedenzfall `zusicherung-ueber-der-leeren-menge-wahr` (Zeile im Skill, Anker auf den Slice des dritten Belegs, Eskalation auf §3.6).

**Herkunfts-Anker: `seit slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt`** — der Slice, in dessen Closure die Klasse ihren dritten Beleg trug, wie im Präzedenzfall. Gemessen, warum nicht einer der beiden anderen:

```sh
grep -c 'regel-rand-ohne-benannte-luecke' <§7 des jeweiligen Slice in done/>
# Shell-Träger 0 · Go-Träger 1 · Kopplungs-Slice 5
```

Der Anker löst über `done/slice-<Kennung>.md` §7 auf; das §7 des Shell-Trägers nennt die Klasse **nicht** (sein Beleg ist mit der Closure des Geschwisters nachgetragen), das des Kopplungs-Slice trägt sie fünfmal.

**Gegen die Alternativen:**

| Ausgang | Warum nicht |
|---|---|
| Hard Rule (§3.6 erweitern, Architect, §3.8) | Eine Verschärfung, brauchte keine ADR (`AGENTS.md` §3.6, letzter Absatz), aber `AGENTS.md` steht in **jedem** Lauf im Kontext, und die Klasse trägt INFO-Gewicht, ist **laut** und wurde dreimal vom Review gefunden. Der Preis (Kontext in jedem Lauf) steht nicht im Verhältnis zum Schaden (ein Befund, eine Doku-Zeile). Bleibt als **Eskalation** (unten), falls die Klasse nach der Skill-Zeile erneut belegt wird |
| `MR`-Eintrag | Es gibt keine Abweichung von der Baseline (`MR-000`); ein `MR` ohne Abweichung ist keine Adaption |
| Gate | Ein Sensor, der eine Aufzählung gegen die Formen einer Sprache hält, ist nicht baubar: die Menge der Formen ist offen. Was baubar ist, ist die **Formen-Probe als Tabellentest** im Träger (der Shell-Träger führt sie bereits als Funktion) — Sache des Slice, der die Regel schreibt, nicht dieser Klasse |
| *geplant* (Slice) | Kein Slice fehlt: die Doku-Reparatur beider Sensor-Docs ist zwei Sätze, keine Lieferung. Ein Slice dafür wäre die Zeremonie, die die Sache nicht braucht |
| *gestrichen* | Die Klasse tritt am HEAD noch auf (zwei Formen ungenannt, oben gemessen) |
| Zeile im Implementer-Anweisungssatz (`ADR-0028`: der Implementer schreibt ihn) | Träfe den Autor, wo der Fehler entsteht, und ist die sinnvollere Zweitstelle — aber die Klasse ist am Träger **Review** gemessen, und dort wirkt sie heute. Ich schlage sie nicht vor; wer sie will, ist der Implementer-Lauf, nicht dieses Verdikt |

**Akzeptiertes Negativ, mit Grund:** die **Autor-Seite** bleibt offen. Solange der Implementer die Aufzählung ohne Formen-Probe schreibt, findet sie der Review — mit INFO-Kosten pro Vorgang und ohne Schaden am Bestand, weil die Folge am Gate laut ist. Das trägt, solange der Review sie findet; dass er sie dreimal fand, ist der Beleg.

### Textvorschlag für den Zielort (wörtlich, Übergabe an den Reviewer)

Zeile in `.harness/skills/reviewer.md`, in der Klassifikation unter **LOW/INFO** (der Reviewer setzt die Stufe nach der Wirkung, so wie sie hier steht):

```markdown
- **Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe** — eine Regel, die
  syntaktisch erkennt (Muster über Markdown, YAML, Pfade, Kommandozeilen), nennt in einer
  Doku, einem Test-Kopf oder einer Meldung ihre Grenzen als Liste oder Zahl („fünf Grenzen",
  „vier Ränder", „die Zeile"). Der Reviewer fährt die Formen der Sprache, über die die Regel
  spricht, selbst — bei Markdown-Links Titel, Spitzklammer-Ziel, Klammern im Ziel, Ziel hinter
  dem Zeilenumbruch, Referenz-Definition; bei YAML Block- statt Flow-Liste, andere
  Quotierung, anderer Schlüssel-Ort — und hält jedes Ergebnis gegen die genannte
  Aufzählung; er liest die Liste nicht nur. Eine gefahrene Form, die fehlt: INFO; LOW, wenn
  eine Meldung oder Anleitung aus der Lücke in die Irre schickt; HIGH nur, wenn kein Gate die
  Folge meldet (Stilles-Grün-Pfad, s. o.). Kein Gate fängt das
  ([`AGENTS.md`](../../AGENTS.md) §3.6; seit slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt)
```

Die Skill-Datei wird nicht überschrieben, sondern versioniert (`Pflege`): Version 2.0.0 → 2.1.0, Datum des Laufs.

### Kennzeichnung nach §3.6 und §3.7

**Grenze der Verkörperung (Klasse *Grenze*).** Ein Wächter existiert nicht: kein Sensor hält eine Aufzählung gegen die Formen einer Sprache, und `make comment-claims` prüft, ob ein genannter Sensor existiert, nicht, ob die Aufzählung vollständig ist. Träger ist der Review, der die Formen fährt; die Zeile deckt Doku, Test-Kopf und Meldung, die im Diff stehen, nicht den Bestand.

**Was passieren müsste, damit die Zusage bricht.** Ein Review-Report zu einem Diff, der die Grenzen-Aufzählung einer erkennenden Regel anfasst oder anlegt, trägt in der Negativbefund-Zeile keine gefahrene Form und lässt die Aufzählung passieren. **Gegenprobe, die der Reviewer beim Schreiben der Zeile fährt** (ich habe sie nicht fahren können, ich habe keinen Reviewer-Lauf): die Zeile am HEAD auf `harness/sensors/archive-welle.md` Punkt 8 angewandt muss die zwei ungenannten Formen (Klammern im Ziel, Ziel hinter dem Zeilenumbruch) als Befund liefern — die Suche oben belegt, dass beide dort fehlen. Färbt die Anwendung nichts, trägt die Zeile nicht.

**Eskalation.** Tritt die Klasse nach der Zeile erneut belegt ein (4. Beleg nach dem Skill-Stand), ist der nächste Schritt eine Falsch/Richtig-Zeile in `AGENTS.md` §3.6 (Architect, §3.8; Vorrat, **nicht** jetzt zu schreiben): *„Falsch: eine Aufzählung „N Grenzen" oder „vier Ränder", die die Formen der Sprache nicht gefahren hat. Richtig: die Formen fahren und je Form das Ergebnis nennen — oder die Aufzählung als nicht vollständig kennzeichnen."* Das ist §3.6s eigener Ausweg (*„die Zusage auf das einschränken, was der Code hält"*), auf die Aufzählung angewandt.

### Reihenfolge, damit „verkörpert" nicht vor der Deckung steht

1. Reviewer-Lauf schreibt die Zeile (eigener Commit, nur `.harness/skills/reviewer.md`), fährt die Gegenprobe.
2. **Danach** setzt der Planner `state.md` auf *verkörpert* (Zielort, Anker, Grenze; mit dem Kommando `grep -c 'seit slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt' .harness/skills/reviewer.md` → 1, wie im Präzedenzfall). Bis dahin steht die Beobachtung auf `offen` — Modul 6 lässt das zwischen dem Beleg, der auf 3 hebt, und dem Lese-Schritt ausdrücklich zu. Ein *verkörpert* vor der Zeile behauptete eine Regel, die nicht steht.
3. Die Instanz-Reparatur (zwei Sätze in `slice-mv.md` und `archive-welle.md`, die die zwei ungenannten Formen nennen) ist ein Implementer-Zug. Für die Shell-Fassung ist die Form **vorher zu fahren**: nur die Go-Fassung hat die Klammer-Sonde gesehen; ob `slice-mv.sh` dieselben Ränder hat, ist gelesen, nicht gemessen. Kein eigener Slice nötig, wenn ein Implementer-Lauf ohnehin die Docs anfasst; sonst bleibt es als Befund am HEAD sichtbar, und der Review der Zeile findet ihn (Gegenprobe oben).

---

## Frage 2 — Das Kästchen „Die drei Paarungen … getragen" bei roter Paarung (c), zweite Hälfte

**Verdikt: nicht „gegen die Wahrheit gesetzt" — aber nur unter einer Lesart, und die Lesart steht in keinem Rang, den §3.7 anerkennt.**

**Was ADR-0069 sagt und was nicht.** Festlegung 2 regelt die **Meldung**: die Closure nennt jedes Verzeichnis ohne Beleg **namentlich** und behauptet die Paarung nicht als getragen (*„nicht ‚getragen, mit Ausnahme'"*). Der Planner tut das in allen drei letzten Closures (vier Namen, Kommando, *„nicht als getragen behauptet"*). Zum **Kästchen** der DoD-Zeile sagt die ADR nichts; ihr Preis-Absatz setzt voraus, dass Closures unter dem Rot **weiterlaufen** (*„jede Closure trägt bis dahin die Zeile mit den Namen"*). Ein Kästchen, das bis zur Tilgung ungehakt bliebe, hielte jeden Slice vor `done/` fest — das kann die ADR nicht gemeint haben.

**Was das Regelwerk sagt.** Modul 5 kennt für DoD-Häkchen als Bedingung von `done/` **eine** Ausnahme (die Liefer-Punkte eines stillgelegten Slice); für eine rote Paarung gibt es keine. Aber die Zeile der Vorlage trägt ihre Lesart selbst: *„… sind getragen — im Repo ohne Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure"*, und Modul 6 legt fest, dass ein Repo mit Wellen eine Welle-Closure hat, *„die liest und prüft alles, was seit der letzten Welle in `done/` liegt — auch Slices ohne Wellen-Zugehörigkeit"*. Dieses Repo führt Wellen (`ls docs/plan/planning/welle-*.md` → `welle-09-…`, `welle-11-…`). **Unter dieser Lesart sagt das Kästchen: die Paarung ist gefahren und ihr Ergebnis steht in §7; die Welle-Closure prüft sie ein zweites Mal** — nicht: sie ist grün. Der Kommentar zur `structure`-Regel in `.d-check.yml` liest so, und die Lesart hat damit einen **Text** in der Baseline, nicht nur eine Gewohnheit.

**Wo es trotzdem dünn ist — das ist der Befund.**

1. Die Lesart steht **nur** in einem Konfigurations-Kommentar (kein Rang, `AGENTS.md` §3.7) und in den drei §7 der Slices, die sie anwenden. Das ist strukturell die Ausnahme, die `ADR-0069` in Alternative A verwirft: *„steht in keiner Norm, hat keine Grenze und keinen Träger"*. Sie ist heute besser als damals (sie nennt Namen und Kommando), aber sie ist dieselbe Bauart.
2. Das Kästchen bleibt bis zur Tilgung ein Kästchen, das ein Leser als „grün" liest. Zwei der vier Verzeichnisse haben **keinen** Weg zum Beleg vor einem künftigen Ereignis (der nächste Release-Schnitt, ein Vorgang, der die Messmethode am Skelett misst); das Rot ist für sie nach `ADR-0069` §Konsequenzen *„unbegrenzt"*.
3. Die Welle-Closure, an die das Kästchen verweist, findet **dasselbe Rot** und muss nach `ADR-0069` Festlegung 2 dieselben Namen nennen. Das Kästchen verschiebt die Frage dorthin, es beantwortet sie nicht.

### Die Wege, gemessen

| Weg | Wer schreibt | Trägt? |
|---|---|---|
| **A — die vier Verzeichnisse heilen** (Beleg oder Streichung) | Planner (Register, `state.md`/`evidence/`; §3.10) | **teilweise, jetzt nur für eine oder zwei.** `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`: die Aussage („sieben statt acht Sektionen") trifft nicht mehr zu (`grep -c '^## ' harness/README.md` → 8) — das Verzeichnis nennt selbst *gestrichen* mit Begründung als Weg; das ist ein Urteil des Planners, das Modul 6 zulässt (*„fällt die Ursache weg, bevor der Zähler 3 erreicht, wandert die Zeile mit Begründung in die gestrichenen"*). `planungs-bestand-waechst-schneller-als-er-abgebaut-wird`: Belege wären echt (der Planner urteilt je Vorgang), aber `ADR-0069` Festlegung 4 nennt die Folge — trifft die Klasse nahezu jede Closure, ist die 3×-Schwelle die Antwort, und dann steht ein Ausgang aus, der bis zu mir geht. Das ist keine Hygiene, das ist eine Entscheidung mit Folgearbeit; **der Planner wägt sie, nicht dieses Verdikt**. `ci-rennt-gegen-die-publikation-…` und `cpp-skelett-erfuellt-…`: **kein Weg heute** — beide hängen an künftigen Ereignissen, ein Verdikt über die Beobachtung ist nach `ADR-0069` Festlegung 3 kein Beleg |
| **B — Vorlage/Zeile ändern** | Norm (vendored Baseline nicht änderbar; eine repo-eigene Lesart der Zeile wäre eine Abweichung, `MR-000`, Architect **und** Auftraggeber) | **nein, nicht empfohlen.** Eine strengere Lesart (kein Kästchen unter Rot) bräche jede Closure bis zu Ereignissen, die niemand herbeiführen kann; eine lockerere, die das Kästchen entkoppelt, ist eine Senkung nach §3.5 gegen eine Prüfung, die die Baseline unbedingt formuliert |
| **C — Kästchen mit Ausnahme, dauerhaft** | Planner, wie bisher | **trägt als Interim**, mit einer Ergänzung: die Lesart steht **einmal** in einem Rang, damit die Ausnahme nicht Closure für Closure neu formuliert wird |

**Empfehlung: C mit dem Kern von A.** Keine Norm ändern; das Kästchen so lassen, wie es der Planner zuletzt gesetzt hat (Namen, Kommando, *„nicht als getragen behauptet"*, Verweis auf die Lesart). Zusätzlich, beides **Planner-Arbeit**, kein ADR:

1. **Die Lesart einmal ablegen.** `ADR-0069` Folgepflicht 1 verpflichtet den Planner, die Lesart des beleglosen Verzeichnisses in der Register-`README.md` zu tragen; ein Satz dort deckt das Kästchen mit: *„Das Kästchen der Paarungs-Zeile ist gesetzt, wenn die Paarung gefahren ist und ihr Ergebnis — bei Befund mit den Namen — in §7 steht; es sagt nicht, dass sie grün ist. Im Repo mit Wellen prüft die Welle-Closure sie erneut."* So hat die Lesart einen Ort im Rang 4/5-Umfeld statt in einem Konfigurations-Kommentar, und die §7 der Slices verweisen darauf, statt den Absatz nachzuformulieren.
2. **Den heilbaren Rest heilen, wenn der Planner das Register ohnehin fortschreibt** — `einstiegs-datei-…` (Streichung mit Begründung, falls der Planner die Aussage so liest), `planungs-bestand-…` (Belege, falls er die Vorgänge so urteilt, mit dem Wissen um die 3×-Folge). **Kein eigener Register-Hygiene-Slice:** er heilte höchstens zwei von vier und wäre für die anderen zwei ohne Gegenstand; das Rot der zwei übrigen bleibt sichtbar, und das ist der Zustand, den `ADR-0069` wählt.

Was die Empfehlung **nicht** tut: sie behauptet das Kästchen nicht als „grün", sie setzt keine Ausnahmeliste, und sie ändert kein Gate.

**Grund für die Abkürzung, ein Satz:** die Lesart des Kästchens hat einen Baseline-Text, die Meldung erfüllt `ADR-0069` Festlegung 2, und jeder strengere Weg bräche Closures an Ereignissen, die sich nicht herstellen lassen.

**Was passieren müsste, damit das Interim bricht:** eine Closure setzt das Kästchen und nennt die vier Namen nicht (dann ist es die Ausnahme ohne Meldung); oder ein fünftes Verzeichnis ohne `evidence/` entsteht und steht nicht in der Zeile. Die Schleife aus `ADR-0069` §Kontext fährt beides —

```sh
for d in docs/plan/planning/observations/BEO-ALL/*/; do
  n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done | wc -l   # 4, gelesen 2026-09-26, keine Erwartung
```

— und ist ein Kommando, das ein Lauf fährt, kein Sensor. **Ein Wächter existiert nicht.**

---

## Zustimmung des Auftraggebers

- **Frage 1:** nein. Eine Zeile im Reviewer-Skill ist Anweisungssatz der ausführenden Rolle (`ADR-0028`), keine Norm des Architect (§3.8); keine ADR entsteht, kein `Proposed`, kein Accept. Ausdrücklich angefragt wird nichts.
- **Frage 2:** nein für die Empfehlung (Register-`README.md` und `state.md` gehören dem Planner, die Lesart ist keine Abweichung). **Ja**, falls der Auftraggeber die strenge Lesart (kein Kästchen unter Rot) oder eine Entkopplung will: beides wäre eine Abweichung von der Baseline mit eigenem Eintrag im Adaptions-Block beziehungsweise eine Senkung nach §3.5, und ihre Annahme ist seine Entscheidung. Ich empfehle keine von beiden.

## Übergaben

| An | Artefakt |
|---|---|
| **Reviewer** | Zeile und Version 2.1.0 für `.harness/skills/reviewer.md` (Textvorschlag oben), Gegenprobe am HEAD auf `harness/sensors/archive-welle.md` Punkt 8 |
| **Planner** | `state.md` der Beobachtung erst **nach** der Zeile auf *verkörpert* (Anker, Grenze, Kommando); den einen Satz zur Lesart des Kästchens in die Register-`README.md`; das Urteil über die zwei heilbaren Verzeichnisse; den Zähler-Stand der drei Nachbarn unverändert |
| **Implementer** | Instanz-Reparatur: die zwei ungenannten Formen in beide Sensor-Docs, für die Shell-Fassung nach eigener Probe |

## Was offen bleibt

- Ob der dritte Beleg als Klasse zählt, urteilt der Planner; der Ausgang trägt in beiden Lesarten.
- Die Autor-Seite ist ein akzeptiertes Negativ, mit Eskalation auf §3.6 beim vierten Beleg nach der Zeile.
- Die Gegenprobe der Zeile ist von mir nicht gefahren (kein Reviewer-Lauf) und liegt beim Reviewer, der sie schreibt.
- Zwei Verzeichnisse ohne Weg zum Beleg (`ci-rennt-…`, `cpp-skelett-…`): das Rot bleibt nach `ADR-0069` sichtbar; `ADR-0069` Trigger 1 löst erst aus, wenn der Planner urteilt, dass eines **nie** einen Vorgang trifft.
