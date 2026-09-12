# Review — slice-217: `doc-*`-Ziel nennt seinen Prüfbereich

**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Skill:** `.harness/skills/reviewer.md` 1.7.0
**Gegenstand:** `497564d7` — `d-check.mk` (+13/−4), `harness/README.md` (+85), `test/doc-block-marke-wiring.bats` (neu), `test/mutations/309-drittes-c-ziel-ohne-marke.sh` (neu)
**Plan:** `docs/plan/planning/in-progress/slice-217-doc-ziel-nennt-seinen-pruefbereich.md`
**Quellen:** [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7, [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), `grundlagen-harness-dateien.md` §harness/README.md
**Vorlauf:** `docs/reviews/2026-09-11-slice-124-*` (dieselbe Gate-Tabellen-Fläche). Kein Docker-Ziel gefahren.

## Findings

### MEDIUM-1 — Kopf-Zahl und danebenstehendes `diff` fallen nicht mehr zusammen
`quelle` [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 · `pfad` `d-check.mk:49` · `verifizierbar` ja — das im Kopf stehende `diff … | grep -c '^[0-9]'`
Der Kopf sagt *„NEU-ERZEUGUNG: FUENF Handgriffe. Abzaehlbar"* und stellt das `diff`-Kommando daneben; jedes der zwei C-Ziele erzeugt im Normal-Format aber **zwei** Kommandos (geänderte Ziel-Zeile · addierte `@echo`-Zeile, getrennt durch die unveränderte Rezept-Zeile), also 4+4=**8** gegen **5**. Lokal nachgestellt: `printf 'a\ntarget: ## alt\n\tdocker run\nb\n' >gen; printf 'a\ntarget: ## alt -- M\n\tdocker run\n\t@echo M\nb\n' >ad; diff gen ad | grep -c '^[0-9]'` → **2**. Versagen: wer regeneriert, liest 8 ab, findet 5 gelistete Handgriffe und kann nicht entscheiden, ob drei Nachpflegen fehlen — genau die Abzählbarkeit, die Handgriff 5 schützen soll, ist weg.
`klasse` Zahl im Text, die ihr danebenstehendes Kommando nicht liefert

### MEDIUM-2 — Der Wächter misst die Anwesenheit der Marke, die Zusage lautet auf ihre Position
`quelle` [`AGENTS.md`](../../AGENTS.md) §3.6 · `pfad` `test/doc-block-marke-wiring.bats:57`, `harness/README.md:274` · `verifizierbar` nein — kein heutiger Gate-Lauf
`harness/README.md` sagt, die Marke stehe „als **letzte Zeile** ihrer eigenen Ausgabe"; `marke_ausgabe_ziele()` prüft nur, ob *irgendeine* `^\t@echo`-Zeile des Rezepts das Literal trägt. Keine der drei rot gesehenen Lagen (a)(b)(c) nimmt dieser Hälfte die Zähne. Versagen: eine Nachpflege nach einer Regenerierung setzt das `@echo` **vor** den `docker run` — der Wächter bleibt grün, der Mensch liest die Marke zuerst und `0 Befund(e)` zuletzt, also genau die Reihenfolge, gegen die der Slice antritt. Zweite Hälfte derselben Zusage: bricht `docker run` mit Befund ab, führt `make` das `@echo` nie aus — für `doc-tracked`, das derselbe Absatz als *nicht inert* ausweist, ist das ein erreichbarer Zustand.
`klasse` Zusage nennt Position, Sensor misst Anwesenheit

### MEDIUM-3 — Die Gegenprobe aus DoD (1) steht neben Kommandos, die so nicht laufen
`quelle` [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 · `pfad` `harness/README.md:232-256` · `verifizierbar` ja — Kommandos verbatim fahren
Beide Blöcke tragen `--enable … --disable …` mit ausgelassener Flag-Liste und ein nirgends gesetztes `$DCHECK_REF`; der `structure:`-Block, der die **100** Befunde erzeugt, ist gar nicht abgedruckt. Die fünf Zahlen (`1145/1`, `1145/1`, `1144/0`, `1144/100`) sind Messwerte, und MR-025 nennt „ein ungefähr passendes Kommando danebenzustellen" ausdrücklich *den Fehler*. Die Nachbar-Absätze derselben Datei (`closure`, `codepaths`) setzen `DIGEST=$(grep -oE …)` und die volle Invokation. Versagen: die Klassifikation *inert* / *nicht inert*, auf der Marke und Wächter ruhen, ist von niemandem nachzumessen — und gerade die elidierte `--disable`-Liste entscheidet, ob ein oder alle Module liefen.
`klasse` Messwert ohne fahrbares Kommando

### MEDIUM-4 — Der Deckungsnachweis wächst in den Abschnitt, den `slice-114` auflösen soll
`quelle` `grundlagen-harness-dateien.md` §harness/README.md als Einstiegspunkt · `pfad` `harness/README.md:197-281` · `verifizierbar` nein — Urteil
`awk '/^## Sensors/{f=1} /^## Traceability/{f=0} f' harness/README.md | wc -c` → **78 413** von `wc -c < harness/README.md` **81 570** Bytes, also **96 %** der Datei (vorher 72 881); der Zuwachs ist **+5 532 B**. Die Ziel-Form verlangt *„Ein Gate je Datei, sobald sein Vertrag mehr braucht als einen Satz"* (`harness/sensors/<target>.md`, hier nicht angelegt) und schließt aus: *„Nicht hinein gehört, womit das Werkzeug selbst gedeckt ist — welcher Test welche Hälfte trägt"* — genau das trägt der Schluss-Absatz. `grep -n '114' <plan>` → keine Zeile: der Plan wägt die offene Adresse [`slice-114`](../plan/planning/in-progress/slice-114-jede-aussage-hat-einen-abschnitt.md) nicht ab, obwohl DoD (1) den Ort vorschreibt. Versagen: `harness/README.md` ist Schritt 1 des Minimal Agent Workflow; jeder Lauf liest 81 kB, um eine Zeile zu brauchen, und slice-114 misst bei seinem Schnitt eine um 5,5 kB größere Halde.
`klasse` Deckungsnachweis in den Einstieg statt in den Werkzeug-Kopf

### LOW-1 — `exempt-targets` wird dem Modul `tracked` zugeschrieben, im Repo ist es ein `targets`-Schlüssel
`quelle` Maintainability · `pfad` `harness/README.md:239,246` · `verifizierbar` ja — `d-check --print-config`
Der Absatz begründet die Byte-Gleichheit mit *„weil der eingebaute Default (`exempt-targets: []`) schon ohne Block gilt"* und ergänzt probeweise `tracked: {exempt-targets: []}`. Im Repo trägt diesen Schlüssel das Modul **`targets`** (`grep -nE '^[a-z-]+:' .d-check.yml` → `85:targets:`, darunter `89:  exempt-targets:`), 55 Zeilen weiter oben in derselben README-Sektion mit anderer Bedeutung. Versagen: trifft `tracked` den Schlüssel nicht, war der Zusatz-Block ein ignorierter Schlüssel und die Gegenprobe belegt nur, dass ein No-Op nichts ändert — die Folgerung *„nicht inert"* trägt dann allein der Lauf **ohne** Block. Das Verdikt selbst bleibt davon unberührt, die Begründung nicht.
`klasse` Konfigurations-Schlüssel dem falschen Modul zugeschrieben

## Negativbefunde (geprüft, ohne Befund)

- **Ableitung der C-Menge** (§3.6-Kernfrage): `c_ziele()` zählt keinen Zielnamen auf, sondern filtert über `--enable`-Modul + `grep -qE "^${modul}:" .d-check.yml`; die `awk`-Helfer manuell nachgefahren → 13 Ziele, C = `doc-tracked`, `doc-structure`, deckungsgleich mit der Klassen-Tabelle des Plans.
- **Mutations-Fall 309 beißt:** `citations` trägt in `.d-check.yml` keinen Top-Level-Block (`grep -nE '^[a-z-]+:'`), das Sondenziel fällt also real in C; Rezept-Zeile beginnt mit Tab (`cat -A`), `# expect:` nennt den bats-Fall wortgleich, `END { finish() }` erfasst das ans Dateiende angehängte Ziel.
- **Leere Menge:** der zweite `@test` verhindert die Bijektion über der leeren Menge — die Falle, an der ein solcher Wächter still grün bliebe.
- **`doc-help` zerschneidet die Marke nicht:** `sed -E 's/:.*## /  /'` (`d-check.mk:125`), das Literal führt kein `## ` — DoD-(2)-Nebenbedingung gehalten.
- **Marke behauptet kein Verhalten:** sie nennt allein die syntaktische Tatsache; README und Commit-Message machen dieselbe Aussage, keine reicht weiter als die Messung.
- **[`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert):** die Nachpflege ist als nummerierter Handgriff 5 deklariert, nicht als Generat-Text getarnt (Zahl-Frage s. MEDIUM-1).
- **Out-of-Scope §1 gehalten:** `.d-check.yml` unberührt, kein `internal/`/`cmd/` im Diff (`git show --name-only`), `modules:` unverändert, `welle-13.md` nicht angefasst.
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):** kein neues `make`-Ziel, keine neue Gate-Tabellenzeile; beide Ziele stehen bereits in `targets.exempt-targets`, das `targets`-Modul bleibt grün.
- **[`AGENTS.md`](../../AGENTS.md) §3.7:** weder `d-check.mk` noch die zwei neuen Testdateien tragen Slice-Nummer oder Befund-Kennung im Kommentar (`grep -nE '(#|//).*(slice-[0-9]|Review-Befund)'` → leer); README-Prosa ist kein Zustandsfeld.
- **[`AGENTS.md`](../../AGENTS.md) §3.11:** die Pfad-Verweise auf `welle-13` und `slice-213` stehen in einem lebenden Artefakt — der Move zieht sie nach, kein einfrierendes Artefakt betroffen.

## Kategorie-Summary

0 HIGH · 4 MEDIUM · 1 LOW · 0 INFO. Wiederkehrende Klasse dieses Laufs: **Zusage/Zahl ohne das Kommando bzw. den Sensor, der sie hält** (MEDIUM-1, -2, -3) — dritte Wiederholung derselben Klasse in einer Sitzung, damit Steering-Loop-Signal für die Closure §7.

## Verdikt

**Blockiert** — 4 MEDIUM. Der Kern des Slice trägt: die C-Menge ist wirklich abgeleitet, der Mutations-Fall greift, die Marke behauptet nicht mehr als sie kann. Die Befunde liegen an den Rändern: die Abzählbarkeit des Adopter-Kopfs (MEDIUM-1), die ungewächterte Positions-Hälfte der Zusage (MEDIUM-2), die nicht nachfahrbare Gegenprobe (MEDIUM-3) und der Ort des Zuwachses (MEDIUM-4).
