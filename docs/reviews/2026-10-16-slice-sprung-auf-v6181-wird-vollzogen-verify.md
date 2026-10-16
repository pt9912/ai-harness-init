# Verifikation slice-sprung-auf-v6181-wird-vollzogen (HEAD a85c72bd)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Range `773bb9ec^..HEAD`
(166 Dateien, 401 Einfuegungen, 365 Loeschungen; Stichproben, nicht der ganze Diff gelesen).
Messungen mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH`.

## Verdikte je DoD-Punkt

- **1 Traeger auf v6.18.1, keine lebende Adresse auf v6.18.0 — bestaetigt.**
  - `make baseline-verify` -> `v6.18.1 OK — 54 Dateien`; `ls .harness/baseline` -> nur `v6.18.1`.
  - Fuenf Pins gemessen: `Makefile:25,34` (`BASELINE_TAG ?= v6.18.1`, sha `c3a256ed…bed31`), `.d-check.yml:544-545` (URL `…/v6.18.1/…`, gleicher sha), `internal/fetch/baseline.go:48,54` (`DefaultTag`, `DefaultBaselineSHA256`, gleicher sha), Mess-Tag `internal/emit/baumaussage.go:36` `InventurMessTag = "v6.18.1"`.
  - Symlinks: `readlink .claude/rules/*.md | grep -c 'baseline/v6\.18\.1'` -> 7; `… | grep '\.harness/baseline/' | grep -vc 'baseline/v6\.18\.1/'` -> 0.
  - Link-Kommando aus §1 -> 0; Inline-Pfade -> 1 (der Slice-Plan selbst, §3-Tabelle „entfernt", Zustandsangabe). Nicht-Markdown-Traeger mit `baseline/v6.18.0`: keine. `git grep -l 'baseline/v6\.18\.0'` ausserhalb Zeitdokumenten/Register/vendored nennt nur `ADR-0093` und den Slice.
  - `make regelwerk-check` (Netz) -> `d-check: 2698 Datei(en) geprueft, 0 Befund(e)`; `make baseline-freshness` -> `aktuell — gepinnt und latest sind beide v6.18.1`.
  - **Rot-Beleg selbst gefahren** (Arbeitskopie als `git worktree` ausserhalb des Repos — Colima teilt `/private/tmp` nicht mit Docker —, danach entfernt, `git worktree list` zeigt nur den Hauptbaum):
    - `BASELINE_TAG ?= v6.18.0` im Makefile -> `not ok 2 sources-url in .d-check.yml traegt den aktuellen BASELINE_TAG` (`test/sources-pin.bats:28`, `grep 'url:' … | grep -q "/$mk_tag/"` failed).
    - sha in `.d-check.yml:545` verfaelscht -> `not ok 1 sources-sha256 in .d-check.yml == Makefile BASELINE_ZIP_SHA256` (`:22`).
    - `DefaultTag = "v6.18.0"` in `internal/fetch/baseline.go` -> `make test-go`: `TestDefaultTag_MatchesBaseline … fetch.DefaultTag "v6.18.0" != Makefile BASELINE_TAG "v6.18.1" (Drift bei Re-Baseline)` und `TestInventurMessTag_IstDerGefetchteStand`.
    - Echte Pin-Werte, nicht Fixture; jede Meldung nennt die gebrochene Stelle.
  - Nicht nachgemessen: Asset -> vendored Baum (bleibt nach MR-007 ungehalten; Plan §6 nennt es).
- **2 Emission folgt den umgeschriebenen Adressen — bestaetigt, mit benannter Grenze (F-2).**
  - `test/neutralisierung-marker.bats` gruen am HEAD (3 Faelle); `ERWARTUNG` fuehrt `conventionsPathRefOld:0`; Tabelle `conventionsPathRefOld` in `templates.go` unveraendert (Verdikt A2, ADR-0093 Festlegung 2).
  - **Rot-Beleg selbst gefahren an der realen Quelle:** in der Arbeitskopie das Praefix der Zeile 87 in `.harness/baseline/v6.18.1/templates/harness/conventions.template.md` entfernt -> `not ok 2 jeder Wortlaut-Marker trifft seine Vorlage … # conventionsPathRefOld: 1 Treffer in harness/conventions.template.md (v6.18.1) — erwartet 0`. Nach Wiederherstellung wieder gruen. Damit ist der Rot-Beleg des Implementers nachgetragen, den der Review nicht fahren konnte.
  - `make full-smoke-host` -> EXIT 0; `full-smoke: OK — frisch gebootstrapptes Repo faehrt make -j gates out-of-the-box gruen …`. Im Log nennt `codepath-missing` nur den beabsichtigten Zahn (`docs/zahn-nicht-vorhanden.md`, Zeile 323); das emittierte `codepaths` meldet keine `.harness/baseline/<tag>/…`-Adresse. Die Meldung `e2e-abdeckung: FEHLER — Stufe ohne Deklaration` im Log ist der beabsichtigte Gegenbeispiel-Lauf der Stufe „E2E-Abdeckung im Ziel", der Lauf endet trotzdem EXIT 0.
  - Die drei Proben im Kommentar von `StripCommentHints`: nicht einzeln nachgefahren (Stichprobe: `make gates` und full-smoke gruen); Beleg ist die Aussage des Implementer-Commits `26ef8f20`.
- **`make gates` — bestaetigt:** EXIT 0 am HEAD `a85c72bd`; `.harness/state/gates-passed.head` == `git rev-parse HEAD` (`a85c72bd69c557f8…`); `git status --short` danach leer.
- **`make full-smoke` — bestaetigt in der macOS-Variante:** `make full-smoke-host` EXIT 0 (`full-smoke` ohne `-host` nicht gefahren; die Host-Variante unterscheidet sich im Traeger-Bau).
- **Review durchgefuehrt, Report liegt vor — bestaetigt:** `docs/reviews/2026-10-16-slice-sprung-auf-v6181-wird-vollzogen.md`, volle Kennung im Dateinamen, 0 HIGH · 0 MEDIUM · 1 LOW · 2 INFO.
- **A1–A3 als eigene Architect-Commits — bestaetigt:** ADR-0093 vor der Range `Accepted`; `5f294fbd` (Adress-Nachzug), `2a44411b` (Buchung), `c63d2f48` (Freshness-Verdikt, leerer Commit, Verdikt in der Message — vor dem Entfernen des alten Baums `e10c2328`, Reihenfolge stimmt). Alle tragen die Rolle in der Message.
- Closure-Notiz, Register, Risiko-Ausgaenge, Paarungen: Planner-Arbeit, nicht geprueft; keine DoD-Haken gesetzt.

## Findings

- **F-1 (LOW-1 des Reviews bewertet — verletzt die DoD nicht):** Fall `577` ist entfernt (`26ef8f20`); die Mutation loescht den Aufruf von `NeutralizeConventionsTemplateRef`, der am Pin ein No-op ist, und faerbte nichts. DoD-Punkt 2 verlangt als Waechter die Erwartung `conventionsPathRefOld:0` am realen Baum — der ist belegt und rot gesehen. Der Kommentar an der Funktion nennt, dass die Zeile aelteren Staenden gilt und der Marker am Pin 0-mal trifft (`templates.go:679-686`); nicht genannt ist, dass der Aufruf selbst am Pin keinen realen Waechter hat (nur `TestConventionsTemplateRefGateSafe` ueber eine Fixture im Wortlaut bis v6.18.0). Das ist eine benannte Luecke in Commit-Message und ADR-0093, nicht am Ort der Zusage (AGENTS.md §3.6, Grenze). Kein Blocker; Planner entscheidet, ob ein Satz am Kommentar nachgezogen wird oder die Luecke als Beobachtung ins Register geht.
- **F-2 (Grenze, Zusage vs. Sensor):** Die DoD sagt „im emittierten Satz steht keine Adresse, die im Ziel nicht aufloest". Gemessen ist nur „wird nicht als `codepath-missing` gemeldet": das emittierte `codepaths` hat `roots: [spec, docs, harness]` (`internal/emit/templates/d-check.yml:32`), ein Pfad mit Anfang `.harness/…` liegt ausserhalb der roots und bleibt am gepinnten d-check still (Kommentar dort, Zeilen 27-29). Die Literale `<tag>` loesen im Ziel nicht auf; sie werden nur nicht geprueft. Kein Sensor haelt „loest auf". Plan §1 nennt den Lauf als Beleg fuer „nicht gemeldet", insofern erfuellt; die breitere DoD-Formulierung ist enger belegt als gesagt. Fuer den Planner bei der Closure festzuhalten, ggf. als drittes Auftreten-Kandidat zu `BEO-ALL/vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt` (Zaehler und Urteil beim Planner).
- **F-3 (INFO-1 des Reviews):** `conventionsPathRefOld:0` unterscheidet „Praefix steht" nicht von „Satz entfaellt"; fuer die Eigenschaft „kein unpraefixierter Pfad im Ziel" folgenlos. Rot-Beleg nachgetragen (oben).
- **F-4 (INFO-2 des Reviews):** Freshness-Verdikt `c63d2f48` ist ein leerer Commit, Verdikt nur in der Message; nach A3 (Verdikt vor dem Entfernen) und dem Register-Eintrag zulaessig. Auffindbarkeit nur ueber `git log`.
- Plan-vs-Code: Diff stimmt mit der §3-Tabelle ueberein (Pins, Mess-Tag, Symlinks, Wortlaut-Test, Fall 577 entfernt, Nachzug je Eigentuemer); Gebautes ohne Plan nicht gefunden. `full-smoke.sh` und `docs/user/e2e-abdeckung.md` unveraendert, wie §3 sagt. Keine Accepted-ADR im Diff geaendert.

## Nicht gefahren

- Mutations-Ergebnis vom CI-Branch: der Implementer nannte keinen `mutate/…`-Branch; `git ls-remote` nicht abgefragt. `make mutate-greift` liegt in `make gates` (gruen).

## Empfehlung

Verdikt: DoD-Punkte 1, 2 (mit F-2), Gates, Review-Report und A1–A3 bestaetigt; keine Verletzung der DoD durch LOW-1. Closure und Haken beim Planner.
