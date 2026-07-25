# Verifier-Report slice-046 — konditionaler Arch-Gate-Emitter (a-check)

Rolle: Verifier (Modul 11). Frischer Kontext, **strikt read-only** — kein `make`-Lauf
(Schaden-Präzedenz F-12/slice-044: mutierender Subagent im Haupt-Tree). Commit `b853f73`,
Basis `4186c20`. Datum: 2026-07-25.

**Was ich unabhängig gemessen habe** (statt nachzufahren):
- `git show/diff/log`, Code-Lesen (`internal/{emit,gen,fetch}`, `cmd/…`, `harness/tools/full-smoke.sh`,
  `test/mutations/65…69`), Plan/ADR/Lastenheft-Abgleich.
- **Gate-Stempel gegen den Baum**: `harness/tools/working-tree-hash.sh` (read-only) liefert
  `2ea8a76c592a3be5a9bb40ce2c191ddc728276a628e625cc6b6e4b3a30c0f609` — **byte-gleich** mit
  `.harness/state/gates-passed.diffsha`. `record-gates` stempelt nur als letztes Prereq von
  `$(GATE_CHECKS)`; `make gates` lief also **auf genau diesem Baum grün** (`git status` clean).
- **Reale a-check-Inspektion** (< 60 s, netzlos, read-only):
  `docker run --network none ghcr.io/pt9912/a-check@sha256:6425c93a… --print-mk`.
- Logs: `fullsmoke3.log` (1852 Z.), mutate-Log (`65 ok, 0 Befund(e)`).

---

## DoD Punkt für Punkt

### 1. Wellen-Vorbedingung (Schritt 0): a-check real, Digest verifiziert, `--print-mk`, Lauf Exit 0 — **BESTÄTIGT** (Notat-Hälfte offen, s. Punkt 10)
- **Digest real:** `docker run` **per Digest** `sha256:6425c93a9a4359ef28c4da231a2d1db6f421fdaa8f96877ac89d201827c42d09`
  läuft — die Referenz löst gegen die Registry auf. Derselbe Digest steht byte-genau in der
  kanonischen Referenz `/Development/hexslice-architecture/lab/examples/go/a-check.mk:5` und in
  `internal/emit/archgate.go:22` (`DefaultArchDigest`).
- **`--print-mk` real:** von mir selbst ausgeführt, liefert das Fragment (Kopf + `A_CHECK_IMAGE ?=`
  + `.PHONY: a-check a-check-graph` + Recipes).
- **Lauf gegen das hexSlice-Skelett Exit 0:** `fullsmoke3.log:1100-1101`
  (`docker run … -v "/tmp/tmp.9kb3qHGaIK/apps/hex":/src:ro … /src` → `gesamt: 0 Befund(e)`)
  und `:1836-1837` (Root-Modul).
- **Fällt der Beleg nicht** → kein Welle-§5-Re-Scope nötig.
- Einschränkung: das **Ergebnis steht nicht im Slice** (§7 leer, nur in der Commit-Message) —
  siehe Punkt 10.

### 2. LH-FA-07 Happy Path: Artefakte liegen, `make gates` fährt a-check mit — **BESTÄTIGT**
- Artefakte: `harness/tools/full-smoke.sh:340-345` prüft `apps/hex/.a-check.yml`, `a-check.mk`,
  `harness/mk/arch-apps-hex.mk` real im Ziel; Unit-Deckung `TestRun_AddLangArchHexsliceEmitsArchGate`
  (main_test.go), `TestArchGate_WritesArtifacts` (archgate_test.go:108).
- **Zusammengeführter Gate, nicht Einzel-Target** (die Kern-Frage): `hex_out` ist die Ausgabe von
  `make -j -Otarget -C "$tmprepo_doc" gates` (`full-smoke.sh:321`), `hex_rc` muss 0 sein
  (`:323`), und der Mount-Beleg `apps/hex":/src:ro` wird **in dieser Ausgabe** gesucht (`:350`).
  Im Log steht die a-check-Recipe-Zeile mitten im `make gates`-Lauf zwischen `baseline-verify`
  und `d-check` (`fullsmoke3.log:1097-1103`). Damit ist belegt: a-check lief **im** `make gates`,
  nicht nur als erreichbares Einzel-Target.
- Verdrahtung: `emit.ArchGateMk` hängt `a-check` (Root) bzw. `a-check-<modul>` (Subdir) an
  `GATE_CHECKS`; der emittierte Aggregator hat `record-gates: $(GATE_CHECKS)` nach dem Include
  (`internal/emit/makefile.go:27/36`).

### 3. LH-QA-01 konditional: `flat` → kein Artefakt, `make gates` grün ohne a-check — **BESTÄTIGT**
- Code: `wireLang` ruft `emit.ArchGate` nur bei `gen.ArchGateConfig(lang, arch) → ok`
  (`cmd/ai-harness-init/main.go`); `ArchGateConfig` gibt `("", false)` für nicht-schichten-tragende
  bzw. sprach-fremde Kombinationen (`internal/gen/arch.go:88-94`), abgeleitet **strukturell** aus
  `archLayered` (trägt das Layout die Domain-Rolle?) statt aus einer zweiten Namensliste.
- Test: `TestRun_AddLangArchFlatEmitsNoArchGate` (Abwesenheit aller vier Pfade),
  `TestArchGateConfig_OnlyLayered` (6 Kombinationen inkl. `cpp+hexslice`, `go+onion`).
- full-smoke-Abwesenheit: `full-smoke.sh:357-366` — `harness/mk/arch-apps-{api,web}.mk`,
  `apps/api/.a-check.yml`, Root-`.a-check.yml` im Mono-Repo-Ziel **und** `a-check.mk`/`.a-check.yml`
  im flachen `--lang go`-Ziel dürfen nicht existieren.
- „grün ohne a-check": das flache Ziel `$tmprepo` fährt `make -j gates` Exit 0 (bestehende
  Sektion), und der Mono-Repo-Lauf ist Exit 0 mit a-check **nur** für `apps/hex`.

### 4. Zähne: verbotener Import färbt das emittierte Gate rot — **BESTÄTIGT (real gesehen)**
- `full-smoke.sh:371-393`: Blank-Import `_ "app/internal/adapters/outbound/notify"` in
  `apps/hex/internal/hexagon/domain/example/greeting.go`, dann `make -C … a-check-apps-hex`;
  `teeth_rc` **muss ≠ 0** sein **und** die Ausgabe `core-impurity|wrong-direction` tragen
  (zwei getrennte Prüfungen — „rot" und „rot aus dem richtigen Grund"), Import danach zurückgenommen.
- Beleg im Log: `fullsmoke3.log:1830-1832` —
  `internal/hexagon/domain/example/greeting.go:8: core-impurity: Kern importiert app/internal/adapters/outbound/notify`.
  Der Befund wird **gedruckt**, nicht nur behauptet (§3.6-konform).
- Einschränkung (kein DoD-Verstoß, s. Restrisiko R-2): rot wurde über die **Kern-Reinheit**
  (`core-impurity`) erzielt, nicht über die `edges:`-Liste (`wrong-direction`).

### 5. Kopplung Config ↔ Skelett (ADR-0009 Fitness-Function) — **BESTÄTIGT**
- `TestArchGateConfig_MatchesSkeleton` (`internal/gen/archgate_test.go:71-124`) generiert das reale
  hexSlice-Skelett und prüft **drei** Eigenschaften: (a) jede Produktionsdatei außerhalb `cmd/`
  fällt unter ≥ 1 Glob (kein Loch), (b) der spezifischste Glob liefert die **ausgeschriebene**
  Soll-Schicht (10 Pfade hart gelistet — nicht aus der Config abgeleitet, also kein
  Selbstbezug), (c) **jeder deklarierte Glob** ist für ≥ 1 reale Datei der spezifischste
  (kein Glob ins Leere → das ist LH-QA-01 eine Ebene tiefer, mechanisch).
- Ergänzend `TestArchGateConfig_CoversEveryLayeredCombo` (jede schichten-tragende (lang, arch) muss
  eine Config haben, aus dem realen Generator abgeleitet) und `TestArchGateConfig_ModuleRelative`.
- Rot-Gegenbeispiel real: Mutation `68-archconfig-kopplung` → `TestArchGateConfig_MatchesSkeleton` rot.

### 6. LH-QA-02: Pin auf den **erzeugenden**, nicht den gedruckten Digest — **BESTÄTIGT (unabhängig nachgemessen)**
- Ich habe die Prämisse selbst geprüft: das laufende Image `…@sha256:6425c93a…` **druckt**
  `A_CHECK_IMAGE ?= ghcr.io/pt9912/a-check@sha256:f1b8ff5e9e9ab2007d2ba88527c97f070a30fb9fe08da78b20f4be6c6b5505ac`.
  Der gedruckte Pin **hinkt real nach** — die Befund-1-Erzählung des Implementers stimmt, das
  Umpinnen ist kein Ritual.
- Mechanik: `AdaptArchMK` (`internal/emit/archgate.go:113-130`) ersetzt die Anker-Zeile durch
  `opts.RunRef()` (Digest sticht Tag, `emit.go:80-89`) und **bricht hart ab**, wenn Anker oder
  Pin nicht greifen — kein halb adaptiertes Fragment.
- Tests: `TestAdaptArchMK_PinsProducingRef` (Fixture druckt bewusst einen **anderen** Pin),
  `TestAdaptArchMK_UnknownFormat`, `TestRun_AddLangArchHexsliceEmitsArchGate` (das emittierte
  `a-check.mk` trägt den Fixture-Pin **nicht** und `DefaultArchDigest` **doch**).
- Rot gesehen: Mutation `66-archgate-pin` → `TestAdaptArchMK_PinsProducingRef` rot.

### 7. `make gates` grün · `make mutate` grün mit rot gesehenen neuen Wächtern — **BESTÄTIGT**
- `make gates`: **unabhängig belegt** über den Stempel-Abgleich (s. o.) — kein bloßes Zitat.
- `make mutate`: Log `65 ok, 0 Befund(e)`; die drei vom DoD verlangten Wächter je rot gesehen —
  `65-archgate-konditional → TestRun_AddLangArchFlatEmitsNoArchGate`,
  `66-archgate-pin → TestAdaptArchMK_PinsProducingRef`,
  `68-archconfig-kopplung → TestArchGateConfig_MatchesSkeleton`;
  zusätzlich `67-baseline-traversierbar → TestBaseline_TagDirTraversierbar` und
  `69-archgate-mount-scope → TestArchGateMk_RootAndScoped`.
- Die Mutationen brechen **Verhalten, nicht das Kompilat** (65 hält `cfg/ok` in Benutzung, 66 hält
  `s`/`i`, 69 ist dollar-frei verankert → SC2016) — die slice-045b-Lehre ist eingehalten.

### 8. `make full-smoke` belegt **beide** Richtungen — **BESTÄTIGT**
- hexslice: Artefakte + a-check im zusammengeführten `make gates` (Modul-scoped, Log :1100) **und**
  am Root (eigenes viertes tmp-Repo, `make a-check` Exit 0, Log :1836-1837).
- flat: vier Abwesenheits-Prüfungen im Mono-Repo-Ziel + zwei im flachen `--lang go`-Ziel.
- Schlusszeile `fullsmoke3.log:1851` + `full-smoke: OK` … Exit 0 (keine `FEHLER`-Zeile im Log).
- Nebenbefund korrekt eingeordnet: `Fehler: unbekannte Architektur "hexslice"; verfuegbar: flat`
  (Log :1095) ist der **erwartete** `cpp+hexslice`-Exit-2-Fall (`full-smoke.sh:310-315`), kein Defekt.

### 9. Doku-Nachzug (AGENTS.md §4 / harness/README.md §Sensors) — **BESTÄTIGT**
- `AGENTS.md:127` liegt in `## 4. Quality Gates`; `harness/README.md:49` liegt in
  `## Sensors (Feedback-Gates)`. Beide Stellen sagen jetzt dasselbe: der Dogfood ist **flach**,
  a-check hätte hier einen leeren Prüfbereich, **emittiert** wird es trotzdem (emitted-only),
  belegt in `make full-smoke` „nicht hier". Das ist eine **Präzisierung ohne Overclaim** — es wird
  kein Dogfood-Gate behauptet, und der Verweis auf den Beleg ist wahr.

### 10. Closure-Notiz mit Steering-Loop-Eintrag — **NOCH OFFEN (erwartet)**
- §7 des Slice ist leer, der Slice liegt in `in-progress/`. Regulär.
- **Mit-offen (Punkt 1, zweite Hälfte):** DoD-Punkt 1 verlangt „Ergebnis im Slice **notiert**".
  Der Schritt-0-Beleg (Digest/`--print-mk`/Exit 0 — inhaltlich von mir bestätigt) steht heute nur
  in der Commit-Message. Bei der Closure in §7 nachziehen, sonst ist der teuerste Beleg der Welle
  nur in der Git-Historie auffindbar. (Ungetickte `- [ ]`-Boxen sind Repo-Konvention auch in
  `done/`-Slices und **kein** Befund.)

---

## Plan (§3-Tabelle) gegen Code

| Geplant | Ist | Urteil |
|---|---|---|
| `internal/gen/arch.go` update — `ArchGateConfig(lang, arch)` | `ArchGateConfig` + `archLayered` + `archGateConfigs` | OK |
| `internal/gen/*_test.go` neu — Kopplungstest | `internal/gen/archgate_test.go` (4 Tests) | OK |
| `internal/emit/archgate.go` neu — `.a-check.yml` skip / `a-check.mk` + Fragment konvergent | exakt so (`writeSkipIfPresent` / 2× `writeFileMode`) | OK, ADR-0007-Klassen konsistent |
| `cmd/…/main.go` update — `wireLang` bekommt `arch`, konditional, Env-Overrides | so, ein Aufrufort für beide Eintrittspunkte; `A_CHECK_IMAGE`/`A_CHECK_DIGEST` im Usage-Text | OK |
| `internal/fetch/baseline.go` update — 0700 → 0755 | `os.Chmod(tmp, 0o755)` + `TestBaseline_TagDirTraversierbar` + Mutation 67 | OK |
| `harness/tools/full-smoke.sh` update — beide Richtungen + Zähne | so, plus eigenständiger Root-Modul-Fall | OK (mehr als geplant) |
| `test/mutations/NN-*.sh` neu — 3 Klassen | 5 Fälle (65–69), Superset der geplanten drei | OK |
| **nicht geplant** | `internal/gen/golang.go` (+68 Z., `goHexArchConfig`) | **Abweichung, sachlich richtig**: der Plan verortete die Config in `arch.go`; der sprach-**spezifische** Config-Text gehört zum Go-Renderer, `arch.go` hält nur die Landkarte `lang → arch → cfg`. Konsistent mit dem slice-044-Seam (Layout ≠ Sprachtext). Keine ungeplante *Funktion*. |

Nichts Geplantes fehlt. Kein ungeplantes Verhalten.

## ADR-Konformität

- **ADR-0009 Entsch. 1/2** (`hexslice`, inward-only): die emittierte `.a-check.yml` trägt die
  **fünf** kanonischen Kanten `app→domain`, `app→ports`, `ports→domain`, `adapters→app`,
  `adapters→domain` und **keine** `adapters→ports`-Kante — 1:1 gegen
  `/Development/hexslice-architecture/lab/examples/go/.a-check.yml:39-47` geprüft, inklusive der
  Begründung der Nicht-Kante. `composition_root: ["cmd/**"]` und `exclude: ["**/*_test.go"]`
  ebenfalls verbatim.
- **ADR-0009 Entsch. 3** (Schema + Digest-Pin `sha256:6425c93a…`): erfüllt; Pin identisch mit ADR-Text.
- **ADR-0009 Entsch. 4** (Tool-als-Quelle aus der Referenz): die Globs tragen **literale**
  Verzeichnis-Präfixe (`…/greet/**`, `…/greet/ports/**`), nicht `…/**/ports/**` — genau die
  Eigenschaft, die die Referenz (`.a-check.yml:6-12`) als Bedingung für `lateral-slice`/
  `port-locality` nennt; `matchGlob` im Test erzwingt sie eng (nur `prefix/**` matcht).
  Der Beispiel-Fachbezug ist von `order/createorder` auf `example/greet` adaptiert — zulässig
  („adaptierbarer Marker").
- **Fitness-Function-Tabelle (4 Zeilen):** Z. 1 (full-smoke hexslice + `make a-check` Exit 0) ✓,
  Z. 2 (flat → kein Artefakt, gates grün) ✓, Z. 3 (`go test` Kopplung) ✓, Z. 4 (verbotener Import
  → a-check rot) ✓ — **mit** der Nuance aus R-2 (rot via `core-impurity`, nicht via `wrong-direction`).
- **ADR-0008** (arch-invariante Bau-/Toolchain-Gerüstung, Idempotenz-Klassen): unberührt bzw.
  konsistent. **ADR-0003** (Docker-only): `printMK` ist der einzige neue Prozess-Aufruf, netzlos.
- **LH-QA-03**: keine neue Go-Abhängigkeit (`go.mod` unberührt); die Config wird im Test mit einem
  10-Zeilen-Zeilenparser statt einer YAML-Bibliothek gelesen — bewusst und kommentiert.

---

## Restrisiken / Befunde (keiner blockiert die DoD)

### R-1 (MEDIUM, verifier-only) — der include-once-Wächter kollidiert mit dem dokumentierten `A_CHECK_IMAGE`-Override
`emit.ArchGateMk` (archgate.go:56-58) schützt das `include a-check.mk` mit
`ifndef A_CHECK_IMAGE`. Dieselbe Variable ist im CLI-Usage als **bewusster Adopter-Override**
dokumentiert (`main.go`, „A_CHECK_IMAGE a-check-Tag-Referenz"). Ist sie in der Umgebung gesetzt,
überspringt make den Include — und im **Root**-Fall bleibt `GATE_CHECKS += a-check` auf ein
**nicht definiertes** Target zeigen: `make gates` bricht mit „No rule to make target 'a-check'"
ab (`makefile.go:36`: `record-gates: $(GATE_CHECKS)`). Der modul-scoped Fall degradiert dagegen
sauber (er definiert sein Target selbst und nutzt den Override wie gewünscht).
Kein Test/Sensor fährt mit gesetztem `A_CHECK_IMAGE`. Fix-Richtung: eigener Sentinel
(`ifndef A_CHECK_MK_INCLUDED` o. Ä., vom Fragment selbst gesetzt) statt der Nutzer-Variablen.

### R-2 (LOW) — die `edges:`-Liste ist nicht behavioral belegt
Der Zähne-Beleg feuert `core-impurity` (Kern-Reinheit). Die fünf `edges` — der größte
hand-adaptierte Block der Config — werden dadurch **nicht** geprüft: eine zu **permissive**
Kanten-Liste (eine Kante zu viel) bliebe grün und unsichtbar. Ein zweiter Zähne-Fall (z. B.
Import `internal/adapters/**` in `…/greet/handler.go` → `app→adapters` ist keine erlaubte Kante
→ `wrong-direction`) schlösse die Lücke. Die ADR-0009-Fitness-Zeile 4 nennt selbst
`wrong-direction` als erwartete Meldung.

### R-3 (LOW) — „`flat` bleibt Docker-/netzlos" ist nur code-gelesen
Die slice-037-Eigenschaft (der flache `add-lang`-Pfad braucht kein Docker) ist im Plan §6 als
Risiko benannt und im Code korrekt (kein `ArchGate`-Aufruf ohne Config), aber **kein** Sensor
kann sie widerlegen: `testSources` injiziert immer eine funktionierende `archMK`-Attrappe, und
full-smoke läuft ohnehin auf einer Docker-Maschine. Ein Test mit `sources{archMK: nil}` auf dem
flat-Pfad (ein Aufruf würde panicken) machte die Eigenschaft falsifizierbar.

### R-4 (INFO) — Root-hexSlice **und** Sub-Modul-hexSlice gleichzeitig ist ungetestet
Trägt das Root-Modul das Gate, mountet `a-check` `$(CURDIR)` — also auch `apps/hex`, dessen
Dateien unter den Root-Globs auf **keine** Schicht fallen. Der Slice-Trigger erlaubte
ausdrücklich, den Mono-Repo-Fall abzutrennen; heute belegt full-smoke die beiden Fälle in
**getrennten** tmp-Repos. Als offener Punkt notieren, nicht als Mangel.

### R-5 (INFO) — Root-Aggregator-Beleg ist ein Trockenlauf mit unspezifischem Marker
Für das Root-Modul belegt `make -n gates | grep -qF "a-check"` (`full-smoke.sh:418`) die
`GATE_CHECKS`-Verdrahtung. Der Suchstring steckt auch in der Image-Referenz derselben Recipe,
ist also nicht target-spezifisch; der **echte** zusammengeführte Lauf existiert nur für das
modul-scoped Gate (Log :1100). Für das Root-Modul wäre `make -n gates` + Grep auf die
Mount-Zeile (analog `:350`) der schärfere Marker.

### R-6 (INFO) — grünes a-check nennt keine Prüfmenge
a-check meldet nur `gesamt: 0 Befund(e)` (d-check meldet „12 Datei(en) geprüft, 0 Befund(e)").
Ein grüner a-check-Lauf **allein** kann „geprüft und sauber" nicht von „nichts geprüft"
unterscheiden. Heute wird die Lücke durch den Zähne-Beleg (Domain-Glob greift real) und
`TestArchGateConfig_MatchesSkeleton` (jeder Glob trifft ≥ 1 Datei) geschlossen — beides in
diesem Slice bewusst gebaut, also **kein** Mangel; als Sensor-Verbesserung (Datei-Zahl
assertieren) für die Steering-Loop vormerken.

### R-7 (INFO) — ADR-0009 listet `internal/hexagon/application/ports/`, die Config nicht
Entsch. 2 nennt den **application-weiten** Port-Ordner als Teil des Layouts. Das Skelett rendert
ihn nicht, also trägt die `.a-check.yml` keinen Glob dafür (und dürfte es nach Test-Eigenschaft
(c) auch nicht, ohne dass eine Datei dort entsteht). Legt ein Adopter ihn später an, fällt er
unter keine Schicht. Ein Satz im Config-Kopf („beim Anlegen eines application-weiten
Port-Ordners den Glob ergänzen") wäre die billige Absicherung.

---

## Gesamturteil

**DoD BESTÄTIGT.**

Alle acht sachlichen DoD-Punkte sind gedeckt, und die drei teuersten nicht durch Zitat, sondern
unabhängig: der **Gate-Stempel** entspricht dem aktuellen Baum (also lief `make gates` real auf
diesem Stand grün), der **gedruckte a-check-Pin** (`f1b8ff5e…`) weicht nachweislich vom
**laufenden** Digest (`6425c93a…`) ab — das Umpinnen ist notwendig, nicht dekorativ (LH-QA-02) —
und a-check lief **innerhalb** des zusammengeführten `make gates`, nicht bloß als erreichbares
Einzel-Target (die klassische Beleg-Lücke). Der Zähne-Beleg ist mit gedrucktem Befund im Log
sichtbar, die Konditionalität in beide Richtungen geprüft, die Kopplung Config ↔ Skelett durch
einen Test gehalten, der auch **leere** Globs verbietet (LH-QA-01 eine Ebene tiefer). Plan §3
und Code decken sich; die einzige Abweichung (Config-Text in `golang.go` statt `arch.go`) ist die
sachlich richtige Schichtung und keine ungeplante Funktion. ADR-0009 Entsch. 1–4 und alle vier
Fitness-Zeilen sind erfüllt, die fünf Kanten 1:1 gegen die kanonische Referenz.

**Vor der Closure zu erledigen:**
1. **R-1** (MEDIUM) beheben oder als bewusstes Restrisiko dokumentieren — ein Adopter, der den
   dokumentierten `A_CHECK_IMAGE`-Override exportiert, bricht sich sein Root-`make gates`.
2. DoD-Punkt 1, zweite Hälfte: den Schritt-0-Beleg in §7 des Slice notieren (heute nur Commit-Msg).
3. R-2/R-3 als `open/`-Folgepunkte schneiden (zweiter Zähne-Fall für `wrong-direction`;
   `archMK: nil`-Test für den Docker-freien flat-Pfad). R-4…R-7 als Backlog-Notizen.
