# Verifikation — slice-gates-pruefgegenstand-stempel-v1

**Verifier-Lauf:** frisch, frischer Kontext (Plan, Review-Report, ADR-0108 gelesen; Läufe und Rot-Züge eigen-händig gefahren)
**Code-Stand:** HEAD `8f901668` (main, `2026-11-27 19:19:21 +0000`); Kette seit Claim `6b03706e` · `831e751f` · `72d1d364` · `f5744d91` · `10acdcb9`; Parallel-Zug `cf3def02` nicht Gegenstand
**Review:** `docs/reviews/2026-11-27-slice-gates-pruefgegenstand-stempel-v1.md` (`a57ffe88`; F-1/F-3/F-4 in `10acdcb9` behoben, F-2 als Plan-Korrektur beim Planner)
**Betriebsform:** docker-los am Host (Linux); alle Läufe über make bzw. die make-Fassung der Skripte; **kein Commit, kein push, kein Netz**; Protokoll-Commits nur im Verifier-Worktree (dann entfernt)
**Run-Log des vollen Laufs:** `/tmp/verify-full-gates.log`

---

## Urteile je DoD-Punkt (§2)

- **Liefer-Punkt 1 — je Check sein Prüfgegenstand: BESTÄTIGT.**
  Bestand: `harness/tools/gates-keys.sh` ist die eine Definition je Bezugsmenge
  (drei Leser, Modus-Verzeichnis im Kopf); Messrezept je Check im Kopf; fail-closed
  je Unform (`MR-017`), leeres Byte-Sheet ist kein Key. Messung (Kante `liste`: 13
  Checks) je Check die Tafel-Menge gezählt — environment-check 6 ·
  baseline-verify 59 · docs-check-host 3109 · lint 148 · build 133 · test 999 ·
  shell-lint 928 · ci-lint 6 · comment-claims 108 · register-ausgang 1412 ·
  mutate-greift 808 · host-bin 132 · span-check 5 Dateien. **Die Rezeptzeile der
  Kante liegt je Check in der Menge — 13/13** (`bash harness/tools/gates-keys.sh
  menge <check> | grep -cE '^Makefile$'` → 13× `1`); damit ist Review F-1
  (Rezeptzeilen außerhalb der Mengen bei 8 der 12 Kanten-Checks) geschlossen
  gemessen. Repräsentative Anker: `menge baseline-verify` führt
  `harness/tools/baseline-verify.sh`, `internal/fetch/baseline.go` und
  `.harness/baseline/v7.0.0/SHA256SUMS`; `menge host-bin` führt `go.mod` und die
  cmd-/internal-Quellen (113 Einträge) — die inert `go.sum`-Zeile (Review F-3) ist
  im Bestand NICHT vor (`ls go.sum` → *No such file or directory*) und in keiner
  Menge, der Fall-804-Kopf trägt die Grenze.
  **Rot-Beleg (Wächter-Züge, eigen-händig im Verifier-Worktree):**
  Test 7 `keys: je Check mit Werkzeug-Skript deckt die Menge ihr eigenes Skript`
  — Substitution `'./harness/tools/baseline-verify.sh'` → `'./harness/tools/baseline-verify.go'`
  in der Tafel → `not ok … Skript-Deckung fuer [harness/tools/baseline-verify.sh]`,
  restore → ok. Test 8 `keys: die kompilierte Menge des host-bin deckt die Baubasis`
  — Substitution `'./go.mod'` → `'./go.mox'` im host-bin-Block → `not ok … Baubasis
  [go.mod] (Zusage: eine Zeile der Menge)`, restore → ok; danach die volle
  `bats test/gates-keys.bats` grün (11/11, u. a. ok 9 „Rezeptzeilen der Kante“ und
  ok 10 „Rezept-Edit dreht den je-Check-Key“).
- **Liefer-Punkt 2 — Fast-Pfad je Form: BESTÄTIGT.**
  (a) `make gates` am unveränderten Baum → SKIP über dem vollständig gedeckten
  Satz (alle 13 Keys je `gates-passed-<check>.key` == Satzerzeuger-Wert, Exit 0),
  der benannte Rest in derselben Meldung. (b) Doku-only-Änderungs-Zug in der
  Arbeitskopie (README.md angefasst, kein Commit) → TEILDRIFT fährt **genau**
  `docs-check-host` (d-check: 3099 Datei(en) geprüft, 0 Befund(e)), stempelt;
  restore → SKIP wieder, Exit 0. (c) `GATES_FORCE=1 make gates` → voller Lauf
  über alle 13 Checks, Exit 0 (siehe unten). CI unverändert voll: die Keys liegen
  gitignored (`.harness/state/`), der Klon fährt fail-closed voll
  (ADR-0108 Festlegung 3 — Gelesene Form, nicht erneut gefahren).
- **Liefer-Punkt 3 — Stop-Hook über der Mischform: BESTÄTIGT; die Rest-Hälfte
  steht als bekannter Posten.** Hook-Züge **ohne Commit** (main-Klon) und die
  Zwei-Kommit-Fälle im Verifier-Worktree — Kommandos und Ausgaben:
  1. HEAD unverändert, Keys decken: `echo '{}' | bash .claude/hooks/stop-require-gates.sh`
     → block: „HEAD unchanged: the per-check keys cover their sets, but files
     outside every declared Menge leave the coverage basis incomplete. Run
     `make record-gates` again (fail-closed, ADR-0108).“
  2. HEAD unverändert, Key gedriftet (README.md dirty, kein Commit) → block:
     „HEAD unchanged, but per-check gate keys do not cover the working tree
     (ADR-0108). Run `make gates` again. Not covered: docs-check-host — Key
     fehlt, unformal oder gedriftet“; restore → der erste Wiederhol-Zug liefert
     dieselbe block. Der Je-Check-Zahn greift an der uncommitteten Änderung.
  3. Neuer HEAD, Inhalt ≠ Nachweis, Keys decken (Worktree, Doku-only-Commit
     `97792eec`, danach die Teildrift-Stempel frisch) → block („… Run
     `make record-gates` again“, Variante der Zeile
     `stop-require-gates.sh:163-165`; Wortlaut nur als block-Entscheidung erfasst).
  4. Neuer HEAD, **Record-only-Commit**: Worktree-Commit `d02e8582`
     (Datei allein unter `.harness/stamp/mutate/`, Inhalt sonst byte-gleich zum
     Nachweis) → **approve** `{"decision":"approve"}` — derselbe „Hash gleich“-Zweig,
     den ADR-0108 Festlegung 5 für den Record-only-Fall zusagt; `make gates` über
     demselben Commit → SKIP über dem vollen Satz, kein Key rotiert.
  **Fail-closed an der Ausnahme-Grenze:** die erste Probe lag unter
  `.harness/stamp/verify-probe-gps.txt` — **außerhalb** der deklarierten
  Hash-Ausnahme (`.harness/stamp/mutate`); der Hook lief in den
  `working-tree-hash`-Fehler („… liegt unter .harness/stamp/ ausserhalb der
  deklarierten Hash-Ausnahmen … ADR-0103 Festlegung 2“) und endete Exit 2
  — fail-closed, kein freies Turn-Ende. Die Ausnahme-Liste ist die eine
  (ADR-0103 Festlegung 2), der Record-only-Vertrag des Plans §5/Festlegung 6 (b)
  ist an `.harness/stamp/mutate/` geschärft, nicht an ganz `.harness/stamp/**`.
  Siehe offene Posten unten.
- **`make gates` grün: BESTÄTIGT.** Zwei Beleg-Formen am HEAD `8f901668`:
  (1) SKIP-Form am unveränderten Baum (Exit 0, Satzmeldung + Rest-Meldung);
  (2) voller Lauf `GATES_FORCE=1 make gates` am Ende, Exit 0 —
  environment-check: 12/12 Pflicht-Werkzeuge · baseline-verify: v7.0.0 OK (55
  Dateien) · comment-claims: 107 Datei(en), 0 Befund(e) · register-ausgang: 293
  Einträge, 83 über der Schwelle, 0 Befund(e) · mutate-greift: **804 Fälle, 804
  greifen, 0 Befunde** · span-check: Traeger vorhanden, span-emit hat einen Span
  geschrieben; bats-Suite 0 rot (`grep -c 'not ok'` → 1, der Treffer ist Testname
  „driver: der abgebrochene Gruen-Vorlauf nennt ein fruehes not ok“, kein roter Fall).
- **Review durchgeführt, Report unter docs/reviews/: BESTÄTIGT** (`a57ffe88`;
  1 HIGH + 2 MEDIUM + 1 LOW; F-1/F-3/F-4 in `10acdcb9` behoben — F-1 und F-3
  dieser Lauf eigen gemessen, F-4 am Register gelesen: die Aufzählung trägt jetzt
  drei nummerierte Sichtungen (1)/(2)/(3)).
- **Doku-Update (öffentliches Vertrag berührt): BESTÄTIGT.** `harness/README.md:62`
  — „Fast-Pfad: SKIP über dem gedeckten je-Check-Satz, bei Teildrift die
  gedrifteten Checks, sonst voll“ gebunden an ADR-0108;
  `harness/sensors/gates.md` trägt die Tier-2-Form vollständig (SKIP-Bedingung
  je-Check-Satz, Teildrift fährt genau die gedrifteten Checks, benannter Rest,
  Wächter, Grenze). Beobachtung ohne Normwirkung: der DoD-Anker „§Fast-Pfad“
  nennt keine Überschrift — die Form steht im Titel („Fast-Pfad je-Check-Satz
  (Tier 2)“) und in §Vertrag.
- **Closure-Notiz mit Lerneintrag: OFFEN (Planner-Closure)** — §7 bleibt nach
  Vorlage leer, wie beim Implementer-Zug erwartet.
- **Beobachtungs-Register fortgeschrieben: BESTÄTIGT für den Implementer-Anteil**
  — `BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf/` mit `state.md` (Zähler 1)
  und `evidence/slice-gates-pruefgegenstandstempel-v1`; das DoD-Kriterium
  „kein Zähler gesetzt“ hält. Die Register-Zeile bei Closure („evidence/ ergänzen“)
  trägt der Planner.
- **Risiko-Ausgänge und drei Paarungen: OFFEN (Planner-Closure)** — inhaltlich
  (siehe unten „Gebautes ohne Plan / Zusage breiter als Messung“), formal an der Closure.

## §5-Closure-Trigger — die zwei Protokoll-Läufe (auf diesen Bericht gelegt)

Beide über reale git-Commits im Verifier-Worktree (`/tmp/verify-gates-wt`,
nach der Messung entfernt — `git worktree remove --force`, prune, Zweig gelöscht;
Stempel- und bin-Ablage je Klon übertragen):

1. **Doku-only-Commit** `97792eeca55dea59699deca0456f8a868aed39fd`
   (nur README.md: `git show --stat` = 1 file changed) → `make gates` →
   TEILDRIFT fährt **genau `docs-check-host`**, die übrigen 12 Checks SKIP, d-check
   läut grün (3099 Datei(en) geprüft, 0 Befund(e)) und stempelt ihren Key; der
   SKIP über dem vollständig gedeckten Satz steht im selben Zug (Meldung der
   Form `gates: SKIP — …` am selben Baum nach dem Restore, siehe LP 2 (b)/(c)).
   **Nicht gefahren: der Code-only-Commit-Halbteil von §5 Zusage 1** („ein
   Code-only-Commit fährt nur die Code-Checks“) — eine Zusage breiter als ihre
   Messung; die Sensitivität der Code-Checks trägt die Tafel und die Rot-Züge
   (Test 7/8), nicht ein Protokoll-Lauf eines Code-only-Commits. **Offener Posten
   an den Planner:** entweder nachfahren (ein Worktree-Commit an `internal/**`
   plus `make gates`) oder die Zusage an dem Ort schärfen, wo sie gemessen ist.
2. **Record-only-Commit** `d12581ad06977cc8b6e9045b53f54e2d5f6e1e56`
   (nur `.harness/stamp/verify-probe-gps.txt`, 1 file changed) → `make gates` →
   SKIP über dem vollständig gedeckten Satz (13 Checks), `MENGE_AUSSCHLUESS` von
   `.harness/stamp/**` — der Hash vor/nach: „KEYS-BYTE-GLEICH vor/nach“
   (`sha256sum .harness/state/gates-passed-*.key | sha256sum` unverändert).
   An dem zweiten Record-only-Commit (innerhalb der Ausnahme, `d02e8582`) liest
   außerdem der Hook den ADR-0108-Satz (approve).

## Plan-vs-Code (beide Richtungen)

- **Gebautes ohne Plan — Bestätigung F-2 (Tafel-Drift, Planzeilen 245/255) für
  den Planner, kein Zug des Verifiers:**
  1. `baseline-verify` — Plan: „`SHA256SUMS` + … die Pin-Zeilen … die vier
     gekoppelten Pin-Stellen (`.d-check.yml` `sources`, `internal/fetch/baseline.go`
     Defaults)“. Gelesen: die Menge trägt `harness/tools/baseline-verify.sh`,
     `internal/fetch/baseline.go` und die `SHA256SUMS` **im Tag-Verzeichnis**
     (`.harness/baseline/v7.0.0/SHA256SUMS`); am Wurzelpfad liegt keine
     (`ls SHA256SUMS` → fehlt), das Wurzel-`.d-check.yml` liegt NICHT in der Menge
     (nur die Baseline-Kopie `.harness/baseline/v7.0.0/templates/.d-check.yml`);
     die Pin-Zeilen des Makefile sind transitiv über `Makefile` in der Menge.
  2. `host-bin` — Plan: „die Traeger-Verdrahtung (Rezept, `harness/tools/`-Anteile,
     `TRAEGER_TAG`-Auswertung)“. Gelesen: `Makefile`, `go.mod`, `cmd/*.go`,
     `internal/*.go` — die Modul-Daten trägt die Menge, `harness/tools/`-Anteile
     keine; die Korrekturen sind nach Review nach Wahrheitsgehalt gerechtfertigt
     (das Rezept kompiliert die Quellen mit ihren Modul-Daten).
- **Geprüft ohne weiteren Befund (Stichprobe, keine Systematik):** die übrigen 11
  Tafel-Zeilen habe ich nicht Zeile-für-Zeile gegen die Messrezepte gelesen; der
  Review-Report trägt die Tafel-Berichtigungen baseline-verify/host-bin je
  Wahrheitsgehalt, und `10acdcb9` zieht die Rezeptzeilen nach (13/13 gemessen).
- **Plan-Nachzug-Form:** der Plan nennt die Rezeptzeilen-Klasse (F-1-Abgrenzung)
  seit `10acdcb9` nicht — auch das gehört zum F-2-Nachzug beim Planner.

## Rollenübergreifendes

- **Mutations-CI-Branch:** der Implementer nennt keinen
  `mutate/<kennung>-<sha8>`-Branch — kein FETCH gelesen (Netz aus im Lauf). Die
  Rot-Belege der neuen Mutations-Fälle 804/805 tragen im Review-Report (worktree)
  bzw. in der Commit-Meldung `10acdcb9` („11/11 gruen“); dieser Lauf fährt sie
  nicht erneut — Stichprobe entfallen, `mutate-greift` im vollen Lauf meldet 804
  Fälle, 804 greifen, 0 Befunde.
- **Stempel-Satz am HEAD:** 13 je-Check-Keys + `gates-passed.diffsha` +
  `gates-passed.head`, alle identisch gestempelt `2026-11-27T19:26` (vor dem
  vollen Lauf dieses Verifiers) — Form des vollen `record-gates`-Laufs;
  `gates-passed.head` == HEAD `8f901668`. Nach dem vollen Lauf dieses Verifiers
  frisch gestempelt (19:45/19:46, Form unverändert, head == HEAD —
  nachgeprüft). Erzeuger des 19:26-Satzes ist aus der Ablage nicht attribuierbar;
  zeitnah zum HEAD-Commit 19:19 — plausibel ein voller Lauf zum HEAD.

## Offene Posten für Planner/Architect (Closure)

1. **F-2 Plan-Tafel-Nachzug** (siehe Plan-vs-Code) — Planner; kein Zug hier.
2. **§5 Code-only-Halbteil ungemessen** (Zusage 1 wider als die zwei
   Protokoll-Läufe gefahren) — nachfahren oder Zusage an der Messung schärfen.
3. **Rest-Viertel der Stop-Hook-Mischform je ADR-0108 Festlegung 5:** der
   `gates-keys.sh rest`-Walk nennt 34 Dateien des Zuordnungs-Rests (im
   Messrezept-Kopf benannt, nicht geschlossen); damit ist der
   `mischform_gedeckt`-Approve-Zweig des Hooks an jedem HEAD-Ende tot — der
   Hook blockt (Variante 1 und 3 oben) auch über deckenden je-Check-Keys, und
   der Träger bleibt der volle `make record-gates` am neuen HEAD plus die
   `stop_hook_active`-Freigabe des zweiten Versuchs. Fail-closed, wie
   deklariert („die Mischform gibt fail-closed nicht frei“); ob der
   Zuordnungs-Rest je Check in die Mengen aufgenommen werden soll, ist eine
   Plan-Entscheidung je ADR-0108 (Abwägung E), kein stiller Eintrag.
4. **Der Record-only-Vertrag ist an `.harness/stamp/mutate/` geschärft** —
   ADR-0103 Festlegung 2; der Plan §3 Festlegung 6 und der Plan-§5-Satz nennen
   die Form als „`.harness/stamp/**`“ (bzw. „die Ausnahme wächst nicht“) —
   für den Konsum des Hooks gilt die engere Menge. Falls der Plan das breiter
   liest, gehört der Nachzug in denselben F-2-Zug.
5. **Closure-Notiz, Risiko-Ausgänge, drei Paarungen** — Planner-Closure nach
   dem `git mv`.
