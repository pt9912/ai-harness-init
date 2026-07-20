# Re-Review — slice-022a: Fix-Commit `8a3355d` (Delta gegen `59c1d21`)

> `docs/reviews/**` ist doc-gate-exempt (MR-009 `exempt-paths`) — bare IDs/Pfade hier ok.
> Erstellt per `cp` aus `.harness/baseline/v3.5.0/templates/docs/reviews/review-report.template.md` (MR-008).

**Review-Art:** Code-Review (Diff gegen **Plan + ADR + Hard Rules/Konventionen**) —
**Re-Review des Deltas**, nachdem `docs/reviews/2026-07-20-slice-022a-review.md`
merge-blockierend war. **Nicht** gegen die DoD (Verifikations-Territorium, Modul 11).

**Gegenstand:** `git show 8a3355d` — der Fix-Commit zu slice-022a. Vorgänger-Stand
`59c1d21` (Ansatzpunkt des ersten Reviews); dazwischen `4e67305` (README/ADR-0005,
**nicht** Gegenstand). Nachfolgend `afbf3c1` (Plan-Commit slice-025, als Einordnung
zu (C) mitgeprüft). Arbeitskopie zu Beginn und Ende **clean**.

**Skill:** `.harness/skills/reviewer.md` v1.2.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
**Modell:** claude-opus-4-8[1m] · **Datum:** 2026-07-20

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan: `docs/plan/planning/in-progress/slice-022a-baseline-fetch.md` (§2 DoD, §6 Risiken).
- Vorheriger Review-Report: `docs/reviews/2026-07-20-slice-022a-review.md` (H1, M1–M4, L1–L5, I1–I4).
- Aktive ADRs: `ADR-0005` (Accepted), `ADR-0004`, `ADR-0003`. Kein superseded ADR referenziert.
- Berührte `LH-*`: `LH-FA-09`, `LH-FA-01`, `LH-FA-06`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`.
- Hard Rules: `AGENTS.md` §3.1–3.5. Konventionen: `MR-007` Setzungen 1–4, `MR-005`, `MR-008`, `MR-013`.
- Vorherige Findings am gleichen Modul: die Teil-Emit-Klasse (slice-002 I1 → slice-003 I1 →
  slice-004a L3 → slice-022a I1) und die Klasse „Doc-Kommentar beschreibt eine Semantik,
  die es im Code nicht gibt" (slice-022a M1) — beide unten wieder einschlägig.
- Neuer Slice: `docs/plan/planning/open/slice-025-bootstrap-preflight.md`.

**Ausgeführt (belegt, nicht nur nachgelesen):**

- `make test` — **66 bats ok / 0 not ok**, Go-Tests `cmd`/`emit`/`fetch` ok, Exit 0.
  (Der erste Lauf war auf `tail -60` gekürzt und zeigte nur die Go-Hälfte; wiederholt
  mit vollem TAP-Mitschnitt.)
- `make baseline-verify` — `v3.5.0 OK — 42 Dateien`, Exit 0.
- **H1-Angriff (`ln -s /etc/hostname <baum>/regelwerk/modul-99.md`) gegen BEIDE Skripte
  real ausgeführt** (Exit-Codes in §A/H1).
- **Mutations-Test der neuen bats-Suite:** acht Mutanten des emittierten Skripts gegen
  alle zehn Fälle (Zähne-Messung, Ergebnis in N3).
- `os.RemoveAll`-Fehlersemantik am Go-Quelltext des **gepinnten** Images verifiziert
  (`golang:1.26.4@sha256:792443b8…`, `src/os/removeall_at.go`) **und** als Teil-Löschung
  real vorgeführt.
- **Wegwerf-Sonde** (`internal/fetch/zz_reviewprobe_test.go`, im gepinnten Image gefahren,
  danach gelöscht — `git status` sauber) zur Messung, was
  `TestBaseline_TraversalEntriesEscapeNothing` offenlässt.
- Cross-Compile-Ziele geprüft (`Dockerfile`: kein `GOOS`/`GOARCH`) zur Bewertung der
  `filepath.IsLocal`-Unerreichbarkeits-Behauptung.
- **Nicht** gelaufen: `make gates` (Implementer belegt grün; `record-gates` kollidiert mit
  dem laufenden Stop-Hook-Nachweis) und `make smoke` (Host-Docker + Netz).

---

## A — Sind die als behoben deklarierten Findings zu?

Jedes einzeln und unabhängig geprüft; der Commit-Message wurde nicht geglaubt.

| ID | Urteil | Beleg |
|---|---|---|
| **H1** | **geschlossen** | Angriff gegen beide Skripte real ausgeführt |
| **M1** | **geschlossen** (erkauft mit N1) | `force` durchgereicht, `TestBaseline_ForceReplaces` |
| **M2** | **geschlossen** | `TestRun_BaselineUndVerifierLanden` hat Zähne |
| **M3** | **geschlossen**, Rest-Lücke als N3 | 10 bats-Fälle, real ausgeführt |
| **M4** | **teilweise** | Haupt-Beobachtung zu, Neben-Beobachtung fallengelassen (N2/N4) |
| **L2** | **geschlossen** | `os.Chmod` + Vorab-Datei jetzt `0644` |
| **L5** | **geschlossen** | `smoke.sh`-Kopf + `main.go`-Paket-Doc nachgezogen |
| **I2** | **geschlossen** | `BASELINE_SHA256` steht in `usage` |

**H1 — geschlossen.** Beide Skripte tragen jetzt `find . ! -type d`
(`internal/emit/templates/baseline-verify.sh:90`, `harness/tools/baseline-verify.sh:90`).
Real ausgeführt, in synthetischen Bäumen in exakt der von `writeSums` erzeugten
`SHA256SUMS`-Form:

- Emittiertes Skript, sauberer Baum → `OK — 3 Dateien`, **Exit 0**.
- Emittiertes Skript nach `ln -s /etc/hostname regelwerk/modul-99.md` →
  `FEHLER: Dateibestand … weicht von SHA256SUMS ab`, Diff-Zeile `> regelwerk/modul-99.md`,
  **Exit 1** (vorher Exit 0 „OK"), während `cat` weiterhin Fremdinhalt liefert.
- Dogfood-Zwilling gegen eine **Kopie der echten vendored Baseline dieses Repos**:
  unverändert → `v3.5.0 OK — 42 Dateien`, **Exit 0**; nach demselben `ln -s` → **Exit 1**.

Die zweite Achse dieses Fundorts (Symlink **ersetzt** eine gelistete Datei) fängt weiterhin
die Integritäts-Achse ab — im Mutations-Test bestätigt (Fall 6 stirbt mit dem
`sha256sum -c`-Mutanten, nicht mit dem Vollständigkeits-Mutanten).

**M1 — geschlossen.** `fetch.Baseline` hat den `force`-Parameter (`internal/fetch/baseline.go:97`),
`cmd/ai-harness-init/main.go:107` reicht `*force` durch, `placeBaseline` ersetzt statt hart
abzubrechen. Ohne `force` bleibt die Meldung „existiert bereits (`--force` zum Ueberschreiben)"
und ist jetzt **wahr**. `TestBaseline_ForceReplaces` (`internal/fetch/baseline_test.go:249`)
legt bewusst eine **nicht-leere** Vorab-Baseline an — genau der Fall, an dem ein blankes
`os.Rename` scheitert — und prüft, dass der Alt-Stand **ersetzt** und nicht gemischt wird.
Gegenprobe zur Kette: `fetch.Skeleton` überschreibt bedingungslos (`internal/fetch/fetch.go:98`,
`O_CREATE|O_TRUNC`) und bricht bei vorhandenem `.harness/skeleton/` nicht ab — ein
`--force`-Re-Run scheitert also an keinem der fünf Schritte mehr. Der Preis steht als **N1**.

**M2 — geschlossen, mit Zähnen.** `TestRun_BaselineUndVerifierLanden`
(`cmd/ai-harness-init/main_test.go:171`) statet vier Pfade im `targetDir`
(`SHA256SUMS`, `regelwerk/README.md`, `templates/AGENTS.template.md`,
`tools/harness/baseline-verify.sh`) plus das Ausführungs-Bit. Ein Entfernen von
`emit.BaselineVerify` bzw. `fetch.Baseline` aus `main.go` färbt ihn rot — die Lücke
„ein Entfernen der beiden Aufrufe färbte nichts rot" ist zu. Der Trick, den Lauf über
eine vorbereitete `.d-check.yml` netzlos an Exit 1 zu binden, hält.

**M3 — geschlossen; das Emittat wird jetzt ausgeführt.** `test/emitted-baseline-verify.bats`
kopiert das eingebettete Skript in ein **Zielrepo**-Layout (`tools/harness/`, nicht
`harness/tools/`) und fährt es zehnmal; als bats 14–23 im `make test`-Lauf grün gesehen.
Die Suite hat messbar Zähne (Mutations-Test unten) und tötet insbesondere genau den
H1-Fehler. Die Herabstufung von `TestBaselineVerify_BothAxes` zum ausdrücklich benannten
Grob-Wächter ist ehrlich: der Test war auf `find . -type f` gepinnt, also auf das Detail,
das den Fehler enthielt. Rest-Lücke → **N3**.

**M4 — teilweise geschlossen.** Der Backslash-Zweig (`baseline.go:237`) hat mit
`TestBaseline_EscapedPathRefused` (`baseline_test.go:302`) seinen Negativfall inklusive
`assertEmptyDir` — geschlossen. Die Behauptung, der `!filepath.IsLocal`-Zweig
(`baseline.go:173`) sei **konstruktionsbedingt unerreichbar**, habe ich unabhängig geprüft
und sie **hält für das gebaute Ziel**: `baselineEntry` gibt ausschließlich
`strings.Join(parts[i:], "/")` zurück, wobei `parts[i]` ein Marker-Segment
(`regelwerk`/`templates`) ist, also nie `.` oder `..`; `path.Clean` läuft davor, sodass `..`
nur noch **führend** überleben kann und damit nie im zurückgegebenen Suffix landet.
`unixIsLocal` prüft genau (a) `IsAbs`, (b) leer, (c) `..`-Präfix nach `Clean` — alle drei
sind ausgeschlossen. Einen ZIP-Eintrag, der den Zweig erreicht, habe ich **nicht** gefunden;
NUL-Bytes im Namen scheiden aus (die Unix-Variante prüft sie nicht), Windows-Reservednamen
wären ein Kandidat, aber der `Dockerfile` setzt weder `GOOS` noch `GOARCH` (linux-only Build).
**Die Behauptung des Implementers stimmt also.** Offen bleibt die **Neben-Beobachtung** aus
M4s `befund` („zwei ZIP-Einträge, die auf denselben Rel-Pfad abbilden") — kein Test deckt sie
ab, und die Commit-Message erwähnt sie weder als geschlossen noch als aufgeschoben (→ **N4**);
und der Test, der die Eigenschaft belegen soll, misst weniger, als sein Name behauptet (→ **N2**).

**L2 — geschlossen.** `os.Chmod(dst, 0o755)` nach dem `os.WriteFile`
(`internal/emit/baseline.go:47-52`), und `TestBaselineVerify_NoOverwriteWithoutForce` legt
die Vorab-Datei jetzt mit `0o644` an — ohne das `Chmod` fiele genau dieser Test. Die
Blindheit, die der Befund benannte, ist behoben.

**L5 — geschlossen.** `harness/tools/smoke.sh:11-12` nennt den zweiten Netz-Fetch
(Release-Asset), `cmd/ai-harness-init/main.go:1-13` beschreibt die fünf schreibenden Schritte
und benennt zusätzlich den offenen Punkt I1 samt Zuweisung. Prosa deckt sich mit `run()`.

**I2 — geschlossen.** `usage` (`cmd/ai-harness-init/main.go:39-44`) führt `BASELINE_SHA256`
zusammen mit `COURSE_TAG`/`DCHECK_IMAGE`/`DCHECK_DIGEST` unter „bewusster Opt-in-Override der
gepinnten Werte — LH-QA-02". Der Schalter steht damit nicht mehr nur im Code.

---

## Findings (B — neu eingeführt / neu sichtbar)

### MEDIUM

**N1 — `placeBaseline` mit `force` zerstört die zugesagte „bei jedem Fehler unverändert"-Invariante; der Doc-Kommentar behauptet sie weiter.**

- `kategorie`: MEDIUM
- `quelle`: `LH-QA-01` (Kein-Teil-Emit-AC, Slice-Plan §2) · `MR-007` Setzung 3 ·
  Reviewer-Skill §MEDIUM (Reproduzierbarkeits-/Robustheitsrisiko, `LH-QA-02`) ·
  Wiederholung der Klasse aus slice-022a M1
- `pfad`: `internal/fetch/baseline.go:151-154` (`os.RemoveAll(final)`) · `:158` (`os.Rename`) ·
  `:130` (`defer os.RemoveAll(tmp)`) · `:94-96` und `:13-15` (die Zusagen)
- `befund`: Mit `force` löscht `placeBaseline` das vorhandene `<tag>`-Verzeichnis **vor** dem
  Rename; scheitert danach irgendetwas, ist die alte Baseline weg und die neue nicht da.
  Der Fall ist nicht nur ein Race: `os.RemoveAll` akkumuliert Fehler und **löscht Geschwister
  weiter** (`removeAllFrom` in `src/os/removeall_at.go` des gepinnten Images zählt `numErr`
  hoch und bricht die Schleife nicht ab), sodass ein einziger nicht entfernbarer Eintrag den
  Rest des Baums trotzdem vernichtet und dann einen Fehler liefert — real vorgeführt: von
  `regelwerk/{modul-01..03}.md`, `templates/slice.template.md` und `SHA256SUMS` blieb nach dem
  Fehlschlag nur der gesperrte Teilbaum übrig. Auf demselben Fehlerpfad räumt zusätzlich
  `defer os.RemoveAll(tmp)` das frisch geholte Ersatz-Bundle weg, sodass das Zielrepo mit
  einer zerlegten Baseline und ohne neue zurückbleibt (`baseline-verify` dort rot). Der
  Doc-Kommentar auf `Baseline` sagt weiterhin „Bei jedem Fehler bleibt destDir unveraendert
  (Temp-Verzeichnis + finales Rename)", und der Datei-Kopf führt „Kein Teil-Emit (LH-QA-01) …
  Bricht irgendein Schritt ab, bleibt das Ziel unberuehrt statt halb befuellt" als Setzung —
  beide gelten mit `force` nicht mehr. Vor dem Fix existierte das Fenster nicht (harter
  Abbruch, nichts angefasst). Kein Test beobachtet den `force`-**Fehler**pfad;
  `TestBaseline_ForceReplaces` deckt nur den Erfolg.
- `verifizierbar`: ja — ein Fall mit einem nicht entfernbaren Kind unter `final` (Modus `0500`
  auf einem Zwischenverzeichnis) zeigt Fehler **und** zerlegte Alt-Baseline; heute existiert keiner.

**N2 — `TestBaseline_TraversalEntriesEscapeNothing` misst weniger, als sein Name zusagt: seine eigene Fixture landet zur Hälfte im Baum, unbeobachtet.**

- `kategorie`: MEDIUM
- `quelle`: Reviewer-Skill §MEDIUM (Spec-Treue-Lücke einer Messmethode) · §Kontext-Eskalation
  (Sicherheitspfad) · `LH-QA-02`
- `pfad`: `internal/fetch/baseline_test.go:275-296` · `internal/fetch/baseline.go:201-211`
  (`baselineEntry`)
- `befund`: Der Test behauptet die Eigenschaft „Traversal-Einträge brechen nirgends aus" und
  prüft dafür drei Pfade **außerhalb** des Ziels auf Abwesenheit. Zwei seiner fünf
  Fixture-Einträge landen aber **innerhalb**: gemessen (Wegwerf-Sonde im gepinnten Image)
  enthält der erzeugte Baum `regelwerk/evil2.md` (aus `../regelwerk/evil2.md`) und
  `regelwerk/evil3.md` (aus `/regelwerk/evil3.md`), und die selbst erzeugte `SHA256SUMS`
  listet beide — der Verifier meldete diesen Baum anschließend als „OK". Ursache ist die
  Marker-Suche in `baselineEntry`, die **jedes** Segment `regelwerk`/`templates` in
  **beliebiger** Tiefe als Wurzel akzeptiert; der Doc-Kommentar begründet das mit „ein
  kuenftiger Top-Level-Prefix aendert den Extrakt damit nicht" und benennt die Kehrseite nicht:
  ein **zweiter**, sachfremder `regelwerk/`- oder `templates/`-Zweig im Asset (bei einem
  Kurs-Repo-Asset kein exotischer Fall) wird still in die vendored Baseline gemischt und
  danach von deren eigenen Prüfsummen gedeckt. Keine Zusicherung im Test unterscheidet
  „wurde verworfen" von „wurde umgeschrieben und aufgenommen"; die Sonde belegt, dass es
  Letzteres ist. Der sha256-Pin begrenzt den Fall auf eine bewusste Re-Baseline — er
  verhindert ihn nicht.
- `verifizierbar`: ja — dieselbe Fixture plus eine Zusicherung auf den Ist-Bestand des Baums
  bzw. auf die Zeilenzahl von `SHA256SUMS` (gemessen 4 statt der erwarteten 2) wird rot.

### LOW

**N3 — Zwei der zehn neuen bats-Fälle sind zahnlos, und die Escape-Vorbedingung des Emittats hat gar keinen Fall.**

- `kategorie`: LOW
- `quelle`: Maintainability (Messmethode) · `LH-QA-01` · Reviewer-Skill §LOW
- `pfad`: `test/emitted-baseline-verify.bats:79-84` (Fall „fehlende SHA256SUMS"), `:92-97`
  (Fall „keine Baseline") · fehlend: ein Fall zu
  `internal/emit/templates/baseline-verify.sh:69-72`
- `befund`: Im Mutations-Test (acht Mutanten × zehn Fälle) töten die Fälle 4/5 den
  Vollständigkeits-Mutanten, 2/6 den Integritäts-Mutanten und 8 den Ein-Tag-Mutanten — die
  Suite hat also überwiegend Zähne, und Fall 5 tötet exakt die H1-Regression
  (`! -type d` → `-type f`). Drei Mutanten überleben jedoch **alle zehn** Fälle:
  (a) entfernte `SHA256SUMS`-Existenzprüfung — Fall 7 bleibt grün, weil das Skript stattdessen
  über `sha256sum -c` mit der irreführenden Meldung „geaenderte oder fehlende Datei" plus einem
  durchgereichten `grep: SHA256SUMS: Datei … nicht gefunden` auf stderr ausgeht und der
  `grep -q 'SHA256SUMS'` des Tests auf diese Ersatzmeldung passt; (b) entfernte
  „keine Baseline"-Prüfung — Fall 9 bleibt grün, weil `set -u` bei `dirs[0]` greift
  (`dirs[0] ist nicht gesetzt`), also ein bash-Interpreterfehler statt der erklärenden Meldung;
  (c) entfernte Escape-Vorbedingung (Schritt 0) — kein einziger Fall der Suite fasst sie an,
  während die Dogfood-Suite (`test/baseline-verify.bats:94-102`) genau dafür einen Fall führt.
  Damit ist die Achse, die `TestBaseline_EscapedPathRefused` auf der Produzentenseite bewacht,
  auf der Konsumentenseite des **Emittats** unbewacht.
- `verifizierbar`: ja — die drei Mutanten sind reproduzierbar; heute bleiben alle zehn Fälle grün.

**N4 — M4s Neben-Beobachtung (kollidierende Rel-Pfade) ist weder geschlossen noch triagiert.**

- `kategorie`: LOW
- `quelle`: Reviewer-Skill §Anti-Pattern (ein Befund verschwindet nicht durch Nichterwähnen) ·
  `LH-QA-02`
- `pfad`: `internal/fetch/baseline.go:180` (`writeFile`, `O_CREATE|O_TRUNC`) ·
  `internal/fetch/baseline_test.go` (fünf `fixtureZip`-Aufrufe, keiner mit kollidierendem Rel-Pfad)
- `befund`: Der erste Review hielt unter M4 zusätzlich fest, dass zwei ZIP-Einträge, die nach
  `baselineEntry` auf denselben Rel-Pfad abbilden, sich still überschreiben. Der Fix ergänzt
  zwei Fälle (Traversal, Backslash), aber keinen dafür; die Commit-Message führt M4 als
  vollständig zu und nennt die Beobachtung in keiner Zeile — auch nicht in der „Offen"-Liste.
  Sie ist damit aus dem Protokoll gefallen, obwohl N2 zeigt, dass die Marker-Suche mehrere
  Einträge auf denselben Zielbaum abbilden **kann**.
- `verifizierbar`: ja — eine Fixture mit `lab/regelwerk/x.md` und `docs/regelwerk/x.md`
  (verschiedene ZIP-Namen, gleicher Rel-Pfad); heute existiert keine.

**N6 — Die Vertagungs-Begründung für L1 stimmt nicht mit dem Code überein.**

- `kategorie`: LOW
- `quelle`: `MR-007` Setzung 2 · Maintainability (Messmethode) · Reviewer-Skill §LOW
- `pfad`: `internal/fetch/baseline_test.go:130-152` · `test/emitted-baseline-verify.bats:29-32` ·
  `test/baseline-verify.bats:22-25`
- `befund`: Die Commit-Message schließt L1 nicht, begründet die Vertagung aber mit „die neue
  bats-Suite deckt die Form jetzt ausfuehrend ab" — eine Abdeckung, die es nicht gibt: beide
  bats-Suiten bauen ihre `SHA256SUMS` in `setup()` selbst per `xargs sha256sum` und prüfen
  danach **diese hand­gebaute** Datei. Ein Grep über alle `*.go`/`*.bats` findet keine Stelle,
  die die von `writeSums` (`internal/fetch/baseline.go:216-259`) **erzeugte** Datei an ein
  echtes `sha256sum -c` übergibt. Die GNU-Format-Kopplung zwischen Produzent und Coreutils hat
  damit weiterhin keinen ausführenden Wächter, und der Befund hat außerdem keinen Folge-Slice
  (slice-025 deckt L3/L4/I1).
- `verifizierbar`: ja — ein Fall, der `fetch.Baseline` laufen lässt und danach im Ergebnisbaum
  `sha256sum -c SHA256SUMS` aufruft, wäre der fehlende Wächter.

### INFO

**N5 — Fixture-Divergenz zwischen den beiden bats-Suiten.**

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `test/emitted-baseline-verify.bats:31` (`find . ! -type d`) ·
  `test/baseline-verify.bats:24` (`find . -type f`)
- `befund`: Die neue Suite baut ihre `SHA256SUMS` mit `find . ! -type d`, die ältere
  Dogfood-Suite unverändert mit `find . -type f`, obwohl beide dieselbe Produzenten-Form
  nachbilden sollen. Heute folgenlos (beide `setup()` legen ausschließlich reguläre Dateien
  an), aber die beiden Fixtures behaupten die Form nun unterschiedlich.
- `verifizierbar`: nein — kein Gate vergleicht die beiden `setup()`-Blöcke.

---

## C — Sind die nicht behobenen Findings korrekt eingeordnet?

**Trägt — mit einer Ausnahme (L1).**

- **L3 / L4 / I1 → `slice-025-bootstrap-preflight.md`: trägt, und zwar gut.** Der Slice
  benennt die Klasse bei ihrer vierten Wiederholung explizit als Muster („Ein viertes
  Weiterreichen wäre kein Plan, sondern ein Muster"), hängt L3 und L4 als eigene DoD-Punkte
  an (§2), verlangt für den Test „rot gesehen" und weigert sich bewusst, die Entwurfsfrage
  (Pre-Flight vs. Staging→Commit) vorzuentscheiden. Das ist die Antwort, die der
  Steering-Eintrag aus slice-004a verlangt hat. Der Trigger (`slice-022b` in `done/`, **vor**
  slice-023 und slice-004b) ist die richtige Reihenfolge — jeder weitere Slice hängt sonst
  einen weiteren ungeschützten Schritt an. **Kein Einwand.** Anmerkung ohne Finding-Status:
  **N1 gehört fachlich in denselben Codepfad** wie L3 und sollte dort nicht untergehen, ist
  aber nach heutiger Lage schwerer als L3 (dort: benignes Restverzeichnis; hier: Verlust des
  Alt-Stands).
- **I3 (Herkunftsklassen-Mischung) als benannte Spec-Lücke in die Closure-Notiz: trägt.**
  Es ist eine Dokumentationsfrage ohne Gate, INFO war richtig, und „in der Closure-Notiz
  benennen" ist die passende Ablage. Ob sie dort landet, prüft der **Verifier** — §7 des
  Slice-Plans ist heute erwartungsgemäß leer.
- **I4 (kein Make-Target) als Regelerfüllung ohne Aktion: trägt.** Hard Rule 3.1 verbietet
  gerade das Behaupten eines Gates über einem noch nicht emittierten `Makefile`; die
  Nicht-Aktion **ist** die Konformität. Der Punkt bleibt als Abnahme-Frage beim Verifier.
- **L1: falsch eingeordnet — aber nicht vergessen.** Entgegen der Annahme im Auftrag ist L1
  in der Commit-Message durchaus erwähnt (in der „Offen"-Liste); nicht das Erwähnen fehlt,
  sondern die Begründung stimmt nicht. Details und Beleg als **N6**. L1 bleibt LOW und damit
  nicht blockierend; blockierend ist die Begründung ebenfalls nicht — sie ist nur unrichtig
  und lässt den Befund ohne Träger zurück.

---

## Negativbefunde (geprüft, ohne Befund)

- **`find . ! -type d` gegen die reale vendored Baseline dieses Repos:** `make baseline-verify`
  → `v3.5.0 OK — 42 Dateien`, Exit 0; zusätzlich gegen eine Kopie des Baums separat ausgeführt,
  gleiches Ergebnis. Die Semantik-Änderung an einem `gates`-Skript färbt dieses Repo **nicht** rot.
- **Falsch-positiv-Suche für `! -type d`:** durchgegangen für Symlink-auf-Datei,
  Symlink-auf-Verzeichnis (find läuft ohne `-L`, klassifiziert also als `l`, nicht als `d`, und
  steigt nicht ab → laut, korrekt), Hardlink (bleibt `-type f`), FIFO/Socket, echtes
  Unterverzeichnis mit Inhalt. Kein Fall gefunden, in dem ein von `unpackTrees` erzeugter Baum
  neu rot würde: `unpackTrees` ruft ausschließlich `writeFile` (`internal/fetch/fetch.go:129-142`)
  und kann keine Nicht-Regulär-Datei erzeugen; git kann in einem `.harness/baseline/`-Baum nur
  reguläre Dateien und Symlinks tragen. Restlücke unverändert und **nicht** neu: ein eingelegtes
  **leeres** Verzeichnis sehen beide Achsen nicht (inhaltslos, kein Fremdinhalt).
- **Symmetrie Produzent/Konsument (`writeSums` `!d.IsDir()` ↔ `find . ! -type d`):**
  klassifikatorisch deckungsgleich — `filepath.WalkDir` baut seine `DirEntry` aus `ReadDir`
  (lstat-basiert), folgt Symlinks also nicht und meldet auch einen Symlink-auf-Verzeichnis als
  Nicht-Verzeichnis, genau wie `find` ohne `-L`. FIFO/Socket/Gerätedatei sind auf der
  Produzentenseite unerreichbar (frisches `os.MkdirTemp`, nur `writeFile`); erreichten sie sie
  doch, wäre `os.ReadFile` das laute Problem, nicht die Klassifikation. Hardlinks sind auf
  beiden Seiten reguläre Dateien. Die verbleibende Asymmetrie zeigt in die **fail-closed**-Richtung
  (Konsument meldet mehr → rot).
- **`!filepath.IsLocal`-Unerreichbarkeit:** unabhängig nachvollzogen und **bestätigt** (Herleitung
  in §A/M4); kein ZIP-Eintrag gefunden, der den Zweig auf dem gebauten Ziel erreicht. Dass der
  Zweig als zweites Netz stehen bleibt und der Test die Eigenschaft statt der Zweigabdeckung
  misst, ist die ehrliche Wahl — N2 betrifft, **was** die Eigenschaft prüft, nicht **dass** sie
  statt des Zweigs geprüft wird.
- **Semantische Äquivalenz emittiert ↔ Dogfood nach dem Fix:** beide `baseline-verify.sh` tragen
  dieselbe geänderte Zeile 90 und dieselbe Kommentar-Erweiterung; die Divergenz bleibt auf die
  Kopf-Prosa und den impliziten Basispfad beschränkt (unverändert gegenüber dem ersten Review).
  In beiden Layouts real ausgeführt, verhaltensgleich in allen geprüften Fällen.
- **`--force`-Kette über alle fünf Schritte:** `fetch.Skeleton` (überschreibt bedingungslos),
  `fetch.Baseline` (neu: `force`), `emit.BaselineVerify`, `emit.DocGate`, `emit.Templates`
  (alle bereits `force`) — kein Schritt bricht bei einem `--force`-Re-Run mehr an einem
  vorhandenen Artefakt ab. Die M1-Klasse ist über die Kette hinweg geschlossen.
- **Hard Rule 3.1:** `make gates`, die Gate-Tabelle in `AGENTS.md` §4 und `harness/README.md`
  sind unberührt; kein neuer Gate-Name. Der `shell-lint`-Glob deckt `internal/emit/templates/*.sh`
  weiterhin ab (`Makefile:73-74`), also auch das geänderte Emittat.
- **Hard Rule 3.2:** `grep -n "nolint\|shellcheck disable"` über alle geänderten Quelldateien →
  keine Treffer; `.golangci.yml` nicht im Diff. Die `'^[\]'`-Regex bleibt SC1003-frei.
- **Hard Rule 3.3:** `8a3355d` enthält keinen Rename; der Plan-Commit `afbf3c1` (slice-025) ist
  ein separater Commit und legt eine neue Datei an, kein `git mv` mit Inhaltsänderung.
- **Hard Rule 3.4/3.5:** kein ADR verändert; keine Gate-Schwelle gesenkt, kein Modul deaktiviert.
  `find . -type f` → `find . ! -type d` ist eine **Verschärfung**, keine Lockerung.
- **`MR-007` Setzung 1:** unberührt — der sha256 steht weiterhin vor `zip.NewReader`
  (`baseline.go:112-119`), der Pin-Bruch bleibt via `*SHA256Mismatch` unterscheidbar.
- **`MR-007` Setzung 2 (`SHA256SUMS`-Form):** `writeSums` unverändert außer dem
  Backslash-Abbruch, der schon vorher da war; Sortierachse, Selbstausschluss und Relativpfade
  unangetastet (fehlender ausführender Wächter: N6).
- **`MR-007` Setzung 4:** die Ein-Tag-Politik hält in beiden Skripten; im Mutations-Test stirbt
  der entsprechende Mutant an Fall 8.
- **`MR-008`:** dieser Report entstand per `cp` aus dem vendored Template; der Diff legt keine
  Kopie eines Kurs-Templates im Repo an.
- **Additivität (Plan §1/§2):** `internal/emit/skel/**` erscheint nicht im Diff;
  `test/skel-drift.bats` unberührt und als bats 62–64 grün.
- **`LH-QA-03`:** keine neue Abhängigkeit — `os.Chmod` ist stdlib, das Emittat bleibt bei
  bash + coreutils, der `netzlos`-Fall (bats 23) hält.
- **Regressionsfreiheit des Gesamt-Stands:** `make test` 66/66 (vorher 55), `make baseline-verify`
  Exit 0. Kein zuvor grüner Fall ist rot geworden.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 3 |
| INFO | 1 |

- **MEDIUM:** N1 `force`-Ersetzung zerstört die „unverändert"-Invariante · N2 Traversal-Test
  misst weniger als sein Name
- **LOW:** N3 zwei zahnlose bats-Fälle + fehlender Escape-Fall · N4 M4-Neben-Beobachtung
  fallengelassen · N6 unzutreffende Vertagungs-Begründung für L1
- **INFO:** N5 Fixture-Divergenz der beiden bats-Suiten

**Status der alten Findings:** H1 · M1 · M2 · M3 · L2 · L5 · I2 **geschlossen**;
M4 **teilweise**; L1 offen mit unzutreffender Begründung (N6); L3 · L4 · I1 sauber nach
slice-025 überführt; I3 · I4 korrekt eingeordnet.

## Verdikt

**Merge-blockierend: JA** — getragen von **N1** und **N2** (Reviewer-Skill: „HIGH und MEDIUM
blockieren typischerweise").

Der Fix leistet, was er zusagt, wo es am meisten zählt: **H1 ist real geschlossen**, in beiden
Skripten, und die Testlücke, die H1 durchrutschen ließ, ist mit einer ausführenden bats-Suite
geschlossen, die im Mutations-Test messbar Zähne hat — sie tötet exakt die Regression, um die es
ging. Das ist keine kosmetische Antwort auf den ersten Review, sondern die richtige.

**N1** ist der Grund, warum der Stand trotzdem nicht durchgeht, und er ist die **zweite
Wiederholung derselben Klasse innerhalb desselben Slice**: M1 wurde gemeldet, weil ein
Doc-Kommentar eine Semantik behauptete, die es im Code nicht gab. Der Fix für M1 erzeugt
denselben Bruch in die andere Richtung — der Code kann jetzt etwas, das die beiden Zusagen im
selben File („bei jedem Fehler bleibt destDir unveraendert", „Kein Teil-Emit (LH-QA-01)")
ausschließen. Der Implementer hat das Fenster selbst als unsicher markiert; das ist ehrlich,
ersetzt aber die Auflösung nicht. Zur gestellten Frage: **ja, das Risiko ist echt und nicht bloß
ein Race** — `os.RemoveAll` löscht bei einem nicht entfernbaren Kind die Geschwister trotzdem
weiter (am Quelltext des gepinnten Images belegt, als Teil-Löschung vorgeführt), und
`defer os.RemoveAll(tmp)` räumt auf demselben Pfad den Ersatz mit weg. Und **ja,
rename-old-aside → rename-new-in → remove-old ist die richtige Form**: beide Schritte sind dann
atomar, ein Fehlschlag am zweiten ist rückrollbar, und nur der dritte darf folgenlos scheitern.
Zwei Nebenbedingungen gehören in die Übergabe, nicht ins Finding: das Beiseite-Verzeichnis muss
**punkt-präfigiert** sein (wie das bestehende `.baseline-*`), sonst sieht der `"$base"/*/`-Glob
zwei `<tag>`-Verzeichnisse und `MR-007` Setzung 4 schlägt an; und ein Abbruch zwischen Schritt 1
und 3 hinterlässt einen Rest, der zu L3 gehört — womit der Fix fachlich zu **slice-025** wandert,
wo L3/L4/I1 ohnehin liegen.

**N2** ist die schwächere der beiden Blockaden und hängt nicht daran, dass der Fix falsch wäre —
die Unerreichbarkeits-Behauptung des Implementers **stimmt** (unabhängig hergeleitet und
bestätigt, inklusive der NUL- und Windows-Gegenproben). Das Problem ist die Messmethode: der neue
Test trägt eine Fixture, deren Hälfte sichtbar im Baum landet und in `SHA256SUMS` aufgenommen
wird, und schaut daran vorbei. Damit bleibt genau die Frage unbeantwortet, für die M4 den Test
verlangt hat — ob der Extrakt Fremdes verwirft oder umschreibt und übernimmt. Gemessen: er
übernimmt. Der sha256-Pin begrenzt das auf eine bewusste Re-Baseline, deshalb MEDIUM und nicht höher.

**M4 ist nur teilweise zu.** Die Neben-Beobachtung zu kollidierenden Rel-Pfaden (N4) ist nicht
gelöst und in der Commit-Message nicht einmal als offen geführt — ein Befund verschwindet nicht
durch Nichterwähnen. Zusammen mit **N6** (die Vertagungs-Begründung für L1 beschreibt eine
Abdeckung, die es nicht gibt) ergibt sich ein kleines, aber wiederkehrendes Muster in der
Berichterstattung dieses Slice: die **Beschreibung** der Abdeckung greift zweimal weiter als die
Abdeckung selbst. Genau diese Klasse war H1. Sie ist hier nur noch in Kommentaren und Commit-Prosa
zu finden, nicht mehr im Gate-Skript — ein deutlicher Fortschritt, aber dieselbe Klasse, und damit
nach Reviewer-Skill §Kontext-Eskalation ein Steering-Signal für die Closure-Notiz.

Die Einordnung der **nicht** behobenen Findings trägt (siehe §C): slice-025 ist der richtige
Träger für L3/L4/I1 und beantwortet den vierfach wiederholten Steering-Eintrag endlich als
eigener Slice statt als Anhängsel; I3 und I4 sind korrekt eingeordnet. Einzige Ausnahme ist
**L1** — offen, mit unzutreffender Begründung und ohne Träger, aber weiterhin LOW.

Keine Hard-Rule-Verletzung, kein halluziniertes Gate, keine Gate-Lockerung (die Änderung an
`baseline-verify` ist eine Verschärfung und lässt die reale Baseline dieses Repos grün), kein
Verstoß gegen `ADR-0005`/`ADR-0004`/`MR-005`/`MR-007`/`MR-008`.

**Übergabe:** Findings gehen an die Implementation, N1 zuerst — mit der Option, N1 zusammen mit
L3 in **slice-025** zu lösen statt punktuell hier, sofern slice-022a bis dahin nicht gemergt wird;
wird er vorher gemergt, muss N1 vorher zu sein, denn er ist heute ein Datenverlust-Pfad, den es
vor diesem Commit nicht gab. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11, anderer Eingabe-Kontext); I3 und I4 sind dort weiterhin als
Abnahme-Fragen hinterlegt.
