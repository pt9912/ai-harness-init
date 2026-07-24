# Roadmap

**Status:** Aktiv. **Letzte Änderung:** 2026-07-23.

**Format-Regel:** Die Roadmap ist eine Reihenfolge von **Wellen**,
keine Reihenfolge von Terminen (siehe
[Kurs Modul 6](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-06-roadmap.md)).
Termine werden — falls überhaupt — als Konsequenz der Wellen-Schätzung
gezeigt, nicht als Treiber.

---

## Aktuelle Welle

**Welle-ID:** [welle-06-freshness](../welle-06-freshness.md) — Multi-Komponenten-Versions-Freshness. **Aktiv** seit 2026-07-23.
**Trigger (gefeuert):** upstream erschien Regelwerk **v3.5.1** > gepinnt `v3.5.0` — erste beobachtete Tag-/Quellen-Drift.
**Slices:** slice-040 (Generalisierung + golangci-lint/d-check) geschnitten in `open/`; slice-041 (Go), slice-042 (ubuntu-Tag) in §4 der Welle (per `cp` bei Schnitt).

**Aktueller Schritt:** slice-040 ([done](../done/slice-040-freshness-generalisierung.md)) **und** slice-041 ([done](../done/slice-041-go-version-freshness.md)) **abgeschlossen** (2026-07-24) — generischer `component-freshness.sh` + golangci-lint/d-check-Achsen (040) und die Go-Sonderquelle go.dev via `go-freshness.sh` (041) im Nachtlauf; je Review KONFORM, Verifikation DoD BESTÄTIGT. **Nächster Welle-Slice:** slice-042 (C++/ubuntu-Base-Tag-Freshness, Quelle Docker-Hub-LTS) — noch **nicht geschnitten** (cp-Disziplin: Slice-Datei per `cp` erst bei Schnitt). Die Welle bleibt offen (slice-042 steht aus).

**Davon unabhängig offen (keine Welle):** der **v3.5.1-Baseline-Bump** ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) — `.harness/baseline/v3.5.1/` neu vendoren, `BASELINE_TAG`/`BASELINE_ZIP_SHA256` (Makefile) + `DefaultTag` (`internal/fetch/baseline.go`) neu pinnen, Doc-Links, `make baseline-verify`. Der nächtliche Sensor **meldet** die Drift, der Bump **behebt** sie.

**Closure-Trigger:** alle Welle-Slices in `done/`; `make gates` + `make mutate` grün; jede Achse im nächtlichen `upstream-drift`-Job verdrahtet (read-only, nicht in gates); Closure-Notiz `welle-06-results.md`.

## Nächste Wellen

Keine weitere Welle ist geschnitten (cp-Disziplin — Plandatei erst per `cp`, wenn ihr erster Slice steht).
Prospektive Kandidaten (nur mit **beobachtbarem Trigger**, Modul 6):

| Welle-Kandidat | Trigger | Wichtigste Slices | Aufwand |
|---|---|---|---|
| Arch-Gate (M4) | der Architektur-ADR (Achse `--arch`) accepted — er wird nach dieser Welle proposed | geschichtetes Skelett-Profil (domain/ports/adapters) · a-check-Emission | M |
| Doc-Gate-Härtung | erneut beobachtete Befund-Klasse (Muster slice-026: neun Instanzen → Sensor) | Anker-Fragment-Sensor · Prosa-Zahlen-Provenienz · citations (slice-014/015) | S |

## Meilensteine

| Meilenstein | Welle(n) | Trigger | Status |
|---|---|---|---|
| M1 — lauffähiger Offline-Kern (`cmd/ai-harness-init` parst + emittiert Gate-Baseline + legt Templates ab, ohne Netz) | welle-01 | slice-001a/001b/002/003 done | **erreicht (2026-07-18)** |
| M2 — vollständiger Bootstrap (inkl. Sprachskelett-Generator + Root-README) | welle-02 **und** welle-03 | slice-005 + slice-024 in `done/` **und** Voll-E2E-Smoke grün (welle-03-Closure) | **erreicht (2026-07-22)** |
| M3 — durchsetzender, phasierter Harness (emittierter Repo erzwingt den Prozess: Hooks + Command-Guard + Workflow-Anleitung; Bootstrap phasiert + idempotent: doc-führt auch für die Zielsprache, `add-lang`/Mono-Repo) | welle-04 **und** welle-05 | welle-04 + welle-05 in `done/` **und** `make full-smoke` grün über die Durchsetzungs- + Idempotenz-Fitness (Guard blockt, Gate-Nachweis-Kreis geschlossen, 2. Init-Lauf idempotent, kein Prune) | **erreicht (2026-07-23)** |
| M4 — Arch-Gate integriert (a-check, [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) | — (Welle noch nicht geschnitten) | ein Skelett trägt hexagonale Schichten (`domain/ports/adapters`) **und** der a-check-Emitter ist gebaut → a-check wird emittiert + aktiv (sonst [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Verstoß über leerem Prüfbereich) | **offen** |

## Abhängigkeitsgraph

```mermaid
flowchart LR
    W1[welle-01<br/>Offline-Kern]
    W2[welle-02<br/>Distributions-Umbau]
    W3[welle-03<br/>README & Voll-Smoke]
    W4[welle-04<br/>Durchsetzung & Emission]
    W5[welle-05<br/>Bootstrap-Phasen]
    W6[welle-06<br/>Freshness]
    W1 --> W2 --> W3 --> W4 --> W5
    W5 -.-> W6
```

## Abgeschlossene Wellen

| Welle | Abschluss | Closure-Notiz |
|---|---|---|
| [welle-01-offline-kern](../done/welle-01-offline-kern.md) | 2026-07-18 | [welle-01-results.md](../done/welle-01-results.md) |
| [welle-02-fetch-und-readme](../done/welle-02-fetch-und-readme.md) | 2026-07-21 | [welle-02-results.md](../done/welle-02-results.md) |
| [welle-03-readme-und-smoke](../done/welle-03-readme-und-smoke.md) | 2026-07-22 | [welle-03-results.md](../done/welle-03-results.md) |
| [welle-04-durchsetzung-und-emission](../done/welle-04-durchsetzung-und-emission.md) | 2026-07-22 | [welle-04-results.md](../done/welle-04-results.md) |
| [welle-05-bootstrap-phasen](../done/welle-05-bootstrap-phasen.md) | 2026-07-23 | [welle-05-results.md](../done/welle-05-results.md) |

## Historische Trigger-Verschiebungen

| Datum | Was wurde geändert? | Warum? |
|---|---|---|
| 2026-07-23 | **M3 nachgetragen** (durchsetzender, phasierter Harness; welle-04 **und** welle-05), bei der welle-05-Closure | Die Meilenstein-Tabelle endete bei M2, während welle-04 (Durchsetzung + Anleitung emittiert) und welle-05 (phasierter, idempotenter Bootstrap, `add-lang`/Mono-Repo) danach einen Fähigkeits-Sprung lieferten — die Tabelle hinkte zwei Wellen hinterher. [welle-04-results.md](../done/welle-04-results.md) hatte den „vollständiger Harness inkl. Durchsetzung"-Meilenstein bereits vorregistriert. Bewusst **nicht** „vollständig" genannt: das Arch-Gate (a-check) fehlt noch (Kandidat für ein späteres M4 mit Release-Binaries) |
| 2026-07-20 | **slice-027 neu** (CI), Harness-Wartung ohne Welle; `make mutate` zusätzlich als Closure-Kriterium in welle-02/03 verankert | Gemessen beim Berichten der slice-026-Restrisiken: es gibt **keine CI**, und `make mutate` stand in keinem Trigger — ein Sensor ohne Auslöser. Schwerer wiegt: [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) benennt seit 2026-06-13 als Restlücke des Gate-Nachweises „frischer Klon … (**CI ist dort das Netz**)" — dieses Netz existiert nicht, die Lücke ist seither unabgedeckt |
| 2026-07-20 | **slice-026 neu** (Mutations-Sensor `make mutate`), Harness-Wartung ohne Welle; Empfehlung: vor den restlichen welle-02-Slices | [`AGENTS.md`](../../../../AGENTS.md) §3.6 entstand aus neun Instanzen einer Befund-Klasse — hat aber **kein** computational feedback, anders als 3.1–3.5. Modul 9: „Hard Rule nur in einem Quadranten ist halb durchgesetzt … Beides ist Pflicht." Beleg kam sofort: der 022b-Re-Review-Befund N-1 ist eine Instanz der Klasse, entstanden **nach** 3.6 und von `make gates` nicht bemerkt |
| 2026-07-20 | **slice-025 neu** (Bootstrap-Kette absichern), eingeschoben **vor** slice-023/004b; Kette jetzt 022a→022b→025→023→004b | Die Teil-Bootstrap-Klasse stand bei ihrer **vierten** Wiederholung (slice-002 I1 → 003 I1 → 004a L3 → 022a I1). Die in slice-004a protokollierte Lösung („gemeinsamer Pre-Flight") war dreimal einem Folge-Slice zugewiesen und nie geliefert; ein viertes Weiterreichen wäre ein Muster, kein Plan. Eigener Slice statt Carveout, weil der Trigger nicht *erreichbar* fehlte, sondern die Zuweisung nicht trug |
| 2026-07-20 | **slice-022 → slice-022a/022b re-sliced** (vor der Implementierung, Modul-5-Rücksprung; Kette jetzt 022a→022b→023→004b) | Ist-Messung deckte auf: der Fetch-Umbau ist ZIP≠Tar (Kernlogik, kein „update"), und [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)s Prüfsummen-AC braucht einen **Ziel-Verifier**, den weder Template-Satz noch Emit-Pfad liefern — zusammen über der Ein-Sitzungs-Review-Linie. 022a additiv, 022b räumt ab; Zwischenzustand von `skel-drift.bats` bewacht |
| 2026-07-20 | **welle-02 umgeplant** (nicht geschlossen): Ziel auf den Distributions-Umbau fokussiert, slice-022/023 neu, slice-004b re-gescopet, slice-005 nach welle-03 umgehängt; **welle-03 neu**; **M2 auf welle-02+welle-03** verteilt | [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) machte das Wellen-Ziel („Skelett vom Kurs-Tag holen") und den Closure-Trigger ungültig. Kappen wäre die Auditierbarkeits-Lücke aus Modul 6 („Welle ≠ Sprint") — dieselbe Umplanungs-Antwort wie beim Go-Pivot 2026-07 |
| 2026-07-18 | welle-01 geschlossen; welle-02 aktiviert; M1 erreicht | Trigger „alle welle-01-Slices `done/` + `make gates` grün" erfüllt |
| 2026-07 | welle-01-Slices auf die Go-Ära re-geschnitten (slice-001 → 001a/001b) | Impl-Sprache Go / native Binaries ([`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md)); slice-001 zu groß (Modul-5-Rücksprung) |
