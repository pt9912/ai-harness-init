# Verifikation — slice-201: Der Inline-Pfad in den vendored Baum bekommt einen Prüfer — oder eine benannte Grenze

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-09-08

**Prüfgegenstand:** `HEAD` = `f99aca04`, Arbeitsbaum sauber (`git status --porcelain` leer vor und
nach diesem Lauf). Slice-Commits: `96c0ada2` (Move), `99109d33` (Verweis-Nachzug), `f5189bba`
(Umsetzung), `b63fff33` (Review, blockierend — 3 HIGH/5 MEDIUM/2 LOW/2 INFO), `f99aca04`
(Review-Nacharbeit HIGH-1/HIGH-2).

**Prüfgrundlage:** die **ursprüngliche** DoD (`git show f5189bba^:…slice-201-….md`), nicht die
heutige — die heutige ist laut Review-Report HIGH-3 im Implementations-Commit selbst umgeschrieben
worden (Planner-Sache, unten bestätigt und nicht verändert). Dazu der Review-Report
(`2026-09-08-slice-201-codepaths-vendored-baum-review.md`), `AGENTS.md` §3.6/§3.7/§3.10/§3.11,
`MR-025` Setzung 1, `LH-QA-01`/`LH-QA-02`. **Ich bin der erste Kontext, der die DoD prüft** — der
Reviewer hat sie ausdrücklich ausgenommen. **Kein Self-Review:** dieser Lauf hat weder `f5189bba`
noch `f99aca04` geschrieben.

---

## Gate-Stand (selbst gefahren)

`make docs-check` → **977 Datei(en) geprüft, 0 Befund(e)**. `make baseline-verify` → **v6.5.0 OK —
54 Dateien**. `make gates` (voller Lauf, alle zehn Ziele) → **Exit 0**, Arbeitsbaum danach
weiterhin sauber. Deckt sich mit dem im Nacharbeits-Commit protokollierten Stand.

---

## Die drei Fixtures — unabhängig reproduziert

Eigenes Sonden-Paar, außerhalb des Arbeitsbaums, gepinnter Digest `sha256:e31a372b…`, drei
erfundene Inline-Pfade in einem Dokument unter `docs/`:

| Fixture | Pfad-Form | `roots: […harness]` | `roots: […harness, .harness]` |
|---|---|---|---|
| a | außerhalb, `harness/does-not-exist-201.md` | rot | rot |
| b | innerhalb, mit `/baseline`-Segment | **stumm** | rot |
| c | innerhalb, **ohne** `/baseline`-Segment (Kontrolle) | **stumm** | rot |

Ergebnis deckungsgleich mit der Zusage: **1 Befund(e)** im ersten Lauf, **3 Befund(e)** im zweiten.
Fixture c ist die Kontrolle, die `scan.ignore` als Ursache ausschließt — sie trägt kein
`.harness/baseline/**`-Präfix und bleibt trotzdem stumm, solange `.harness` nicht in `roots` steht,
und färbt rot, sobald es dort steht. Die Diagnose (`roots` als Präfix-Zeichenkette, nicht
`scan.ignore`, kein Ventil) ist damit **bestätigt**, unabhängig vom Implementations- und
Review-Lauf.

---

## Die 128 — vor und nach diesem Bericht

Über einem frischen `git clone --local --no-hardlinks` von `f99aca04`, `roots` um `.harness`
ergänzt:

```
$ grep -c codepath-missing lauf.txt
128
```

Deckungsgleich mit dem im Nacharbeits-Commit `f99aca04` abgedruckten Wert (HIGH-1 ist damit
**behoben** — die zuvor falsche 122 ist korrigiert). **Nach dem Schreiben dieses Berichts** wurde
derselbe Klon erneut vermessen, diesmal mit diesem Bericht im Baum
(`docs/reviews/2026-09-08-slice-201-codepaths-vendored-baum-verify.md`): weiterhin **128**. Dieser
Bericht verändert die Zahl nicht — er nennt tote `.harness/`-Pfade ausschließlich in Fließtext ohne
Inline-Code-Formatierung (Fixture-Beschreibung oben ausgenommen, die reale, existierende Pfade
zitiert) und trägt keinen Markdown-Link in den vendored Baum.

---

## Die Aufschlüsselung 102 / 26 / 6 — geprüft, mit einem offenen Rest

Die zwei Abzüge (102 in den drei genannten Nicht-Bug-Klassen, macht 26 Rest) sind über derselben
Lauf-Datei nachgerechnet und **korrekt**:

```
$ awk -F'\t' '$2 ~ /^\.harness\/(baseline|state|cache)/' lauf.txt | grep -c codepath-missing
102
$ awk -F'\t' '$2 !~ /^\.harness\/(baseline|state|cache)/' lauf.txt | grep -c codepath-missing
26
```

Die **6 echte Fundstellen**, die der Absatz aus den 30 `\.harness/baseline/`-Treffern plus einer
Stelle „anderer Form“ zieht, sind ebenfalls exakt nachvollziehbar (fünf Slice-/Welle-Pläne mit
einem `.harness/baseline/<abgelöster Tag>/…`-Pfad, eine Skill-Datei mit totem
Vorlagen-Verweis) — dieser Teil der Zusammenfassung **trägt**.

**Der Rest von 26 trägt sie nicht vollständig.** Die 26 zerfallen — geprüft Ziel für Ziel — in zwei
Gruppen:

- **19 in eingefrorenen bzw. archivierten Artefakten:** zehn Treffer eines abgelösten
  `.gitignore`-Verweises und zwei eines abgelösten Skeleton-Verweises, alle in `done/`
  (Zeitdokument nach `AGENTS.md` §3.7 Geltungsbereich); ein Treffer in einer nach `AGENTS.md` §3.4
  angenommenen ADR; ein Treffer in einer nach Merge unveränderlichen `evidence/`-Datei des
  Beobachtungs-Registers; fünf weitere Treffer desselben toten Skill-Pfads unten in ebenfalls
  eingefrorenen bzw. archivierten Stellen (eine ADR, drei `done/`-Slices).
- **6 in lebenden, unveränderten Artefakten**, alle mit demselben Ziel — einem toten Verweis auf
  eine Skill-Datei, die im Repo nicht existiert (`ls .harness/skills/` führt nur eine Datei) —, in:
  der laufenden Roadmap, zwei offenen Slice-Plänen und drei flachen, noch offenen Welle-Plänen.

Diese sechs sind mechanisch identisch zu der Klasse, die der Absatz misst — ein Inline-Pfad unter
`.harness/`, der wegen der `roots`-Präfixlücke dauerhaft gate-unsichtbar bleibt, in einem
**lebenden** Artefakt —, und sie fallen unter keine der beiden benannten Ausschlussklassen (nicht
der eigene Beleg-Pfad des Plans, kein `$(BASELINE_TAG)`-Platzhalter). Der Absatz erwähnt sie an
keiner Stelle: Die Formulierung „der Rest zählt sechs Fundstellen, nicht null“ zählt in Wahrheit
**zwölf**, sofern man dieselbe Definition von „echt“ anlegt, die der Absatz für die
`\.harness/baseline/`-Treffer verwendet. Ob der fehlende Pfad eher als **geplanter,
roadmap-geführter Rückstand** (er ist an anderer Stelle im Repo bereits als bekannte Lücke geführt,
mit eigenem Kandidaten-Slice) oder als derselbe „echte Fund“ zu werten ist, ist eine Einordnung,
die der Absatz nicht trifft — er zählt ihn schlicht nicht mit, obwohl die Sonde ihn liefert.

**Das ist dieselbe Fehlerklasse wie HIGH-2**, nur an einer anderen Stelle derselben Lauf-Ausgabe:
Der HIGH-2-Fix hat die 30 `\.harness/baseline/`-Treffer vollständig durchgezählt, aber die
verbleibenden 26 nicht — dort wurde nur ein einzelner Fund („andere Form“) herausgegriffen, ohne
den Rest zu klassifizieren. Review hat dieselbe Engführung: Die HIGH-2-Kommandos filtern ebenfalls
nur auf `^\.harness\/baseline\/`, prüfen also dieselbe Teilmenge, in der HIGH-2 schon gefunden
wurde, nicht die komplementäre. Dieser Befund ist daher ein **Verifier-only-Fund** — für Review
unsichtbar, weil dessen Sonde denselben blinden Fleck hatte.

---

## DoD, Punkt für Punkt (ursprüngliche Fassung)

1. **Die Ursache ist gemessen, nicht gelesen.** — **erfüllt**, oben unabhängig reproduziert.
2. **Der Ausgang ist gewählt und belegt: Prüfer oder benannte Grenze.** — **teilweise erfüllt.**
   Der Ausgang (benannte Grenze) ist die richtige Wahl angesichts der 102/128 Nicht-Bug-Treffer und
   der ADR-0039-Analogie; die Zahl ist nach der Nacharbeit korrekt (128, nicht mehr 122). Der
   *Beleg*-Teil des Punktes — die Vollständigkeit der Zusammenfassung — trägt nicht ganz: siehe
   §Aufschlüsselung oben, sechs echte Fundstellen fehlen in der Zählung. Das ursprüngliche
   Liefer-Punkt-2 enthielt die Klausel *„Ein dritter Ausgang existiert nicht: … bleibt eine
   Vollständigkeits-Zeile stehen, die mehr behauptet als sie trägt“* — genau das trifft auf den
   heutigen Absatz noch zu, nur eine Stufe tiefer als der ursprüngliche Text meinte (nicht „Prüfer
   oder Grenze“ fehlt, sondern die Grenze selbst ist unvollständig beschrieben).
3. **Das Gegenbeispiel ist rot gesehen.** — **erfüllt**, oben unabhängig reproduziert; dieselbe
   Einordnung wie Review-INFO-1 (rot gesehen ist die Kontrolle, nicht die Grenze selbst — richtige
   Beleglage, falsch benannt, kein blockierender Punkt).
4. **`make gates` grün.** — **erfüllt**, siehe §Gate-Stand.
5. **Review durchgeführt, Report liegt vor.** — **erfüllt**:
   `docs/reviews/2026-09-08-slice-201-codepaths-vendored-baum-review.md`, Rollenwechsel gewahrt
   (Reviewer ≠ Implementer ≠ dieser Lauf).
6. **Doku-Update für <Schnittstelle X> falls öffentlicher Vertrag berührt.** — **erfüllt in der
   Sache** (`harness/README.md` §Sensors trägt den neuen Absatz), **mit einem Fund**: Die
   DoD-Zeile selbst zitiert an zwei Stellen noch die Zahl 122 (`grep -n '122'
   …slice-201-….md` → zwei Treffer), obwohl `harness/README.md` seit `f99aca04` 128 zeigt. Ein
   Leser, der der abgehakten DoD-Zeile statt dem Zieldokument traut, bekommt eine überholte Zahl —
   dieselbe Klasse wie MEDIUM-4 im Review (Aussage ohne Stand), hier als Drift zwischen zwei
   Artefakten desselben Slice statt als fehlender Stand.
7. **Closure-Notiz mit Steering-Loop-Lerneintrag.** — **nicht fällig**, korrekt unangehakt und als
   Planner-Arbeit (`AGENTS.md` §3.10) markiert.
8. **Reconciliation-Register fortgeschrieben, falls …** — **erfüllt** (entfällt): Die Datei
   existiert nicht (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden), wie im Slice-Kopf
   begründet.
9. **Beobachtungs-Register fortgeschrieben.** — **nicht fällig**, korrekt als Planner-Arbeit
   markiert. Für die Closure ist zu beachten: der Zähler für die Klasse „Zusammenfassung stärker
   als ihre Quelle“ steht bei **2** Belegen (`ls
   docs/plan/planning/observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/evidence/*.md
   | wc -l`); mit dem Beleg dieses Slice (der sowohl HIGH-2 als auch den obigen Rest-Fund trägt —
   ein Vorgang, ein Beleg) erreicht er die Schwelle 3×, wie Review bereits notiert hatte.
10. **Jedes Risiko aus §6 trägt einen Ausgang.** — **nicht fällig**, Planner-Arbeit. Zur Information
    für die Closure: Risiko 1 („vermutete Ursache falsch“) ist widerlegt und schließt mit
    *entfallen*; Risiko 2 („Anheben deckt mehr auf“) ist eingetreten (102/128 Zusatzbefunde
    gemessen); Risiko 3 („Grenze ist Nicht-Änderung“) ist eingetreten und im Text als Lücke
    benannt, aber — siehe oben — nicht vollständig; Risiko 4 („Bestand blockiert eigenen
    Gate-Lauf“) ist *entfallen*, weil `roots` nicht angehoben wurde.
11. **Die drei Paarungen sind getragen.** — **nicht fällig**, Planner-Arbeit (wellenlos, hier bei
    Closure zu prüfen).

**Zu HIGH-3 (fremdes Rollen-Artefakt):** eigenständig nachgezählt und mit dem Review-Report
deckungsgleich — 6 neu gesetzte Häkchen, 9 ersetzte DoD-Zeilen, 11 DoD-Zeilen gesamt, drei
geänderte Dateien in `f5189bba`. Bleibt **offen und Planner-Sache**, wie im Auftrag benannt; dieser
Lauf ändert daran nichts.

---

## Plan-vs-Code (gegen die ursprüngliche Fassung)

**§1 Ziel und Abgrenzung:** Der gewählte Ausgang (benannte Grenze) und die vier Ausschlüsse
(`ignore-refs`-Ventile als eigener Vorgang, Prüfbereich außerhalb `.harness` als eigene Stufe, der
Bestand toter Baseline-Pfade als eigener Vorgang „findet sie viele“, die emittierte Fassung
außerhalb) sind eingehalten — `.d-check.yml` ist im gesamten Slice unberührt
(`git show --pretty=format: --name-only f5189bba f99aca04 | grep -c '.d-check.yml'` → `0`). Der
dritte Ausschluss trägt genau den Fund, den §Aufschlüsselung oben vertieft: „findet sie viele, ist
das ein eigener Vorgang“ — die Sonde findet 128, der Ausschluss greift korrekt, nur die
*Darstellung* dessen, was schon gefunden wurde, bleibt unvollständig.

**§3 Plan (vor Code):** Alle drei angekündigten Zeilen treffen zu — `.d-check.yml` unverändert
(Grenze fasst die Config nicht an), `harness/README.md` §Sensors aktualisiert, keine sonstigen
lebenden Artefakte angefasst (der Plan sagte „nur falls die Messung welche findet — findet sie
viele, greift §1 dritter Ausschluss“, und genau das ist eingetreten).

**§4 Trigger:** Start-Trigger „`make gates` grün“ war laut Plan am Erstellungstag unerfüllt
(wartete auf `slice-197`) — inzwischen erfüllt, keine Diskrepanz. Die Rückführungs-Bedingungen
(„zu groß“, „blockiert durch anderen roten Grund“) sind nicht eingetreten; zutreffend, denn der
gewählte Ausgang ist die *benannte Grenze*, die den größten Teil des möglichen Scope-Zuwachses
(das Anheben von `roots`) explizit vermeidet.

**MEDIUM-2 des Reviews** (benannte Grenze ohne Folge-Slice-Kennung, obwohl §8 „sie bekommt ihren
Ausgang mit demselben Slice, nicht später“ zugesagt hatte) bleibt bei eigener Prüfung **bestätigt**:
kein Slice unter `open/` oder `next/` nennt `slice-201`
(`git grep -ln 'slice-201' -- docs/plan/planning/open docs/plan/planning/next` → leer). Mit dem
obigen Fund (sechs statt einer Fundstelle unentdeckt) wird diese fehlende Adresse **dringlicher**,
nicht weniger.

---

## Urteil zur benannten Lücke

**Trägt der gewählte Ausgang (benannte Grenze statt Prüfer)?** Ja — die Entscheidung selbst ist
durch die Fundmenge gedeckt: 102 von 128 zusätzlichen Befunden liegen tatsächlich in den drei
genannten Nicht-Bug-Klassen, ein Prüfer bräuchte eine mehrteilige, aufwendige Ausnahme-Apparatur,
und das sprengt den Umfang dieses Slice. **Trägt die Darstellung der Grenze?** Nein, nicht
vollständig — die Zusage „6 echte Fundstellen“ ist eine Vollständigkeits-Zeile im Sinne von
`AGENTS.md` §3.6/HIGH-2-Klasse, die mehr behauptet, als sie hält: eine unabhängige, vollständige
Zählung über derselben Lauf-Ausgabe liefert zwölf, nicht sechs, wovon sechs — alle desselben
Ziels — in aktuell offenen Planungsartefakten liegen. **Bleibt eine Zusage stehen, die unter
keiner Mutation rot werden kann?** Ja, aus demselben Grund wie beim ursprünglichen HIGH-1/HIGH-2:
kein Modul aus `modules:` der `.d-check.yml` hält eine Zahl in Prosa gegen einen Lauf, und
`make mutate` kennt keine Fehlschlag-Form für eine Zähl-Behauptung in einem Fließtext-Absatz. Der
Befund ist reproduzierbar, aber nicht gate-gedeckt — Verifier-only in genau dem Sinn, den `AGENTS.md`
§Kern der Rolle beschreibt.

---

## Was offen bleibt (Übergabe an den Planner)

- **HIGH-3** (neun ersetzte, sechs abgehakte DoD-Zeilen) — unverändert offen, wie im Auftrag
  benannt; dieser Lauf bestätigt Zahlen und Umfang nur erneut.
- **Neuer Fund dieses Laufs:** die Aufschlüsselung 102/26/6 in `harness/README.md` unterzählt den
  Rest der 26 — sechs statt einer echten Fundstelle bleiben unerwähnt, alle mit demselben Ziel
  (eine im Repo fehlende Skill-Datei), alle in lebenden Planungsartefakten (Roadmap, zwei offene
  Slice-Pläne, drei flache Welle-Pläne). Empfehlung an den Planner: entweder den Absatz um diese
  sechs ergänzen (mit derselben Sonde reproduzierbar) oder ausdrücklich begründen, warum dieses
  Ziel — anders als die fünf Baseline-Tag-Treffer — nicht als „echter Fund“ dieses Slice zählt
  (es ist an anderer Stelle im Repo bereits als bekannter, roadmap-geführter Rückstand notiert;
  ob das als Ausschlussgrund trägt, ist eine Einordnung, die bisher nirgends explizit getroffen
  wurde).
- **Stale Zahl in der DoD-Zeile** (122 statt 128, zwei Stellen) — im selben Zug korrigierbar, wenn
  der Planner die DoD-Häkchen bei Closure ohnehin anfasst.
- **MEDIUM-2** (fehlende Folge-Slice-Kennung für die benannte Grenze) — bestätigt offen, jetzt mit
  einem größeren Rest als bei der ersten Messung.
- **MEDIUM-3** (Register-Eintrag `gate-modul-erreicht-den-vendored-baum-nicht` hält einen
  widerlegten Satz in `state.md`) — nicht erneut geprüft, Review-Befund unverändert zu übernehmen.
- **Beobachtungs-Register:** Beleg für `zusammenfassung-staerker-als-ihre-quelle` bei Closure
  anlegen (Zähler geht damit von 2× auf 3×, Schwelle erreicht) — der Beleg sollte HIGH-2 **und**
  den obigen Rest-Fund als einen Vorgang tragen.
- **Risiken §6, Register-Fortschreibung, drei Paarungen** — Planner-Arbeit bei Closure, siehe
  DoD-Punkte 9–11 oben für die vorbereiteten Einordnungen.

**Verdikt:** Die **Sache** des Slice trägt — Diagnose gemessen, Ausgang begründet gewählt,
Gegenbeispiel rot gesehen, `make gates` grün. HIGH-1 ist korrekt behoben. HIGH-2 ist in der
geprüften Teilmenge korrekt behoben, aber derselbe Fehlertyp besteht unentdeckt in der
komplementären Teilmenge derselben Lauf-Ausgabe fort — kein neuer Blocker der gleichen Schwere wie
das ursprüngliche HIGH-2 (die Sache selbst, „benannte Grenze“, ändert sich dadurch nicht), aber ein
zusätzlicher Korrekturbedarf, den weder Review noch der Implementer-Fix bisher gesehen haben.
Kombiniert mit dem unverändert offenen HIGH-3 bleibt der Slice **nicht abschlussreif** ohne
Planner-Entscheidung zu: (a) den neun umgeschriebenen DoD-Zeilen, (b) der unvollständigen
102/26/6-Aufschlüsselung, (c) der fehlenden Folge-Slice-Kennung.
