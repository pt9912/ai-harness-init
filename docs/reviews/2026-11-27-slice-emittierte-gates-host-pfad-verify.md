# Verifikation — slice-emittierte-gates-host-pfad

**Verifier-Lauf:** frisch, frischer Kontext (Slice-Plan §2/§3/§6 und Review-Report gelesen; Rot-/Run-Belege eigen-händig gefahren)
**Code-Stand:** HEAD `6cabbee6` (main, gepusht); Implementer-Diff `ef1ac86f..6cabbee6` — Implementer `f272edd3`, `0fe90d56`, `e41cf3c5`; Review-Zug `51cfd1c0` (Report) + Behebung `9bd6f440`/`b6971de0`/`6cabbee6`
**Review:** `docs/reviews/2026-11-27-slice-emittierte-gates-host-pfad.md` (1 HIGH, 5 MEDIUM, 1 LOW, 2 INFO — alle im Behebungszug bearbeitet, s. Verifikation der Findings)
**Betriebsform:** docker-los am Host (Linux), kein Netz, kein Push, alle Läufe über make-Ziele — außer dem Produkt-Binary-Aufruf des LP2-Bootstrap (der Schritt selbst ist der unter Messung stehende Carrier-Weg, gemäß F-6-Umgebungsaufgabe `DCHECK_CARRIER` von außen)

---

## Urteile je DoD-Punkt (§2)

- **Liefer-Punkt 1 — emittierte Gates-Fragmente tragen die host-native Form mit Inventar-Emittierung: ERFÜLLT, MIT GRENZE (neuer Befund, unten).**
  Bestand: `internal/emit/environment.go` — `GATE_CHECKS := environment-check $(GATE_CHECKS)` (Präferenz-Form); `internal/emit/emit.go` — `dcheck-fetch`-Rezept reicht die Pins exportiert (`DCHECK_IMAGE="$(DCHECK_IMAGE)" DCHECK_DIGEST="$(DCHECK_DIGEST)"`), `docs-check-host` mit Diagnose-Ausgang (fail-closed, Exit 2); Inventar je Sprach-Skelett über `gen.InventoryRows` + `emit.EnsureInventoryRows` (konvergent, je Werkzeug die eine Zeile, geändertes Soll gewinnt).
  Rot-Belege (am realen Bestand gezeigt, je Wächter mutiert → rot → zurück, `git diff --quiet` bestätigt):
  - `TestDocGateMk_FetchRezeptExportiertDiePins` — exportierte Pin-Form aus dem Rezept entfernt → **rot**; zurück → grün.
  - `TestInventoryRows_SollTragtDenPinDesFragments` — Soll-Wert in `gen.InventoryRows` hart verdrahtet (statt vom Pin abgeleitet) → **rot**; zurück → grün.
  - Fall 40 (`GATE_CHECKS += docs-check-host` → `docs-xxxx`, sed von Hand an der realen Quelle, weil der `make mutate`-Vorlauf an den zwei vorbestehenden test-go-Klassen bricht) → **rot**: der genannte Wächter `TestDocGate_FragmentWiresDocsCheck` fällt, daneben die weiteren Gates-Kette-Wächter (`TestArchivierungFragment_ZielAmTraegerUndNichtInDerGatesKette`, `TestE2eAbdeckung_FragmentHaengtAnKeinerGateKetteDesZiels`, `TestErfassung_NichtInDerGatesKette`, `TestHooksInstallFragment_IstKeinGateUndNenntDenTraeger`, `TestSelbstpruefung_FragmentHaengtAnKeinerGateKetteDesZiels`, `TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette`) — dieselbe eine Zeile trägt mehrere Wächter, erwartet. Zurück → Stand clean.
  Emitter-Tests (LP3-Halbteil): `make test-go` an HEAD, ohne die Mutationen — grün außer den **zwei vorbestehenden Klassen** (unten); die neuen Tests (`TestEmmittedEnvironmentMk_StelltCheckVorAlleChecks`, `TestEmittedEnvironmentCheck_EngineGleichDerLabFassung`, `TestDocGateMk_FetchRezeptExportiertDiePins`, Identitäts-Wächter beidseitig, Paarungs-Wächter) grün.
  **Grenze (neuer Befund)** — die Inventar-Emittierung kann grün nur mit Soll-Form, die der Probe passt; siehe Abschnitt „Neuer Befund".
- **Liefer-Punkt 2 — frisch gebootstrapptes Ziel fährt `make gates` out-of-the-box grün ohne Docker-Daemon, belegt im realen Lauf: NICHT ERFÜLLT am Host — real gefahren, mit drei benannten Grenzen.** Reale Lauf-Kette (dieser Verifier, netz- und docker-frei):
  1. Carrier-Bau am Host: `make host-bin` → HEAD-Binary `.harness/state/bin/ai-harness-init`.
  2. Bootstrap eines tmp-Ziels (`git init` + Produkt-Binary `--lang go`) mit **extern geliefertem** `DCHECK_CARRIER=<dotfood>/.harness/state/bin/d-check` → **Exit 0**, Fragment-Assembly steht: `harness/mk/environment.mk` trägt die Präferenz-Zeile `GATE_CHECKS := environment-check $(GATE_CHECKS)`, `harness/mk/go.mk` trägt `GATE_CHECKS += lint build test`, `dcheck-fetch`-Rezept exportiert die Pins.
  3. d-check nach `.harness/state/bin/d-check` im Ziel gelegt (extern — im realen frischen Ziel nur `make dcheck-fetch`, Netz).
  4. `make gates` im Ziel → **rot an `environment-check`, dem ersten Check** — exakt die Semantik der ersten-Check-Zusage: „2 von 7 Pflicht-Werkzeugen tragen ihr Soll nicht": (a) `go · Soll: 1.27.3 · Ist: 1.27.4` — legitime Umgebungs-Semantik (Skelett-Pin 1.27.3, Host trägt 1.27.4; dieselbe Klasse, die `TestGoProfile_PinsMatchRepo` am Dogfood nennt); (b) `golangci-lint · Soll: v2.15.0 · Ist: 2.15.0` — **nie auflösbare Soll-Form, neuer Befund (unten)**.
  Fazit: `out-of-the-box grün` ist am Default-Weg **nicht** erreicht — drei Grenzen, jede benannt: (1) Carrier für `--print-mk` von außen (F-6, Umgebungsaufgabe); (2) d-check-Ablage im Ziel von außen oder `make dcheck-fetch` (Netz); (3) die zwei Umgebungs-Befunde des Laufs, davon einer eine Soll-Form, die auch bei korrekt installiertem Werkzeug rot bleibt. Ein vollgrüner Lauf braucht einen Host, der die Pins exakt trägt (go 1.27.3, golangci 2.15.0 erkannt) **und** die v-freie Soll-Form — Träger CI mit passender Matrix.
- **Liefer-Punkt 3 — Emitter-Tests tragen die Form, Mutations-Anker neu gemessen (MR-071/MR-090): ERFÜLLT FÜR FALL 40; GRENZE beider Vorläufe.** Fall 40: `make mutate MUTATE_CASES=40-docgate-fragment-wiring` → Bruch **im Vorlauf** (`make test-go` in der Kopie, Exit 1 an den zwei vorbestehenden Klassen `TestStopHook_CommitBindung`/`TestGoProfile_PinsMatchRepo`) — der Fall selbst fuhr dadurch nicht; der Rot-Beleg kam per Hand-Sed an der realen Quelle (LP-1 oben, rot, zurück). Fall 40-**Greift**-Beleg liegt aus dem Review vor (794/796, Befunde nur 784/785). **Grenze (bestätigt, Review INFO):** die neue Präferenz-Zusage (`environment.go`, first Check) trägt **keinen** Fall in der Mutations-Anlage — ihr Rot-Zug existiert als Test-Kopf-Text (`TestEmittedEnvironmentMk_StelltCheckVorAlleChecks`), nicht als Fall; der Verifier fuhr den Red-Tour des exportierten Pins und des Paarungs-Wächters, **nicht** den der Präferenz-Zusage. → offener Posten (Closure).
- **`make gates` grün: NICHT ERFÜLLT — rot an vorbestehenden Klassen.** Ende-Lauf `make gates` an HEAD: fail-fast an `docs-check-host` mit **106 Befund(e) an 3079 Datei(en)** (Klassen: `target-missing`, `id-unlinked`, `planning-drift`, `section-cell-oversized`, `span-unclosed`); keine aus dem Diff — Differenz zum Claim-Stand siehe unten.
- **Review durchgeführt, Report unter `docs/reviews/`: ERFÜLLT** (`51cfd1c0`, eigener Kontext, 1 HIGH/5 MEDIUM/1 LOW/2 INFO; Behebungszug danach, kein Self-Review).
- **Doku-Update (emitter-Doku, benutzerhandbuch, README): ERFÜLLT** — `docs/user/benutzerhandbuch.md` trägt die Kante (Host-Weg, dcheck-fetch einmalig Netz, Image-Weg als Weg-nicht-Pflicht) und nach F-5 die Diagnose-Grenze des geklonten Klon-Absatzes, nachdem die d-check-Ablage angelegt ist (Zeile 344), ferner die DCHECK_CARRIER-Umgebungsaufgabe mit Grenze (Z. 870).
- **Closure-Notiz mit Steering-Loop-Lerneintrag: OFFEN (Planner-Closure)** — §7 leer, wie geplant.
- **Beobachtungs-Register fortgeschrieben: OFFEN (Planner-Closure)** — §8 nennt die zwei Treffer (gemischtes Root, GNU-only-bats) unter der Schwelle; das Register wird bei der Closure bedient.
- **Jedes §6-Risiko trägt einen Ausgang: OFFEN (Planner-Closure)** — inhaltlich belegt: die zwei Risiken „Skelett-Toolchains" und „full-smoke" behalten ihre benannten Ausgänge; das dritte (Bootstrap-Henne-Ei des Carrier-Wegs, F-6) ist mit den Messungen dieses Laufs **weiter offen** — Ausgangs-Vorschlag unten.
- **Drei Paarungen: OFFEN (Planner-Closure)** — wie geplant der nächsten Welle-Closure zugeordnet.

## Verifikations-Beleg-Liste (Läufe dieses Laufs)

- **V-1** Rot-Zug `TestDocGateMk_FetchRezeptExportiertDiePins`: Rezept-Export-Zeile entfernt → `make test-go` → `--- FAIL: TestDocGateMk_FetchRezeptExportiertDiePins`; zurück → grün.
- **V-2** Rot-Zug `TestInventoryRows_SollTragtDenPinDesFragments`: Soll hart verdrahtet (`9.8.7` statt Pin-Ableitung) → `make test-go` → `--- FAIL: TestInventoryRows_SollTragtDenPinDesFragments`; zurück → grün. (Beide Rot-Züge je in demselben test-go-Lauf; die zwei bekannten Vorbestand-Klassen fielen daneben wie bisher.)
- **V-3** Fall-40-Sed am realen Bestand (Vorlauf-Begrenzung von `make mutate MUTATE_CASES=40-…` wegen der zwei vorbestehenden Klassen) → `make test-go` → **8 rot**, darunter der genannte Anker `TestDocGate_FragmentWiresDocsCheck` und die sieben Gates-Kette-Wächter, die dieselbe Zeile lesen; zurück → `git diff --quiet` clean.
- **V-4** `make mutate MUTATE_CASES=40-docgate-fragment-wiring` → Bruch im Vorlauf (die zwei vorbestehenden Klassen), Fall fuhr nicht — dokumentiert statt still übernommen.
- **V-5** LP2-Kette (siehe LP2 oben): `make host-bin` · Produkt-Binary-Bootstrap mit externem `DCHECK_CARRIER` (Exit 0) · d-check extern gelegt · `make gates` im Ziel → UMFELD-BEFUND an den zwei Soll-Abweichungen, Exit 1. Carrier nach dem Lauf am fetched Release-Stand zurückgestellt (`.harness/state/bin/ai-harness-init` = Release-Binary, wie vor dem Lauf).
- **V-6** `make docs-check-host` an HEAD → **106 Befunde, 3079 Datei(en)**; Worktree am Claim-Stand `ef1ac86f` → **106 Befunde, 3078 Datei(en)**; byte-Differenz der Befund-Einheiten: **genau drei Zeilenverschiebungen** im Slice-Plan (Z. 115→116, 126→127, 131→132), keine neue Kennung, keine neue Klasse; eine Datei mehr geprüft (der Review-Report). `make mutate-greift`-Anlagenkontext (794/796, Befunde 784/785) aus dem Review übernommen, vom Verifier nicht neu gefahren.
- **V-7** `make shell-lint` → rot an **vorbestehenden** Offendern (`gates-keys.sh` SC2254 ×4, `test/mutations/785` SC2016, Infos 797–801); **keine Meldung** in `test/mutations/40-…` (der behebungszug hat den Fall-Kopf lint-clean gelassen).
- **V-8** Bats-Seite (273/784/785): `git diff --name-only ef1ac86f..HEAD -- test/` → einzig `test/mutations/40-docgate-fragment-wiring.sh`; keine der drei genannten Fall-Klassen ist vom Diff berührt (code-level, nicht neu gefahren).
- **V-9** `make gates` an HEAD (Ende-Lauf) → Exit 2 an `docs-check-host`, 106 Befunde (vorbestehend, siehe V-6).

## Verifikation der Review-Findings (Behebungszug `9bd6f440..6cabbee6`)

- **F-1 (HIGH) — Fall-40-Kommentar in IST-Form: BESTÄTIGT.** Der Kopf trägt den ganzzeiligen `$`-Anker als Mechanik, keinen Prefix-Verlauf mehr; die Herkunft-Zeile nennt den entfernten Fall 21 ohne Herkunfts-Prosa (gelesen, V-3).
- **F-2 (MEDIUM) — exportierte Pin-Form: BESTÄTIGT** (Code + Rot-Beleg V-1; „Waechter rot gesehener Anlage" trägt am Wächter, der die export-Zeile hält).
- **F-3 (MEDIUM) — Identitäts-Wächter beidseitig: BESTÄTIGT** — `gleichZeilenweise` misst Mengen-Gleichheit und Zeile-für-Zeile; die appended-Zeile-Klasse ist geschlossen.
- **F-4 (MEDIUM) — Paarungs-Wächter Zeile↔Pin-Stelle: BESTÄTIGT** (`internal/gen/inventory_rows_test.go`, Rot-Beleg V-2); der F-4-Nachzug (`6cabbee6`) nennt die Paarungs-Datei in der Zeile der abgeleiteten Soll-Form (`internal/gen/golang.go:1097`).
- **F-5 (MEDIUM) — Klon-Zusage mit Diagnose-Grenze: BESTÄTIGT** (benutzerhandbuch:344).
- **F-6 (MEDIUM) — Carrier-Henne-Ei als Plan-§6-Risiko mit benannter Lücke: BESTÄTIGT** (Plan §6 trägt den Ausgangs-Vorschlag; Handbuch Z. 870 trägt dieselbe Grenze); die Lücke bleibt real — LP2 oben.
- **F-7 (MEDIUM) — Plan §3-Tabelle trägt die gen-Skelett-Zeile: BESTÄTIGT** (gelesen).
- **F-8 (INFO) — Reihenfolge-Grenze im emittierten Fragment-Kommentar: BESTÄTIGT** (`environment.go`, „Grenze der Reihenfolge" über der Präferenz-Zeile).

## Neuer Befund (aus dem realen LP2-Lauf, vom Verifier)

- **Klasse:** emittierte Soll-Form trägt das v-Pin-Präfix, die exakte Prüfform kann es nicht treffen
- **Pfad:** `internal/gen/golang.go:1098` (`"golangci-lint|exakt|pflicht|abgeleitet:" + golangciVersion + "…"` mit `golangciVersion = "v2.15.0"`) · probe-Ausgabe des emittierten Check-Skripts (`golangci-lint --version` → `2.15.0`, ohne `v`)
- **Befund:** Das emittierte Inventar leitet das Soll von der Pin-Stelle ab, die das **Modul-Tag** (`v2.15.0`) trägt; die exakte Prüfform vergleicht gegen die **Version-Ausgabe** des Werkzeugs (`2.15.0`). Der Lauf im gebootstrappten Ziel fasst beide an einem Werkzeug zusammen: even mit dem exakt gepinnten Werkzeug installiert bleibt `golangci-lint exakt` rot — die Soll-Form ist von keinem Host-Träger erreichbar. Das Dogfood leitet dieselbe Zeile **v-frei** ab (`harness/tools/environment-inventory.txt` Z. 29: `abgeleitet:2.15.0` bei Pin `v2.15.0`, Makefile:23) — dort ist `make environment-check` grün. Die Kopplung trägt: der Paarungs-Wächter (`TestInventoryRows_SollTragtDenPinDesFragments`) hält Zeile↔Pin **intern** konsistent und bleibt darum grün; die Auswirkung im Ziel trägt kein Wächter (AGENTS §3.6, Wächter über nachgebauter Eingabe). Der reale Lauf (V-5) ist der Rot-Beleg.
- **Verifizierbar:** ja — gebootstrapptes Ziel (Carrier extern), `make gates` → `umgebung: golangci-lint · Soll: v2.15.0 · Ist: 2.15.0`.
- **Rang-Vorschlag:** MEDIUM (Plan-vs-Code: LP1 Inventar-Emittierung × LP2 out-of-the-box); Scoping beim Planner-Closure.

## Risiken aus §6 — Ausgangs-Vorschläge für die Planner-Closure (Urteil ist Planner)

- **Skelett-Toolchains (K/J/P/C):** unverändert benannt (kein K/J/P/C-Fragment im Diff umgestellt, `InventoryRows` liefert `nil` mit benannter Begründung — der Paarungs-Wächter hält auch das) — Ausgang wie im Plan vorgesehen, formal in der Closure.
- **full-smoke fährt die emittierte Ebene:** unverändert; der Beleg bleibt bis zum Folge-Slice der manuelle Lauf (V-5).
- **Bootstrap-Henne-Ei des Carrier-Wegs (F-6):** **weiter offen → Beobachtungs-Register** (wie im Plan §6 vorgeschlagen); Adresse: eigener Mikroslice (Carrier-Besorgung im Bootstrap-Lauf, fail-closed an genau diesem Aufruf) oder der Weg in `welle-ohne-docker`. Die Messung dieses Laufs belegt die Lücke real (V-5, Schritt 2): Bootstrap lief, sobald der Carrier von außen kam, nicht out-of-the-box.

## Offene Posten für die Closure (Planner)

- **Neuer Befund** (v-Prefix-Soll-Form) — Scoping: Reparatur der Ableitung (v-stripping wie im Dogfood) **oder** Lücke am Ort benennen; Folge-Slice-Adresse benennen.
- **Mutations-Branch-Push (CI-Träger)** — der Implementer-Branch läuft auf dem veralteten Tip (`e41cf3c5`); der CI-Lauf müsste auf dem neuen Tip fahren (`make mutate-auswahl` am `6cabbee6`). Kein Push, kein Netz-Zug — Träger CI; Fall-40-Rot-Beleg trägt am realen Quell-Lauf (V-3).
- **Praeferenz-Zusage ohne Fall-Anlage (Review INFO)** — Fall nachziehen oder Lücke am Ort benennen; der Rot-Zug des Wächters fuhr nicht.
- **Fall-273-Präzedenz + F-1-comment-Grenze** (Vorbild-Run) — nichts still übernommen: nicht berührt, keine Präzedenz dieses Sllices.
- **LP2-Träger-Form** — vollgrüner Lauf braucht einen Host, der die Pins exakt trägt (go 1.27.3; golangci v-frei erkannt) **und** die zwei externen Besorgungen Carrier/d-check; Träger CI mit passender Matrix, im Dogfood solange `out-of-the-box` als Ziel-Form steht.
- **Die 5 vorbestehenden Rot-Klassen** (dok-check 106, bats 273/784/785-Klassen, shell-lint SC2254/SC2016, test-go Stop-Hook/GO-Profile) — tragerseits zuständige Rollen, wie im Vorbild-Bericht; keine aus dem Slice-Diff.
- **Räumung:** Worktree am Claim-Stand entfernt, tmp-Ziel entfernt, /tmp-Backups entfernt, Release-Carrier wiederhergestellt, Arbeitsbaum clean (`git status` leer).

## Fazit

LP1 erfüllt (bei Grenze der Soll-Form-Ableitung), LP2 real gefahren, nicht grün — die Grenzen sind benannt, eine (`v-Prefix`-Soll-Form) ist ein neuer Befund, der in keiner Vorbestand-Klasse liegt; LP3 für Fall 40 bestätigt (rot, real, zurück), die Fall-Anlage-Lücke der Präferenz-Zusage trägt weiter offen; `make gates` rot ausschließlich an den vorbestehenden Klassen, Differenz zum Claim-Stand exakt die drei planseitigen Zeilenverschiebungen, kein zusätzlicher Befund. Der Slice wird dem Planner mit zwei offenen Posten (neuer Befund, CI-Branch am neuen Tip) zur Closer-Entscheidung übergeben.
