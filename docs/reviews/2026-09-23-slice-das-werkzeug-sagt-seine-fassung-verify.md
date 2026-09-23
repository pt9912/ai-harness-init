# Verifikation `slice-das-werkzeug-sagt-seine-fassung`: DoD 1 bis 3 erfüllt, beide Ausgänge live gemessen, Fall 400 nacheilend rot, Fall 403 gezielt rot — Restposition F-3 und zwei Übergaben an den Planner

**Rolle:** Verifier · **Datum:** 2026-09-23 · **Geprüfter Stand:** `e3b0ae026ad130bc87b7b2f6fd9fb3e0d68e8c5e` (=`HEAD`, Arbeitsbaum vor diesem Bericht sauber; Kette `05ded93c` Umsetzung → `255af105` Review → `0ec701ce` Fix-Runde F-1/F-2/F-4 → `e3b0ae02` Planner F-5). **Verifikations-Art:** DoD- und ADR-Konformität gegen den tatsächlichen Baum (`v6.9.0` · `regelwerk/modul-11-verification.md`). Das ist kein Review. **Modell:** `glm-5.3-flash[1m]`.

**Eingang:**

- der Slice-Plan `slice-das-werkzeug-sagt-seine-fassung` §1 bis §8, Stand im Pfad `in-progress/`;
- der Review-Report vom 2026-09-23 (Verdikt: kein Merge-Blocker, 2 MEDIUM, 3 LOW, 1 INFO). Er ist als Kontext gelesen, nicht als Beleg: jede Substanz-Aussage unten beruht auf einem eigenen Lauf dieses Berichts;
- [`ADR-0063`](../plan/adr/0063-das-werkzeug-sagt-seine-fassung.md) (*Proposed*), [`ADR-0058`](../plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (*Accepted*), [`ADR-0059`](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (*Accepted*), [`MR-048`](../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).

---

## 1. Ergebnis je DoD-Punkt

| DoD-Punkt | Status | Beleg |
|---|---|---|
| **(1)** — `ai-harness-init --version` meldet die Fassung oder ihren Fehlt-Fall laut | **erfüllt** | §2.1 — **beide Ausgänge live gemessen** am selbst gebauten Träger: mit Kontext Exit 0 und der **übergebene** Wert exakt auf stdout (nicht der Pin-Default `v0.2.2`); ohne Kontext Exit 2, stdout leer, der dokumentierte Wortlaut auf stderr. Der gemessene Wortlaut ist byte-identisch mit dem Quelltext (`cmp`, §2.1). Rot: Fall 399 vom Reviewer live rot (Meldung gelesen, richtige Ursache), Fall 400 von diesem Lauf nacheilend rot (§2.3) |
| **(2)** — der Release-Bau injiziert die Fassung | **erfüllt** | §2.2 — die Kette Makefile-Rezepte → Dockerfile-`ARG` → `release.yml` geprüft; der `ldflags`-String bleibt ohne Wert exakt `-s -w` (Expansion hermetisch geprüft, §2.2). Der Live-Vergleich zweier Bauten auf Byte-Gleichheit hängt — wie beim Reviewer — an den artifact/smoke-Zähnen des frischen Gates-Stempels, nicht an einem eigenen Lauf |
| **(3)** — Doku-Nachzug (Weg A, B und C) | **erfüllt** | §2.1/§2.6 — Weg A (`benutzerhandbuch.md:118`) und Weg B (`:151`) tragen den Wortlaut **verbatim** samt **Exit 2**, byte-gleich mit dem Quelltext; Weg C trägt die Fassungs-Erkennung (`:157`, Formel und Digest bleiben die zwei Beleg-Wege daneben — [`ADR-0059`](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Festlegung 3). F-4 gezogen: die Meldung nennt keine repo-interne Referenz (`grep 'ADR' version.go` auf den Meldungs-String → leer); Referenzen hält `docs-check` im frischen Gates-Lauf |
| `make gates` grün | **erfüllt, nicht erneut gefahren** | Auftrag. Aufzeichnung `.harness/state/gates-passed.diffsha` = `413a3498…3c`; `harness/tools/working-tree-hash.sh` liefert über dem geprüften Baum denselben Hash — die Aufzeichnung deckt den geprüften Stand (§2.5) |
| Review, Report unter `docs/reviews/` | **erfüllt** | `docs/reviews/2026-09-23-slice-das-werkzeug-sagt-seine-fassung.md` (kein Blocker). Als Kontext gelesen, nicht als Beleg |
| Doku-Update (Weg C; Release-Text des nächsten Schnitts) | **erfüllt** | Weg C trägt die Erkennung (`benutzerhandbuch.md:157`); der Release-Text des nächsten Schnitts ist **Vorbedingung (§4)**, nicht Gegenstand dieses Slice |
| Closure-Notiz, Register, Risiko-Ausgänge, drei Paarungen | **nicht geprüft — Planner** | Closure-Pflichten ([`AGENTS.md`](../../AGENTS.md) §3.10); die Belege für die Risiko-Ausgänge stehen in §5. |
| Reconciliation-Register | entfällt | wie im Plan begründet — die Datei führt dieses Repo nicht |

## 2. Eigene Messungen

Alle Läufe über `make`, `docker` und `git` ([`AGENTS.md`](../../AGENTS.md) §3.9), gegen den sauberen Arbeitsbaum am Stand `e3b0ae02`. Nach jedem Mutationslauf: `git checkout -- <datei>`, `git status --porcelain` leer. Keine Zahl ist ein Erwartungswert.

### 2.1 DoD (1) — beide Ausgänge, selbst gebaut und gemessen

```sh
make host-bin TRAEGER_VERSION=v9.9.9-verif     # (a) Bau mit gesetztem Kontext
.harness/state/bin/ai-harness-init --version   # exit=0 · stdout 13 B "v9.9.9-verif\n" · stderr 0 B
make host-bin                                  # (b) Bau ohne Kontext
.harness/state/bin/ai-harness-init --version   # exit=2 · stdout 0 B · stderr 134 B (Wortlaut)
```

- **(a)** meldet **exakt den übergebenen Wert** `v9.9.9-verif` — nicht den Pin-Default `v0.2.2` des Makefiles (`TRAEGER_TAG ?= v0.2.2`, Zeile 45; der 403-Wächter hält, dass kein Rezept ihn liest, §2.2). Exit 0, stderr leer.
- **(b)** meldet auf stderr (stdout leer, Exit 2):

  ```
  ai-harness-init: keine Fassung injiziert — dieser Bau traegt keinen geschnittenen Tag; die Fassung kommt nur mit einem Release-Bau.
  ```

  `cmp` gegen `const versionFehltMeldung` aus `cmd/ai-harness-init/version.go` → **byte-identisch** (inkl. Zeilenumbruch). Die Meldung trägt den Pin-Stand nirgends — der Fehlt-Fall ist **nicht** die erfundene Zahl und nicht leer (`Exit ≠ 0`, [`ADR-0063`](../plan/adr/0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 2).
- **Messqualität (1a)/(1b):** der (1b)-Bau traf den Docker-Cache (`DONE 0.0s`), der (1a)-Bau übersetzte neu — die zwei Messungen liefen auf **getrennten Cache-Schlüsseln** und liefen **differierend** aus; wäre der Schlüssel arg-unempfindlich, hätte (1b) die `v9.9.9-verif`-Binary aus dem (1a)-Lauf geliefert. Der Cache-Schlüssel trägt den `--build-arg`-Wert — dieselbe Lage, die [`MR-050`](../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt) für `host-bin` deklariert.

### 2.2 Bewusstes Brechen — Fall 403 (`fassungs-pin-default`), F-2-Nachweis, gezielt rot

Verfahren nach der Fall-Datei (`verify: test-bats`):

```sh
sed -i '/^TRAEGER_TAG ?= /a\TRAEGER_VERSION ?= v0.2.2' Makefile   # Mutation sitzt (sed -n 45,47p: 3 Zeilen)
docker run --rm --network none -v $PWD:/code:ro -w /code $(BATS_IMAGE) \
  test/release-matrix.bats --filter 'Fassung|TRAEGER_VERSION'
git checkout -- Makefile                                          # Baum sauber
```

`1..3` — **ok 1** (Operand), **ok 2** (Durchreichung), **not ok 3**:

```
not ok 3 release: TRAEGER_VERSION traegt keinen Default im Makefile
# TRAEGER_VERSION hat eine Default-Zuweisung — die Fassung kommt aus dem uebergebenen
# Kontext, nie aus dem Pin-Default; ein Bau ohne uebergebenen Wert injiziert nicht,
# sonst waere der Fehlt-Fall unerreichbar: TRAEGER_VERSION ?= v0.2.2
```

- **Rot aus dem richtigen Grund:** die Meldung zitiert die eingeschleuste Zeile und die in der Fall-Datei vorhergesagte Ursache (erfundene Zahl, Fehlt-Fall unerreichbar) — nicht irgendeine.
- **Die zwei Nachbar-Wächter blieben grün** unter derselben Mutation: Operand (`die build-Stage injiziert die Fassung aus dem uebergebenen Wert`) und Durchreichung (`die Bau-Rezepte reichen TRAEGER_VERSION an die build-Stage`) — die Mutation trifft ihre Gegenstände nicht; der Fall wird **nur** vom benannten Wächter gefangen („bindet", [`AGENTS.md`](../../AGENTS.md) §3.6).
- **Der unveränderte Bestand schweigt:** am unmutierten Makefile zählt `grep -cE '^TRAEGER_VERSION[[:space:]]*[-?+:!]*=[[:space:]]*[^[:space:]]'` → **0**; der Wächter stand im frischen Gates-Lauf grün.
- Die Referenz-Form aus der Fall-Datei (`TRAEGER_VERSION ?= $(TRAEGER_TAG)`) fällt an derselben Zeile desselben Wächters — der Fall deckt die Klasse, nicht nur das Literal.

### 2.2a Fall 400 (`fassung-meldet-falschen-wert`) — nacheilender Rot-Beleg

DoD (1) nennt zwei Mutations-Fälle; Fall 399 war vom Reviewer live rot (§2.2a unten), Fall 400 war von keinem Lauf rot gesehen. Nach Modul 11 (§Bewusstes Brechen für DoD-Testbehauptungen) trägt dieser Lauf ihn nach:

```sh
sed -i 's|fmt.Fprintln(stdout, fassung)|fmt.Fprintln(stdout, "v0.0.0-fest")|' cmd/ai-harness-init/version.go
make test-go      # exit 2
git checkout -- cmd/ai-harness-init/version.go   # Baum sauber
```

```
--- FAIL: TestVersionMeldetDieInjizierteFassung (0.00s)
    version_test.go:24: stdout meldet "v0.0.0-fest\n", want "v9.9.9-mutprobe\n" —
    der gemeldete Wert haengt an der Injektion, nicht an einer Konstanten
```

- Die Meldung kommt vom benannten Wächter (`expect:` der Fall-Datei) und trägt die behauptete Ursache (Konstante statt Injektion); nur `cmd/ai-harness-init` fiel — `TestVersionFehltFallIstLaut` blieb unter derselben Mutation grün (kein FAIL-Eintrag im selben Lauf).
- Damit ist der zweite DoD-(1)-Rot-Verweis belegt; die vier übrigen Fälle (399, 401, 402, 403) sind ihrer Form nach gelesen, 403 live von diesem Lauf (§2.2).

### 2.2b Fall 399 — vom Reviewer live rot gesehen, hier nicht wiederholt

Der Review-Report führt den Live-Lauf mit der exakt vorhergesagten Meldung (`Exit 0 ohne Injektion, want 2 … stderr: ""`), nur der benannte Wächter fiel. Kein Nachbeleg, den ein anderer Lauf schon erbracht hat.

### 2.3 DoD (2) — die Injektions-Kette, statisch und hermetisch

| Glied | Beleg |
|---|---|
| Makefile-Rezepte | vier Rezepte reichen `--build-arg TRAEGER_VERSION="$(TRAEGER_VERSION)"` durch: `build` (Makefile:91), `artifact-host` (:118), `release-artifacts` (:146), `host-bin` (:387); **kein** Rezept berührt den Pin-Default |
| Dockerfile-`ARG` | `ARG TRAEGER_VERSION=` leer (Dockerfile:96); der Operand `-ldflags="-s -w${TRAEGER_VERSION:+ -X main.fassung=${TRAEGER_VERSION}}"` (:99) |
| `release.yml` | `TRAEGER_VERSION: ${{ github.ref_type == 'tag' && github.ref_name || '' }}` (`release.yml:64`) — Tag-Ref übergibt den Ref-Namen, **dispatch auf einem Zweig übergibt leer**; der `homebrew-formula-fill.sh`-Schritt liest dasselbe `GITHUB_REF_NAME` |
| Expansion (hermetisch) | `sh -c 'TRAEGER_VERSION=; printf "[%s]" "-s -w${TRAEGER_VERSION:+ -X main.fassung=${TRAEGER_VERSION}}"'` → `[-s -w]`; mit Wert → `[-s -w -X main.fassung=vX]` — der leere Wert lässt den `ldflags`-String **exakt** `-s -w` (byte-identischer Default-Pfad, [`MR-048`](../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)) |
| Form-Wächter | der byte-exakte bats-Grep auf den Operanden lief im gefilterten Lauf (ok 1, §2.2); der Byte-Vergleich zweier Bauten bleibt an den artifact/smoke-Zähnen im Gates-Stempel |
| `compile` un-injiziert | das Rezept (Makefile:157) trägt nur `--build-arg GO_VERSION` — die compile-Stage bekommt keinen Injektions-Wert |

### 2.4 DoD (3) — der Wortlaut an drei Stellen

```sh
grep -o 'const versionFehltMeldung = ".*"' cmd/ai-harness-init/version.go | …   # → /tmp/wortlaut-code.txt
cmp /tmp/wortlaut-code.txt /tmp/vf-err2.txt                                     # byte-identisch
grep -n 'keine Fassung injiziert' docs/user/benutzerhandbuch.md                 # → :118, :151
```

Weg A (`:118`) und Weg B (`:151`) tragen den Wortlaut verbatim samt Exit 2 — beide Fundstellen enthalten denselben String wie der Code-Konstanttext; Weg C nennt die Erkennung (`:116`, `:157`). F-4 gezogen: weder der Code-String noch die Handbuch-Fassungs-Stellen tragen eine `ADR`-Referenz (`grep -n 'ADR' version.go` trifft nur Kommentare, nicht die Meldung; `benutzerhandbuch.md:3` betrifft `--arch`, nicht die Fassung).

### 2.5 Closure-Trigger — beide Kriterien gemessen

1. `make gates` **nicht erneut gefahren** (Auftrag). Beleg: `.harness/state/gates-passed.diffsha` = `413a3498250d81bc09466334e6d19b7b75dd21225139eadb29744d63e679a53c`; `bash harness/tools/working-tree-hash.sh` über dem geprüften Baum liefert denselben Hash. Die zweite Hälfte (`ai-harness-init --version` meldet die Fassung aus dem übergebenen Wert, gemessen am Träger) ist selbst gefahren: §2.1 (a).
2. Der Fehlt-Fall ist **einmal laut gesehen** — von diesem Lauf: §2.1 (b), Exit 2, klare Meldung, stdout leer, Meldung gelesen; die Form trägt [`ADR-0063`](../plan/adr/0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 2 (dokumentierter Ausgang).

Danach zwei `make test-go`-Läufe und ein gefilterter bats-Lauf für die Rot-Belege; der Baum nach jedem Lauf zurückgesetzt und sauber.

## 3. Plan-vs-Code-Diff

`git show --stat` über die Kette: `05ded93c` (14 Dateien), `0ec701ce` (5), `e3b0ae02` (1). §3 des Plans nennt sieben Positionen; jede ist gebaut, keine weitere Datei liegt außerhalb:

| Richtung | Datei | Einordnung |
|---|---|---|
| geplant, gebaut | `cmd/ai-harness-init/version.go` (neu), `main.go` (update), `version_test.go` (neu) | der geführte Ausgang im Dispatch, Fehlt-Fall-Wortlaut mit Exit 2, die zwei Wächter — **F-6 offen**: die §3-Korrektur (Dispatch unter `cmd/`, nicht `internal/`) schrieb der Implementer im eigenen Commit (`05ded93c`, 7 Zeilen am Plan); der Planner bestätigt sie bei der Closure (Review-Verdikt nennt das bereits) |
| geplant, gebaut | `Makefile`, `Dockerfile`, `.github/workflows/release.yml` | eine Ursache, drei Stellen — die Injektions-Durchreichung (§2.3) |
| geplant, gebaut | `test/release-matrix.bats` | die drei Kopplungs-Wächter (Operand, Durchreichung, keine Default-Zuweisung) |
| geplant, gebaut | `test/mutations/399…403` | **fünf Fälle** — genau die fünf aus §3 (Fehlt-Fall, abweichender Wert, Injektion entfernt, Durchreichung, Pin-Default); 403 kam mit der Fix-Runde (F-2) nach |
| geplant, gebaut | `.golangci.yml` | die zentrale Lint-Ausnahme (`path:` auf `version\.go$` + `text: ^fassung is a global variable`, Why-Kommentar); **F-5 gezogen** — der Plan trägt die Zeile seit `e3b0ae02` |
| geplant, gebaut | `docs/user/benutzerhandbuch.md` | Weg A/B/C (§2.4) |

**Keine Datei gebaut, die §3 nicht nennt.** §1-Ausschlüsse gehalten: `test/traeger-fetch.bats`, `internal/`, die Formel-Mechanik und die `SHA256SUMS`-Erzeugung sind in keinem Commit der Kette.

## 4. ADR- und MR-Konformität (Substanz-Seite des Acceptance-Triggers)

Der Reviewer meldete kein blockierendes Befund an der Substanz; die Stichproben dieses Laufs halten alle drei Festlegungen am Code — die Reviewer-Runde zur ADR selbst bleibt eigener Vorgang.

| Quelle | Ergebnis | Beleg |
|---|---|---|
| `ADR-0063` Festlegung 1 | konform | Die Injektion liest den **übergebenen** Wert — live belegt (§2.1a: `v9.9.9-verif`, nicht der Pin-Default); kein Rezept berührt den Pin-Default (§2.3), und der 403-Wächter hält die Abwesenheit in beide Richtungen (§2.2); der Workflow übergibt den Tag-Ref, leer bei dispatch |
| `ADR-0063` Festlegung 2 | konform | Der Fehlt-Fall ist laut, Exit 2, stdout leer, byte-fester Wortlaut (§2.1b); geführter Ausgang im Dispatch **vor** dem Flag-Parsen (`main.go`, exakte `--version`/`-version`-Form; mit Zusatz-Argument fällt er durchs Flag-Parsen in die unbekannte-Flag-Sperre — Reviewer-Negativbefund, gelesen, nicht wiederholt); kein Fall im Init-Pfad |
| `ADR-0063` Festlegung 3 | konform | `test/traeger-fetch.bats` nicht im Diff (Pin-Achse unberührt); Formel- und `SHA256SUMS`-Mechanik nicht im Diff; der `ldflags`-String bleibt ohne Wert exakt `-s -w` (hermetisch, §2.3); `compile` und die emittierte Ebene (`internal/`) unberührt |
| `MR-048` | konform | gleiche Injektion, gleiche Bytes — der leere Wert fehlt als Operand, statt einen leeren zu setzen; der Byte-Vergleich hängt an den artifact/smoke-Zähnen des frischen Stempels |
| [`AGENTS.md`](../../AGENTS.md) §3.2 | konform | keine Inline-Suppression (`grep -n 'nolint' cmd/ai-harness-init/version.go` → leer); die Ausnahme steht zentral in `.golangci.yml:181-184`, verengt auf Datei **und** Bezeichner |
| [`AGENTS.md`](../../AGENTS.md) §3.6 | konform | drei der fünf Fälle live rot gesehen (399 Reviewer, 400 und 403 dieser Lauf), jeweils Meldung gelesen und gegen die Fall-Vorhersage geprüft; der unmutierte Bestand schweigt an allen drei Wächtern (Gates-Stempel) |
| [`AGENTS.md`](../../AGENTS.md) §3.9 | konform | alle Messungen über `make`/`docker`/`git`; der Host führt nichts zusätzlich |

## 5. Belege für die Risiko-Ausgänge (§6, an den Planner)

**Der Ausgang vergibt hier nicht** — der Planner trägt ihn in §7 ein; hier steht die Prüfperspektive je Risiko.

- **Risiko 1 (lokales Binary meldet den Pin-Stand).** Gemessen: der Bau ohne Kontext meldet den Fehlt-Fall, **nicht** `v0.2.2` (§2.1b); die Injektion hängt am übergebenen Wert (§2.1a). Belege sprechen für *entfallen* — die Form trägt `ADR-0063` Festlegung 2.
- **Risiko 2 (Injektion bricht die byte-identische Eigenschaft).** Der leere Wert lässt den `ldflags`-String exakt `-s -w` (hermetisch, §2.3), der (1b)-Bau lief auf dem Default-Pfad, und der Byte-Vergleich hängt unverändert an den artifact/smoke-Zähnen im frischen Stempel. Belege sprechen für *entfallen*; die Restgrenze (der Live-Vergleich war auch dem Reviewer nicht zugänglich) trägt der Stempel.
- **Risiko 3 (Formel liest die Fassung zweifach).** Kein Weg des Diffs greift in die Formel oder die `SHA256SUMS` ein; das Flag ist der dritte, belegende Ort (§2.4, Weg C). Belege sprechen für *entfallen*.

## 6. Befunde

| ID | Schwere | Befund | Beleg | Adresse |
|---|---|---|---|---|
| V-1 | LOW | **F-3 des Reviewers ist in der Fix-Kette nicht gezogen.** `harness/tools/homebrew-formula.rb.tmpl:3` trägt weiter „kein Wert reist im Binary" — seit `ADR-0063` Festlegung 1 reist genau **ein** Wert ins Binary (die Fassung als Release-Entscheidung); der Satz ist überbreit und liest sich als Verbot auch der Fassung. `grep -n 'kein Wert reist im Binary' harness/tools/homebrew-formula.rb.tmpl` → `:3`. | ADR-0063 Festlegung 1 | Planner: als Nachzug an den Implementer oder als Ausgang in der Closure-Notiz — die übrigen Fix-Commits (`0ec701ce`, `e3b0ae02`) trugen F-1/F-2/F-4/F-5, nicht F-3 |
| V-2 | INFO | **Die §3-Korrektur (F-6) ist noch nicht von der Planner-Rolle bestätigt.** Der Implementer-Commit `05ded93c` schrieb die Plan-Korrektur (Dispatch-Ebene `cmd/`) selbst; `e3b0ae02` trug nur die F-5-Zeile nach. | `git show --stat e3b0ae02` (1 Datei) | Planner: Bestätigung bei der Closure (Review-Verdikt F-6 nennt das bereits) |

**Kein Befund blockiert die Closure.** Kein Liefer-Punkt fehlt, keine §1-Grenze ist verletzt, keiner der im DoD genannten Mutations-Fälle bleibt ohne Rot-Beleg (399 Reviewer-live, 400 und 403 von diesem Lauf), beide Closure-Kriterien sind gemessen. V-1 ist die einzige offene Restposition eines Review-Findings und betrifft eine Skeleton-Kommentar-Zeile außerhalb des Diffs.

## 7. Gate-Lauf

`make gates` ist **nicht erneut gefahren** (Auftrag). Beleg für Closure-Trigger 1: die Aufzeichnung `.harness/state/gates-passed.diffsha` (`413a3498…3c`) deckt den Arbeitsbaum — `harness/tools/working-tree-hash.sh` liefert denselben Hash. Eigene Läufe dieses Berichts: zwei `make host-bin`-Läufe (§2.1), ein gefilterter bats-Lauf unter Mutation 403 (§2.2), zwei `make test-go`-Läufe unter Mutation 400 (§2.2a). Die `--version`-Messung (§2.1b) lief gegen den Fehlt-Fall-Bau im gitignorierten Zustands-Bereich — kein Einfluss auf den Baum-Hash.

## 8. Negativbefunde

- Der Arbeitsbaum war vor jedem Mutationslauf sauber und ist nach jedem `git checkout` wieder sauber; die einzige Änderung dieses Laufs ist dieser Bericht. Nach Mutation 403: `git status --porcelain` leer; nach Mutation 400: `grep -c 'v0.0.0-fest' cmd/ai-harness-init/version.go` → **0**.
- Die sed-Anker der zwei selbst gefahrenen Fälle trafen den Quell-Bestand (nach Anwendung nicht-leeres `git diff` bzw. sichtbarer Treffer) — kein stummer No-op ([`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
- Der 403-Wächter hält in beiden Richtungen: am unmutierten Bestand schweigt er (0 Treffer, grün im frischen Stempel), unter der Mutation fällt er mit der Meldung, die die Ursache trägt; die zwei Nachbar-Wächter blieben unter derselben Mutation grün („bindet").
- `test/traeger-fetch.bats`, `internal/`, `harness/tools/homebrew-formula*.sh`, die `SHA256SUMS`-Erzeugung und die emittierten Vorlagen sind in keinem Commit der Kette — alle §1-Ausschlüsse gehalten.
- Die `--version`-Messungen sind am **selbst gebauten** Träger gefahren (`make host-bin`), nicht am Fetch-Produkt — die Injektions-Semantik ist eine Bau-Ebene; der Release-Workflow übergibt denselben Wert-Kanal (`release.yml:64`), ein realer Tag-Dispatch ist kein Lauf dieses Kontexts (Grenze wie beim Reviewer).