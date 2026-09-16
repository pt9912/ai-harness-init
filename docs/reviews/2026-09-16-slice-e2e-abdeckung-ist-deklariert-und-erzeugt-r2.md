# Review Runde 2 `slice-e2e-abdeckung-ist-deklariert-und-erzeugt` — 0 HIGH · 0 MEDIUM · 4 LOW

**Rolle:** Reviewer · **Datum:** 2026-09-16 · **Runde 2** — Gegenstand: die eigenen Findings aus
Runde 1 (`docs/reviews/2026-09-16-slice-e2e-abdeckung-ist-deklariert-und-erzeugt.md`) gegen die
Nachzüge. **Geprüfter Stand:** `32ef9ef7` (Implementer-Nachzug) auf `aeafce6d` (Planner-Entscheidung)
auf `54184620`/`ce74fa41` (Umsetzung). **Review-Art:** Code-Review gegen Plan + Konventionen +
Hard Rules (§10 Modul 10) · **Nicht Gegenstand:** die DoD-Abhakung (Verifikation, Modul 11).

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` · **Modell:** `deepseek-v4.1-flash:cloud[1m]`

**Eingangs-Kontext:** Slice-Plan
`slice-e2e-abdeckung-ist-deklariert-und-erzeugt` im Stand nach `aeafce6d` (§1, §2, §3, §6) ·
der eigene Runde-1-Report · `AGENTS.md` §3.6, §3.7, §3.10 · `LH-QA-01`, `LH-FA-01` ·
die Gate-Kette des Makefile (`Makefile:450` `record-gates: … test …`, `gates: record-gates`) ·
die Rollen-Karte `.claude/agents/reviewer.md` (Setzung des Auftraggebers: die Karte gehört der
ausführenden Rolle).

> **Zitier-Form.** Kennung statt Adresse für alles, was der Prozess bewegt (der Slice-Plan wandert
> nach `done/` und wird als **Kennung + `§`** zitiert, nie als Pfad); ortsfeste Code-Pfade als
> Inline-Code mit `Datei:Zeile`.

**Offengelegt — was dieser Lauf am Baum getan hat.** Zwei Sandkasten-Erzeugungen in `/tmp`
(`/tmp/rev-sand`, Host) und im **bats-Container** (`bats/bats@sha256:e8f18e…`, `--network none`,
`-v $PWD:/code:ro`, geschrieben nur unter `/tmp`), dazu vier sed-Proben in beiden Umgebungen.
Am Repo wurde nichts angefasst: `git status --porcelain` war vor und nach jeder Messung leer.
`make gates`, `make test`, `make mutate` und `make full-smoke` hat dieser Lauf **nicht** gefahren.

---

## Verdikt je Finding aus Runde 1

| ID | Runde 1 | Verdikt Runde 2 | Beleg dieses Laufs |
|---|---|---|---|
| F-1 | MEDIUM | **geschlossen** | Der Halter (`test/e2e-abdeckung.bats:99`) fährt den Erzeuger in einen Sandkasten mit denselben relativen Pfaden und vergleicht per `cmp -s` gegen die committete Datei. Nachgefahren in **beiden** Umgebungen: Host und bats-Container erzeugen je **byte-gleich** gegen `docs/user/e2e-abdeckung.md` — die Divergenz ist weg, und die zwei Umgebungen, die sie erzeugt hatten, sind jetzt durch genau diesen Fall aneinander gebunden. Jede der drei Staleness-Lagen (geänderte Deklaration, eingefügte Zeile oberhalb einer Stufe, entfernte Stufe) ändert Bytes und lässt den Fall fallen. Er läuft in `make test` und damit in `make gates`. |
| F-2 | LOW | **offen, unverändert** | Kein Commit der Nachzüge berührt `harness/tools/full-smoke.sh` oder ergänzt einen Fall für die Funktion. Die Laufzeit-Hälfte hat weiterhin kein Gegenbeispiel; Rot gesehen ist sie nur an der Schwester-Implementierung im Erzeuger. |
| F-3 | INFO | **geschlossen** | Der Planner hat den `NICHT`-Punkt 4 in `aeafce6d` gezogen: „keine **bestehende** Prüfung, keine **bestehende** Erwartung und keinen **bestehenden** Exit-Code" plus der Satz, dass der neue Abbruchpfad *ihr Gegenstand* und kein geänderter Bestand ist. Der Widerspruch zwischen §1 und §2(1) ist damit aufgelöst — auf dem Weg, den §3.10 verlangt (Planner, eigener Commit, Rolle in der Message). |

**Zur Einschränkung, die der Implementer selbst gemeldet hat** („beim entfernten Deklaration fällt
die Zusage zuerst am Erzeuger, `cmp` kommt nicht zu Wort"): Das **trägt** den Halter. Der Fall hat
zwei Glieder — `[ "$status" -eq 0 ]` für die Erzeugung und `cmp -s` für die Übereinstimmung —, und
eine entfernte Deklaration fällt am ersten, eine **veraltete, aber gültige** Tabelle am zweiten. Der
zweite ist der eigenständige Gegenstand des Halters, und er ist rot gesehen (eingefügte Zeile →
„sind verschieden"). Die Richtung „Deklaration entfernt" bleibt dabei nicht ungeprüft: sie fällt im
selben `@test`-Satz am Happy Path und ist der Gegenstand des Mutationsfalls `362`. Die beabsichtigte
Richtung des Halters bleibt also geprüft; die *eingeschränkte* Fassung betrifft nur, welches Glied
zuerst feuert.

## Findings Runde 2

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-4 | LOW | Der Kommentar nennt als Ursache der Umgebungs-Divergenz einen Bereich, den die Messung nicht trägt: `[!-,]` wird von beiden seds **gleich** gelesen (`a!b,c-d` → `abc-d` in Host und Container, also wörtliche Menge, keine negierte Klasse — der neue Ausdruck beginnt ebenfalls mit `!` und arbeitet im Container korrekt). Der Ziffern-Verlust kam aus `[.-@]`: Host behält die Ziffern (`a1b/c.d@e-f_g` → `a1bcde-f_g`), Container wirft sie heraus (→ `abcde-f_g`). Die Ersetzung durch eine wörtliche Aufzählung ist richtig und in beiden Umgebungen byte-gleich — die *begründende* Aussage im Kommentar ist es nicht. | `AGENTS.md` §3.7 | `harness/tools/e2e-abdeckung.sh:74` | ja — die vier sed-Proben in beiden Umgebungen | Kommentar nennt eine Ursache, die die Messung widerlegt |
| F-5 | LOW | Die Sensor-Prosa sagt, der Halter laufe „in `make test`, nicht in `make gates`". `make test` ist Prerequisite von `record-gates` und damit von `make gates` (`Makefile:450`, `gates: record-gates`), und `harness/README.md` §Sensors führt `make test` selbst als Gate. Die Aussage widerspricht dem Gate-Index und gibt die Reichweite des Halters zu klein an. | `LH-QA-01` · Gate-Index §Sensors | `harness/sensors/full-smoke.md:33` | nein — kein Modul des Doku-Gates hält Prosa gegen die Gate-Kette | Aussage über Gate-Reichweite widerspricht dem Gate-Index |
| F-6 | LOW | Der neue DoD-Punkt benennt als Rot-Beleg „über einer Kopie, in der eine Stufe ihre Deklaration verloren hat, weicht die frische Erzeugung von der committeten Datei ab". Diesen Pfad nimmt die Messung nicht: die verlorene Deklaration endet am Erzeuger mit Exit 1, `cmp` kommt nicht zu Wort; die Byte-Abweichung ist am eingefügten-Fall belegt. Der Punkt fällt („der Fall fällt" trägt), seine Begründung nicht. | Plan §2 (Rot gesehen) · `AGENTS.md` §3.6 | `slice-e2e-abdeckung-ist-deklariert-und-erzeugt` §2, Zeile 170 | nein — Plan-Text | Beleg nennt einen Pfad, den die Messung nicht nimmt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Byte-Gleichheit in **beiden** Umgebungen (Frage 1) | geprüft, ohne Befund. Halter-Verfahren auf dem **Host**: Sandkasten `harness/tools/full-smoke.sh` + `docs/user/tabelle.md` → `cmp` gegen die committete Datei **gleich**. Dasselbe im **bats-Container** → **gleich**. Beide Umgebungen reproduzieren also die committete Tabelle Byte für Byte, und der Halter bindet sie aneinander. |
| Vollständigkeit der Ersetzung (Frage 2) | geprüft, ohne Befund für die tragende Hälfte. Ein **zweiter Bereich** steht noch im Erzeuger: `sed -e 's/[{-~]//g'` (`harness/tools/e2e-abdeckung.sh:126`) — gemessen in beiden Umgebungen **gleich** (`a{1|b}c~d` → `a1bcd`, Ziffern bleiben), und keine Überschrift des Lastenhefts trägt eines dieser Zeichen. Kein messbarer Divergenz-Fall; die Ursache der ersten Divergenz (Bereichs-Expansion über eine Spanne, die die Ziffern einschließt) hat dieser Bereich nicht. Die übrigen Glieder des Slugs arbeiten mit Zeichenklassen (`[[:upper:]]`, `[[:space:]]`), Literalen oder wörtlichen Aufzählungen; kein weiteres `[!…]`/`[^…]` und kein zweites Spannen-Paar. |
| Halter-Konstruktion | geprüft, ohne Befund. Quelle und Ziel sind dieselben relativen Pfade, die `make e2e-abdeckung` übergibt; der **Zielname** geht in keine Zeile der Tabelle ein (der Kopf nennt die Quelle, nicht sich selbst), die Tiefe ist gleich (zwei `/`), und der Sandkasten **liest** den geprüften Baum (die Kopie ist die Quelle, das Lastenheft kommt über `$HIER`). Kein Schreiben in den Baum. |
| Die gezogenen Doku-Stellen | geprüft, ohne Befund (außer F-5). `harness/README.md:73` nennt den Halter und behält `kein Gate` in der Zeile; `harness/sensors/full-smoke.md` nennt ihn mit dem richtigen Gegenstand („ungeprüft bleibt allein die Zuordnung selbst"); der Kopfkommentar des Erzeugers ersetzt die falsche Wächter-Aussage (`make docs-check` prüfe „was er schreibt") durch die richtige Trennung von Verweisen und Übereinstimmung. |
| `.claude/agents/implementer.md` (Nachzug im selben Commit) | geprüft, ohne Befund. Fünf Worte Budget-Zeile in der Karte der **eigenen** Rolle; keine Norm-Aussage, kein Fremd-Artefakt. Sie ist nicht mein Gegenstand, nur mitgelesen. |
| Beide Lücken-Richtungen, Mutationsfall `362`, Nicht-Gate-Einordnung | geprüft in Runde 1, unverändert — kein Commit der Nachzüge berührt `harness/tools/full-smoke.sh`, `test/mutations/362-…`, `Makefile` oder `.d-check.yml`. |

## Nicht geprüft

| Bereich | Grund |
|---|---|
| `make gates`, `make test`, `make mutate`, `make full-smoke` | nicht gefahren (Auftrags-Budget). Der Halter ist im Container **direkt** nachgefahren (Erzeuger + `cmp`), nicht über die bats-Stufe. |
| Laufzeit-Hälfte des Ankers im E2E | unverändert F-2 — nur ein voller E2E erreicht sie. |
| `LH-FA-11` in `spec/lastenheft.md` | fremder Gegenstand (Architect-Lauf), nur als Zahlengrundlage zur Kenntnis genommen. |
| DoD-Abhakung | Verifier-Auftrag (Modul 11). |
| §6 Risiko 2 (`codepaths.check-lines` über `file:NNN`) | nicht gemessen; die Prosa von `harness/sensors/docs-check.md` sagt dazu nichts. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 4 (F-2 offen, F-4, F-5, F-6) |
| INFO | 0 neu; F-3 geschlossen |

**Finding-Klassen dieses Laufs:** Kommentar nennt eine Ursache, die die Messung widerlegt ·
Aussage über Gate-Reichweite widerspricht dem Gate-Index · Beleg nennt einen Pfad, den die
Messung nicht nimmt · Zusage mit Gegenbeispiel nur an der Schwester-Implementierung (F-2, aus
Runde 1 weitergeführt)

## Verdikt

**Merge-blockierend:** **nein** — kein HIGH und kein MEDIUM offen; F-1 ist geschlossen, F-3 ist
zwischenzeitlich vom Planner entschieden. Die vier LOW blockieren nicht.

**F-1 geschlossen, und der Grund ist gemessen, nicht übernommen.** Die Nachbesserung stellt genau
die zwei Umgebungen aneinander, die den Fehler erzeugt hatten: der Erzeuger läuft auf dem Host,
der Halter im Container, und beide liefern dieselben Bytes gegen dieselbe committete Datei. Der
Implementer hat den Halter dabei nicht über seinen eigenen Ausgang laufen lassen (das wäre die
Tautologie gewesen), sondern über einer **Kopie** des geprüften Skripts, und die Zielpfad-Tiefe
nachgebaut statt den absoluten Pfad zu nehmen — die zwei Gründe, aus denen eine Byte-Gleichheit
sonst unerreichbar gewesen wäre, stehen im Fall selbst geschrieben. Der `cmp`-Fall und der
Exit-1-Fall sind zwei Gegenstände, und beide haben ihr Gegenbeispiel: das Rot der einen Richtung
liegt an der Byte-Abweichung, das der anderen am Happy Path und am Mutationsfall.

**Übergabe:** F-2 geht an den Implementer (unverändert), F-6 an den Planner (Plan-Text, Rückkante),
F-4 und F-5 an den Implementer (Kommentar bzw. Sensor-Prosa). Die **Finding-Klassen** gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler des Beobachtungs-Registers. Dieser
Report ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen, ersetzt keine
Verifikation (Modul 11) und ist die Fortsetzung, nicht die Überschreibung von Runde 1.
