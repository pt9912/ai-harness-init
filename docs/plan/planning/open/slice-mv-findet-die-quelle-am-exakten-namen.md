# Slice slice-mv-findet-die-quelle-am-exakten-namen: `slice-mv` findet die Quelle zuerst am exakten Namen

**Kennung:** benannt nach [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 1.

**Lifecycle:** Der Zustand ist das Verzeichnis, in dem diese Datei liegt; er wechselt nur durch `git mv`.

**Welle:** ohne Welle — kein repo-weiter Beleg über die DoD hinaus.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die Meldung `mehrdeutig` behauptet eine Mehrdeutigkeit, die der volle Name nicht hat), [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) (benannte Kennungen sind volle Namen ohne Nummern-Kurzform), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung

**Ziel:** `slice-mv` löst `SLICE=<voller Name>` zuerst als exakte Datei `${SLICE%.md}.md` in genau einem Lifecycle-Verzeichnis auf und fällt **nur ohne exakten Treffer** auf den Präfix-Glob zurück — die Kurzform `slice-174` des Bestands bleibt eindeutig.

Der Fund: Der Block „Quelle finden" (`harness/tools/slice-mv.sh:318`, wortgleich in `internal/emit/templates/enforce/slice-mv.sh:197`) globbt `"${SLICE%.md}"*.md` und bricht bei zwei Treffern mit `mehrdeutig` ab. Ist ein Name Präfix eines anderen (`slice-abc` und `slice-abc-erweitert`), ist der **volle** Name nie eindeutig adressierbar. Heute tritt es nicht auf — gemessen über die Namensliste `ls docs/plan/planning/{open,next,in-progress,done}/slice-*.md | sed 's#.*/##;s/\.md$//' | sort -u | wc -l` (keine Erwartungswerte) und je Name gegen jeden anderen `index(n[j],n[i])==1` in `awk`: kein Name ist Präfix eines anderen —, aber benannte Kennungen ohne Nummer machen es möglich.

**Ausdrücklich NICHT in diesem Slice:**

- **Die Verweis-Umschreibung** (eingehend/ausgehend, `psed_i`): sie arbeitet am exakten Basisnamen und ist von der Quellensuche unabhängig. *Anderer Vorgang.*
- **Eine Namensregel, die Präfix-Namen verbietet.** Eine Vergabe-Regel wäre Norm ([`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer), Architect); der Slice macht das Werkzeug robust, statt die Vergabe zu beschränken.
- **Mehr Eindeutigkeit für den Rückfall.** Ein Präfix wie `slice-abc` für `slice-abc-erweitert` bleibt als Rückfall erlaubt, wenn es kein exakt `slice-abc.md` gibt.

## 2. Definition of Done

- [ ] **(1) Exakter Treffer zuerst, in beiden Fassungen.** `harness/tools/slice-mv.sh` und `internal/emit/templates/enforce/slice-mv.sh` suchen `${SLICE%.md}.md` über die Lifecycle-Verzeichnisse; genau ein Treffer gewinnt, auch wenn der Präfix-Glob mehrere findet. Ohne exakten Treffer gilt der bisherige Präfix-Glob samt `kein Slice`/`mehrdeutig`.
- [ ] **(2) Die Gegenbeispiele sind rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): Name ist Präfix eines anderen → mit vollem Namen eindeutig (`slice-abc` neben `slice-abc-erweitert`); Kurzform `slice-174` des Bestands bleibt eindeutig; `slice-13` in Gegenwart von `slice-130` bleibt als Präfix-Fall mehrdeutig. `test/slice-mv.bats` und ein Mutations-Fall (exakter Zweig entfernt → Fall rot).
- [ ] **(3) Das Ziel fährt es:** `make full-smoke` nutzt `slice-mv` im gebootstrappten Ziel; die emittierte Fassung trägt den Zweig, der Lauf bleibt grün (gelesene Ausgabe), die Gleichheit beider Fassungen hält `internal/emit/slicemv_test.go`.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Doku-Update: [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md), falls es die Suche beschreibt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben (kein Zähler wird gesetzt); keine Beobachtung angefallen ist ebenfalls eine Antwort.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang.
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/slice-mv.sh`, `internal/emit/templates/enforce/slice-mv.sh` | update | Block „Quelle finden" (DoD 1) |
| `test/slice-mv.bats`, `test/mutations/` | update/neu | Gegenbeispiele und Zahn (DoD 2) |
| `harness/tools/full-smoke.sh`, `internal/emit/slicemv_test.go` | lesen/update | Ziel-Lauf und Fassungs-Gleichheit (DoD 3) |

## 4. Trigger

**Start** (`next` → `in-progress`): `in-progress/` ist frei, `Verantwortlich:` gesetzt. Kein Vorgänger-Slice.

**Rückführungen:**

- `in-progress` → `next`: wenn die emittierte Fassung die Suche nicht ohne Änderung des Ziel-Vertrags tragen kann.
- `in-progress` → `open`: wenn eine Kennungs-Entscheidung (Präfix-Verbot) nötig wird, die beim Architect liegt.

## 5. Closure-Trigger

1. DoD 1 bis 3 belegt, mit gelesenem Rot je Gegenbeispiel.
2. Der unveränderte Bestand (Kurzform `slice-174`) bleibt grün.

Lerneintrag: die Form entscheidet die Closure.

## 6. Risiken und offene Punkte

- **(1) Der exakte Treffer maskiert einen Tippfehler:** ein vollständiger, aber falscher Name trifft still einen anderen Slice — **Ausgang:** <…>
- **(2) Die emittierte Fassung driftet von der Dogfood-Fassung** — **Ausgang:** <…>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `harness/tools/` (`TOOLS`) und `*` (`ALL`, die emittierte Vorlage); beide erfüllen das Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** Treffer zur Quellensuche von `slice-mv`: `ls docs/plan/planning/observations/BEO-ALL | grep -c 'slice-mv'` (keine Erwartungswerte).

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt.

