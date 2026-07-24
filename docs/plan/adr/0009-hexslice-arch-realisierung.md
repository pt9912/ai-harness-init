# ADR-0009: HexSlice als konkrete Realisierung der Architektur-Achse

**Status:** Proposed

**Datum:** 2026-07-24

**Autor:** Claude (Pair-Session)

**Bezug:** [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0008](0008-arch-achse-emittiertes-skelett.md), [ADR-0005](0005-ziel-repo-distribution.md)

**Verfeinert (nicht supersedet):** [ADR-0008](0008-arch-achse-emittiertes-skelett.md). Die dortige **Mechanik** (`--arch`-Achse, `lang-renderer × arch-layout`-Komposition, a-check emitted-only + konditional, Idempotenz-Klassen) gilt unverändert; ADR-0009 pinnt nur die **konkrete Realisierung** des schichten-tragenden Layouts.

**Schärft:** [`architecture.md`](../../../spec/architecture.md) (das konkrete hexSlice-Layout + die a-check-Config). Aufwärts-Deklaration: wer diese ADR ändert, zieht die betroffenen Anforderungen ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) und `architecture.md` nach.

---

## Kontext

[ADR-0008](0008-arch-achse-emittiertes-skelett.md) führte die **Architektur-Achse** `--arch` ein und
**skizzierte** das schichten-tragende Layout als „`hexagonal` (`domain/ports/adapters`)". Es benannte
zwei offene Punkte ausdrücklich: (a) die **reale Verfügbarkeit von a-check** (gepinntes Image mit
`--print-mk`) als **Vorbedingung**, (b) das Layout als grobe Skizze.

Beide Punkte sind jetzt **aufgelöst durch eine kanonische Referenz** (`hexslice-architecture`, Autor
pt9912— dieselbe Quelle wie d-check/a-check):

1. **a-check ist real und gepinnt.** `ghcr.io/pt9912/a-check@sha256:6425c93a9a4359ef28c4da231a2d1db6f421fdaa8f96877ac89d201827c42d09`
   (**v0.15.0**, Digest per `imagetools` verifiziert). `a-check --print-mk` erzeugt das `a-check.mk`-Fragment;
   der Lauf ist `docker run --network none -v …:ro <image> /src` — read-only, netzlos ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)/[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
2. **Das reale Layout ist „HexSlice" (Hexagonal + Vertical Slice), nicht die flache `domain/ports/adapters`-
   Skizze.** Der fachliche Kern (`hexagon`) trägt **Domain** + **Application als vertikale Use-Case-Slices**;
   **Adapter** (inbound/outbound) umgeben ihn; die Abhängigkeitsrichtung zeigt **nur nach innen**. a-check
   v0.15.0 prüft genau diese Regeln (die Release-Notiz nennt „HexSlice rules: lateral-slice & port-locality").

**Warum eine eigene ADR statt ADR-0008 zu ändern:** [ADR-0008](0008-arch-achse-emittiertes-skelett.md) ist
**Accepted → immutable** ([`AGENTS.md` §3.4](../../../AGENTS.md)). Die materielle Präzisierung (Achsen-Wert
`hexslice` statt `hexagonal`; reiches Layout; a-check-Pin + `.a-check.yml`-Schema) ist eine **Verfeinerung**,
die als neue ADR entsteht — die ADR-0008-**Mechanik** bleibt tragend.

**Tragende Annahmen** (kippen sie, kippt die Entscheidung):

1. **Die hexSlice-Referenz ist die kanonische Quelle** (Tool-als-Quelle, [ADR-0005](0005-ziel-repo-distribution.md)):
   der Go-Renderer leitet das Skelett aus dem realen `lab/examples/go`-Beispiel ab, nicht aus dem Nichts.
2. **a-check v0.15.0 bleibt verfügbar + digest-stabil** (wie d-check); ein Re-Pin folgt dem d-check-Muster.
3. **Das hexSlice-Layout trägt reale Schichten** → a-check hat einen nicht-leeren Prüfbereich
   ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); `flat` bleibt Default ohne a-check.

## Entscheidung

Das schichten-tragende Arch-Layout aus [ADR-0008](0008-arch-achse-emittiertes-skelett.md) ist **`hexslice`**
(nicht der Platzhalter „hexagonal"). Vier Festlegungen:

1. **Achsen-Wert `hexslice`.** `--arch flat` (Default, unverändert) | `--arch hexslice` (opt-in,
   schichten-tragend). „hexagonal" aus [ADR-0008](0008-arch-achse-emittiertes-skelett.md) war die Skizze;
   der kanonische Wert ist `hexslice` (Hexagonal + Vertical Slice).
2. **Konkretes Layout** (das der `hexslice`-Arch-Layout im Generator definiert; Rollen → Verzeichnisse):
   ```
   internal/hexagon/domain/<area>/            entity · value-object · domain-event · domain-service
   internal/hexagon/application/<area>/<usecase>/   command|query · handler · validator · result
   internal/hexagon/application/<area>/<usecase>/ports/   use-case-lokaler Port
   internal/hexagon/application/<area>/ports/        business-area-Port
   internal/hexagon/application/ports/              application-weiter Port
   internal/adapters/inbound/<typ>/<area>/    Use-Case-Entrypoint (CLI · API · Messaging)
   internal/adapters/outbound/<typ>/<area>/   Port-Implementierung (Persistenz · Notify · …)
   cmd/<binary>/main.go                       Composition Root (a-check-exempt)
   ```
   **Abhängigkeitsrichtung nur nach innen — die fünf erlaubten Kanten der kanonischen `.a-check.yml`
   (verbatim zu emittieren, Punkt 3):** `app→domain`, `app→ports`, `ports→domain`, `adapters→app`,
   `adapters→domain`. Domain→Application/Adapters ist **verboten**. **Keine `adapters→ports`-Kante:**
   Outbound-Adapter *implementieren* Ports über Go-Interface-Erfüllung (strukturell, **kein** Import) —
   verdrahtet im Composition Root (`cmd/**`, a-check-exempt). Die Bau-/Toolchain-Gerüstung
   ([ADR-0008](0008-arch-achse-emittiertes-skelett.md): `go.mod`/`Dockerfile`/`.golangci.yml`) bleibt
   **arch-invariant** — `hexslice` ersetzt nur den Code-Teil.
3. **a-check v0.15.0 gepinnt + `.a-check.yml`-Schema.** Bei `--arch hexslice` emittiert der Bootstrap
   `.a-check.yml` (Schichten `domain`/`app`/`port`/`adapter` mit Globs + erlaubten `edges` + `composition_root:
   cmd/**` + `exclude` Tests) und `a-check.mk` (aus `a-check --print-mk`, Image **digest-gepinnt** auf
   `sha256:6425c93a…`). Bei `flat` **kein** a-check ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), wie [ADR-0008](0008-arch-achse-emittiertes-skelett.md)).
4. **Tool-als-Quelle aus der Referenz.** Der Go-hexSlice-Renderer + die `.a-check.yml`/`a-check.mk`-Vorlagen
   leiten sich aus dem realen `lab/examples/go`-Beispiel der `hexslice-architecture`-Referenz ab (ein
   lauffähiges Bestell-Domänen-Skelett) — nachvollziehbar, nicht aus dem Nichts
   ([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), wie das flache Skelett). Der emittierte Fachbezug (z. B. „order") ist ein
   **adaptierbarer Marker**, kein fixer Inhalt.

## Verglichene Alternativen

<!--
Mindestens drei Optionen mit Pro/Contra. Alternativ "nichts tun" ist
auch eine Option.
-->

| Option | Pro | Contra |
|---|---|---|
| A — **ADR-0008 als „hexagonal/domain-ports-adapters" wörtlich nehmen** | keine neue ADR | verfehlt die kanonische Referenz (hexSlice ist reicher); a-check v0.15.0 prüft HexSlice-Regeln, nicht die flache Skizze → das emittierte Gate passte nicht zum emittierten Layout |
| B — **ADR-0008 editieren** (Wert/Layout anpassen) | ein ADR | **verboten** — [ADR-0008](0008-arch-achse-emittiertes-skelett.md) ist Accepted/immutable ([`AGENTS.md` §3.4](../../../AGENTS.md)) |
| C — **eigene Achse neben `--arch`** (z. B. `--slice`) | trennt Hexagonal von Vertical-Slice | künstlich — hexSlice ist **ein** Architektur-Stil (a-check prüft ihn als Einheit); zwei Achsen für einen Belang |
| **D — gewählt: verfeinernder ADR-0009, Wert `hexslice`, Layout + a-check-Pin gepinnt** | ehrt die immutable ADR-0008 (Mechanik bleibt) und pinnt die konkrete Realität aus der Referenz; a-check-Gate passt zum Layout | eine zweite ADR zum selben Belang (Lese-Kette 0008→0009); der Renderer trägt ein reiches Rollen-Set |

## Konsequenzen

<!--
Was folgt aus der Entscheidung? Sowohl Positives als auch Schmerzen.
Was wird leichter, was schwerer.
-->

- **Positiv:** Die ADR-0008-Vorbedingung (a-check real) ist **eingelöst** → [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)/M4 ist
  konkret baubar. Das emittierte `.a-check.yml` bildet das emittierte Layout ab (Gate passt zum Skelett).
  Der Renderer ist **referenz-geerdet** (Tool-als-Quelle), kein erfundenes Layout. `flat` unberührt.
- **Negativ:** Ein reiches Rollen-Set (Domain-Entity/VO, Use-Case-Slice mit command/handler/validator/result,
  lokale/geteilte Ports, inbound/outbound-Adapter, Composition Root) — der Go-Renderer ist deutlich größer als
  das flache Skelett (Slice-Scope: die Welle re-sliced ihn). Zwei ADRs zum selben Belang (0008-Mechanik +
  0009-Realisierung). Der emittierte Fachbezug („order") ist ein Beispiel-Domänen-Marker, den der Adopter
  ersetzt — er darf nicht als vorgeschriebene Fachlichkeit missverstanden werden.
- **Folgepflicht:**
  - **CR an [`lastenheft.md`](../../../spec/lastenheft.md):** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) Architektur-Wert `hexagonal`→`hexslice` + das
    konkrete Layout; [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) Happy-Path auf `--arch hexslice` + den a-check-v0.15.0-Pin.
  - **[`architecture.md`](../../../spec/architecture.md)-Nachzug:** das hexSlice-Layout (Rollen/Verzeichnisse) + die a-check-Config-Emission.
  - **Welle-Re-Slice** (die [ADR-0008](0008-arch-achse-emittiertes-skelett.md)-getriebene welle-07): slice-045 → **045a**
    (hexSlice-Arch-Layout + Go-Rollen-Renderer) + **045b** (`--arch`-CLI-Achse); slice-046 (a-check-Emitter) mit dem
    jetzt realen Pin.

## Fitness Function (falls maschinell prüfbar)

<!--
Wenn die Entscheidung sich in einer prüfbaren Eigenschaft des Codes
niederschlägt: hier die konkrete Regel benennen. Beispiel:
"depguard verbietet Import von internal/runtime aus internal/service."
-->

| Tooling | Regel | Make-Target |
|---|---|---|
| `make full-smoke` | `add-lang go <pfad> --arch hexslice` → das Skelett trägt `internal/hexagon/{domain,application}` + `internal/adapters/{inbound,outbound}` + `cmd/<binary>`, `.a-check.yml` + `a-check.mk` liegen, `make a-check` ist Exit 0 (a-check v0.15.0 gegen das reale Layout) | `make full-smoke` |
| `make full-smoke` | `--arch flat` → **kein** `.a-check.yml`/`a-check.mk`, `make gates` grün ohne a-check ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) | `make full-smoke` |
| `go test` | die emittierte `.a-check.yml` deklariert genau die Schichten/Kanten, die das emittierte Skelett trägt (Kopplung Layout ↔ Config; eine Drift färbt rot) | `make test` |
| `a-check` (im Ziel) | die inward-only-Kanten halten: ein `domain→application`-Import im emittierten Skelett wäre `wrong-direction` (a-check rot) — das Skelett selbst ist a-check-konform | `make a-check` (Ziel) |

## Re-Evaluierungs-Trigger

- Wenn **a-check** ein neues Release bringt, das die HexSlice-Regeln/das `.a-check.yml`-Schema ändert
  (Re-Pin + Schema-Nachzug, dem d-check-Muster folgend).
- Wenn die `hexslice-architecture`-Referenz ihr Layout ändert (der Renderer ist referenz-geerdet).
- Wenn eine **zweite geschichtete Architektur** gebraucht wird (weiterer `--arch`-Wert) — dann je Wert ein
  belegter Bedarf + ein a-check-Config-Satz, kein spekulatives Layout.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-24 | Proposed (verfeinert [ADR-0008](0008-arch-achse-emittiertes-skelett.md) nach der kanonischen `hexslice-architecture`-Referenz + realem a-check v0.15.0) | dieser ADR |
| 2026-07-24 | Proposed überarbeitet nach 1. Review (KONFORM, 1 MEDIUM der ADR-0007-H2-Klasse: die Kanten-Aufzählung in Entscheidung 2 ließ `app→ports` aus — auf den vollständigen 5-Kanten-Satz der realen `.a-check.yml` korrigiert + die `adapters→ports`-Nicht-Kante begründet. 2 INFO nicht-blockierend) | [Review 1](../../reviews/2026-07-24-adr-0009-proposed-review.md) |

<!--
Nach Accepted: NICHT mehr inhaltlich überschreiben (Hard Rule aus
c-hsm-doc, siehe Kurs Modul 4). Spätere Schärfungen als neue ADR mit
"Supersedes ADR-NNNN" anlegen.
-->
