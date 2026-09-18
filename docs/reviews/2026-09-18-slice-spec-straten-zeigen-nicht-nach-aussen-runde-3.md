# Review-Report: `slice-spec-straten-zeigen-nicht-nach-aussen` — 2026-09-18, Runde 3

**Review-Art:** Code — geprüft wird **ein** Commit gegen Plan, aktive ADRs, die Hard Rules und die
drei offenen Findings der Runde 2. **Nicht** gegen die DoD: die prüft der Verifier (Modul 11).

**Gegenstand:** `e621fbc2` — die Korrekturen des Implementers zu F-1 (HIGH), F-2 (MEDIUM) und
F-3 (LOW) der Runde 2. Der übrige Slice ist in den Runden 1 und 2 abgehandelt und **nicht**
Gegenstand dieses Laufs; F-4 bis F-6 der Runde 2 bleiben auf Anweisung des Auftraggebers ohne
Code-Änderung und werden hier nicht erneut vorgetragen.

**Skill:** `.harness/skills/reviewer.md` v2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-18

> **Zitier-Form** *(Norm, kein Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert,
> bewegt sich weiter. Deshalb **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine Baseline-Stelle
> als Tag + Pfad in Inline-Code (`v6.9.0` · `regelwerk/<datei>.md` §<Abschnitt>) statt als Link.
> Ortsfeste Ablagen stehen als Pfad (`AGENTS.md` §3.11). Die Reports der Runden 1 und 2 werden
> **nicht** nachgebessert; dieser tritt daneben. Die Findings dieses Laufs heißen `R3-*`, damit
> sie sich nicht mit den `F-*` der Vorrunden mischen.

**Eingangs-Kontext:**

- der Slice-Plan `slice-spec-straten-zeigen-nicht-nach-aussen` samt §1 *Ziel und Abgrenzung*
- der eigene Report der Runde 2 (F-1 bis F-6)
- die Commit-Message von `e621fbc2` — sie trägt die Zusagen, gegen die dieser Lauf misst
- `AGENTS.md` §3.6 · §3.7 · §3.9
- `MR-017`, `MR-025`, `MR-054`
- `LH-FA-03`, `LH-QA-01`
- `v6.9.0` · `regelwerk/modul-11-verification.md` §Fitness Function ohne Standard-Tool
  (Break-Test **und** der unveränderte Bestand, auf dem der Sensor schweigt)

**Eigene Messungen dieses Laufs.** Alle Läufe in einem Wegwerf-Klon des Repos im Scratchpad,
ausgecheckt auf `e621fbc2`, über `make test-go` und `make e2e-abdeckung` — Docker-only
(`AGENTS.md` §3.9), keine Host-Toolchain. Der Arbeitsbaum wurde nicht verändert. `make gates` und
`make docs-check` über demselben Commit sind vom Auftraggeber belegt und hier **nicht** wiederholt.
Keine Zahl ist ein Erwartungswert (`MR-025` Setzung 2).

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R3-1 | MEDIUM | Die Positions-Zusicherung (`aussen` ist die letzte Klasse) hat weiterhin **keinen isolierenden** Fall in `test/mutations/`. Gemessen: der gelistete Fall `372` färbt `emit_test.go:73` **und** `:76` zugleich; verliert die Positions-Zusicherung ihre Zähne, während `372` unverändert bleibt, fällt der genannte Test weiter über `:73` — `make mutate` meldet dann `ok` und der verlorene Zahn bleibt unsichtbar. Der isolierende Wurf (`aussen` verschieben statt entfernen) ist von Hand rot gesehen, aber nicht gelistet. Die Commit-Message sagt dazu *„Die Positions-Zusicherung ist damit auch isoliert"*; die `classes:`-Grenze aus R3-Auftrag 3 ändert an dieser Lage nichts. Unaufgelöster Rest von F-2 der Runde 2, keine neue Klasse. | `AGENTS.md` §3.6 (*„wer keinen Fall in `test/mutations/` hat, ist unbewacht"*; die Commit-Message ist eine der vier Zusage-Klassen) | `internal/emit/emit_test.go:75`; fehlend in `test/mutations/` | ja — die Bedingung in `:75` auf jede Klassen-Zeile weiten und `372` fahren: der Test fällt weiter, `make mutate` bleibt still (in diesem Lauf gemessen) | neuer-waechter-ohne-mutations-fall |
| R3-2 | LOW | Die in diesem Commit **geweitete** Meldung an `emit_test.go:93` behauptet mehr, als die Prüfung misst: Sie sagt *„an keiner Position darf er die Status-Deckung der Klasse `welle` zurücknehmen"*, geprüft wird aber ein reines `Contains` über die ganze Datei einschließlich ihrer Kommentare. Gemessen: der Pfad allein in einem **Kommentar** der emittierten Vorlage färbt `:93` rot — ein Kommentar nimmt keiner Klasse ihre Deckung. Die vorige, engere Meldung trug diese Aussage nicht. Fail-closed in die sichere Richtung: falsches Rot ist möglich, falsches Grün nicht. | Maintainability (`AGENTS.md` §3.7 — die Zusage auf das einschränken, was der Code hält) | `internal/emit/emit_test.go:93` | ja — den Pfad in den erklärenden Kommentar der emittierten Vorlage schreiben; `make test-go` fällt mit dieser Meldung (in diesem Lauf gemessen) | Wächter-Meldung behauptet mehr, als die Prüfung misst |
| R3-3 | INFO | `375` ändert **zwei** Zeilen der emittierten Vorlage, nicht eine: neben dem ADR-Muster von `ids` (Zeile 13) trifft dasselbe `sed` die **auskommentierte** Requirement-Beispielzeile (Zeile 16), die denselben Anker `link-policy: always}` trägt. Der Kopfkommentar des Falls nennt eine Position. Ohne Wirkung auf die Isolation — gemessen fällt weiter genau `:93` —, und ohne Wirkung auf die Robustheit: verschwände Zeile 13, träfe der Fall weiter Zeile 16 und färbte dieselbe Zusicherung. | `AGENTS.md` §3.7 (ein Kommentar beschreibt, was da ist) | `test/mutations/375-emittierter-welle-pfad-kehrt-zurueck.sh` | ja — `git diff --stat` nach dem Fall zeigt 2 geänderte Zeilen | Mutations-Kommentar nennt eine Position, die Mutation trifft zwei |

### Belege

**Zu F-1 der Runde 2 — steht der Satz wieder, und stimmt die Zahl?** Die Zeile ist zurück, der
Satz läuft durch (`harness/tools/full-smoke.sh:804`: *„ZAEHNE zu den drei … Modulen ids/matrix/spans —
SECHS Gegenbeispiele im gebootstrappten Ziel (AGENTS.md §3.6), nach derselben Form wie der
Feldlisten-Zahn oben: …"*), der normative Anker `AGENTS.md` §3.6 steht wieder darin, und `:810`
(*„bei allen sechs"*) hat mit `:804` wieder seinen Bezug. Die **Zahl** ist nachgezählt, nicht
übernommen:

```sh
grep -c '^modul_zahn_alte_module_gruen ' harness/tools/full-smoke.sh   # 6
```

Sechs Zahn-Blöcke, jeder mit seiner zweiten Richtung: `matrix-Zahn` (matrix-forbidden
spec-straten → adr) · `matrix-downward-Zahn` · `matrix-aussen-Zahn` · `ids-Zahn` (bare
ADR-Kennung) · `matrix-MR-Zahn` (token: der Klasse `adaptionsblock`) · `spans-Zahn`. Das sind
**vier** `matrix`, **einer** `ids`, **einer** `spans` — genau die Aufteilung, die der Kommentar in
seiner Klammer nennt. **Kein Erwartungswert**, die Zahl wandert mit dem Skript.

**Zu F-2 der Runde 2 — sind die zwei neuen Fälle isoliert?** Ja. Je Fall der unmutierte Bestand,
auf dem der Wächter schweigt, und die Mutation, die er meint; gemessen über `make test-go` im
Klon, gefiltert auf die fallenden Zusicherungs-Zeilen und die `--- FAIL:`-Zeile, die `make mutate`
als Rot-Form liest:

| Stand im Klon | fallende Zusicherung(en) | fallender Test |
|---|---|---|
| unverändert (`e621fbc2`) | — | keiner, alle Pakete `ok` |
| `372` (Klasse `aussen` entfernt) | `emit_test.go:73` **und** `:76` | `TestDCheckConfig_EntschiedeneModulListe` |
| `373` (`token:` entfernt) | `emit_test.go:84` | dito |
| `374` (ADR-Index aus `matrix.exempt-paths`) | `emit_test.go:90` | dito |
| `375` (Welle-Pfad an anderer Position) | `emit_test.go:93` | dito |

`374` und `375` färben je **genau eine** Zusicherung, und zwar die, über die ihr Kopfkommentar
spricht; kein anderer Go-Test fällt mit. Damit ist die Hälfte von F-2, die zwei Zusicherungen ohne
jeden Fall betraf, aufgelöst. Die Zeile `372` ist der Rest — sie trägt R3-1.

**Zu R3-1 — was `make mutate` an der Positions-Zusicherung nicht sieht.** Zwei Läufe im Klon,
beide über `make test-go`:

| Lage | Ergebnis |
|---|---|
| Positions-Zusicherung verliert ihre Zähne (`HasPrefix(letzteKlasse, "- {name: aussen,")` → `"- {name: "`), dann `372` | fällt weiter — aber über `emit_test.go:73`; die Rot-Form `--- FAIL: TestDCheckConfig_EntschiedeneModulListe` steht, also meldet `make mutate` `ok` und den verlorenen Zahn **nicht** |
| Klasse `aussen` bleibt stehen und wandert nur vor die Klasse `adr` | fällt **isoliert** über `emit_test.go:76` — genau der Wurf, den die Commit-Message beschreibt, und er steht in keinem Fall unter `test/mutations/` |

**Zu F-3 der Runde 2 — hat die `classes:`-Grenze beide Enden?** Ja, und die Schleife kann nicht
herauslaufen:

```sh
grep -cE '^ *(classes:|rules:)$' internal/emit/templates/d-check.yml                              # 2
grep -c '^ *- {name: ' internal/emit/templates/d-check.yml                                        # 6
sed -n '/^ *classes:$/,/^ *rules:$/p' internal/emit/templates/d-check.yml | grep -c '^ *- {name: '  # 6
```

Genau eine öffnende und eine schließende Marke, und **alle** sechs Klassen-Zeilen liegen zwischen
ihnen — die Messung von `letzteKlasse` kann heute an keiner späteren Listen-Zeile wieder
herauslaufen. Das Risiko, gegen das F-3 geschrieben war, ist damit geschlossen. **Keine
Erwartungswerte**, alle drei Zahlen wandern mit der Vorlage.

**Zum Mit-Gegenstand `docs/user/e2e-abdeckung.md` — nur Zeilennummern, und aus dem Generator.**
Zwei Messungen. Erstens: außerhalb der Stufen-Zeilennummern ist die Datei byte-gleich —

```sh
diff <(sed -E 's/full-smoke\.sh:[0-9]+/full-smoke.sh:NNN/g' <vorher>) \
     <(sed -E 's/full-smoke\.sh:[0-9]+/full-smoke.sh:NNN/g' <nachher>)   # kein Unterschied
```

und die Verschiebung ist die erwartete: **3** Stufen oberhalb der eingefügten Zeile 804 bleiben
stehen (357, 371, 421), **15** darunter gehen um genau **1** nach unten. Zweitens: `make e2e-abdeckung`
im Klon über `e621fbc2` meldet `e2e-abdeckung: unverändert — docs/user/e2e-abdeckung.md
(18 Stufen, 18 Deklarationen).` und lässt `git status --porcelain` leer — die Sicht steht so da,
wie der Generator sie schreibt, nicht wie eine Hand sie nachgezogen hätte.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| F-1 der Runde 2 (abgebrochener Satz, verlorene Zahl, verlorener §3.6-Anker) | **aufgelöst** — Satz läuft durch, Anker steht, `:810` hat seinen Bezug; die Zahl **sechs** gegen sechs Zahn-Blöcke nachgezählt, Aufteilung 4/1/1 wie im Kommentar behauptet |
| F-2 der Runde 2, Hälfte *zwei Zusicherungen ohne jeden Fall* | **aufgelöst** — `374` und `375` gemessen, je genau eine Zusicherung, rot aus dem richtigen Grund, unveränderter Bestand still |
| F-2 der Runde 2, Hälfte *`372` isoliert die Positions-Zusicherung nicht* | **nicht aufgelöst** — R3-1 |
| F-3 der Runde 2 (Schleife ohne Block-Grenze) | **aufgelöst** — beide Enden vorhanden, alle sechs Klassen-Zeilen innerhalb, gemessen |
| `docs/user/e2e-abdeckung.md` | geprüft, ohne Befund — nur Stufen-Zeilennummern, Verschiebung +1 unterhalb der neuen Zeile, generator-identisch |
| Der neue Kommentar an `emit_test.go:30`–`:32` gegen `AGENTS.md` §3.7 | geprüft, ohne Befund — die erste Hälfte nennt im Indikativ, was das Feld hält; die zweite (*„sonst zählte jede spätere Liste mit …"*) schreibt an den, der die Grenze **entfernt**, und ist damit eine Grenz-Aussage, keine verworfene Alternative. Dieselbe Form trägt der Bestand daneben (`:86`–`:88`, und der Kommentarblock der emittierten Vorlage) |
| Kopf-Form der zwei neuen Mutations-Fälle | geprüft, ohne Befund — beide tragen `# files:` und `# expect:`, beide `100755`; `make mutate` leitet daraus die Go-Stufe ab und findet seine Rot-Form |
| Fallzahl-Aussagen in lebenden Artefakten | geprüft, ohne Befund — kein lebendes Markdown-Artefakt nennt eine **Gesamtzahl** der Fälle, die durch die zwei neuen falsch würde (`ls test/mutations/*.sh \| wc -l` → **362**, kein Erwartungswert); die Spezifikation nennt einzelne Fall-Dateien, keine Summe |
| Umfang des Diffs gegen den Slice-Plan §1 | geprüft, ohne Befund — fünf Dateien, alle im Gegenstand des Slice (emittierte Vorlage samt ihrer Zusicherungen, Zähne im `full-smoke`, Mutations-Fälle, erzeugte Sicht); kein Produkt-Code außerhalb, keine Norm-Artefakte fremder Rollen |
| Host-Toolchain im Diff oder in den neuen Fällen | geprüft, ohne Befund — die zwei Fälle fahren `sed`, kein Paketmanager, keine Sprach-Toolchain (`AGENTS.md` §3.9) |
| Nachbar-Repo-Spuren (fremde Pfade, fremde Kennungen) | geprüft, ohne Befund — keine |
| F-4 bis F-6 der Runde 2 | auf Anweisung des Auftraggebers nicht erneut geprüft und nicht erneut vorgetragen |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** neuer-waechter-ohne-mutations-fall · Wächter-Meldung behauptet
mehr, als die Prüfung misst · Mutations-Kommentar nennt eine Position, die Mutation trifft zwei

## Verdikt

**Merge-blockierend: ja, aber nur noch durch ein MEDIUM.** Der HIGH der Runde 2 ist **aufgelöst** —
gemessen, nicht geglaubt: Der Satz läuft durch, der `AGENTS.md`-§3.6-Anker steht wieder darin, und
die Zahl **sechs** deckt sich mit sechs real vorhandenen Zahn-Blöcken in der Aufteilung, die der
Kommentar selbst nennt.

Auch die Sache von F-2 ist entschieden: Die zwei Zusicherungen, die keinen Fall hatten, haben je
einen, und beide sind **isoliert** — jede Mutation färbt genau die Zusicherung, über die ihr
Kopfkommentar spricht, der unveränderte Bestand bleibt still, und die Rot-Form, die `make mutate`
liest, steht. Der Weg dorthin ist der richtige: `375` schmuggelt den Pfad an einer anderen
Position ein, statt ihn zurückzuschreiben, und trifft die Welle-Zusicherung damit allein.

**R3-1 ist der Rest, den die Korrektur nicht erreicht hat, und die Commit-Message erklärt ihn für
erledigt.** Die `classes:`-Grenze war die richtige Antwort auf F-3 und ist korrekt gebaut — sie
ändert an der Isolation aber nichts: Der gelistete Fall `372` färbt weiter zwei Zusicherungen, und
der Wurf, der die Positions-Zusicherung allein trifft, war schon in Runde 2 von Hand rot und steht
bis heute in keinem Fall. Gemessen ist die Folge: Nimmt man dieser Zusicherung die Zähne, bleibt
`make mutate` still. Das ist dieselbe Klasse wie F-2 der Runde 2, derselbe Vorgang, und sie zählt
im Beobachtungs-Register darum **einmal** (`v6.9.0` · `regelwerk/modul-06-roadmap.md` §Das
Beobachtungs-Register). Der Weg ist kurz — ein Fall oder ein anderer Schnitt an `372` —, aber er
ist nicht gegangen, und ich stufe ihn nicht herab, weil eine Runde vergangen ist.

R3-2 und R3-3 blockieren nicht. Beide sind fail-closed in die sichere Richtung: Sie können ein
falsches Rot erzeugen, kein falsches Grün.

**Ist der Weg zu Verifikation und Closure frei? Noch nicht** — er hängt allein an R3-1. Sobald die
Positions-Zusicherung einen Fall hat, der sie allein trifft, ist aus diesem Review nichts mehr
offen; R3-2 und R3-3 sind dann Ermessen des Implementers.

**Übergabe:** Findings an den Implementer. Ein Rollen-Konflikt liegt nicht vor; ein Gang zum
Architect ist nicht nötig — alle drei Punkte berühren die Ausführung, keine Entscheidung. Die
**Finding-Klassen** gehen in die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein
**Lauf-Beleg** und ersetzt keine Verifikation — DoD- und Spec-Konformität prüft der Verifier
separat.
