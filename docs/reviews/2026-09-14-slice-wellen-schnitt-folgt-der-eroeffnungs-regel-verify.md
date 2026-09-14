# Verifikation slice-wellen-schnitt-folgt-der-eroeffnungs-regel — Die drei lebenden Träger des Wellen-Schnitts lehren die geltende Arbeitsweise

**Rolle:** Verifier · **Datum:** 2026-09-14 · **Geprüfte Commits:** `a9138e86` (welle-13),
`fdb5465a` (roadmap.md), `bf5e5bca` (plan-welle.md), `233e1385` (Review-Nachzug F-1/F-2/F-3) ·
**Plan:**
[`slice-wellen-schnitt-folgt-der-eroeffnungs-regel`](../plan/planning/done/slice-wellen-schnitt-folgt-der-eroeffnungs-regel.md)
· **Review:**
[`2026-09-14-…`](2026-09-14-slice-wellen-schnitt-folgt-der-eroeffnungs-regel.md) (2 MEDIUM · 1 LOW
· 2 INFO, Verdikt: blockierend wegen 2 MEDIUM — beide durch `233e1385` behoben) ·
**Prüfgegenstand:** DoD und [`ADR-0046`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
— nicht Plan/Hard Rules, das ist Reviewer-Sache. `make gates` nicht selbst gefahren
(Docker-only, `AGENTS.md` §3.9); Beleg über den inhaltsbasierten Working-Tree-Hash.

---

## 1. Ist der Sensor gelaufen?

```sh
cat .harness/state/gates-passed.diffsha
# ef3baf6ee0ddc8b64ba1325d7e30a93f144e2350d0bfde122efec25513561066
bash harness/tools/working-tree-hash.sh
# ef3baf6ee0ddc8b64ba1325d7e30a93f144e2350d0bfde122efec25513561066
git status --porcelain
# (leer)
```

Deckungsgleich, Baum sauber, kein Docker-Ziel selbst gefahren. Der aufgezeichnete Nachweis deckt
den Stand **nach** `233e1385` — die Review-Nacharbeit ist im geprüften Hash enthalten, nicht nur
die ursprüngliche Lieferung.

## 2. Deckt der Sensor die Zusage? — DoD (3)

Alle sieben §1-Kommandos in diesem Lauf selbst neu gefahren, keine Zahl aus Review oder
Commit-Message übernommen:

```sh
grep -c 'aktive bzw. geplante' .claude/commands/plan-welle.md                                       # 0
grep -c 'Ob eine flache Welle \*aktuell\* oder \*geplant\* ist' .claude/commands/plan-welle.md      # 0
grep -c 'aktiv/geplant' .claude/commands/plan-welle.md                                              # 0
grep -c 'geplant' .claude/commands/plan-welle.md                                                    # 1
grep -c 'Ein verlinkter Name hat eine flache Plan-Datei' docs/plan/planning/in-progress/roadmap.md  # 0
grep -c 'Ein Sensor nach \[slice-125\]' docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md # 0
grep -c 'roadmap.md) unter \*Offene Wellen\*' docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md  # 0
```

Der einzige Resttreffer (Kommando 4, Zeile 6 in `plan-welle.md`: *„… das gemeinsam geplant und
geschlossen wird"*) setzt nichts mit der flachen Datei gleich — DoD (3) ist wörtlich erfüllt, nicht
nur plausibel. Zusätzlich auf eine fünfte, neu entstandene Gleichsetzung geprüft
(`grep -c 'Aktuelle Welle' .claude/commands/plan-welle.md` → `0`) — keine gefunden.

## 3. Sagt der Plan, was der Code tut? — DoD (1)–(3) gegen die vier Commits

**DoD (1) — `welle-13` §1 Punkt 2:** Zahlen-Diff über die ganze Datei selbst nachgefahren:

```sh
diff <(git show a9138e86^:docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md | grep -oE '[0-9]+') \
     <(git show a9138e86:docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md  | grep -oE '[0-9]+')
# 91,93c91,93 < 11/125/125 (aus "welle-11", "slice-125"×2) > 0046/0046/1 (zwei ADR-Kennungen, eine Festlegungs-Nummer)
git show a9138e86 --format= -U0 | grep '^@@'   # genau ein Hunk, @@ -79,7 +79,7 @@
```

Kein Messwert des Absatzes berührt, ein Hunk, exakt Punkt 2. **Erfüllt.**

**DoD (2) — `roadmap.md` §Nächste Wellen:** Der alte Satz ist ersetzt (nicht mehr auffindbar), der
neue trägt nach dem Review-Nachzug `233e1385` die Spalten-Grenze (*„einer hier in **Spalte 1**
genannten Kennung"*, Zeile 35) — vor dem Nachzug fehlte sie (F-1). Das Gegenbeispiel-Paar aus
`fdb5465a` (`wave-preview-exists` bei Lage 1, `wave-drift` + `wave-preview-exists` bei Lage 2, je
mit Kommando/Fundstelle/EXIT) ist in der Commit-Message dokumentiert und arithmetisch konsistent
(Review hat die Zeilennummern gegengerechnet; hier nicht erneut reproduziert, da das rot-Sehen
selbst — nicht seine Wiederholbarkeit — die Zusage aus §3.6 trägt). **Erfüllt.**

**DoD (3) — `plan-welle.md`:** Siehe §2 oben. Zusätzlich: Der Review-Nachzug `233e1385` hat die
Gate-Zusage im Kopf (F-2) auf die tatsächliche Modul-Reichweite verengt. Wörtlicher Abgleich gegen
`ADR-0046` §Fitness Function:

```sh
grep -n 'kein Sensor' .claude/commands/plan-welle.md
# 21:nicht der Start-Trigger selbst: Träger dieser Folgepflicht ist der Rollen-Wechsel und kein Sensor
```

Deckt sich wörtlich mit `ADR-0046` §Fitness Function, letzter Satz: *„Träger der dritten
Folgepflicht ist darum der Rollen-Wechsel und kein Sensor."* Ein Zitat, keine neue Behauptung —
genau das, was der Auftrag verlangte. Ebenso F-1s Fix (*„… genannten Kennung"* → *„… in **Spalte
1** genannten Kennung"*) deckt sich wörtlich mit der Tabellenzeile 2 derselben ADR-Sektion. **Beide
MEDIUM-Findings sind sachlich behoben, keine neue Zusage entstanden.** **Erfüllt.**

## 4. F-4 (INFO) — welche Formulierung gilt bei der Closure?

**DoD (3).** §5 Kriterium 1 behandelt Kommando 4 fälschlich wie die anderen sechs Muster-Treffer,
obwohl §1 selbst festhält, dass Kommando 4 kein Muster für eine überholte Formulierung ist, sondern
der Fundmengen-Zähler — ein legitimer Resttreffer (`1`) ist deshalb kein Fehlschlag, sondern der
plangemäße Zustand. §5 ist damit die ungenauere von zwei Formulierungen desselben Punkts und
gehört bei Gelegenheit an DoD (3) angeglichen, nicht umgekehrt.

## 5. Register, §6-Risiken, Out-of-Scope

Beobachtungs-Register unverändert (§8 des Plans nennt drei Treffer unter der Schwelle, keiner
erreicht mit diesem Slice 3×) — korrekt: dieser Slice ist noch nicht geschlossen, das Fortschreiben
ist Planner-Arbeit (`AGENTS.md` §3.10). Die vier §6-Risiken tragen `<eingetreten / entfallen /
weiter offen — bei Closure zu setzen>` — korrekter Zwischenstand für `in-progress/`. Out-of-Scope
(§1) vollständig gehalten: `git show --stat` aller vier Commits zeigt ausschließlich die drei
genannten Träger, keine ADR, kein `AGENTS.md`/`harness/conventions`, keine emittierte Vorlage, kein
`close-welle.md`, kein Produkt-Code. Slice-Plan selbst unangetastet (keine DoD-Häkchen gesetzt,
§6/§7 leer) — §3.10 gewahrt.

## Was ich nicht erneut geprüft habe

- Die Zeilenarithmetik der zwei rot gesehenen Gegenbeispiele in `fdb5465a` (Review hat sie bereits
  gegengerechnet; das erneute Reproduzieren würde denselben temporären Bestandszustand herstellen,
  den der Review schon dokumentiert hat).
- F-3 (LOW, Schritt 8 in der Aussetzungs-Liste) und F-5 (INFO) — beide sind Review-Findings ohne
  DoD-Bezug, siehe Folge-Auftrag unten.

## Verdikt

**DoD erfüllt.** Alle drei Liefer-Punkte sind wörtlich und nicht nur plausibel erbracht, der
Review-Nachzug (`233e1385`) hat beide MEDIUM-Findings sachlich und mit Zitat statt neuer Behauptung
behoben, `make gates` deckt den Stand nach dem Nachzug (Hash deckungsgleich), Out-of-Scope und
§3.10 sind gewahrt.

**Was der Planner abhaken darf:**

- DoD (1): ja — Zahlen-Diff bestätigt, ein Hunk, Messzahlen unangetastet.
- DoD (2): ja — Satz ersetzt, Spalten-Grenze nachgezogen, zwei Gegenbeispiele real rot gesehen.
- DoD (3): ja — alle vier Fundstellen bei `0`, Fundmengen-Zähler bei `1` ohne Gleichsetzung, keine
  fünfte Stelle entstanden, Gate-Zusage auf Modul-Reichweite verengt.
- `make gates` grün: ja — Hash-Deckung über dem Stand nach `233e1385`.
- Review durchgeführt: ja — Report liegt vor, ursprünglich blockierend, Nachzug behebt beide
  MEDIUM.

**Folge-Slice-Auftrag** (F-5, aus dem Review übernommen — vier lebende Reststellen tragen die alte
Lesart weiter, bewusst außerhalb der DoD dieses Slice):
`docs/plan/planning/README.md:26`, sowie die `Lifecycle:`-Kopfnoten von
[`welle-09`](../plan/planning/welle-09-modul-15-konformitaet.md),
[`welle-11`](../plan/planning/welle-11-traeger-aussage.md) und
[`welle-13`](../plan/planning/welle-13-regeln-bekommen-ihren-sensor.md) (je der Satz *„Ob eine
flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap"*).
