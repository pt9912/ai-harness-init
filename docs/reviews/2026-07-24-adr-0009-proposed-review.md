# Review — ADR-0009 (Proposed): HexSlice als konkrete Realisierung der Architektur-Achse

**Rolle:** Unabhängiger Reviewer (Modul 10 + Modul 4 ADR-Review, Proposed-Runde) · frischer Kontext, kein Selbst-Review.
**Datum:** 2026-07-24 · **Gegenstand:** `docs/plan/adr/0009-hexslice-arch-realisierung.md` (Status Proposed).
**Betrieb:** read-only (git/grep/cat), keine `make`-Läufe, keine git-Mutationen.

## Urteil: KONFORM — mit 1 MEDIUM (Truth-Accuracy, ADR-0007-H2-Klasse) vor Freeze zu schließen

ADR-0009 verfeinert ADR-0008 sauber, ist überwiegend referenz-treu, die Richtung trägt. Ein Faktum-Detail wich vom kanonischen `.a-check.yml` ab (MEDIUM-1, vom Autor aufgelöst).

## Verifiziert (referenz-treu, wörtlich geprüft)

- **a-check-Pin exakt:** `ghcr.io/pt9912/a-check@sha256:6425c93a9a4359ef28c4da231a2d1db6f421fdaa8f96877ac89d201827c42d09` steht byte-genau in `/Development/hexslice-architecture/lab/examples/go/a-check.mk:5` + `Makefile:20`; **v0.15.0** bestätigt (`README.md:41`), „HexSlice rules: lateral-slice & port-locality" real (`README.md:49/51`).
- **Layout** deckt sich mit der kanonischen Ordnerstruktur (`hexslice-architecture.de.md:84-120`): `domain/<area>/{entity·value-object·domain-event·domain-service}`, `application/<area>/<usecase>/{command|query·handler·validator·result}`+`ports/`, `application/<area>/ports/`, `application/ports/` (im Doc-Struktur-Block vorhanden, auch wenn das minimale Beispiel ihn nicht materialisiert — kanonisch gedeckt, nicht erfunden), `adapters/{inbound,outbound}/<typ>/<area>`, `cmd/<binary>/main.go` (`composition_root: cmd/**`).
- **`.a-check.yml`-Schema** (version/languages/layers domain·app·port·adapter/edges/composition_root/exclude `**/*_test.go`) trifft die reale Datei.
- **Naming `hexslice`** gerechtfertigt (Referenz „HexSlice Architecture"; a-check v0.15.0 prüft „HexSlice rules"); „hexagonal" korrekt als ADR-0008-Skizze geframt.
- **Verfeinerung, keine Verletzung von ADR-0008 (§3.4):** Mechanik unangetastet; ADR-0008 reservierte Layout + a-check-Verfügbarkeit selbst als offene Vorbedingungen → „Verfeinert (nicht supersedet)" tragfähig.
- **LH-QA-01 konditional erhalten;** Alternativen fair, Konsequenzen ehrlich; Folgepflicht vollständig (CR LH-FA-04/07, architecture.md, Re-Slice 045a/045b/046).

## MEDIUM-1 — Kanten-Enumeration (Entscheidung 2) unvollständig gegen die kanonische `.a-check.yml`

Die ADR-Prosa listete „Adapters→Application, Application→Domain, Adapters→Domain, Ports→Domain" — die reale `lab/examples/go/.a-check.yml` deklariert **fünf** `edges` inkl. **`{from: app, to: ports}`**. Diese `Application→Ports`-Kante ist vom Skelett erzwungen (Slice-Handler importieren ihre slice-lokalen/area-Ports, z. B. `createorder/handler.go`→`createorder/ports`). Ohne sie wäre das emittierte Skelett `wrong-direction`-rot — im Widerspruch zur Fitness-Function. **Auflösung (Autor):** Entscheidung 2 auf den vollständigen 5-Kanten-Satz korrigiert + die (korrekt fehlende) `adapters→ports`-Nicht-Kante begründet (strukturelle Interface-Erfüllung, kein Import, Wiring im Composition Root).

## INFO (nicht-blockierend)

- Der Achsen-Wert-Rename `hexagonal`→`hexslice` liegt am nächsten an der §3.4-Grenze, ist aber durch ADR-0008s eigene Skizze-Rahmung + die deklarierte Lastenheft-CR abgesichert — Nicht-Supersede haltbar.
- `adapters/outbound/<typ>/<area>` folgt dem kanonischen Doc-Struktur-Block (das minimale Beispiel verkürzt bei `notify`/`id` das `<area>`-Segment) — truthful generalisiert.
