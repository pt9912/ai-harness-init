# Verifikation zu slice-releasing-doku-traegt-den-release-vorgang

**Rolle:** Verifier (Modul 11), frischer Kontext. **Datum:** 2026-09-19.
**Frage:** Trägt `docs/user/releasing.md` die Prozedur, die Plan und die zwei ADRs verlangen?

**Eingabe:** der Slice-Plan `docs/plan/planning/done/slice-releasing-doku-traegt-den-release-vorgang.md`,
`ADR-0059` (`Accepted`), `ADR-0058` (`Accepted`). Prüfgegenstand sind Plan und ADRs — nicht der
Review-Bericht der Runde 1.

**Übernommene Belege (Auftrag: „Wiederhole nicht"):** `make gates` grün am Kopf `ce64c4a0`
(aufgezeichneter Lauf; Träger des Nachweises ist der Stop-Hook-Zustand) und `make docs-check` → 1743/0.
Diese Verifikation bestätigt die Kopf-Identität (`git log -1 --format='%H'` → `ce64c4a09109…`) und
wiederholt beide Läufe nicht. Sie selbst fährt Lektüren und git-Kommandos, je mit Ausgabe unten.

## DoD — Punkt für Punkt

### Liefer-Punkt 1 — Prozedur: erfüllt

| DoD-Element | Beleg |
|---|---|
| Sieben Schritte | `releasing.md` §Prozedur führt Schritte 1–7 |
| Schritt 1 — Assets und SUMS im selben Lauf | `Makefile:108-124`: `release-artifacts` verlangt `DEST`, fährt `RELEASE_PLATFORMS` (`Makefile:106` — genau die sechs Plattformen von `LH-QA-04`) und ruft `release-sums.sh generate "$(DEST)"` im selben Lauf (`Makefile:123`) |
| Gegenprobe 1 — Matrix-Asset fehlt → rot | `test/release-matrix.bats` trägt die Zähne: `:61` „die Plattform-Liste deckt GENAU die Matrix des Lastenhefts", `:69` „die Matrix traegt sechs Kombinationen" — genaue-Menge-Vergleich gegen die Matrix aus `spec/lastenheft.md` (gelesen per `sed -n 's/^RELEASE_PLATFORMS ?= //p' "$MK"`, `:58`) |
| Schritt 2 — Pin | `Makefile:45-51` trägt `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*`; die emittierte Vorlage `internal/emit/templates/enforce/traeger.mk` trägt nur den Tag (`grep -nE 'TRAEGER\|sha256' …` → `TRAEGER_TAG ?= v0.2.1`, `TRAEGER_CARRIER`, kein `sha256`) — ADR-0059 Festlegungen 2/3; die Kopplung im selben Commit ist ADR-0058 Festlegung 2, wörtlich („koppelt Pin und Werkzeug-Fassung im selben Commit") |
| Schritt 3 — verify, vier Bruch-Fälle | `harness/tools/release-sums.sh`: `:72-75` fehlende SUMS · `:76-82` Zeilen-Form · `:83-97` Menge in beide Richtungen · `:98-103` Inhalt (`sha256sum -c`). Der Wortlaut von Schritt 3 zählt genau diese vier |
| Schritt 4 — Gates am Tag-Baum vor dem Tag-Push | Position als Schritt 4, vor Schritt 5 (Tag-Push und Publikation); „der Release-Workflow fährt kein `docs-check`" verifiziert: `release.yml` führt die Jobs `artifacts`/`start-smoke`/`publish`, kein `docs-check` darin |
| Schritt 5 — SUMS vor dem Upload, sieben Assets | `release.yml:132-137` („SHA256SUMS gegen die Artefakte halten") steht vor dem Upload-Schritt (`:138` „Artefakte ans Release hängen"); `dist/*` trägt die SUMS mit — sieben Assets; Start-Smoke auf allen sechs Runnern (`release.yml:72-85`); Handbuch-Zitat wörtlich in `docs/user/benutzerhandbuch.md:63f` (§Systemanforderungen); `workflow_dispatch` lädt nichts hoch (`release.yml:113`, `if: github.event_name == 'push'`) |
| Gegenprobe 2 — SUMS fehlt im Release → Ziel-Fetch bricht laut ab | **teilweise unbestätigt — Befund V-1:** die Abweichungs-Klasse ist gemessen (`test/traeger-fetch.bats:174` „negative im Ziel-Modus: eine Abweichung vom Manifest-Eintrag bricht fail-closed, ohne den Traeger zu legen"); die Fehlt-Klasse (Manifest 404) trägt keinen Test und keinen auflösbaren Mess-Beleg |
| Schritt 6 — CI am Tag abwarten | Prozedur-Zeile ohne Sensor — Plan §6 Risiko 1 deklariert genau das |
| Schritt 7 — Meldung in Stand-Form | Zustandsform; die Zahl 7 in Schritt 5 trägt ihr Kommando (`gh release view <tag> --json assets --jq '.assets \| length'`) |
| Grenze — kein Signier-Schritt | §Grenze deckt ADR-0059 Festlegung 1 in deren eigenem Satz („ein Kanal, der Manifest und Asset gemeinsam ersetzt") und ADR-0058 Trigger 3 („der Fetch prüft den Digest, nicht die Signatur"); das Handbuch trägt dieselbe Grenze (`docs/user/benutzerhandbuch.md:112`) |
| Zwei Disziplin-Zeilen als harte Schritte | Schritte 4 und 6 stehen in der Schritt-Folge, keine Box daneben |

### Liefer-Punkt 2 — Verdrahtung: erfüllt

- Rang 6 trägt das Verzeichnis: `harness/README.md:22` — `| 6 | docs/user/ (falls vorhanden) | Operations, Quality, Releasing |`. Ziel-Form: Verzeichnis, keine Datei-Liste — kein Index-Nachzug nötig.
- `make docs-check` grün: übernommener Beleg (1743/0); die Links der Datei reisen in diesem Lauf mit.
- Handbuch unangetastet: `git log -- docs/user/benutzerhandbuch.md` — die letzte Berührung liegt vor diesem Slice (`399c17f1`, `0acdf385`, slice-zielordner); die Commits dieses Slices berühren es nicht.
- Berührungs-Stellen: die Start-Prüfung trägt ihre Adresse (Schritt 5 → `benutzerhandbuch.md#systemanforderungen`); die Grenze trägt ihr Anker-Paar (ADR-0058/ADR-0059). Der Download-Weg trägt in der Datei keine eigene Adresse ins Handbuch — Anmerkung V-3.

### Liefer-Punkt 3 — Belegbasis-Abschnitt: erfüllt

- Klasse benannt: „Ein ge-tagter/gepushter Stand trägt für seinen Baum keinen Gates-Beleg".
- Die drei Fundstellen lösen auf:
  - `git rev-parse --short v0.2.0` → `70139992`
  - `git rev-parse --short v0.2.1` → `28337be5`
  - `git check-ignore .harness/state/gates-passed.diffsha` → Pfad (ignoriert)
  - `ls -d docs/plan/planning/observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/` und beide Beleg-Dateien existieren
- Spiegelung der eingefrorenen Belege: Fundstelle 2 (Abschnitt **Schaden**) und Fundstelle 3 (Klassen-Beleg) wörtlich; Fundstelle 1 (Abschnitt **CI-Lage**) in zwei Details geglättet — das `rot`-Attribut der zwei Pushes entfällt, `war` statt `wurde` (Anmerkung V-4, INFO; die Substanz trägt, der Anker trägt die eingefrorene Form).
- Der Prozedur-Text trägt die Fundstellen nicht (Schritte 1–7 ohne Fundstellen) — Plan LP3 erfüllt.
- Grenz-Zeile nach F-1 (`git show ce64c4a0 --stat` → nur `docs/user/releasing.md`, +2/−1): sie nennt die gedeckte Form — `make docs-check` liest die Datei, die Fundstellen-Links reisen in seinem Lauf mit — und keine Abwesenheits-Behauptung steht mehr.
- Rot-Richtung: docs-check deckt die Links (1743/0, übernommen); die Zustandsform selbst ist keinem Sensor unterworfen — die vom Plan LP3 deklarierte Grenze. Diese Verifikation trägt sie semantisch (dieser Abschnitt).

### `make gates` grün — übernommen, nicht wiederholt

Auftrag: Kopf `ce64c4a0` gepusht, Gates grün, nicht wiederholen. Bestätigt ist die Kopf-Identität
(`git log -1` → `ce64c4a09109…`); der aufgezeichnete Lauf ist der Träger. Negativbefund unten.

### Review durchgeführt — erfüllt

`docs/reviews/2026-09-19-slice-releasing-doku-traegt-den-release-vorgang-runde-1.md` liegt vor
(`ls docs/reviews/`). Der Bericht selbst ist nicht Prüfgegenstand dieser Verifikation.

### Doku-Update bei berührtem öffentlichem Vertrag — fällt mit Liefer-Punkt 2 (erfüllt)

Die Datei selbst ist das Update; das Handbuch blieb unangetastet (git log oben).

### Closure-Pflichten — beim Planner anstehend, hier nicht prüfbar

Closure-Notiz mit Lerneintrag, Ausgang je §6-Risiko, die drei Paarungen und der `git mv` sind Planner-Arbeit
(§3.10), nicht Gegenstand dieses Verifikations-Auftrags. Festgestellter Stand zum Mitnehmen: das
Register-Verzeichnis und sein Klassen-Beleg existieren bereits; die im Plan §6 offene Fund→Vorgang-Zuordnung
ist im Klassen-Beleg mit „Ein Beleg, nicht drei" entschieden — alle drei Fundstellen im Vorgang
`slice-release-schnitt-koppelt-pin-und-fassung`; die planseitige Annahme („Fundstelle 3 im `v0.2.1`-Schnitt")
ist damit überholt.

## Plan-vs-Code-Diff

Plan → Code:

1. **Fundstelle 3** (planseitig, vorvermerkt): der Plan trägt `git rev-parse --short v0.2.1` →
   `77471f53`; der Anker löst nicht — der Tag zeigt auf `28337be5`. Die Datei trägt die auflösende Form.
   INFO; Plan-Korrektur beim Planner.
2. **Schritt-Position** (planseitig, vorvermerkt): Plan §3 verortet die erste Disziplin-Zeile
   „zwischen Asset-Publikation und Tag-Push"; die Datei trägt sie als Schritt 4 — vor Schritt 5, das
   Tag-Push **und** Asset-Publikation zusammen trägt (der tag-getriebene Lauf publiziert erst nach dem
   Push). Die Datei-Position ist die mechanisch tragende; die planseitige Formulierung ist überholt. INFO.
3. **V-1 (Befund):** die zweite LP1-Gegenprobe „gemessen am Ziel-Fetch: HTTP 404, curl-Exit 22" trägt
   keinen auflösbaren Beleg im Repo. `grep -rn 'exit 22\|Exit 22' …` → einzige Fundstelle ist der Plan
   selbst (`Plan:135`); `grep -rn '404' harness/ internal/ test/ .github/` → keine Spur dieser Messung;
   die Testliste von `test/traeger-fetch.bats` trägt die Abweichungs-Klasse (`:174`), nicht die
   Fehlt-Klasse. Die Zusage selbst (ADR-0059 Festlegung 1: Fetch fail-closed gegen das Manifest) trägt
   einen Sensor — die Behauptung „gemessen … 404/exit 22" ist damit unbestätigt (§3.6). Übergabe an den
   Planner: Mess-Beleg auflösbar machen oder die Gegenprobe auf die gemessene Klasse zurücknehmen.
4. **V-2 (INFO):** Plan §1 verweist für die Start-Prüfung auf „benutzerhandbuch.md §Erstellung eines
   Release" — eine solche Sektion trägt das Handbuch nicht (`grep -n 'Erstellung' docs/user/benutzerhandbuch.md`
   → 0 Fundstellen); die Zusagen stehen in §Systemanforderungen, und genau dorthin adressiert die Datei.
   Plan-Korrektur beim Planner.
5. **V-3 (Reichweite):** die planseitige Aufzählung der Berührungs-Stellen („Download-Weg, Start-Prüfung,
   Grenze") trägt die Datei nur für die Start-Prüfung als Adresse ins Handbuch; die Grenze trägt ihr
   Anker-Paar (ADR-0058/ADR-0059), das Handbuch trägt sie unlinked (`:112`). Kein DoD-Bruch — die
   LP2-Formulierung ist in dieser Reichweite doppeldeutig; Klärung beim Planner (Plan-Korrektur oder
   Nachzug im pausierten Handbuch-Nachzug).

Code → Plan (Gebaut-aber-nicht-Geplant): nichts gefunden. Die Datei führt genau die drei geplanten
Abschnitte (Prozedur, Belegbasis, Grenze); die Register-Neuanlage ist DoD-getrieben (Register-Pflicht),
die Fund→Vorgang-Zuordnung ist die im Plan §6 offene Frage, entschieden im Klassen-Beleg — Ausgang
beim Closure.

## Spec-Lücken (benannt, nicht geschlossen)

1. Die zwei Disziplin-Zeilen sind Prozedur ohne Sensor — kein Gate hält die Schritt-Folge (Plan §6
   Risiko 1; hier bestätigt: `release.yml` fährt kein `docs-check`, ein Wächter für die Schritt-Folge
   existiert nicht). Ausgang beim Closure.
2. Die Zustandsform des Belegbasis-Abschnitts ist keinem Sensor unterworfen (Plan LP3 deklariert die
   Grenze) — getragen vom Review und dieser Verifikation; ein Sensor für Zustandsform existiert nicht
   (`make comment-claims` prüft genannte Sensoren, nicht Zustandsform).
3. Die rot-Richtung der LP1-Gegenproben ist zur Hälfte behauptet, nicht gemessen — V-1. Die
   Matrix-Hälfte trägt (`test/release-matrix.bats:61/:69`, genaue-Menge-Vergleich).
4. Die Grenz-Zeile nennt ADR-0058 als Träger des Re-Evaluierungs-Trigger; ADR-0059 trägt einen zweiten
   Trigger desselben Gegenstands (Trigger 1: „Wenn das Release einen Signier-Schritt bekommt"). Wahr,
   nicht erschöpfend — INFO.

## Negativbefunde — was diese Verifikation nicht belegt

- `make gates` und `make docs-check` habe ich nicht wiederholt; ich übernehme die Belege des Auftrags
  und bestätige die Kopf-Identität. Ein erneuter Lauf dieser Verifikation würde sie nicht stärken.
- Die Zustandsform der Belegbasis habe ich semantisch geprüft (Anker, Spiegelung), nicht maschinell —
  sie ist keinem Sensor unterworfen.
- `make mutate` habe ich nicht gefahren; die Aussage „färbt rot" der LP1-Gegenproben beruht auf
  Existenz und Lektüre der Tests, nicht auf einer von mir gefahrenen Mutation.
- Die 404/exit-22-Messung blieb unauffindbar; ob sie real stattfand, ist aus dem Repo nicht entscheidbar.

## Verdikt

Die drei Liefer-Punkte sind erfüllt; kein DoD-Punkt ist gebrochen. Zwei neue planseitige Befunde
(V-1, V-2) und die Reichweiten-Anmerkung (V-3) gehen als Übergabe an den Planner (§3.10) — sie treffen
den DoD-Text und die planseitigen Verweise, nicht die Lieferung. Die zwei vorvermerkten INFO-Posten der
Runde 1 (Schritt-Position, Fundstelle 3) bestätige ich in der hier gemessenen Form. Der Übergang nach
`done/` bleibt Planner-Arbeit mit den Closure-Pflichten (Notiz, Risiko-Ausgänge, Paarungen, `git mv`).