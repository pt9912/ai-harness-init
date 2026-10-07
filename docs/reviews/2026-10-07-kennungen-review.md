# Review — slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen

**Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md`) · **Datum:** 2026-10-07 ·
**Gegenstand:** `c5bc8656`, `445efe8c`, `54b5b37e` gegen den Slice-Plan
(`docs/plan/planning/in-progress/`), [`MR-057`](../../harness/conventions.md#mr-057),
[`MR-059`](../../harness/conventions.md#mr-059), [`MR-071`](../../harness/conventions.md#mr-071),
`ADR-0058`/`ADR-0059` (Träger-Fetch), [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7.

**Summary:** 1 HIGH · 0 MEDIUM · 0 LOW · 3 INFO. Klasse des HIGH: *Grenzen-Aufzählung einer
erkennenden Regel ohne Formen-Probe*.

## Findings

### HIGH-1 — Das Muster erkennt drei Ziffernformen, die Aufzählung nennt sie als „die Kennungen dieses Repos in Ziffernform"

- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6; Skill §LOW/INFO mit Eskalation, *Grenzen-Aufzählung
  ohne Formen-Probe* (Eskalation auf HIGH: kein Gate meldet die Folge)
- **pfad:** `cmd/ai-harness-init/kennungen_test.go:14-17` (Kommentar zu `kennungMuster`) und `:85-86`
  (`GRENZE` im Testkopf)
- **befund:** Der Kommentar nennt `ADR-NNNN`, `LH-XX-NN`, `MR-NNN` als „die Kennungen dieses Repos in
  Ziffernform"; dieses Repo führt weitere Ziffernformen (`SPEC-NNN`, `CO-NNN`, `slice-NNN`,
  `welle-NN`) und Namensformen (`slice-<name>`, [`MR-057`](../../harness/conventions.md#mr-057)). Die
  `GRENZE` im Testkopf nennt nur Lauf-Varianten, nicht die Form-Grenze. Failure-Szenario: ein
  emittierter Kommentar mit `(SPEC-024)` oder `· seit slice-<name>` bleibt unter dem Test, dessen Name
  „tragen nur im Ziel auflösende Kennungen“ sagt, grün, und kein anderes Gate meldet ihn. Heute liegt kein
  solcher Fund vor (Probe unten) — der Pfad ist offen, nicht belegt. Der Plan §1 grenzt das Ziel auf
  dieselben drei Formen ein; das Problem ist also, dass die Grenze dort, wo der Test gelesen wird,
  nicht genannt ist, und nicht, dass vom Plan abgewichen wurde.
- **verifizierbar:** ja — Probe-Test in einer Klon-Kopie mit erweitertem Muster
  (`SPEC-|CO-|slice-NNN|slice-<name>|welle-NN|BEO-`), fünf Varianten inkl. add-lang im
  Unterverzeichnis: 68 Funde, davon 0 in den zusätzlichen Formen; alle `slice-*`-Funde sind
  Falsch-Positive (`slice-mv`, `slice-lokal`, `slice-a-b`) — `slice-<name>` ist mit einem einfachen
  Muster also nicht erkennbar, `SPEC-`/`CO-`/`slice-NNN` wären es ohne Fund.
- **klasse:** Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe

### INFO-1 — Laufzeit-Meldungen des Werkzeugs tragen weiter Kennungen; die Grenze steht nur im Testkopf

- **quelle:** Plan §1 Ziel („keine emittierte Meldung“) gegen DoD 1 („Meldungen aller emittierten
  Dateien“)
- **pfad:** `internal/emit/emit.go:142` (`LH-QA-01`), `internal/emit/enforce.go:482` (`ADR-0007`),
  `internal/fetch/baseline.go:131/141/402` (`LH-QA-02`, `LH-QA-03`, `MR-007`),
  `cmd/ai-harness-init/vendor_baseline.go:92` (`MR-007`), `addLangUsage` in `main.go` (`ADR-0009/ADR-0010`)
- **befund:** Diese Meldungen sieht der Anwender im Ziel. Ihre Kennungen lösen dort nicht auf. DoD 1 bindet nur
  Dateien. Der Testkopf nennt die Grenze („die Meldungen, die der Träger zur Laufzeit ausgibt“, der Träger ist
  dasselbe Binary); Plan §1 führt sie nicht unter den Ausschlüssen. Damit ist sie korrekt benannt, aber nur an einer Stelle,
  die die Closure nicht liest — Eingang für Risiko §6 Punkt 1.
- **verifizierbar:** ja — `git grep -nE '(Fprint|Errorf|Sprintf).*\b(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3})\b' -- 'cmd/**/*.go' 'internal/**/*.go' ':!*_test.go'`
- **klasse:** Grenze nur im Testkopf benannt

### INFO-2 — Wächter liegt in `cmd/ai-harness-init`, DoD 2 nennt `internal/emit/`

- **quelle:** Plan DoD 2
- **pfad:** `cmd/ai-harness-init/kennungen_test.go`
- **befund:** Die Abweichung trägt: nur über `run()` liest der Test auch die Emission aus
  `internal/gen` (Dockerfile, `go.mk`, `cpp.mk`, die `c5bc8656` mit ändert). Ein Test in
  `internal/emit` sähe sie nicht. Die Abweichung steht weder im Plan noch in einer Commit-Message —
  Übergabe an den Verifier/Planner, kein Implementer-Nachzug.
- **verifizierbar:** nein (Urteil)
- **klasse:** Plan-Abweichung ohne Übergabe-Vermerk

### INFO-3 — `d-check.mk` ist im Test eine Fixture

- **pfad:** `cmd/ai-harness-init/kennungen_test.go:116` (`docMKFixture`)
- **befund:** Der reale Inhalt kommt aus `d-check --print-mk`. Das ist Fremdtext wie die Baseline,
  wird aber anders als sie nicht in `kennungsAusnahme`/`GRENZE` genannt. Das ist folgenlos für die Zusage (kein Text dieses
  Werkzeugs) und betrifft nur die Vollständigkeit der Aufzählung.
- **klasse:** Grenze nur im Testkopf benannt

## Gefahrene Belege

- `make mutate MUTATE_CASES='558-emittierte-vorlage-traegt-erfundene-kennung 559-kennungs-ausnahme-gestrichen'`
  → EXIT 0, `2 ok, 0 Befund(e)`, beide → `TestEmittierteDateienTragenNurImZielAufloesendeKennungen rot`.
- Gegenprobe 558 (Klon-Kopie, Mutation angewandt, `t.Skip` **nur** im benannten Test,
  `go test -count=1 ./...` im `test`-Stage-Bild): alle Pakete `ok` — der benannte Test bindet allein.
- `make mutate MUTATE_CASES='360-fragment-ohne-klassen-satz'` → EXIT 0, `ok`. Beide `sed`-Anker treffen
  `internal/emit/templates/enforce/hooks-install.mk:10/16` ([`MR-071`](../../harness/conventions.md#mr-071)).
- `cmp harness/tools/traeger-fetch.sh internal/emit/templates/enforce/traeger-fetch.sh` → byte-gleich.

## Geprüft, ohne Befund

- **(a) Ersatz-Wortlaut:** alle 90 geänderten Zeilen von `c5bc8656` gelesen (`traeger-fetch.sh`,
  `traeger.mk`, `span-emit.sh`, `selbstpruefung.sh`, `record-gates.sh`, `hooks-install.mk`,
  `emit.go`/`makefile.go`, `golang.go`/`cpp.go`). Fast überall entfällt nur ein Klammer-Zusatz, und
  der Satz behält seine Zusage. Ein Fall ohne Klammer: `traeger-fetch.sh` „verifizieren (… die Dogfood-Hälfte
  bleibt am Makefile-Pin)“ entfällt ersatzlos, der Block „WOHER DER ERWARTETE DIGEST KOMMT“ trägt dieselbe
  Aussage. Ersetzt: „den ADR-0054 Festlegung 1 freistellt“ → „den skip-if-present freistellt“; „mit ADR-0059
  Folgepflicht 3 entfallen“ → „keine Digest-Variable, kein Export“. Keine Zusage ist verloren, keine neu
  hinzugekommen. Jede Meldung nennt weiter, was fehlt.
- **(b) Varianten-Deckung:** add-lang im Unterverzeichnis (go hexagonal/flat, cpp hexslice) per Probe
  gefahren: keine Kennung über der Ausnahme-Liste. Die `GRENZE` zu add-lang und Flag-Kombinationen ist zutreffend.
- **(c)** siehe Belege; kein Fall-Kopf behauptet Exklusivität.
- **(d)** byte-gleich, Fall 360 grün gebunden; kein anderer Mutations-Fall verankert `sed` auf einer
  entfernten Kennung.
- **(e)** siehe INFO-1.
- **§3.7:** die neuen Kommentare in `kennungen_test.go` beschreiben den Zustand; keine Chronik, keine
  Befund-Kennung.
