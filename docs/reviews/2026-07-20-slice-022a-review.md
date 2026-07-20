# Code-Review — slice-022a: Baseline-Fetch ins Zielrepo (`59c1d21`)

> `docs/reviews/**` ist doc-gate-exempt (MR-009 `exempt-paths`) — bare IDs/Pfade hier ok.

## Kopf-Metadaten

- **Review-Art:** Code-Review (Diff gegen **Plan + ADR + Hard Rules/Konventionen**).
  **Nicht** gegen die DoD — das ist Verifikations-Territorium (Modul 11, getrennter Kontext).
- **Gegenstand:** slice-022a — `internal/fetch` holt das sha256-gepinnte
  `lab-regelwerk.zip`, legt Regelwerk + Templates als vendored Baseline des Zielrepos ab
  (`+ SHA256SUMS`) und emittiert einen tool-generierten `baseline-verify`.
- **Diff/Commit-Range:** `git show 59c1d21` (ein Content-Commit). Vorangehend `292972f`
  (reiner Move `open/`→`in-progress/`). HEAD = `59c1d21`, Arbeitskopie clean.
- **Betroffene Dateien:** neu `internal/fetch/baseline.go`, `internal/fetch/baseline_test.go`,
  `internal/emit/baseline.go`, `internal/emit/baseline_test.go`,
  `internal/emit/templates/baseline-verify.sh`; geändert `cmd/ai-harness-init/main.go`,
  `cmd/ai-harness-init/main_test.go`, `Makefile`.
- **Rolle:** unabhängiger Reviewer (Modul 10), frischer Kontext — Code nicht selbst geschrieben.
- **Skill:** `.harness/skills/reviewer.md` v1.2.0 · **Modell:** claude-opus-4-8[1m] ·
  **Datum:** 2026-07-20 <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
- **Pflicht-Kontext (v3.5.0, fünf Punkte + Repo-Ergänzung):**
  - Diff/Commit-Range: `59c1d21` (oben).
  - Berührte `LH-*`: `LH-FA-09` (Regelwerk emittieren), `LH-FA-01` (Boundary-AC `--force`),
    `LH-FA-06` (emittiertes `tools/harness/`), `LH-QA-01`, `LH-QA-02`, `LH-QA-03`.
  - Aktive ADRs: `ADR-0005` (Accepted, im Commit referenziert), `ADR-0004` (Picker-Stanz,
    als Scope-Grenze), `ADR-0003` (Docker-only). Kein superseded ADR referenziert.
  - Hard Rules: `AGENTS.md` §3.1–3.5.
  - Konventionen: `MR-005` (Layout, Emissions-Abgrenzung), `MR-007` (Setzungen 1–4),
    `MR-008`, `MR-010`/`MR-013` (Pin-Kopplungs-Muster).
  - Vorherige Findings am gleichen Modul (Emit/Bootstrap-Kette): slice-002 I1 → slice-003 I1 →
    slice-004a L3 (**Teil-Emit-Klasse**, dort bereits als Steering-Signal notiert);
    slice-004a M2 (main-Verdrahtung untested); slice-004a I1 (`--force` im Fetch-Pfad ignoriert);
    slice-004a M1 (Pin-/Tag-Drift → Kopplungstest).
  - Slice-Plan: `docs/plan/planning/in-progress/slice-022a-baseline-fetch.md`.
- **Ausgeführt (belegt, nicht nur nachgelesen):**
  - Emittiertes `internal/emit/templates/baseline-verify.sh` in einem synthetischen Zielrepo
    (`tools/harness/` + `.harness/baseline/v3.5.0/{regelwerk,templates}` + handgebautem
    SHA256SUMS in exakt der von `writeSums` erzeugten Form) **real ausgeführt**, sechs Fälle:
    sauberer Baum → Exit 0; geänderte Datei → Exit 1; gelöschte Datei → Exit 1; eingelegte
    **reguläre** Datei → Exit 1; **eingelegter Symlink → Exit 0 („OK")**; zwei `<tag>`-
    Verzeichnisse → Exit 1.
  - `os.Rename`-Semantik über ein **leeres** Zielverzeichnis (POSIX-`rename`) reproduziert:
    ersetzt es stillschweigend.
  - Bash-Glob-Verhalten `"$base"/*/` gegen ein `.baseline-*`-Restverzeichnis reproduziert:
    Punkt-Präfix wird nicht gematcht.
  - `grep` über die fünf neuen/geänderten Quelldateien nach `//nolint` / `# shellcheck disable`.
  - **Nicht** gelaufen: `make gates` (Implementer belegt grün; `record-gates` würde mit dem
    laufenden Stop-Hook-Nachweis kollidieren) und `make smoke` (Host-Docker + Netz).

---

## Findings

### HIGH

**H1 — Das emittierte `baseline-verify` meldet einen eingelegten Symlink als „OK": stilles Grün im Gate-Skript.**

- `kategorie`: HIGH
- `quelle`: Reviewer-Skill §HIGH („Stilles-Grün-Pfad in einem Gate oder Gate-Skript
  (Harness-Lüge)") · `LH-QA-01` · `MR-007` Setzung 3 · Slice-Plan §2 (Prüfsummen-AC:
  „diese Lücke wird **nicht** ins Ziel vererbt")
- `pfad`: `internal/emit/templates/baseline-verify.sh:84` (`find . -type f`), im Zusammenspiel
  mit `internal/fetch/baseline.go:213-240` (`writeSums` via `filepath.WalkDir`/`!d.IsDir()`)
- `befund`: Der Vollständigkeits-Check listet den Ist-Bestand mit `find . -type f` und sieht
  damit nur **reguläre** Dateien; ein zusätzlich in den Baum gelegter **Symlink** (oder jede
  andere Nicht-Regulär-Datei) ist weder in `SHA256SUMS` gelistet noch im Ist-Bestand sichtbar,
  weshalb beide Achsen grün bleiben. Real vorgeführt: `ln -s /etc/hostname
  regelwerk/modul-99.md` im verifizierten Baum → `baseline-verify: v3.5.0 OK — 2 Dateien
  (Integritaet + Vollstaendigkeit, netzlos)`, Exit 0, während `cat regelwerk/modul-99.md`
  Fremdinhalt liefert. Damit erbt das Zielrepo genau die Klasse „eingelegte Datei bleibt grün",
  die `MR-007` Setzung 3 als überdehnte Gate-Behauptung benennt und die die Commit-Message
  als nicht vererbt ausweist. Die Produzenten-/Konsumenten-Achsen sind asymmetrisch:
  `writeSums` (`!d.IsDir()`) **würde** einen Symlink listen, `find -type f` findet ihn nie.
  Der Dogfood-Zwilling `harness/tools/baseline-verify.sh:84` trägt dieselbe Zeile (Befund dort
  vorbestehend, hier nicht Gegenstand).
- `verifizierbar`: ja — reproduzierbar durch Ausführen des emittierten Skripts nach einem
  `ln -s` im Baum (Exit 0 statt 1); im Gate-Lauf sichtbar über `make baseline-verify` gegen
  einen so präparierten Baum.

### MEDIUM

**M1 — `fetch.Baseline` kennt kein `--force`; die Fehlermeldung nennt es dennoch als Ausweg.**

- `kategorie`: MEDIUM
- `quelle`: `LH-FA-01` Boundary-AC („kein Überschreiben ohne `--force`") · Reviewer-Skill
  §MEDIUM (Abdeckungslücke einer Akzeptanzanforderung)
- `pfad`: `internal/fetch/baseline.go:97` (Signatur ohne `force`), `:145-151`
  (`placeBaseline`), `cmd/ai-harness-init/main.go:93`
- `befund`: `run()` reicht `*force` an `emit.BaselineVerify`, `emit.DocGate` und
  `emit.Templates` durch, an `fetch.Baseline` jedoch nicht — die Funktion hat keinen
  `force`-Parameter, und `placeBaseline` bricht bei vorhandenem `<tag>`-Verzeichnis
  bedingungslos mit `"%s existiert bereits (--force zum Ueberschreiben)"` ab. Ein Re-Run mit
  `--force` gegen ein bereits gebootstrapptes Zielrepo endet daher mit Exit 1 und einer
  Meldung, die genau das Flag empfiehlt, das der Aufrufer schon gesetzt hat; das
  `--force`-Overwrite, das vor diesem Commit über alle Emit-Schritte hinweg funktionierte,
  ist für den Baseline-Schritt nicht vorhanden. Der Doc-Kommentar
  (`baseline.go:94-96`: „Ohne force wird ein vorhandenes `<tag>`-Verzeichnis nicht
  ueberschrieben") beschreibt eine Semantik, die es im Code nicht gibt.
  Zweites Auftreten der Klasse aus slice-004a I1 („Fetch-Schritt ignoriert `--force`") — dort
  benigne (stilles Overwrite), hier fail-hard.
- `verifizierbar`: ja — `go test ./cmd/...` mit einem Fall
  „vorbereitetes `.harness/baseline/v3.5.0/` + `--lang go --force`" (existiert nicht) bzw.
  ein zweiter `make smoke`-Lauf gegen dasselbe tmp-Repo.

**M2 — Die neue `run()`-Verdrahtung des Baseline-Schritts ist in keinem Test verankert.**

- `kategorie`: MEDIUM
- `quelle`: Reviewer-Skill §MEDIUM (fehlende Tests bei neuem öffentlichen Vertrag) ·
  `LH-FA-09` Happy-Path-AC · Wiederholung von slice-004a M2
- `pfad`: `cmd/ai-harness-init/main.go:92-102` · `cmd/ai-harness-init/main_test.go:87-161` ·
  `harness/tools/smoke.sh:36-41`
- `befund`: Die vier `TestRun`-Fälle kehren vor dem Fetch zurück, `TestRun_UnknownLang` bricht
  im Skelett-Schritt ab, und `TestRun_EmitFehler` durchläuft `fetch.Baseline` +
  `emit.BaselineVerify` zwar erfolgreich, prüft danach aber ausschließlich Exit-Code und
  stderr des **DocGate**-Fehlers. Kein Test behauptet, dass nach einem Lauf
  `.harness/baseline/<tag>/{regelwerk,templates}/SHA256SUMS` oder
  `tools/harness/baseline-verify.sh` im `targetDir` liegen; ein Entfernen des
  `emit.BaselineVerify`-Aufrufs aus `main.go` färbt keinen Go-Test rot. `make smoke` wurde
  nicht erweitert (Schritt 3/4 prüft weiterhin nur `.harness/skeleton/Makefile`), sodass auch
  Tier 2 die neue Ablage nicht beobachtet. Die Paket-Ebene (`internal/fetch`,
  `internal/emit`) ist davon unberührt und gut gedeckt — die Lücke betrifft die Glue in `main`.
- `verifizierbar`: ja — Coverage über `cmd/ai-harness-init` bzw. probeweises Auskommentieren
  der beiden neuen Aufrufe (`make test` bleibt grün).

**M3 — Das emittierte Skript wird nirgends ausgeführt; seine Eigenschaften sind nur gegrept.**

- `kategorie`: MEDIUM
- `quelle`: Reviewer-Skill §MEDIUM (Spec-Treue-Lücke einer Messmethode) · `LH-FA-09`
  Prüfsummen-AC
- `pfad`: `internal/emit/baseline_test.go:34-46` (`TestBaselineVerify_BothAxes`),
  `:50-57` (`TestBaselineVerify_Netzlos`)
- `befund`: Beide Tests laden das eingebettete Skript als String und prüfen per
  `strings.Contains` auf vier Marker bzw. vier verbotene Substrings; das Skript wird in keinem
  Test, in keinem `.bats`-Fall und in `make smoke` ausgeführt. Damit belegt
  `TestBaselineVerify_BothAxes` nur, dass die Zeichenketten `sha256sum -c SHA256SUMS`,
  `find . -type f`, `cut -d' ' -f3- SHA256SUMS` und `[ "$listed" != "$actual" ]` im Text
  vorkommen — nicht, dass ein eingelegtes Artefakt rot wird. Genau das ist der Grund, weshalb
  H1 die Testsuite unbemerkt passiert: die dort behauptete Eigenschaft („kein stilles Grün
  bei eingelegter Datei") hält für reguläre Dateien und bricht für Symlinks, und der Test kann
  diesen Unterschied konstruktionsbedingt nicht sehen. `test/baseline-verify.bats` deckt den
  **Dogfood**-Zwilling ab, nicht das Emittat.
- `verifizierbar`: ja — ein bats-/Go-Fall, der das emittierte Skript gegen einen präparierten
  Baum laufen lässt, würde H1 sofort zeigen; heute existiert keiner.

**M4 — Die beiden neuen Schutz-Zweige (Zip-Slip, Backslash/Newline) sind im Test tot.**

- `kategorie`: MEDIUM
- `quelle`: Reviewer-Skill §MEDIUM (fehlende Negativtests bei neuem öffentlichem Vertrag) ·
  `LH-QA-02`
- `pfad`: `internal/fetch/baseline.go:167-169` (`!filepath.IsLocal(rel)` → `continue`),
  `:231-233` (Backslash/Newline-Abbruch in `writeSums`)
- `befund`: Keine Fixture in `internal/fetch/baseline_test.go` enthält einen
  Traversal-Eintrag (`../…`, absoluter Pfad) oder einen Pfad mit Backslash/Newline; beide
  Zweige werden von keinem Test betreten. Der Tar-Pfad desselben Pakets hat den
  entsprechenden Negativfall (`TestSkeleton_Extract` prüft laut slice-004a-Review die
  Abwesenheit von `../evil.txt`) — im neuen ZIP-Pfad fehlt er, obwohl die Extrakt-Kernlogik
  ausgetauscht wurde. Zusätzlich unbeobachtet: zwei ZIP-Einträge, die nach
  `baselineEntry` auf denselben Rel-Pfad abbilden (`writeFile` nutzt `O_CREATE|O_TRUNC`, der
  zweite Eintrag überschreibt den ersten still).
- `verifizierbar`: ja — Coverage über `internal/fetch` (beide Zweige 0 Hits); ein Fixture-ZIP
  mit `regelwerk/../../evil.txt` bzw. `regelwerk/a\b.md` würde sie betreten.

### LOW

**L1 — `TestBaseline_SumsVerifiableByCoreutils` ruft keine coreutils auf.**

- `kategorie`: LOW
- `quelle`: Maintainability (Messmethode) · `MR-007` Setzung 2
- `pfad`: `internal/fetch/baseline_test.go:127-152`
- `befund`: Der Test heißt „VerifiableByCoreutils" und begründet sich damit, dass „das
  emittierte baseline-verify sie genau so fuettert", zerlegt die Datei dann aber selbst und
  rechnet den Hash mit `crypto/sha256` nach — `sha256sum -c` wird nie aufgerufen. Die
  behauptete GNU-Format-Kompatibilität hält heute (unabhängig verifiziert: eine Datei in
  exakt der von `writeSums` erzeugten Form wird von `sha256sum -c` akzeptiert), hat aber
  keinen ausführenden Wächter gegen eine Format-Regression.
- `verifizierbar`: ja — eine Formatänderung (etwa ein Trenner statt zwei Leerzeichen) ließe
  den Test grün und das emittierte Skript rot.

**L2 — `emit.BaselineVerify` setzt mit `--force` den Ausführungs-Modus nicht neu.**

- `kategorie`: LOW
- `quelle`: `LH-FA-09` (netzlos prüfbar) · Maintainability
- `pfad`: `internal/emit/baseline.go:44` · `internal/emit/baseline_test.go:59-81`
- `befund`: `os.WriteFile(dst, baselineVerify, 0o755)` wendet das Perm-Argument nur beim
  **Anlegen** an; über eine bereits vorhandene Datei geschrieben bleibt deren Modus erhalten.
  Liegt im Zielrepo ein `tools/harness/baseline-verify.sh` mit `0644`, liefert ein
  `--force`-Lauf den richtigen Inhalt in einer nicht ausführbaren Datei — was der Kommentar
  („ein nicht ausfuehrbares Gate-Skript waere eine leere Zusage") gerade ausschließen will.
  `TestBaselineVerify_NoOverwriteWithoutForce` legt die Vorab-Datei mit `0o755` an und ist
  für diesen Fall blind; `TestBaselineVerify_EmittedExecutable` deckt nur den Neuanlage-Pfad.
- `verifizierbar`: ja — derselbe Test mit `0o644` als Vorab-Modus.

**L3 — Stat→Rename-Fenster und `.baseline-*`-Restverzeichnis.**

- `kategorie`: LOW
- `quelle`: Maintainability (Robustheit) · `MR-007` Setzung 4
- `pfad`: `internal/fetch/baseline.go:145-156`
- `befund`: Zwischen `os.Stat(final)` und `os.Rename(tmp, final)` liegt ein Fenster: ein in
  dieser Spanne entstandenes **leeres** `<tag>`-Verzeichnis wird von `rename(2)` still
  ersetzt (reproduziert), die Existenzprüfung greift dann nicht. Zweitens hinterlässt ein
  zwischen `os.MkdirTemp` und dem Rename abgebrochener Lauf (Signal, Stromausfall) ein
  `.harness/baseline/.baseline-XXXX/` im Zielrepo, das der `defer` nicht mehr räumt; der
  `<tag>`-Glob des Verifiers übersieht es (Punkt-Präfix, reproduziert), ein `git add -A` des
  Adopters nicht.
- `verifizierbar`: nein (Race) / ja für den Rest-Fall — ein `SIGKILL` während `unpackTrees`
  zeigt das Verzeichnis.

**L4 — Der Asset-Body wird unbegrenzt in den Speicher gelesen, bevor der Pin greift.**

- `kategorie`: LOW
- `quelle`: Maintainability · `LH-QA-03`
- `pfad`: `internal/fetch/baseline.go:104` (`readAllClose`) · `:260-263`
- `befund`: `io.ReadAll` puffert die HTTP-Antwort ohne `http.MaxBytesReader`/Größen-Schranke;
  die sha256-Prüfung (`:112`) läuft erst **danach**, sodass ein fehlgeleiteter oder
  aufgeblähter Endpunkt den Prozess vor jeder Verifikation über den Speicher kippen kann.
  Das reale Asset misst ~241 KB, die Bindung an `io.ReaderAt` (Plan §6) erzwingt das Puffern —
  die fehlende Obergrenze ist die beobachtbare Lücke, nicht das Puffern selbst.
- `verifizierbar`: ja — ein `AssetFetch`, der einen unendlichen Reader liefert (kein Test
  deckt das ab).

**L5 — Doku-Drift: `smoke.sh`-Kopf und `main.go`-Paket-Doc kennen den Baseline-Schritt nicht.**

- `kategorie`: LOW
- `quelle`: Maintainability (Doku-Drift)
- `pfad`: `harness/tools/smoke.sh:8-13` · `cmd/ai-harness-init/main.go:1-4`
- `befund`: Der Smoke-Kopf zählt die Bootstrap-Wirkung als „Doc-Gate + Template-Baseline +
  Sprachskelett-Fetch" auf und nennt den nun zweiten Netz-Fetch (Release-Asset) nicht; die
  Paket-Doc von `main.go` sagt weiterhin „Weitere Bootstrap-Wirkung (Templates,
  Sprachskelett) folgt in slice-003 ff.". Beide beschreiben einen Stand vor diesem Commit,
  obwohl der Commit die Schrittfolge in `run()` ändert. (Die `main.go`-Zeile ist
  vorbestehend; der Smoke-Kopf wird durch diesen Diff unrichtig.)
- `verifizierbar`: nein — kein Gate deckt Prosa in Shell-/Go-Kommentaren ab.

### INFO

**I1 — Teil-Bootstrap: vierte Wiederholung der Klasse, Steering-Zusage nicht eingelöst.**

- `kategorie`: INFO
- `quelle`: Reviewer-Skill §Kontext-Eskalation · slice-004a Closure-Notiz
  §Steering-Loop-Eintrag 2
- `pfad`: `cmd/ai-harness-init/main.go:82-120`
- `befund`: `run()` führt jetzt fünf schreibende Schritte ohne gemeinsamen Pre-Flight aus
  (Skelett → Baseline → Verifier → DocGate → Templates); scheitert Schritt n, bleiben die
  Ergebnisse von 1…n-1 liegen. Der Baseline-Schritt selbst ist intern atomar (Temp→Rename,
  s. Negativbefunde) — die Klasse betrifft die Kette. slice-004a hielt als Steering-Eintrag
  fest, dass „ein **gemeinsamer Pre-Flight über alle Bootstrap-Schritte** (oder ein
  Staging→Commit-Modell) die eigentliche Lösung" sei und wies ihn slice-004b/005 zu; er ist
  nicht gelandet, und dieser Diff fügt zwei weitere Schritte in die ungeschützte Kette ein.
  Zusammen mit M1 verschärft sich die Wirkung: der bisher verfügbare Ausweg „Re-Run mit
  `--force`" trägt für den neuen Schritt nicht.
- `verifizierbar`: ja — ein Lauf mit fehlschlagendem DocGate hinterlässt Skelett + Baseline +
  Verifier im Zielrepo (`TestRun_EmitFehler` erzeugt genau diesen Zustand, prüft ihn aber nicht).

**I2 — `BASELINE_SHA256` ist ein neuer, nirgends dokumentierter Env-Override auf den Pin.**

- `kategorie`: INFO
- `quelle`: `LH-QA-02` · `MR-007` Setzung 1 · Reviewer-Skill §INFO (undokumentierte Annahme)
- `pfad`: `cmd/ai-harness-init/main.go:156`
- `befund`: `envOr("BASELINE_SHA256", fetch.DefaultBaselineSHA256)` macht den
  Reproduzierbarkeits-Anker zur Laufzeit überschreibbar; zusammen mit dem bestehenden
  `COURSE_TAG` (das per String-Konkatenation in die Asset-URL fließt, `baseline.go:61`) lässt
  sich damit ein beliebiges Asset unter beliebigem Hash vendorn. Der Schalter ist
  Operator-intentional und folgt dem Muster von `DCHECK_DIGEST`/`COURSE_TAG` — anders als
  jene ist er in keinem MR, in `usage` (`main.go:21-31`), im README und im Slice-Plan
  erwähnt, sodass die Ausnahme vom „gepinnt"-Versprechen nur im Code steht.
- `verifizierbar`: nein — kein Gate prüft Env-Oberflächen; `grep -r BASELINE_SHA256` findet
  genau eine Fundstelle (den Code).

**I3 — Herkunftsklassen-Mischung in `tools/harness/` bleibt unbenannt.**

- `kategorie`: INFO
- `quelle`: `ADR-0005` (vier Herkunftsklassen) · `ADR-0004`/`LH-FA-06` · `MR-005`
- `pfad`: `internal/emit/baseline.go:22-26`
- `befund`: Die **Pfadwahl** ist korrekt begründet (`LH-FA-06` nennt `tools/harness/` und ist
  rank-1; `MR-005` hält ausdrücklich fest, dass die lokale `harness/tools/`-Adaption nicht auf
  die Emission generalisiert — s. Negativbefunde). Beobachtbar ist nur, dass das Verzeichnis
  damit zwei Herkunftsklassen mischt: `LH-FA-06`/`ADR-0004` füllen es aus dem **Picker**
  (Kurs-Template-Satz), `baseline-verify.sh` ist **Generator**/Tool-als-Quelle (`ADR-0005`).
  Weder `ADR-0005` noch `MR-005` noch der Slice-Plan sagen etwas dazu, ob das Verzeichnis
  klassenrein sein soll.
- `verifizierbar`: nein — Dokumentations-Frage, kein Gate.

**I4 — Kein Make-Target für den emittierten Verifier (korrekt aufgeschoben).**

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.1 · `LH-FA-09` Happy-Path-AC
- `pfad`: `internal/emit/baseline.go:26` · `harness/tools/smoke.sh`
- `befund`: Das Zielrepo erhält das Skript, aber kein `make baseline-verify`; ein emittiertes
  Root-`Makefile` existiert heute nicht (Generator = slice-023), weshalb keine Verdrahtung
  möglich und **kein** Gate behauptet wird — Hard Rule 3.1 ist gewahrt. Festgehalten, damit
  der Verifier die `LH-FA-09`-Formulierung „ist netzlos verifizierbar (Prüfsummen)" bewusst
  gegen „Skript liegt vor" statt „Gate läuft" abnimmt.
- `verifizierbar`: ja — `make -C <tmp-repo> baseline-verify` existiert nach dem Bootstrap nicht.

---

## Negativbefunde (geprüft, ohne Befund)

- **Zip-Slip / Pfad-Traversal (`internal/fetch/baseline.go:195-205`, `:167`):**
  `baselineEntry` normalisiert mit `path.Clean` **vor** dem Marker-Scan; danach können `..`
  nur noch als *führende* Segmente überleben, vor denen kein Marker steht — jede von mir
  konstruierte Form (`regelwerk/../../etc/x`, `x/regelwerk/../../../etc/x`,
  `/regelwerk/x`, `templates/../regelwerk/x`) liefert entweder `""` oder einen sauberen
  Rel-Pfad. `filepath.IsLocal(rel)` ist ein zweites Netz. Kein Ausbruchspfad gefunden
  (Testlücke separat als M4).
- **Symlinks/Sonderdateien aus dem Bundle:** `unpackTrees` ruft ausschließlich `writeFile`
  (`fetch.go:129-142`, `O_CREATE|O_TRUNC|O_WRONLY`, feste `0o644`) und nie `os.Symlink`/
  `os.Mknod`; ein Symlink-Eintrag im ZIP materialisiert als reguläre Datei mit dem Linkziel
  als Inhalt. Der Extrakt kann keinen Symlink **erzeugen** (H1 betrifft nachträglich vom
  Nutzer eingelegte).
- **Extrakt-Ziel nicht unterwanderbar:** entpackt wird in ein frisches `os.MkdirTemp`;
  `O_CREATE|O_TRUNC` kann dort keinem vorbestehenden Symlink ins Repo folgen.
- **„Kein Teil-Emit" innerhalb von `Baseline` (`baseline.go:97-139`):** der Rename ist die
  **letzte** Anweisung, nach ihr passiert nichts mehr; `defer os.RemoveAll(tmp)` ist danach
  ein No-op. Auf jedem Fehlerpfad davor (Fetch, Pin, `zip.NewReader`, fehlender Baum,
  `writeSums`) bleibt in `destDir` nur das Temp-Verzeichnis, das der `defer` räumt —
  `assertEmptyDir` verankert das in drei Tests (Mismatch, unvollständiges Bundle,
  Fetch-Fehler). Der Fehler-nach-Rename-Fall existiert innerhalb der Funktion nicht (Kette:
  I1; Race: L3).
- **`writeSums`-Determinismus (`baseline.go:210-253`):** sortiert per `sort.Slice` über
  `entries[i].rel < entries[j].rel` — Go-String-Vergleich ist Byte-Ordnung und damit
  `LC_ALL=C`; gehasht wird ausschließlich der Inhalt (keine mtime, kein Modus), Pfade sind
  relativ zu `<tag>/` und `filepath.ToSlash`-normalisiert. Zwei Läufe liefern byte-identische
  Dateien (`TestBaseline_Deterministic`). Die Sortier-**Achse** (Pfad statt Hash) ist der
  Punkt, den der Verifier über `cut … | sort` konsumiert; `TestBaseline_SumsForm` hält sie
  fest und wurde vom Implementer rot gesehen.
- **`SHA256SUMS` schließt sich selbst aus:** `rel == sumsName` → `return nil` (`:225-227`),
  und die Datei wird erst **nach** dem Walk geschrieben (`:249`) — sie kann sich weder selbst
  hashen noch listen. Vom Test verankert.
- **Leerer Baum:** `unpackTrees` erzwingt für beide Bäume `seen[tree] != 0` (`:181-187`), ein
  leerer Baum erreicht `writeSums` also nie; Verzeichnis-Einträge werden übersprungen, sodass
  keine leeren Verzeichnisse entstehen, die der `find -type f`-Vergleich nicht sähe.
- **`MR-007` Setzung 1 (Provenienz vor Integrität):** `hex.EncodeToString(sha256Sum(data)) !=
  wantSHA` steht **vor** `zip.NewReader` (`:112-119`) — der Pin greift vor jedem Entpacken,
  und der Bruch ist als eigener Typ `*SHA256Mismatch` via `errors.As` unterscheidbar
  (`TestBaseline_SHA256Mismatch_NothingWritten` prüft Typ **und** Feldinhalte).
- **`MR-007` Setzung 4 im Emittat (`baseline-verify.sh:38-52`):** das `<tag>`-Verzeichnis wird
  per Glob **entdeckt**, null Verzeichnisse und >1 Verzeichnis sind je ein lauter Fehler —
  real ausgeführt, beide Fälle Exit 1 mit erklärender Meldung.
- **Semantische Äquivalenz emittiert ↔ Dogfood:** Zeile-für-Zeile identischer Kontrollfluss
  (nullglob-Entdeckung → Ein-Tag-Prüfung → `SHA256SUMS`-Existenz → Escape-Vorbedingung →
  `sha256sum -c` → Bestandsvergleich → Erfolgsmeldung), identische Exit-Codes, identischer
  `cut`/`find`/`diff`-Vergleich. Divergenz ausschließlich (a) in der Kopf-Prosa (MR-/gates-/
  `regelwerk-check`-Verweise gestrichen, Bootstrap-Rahmung ergänzt — im Ziel gibt es weder
  MR-Nummern noch `make regelwerk-check`, also begründet) und (b) im impliziten Basispfad:
  aus `tools/harness/` löst `$here/../../.harness/baseline` auf `<target>/.harness/baseline`
  auf, genau wohin `main.go:92` schreibt. Real ausgeführt und in fünf von sechs Fällen
  verhaltensgleich zum Dogfood (Ausnahme = H1, die beide teilen).
- **Pfad-Entscheidung `tools/harness/` (`emit/baseline.go:26`):** konform. `LH-FA-06` (rank-1)
  nennt `tools/harness/` für die emittierte Struktur; `MR-005` §Auflösungs-Trigger führt genau
  diese Reconciliation als offen und hält fest, dass die lokale Adaption `harness/tools/` die
  Emission **nicht** berührt. Der Diff folgt der höherrangigen Quelle statt der lokalen
  Konvention — richtig herum aufgelöst (Klassen-Mischung als I3 notiert).
- **`ADR-0005`-Konformität:** Regelwerk + Templates kommen per **Fetch** vom Kurs-Tag
  (Klasse 1), der Verifier ist tool-autoriert/generiert (Klasse 2). Das `//go:embed` des
  Verifiers ist **nicht** das Embed-Duplikat, gegen das `ADR-0005` argumentiert: dessen
  Begründung ist „zwei Quellen für denselben Inhalt driften" — für ein tool-eigenes Artefakt
  existiert keine zweite Quelle. `ADR-0005` ist Accepted und unverändert; kein superseded ADR
  (`ADR-0001`) wird referenziert.
- **Additivität (Plan §1/§2):** `internal/emit/skel/**` erscheint **nicht** im Diff (Dateiliste
  des Commits: acht Dateien, keine unter `skel/`); `test/skel-drift.bats` unberührt. Der Slice
  fügt hinzu, er räumt nicht ab.
- **Slice-Plan §3 (Fünf-Zeilen-Tabelle):** alle fünf geplanten Änderungs-Arten haben eine
  Entsprechung im Diff (ZIP-Pfad neben Tarball-Pfad; `SHA256SUMS`-Erzeugung; generierter
  `baseline-verify`; `cmd`-Verdrahtung mit belassenem `fetch.Skeleton` als
  `--lang`-Validierung; ZIP-Fixture-Tests). Keine ungeplante Erweiterung außer der
  `sources`-Struct-Refaktorierung (im Commit begründet) und der `shell-lint`-Glob-Erweiterung.
- **Hard Rule 3.1 (keine halluzinierten Gates):** `make gates` und die Gate-Tabelle in
  `AGENTS.md` §4 / `harness/README.md` §Sensors sind unberührt; kein neuer Gate-Name. Die
  einzige Makefile-Änderung erweitert `shell-lint` um `internal/emit/templates/*.sh` — ein
  real existierender, nicht-leerer Glob (die Datei ist die erste `.sh` dort; vorher enthielt
  das Verzeichnis nur `d-check.yml`), also ein echter, nicht behaupteter Prüfbereich.
- **Hard Rule 3.2 (Lint-Suppression):** `grep -n "nolint\|shellcheck disable"` über alle fünf
  neuen/geänderten Quelldateien → keine Treffer; `.golangci.yml` ist nicht Teil des Diffs.
  Die Escape-Regex im Skript nutzt `'^[\]'` statt `'^\\'`, um SC1003 **ohne** Suppression zu
  vermeiden — genau die Linie, die 3.2 verlangt.
- **Hard Rule 3.3 (git mv + Inhalt):** `59c1d21` enthält keinen Rename; der Lifecycle-Move des
  Slice-Plans liegt als eigener Commit `292972f` davor.
- **Hard Rule 3.4/3.5:** kein ADR verändert; keine Gate-Schwelle gesenkt, kein Modul
  deaktiviert, keine Config gelockert.
- **`LH-QA-03` (minimale Abhängigkeiten):** `baseline.go` nutzt ausschließlich stdlib
  (`archive/zip`, `crypto/sha256`, `net/http`, …); `go.mod` ist nicht Teil des Diffs. Das
  emittierte Skript kommt mit `bash` + coreutils aus (kein node/jq/python; `--quiet` bewusst
  gemieden), und `TestBaselineVerify_Netzlos` grept die Netz-Werkzeuge aus.
- **Pin-Kopplung (`MR-013`-Muster):** `TestDefaultBaselineSHA256_MatchesMakefile` liest
  `BASELINE_ZIP_SHA256` aus dem `Makefile` und koppelt den eingebetteten Pin fail-closed —
  dieselbe Tier-1-Achse wie `TestDefaultTag_MatchesBaseline` (slice-004a M1) und
  `TestDefault…_MatchesCanonical`. Der Implementer hat den Test rot gesehen. Der Wert
  `123e3383…f8ff` stimmt mit `Makefile:34` und dem `.d-check.yml`-`sources`-Block überein.
- **`MR-008` (Templates referenziert statt kopiert):** der Diff legt keine Kopie eines
  Kurs-Templates im Repo an; `internal/emit/templates/baseline-verify.sh` ist tool-autoriert
  und hat keine Entsprechung im vendored Baum.
- **`--lang`-Validierung:** `fetch.Skeleton` bleibt der erste Schritt und damit fail-fast vor
  dem Baseline-Fetch — genau die Setzung aus Plan §6; `TestRun_UnknownLang` (Exit 2) hält sie.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 1 | H1 stilles Grün bei eingelegtem Symlink (emittiertes Gate-Skript) |
| MEDIUM | 4 | M1 `--force` im Baseline-Schritt wirkungslos · M2 `run()`-Verdrahtung untested · M3 Emittat nur gegrept, nie ausgeführt · M4 Zip-Slip-/Escape-Zweige im Test tot |
| LOW | 5 | L1 Coreutils-Test ohne Coreutils · L2 Modus bei `--force` · L3 Stat→Rename-Fenster + Temp-Rest · L4 unbegrenztes `io.ReadAll` · L5 Doku-Drift Smoke/Paket-Doc |
| INFO | 4 | I1 Teil-Bootstrap (4. Wiederholung) · I2 `BASELINE_SHA256` undokumentiert · I3 Herkunftsklassen-Mischung · I4 kein Make-Target (aufgeschoben) |

## Verdikt

**Merge-blockierend: JA.**

Getragen von **H1** und **M1–M4** (Reviewer-Skill: „HIGH und MEDIUM blockieren typischerweise").

**H1** ist der harte Blocker und kein latentes Risiko: das Skript, das dieser Slice als
Kern-Zusage ins Zielrepo trägt, meldet einen manipulierten Baum als „OK — Integritaet +
Vollstaendigkeit". Damit erbt jedes emittierte Repo genau die Lücke, die `MR-007` Setzung 3
als überdehnte Gate-Behauptung benennt und die Commit-Message und Plan §2 ausdrücklich als
nicht vererbt ausweisen. Der Befund ist real ausgeführt, nicht abgeleitet. Dass der
Dogfood-Zwilling dieselbe Zeile trägt, mildert ihn nicht — es verdoppelt den Fundort.

**M1** ist eine Regression an einem bestehenden Vertrag (`LH-FA-01` Boundary-AC): `--force`
trägt über alle anderen Emit-Schritte, nur nicht über den neuen — und die Fehlermeldung
empfiehlt das Flag, das der Aufrufer bereits gesetzt hat. Zusammen mit **I1** heißt das: ein
teilgebootstrapptes Zielrepo ist ohne Handarbeit nicht mehr fortsetzbar.

**M2/M3/M4** sind eine gemeinsame Deckungs-Signatur: die Paket-Logik ist ordentlich getestet
(die drei vorgeführten Zähne-Beweise halten, was sie behaupten), aber alles, was den Code
**verlässt** — die `run()`-Verdrahtung, das emittierte Skript, die Schutz-Zweige des neuen
ZIP-Extrakts — ist entweder gar nicht oder nur per `strings.Contains` beobachtet. H1 ist die
Rechnung dafür: ein Test, der das Skript ausführt statt es zu grepen, hätte den Befund in
derselben Sitzung geliefert.

Die fünf LOW und vier INFO blockieren nicht. **I1** ist über diesen Slice hinaus ein
Steering-Signal: die Teil-Bootstrap-Klasse steht bei ihrer **vierten** Wiederholung
(slice-002 I1 → slice-003 I1 → slice-004a L3 → hier), und die in slice-004a protokollierte
Zusage (gemeinsamer Pre-Flight, zugewiesen an slice-004b/005) ist nicht eingelöst, während
die Kette weiter wächst.

Keine Hard-Rule-Verletzung, kein halluziniertes Gate, keine Gate-Lockerung, kein Verstoß
gegen `ADR-0005`/`ADR-0004`/`MR-005`/`MR-007`/`MR-008`; die Pfad-Entscheidung `tools/harness/`
und die Additivität gegenüber `internal/emit/skel` sind korrekt aufgelöst.

**Übergabe:** Findings gehen an die Implementation (HIGH zuerst). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11, anderer
Eingabe-Kontext); I4 ist dort bewusst als Abnahme-Frage hinterlegt.
