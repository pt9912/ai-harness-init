# Verifikation slice-spec-beschreibt-das-zielbild-nicht-den-lieferstand (HEAD 69f1c205)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Diff `b7999710^..HEAD`: 5 Dateien (`spec/lastenheft.md`,
`spec/architecture.md`, Slice-Datei, `roadmap.md`, Review-Report). Nicht im Diff: `spec/spezifikation.md`, ADRs, `AGENTS.md`,
`harness/conventions*` (`git diff --name-only` auf diese Pfade leer). Lastenheft nur in `b7999710` (0.27.0) und `d4e63263` (0.27.1)
geaendert (`git log -- spec/lastenheft.md`). Haekchen und Closure sind Planner-Arbeit (`AGENTS.md` §3.10); die Slice-Datei traegt keine Closure (§7 ist Vorgabetext, alle Haekchen leer).

## Verdikte je DoD-Punkt

- **(1) Umformulierung: bestaetigt.** Jede Klasse-A/B/C-Stelle aus §3 steht im Indikativ:
  - LH Z. 39 (FA-01), Z. 80 (FA-04 Titel/Anker), Z. 100 (FA-04 `flat`), Z. 122 (`cpp`), Z. 146 (FA-06), Z. 172 (FA-07), Z. 212 (FA-08),
    Z. 612/616/624/625 (QA-04), Z. 641 (§5); AR Z. 6, 97, 170, 186. Alle im `git diff` gelesen.
  - Bedeutungstreu (Punkt 4 unten); keine Ueberschrift im Diff (`git diff b7999710^ HEAD -- spec/lastenheft.md | grep -c '^[-+]#'` -> `0`), Anker unveraendert.
  - Stehen gelassen wie §3 benennt: LH Z. 118/620 (datierte Messung), Z. 354/606/623 „nicht zugesagt", Z. 646 „spaetere Instanzen", SP Z. 93/150/199, AR Z. 201/228.
- **(2) CR-Eintrag: bestaetigt.** Kopf Z. 3 `0.27.1` == letzte §7-Zeile. §7-Zeilen 0.27.0 und 0.27.1 haben die Form von 0.25.0/0.25.1/0.26.0
  (`CR: **…** — …` | `Nutzer-Entscheidung 2026-10-17`). Der Anlass (Feststellung des Auftraggebers) steht nicht in der Zeile (MR-042); Stufe Minor/Patch begruendet wie bei 0.15.0/0.25.1.
  Eigene Commits nur Lastenheft (MR-015 Setzung 2): `git log --stat` zeigt je Commit nur `spec/lastenheft.md`.
  Einschraenkung: 0.27.0 nennt in der Aufzaehlung nicht Z. 80 (FA-04-Titelhinweis) — „Hinweis zum Titel" ist genannt, ok; Z. 80 steht damit abgedeckt.
- **(3) Messbeleg mit Rot: bestaetigt, selbst gemessen und selbst gebrochen.**
  - Messung am HEAD (P1 / P2 wie §3, `sed` bis zur Historie; Zahlen sind Messwerte von heute, keine Erwartungswerte, MR-025):
    - `sed -n '1,/^## 7\. Historie/p' spec/lastenheft.md | grep -cE '<P1>'` -> **4**; `… '<P2>'` -> **0**
    - `sed -n '1,/^## 8\. Historie/p' spec/spezifikation.md | grep -cE '<P1>'` -> **3**; P2 -> **0**
    - `grep -cE '<P1>' spec/architecture.md` -> **2**; P2 -> **0**
  - Jede Resttreffer-Zeile gelesen: LH 354, 606, 623 „nicht zugesagt" (Zusage-Grenze, harmlos); LH 646 „spaetere Instanzen" (Verwendung im Zielrepo, harmlos);
    SP 93 „kuenftigen Payload" (Geschlossenheits-Regel), SP 150 „kein Programm folgt" (Syntax), SP 199 `Folgenummer` (Bezeichner); AR 201, 228 „folgen" = *entsprechen*. Kein Befund.
  - `git grep -n 'heutige\|heutigen' -- spec` -> genau 1 Treffer: `lastenheft.md:683`, die §7-Zeile 0.27.1, die den alten Wortlaut als Protokoll zitiert. Wie erwartet.
  - Rot-Beleg (selbst, nur in Kopien unter `~/.colima-tmp/vbreak`, Kopien entfernt, Arbeitsbaum sauber): je ein Satz „Die Unterstuetzung folgt in der naechsten Fassung." als Zeile 10 in Kopien der drei Dateien:
    `lastenheft` 4 -> **5**, `spezifikation` 3 -> **4**, `architecture` 2 -> **3**. Die Spezifikation (vom Implementer nicht gefahren) steigt ebenfalls.
    Ein erster Versuch mit BSD-`sed` schlug an der `sed`-Syntax fehl und lieferte 4/3/2 (kein Einfuegen); mit `awk` wiederholt, gueltig ist nur der zweite Lauf.
- **`make gates`: bestaetigt.** `make gates` auf HEAD `69f1c205` Exit 0; `d-check: 2760 Datei(en) geprueft, 0 Befund(e)` (inkl. Links, Anker, ids, matrix, codepaths, spans); golangci `0 issues.`; bats `ok`; `span-check` ok.
  `.harness/state/gates-passed.head` == `git rev-parse HEAD` == `69f1c2051a4688bd4d4200fde6c131b324c93d5c`.
- Review-Report liegt vor (`12a9d428`, 0 HIGH/0 MEDIUM/2 LOW/4 INFO); die zwei LOW sind durch 0.27.1 behoben (Z. 100 `heutige` weg, Z. 146 Klammer weg — gemessen). Closure, Register, Risiko-Ausgaenge, Paarungen: nicht Gegenstand, stehen aus.

## (4) Bedeutungstreue der Lastenheft-Umformulierungen

- Z. 39 `folgt als separater, wiederholbarer Schritt` -> `ist ein eigener, wiederholbarer Schritt, der nach dem Init laeuft, erst nachdem …`: gleiche Ablauf-Aussage (nach dem Init, nach ADR-Entscheidung). Keine Aenderung.
- Z. 80: Titelhinweis nennt nicht mehr die Historie, sagt „Generator, kein Fetch"; Anker-Zusage bleibt. Aussage des Rumpfs (FA-04 Beschreibung) unveraendert.
- Z. 100 `das heutige Verhalten` -> `das Verhalten ohne --arch`: dieselbe Bedeutung (Default `flat`).
- Z. 122 `cpp … folgt` -> `cpp traegt C++/CMake (…)`: eher eine Bereinigung (cpp ist ein Profil, `internal/gen` fuehrt es). Die Sprachliste Z. 121 bleibt unveraendert Zielbild; **kein** Lieferbeleg fuer python/java/csharp (bewusst out of scope, Slice §1).
- Z. 146: Klammer „seine Vorlage ist eine offene Ergaenzung" ersatzlos gestrichen. Z. 145 sagt weiter „autort, nicht tool-generiert"; der Rumpf von LH-FA-06 (Z. 136–160) und die Akzeptanzkriterien nennen keine Vorlage fuer `CLAUDE.md`
  (`grep -n 'CLAUDE.md'` zeigt nur Aufzaehlung und AC „liegen im Zielrepo"). FA-08 Z. 214 nennt `CLAUDE.md` nur als Durchsetzungs-Artefakt. Kein Widerspruch. Die Streichung nimmt eine Aussage ueber den Kurs-Stand (kein Anforderungsinhalt) heraus.
- Z. 172: „Vorbedingung erfuellt … (v0.15.0, Digest-gepinnt); die Umsetzung stuetzt sich auf diesen Beleg" -> „Voraussetzung: a-check ist — wie d-check — ein Digest-gepinntes Image mit `--print-mk`".
  LH-QA-01-Konformitaet haengt am Pin (Z. 162 „a-check-Image per Digest gepinnt" bleibt; `internal/emit/archgate.go` `DefaultArchImage = …a-check:v0.23.2`) und am AC Z. 191 (fail-closed), nicht am Beleg-Satz. Keine Zusage entfaellt.
- Z. 212 „nicht mehr Vorbedingung (die fruehere Picker-Setzung entfaellt)" -> „nicht Vorbedingung": gleiche Aussage ohne Verweis auf abwesenden Text.
- QA-04 (Z. 612/616/624/625): „erst mit" -> „nur mit", „heute schlicht nicht" -> „dort schlicht nicht", „offen und nicht zugesagt" -> „nicht zugesagt". Messmethode und Grenze unveraendert; „nicht zugesagt" bleibt. Eine Spur schaerfer („nur mit" statt „erst mit") ist eine reine Zeitfreiheit, keine neue Zusage.
- Z. 641 (§5): „Weitere Sprachen folgen sprach-agnostisch ueber je einen Renderer" -> „Jede weitere Sprache ist ein eigener Renderer des sprach-agnostischen Generators": gleiche Out-of-Scope-Aussage.
- Ergebnis: keine Anforderung, Zusage, Abnahmebedingung oder Grenze geaendert.

## (6) architecture.md

- Marker `**Letzte Aenderung:** 2026-10-17` gesetzt; keine Historie eingefuehrt; Hard-Rule-Zeile Z. 6 ohne `*(folgt)*`. Die Sicht enthaelt keinen neuen Wellen-/Slice-/Commit-Bezug; `Use-Case-Slices` ist Architekturbegriff.
- ARC-009 (Z. 97): „`flat` = das arch-lose Skelett, byte-identisch zur Ausgabe ohne `--arch`". Die Fassung ist nahezu tautologisch, da Default `flat` ist (LH-FA-04), aber **pruefbar** (Gleichheit der Ausgabe von `--arch flat` und ohne `--arch`) und widerspricht LH-FA-04 (seit 0.16.0 „funktional unveraendert") nicht. Ob ein Test diese Gleichheit haelt, habe ich nicht gemessen; die Aussage ist hier als Zusage ohne benannten Waechter zu lesen (Hinweis, kein Befund).
- AR Z. 170: „ein Entry-Point wie heute" -> „ein Entry-Point"; AR Z. 186: `real ab v0.15.0` entfaellt. Beide verlieren nur den Zeitbezug.

## (8) Plan-vs-Code (beide Richtungen)

- Jede Zeile aus §3 liegt im Diff (LH Rumpf/Version/§7; LH Z. 100 und 146 in `d4e63263`; AR Kopf/§5). Gebautes ohne Plan: keines; `slice-053-…` (zitiert alten Wortlaut) unberuehrt, `spec/spezifikation.md` unberuehrt (Messung §3: 3/0, nur harmlose Treffer).
- Slice-Datei nennt die Aenderung der Planner-Nachfuehrung (`69f1c205`); Roadmap-Marke im Planner-Commit `6fbca569`. Konsistent; der Hash-Wechsel des Planner-Commits ist nicht Gegenstand.

## Erweiterte Suche ausserhalb der Slice-Muster (nur ausserhalb der Historien)

- Muster `sobald|bisher|inzwischen|bereits|frueher|nun |erst |vorlaeufig|wird eingefuehrt|ab Version|im Moment|mittlerweile|neu|nicht mehr|noch |jetzt|dann |wurde|wurden|seit ` (mit Umlauten wie im Text): LH 8 Zeilen, SP ~20 (meist Tabellenzeilen), AR 4.
  Einzeln gelesen die erreichbaren: LH Z. 41 `erst nachdem` (Ablauf-Bedingung), Z. 61 `sobald der erste ADR/Carveout existiert` (Bedingung, kein Lieferstand), Z. 117 `bereits einer Sprache` (Zustand des Ziels), Z. 168/481/553/623/645 harmlos;
  SP 163 „entfaellt, sobald die `tool_response` … Zaehler traegt" (Bedingung einer Abweichung, nicht Lieferstand), SP 190 „seit dem Feld `rule_version`" (Fassungsbezug im Feldtext), SP 223 „hochgezaehlt wurde" (Zustand); AR 29/67/147/194/210 harmlos.
  Kein Befund, aber SP 163 und SP 190 sind Zeitbezuege (Bedingung/Fassung), die der Slice-Muster nicht erfasst und die hier nicht angefasst wurden (SP ist laut Plan unberuehrt).
- **Nicht erfasst:** Formulierungen ohne Signalwort (Perfekt/Praeteritum: „wurde ersetzt", bei Treffer nur die oben gelesenen), implizite Liefer-Aussagen („traegt", „liefert" ohne Zeitwort), Aussagen in Tabellenzellen jenseits der Zeilengrenze, `sed`-Bereiche innerhalb der Historien, Fremdsprachliches, und die Wahrheit der Aussagen (z. B. ob alle sechs Sprachen ein Profil tragen: nein, `python`, `java`, `csharp` nicht — Lieferstand-Luecke, ausserhalb des Slice).

## Nicht belegt

- Kein Waechter fuer Zeit-/Liefer-Saetze in Specs (der Slice benennt es; das Muster P1 trifft `folgen` im Sinn von *entsprechen*): der Messbeleg ist ein Lauf mit Wortliste, kein Gate.
- CI auf anderem Host: nicht gefahren; `make gates` lokal gruen.
- Sprachliste (Z. 121): Zielbild bleibt, Lieferstand pro Sprache hier nicht geprueft.
- Rollenfrage fuer `spec/architecture.md`/`spec/spezifikation.md`: nicht Gegenstand (slice-151); F1 entschied Implementer-Nachzug.

## Befunde

- Keine HIGH/MEDIUM. Keine Befunde der Klasse DoD-Verletzung. Hinweise (nicht blockierend): ARC-009 `flat`-Satz fast tautologisch ohne benannten Waechter; SP 163/190 tragen Zeitbezuege ausserhalb der Slice-Muster.
- Offen fuer den Planner: Closure-Notiz (Anlass nach MR-042, Vorher/Nachher je Satz, F1–F3), Register-Beleg samt Messgrenze, Risiko-Ausgaenge §6 (alle vier: Bedeutung — kein Befund, Reihenfolge — LH-Commits vor dem Start, Messbereich — oben benannt, SP — keine Klasse A), Rollenfrage an den Architect.
