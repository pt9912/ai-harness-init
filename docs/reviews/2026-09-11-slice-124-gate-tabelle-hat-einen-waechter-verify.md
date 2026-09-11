# Verifikation — slice-124: Die Gate-Tabellen bekommen einen Wächter

**Rolle:** Verifier (Modul 11, frischer Kontext) · **Datum:** 2026-09-11

## Eingang

- **Slice-Plan:** [`docs/plan/planning/done/slice-124-gate-tabelle-hat-einen-waechter.md`](../plan/planning/done/slice-124-gate-tabelle-hat-einen-waechter.md)
  — alle drei DoD-Häkchen `[ ]` (korrekt, [`AGENTS.md`](../../AGENTS.md) §3.10: Closure ist Planner-Arbeit).
- **Zwei Review-Runden:** [Runde 1](2026-09-11-slice-124-gate-tabelle-hat-einen-waechter.md)
  (1 HIGH/3 MEDIUM/2 LOW/1 INFO, blockierend) · [Runde 3](2026-09-11-slice-124-runde-3-anker-und-formulierungen.md)
  (0 HIGH/1 MEDIUM/3 LOW, blockierend, *„Übergabe an den Verifier: nach dieser einen Umformulierung"*).
  (Es gibt keine separat abgelegte „Runde 2" — Runde 3 deckt die Commits `adce3be1`+`5d3f13b3`, die
  Runde-1-HIGH-1 behoben.)
- **Commit-Kette (Plan-Umfang):** `6f454e15` (erster Implementer-Commit) … `d55fd1d9` (Runde-4-Fix, MEDIUM-1
  aus Runde 3 gestrichen statt repariert). Davor zwei reine `slice-mv`-Commits (`d7fb8844`, `b90fb9d9`),
  nicht Gegenstand der Reviews und hier ebenfalls nicht erneut geprüft (Lifecycle-Bewegung).
- **Baum bei Prüfungsbeginn:** `git status --porcelain` leer, `HEAD` = `d55fd1d9`.
- **Betriebsauflage dieser Verifikation:** kein `make gates`/`mutate`/`full-smoke`/`test`/`smoke`/`docs-check`
  und kein `docker build` selbst gefahren — ein `make mutate`-Vollauf (288 Fälle, 4 Worker, gestartet 10:20,
  `.harness/state/mutate.lock` vorhanden) teilt sich Docker-Tags mit jedem `make`-Gate-Lauf. Evidenz
  stattdessen über: den vorhandenen `record-gates`-Stempel (reiner Hash-Vergleich, kein Docker), vier
  einzelne `docker run --network none --rm -v <kopie>:/repo:ro` gegen den in `d-check.mk` gepinnten Digest
  (`sha256:e31a372b…`) über Kopien außerhalb des Repos, sowie hermetisches `sed`/`awk`/`grep`/`diff`.

## 1. DoD Punkt für Punkt — Sache statt Häkchen

**(1) `targets` ist in `.d-check.yml` aktiviert und läuft in `make gates`.**

- `grep -n '^modules:' .d-check.yml` → `modules: [links, anchors, ids, matrix, codepaths, spans, planning,
  targets]` — `targets` ist Teil der bestehenden Modul-Liste, kein zweites Gate-Ziel (`d-check.mk` hat kein
  `doc-targets`-Rezept in der `gates`-Kette — `grep -n 'doc-targets' Makefile` → kein Treffer). `docs-check`
  liest `.d-check.yml` implizit (`docker run … $(DCHECK_REF)` ohne `--config`), also läuft `targets` bei
  jedem `make docs-check`/`make gates`.
- **„Stilles Grün" selbst nachgemessen** (Instruktion 2), am Elternstand vor dem ersten Implementer-Commit
  (`6f454e15^`, `.d-check.yml` dort ohne `targets:`-Block): dieselben Flags wie das `doc-targets`-Rezept
  → `d-check: 1098 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Exakt die im Plan behauptete Zahl. Bestätigt: das
  Modul lief und prüfte nichts.
- **Beide Richtungen selbst rot gesehen** (Instruktion 3), am aktuellen `HEAD`, je eine isolierte Kopie:
  - `gate-phantom`: Tabellenzeile `` `make phantom-verify-gate` `` an `AGENTS.md` angehängt →
    `AGENTS.md:500  phantom-verify-gate  gate-phantom  dokumentiertes Target … ohne Makefile-Regel`,
    `1100 Datei(en), 1 Befund(e)`, **Exit 1**.
  - `gate-undocumented`: `.PHONY`-Rezept `verify-neues-ziel` an `Makefile` angehängt →
    `Makefile:414  verify-neues-ziel  gate-undocumented  … ohne Deklaration in der Autoritäts-Doku AGENTS.md`,
    `1100 Datei(en), 1 Befund(e)`, **Exit 1**.
  - Grüner Start am aktuellen `HEAD`, unverändert: `1100 Datei(en) geprüft, 0 Befund(e)`, Exit 0.
- **Erfüllt** — drei eigene Docker-Läufe zusätzlich zum vierten oben, insgesamt vier.

**(2) Jeder Befund des gewählten Config-Blocks ist aufgelöst; die sechs in Prosa dokumentierten Ziele sind
ausdrücklich entschieden.**

- `makefiles: [Makefile, d-check.mk]` korrigiert `docs-check` (kein `exempt-targets`-Eintrag dafür,
  `comm -12` zwischen Ausnahmeliste und Autoritäts-Tabelle bleibt leer) — die im Plan §1 benannte
  Config-Korrektur ist umgesetzt, nicht durch eine Ausnahme ersetzt.
- `exempt-targets`: **36** Einträge, exakt (`grep -E '[*?\[]'` über die extrahierte Liste → kein Treffer,
  selbst geprüft), in zwei benannten Gruppen. Gruppe (a), **16** Namen, trägt seit `d55fd1d9` die
  Begründung *„kein Gate-Versprechen (wie (b)), jedes Rezept zusätzlich in harness/README.md namentlich
  genannt"* — **beide Hälften an allen 16 Namen selbst nachgemessen**:
  - *namentlich genannt*: `grep -cF "$t" harness/README.md` für jeden der 16 Namen → jeder Wert ≥ 2 (die
    Ausnahme-Absatz-Zeile zählt mit, also mindestens eine weitere Fundstelle je Name).
  - *kein Gate-Versprechen*: keiner der 16 Namen steht als `make X`-Tabellenzeile in `AGENTS.md` §4 (die
    Gate-Tabelle selbst gelesen — 11 Zeilen, keine der 16 darunter) und `record-gates` selbst ist nicht Teil
    der Zeilen, die es startet.
  - Damit ist die MEDIUM-1-Reparatur aus Runde 3 (gestrichen statt ein drittes Mal repariert) tragfähig:
    Die vorherigen zwei Formulierungen (Runde-1-Text „in Prosa erklaert, was es prueft und was nicht" und
    Runde-3-Zwischenstand „in harness/README.md in Prosa erklaert") behaupteten je ein Konjunkt, das 4 bzw.
    2 der 16 nicht trugen; die jetzige Formulierung ist gegen den vollständigen Bestand der 16 falsifizierbar
    und hält.
- Die sechs ursprünglich strittigen Ziele (`smoke`, `full-smoke`, `mutate`, `span-clean`, `span-report`,
  `hook-overhead`) stehen namentlich in derselben Gruppe (a) und in derselben `harness/README.md`-Passage
  (Zeile 181–192) — explizit entschieden, nicht stillschweigend in eine Muster-Ausnahme gelegt.
- Die zwei bats-Tests `jedes .PHONY-Target ohne Tabellenzeile in AGENTS.md steht genau einmal in
  exempt-targets` und `kein exempt-targets-Eintrag ist zugleich eine AGENTS.md-Tabellenzeile`
  (`test/targets-modul-wiring.bats`) halten die Bijektion laufend, nicht nur zum Zeitpunkt der Kuratierung.
- **Erfüllt.**

**(3) Die Grenzziehung in `MR-010` Setzung 2 ist nachgezogen — als Übergabe, nicht als Eigenmacht.**

- Der Plan sagt selbst: „Kein Kommando faerbt diesen Punkt rot … Der Slice liefert die Messung; der
  Norm-Text entsteht im Architect-Lauf." Kein mechanischer Sensor ist also anwendbar — geprüft ist die
  **Messung**, nicht ihre Umsetzung.
- Die Messung selbst wurde zwischen den Runden korrigiert: Runde 1 LOW-1 hielt die Plan-Prämisse für falsch
  widerlegt (Setzung 2 bleibt zutreffend, weil `targets` ein **Modul innerhalb** von `docs-check` ist, kein
  zweites Gate-**Ziel**); Runde 3 bestätigt das explizit unter „LOW-1 aus Runde 1 ist zu Recht zurückgezogen"
  und weist stattdessen `MR-001` (Modul-Aktivierung) als die tatsächlich offene Norm-Änderung aus. Selbst
  nachgemessen: `grep -n 'targets' harness/conventions/MR-001-…md` → kein Treffer — die Übergabe ist real
  offen, korrekt benannt, und liegt bei `MR-001`, nicht bei `MR-010`.
  `git diff 6f454e15^..HEAD --stat -- AGENTS.md harness/conventions.md harness/conventions/` → leer:
  [`AGENTS.md`](../../AGENTS.md) §3.8 ist eingehalten, kein Norm-Text im Implementer-Lauf geschrieben.
- **Erfüllt** — als das, was DoD (3) verlangt: eine korrekt adressierte Messung, kein Vollzug. Der
  tatsächliche Architect-Lauf (MR-001-Eintrag für die Aktivierung von `targets`) bleibt offen und ist
  **kein** Blocker dieses Slice — DoD (3) definiert genau das als seinen Erfüllungspunkt.

**Unbenannter vierter Punkt — Standard-Closure-Trigger aus §5 des Plans.**

- **`make gates`: grün, belegt ohne eigenen Docker-Lauf.** `.harness/state/gates-passed.diffsha` =
  `fa5cb2aa…03e25`; `bash harness/tools/working-tree-hash.sh` liefert für den aktuellen, sauberen Baum
  denselben Wert. Der Gate-Stempel deckt exakt `HEAD` = `d55fd1d9` — unabhängig vom Implementer-Bericht.
- **`make mutate`: OFFEN.** Siehe Abschnitt 3.
- **Review nach Modul 10:** zwei Runden, letztes Verdikt „Übergabe an den Verifier: nach dieser einen
  Umformulierung" — die Umformulierung ist in `d55fd1d9` erfolgt und oben gegen den Bestand nachgemessen.
- **Verifikation nach Modul 11:** dieser Bericht.
- **Closure-Notiz §7:** unverändert `<!-- Erst nach Abschluss fuellen -->` — korrekt, Planner-Arbeit.

## 2. Plan-vs-Code-Diff

Grundlinie: `6f454e15^` (Stand vor dem ersten Implementer-Commit) gegen `HEAD` = `d55fd1d9`. Der Slice-Plan
selbst ist über die gesamte Kette unverändert (`git diff 6f454e15^..HEAD -- docs/plan/planning/done/slice-124-gate-tabelle-hat-einen-waechter.md`
→ leer) — die Grundlinie ist damit stabil, keine nachträgliche Plan-Anpassung an den Code.

`git diff 6f454e15^..HEAD --stat`:

| Plan sagt (§3) | Code tut | Deckung |
|---|---|---|
| `.d-check.yml` update | `targets` in `modules:` + vollständiger `targets:`-Block (36 Ausnahmen, 2 Gruppen, Config-Korrektur `makefiles`) | ✅ |
| `AGENTS.md` §4 update | **keine Änderung** | ✅ — Tabelle war bereits korrekt (0 Befunde gegen die gewählte Config, selbst gemessen); „update" war eine Eventualität, keine feste Zusage |
| `harness/README.md` update | neuer Absatz (Prüfbereich, 36 Ausnahmen, beide Gruppen, Autoritäts-Asymmetrie) + Modul-Aufzählung nachgezogen (`…, planning, targets`) | ✅ |
| `test/` neu (Zahn + `test/mutations/`) | `test/targets-modul-wiring.bats` (7 `@test`), `test/mutations/301`, `302`; zusätzlich `269`/`279` gehärtet (Regression aus Runde 1, in derselben Kette behoben) | ✅ |
| `harness/conventions.md`/`harness/conventions/` — **nicht durch diesen Slice** | unverändert | ✅ — Übergabe an Architect korrekt nicht vollzogen |
| `internal/emit/` — unverändert | unverändert | ✅ |

**Außerhalb der Plan-Tabelle, aber im Diff:** `.github/workflows/ci.yml` (1 Kommentarzeile, Modul-Aufzählung
nachgezogen — MEDIUM-2 aus Runde 1, vom Reviewer als sachlich nächstliegend statt Scope-Verstoß bewertet,
hier bestätigt: reiner Kommentar, keine Funktionsänderung) und
`docs/plan/planning/in-progress/roadmap.md` (Ruhe-Marker → Zustandszeile, INFO-1 aus Runde 1 — Rollen-Frage
unbeantwortet, aber inhaltlich korrekt und durch Bestand gedeckt, kein Blocker). Zwei neue Review-Report-Dateien
unter `docs/reviews/` sind Prozess-Artefakte, kein Code-Diff.

**Kein Scope-Leck:** `git diff 6f454e15^..HEAD --stat` trifft keine weitere Datei außerhalb der Plan-Tabelle,
der zwei benannten Nebeneffekte und der Review-Reports.

## 3. Der eine offene Sensor — `make mutate`, Abnahme-Kriterium statt Urteil

**Lage bei Prüfungsende:** `make mutate` läuft seit 10:20 (`ps`: PID 301963 `make mutate`, vier
Worker-Prozesse aktiv, `.harness/state/mutate.lock` vorhanden, kein `mutate-passed.key` mit passendem
Isolationsschlüssel — der Lauf ist ein echter Versuch, kein Cache-Übersprung). Fallzahl heute:
`ls test/mutations/*.sh | wc -l` → **288**.

**Vorgeschichte (Auftrag, nicht mein Fund):** drei vorherige Läufe unvollständig — zwei bewusst von der
aufrufenden Rolle beendet (anstehende Korrekturen betrafen Mutations-Zieldateien), einer an einem
Netzausfall gestorben (`docker/dockerfile:1.7` nicht auflösbar), der dabei für die Fälle `100`/`101`
korrekt `„rot, aber der erwartete Test faellt nicht — falscher Grund"` meldete. Das ist laut Auftrag ein
Umgebungs-Artefakt, kein Zahn-Defekt — ich übernehme diese Einordnung nicht ungeprüft als Freispruch für den
laufenden Lauf, sondern als Kontext dafür, wie ein `100`/`101`-Fehlschlag im **nächsten** Ergebnis zu lesen
wäre, falls er erneut auftritt.

**Abnahme-Kriterium — was „grün" hier bedeutet, gegen den Code von `harness/tools/mutate.sh`:**

Erfüllt ist der `mutate`-Teil des Closure-Triggers (Plan §5: *„`make mutate` ohne Befund"*) genau dann, wenn
der abgeschlossene Lauf **alle** vier Bedingungen zeigt:

1. Exit-Code des Rezepts `make mutate` = **0** (`main()` gibt `[ "$fail_count" -eq 0 ]` zurück,
   `harness/tools/mutate.sh:1660f`).
2. Die Bilanz-Zeile lautet exakt `mutate: 288 ok, 0 Befund(e)` (`harness/tools/mutate.sh:1659`).
3. **Keine** Zeile der Form `mutate: BEFUND …` im vollständigen Log — unabhängig von der Klasse. Insbesondere
   zählt eine `vollstaendigkeit`- oder `zeit-bilanz`-Meldung (unvollständiger Lauf, Bedingungen aus
   `harness/tools/mutate.sh:1311/1348/1385`) **nicht** als „grün", selbst wenn alle gezogenen Einzelfälle
   `ok` waren — genau die Form, die ein früherer Vollauf dieses Repos bereits gezeigt hat.
4. Insbesondere tragen die drei in diesem Slice neu verankerten bzw. gehärteten Fälle `269`, `279`, `301`
   je eine eigene `mutate: ok  <name>`-Zeile — ihr Fehlen (oder ein `BEFUND` an einer dieser drei Adressen)
   wäre der Rückfall in die HIGH-1-Regression aus Runde 1, unter dem echten Treiber statt unter der isolierten
   Nachmessung des Reviewers.

**Verfehlt** ist das Kriterium bei jeder Abweichung von 1–3, einschließlich: Exit ≠ 0, jeder `BEFUND`-Zeile,
einer Bilanz-Zeile mit anderer Zahl als `288 ok, 0 Befund(e)`, oder einem durch `MUTATE_STALL_SECONDS`
selbst-terminierten Lauf (Log nennt dann die noch laufenden Worker statt einer Bilanz).

**Sonderfall `100`/`101`:** Meldet der abgeschlossene Lauf ausschließlich für diese zwei Fälle
`„rot, aber … faellt nicht — falscher Grund"`, mit erkennbarem Netz-/BuildKit-Bezug in der Fehlermeldung
(`docker/dockerfile:1.7` nicht auflösbar o. ä.), ist das nach der oben referenzierten Vorgeschichte ein
Umgebungs-Artefakt und **kein** slice-124-Befund — der Plan-Closure-Trigger verlangt dennoch wörtlich „ohne
Befund"; ein Planner, der auf dieser Grundlage schließen will, braucht einen **erneuten** Lauf mit
funktionierendem Netz-Pull, nicht eine Ausnahme für diesen Lauf. Jeder andere `BEFUND` — insbesondere an
`269`, `279`, `301`, `302` oder an einer bislang unbeteiligten Adresse — ist ein echter Fund und bräuchte
eine eigene Einordnung, keine.

**Ich behaupte kein Ergebnis.** Bei Abschluss dieser Verifikation läuft der Lauf weiter; kein Log dieses
Laufs liegt mir vollständig vor.

## 4. ADR-/Hard-Rule-/MR-Konformität

- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).** Der Slice schließt
  exakt die im Plan benannte Lücke (ein Modul, das lief und nichts prüfte) und benennt selbst, was offen
  bleibt (Prosa-Erwähnungen außerhalb von Tabellenzeilen, zweite `doc-tables`-Datei nur Richtung 2) — beides
  in `harness/README.md` dokumentiert, nicht verschwiegen.
- **[`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  (Gate-*Anheben*, kein ADR nötig).** `targets` erweitert `modules:`, keine Schwelle sinkt — konform mit der
  Selbstauskunft aus §3.6-Nachbarschaft; der zugehörige Adaptions-Eintrag fehlt noch (DoD (3), Architect-Arbeit,
  offen und korrekt so benannt).
- **[`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) („kein Rückfall
  auf stilles Grün, jede Ventil-Zeile nennt was und warum").** Alle 36 Ausnahmen sind namentlich und mit
  tragender Begründung versehen — nach der `d55fd1d9`-Korrektur auch für die zuvor zu weit gefassten 4 (Runde 1)
  bzw. 2 (Runde 3) Fälle, selbst gegen alle 16 nachgemessen (Abschnitt 1, DoD (2)).
- **[`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 2.**
  Unberührt — `docs-check` bleibt das einzige in `record-gates`/`gates` verankerte Ziel; `doc-targets` selbst
  ist advisory und in keiner Prerequisite-Kette (`grep -nE '^(gates|record-gates):' Makefile` zeigt nur
  `docs-check`). Selbst nachgeprüft, deckt sich mit Runde 3.
- **[`AGENTS.md`](../../AGENTS.md) §3.6 (rot gesehenes Gegenbeispiel).** Beide Grund-Codes des neuen Moduls
  sind eigenständig rot gesehen (Abschnitt 1) — von mir wiederholt, nicht nur aus dem Review übernommen.
  Die drei Mutations-Fälle `269`/`279`/`301` sind auf ihre reale Zieladresse geprüft (Abschnitt „Plan-vs-Code");
  ihr Grün-unter-echtem-Treiber ist der offene Sensor (Abschnitt 3).
- **§3.7 (Kommentar beschreibt, was da ist).** Die drei neuen/geänderten Kommentarblöcke
  (`.d-check.yml`, `harness/README.md`, `test/targets-modul-wiring.bats`) stehen im Indikativ über den
  jetzigen Zustand; keine Forensik, keine Befund-Kennungen — selbst geprüft:
  `git diff 895d07ba..HEAD | grep -E '^\+' | grep -E 'Review-Befund|frueher|bis slice-|Runde [0-9]|HIGH-|MEDIUM-|LOW-'`
  → kein Treffer.
- **§3.8 (Hard Rules/Adaptions-Block nur Architect).** `AGENTS.md`, `harness/conventions.md`,
  `harness/conventions/` über die gesamte Kette unberührt (Abschnitt 2) — konform, und das ist zugleich der
  Grund, warum DoD (3) als Übergabe endet statt als Vollzug.
- **§3.9 (Docker-only).** Kein Host-Toolchain-Aufruf in den geprüften Diffs.
- **§3.10 (Closure ist Planner-Arbeit).** Alle DoD-Häkchen unverändert `[ ]`, §7 trägt den Platzhalter, kein
  `git mv` erfolgt. Konform.
- **Kein Gate gelockert (§3.5).** `modules:` wächst; `exempt-targets` ist eine kuratierte, exakt begründete
  Liste, keine geweitete Ausnahme-Klasse.

## 5. Zusammenfassung — was noch fehlt, unabhängig von `mutate`

1. **`make mutate` über den laufenden Vollauf: Ergebnis noch offen.** Abnahme-Kriterium in Abschnitt 3.
2. **DoD (3) ist als Übergabe erfüllt, der zugehörige Architect-Lauf (MR-001-Eintrag) steht noch aus** — das
   ist per Plan-Definition kein Blocker dieses Slice, sondern der nächste Schritt danach.
3. Die im Plan §6 benannten Risiken brauchen bei Closure ihren Ausgang (Standard-Closure-Arbeit).
4. Zwei LOW-Findings aus Runde 3 (LOW-1: Härtungen ohne eigenen Mutations-Wächter; LOW-3: Listen-Literal-Anker
   in `test/mutations/278`, außerhalb des Slice-Zuschnitts) sind vom Reviewer ausdrücklich nicht als Auflage
   geführt und im Implementer-Commit `d55fd1d9` als Übergabe benannt — Kandidaten für die Closure-Notiz bzw.
   das Beobachtungs-Register, kein DoD-Verstoß.

## Verdikt

**Ist die DoD erfüllt? Nur bis auf den laufenden Sensor.** DoD (1), (2) und (3) sind in der Sache erfüllt und
in dieser Verifikation **eigenständig** nachgemessen — nicht aus den Review-Reports übernommen: vier eigene
`docker run`-Läufe (stilles Grün am Elternstand, grüner Start, beide Grund-Codes rot) plus hermetische
Nachmessung der 16-Namen-Begründung aus DoD (2) und der MR-010/MR-001-Übergabe aus DoD (3). Der Gate-Stempel
(`.harness/state/gates-passed.diffsha`) belegt `make gates` grün für exakt `HEAD` = `d55fd1d9`, ohne dass ich
selbst Docker starten musste. Einzig `make mutate` — wörtlicher Closure-Trigger aus Plan §5 — ist zum
Prüfungszeitpunkt noch nicht abgeschlossen.

**Kann der Planner schließen, sobald der Sensor grün zurückkommt? Ja — unter dem in Abschnitt 3 genannten
Kriterium, mit einer Einschränkung.** Kommt der Lauf mit `mutate: 288 ok, 0 Befund(e)`, Exit 0, ohne jede
`BEFUND`-Zeile zurück, ist kein weiterer Blocker dieser Verifikation offen; DoD (3) verlangt für **diesen**
Slice keinen Architect-Vollzug, nur die Messung, und die liegt vor. Kommt der Lauf ausschließlich mit den
zwei benannten Umgebungs-Befunden (`100`/`101`, Netz-/BuildKit-Bezug) zurück, ist das nach der dokumentierten
Vorgeschichte kein Fund gegen diesen Slice, aber auch kein „ohne Befund" im Wortlaut des Plans — der Planner
braucht dafür einen erneuten, vollständig grünen Lauf, keine Ausnahme für den vorliegenden. Kommt der Lauf mit
einem `BEFUND` an einer anderen Adresse zurück (insbesondere `269`, `279`, `301`, `302`), ist das ein echter,
neuer Fund und diese Verifikation deckt ihn nicht ab — ein erneuter Verifikations-Durchgang wäre dann nötig.

---

**Sensor-Belege dieser Verifikation** (vier Docker-Läufe durch mich, alle `--network none`, `:ro`, gegen
Kopien außerhalb des Repos, Digest `sha256:e31a372b…`):

- Elternstand (`6f454e15^`), Flags des `doc-targets`-Rezepts: `1098 Datei(en), 0 Befund(e)`, Exit 0.
- `HEAD`, `gate-phantom`-Sonde (`AGENTS.md`): `1100 Datei(en), 1 Befund(e)`, Exit 1.
- `HEAD`, `gate-undocumented`-Sonde (`Makefile`): `1100 Datei(en), 1 Befund(e)`, Exit 1.
- `HEAD`, unverändert (grüner Start): `1100 Datei(en), 0 Befund(e)`, Exit 0.
- `bash harness/tools/working-tree-hash.sh` → `fa5cb2aa…03e25`, deckungsgleich mit
  `.harness/state/gates-passed.diffsha`.
- `grep -cF "$t" harness/README.md` für alle 16 Namen der Ausnahme-Gruppe (a) — jeder Wert ≥ 2.
- `grep -n 'targets' harness/conventions/MR-001-…md` → kein Treffer (Übergabe real offen).
- `git diff 6f454e15^..HEAD --stat` sowie `git diff 6f454e15^..HEAD -- <slice-plan>` (leer).
