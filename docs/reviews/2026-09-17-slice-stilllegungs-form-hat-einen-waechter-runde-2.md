# Review `slice-stilllegungs-form-hat-einen-waechter`, Runde 2 — 0 HIGH · 0 MEDIUM · 2 LOW · 4 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:**
- `be2f8b83`: Architect-Verdikt zu F-1, 1 Datei, +179.
- `61a6fe61`: Implementer, Umsetzung von F-1 bis F-6, 6 Dateien, +46/−26.

Beide Commits liegen auf `origin/main`.

**Review-Art:** Code-Review gegen Plan, Verdikt, Konventionen und Hard Rules (`v6.9.0` ·
`regelwerk/modul-10-review-harness.md`). **Nicht Gegenstand:**
- die DoD-Abhakung;
- die Punkte, die Implementer und Architect nur an andere Rollen gemeldet haben (hier als INFO
  mit Adresse, R2-6).

Runde 1 steht in einer eigenen Datei, `2026-09-17-slice-stilllegungs-form-hat-einen-waechter.md`.
Der Skill sieht für jeden Folgelauf eine neue Datei vor.

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` (`1b643a87`) · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:**
- Review-Report Runde 1 (`90263a93`).
- Architect-Report `2026-09-17-slice-stilllegungs-form-hat-einen-waechter-architect.md` (§1 bis §4).
- Baseline `v6.9.0`, am vendored Baum gelesen:
  - `regelwerk/modul-05-planning-harness.md`
  - `regelwerk/modul-06-roadmap.md`
  - `templates/docs/plan/planning/slice.template.md`
- `MR-025`, `MR-033`, `MR-053`, `MR-054`, `MR-055`.
- `AGENTS.md` §3.3, §3.7, §3.8, §3.9.
- `v6.9.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz: Ein HIGH wird
  nicht herabgestuft. Geprüft ist, ob die Übernahme ihn erledigt.

---

## Eigene Messung

| Messung | Ergebnis |
|---|---|
| Zitat *„Das ist die einzige Ausnahme davon, dass DoD-Häkchen Bedingung für `done/` sind — und sie gilt nur für die **Liefer-Punkte** der DoD"*, `grep -cF` gegen den zeilenweise zusammengefügten Text von `modul-05` | 1 |
| Zitat *„Die Closure-Pflichten darunter (Notiz, Register, Risiko-Ausgänge, Paarungen) werden abgehakt wie bei jeder Closure."*, ebenso | 1. `grep -n 'werden abgehakt wie bei jeder Closure'` → Zeile 191 |
| Zitat *„mit einer Ausnahme für die Liefer-Häkchen"* (`modul-05`), ebenso | 1 |
| Zitat aus `modul-06`, *„… liegt — auch Slices ohne Wellen-Zugehörigkeit"*, ebenso | 1. Der Wortlaut ist gleich. Das Verdikt lässt die Hervorhebung `**…**` weg und setzt *[die Welle-Closure]* als Einschub |
| `grep -nE 'Träger im Repo \*\*ohne\*\* Wellen\|Alle drei Paarungen\*\*'` über `modul-06` | Zeilen 43 und 49 |
| Vorlage §7: *„einzige Ausnahme ist das letzte DoD-Item in §2 (…)"* · *„Inhalt, `git mv`, Haekchen"* · *„BEDIENHINWEIS — keine Norm"* | je 1 |
| `grep -ciE 'häkchen\|abgehakt\|abhaken'` über `modul-06` und über `.claude/commands/close-welle.md`, dazu `grep -ci 'paarung' .claude/commands/close-welle.md` | 0 · 0 · 0 |
| Mitglieder von `welle-emittierte-werkzeuge` mit offener Paarungen-Zeile (Kommando aus dem Verdikt) | 4 von 4; die Ergebnis-Notiz nennt Paarungen (`grep -ci paarung` → 8) |
| Übernahme `.d-check.yml`: Codeblock aus Verdikt §3 gegen `sed -n '73,82p' .d-check.yml`, `diff` | identisch |
| Übernahme `docs-check.md`: beide Blockzitate aus Verdikt §3 (*Was es hält*, *Grenzen*), `grep -cF` gegen den zusammengefügten Text der Datei | je 1 |
| F-2: die zwei Kommandos der Commit-Message `61a6fe61`, nachgefahren am Stand `61a6fe61` | Trefferdateien in R2-1 abgeglichen |
| F-2, eigene Suche nach Aussagen über den Aktivierungsstand von `structure`: `git grep -n structure` in lebenden Dateien, gefiltert auf *nicht aktiv/inert/kein structure* | Treffer in R2-2 |
| `command -v bats` | kein `bats` auf dem Host |
| `ls -d docs/plan/planning/done/*/` | keine Ausgabe |

---

## Stand der Befunde aus Runde 1

| ID | Stand | Beleg |
|---|---|---|
| F-1 (HIGH) | **erledigt durch Übernahme**, nicht herabgestuft | Verdikt 1 trägt. `modul-05` §Ein Slice, dessen Gegenstand ein anderer übernimmt, zählt die Paarungen namentlich zu den Pflichten, die *„wie bei jeder Closure"* abgehakt werden, und nennt die Liefer-Punkte die *„einzige"* Ausnahme. Die Gegenlesart ließe ein Kästchen offen, das kein Schritt der Welle-Closure abhakt (je 0 Treffer). Alle Zitate stimmen am vendored Baum im Wortlaut. §3 ist wörtlich übernommen, an allen drei Stellen. Runde 1 hatte den Satz aus `modul-05` nicht als Regel für den Zeitpunkt der Paarungen-Zeile gelesen. Die Aussage *„keine Quelle legt fest"* war darum unvollständig |
| F-2 (MEDIUM) | **erledigt an den Fundorten**. Die Fundmenge hat zwei Lücken: R2-1, R2-2 | `ci.yml:26`, `history-range-guard.md:54-57` und `docs-check.md:7-10` nennen das Kommando statt der Liste, dazu `docs-check.md:137-139`. Stehen geblieben sind `d-check.mk:88` und `README.md:94`, begründet mit der Roadmap-Zeile *Doku- und Sensor-Wartung*, Punkt 6 |
| F-3 (LOW) | erledigt | `ZWEITES`. Der Dateiname bleibt, denn ein Move ist ein eigener Commit (`AGENTS.md` §3.3). Zum Rot-Beleg: R2-4 |
| F-4 (LOW) | erledigt | *„Das Rezept von `doc-tracked` reicht …"* |
| F-5 (LOW) | erledigt | Kriterium 3 *„nicht erfüllt"*, mit Verweis auf `MR-055` Setzung 3 und dem Kommando → 0. Die Entscheidung bleibt bei Kriterium 2 |
| F-6 (INFO) | erledigt | Die Begründung der Namensliste steht im Indikativ |
| F-7, F-10 (INFO) | unverändert, keine Umsetzung verlangt | — |
| F-8 (INFO) | stehen gelassen, mit Adresse | Roadmap-Zeile *Doku- und Sensor-Wartung*, Punkt 6 (Planner) |
| F-9 (INFO) | Kern bleibt, Prämisse berichtigt | R2-5 |

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R2-1 | LOW | Die Fundliste der Commit-Message ordnet nicht jeden Treffer ihres eigenen ersten Kommandos zu. Ohne Einordnung bleiben `MR-011:30`, `MR-012:29`, `MR-029:114`, `MR-054:84`, `:90`, `:100` und `observations/BEO-ALL/anweisungssatz-nachzug-ohne-waechter/state.md:6`. Keiner dieser Treffer führt eine Liste der aktiven Module im Dogfood. Drei nennen die emittierte Liste als `[links, anchors]`, obwohl die Vorlage fünf Module führt. Das ist dieselbe Klasse, die die Message für `internal/emit/templates.go` als vorbestehend nennt. | `MR-051` (die Commit-Message ist Zahl- und Fundbeleg); Auftrag Runde 2: *„die gemessene Fundmenge"* | Commit-Message `61a6fe61`, Abschnitt *F-2, Fundmenge* | ja — das erste Kommando der Message gegen ihre Klassen-Liste halten | Fundliste unterschreitet die Ausgabe ihres eigenen Kommandos |
| R2-2 | LOW | Beide Suchmuster finden nur Aufzählungen. Aussagen, `structure` sei nicht aktiv, erfassen sie nicht, und davon stehen zwei in Plänen in `next/`. `slice-114` sagt an zwei Stellen *„`structure` … nicht aktiviert"*, einmal mit `grep -c 'structure' .d-check.yml` → 0. Das Kommando liefert jetzt 6 statt 0. `slice-218` plant, den `structure`-Block anzulegen (*„der Block entsteht mit diesem Slice"*) und die Inertheits-Aussage in `doc-structure.md` samt der README-Zelle abzulösen. Beides hat `8366b374` schon getan. Die Pläne gehören dem Planner. | `MR-025` (Zahl neben Kommando, das Kommando liefert heute anderes); Maintainability | `slice-114`, §Kopf `:47` und `:244`; `slice-218` `:84-88`, `:162-163` (Kennung, Zeilen am Stand `61a6fe61`) | nein | Korrektur trifft den Fundort statt die gemessene Fundmenge |
| R2-3 | INFO | Der CI-Kommentar trägt *„keines davon liest `git`-Historie"* ohne Werkzeug-Stand. Die zwei Geschwister-Stellen datieren dieselbe Aussage (*„gemessen am Stand `v0.76.1`: `AGENTS.md` §3.8"*). `MR-053` bindet nur Adaptions-Einträge. | `MR-053` (Form), `AGENTS.md` §3.7 | `.github/workflows/ci.yml:26-27` | nein | Werkzeug-Aussage ohne Stand |
| R2-4 | INFO | Die Message belegt den Zahn von Fall 309 mit *„bats test/doc-block-marke-wiring.bats → not ok 1"*, nennt aber keinen Träger. Auf dem Host gibt es kein `bats`, der Lauf ist also nur über einen ungenannten Weg nachfahrbar. Die Umsetzung von F-3 ändert nur einen Kommentar und hängt nicht daran. | `AGENTS.md` §3.9; `LH-QA-02` | Commit-Message `61a6fe61`, Abschnitt *F-3* | nein | Rot-Beleg ohne gepinnten Träger |
| R2-5 | INFO | Berichtigung zu Runde 1, F-9: Von den fünf benannten Einträgen in `exempt-paths` sind nur zwei wellenlos (`slice-commit-traeger-wird-skip-if-present`, `slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke`). Drei gehören zur schon geschlossenen `welle-emittierte-werkzeuge`, deren Closure nichts archiviert hat; unter `done/` liegt kein Unterverzeichnis. Der Kern bleibt: d-check `v0.76.1` prüft an `exempt-paths` nur die Syntax, und ein späteres Archivieren ließe Einträge still ins Leere zeigen. | Maintainability | `.d-check.yml:104-134` | nein | Ausnahmeliste nur auf Form geprüft |
| R2-6 | INFO | Diese Punkte wurden nur gemeldet und sind hier nicht Gegenstand. Sie stehen mit Adresse in der Message `61a6fe61` oder im Verdikt §4. Details: Tabelle *Gemeldete Punkte* unten. | Auftrag Runde 2 | — | nein | — |

**Gemeldete Punkte (R2-6)**

| Adresse | Punkte |
|---|---|
| **Architect** | `docs/plan/adr/README.md:102` (ADR-Index, sechs Module). `MR-026:65`, `MR-047:91`, `MR-048:63`, `MR-049:55`, `MR-050:48`: Modul-Liste im Präsens. Die datierten Sprung-Messungen in `MR-024`, `MR-027`, `MR-052`, `MR-061`, `MR-063`, `MR-064`. Dazu aus R2-1 die emittierte Liste in `MR-011`, `MR-012`, `MR-029` und aus der eigenen Suche `MR-025:76` (*„verfügbar, nicht aktiviert"*, zu sichten) |
| **Planner** | `roadmap.md:40`, `slice-139:133`, `slice-121:68-69`, `slice-072:135`, `welle-11-traeger-aussage.md:47`. Verdikt §4: die Paarungen-Zeile wird bei jeder Slice-Closure abgehakt; DoD und §7 dieses Slice (Lage V8); `close-welle.md` ohne Paarungen (`ADR-0028`); Register-Frage zu F-1. Dazu R2-2 |
| **ohne Adresse, als vorbestehend begründet** | `internal/emit/templates.go:531`, `:560`, `:1011` (emittierte Liste) |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Punkt 1: Verdikt trägt | geprüft, ohne Befund. Die Quellen stimmen im Wortlaut (Eigene Messung), und die Argumentation folgt aus ihnen. Die Einordnung als *„keine Abweichung, kein `MR`"* passt zu `MR-000` und `ADR-0056` |
| Punkt 2: Übernahme §3 im Wortlaut | geprüft, ohne Befund: an allen drei Stellen identisch. `hint` und Regel sind unverändert (`git show 61a6fe61 -- .d-check.yml` berührt nur Kommentarzeilen) |
| Architect-Report `be2f8b83`, Form | geprüft, ohne Befund. Jede Zahl steht neben ihrem Kommando und trägt *keine Erwartungswerte* (`MR-025`). Baseline-Aussagen nennen `v6.9.0` (`MR-033`). Slices und Wellen stehen bei ihrer Kennung, Links gehen nur auf ortsfeste Ziele (`AGENTS.md` §3.11) |
| `AGENTS.md` §3.7 im Diff `61a6fe61` | geprüft, ohne Befund. Die neuen Kommentarzeilen in `.d-check.yml` stehen im Indikativ und tragen keine Chronik und keine Befund-Kennung. Die Herkunft steht als Stellen-Anker (`v6.9.0 · modul-05 …`). `309:5` beschreibt, was da ist |
| `MR-025` im Diff `61a6fe61` | geprüft, ohne Befund. Die zwei neuen Aussagen über aktive Module nennen das Kommando statt einer Zahl. Kriterium 3 steht neben `grep -ciE … → 0` |
| `MR-053` im Diff `61a6fe61` | geprüft: `docs-check.md:7-10` und `history-range-guard.md:54-57` datieren die Werkzeug-Aussage auf `v0.76.1`. Rest: R2-3 |
| `AGENTS.md` §3.8, Commit-Zuschnitt | geprüft, ohne Befund. `be2f8b83` berührt nur `docs/reviews/`, kein Norm-Artefakt. `61a6fe61` berührt keine Architect-Artefakte |

## Summary

0 HIGH · 0 MEDIUM · 2 LOW · 4 INFO

**Finding-Klassen dieses Laufs:**
- Fundliste unterschreitet die Ausgabe ihres eigenen Kommandos
- Korrektur trifft den Fundort statt die gemessene Fundmenge
- Werkzeug-Aussage ohne Stand
- Rot-Beleg ohne gepinnten Träger
- Ausnahmeliste nur auf Form geprüft

Nahe Einträge im Beobachtungs-Register:
- `BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`
- `BEO-ALL/extensionale-zahl-unterschreitet-die-eigene-fundmenge`
- `BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`

Ob die Closure sie zitiert, entscheidet sie.

## Verdikt

**Merge-blockierend: nein.**
- **F-1** ist durch die Übernahme des Verdikts erledigt, **F-2 bis F-6** an ihren Fundorten.
- Offen bleiben zwei LOW:
  - **R2-1:** Die Fundliste in der Message ist unvollständig eingeordnet, eine inhaltliche Drift
    im Dogfood steht nicht dahinter.
  - **R2-2:** zwei Pläne in `next/` mit überholter Voraussetzung; Adresse ist der Planner.
- Dazu Hinweise ohne Umsetzungspflicht.

**Übergabe:** R2-1 geht an den Implementer. R2-2 und die Planner-Zeile aus R2-6 gehen an den
Planner, die Architect-Zeile an den Architect. Die Finding-Klassen gehen in die Closure §7.
