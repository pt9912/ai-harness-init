# Review slice-114 — Harness-Einstieg auf die Ziel-Form, 14 Sensor-Dateien

**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Commit:** `9a57f2b3` (15 Dateien, +782/−471) ·
**Plan:** [`slice-114`](../plan/planning/in-progress/slice-114-jede-aussage-hat-einen-abschnitt.md) ·
**Ziel-Form:** `.harness/baseline/v6.5.0/regelwerk/grundlagen-harness-dateien.md` §harness/README.md und die Vorlage `.harness/baseline/v6.5.0/templates/harness/sensors/gate.template.md` ·
**Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7/§3.11 · **MR:** `MR-008`, `MR-025`, `MR-045` ·
**Vorlauf:** [`slice-217`](2026-09-12-slice-217-doc-ziel-nennt-seinen-pruefbereich.md) MEDIUM-4

## Findings

**HIGH-1 · Ziel-Form §harness/README.md · `harness/sensors/archive-welle.md:5,7,11,17` + 8 weitere Dateien ·** Ziel-Form und Vorlage schließen den Deckungsnachweis aus der Sensor-Datei aus (*„Nicht hinein gehört, womit das Werkzeug selbst gedeckt ist — welcher Test welche Hälfte trägt, welcher Mutations-Fall welchen Zweig bewacht"*); 9 der 14 Dateien tragen ihn mit 34 Nennungen (`grep -hoE 'test/[a-z0-9-]+\.bats|test/mutations/[a-z0-9.-]+\.sh|\bTest[A-Z][A-Za-z_]+|[a-z_]+_test\.go' harness/sensors/*.md | wc -l`). Damit tritt der Fall ein, den dieselbe Stelle benennt — *„der Ort hätte gewechselt, die Menge nicht"*: 76 869 der 78 413 Bytes des alten Abschnitts sind ungefiltert umgezogen (`cat harness/sensors/*.md | wc -c` gegen `git show 9a57f2b3^:harness/README.md | awk '/^## Sensors/{f=1} /^## Traceability/{f=0} f' | wc -c`).
Versagen: wird `TestZipIstUeberZweiLaeufeByteGleich` umbenannt, behauptet `archive-welle.md` die Deckung weiter — kein Sensor liest diese Namen. **Verifizierbar:** nein · **Klasse:** „Sensor-Datei trägt Deckungsnachweis statt Grenze".

**MEDIUM-1 · `MR-008` / Vorlage `gate.template.md` · `harness/sensors/archive-welle.md:5` ·** Keine der 14 Dateien ist aus der vendored Vorlage entstanden: `grep -h '^## ' harness/sensors/*.md | sort | uniq -c` → nur Vertrag (14), Grenze (9), Bindung (14); die Vorlagen-Abschnitte *Ausgabe und Ausgänge* und *Sperren* fehlen durchweg (`grep -l '^| Exit' harness/sensors/*.md` → keine), obwohl vier Dateien Exit-Codes und `archive-welle.md` acht Sperren führen — dort in einer Vertrag-Zeile von 6 089 Zeichen (`awk '{if(length>m)m=length}END{print m}' harness/sensors/archive-welle.md`).
Versagen: wer die Abbruch-Bedingung eines Laufs sucht, findet sie nicht an dem Ort, den die Vorlage dafür führt — dieselbe Klasse, die der Plan §1 als Ursache des Ausgangsbefunds nennt. **Verifizierbar:** nein · **Klasse:** „Artefakt nachgebaut statt aus der Vorlage kopiert".

**MEDIUM-2 · Plan §4 (Rückführung `in-progress → next`) · Plan gegen Diff ·** Der Plan nennt `harness/sensors/` an keiner Stelle (`grep -c sensors docs/plan/planning/in-progress/slice-114-*.md` → 0) und macht den Fall, dass die Sätze „nicht in Skript-Köpfe passen, sondern eine eigene Ziel-Form brauchen", zur Rückführungs-Bedingung; die Commit-Message stellt genau das fest (*„weil kein anderer Ort existiert"*, 9 Dateien), der Lauf hat die Rückführung nicht gezogen.
Versagen: die Form-Entscheidung über einen neuen Artefakt-Baum fällt im Implementations-Kontext ohne zweiten Blick. **Verifizierbar:** nein · **Klasse:** „benannte Rückführungs-Bedingung eingetreten, nicht gezogen".

**MEDIUM-3 · Ziel-Form (*lebendes Artefakt adressiert die Sensor-Datei*) · `AGENTS.md:474,481` ·** §4 sagt weiter *„Die Beschreibung dieser Ziele — was jedes prüft, was es nicht prüft … — steht in `harness/README.md`"* und verweist für `comment-claims` auf *„Details in `harness/README.md`"*; beide Beschreibungen liegen seit diesem Commit in `harness/sensors/*.md`.
Versagen: ein Lauf folgt dem Zeiger aus Rang 8, findet in Rang 9 eine Tabellenzeile und schließt, dass es keine weiteren Grenzen gibt. **Verifizierbar:** nein (`links` prüft die Datei, nicht die Aussage) · **Klasse:** „Zeiger überlebt den Umzug seines Ziels".

**MEDIUM-4 · Ziel-Form §Bindung-Spalte · `harness/README.md:69` ·** Die Zeile `make smoke` trägt als Bindung `kein Gate · slice-002` — eine Klasse außerhalb der vier kanonischen und in [`harness/conventions.md`](../../harness/conventions.md) nicht deklariert (`grep -ci bindung harness/conventions.md` → 0), während die Ziel-Form sagt: *„Eine Bindung ohne Deklaration ist eine stille Setzung — und damit eine Harness-Lüge in derselben Klasse wie ein halluziniertes Gate."*
Versagen: ein Reviewer kann `slice-002` nicht von einem Tippfehler unterscheiden. **Verifizierbar:** nein · **Klasse:** „undeklarierte Bindungs-Klasse".

**LOW-1 · Vorlage (*Kopiere nach `harness/sensors/<target>.md`*) · `harness/README.md:48` ·** `make docs-check` zeigt auf `sensors/doc-check.md`; der Dateiname folgt dem Target nicht — alle übrigen 13 Paare stimmen überein (Target und Dateiname aus den Target-Zellen extrahiert und verglichen). Versagen: wer den Pfad aus dem Target ableitet — Mensch oder ein künftiger Namens-Sensor —, greift ins Leere; die Ziel-Form führt genau *Zeile zeigt auf die falsche Datei* als still grün. **Verifizierbar:** nein · **Klasse:** „Dateiname weicht vom Target ab".

**LOW-2 · `AGENTS.md` §3.6 · `harness/sensors/hook-overhead.md:9` ·** Der Satz *„in keiner Tabelle oben"* ist mitgezogen; `hook-overhead` steht seit diesem Commit in der Tabelle *Werkzeuge (kein Gate)* (`grep -n 'hook-overhead' harness/README.md`), und in der Sensor-Datei hat „oben" keinen Bezug. Versagen: die Aussage ist an ihrem neuen Ort falsch und an keinem Sensor. **Verifizierbar:** nein · **Klasse:** „deiktischer Verweis überlebt den Umzug".

**LOW-3 · Ziel-Form (*was seine Ausgabe bedeutet*) · `harness/README.md:72` ·** Für `make span-report` entfällt ersatzlos, was seine Ausgabe bedeutet (alt: *„die Ausgabe nennt ihren Nenner, den Sammelposten-Anteil und die Abdeckungszahl samt Bezugsmenge"*); eine Sensor-Datei gibt es nicht, der Makefile-Kopf trägt nur den leeren Nenner (`sed -n '302,313p' Makefile`), und die vom Plan §3 verlangte Zuordnungs-Liste *Aussage → Ziel oder Entfall mit Grund* liegt dem Commit nicht bei. **Verifizierbar:** nein · **Klasse:** „stille Löschung beim Verschieben".

## Negativbefunde

- **Prosa gewandert, nicht neu geschrieben:** satzweiser Abgleich gegen `9a57f2b3^:harness/README.md` findet keine unbelegte neue Sachaussage; die drei prüfbaren neuen Sätze treffen zu (acht aktive Module in `.d-check.yml:29` · `structure:`-Block ist DoD (2) von `slice-213` · `exempt-targets` 17 Tabellen-Ziele + 20 aufgezählte = 37, bijektiv geprüft).
- **Zuwachs erklärt:** +5 596 Bytes gegenüber dem alten Stand bei 204 Struktur-Zeilen in `harness/sensors/` (`cat harness/sensors/*.md | grep -cE '^#|^$'`) — die +311 Zeilen sind Umbruch, kein Text.
- **Kein tragender Verlust:** die fünf benannten Grenzen sind angekommen (`comment-claims` drei Achsen · `codepaths`/vendored Baum samt 128/102-Messung · `doc-commits` unbedienbar · `archive-welle` acht Sperren); `mutate` ist auf den Skriptkopf verkürzt, und der trägt sie wirklich (`grep -cE 'isolation_key_files|ISOLATION_KEY_EXEMPT|MUTATE_STALL_SECONDS' harness/tools/mutate.sh` > 0).
- **Sensor trägt:** 14 von 14 Dateien hängen an einer Target-Zelle am Zeilenanfang, keine Datei ohne Index-Zeile (`ls harness/sensors | wc -l` → 14; Target-Zellen-Links gezählt → 14).
- **Gegenbeispiel rot gesehen (§3.6):** Kommando und Ausgabe stehen in der Commit-Message (`target-missing`, Exit 1 → Exit 0), und `harness/README.md:48` ist die dort genannte Zeile. Der fehlende `test/mutations/`-Fall ist belegt unmöglich — `failure_form()` kennt keinen `docs-check`-Modus (`grep -n '^failure_form()' -A16 harness/tools/mutate.sh`, Default `return 1`); die Register-Klasse `BEO-ALL/neuer-waechter-ohne-mutations-fall` existiert.
- **Pflichtgliederung:** alle acht Abschnitte in der Reihenfolge der Vorlage; Leseordnung mit vier geordneten Zeigern, unverändert.
- **DoD-Zahlen:** längste Zeile 261, Sensors-Prosa 651 Zeichen — beide gemessen, beide unter der Schranke.
- **§3.11 und Rollen-Eigentum:** kein einfrierendes Artefakt berührt, keine Adresse in `docs/reviews/**` oder `done/**` geändert; `AGENTS.md`, `harness/conventions.md`, `.d-check.yml`, `internal/` unverändert (`git show --numstat 9a57f2b3`).

## Kategorie-Summary

HIGH 1 · MEDIUM 4 · LOW 3 · INFO 0. Wiederkehrende Klasse: **Verschieben ohne Filter — der Ort wechselt, die Menge bleibt** (HIGH-1, MEDIUM-1, LOW-2 und LOW-3 sind vier Ausprägungen desselben Musters).

## Verdikt

**Blockiert.** HIGH-1 und MEDIUM-1 treffen den Gegenstand des Slice selbst: die mechanische Hälfte der Ziel-Form (eine Datei je Gate, Target-Zelle als Link, Gegenbeispiel rot gesehen) ist erreicht und belegt, die inhaltliche (Filter gegen den Deckungsnachweis, Abschnitts-Form der Vorlage) nicht. MEDIUM-2 gehört vor jede Fortsetzung an den Planner.
