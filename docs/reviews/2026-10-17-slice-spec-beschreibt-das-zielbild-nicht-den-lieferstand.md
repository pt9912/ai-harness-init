# Review-Report: slice-spec-beschreibt-das-zielbild-nicht-den-lieferstand

**Datum:** 2026-10-17 · **Rolle:** Reviewer (frischer Kontext) · **Diff:** `b7999710` (Lastenheft 0.27.0), `a3bc9f05` (Slice nachgezogen), `8a061e44` (spec/architecture.md)
**Plan:** `slice-spec-beschreibt-das-zielbild-nicht-den-lieferstand` §1-§6, §8 · **Bezug:** LH-FA-04, LH-FA-06, LH-FA-07, LH-FA-08, LH-QA-04, MR-015, MR-042, MR-019, MR-075, AGENTS.md §3.3/§3.4/§3.7/§3.8/§3.10
**Nicht geprueft:** DoD-Abhakung (Verifier).

## Summary

HIGH 0 · MEDIUM 0 · LOW 2 · INFO 4. Keine wiederkehrende Finding-Klasse. Keine Umformulierung ändert eine Anforderung, eine Abnahmebedingung oder die Messmethode; zwei Stellen verschieben die Aussage leicht (LOW-1, INFO-1).

## Findings

### LOW-1
- kategorie: LOW · quelle: LH-FA-06 / LH-FA-08 / MR-015 (Bedeutungstreue im Vertrag) · pfad: spec/lastenheft.md:146
- befund: „seine Vorlage ist eine Ergänzung des Kurses" (vorher „eine offene Ergänzung") liest sich als Zustandsaussage, dass die `CLAUDE.md`-Vorlage zum Kurs gehört; im vendored Baum gibt es keine (`find .harness/baseline/v6.18.1/templates -iname '*claude*'` → leer), und Z. 145 begründet gerade damit „autort, nicht tool-generiert". Das alte „offen" trug „fehlt dem Kurs noch"; Z. 212 (LH-FA-08, „Kurs-Upstream-Ergänzung ist nicht Vorbedingung") stützt nur die Lesart „mögliche Upstream-Ergänzung".
- verifizierbar: nein · klasse: Umformulierung streicht das Wort, das den Sachverhalt trug

### LOW-2
- kategorie: LOW · quelle: Slice §1/§3 (Befund-Einordnung), AGENTS.md §3.7 (Zustandsfeld/Zeitbezug) · pfad: spec/lastenheft.md:100
- befund: LH-FA-04 trägt weiter „Default `flat` (das heutige Verhalten)" — ein Zeitbezug derselben Art wie „wie heute" in `architecture.md` (Z. 170, umformuliert). Das Muster P1 enthält `heute`, trifft aber `heutige` nicht (`git grep -n 'heutige\|heutigen' -- spec` → genau diese Zeile); die Stelle steht in keiner Zeile der §3-Tabelle, weder als geändert noch als „stehen lassen".
- verifizierbar: ja (`git grep -n 'heutige' -- spec`) · klasse: Messmuster enger als der Gegenstand (benannt in Slice §6 Risiko 3, hier ein konkreter Treffer)

### INFO-1
- kategorie: INFO · quelle: LH-QA-04, MR-015 · pfad: spec/lastenheft.md:624
- befund: „offen und nicht zugesagt" → „nicht zugesagt": die in 0.14.1 ausdrücklich gesetzte Aussage „Auflösung offen" entfällt als Wort; „ein Weg dorthin ist eine eigene Entscheidung mit eigenem Trigger" trägt „nicht entschieden" weiter, es bleibt also kein Vertragsinhalt verloren. Die 0.27.0-Zeile nennt die Abgrenzung zu 0.14.1 (Grenz-Notiz = Patch) nicht und wählt Minor nach 0.15.0; vertretbar, aber nicht begründet.
- verifizierbar: nein · klasse: Wort einer früheren CR-Zeile entfällt ohne Hinweis in der Folge-Zeile

### INFO-2
- kategorie: INFO · quelle: MR-019, Slice §3 (zusätzlich zum Plan) · pfad: spec/architecture.md:97
- befund: „`flat` = das arch-lose Skelett, byte-identisch zur Ausgabe ohne `--arch`" ist wahr per Definition (Default ist `flat`) und trägt keine prüfbare Aussage mehr; die Invariante, die das Lastenheft führt („funktional unverändert, im Inhalt weicht es allein um das Minimum ab", LH-FA-04 AC Arch-Achse seit 0.16.0), steht nicht dort. Ein Widerspruch zum Lastenheft besteht nicht: „byte-identisch" gilt hier für die Ausgabe zweier Aufrufe von `flat`, was LH-QA-02 zusagt; das alte „byte-identisch zum heutigen Skelett" war dagegen mit 0.16.0 überholt.
- verifizierbar: nein · klasse: Ersatzformulierung ohne Aussagegehalt

### INFO-3
- kategorie: INFO · quelle: MR-015 Setzung 2/3, AGENTS.md §3.8/§3.10 · pfad: Commit `b7999710`
- befund: Das Präfix „Rolle Auftraggeber-Anweisung" ist die Form der fünf vorigen Lastenheft-Commits (`d2e8beac`, `4be6bbb2`, `a2cd5d1b`, `126b1009`; Autor jeweils `pt9912`); es benennt die Instanz, auf deren Anweisung der Commit entsteht, keine Modul-8-Rolle und keinen Autor. §3.8 (Hard Rules, Adaptions-Block) und §3.10 (Slice-Abschluss) binden den Commit nicht; Setzung 2 ist erfüllt: `git log --stat` → nur `spec/lastenheft.md`, vor `9185b54a` (`next/ → in-progress/`). Beleg der Reihenfolge der Aufzeichnung: die Entscheidungen F1-F3, die der Commit schon trägt (Z. 39, Klasse C), stehen im Slice erst in `a3bc9f05`, einen Commit danach.
- verifizierbar: ja (`git log --stat -- spec/lastenheft.md`) · klasse: keine

### INFO-4
- kategorie: INFO · quelle: LH-FA-07, LH-QA-01 · pfad: spec/lastenheft.md:172
- befund: „Vorbedingung erfüllt … real verfügbar (v0.15.0 …); die Umsetzung stützt sich auf diesen Beleg" → „Voraussetzung: … Digest-gepinntes Image mit `--print-mk`". Die Zusage (Image, Digest-Pin, `--print-mk`) bleibt; der Beleg-Satz entfällt, der Beleg (v0.15.0, real verfügbar) steht unverändert in der Historie 0.12.0 und ist mit dem Pin (`internal/emit/archgate.go`, v0.23.2 laut MR-093) ohnehin überholt. Keine Zusage entfällt; LH-QA-01-Konformität hängt am Pin, nicht an diesem Satz.
- verifizierbar: nein · klasse: keine

## Ergebnis zu den Schwerpunkten

- (a) Bedeutungstreue, alt gegen neu aus `git diff b7999710^ b7999710 -- spec/lastenheft.md`: Z. 39 und Z. 41 (LH-FA-01), „Sprachskelett ist ein eigener Schritt, der nach dem Init läuft, erst nachdem …" gleiche Reihenfolge-Aussage; Z. 122 `cpp` „folgt" → „trägt" (zuvor überholt, `cpp` ist Profil); Z. 212 gleiche Aussage; Z. 612/616 „erst mit"→„nur mit", „heute schlicht nicht"→„schlicht nicht" ändern Grenze und Messmethode nicht (der Satz „beschreibt, was real läuft" bleibt Zeitbezug des Präsens); Z. 641 „Weitere Sprachen folgen … je einen Renderer" → „Jede weitere Sprache ist ein eigener Renderer …": ohne Lieferversprechen, Struktur-Aussage gleich; Z. 80 „Titel und Anker": der Zeiger auf §7 v0.7.0 entfällt, Anker-Zusage bleibt; keine Heading-Zeile im Diff. Einzelfragen: (1) siehe INFO-1, kein Vertragsverlust; (2) siehe LOW-1; (3) siehe INFO-4; (5)/(6)/(7)/(8) ohne Befund.
- (b) §7-Zeile 0.27.0: Form wie 0.26.0/0.25.0 (Version, Datum, „CR: …", `Nutzer-Entscheidung 2026-10-17`), der Anlass steht nicht dort (MR-042; die Zeile beschreibt die Änderung, nicht die Feststellung des Auftraggebers); Kopf Z. 3 `0.27.0`; Stufe Minor wie 0.15.0 (Begründungssatz vorhanden, Abgrenzung zu 0.14.1 s. INFO-1); die Zeile nennt „Heading-Anker bleiben stabil" und „datierte Messungen bleiben" — beides stimmt (kein Heading im Diff, Z. 118/620 unberührt).
- (c) „Auftraggeber-Anweisung": INFO-3; kein Widerspruch zu §3.8/§3.10/MR-015 Setzung 2, kein Präzedenzfall neu (5 Vorgänger). Schweregrad ehrlich INFO.
- (d) `spec/architecture.md`: Marker 2026-10-17 · `*(folgt)*` entfällt (die Schicht besteht: `docs/plan/planning/` vorhanden) · ARC-009 (INFO-2) · Z. 169/170 „ein Entry-Point wie heute" → „ein Entry-Point" bedeutungstreu · Z. 186 `--print-mk` ohne „real ab v0.15.0" (wie INFO-4). Sprach- und meilensteinfrei: `grep -nE 'v[0-9]+\.[0-9]+|Welle|slice-|[0-9a-f]{8}' spec/architecture.md` ergab nur den Hard-Rule-Satz selbst (Z. 5); P1/P2 lassen nur Z. 201 und 228 („folgen" = entsprechen) übrig; der Hard-Rule-Satz im Kopf bleibt wahr.
- (e) Messung selbst gefahren (Kommandos aus Slice §3, vorher über `git show <commit>^:…`): LH 9/3 → **4/0**, SP **3/0** (unberührt), AR 5/1 → **2/0**. LH-Resttreffer 355, 607, 624, 647 und AR 201, 228 sind harmlos (Zusage-Grenze, „nicht zugesagt", „spätere Instanzen", „folgen" = entsprechen). Weitere Muster (`sobald|ab Version|wird eingeführt|heutige|bisherig|inzwischen|mittlerweile|vorerst|neu|nun|bereits|schon|erst|noch|früher|ursprünglich|umgestellt|historisch|seit`) außerhalb der Historien: LH Z. 41 „erst nachdem" (Ablauf), Z. 61 „sobald der erste ADR existiert" (Bedingung), **Z. 100 „heutige Verhalten" (LOW-2)**, Z. 117 „bereits einer Sprache" (Zustand des Ziels), Z. 169, 554; AR Z. 29, 67, 147, 194; SP Z. 52-59, 103-104, 133, 144, 150, 163-193 (SP Z. 144 „nachgezogen" und Z. 190 „seit dem Feld" bei Lektüre Bestand-Aussagen über Felder, Rang 2, nicht Teil dieses Auftrags). Außer Z. 100 keine Zeit-/Liefer-Aussage gefunden.
- (f) Nebenwirkungen: `make docs-check` → `d-check: 2759 Datei(en) geprüft, 0 Befund(e)`; kein Heading und kein Anker verändert; `git grep -n 'real ab v0.15.0\|offen und nicht zugesagt\|Titel historisch\|folgt als separater' -- . ':!docs/reviews' ':!docs/plan/planning/done'` nennt nur die Slice-Tabelle und die Historie (0.12.0/0.14.1), also kein Test, Schema oder Mutations-Fall; `done/slice-053` unberührt.
- (g) Slice-Nachzug `a3bc9f05` gegen die Entscheidungen: §6 trägt F1 (Implementer im Slice), F2 (Klasse C umformulieren, Messungen und „nicht zugesagt" bleiben), F3 (Z. 39, „ist ein eigener, wiederholbarer Schritt, der nach dem Init läuft"), Stufe Minor; §1/§2/§4/§8 stimmen damit überein (DoD (1) nennt Klasse A/B/C und den `LH`-/`AR`-Teil; Start-Trigger „erfüllt" mit `b7999710`). Z. 39 des Lastenhefts ist in §2 (1) als Teil der DoD geführt. Ohne Befund.
- (h) Commit-Zuschnitt: `b7999710` allein `spec/lastenheft.md` (1 Datei, 17/17), vor dem `in-progress`-Move; `a3bc9f05` nur Slice-Datei (Planner, §3.3: kein Move darin); `8a061e44` Roadmap, Slice, `spec/architecture.md` (Implementer; F1 entschieden, slice-151 offen) — kein Move, keine Norm-Artefakte nach §3.8, keine Closure nach §3.10. Gate-Stempel `.harness/state/gates-passed.head` = `8a061e44c87b55b249c767bedec06385701fb1b8` = HEAD.

## Sensoren

`make docs-check`: Exit 0 (0 Befunde) · `make gates` am Ende: Exit 0.

## Geprüft, ohne Befund

Lastenheft Z. 39/41, 80, 122, 212, 612/616, 641 (Bedeutungstreue) · §7-Zeile und Kopf-Version · Anker/Überschriften · Commit-Zuschnitt und Stempel · Slice-Nachzug gegen F1-F3 · Nebenwirkungen auf Tests und Schemata · Kommentare (§3.7): keine Code- oder Konfigurations-Kommentare im Diff.
