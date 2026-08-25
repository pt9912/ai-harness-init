# Review-Report: slice-100 — Bestätigungsrunde — 2026-08-25

> `docs/reviews/**` ist doc-gate-exempt (MR-009 `codepaths.exempt-paths`, MR-011 `ids.exempt-paths`)
> — bare IDs und Pfade stehen hier ohne Link-Pflicht.

**Review-Art:** **Code** — Bestätigungsrunde über den Nachzug-Commit zum Runde-1-Report, geprüft
gegen die drei im Auftrag benannten Punkte plus die stehenden Prüfungen. Kein Voll-Review — was in
Runde 1 als Negativbefund geschlossen wurde, ist nicht neu aufgerollt.

**Gegenstand:** `71b6aba..c44519d` — **ein** Commit (`c44519d`), **eine** Datei
(`test/mutate-driver.bats`, +29/−0, `git diff --stat` selbst gemessen). `harness/tools/mutate.sh`
ist **unverändert** (`git diff 71b6aba..c44519d -- harness/tools/mutate.sh | wc -l` → **0**). HEAD =
`c44519d`, Arbeitsbaum sauber (`git status --short` → leer).

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · **Modell:** claude-sonnet-5 · **Datum:** 2026-08-25

**Eingangs-Kontext:**

- **Diff:** `71b6aba..c44519d`, `git diff` im Volltext gelesen; Commit-Message `c44519d` im
  Volltext gelesen.
- **Runde-1-Report:** [`docs/reviews/2026-08-25-slice-100-review.md`](2026-08-25-slice-100-review.md)
  (1 HIGH / 2 MEDIUM) — die zu bestätigende Befundmenge.
- **Slice-Plan:**
  [slice-100](../plan/planning/done/slice-100-vorlauf-nennt-den-grund.md) (aktuelle Fassung
  gelesen, insbesondere DoD (1)).
- **ADR:** keine referenziert, keine berührt.
- **Hard Rules:** `AGENTS.md` §3.2, §3.6, §3.7.
- **Vorherige Findings am gleichen Modul:** Runde-1-Report (oben) — kein weiterer Wiederholungs-
  Fund über drei Runden, kein Steering-Loop-Signal.

---

## Selbst gefahren (nichts aus der Übergabe übernommen)

Alle drei im Auftrag benannten Punkte sind durch eigene Läufe entschieden, zwei davon **im echten
`bats`-Image** (demselben, das `make test-bats` verwendet), nicht nur in einer Bash-Nachbildung.

| Probe | Aufbau | Ergebnis |
|---|---|---|
| Neuer Fall gegen den **unveränderten** `mutate.sh` (Guard intakt), im echten `bats/bats`-Container mit `/code:ro` | eigene `probe.bats`-Datei mit dem Testkörper aus dem Diff, `DRIVER=/code/harness/tools/mutate.sh` | **ok** — beide Assertions passen |
| Derselbe Testkörper gegen eine Kopie von `mutate.sh` mit dem `case`-Guard in `prepare_prerun_log` **komplett entfernt**, im selben Container | `docker run --rm --network none -v $(pwd):/code:ro -v $S/batsprobe:/probe:ro … bats/bats … /probe/probe.bats` | **not ok**, exakt an `[ "$status" -ne 0 ]` (Zeile 39 der Probe) — Status ist **0**, weil `mktemp`-Stub + fehlender Guard den gestubbten Repo-Pfad klaglos durchreicht |
| Derselbe Testkörper gegen eine Kopie mit **unverändertem** Guard, aber geändertem Meldungs-Wortlaut (`"anderer Wortlaut"` statt `"das Vorlauf-Protokoll laege im Repo"`) | derselbe Container-Aufbau | **not ok**, exakt am `grep -qF …`-Marker (Zeile 58) — Status bleibt **1** (Guard feuert), nur der Marker fehlt |
| Standalone-Vorprobe (reines `bash`, außerhalb Docker) derselben drei Varianten | identischer Testkörper, direkt ausgeführt | deckungsgleich mit den Container-Ergebnissen — bestätigt, dass die Container-Läufe nicht durch Umgebungsartefakte verfälscht sind |
| `make mutate` läuft NICHT in Docker | `grep -n '^mutate:' -A2 Makefile` → `@bash harness/tools/mutate.sh` (kein `docker run`); `make test-bats` dagegen `docker run … -v $(CURDIR):/code:ro …` | bestätigt: der `:ro`-Mount ist eine Eigenschaft **ausschließlich** des `test-bats`-Targets, nicht von `mutate.sh` selbst — unter `make mutate` läuft der Treiber mit `bash`-`BASH_SOURCE`-Auflösung direkt auf dem Host-Checkout (schreibbar) |
| Fall 72 (`sed -i 's/^      return 1$/      return 0/'`) auf eine isolierte Voll-Kopie (`tar`-Kopie, wie `prepare_isolation` es tut) angewandt, volle `mutate-driver.bats`-Suite im echten Container gefahren | `docker run … bats/bats … test/mutate-driver.bats` gegen die mutierte Kopie | **1..21**, genau **zwei** `not ok`: #5 (`isolation_path VERWEIGERT …`, eigener Zweck des Falls) und #12 (`der abgebrochene Gruen-Vorlauf zeigt stdout UND stderr …`, Kollateral-Treffer an `mutate.sh:474`); #14 (`prepare_prerun_log VERWEIGERT …`, der neue Fall) bleibt **grün** — er testet nicht an dieser Anker-Zeile |
| `grep -n "green_prerun" test/mutate-driver.bats` | — | **ein** Aufrufer, mit bekanntem Modus `test` — der andere Kollateral-Treffer (`mutate.sh:462`, der Zweig für einen **unbekannten** `# verify:`-Modus) wird von keinem bestehenden Fall erreicht |
| `grep -n "das Vorlauf-Protokoll laege im Repo\|Rot A" …` über den lebenden Baum (nicht `docs/reviews/**`, nicht `done/`) | — | die falsche Rot-A-Beschreibung ("Rot gesehen, indem allein `>/dev/null` … wiederhergestellt wird → der stdout-Marker fehlt") steht **ausschließlich** in `docs/plan/planning/in-progress/slice-100-vorlauf-nennt-den-grund.md:215` (Plan-DoD) und in der Commit-Message von `241db77` (Git-Historie, immutabel); kein Treffer in `harness/tools/mutate.sh` oder `test/mutate-driver.bats` — die dortigen Kommentare (`:454`, `:196-198`) sagen nur "beide Ströme sind zu prüfen", ohne eine Isolationsaussage über eine konkrete Einzel-Mutation zu machen |
| `make gates` | vollständiger Lauf | **Exit 0** — d-check `374 Datei(en) geprüft, 0 Befund(e)`, bats `1..147`, keine `not ok`, comment-claims `40 Datei(en) geprueft, 0 Befund(e)`, span-check grün |
| `make shell-lint` | vollständiger Lauf | **Exit 0**; `grep -n "shellcheck disable" test/mutate-driver.bats harness/tools/mutate.sh` → kein Treffer (Exit 1 von grep), §3.2 sauber |
| `make test-bats` | vollständiger Lauf | **Exit 0**, `1..147`, letzte Zeile `ok 147 …`; `grep -c '^@test' test/mutate-driver.bats` → **21** (18 alt + 2 aus `241db77` + 1 neu) |
| Stehende Prüfungen (Diff-Umfang) | `git diff 71b6aba..c44519d --stat -- .github/workflows/ci.yml harness/tools/full-smoke.sh AGENTS.md harness/README.md docs/plan/ test/mutations/ harness/tools/mutate.sh` | **leer** — nur `test/mutate-driver.bats` geändert |
| `make mutate` | **nicht selbst gefahren** (Auftrag) | — | **nicht bestätigt**, siehe unten |

---

## Status der Runde-1-Findings

| Runde-1-Finding | Status | Beleg |
|---|---|---|
| **HIGH-1** — `prepare_prerun_log`s Ortsregel hat keinen lebenden Gegenbeweis | **aufgelöst** | Der neue Fall misst jetzt tatsächlich die **Schranke**, nicht nur die **Lage**: im echten `bats`-Container (mit `:ro`-Mount, exakt der Umgebung von `make test-bats`) reproduziert ein `mktemp`-Stub auf `$PATH` die Bedingung `dir` liegt unter `$REPO` — etwas, das `mktemp -d` ohne Stub im Container strukturell nie liefert. Unter dieser Bedingung fällt der Fall bei entferntem Guard **exakt an der Status-Assertion** (Status 0 statt erwartet ≠0), bei unverändertem Guard aber geändertem Wortlaut **exakt an der Marker-Assertion**. Beides selbst reproduziert, beide Male der vom Implementer benannte Mechanismus. Der Nachbar-Fall `isolation_path VERWEIGERT …` bleibt komplementär funktionsfähig (eigene Probe: mit `mktemp -d -p "$REPO"` an der Aufruf-Stelle fällt er, der neue Fall bleibt davon unberührt) — beide Fälle decken jetzt zusammen, was Runde 1 als Lücke benannt hatte. AGENTS.md §3.6s "Falsch"-Beispiel trifft nicht mehr zu. |
| **MEDIUM-1** — Rot A (DoD 1, `stdout`) belegt nicht, was er beansprucht | **aufgelöst als Code-/Verify-Sache; ein schmaler Rest-Punkt im Plan-Text bleibt, siehe LOW-1 unten** | Kein Code-Eingriff nötig — bestätigt: die falsche Rot-A-Beschreibung findet sich in genau **zwei** Stellen im Repo, beide außerhalb von Code/Konfiguration/Skript (§3.7-Geltungsbereich): der Commit-Message von `241db77` (Git-Historie, korrekt unangetastet) und dem Plan-DoD selbst (`slice-100-vorlauf-nennt-den-grund.md:215`, lebend, siehe LOW-1). Kein Treffer in `harness/tools/mutate.sh` oder `test/mutate-driver.bats`. Die eigentliche **Verify-Praxis** ist jetzt korrekt: der Implementer berichtet, `>/dev/null 2>"$log"` (isoliert stdout) und `>"$log" 2>/dev/null` (isoliert stderr) einzeln gefahren zu haben, mit je einer allein fallenden Assertion — das deckt sich mit der in Runde 1 selbst gefahrenen Kontrollprobe (dieselbe Tabelle, Zeile "Rein isolierte Stdout-Mutation"). Die ursprüngliche Kritik ("`>/dev/null` allein wiederhergestellt nimmt beide Ströme, nicht nur stdout") bleibt am **beschriebenen** Rot-A-Rezept richtig, ist aber jetzt gegen eine tatsächlich sauber geführte Verify-Praxis kein Substanz-Einwand mehr. |
| **MEDIUM-2** — Fall 72s Anker trifft jetzt drei statt eine Stelle; sein Kommentar ist falsch geworden | **bleibt Befund — Kategorie auf LOW herabgestuft, siehe Begründung** | Die neue Messung ist nachvollzogen und bestätigt: die Fall-72-Mutation färbt am echten HEAD **zwei** bats-Fälle rot (`isolation_path VERWEIGERT …` — eigener Zweck — und `der abgebrochene Gruen-Vorlauf zeigt stdout UND stderr …` — Kollateral an `mutate.sh:474`), nicht mehr "unbemerkt" wie in Runde 1 angenommen. Das **reduziert** das Reproduzierbarkeits-Risiko real: die konsequenzreichere der beiden Kollateral-Zeilen (474, kehrt `green_prerun`s Abbruch bei rotem Sensor tatsächlich um) hat jetzt einen — wenn auch zufälligen — lebenden Wächter. **Nicht** reduziert: `mutate.sh:462` (Zweig für unbekannten `# verify:`-Modus) bleibt von jedem bestehenden Fall unerreicht (`grep -n green_prerun test/mutate-driver.bats` → ein Aufrufer, mit bekanntem Modus), und der Kommentar "einmalig, geprueft" in `test/mutations/72-…sh` bleibt eine unverändert falsche Tatsachenbehauptung (`grep -c '^      return 1$' harness/tools/mutate.sh` → weiterhin **3**). Weil der schwerere der zwei ursprünglich benannten Risiko-Anteile jetzt eine reale Deckung hat, stufe ich den Befund von MEDIUM auf **LOW** herab: verbleibend ist im Kern eine **Doku-Drift** (falsche Zahl in einem Kommentar) plus eine schmalere, noch unbewachte Rest-Lücke an einer selten getroffenen Verzweigung — beides passt zum LOW-Anker des Reviewer-Skills, nicht mehr zum MEDIUM-Anker "Reproduzierbarkeitsrisiko" in seiner ursprünglichen Breite. |

---

## Punkt 2 — Trägt das Argument gegen das Streichen des Guards?

**Ja.** `grep -n '^mutate:' -A2 Makefile` zeigt `@bash harness/tools/mutate.sh` — kein `docker run`,
kein Mount. `make test-bats` dagegen startet `docker run --rm --network none -v "$(CURDIR)":/code:ro
-w /code $(BATS_IMAGE) test/`. Der `:ro`-Mount ist damit tatsächlich eine Eigenschaft **eines**
Aufrufers (des `test-bats`-Targets für den `bats`-Container), nicht des Treibers selbst: unter
`make mutate` läuft `mutate.sh` mit eigener `BASH_SOURCE`-Auflösung direkt auf dem Host-Checkout,
der beschreibbar ist. Ein `mktemp -d` ohne `-p`, dessen `$TMPDIR` (versehentlich oder durch
Fremdkonfiguration) unter `$REPO` zeigt, ist auf diesem Pfad kein hypothetischer, sondern ein
realer — wenn auch seltener — Fall; im `bats`-Container ist er dagegen zusätzlich durch den
Read-only-Mount strukturell ausgeschlossen (bereits in Runde 1 selbst gemessen: `mktemp -d -p
"$REPO"` scheitert dort an "Read-only file system"). Der Guard ist damit **kein toter Code** — er
ist ein Test, der nur in der `bats`-Sandbox strukturell nicht auf dem regulären Weg erreichbar ist,
und genau dafür liefert der neue Fall mit dem `mktemp`-Stub den Ersatzweg, der ihn dennoch prüfbar
macht.

---

## Neue Findings dieser Runde

### LOW-1 — Der Plan trägt die von MEDIUM-1 widerlegte Rot-A-Beschreibung unverändert weiter

- **Kategorie:** LOW (Doku-Drift; kein Code-/Konfig-/Skript-Artefakt, daher kein §3.7-Verstoß)
- **Quelle:** `LH-QA-02` (§Vorab-Messung eines DoD-Punkts) · Reviewer-Skill §LOW
- **Pfad:** `docs/plan/planning/in-progress/slice-100-vorlauf-nennt-den-grund.md:212-215` (DoD 1,
  "Rot A")
- **Befund:** Der Plan-Text sagt weiterhin wörtlich: *„Rot gesehen, indem allein `>/dev/null` an
  der Aufruf-Stelle wiederhergestellt wird → der `stdout`-Marker fehlt."* Das ist am Code weiterhin
  falsch (siehe MEDIUM-1-Status oben und Runde 1): weil `2>&1` das *aktuelle* Ziel von fd1
  dupliziert, verschwinden bei diesem Eingriff **beide** Marker, nicht nur der stdout-Marker; der
  Fall fällt an der ersten Assertion, weil sie zuerst geprüft wird, nicht weil nur ein Strom fehlt.
  Der Implementer hat die tatsächliche Verify-Praxis korrigiert (zwei sauber isolierte Eingriffe
  statt des im Plan beschriebenen), aber den Plan-Satz selbst nicht angefasst.
- **Verifizierbar:** ja — Kopie von `mutate.sh` mit `>"$log" 2>&1` → `>/dev/null 2>&1`, `green_prerun
  test` mit dem `make`-Stub aufrufen: Log-Datei fehlt, **beide** Marker fehlen (Runde-1-Probe,
  unverändert reproduzierbar).
- **Rollen-Verweis:** Planner-Artefakt — hier gemeldet, nicht geändert; nicht Bestandteil dieses
  Code-Diffs und daher nicht merge-blockierend.

---

## Negativbefunde (geprüft, ohne Befund)

- **§3.2 Inline-Suppression:** `grep -n "shellcheck disable" test/mutate-driver.bats
  harness/tools/mutate.sh` → kein Treffer.
- **Diff-Umfang:** `git diff 71b6aba..c44519d --stat -- .github/workflows/ci.yml
  harness/tools/full-smoke.sh AGENTS.md harness/README.md docs/plan/ test/mutations/
  harness/tools/mutate.sh` → leer. Nur `test/mutate-driver.bats` geändert, keine ADR berührt.
- **§3.7 in den zwei betroffenen Kommentaren (`harness/tools/mutate.sh:454` und
  `test/mutate-driver.bats:227-232`):** beide beschreiben präzise, was die neuen Zeilen tun und
  warum (Lage vs. Schranke, Status allein trägt die Aussage nicht) — keine überclaimte Zusage,
  deckt sich mit der empirischen Probe oben.
- **Rollen-Zuschnitt (§3.8):** `git show --stat c44519d` → genau eine Datei; Commit-Message beginnt
  mit dem Slice-Bezug, kein fremdes Rollen-Artefakt berührt.
- **Zahlen im Diff (MR-025-Nähe):** `21 @test`-Fälle, `374/0` d-check, `40/0` comment-claims,
  `1..147` bats — alle selbst nachgemessen, decken sich mit der Commit-Message.

## Nicht bestätigt (Auftrag: `make mutate` nicht selbst fahren)

Die Aussage *„make mutate Exit 0 mit 147 ok, 0 Befund(e) in 1046.30 s"* wird als
Implementer-Behauptung übernommen. Sie ist mit den hier gefahrenen Ersatzproben (Container-Lauf der
vollen `mutate-driver.bats`-Suite gegen eine Fall-72-mutierte Voll-Kopie, `make gates`/`shell-lint`/
`test-bats` je einzeln grün) **konsistent**, aber nicht durch einen eigenen `make mutate`-Lauf
bestätigt.

---

## Kategorie-Summary

| Kategorie | Runde 1 | Diese Runde |
|---|---|---|
| HIGH | 1 | 0 |
| MEDIUM | 2 | 0 |
| LOW | 0 | 1 (neu, nicht blockierend) |
| INFO | 0 | 0 |

## Verdikt

**Frei.** HIGH-1 ist an der Sache behoben — im echten `bats`-Container selbst reproduziert:
Guard entfernt fällt an der Status-Assertion, Wortlaut geändert fällt an der Marker-Assertion; der
Fall misst jetzt die Schranke, nicht mehr nur die Lage, die `mktemp -d` zufällig liefert. Das
Argument gegen das ersatzweise Streichen des Guards trägt (Punkt 2): `make mutate` läuft unstreitig
außerhalb von Docker auf dem schreibbaren Host-Checkout, der `:ro`-Mount ist ausschließlich eine
Eigenschaft des `test-bats`-Targets — der Guard ist kein toter Code. MEDIUM-1 ist als Code-/
Verify-Sache aufgelöst; die verbliebene Textungenauigkeit im Plan-DoD ist als neues LOW-1 erfasst,
nicht blockierend (Planner-Artefakt, außerhalb §3.7-Geltungsbereich). MEDIUM-2 bleibt ein Befund,
aber die nachvollzogene neue Messung (zwei statt einem `not ok` unter der Fall-72-Mutation)
verkleinert ihn glaubhaft — herabgestuft auf LOW.

`make gates` (Exit 0, d-check 374/0, bats 147/147, comment-claims 40/0, span-check grün),
`make shell-lint` (Exit 0, keine Suppression) und `make test-bats` (Exit 0, 21 Fälle in der
geänderten Datei) sind selbst gefahren und grün. `make mutate` ist nicht selbst gefahren
(Auftrag) und bleibt insoweit unbestätigte Implementer-Behauptung, ohne dass eine der hier
gefahrenen Ersatzproben ihr widerspricht.

Nichts steht dem Merge mehr entgegen.
