# Roadmap

**Status:** Aktiv. **Letzte Änderung:** 2026-07-23.

**Format-Regel:** Die Roadmap ist eine Reihenfolge von **Wellen**,
keine Reihenfolge von Terminen (siehe
[Kurs Modul 6](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-06-roadmap.md)).
Termine werden — falls überhaupt — als Konsequenz der Wellen-Schätzung
gezeigt, nicht als Treiber.

---

## Aktuelle Welle

**Keine aktive Welle.** [welle-05 — Bootstrap-Phasen](../done/welle-05-bootstrap-phasen.md) ist
**geschlossen (2026-07-23)** — [`ADR-0007`](../../../../docs/plan/adr/0007-bootstrap-phasen.md) ist umgesetzt
(Init sprach-agnostisch, `add-lang` wiederholbar/Mono-Repo, idempotente Emission konvergent/skip-if-present,
Guard-Boden gebacken). Ergebnisse: [welle-05-results.md](../done/welle-05-results.md).

Die nächste Welle ist **noch nicht geschnitten** (green-before-extend, cp-Disziplin): die Backlog-Cluster
**B/C/D** (unten) sind die Kandidaten, je nach erster beobachteter Drift bzw. nächster Wartungsrunde.

**Benannter `open/`-Folgepunkt** (aus welle-05 out-of-scope, [`ADR-0007`](../../../../docs/plan/adr/0007-bootstrap-phasen.md)
INFO I-1): git-Repo-Vorbedingung der emittierten `make gates` — `record-gates` startet mit `git rev-parse`;
ein Bootstrap in ein nicht git-initialisiertes Verzeichnis röte `make gates` trotz grüner Übrig-Gates.
`make full-smoke` git-init'et das Ziel; der reale Nicht-git-Init-Fall bleibt ein separater Wartungs-/Doku-Slice.
Ebenso offen: `smoke.sh:89` toter `@@BLOCKED_SET@@`-Check (slice-036-Folgepunkt).

## Nächste Wellen

Nach [welle-05](../done/welle-05-bootstrap-phasen.md) sind die **Backlog-Cluster B/C/D** (unten) die
Kandidaten — je nach erster beobachteter Drift bzw. nächster Wartungsrunde; Plandatei per `cp`, sobald
der erste Slice geschnitten wird (green-before-extend; cp-Disziplin — kein Vorab-Schnitt).
**a-check ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) bleibt aufgeschoben**
(hängt an hexagonalen Schichten — weder Dogfood noch Skelett tragen `domain/ports/adapters`).

## Backlog (aus Slice-§6 gehoben, 2026-07-21)

> Diese Folge-Punkte standen verstreut als „offen / Folge-Slice / spätere Welle"
> in einzelnen Slice-§6-Blöcken. Hier zentral als **planbare Cluster** (Modul 6/7),
> damit sie auditierbar sind statt in Fußnoten zu driften. Jeder Cluster trägt eine
> **Trigger-Bedingung, kein Datum** (Modul 6). Ein Wellen-Kandidat bekommt seine
> Plandatei per `cp` **erst, wenn sein erster Slice geschnitten wird** — genau so
> entstand welle-03 (slice-005/024 zuerst, dann die Datei); eine Welle-Datei mit
> leerem §4 wäre die „zweite Wahrheit, die driftet". Slice-Namen bewusst **plain**
> (Provenienz, keine Lifecycle-Pfad-Kopplung). **Nicht** hier, weil bereits
> geliefert: „Scheduled CI-Job" (slice-009/018) → slice-027; „Sensor auf neuen
> Tag" (slice-011) → slice-018; **Cluster A · Durchsetzung & Emission** komplett →
> welle-04 (Durchsetzungs-Mechanik + Command-Guard + Workflow-Commands) und welle-05
> (BLOCKED-Set je Sprache); der einzige Rest, das Arch-Gate a-check, ist als
> M4-Kandidat + „aufgeschoben" getrackt. **architecture.md an das Distributionsmodell**
> (slice-023) → welle-05-Nachzug (`Tool-als-Quelle` in der Schichten-Tabelle);
> **README-d-check-Pin** (slice-019) → entfällt (README nennt keinen Pin mehr).

| Cluster | Folge-Punkte (Herkunfts-Slice) | Trigger (Bedingung) | Vorgesehene Ablage |
|---|---|---|---|
| **B · Freshness** | go-freshness-Sensor · SKEL_GO_VERSION=latest Web-Lookup (slice-023) · mechanische Freshness für Quellen-Links / BASELINE_TAG (slice-012) · Regelwerk-Refresh-Mechanik (slice-007) | erste beobachtete Pin-/Tag-/Quellen-Drift — der **M2-Trigger ist gefeuert** (erreicht 2026-07-22), B ist damit ein lebender Nächste-Welle-Kandidat | kleine Welle „Freshness-Sensoren" (netz/nächtlich, Muster [slice-018](../done/slice-018-baseline-freshness.md)) bzw. Einzel-Slices |
| **C · Doc-Gate-Härtung** | Prosa-Zahlen-Provenienz (slice-011/015) · Anker-Fragment-Sensor (slice-014) · citations-Modul / Zitat gegen Zeilenspanne (slice-015) | erneutes Auftreten einer der Befund-Klassen (Muster slice-026: neun Instanzen → Sensor) | kleine Welle bzw. Einzel-Slices |
| **D · Doku/Prozess-Reconciliation** | „≤3-DoD"-Regel klären (slice-013) · lastenheft_refs vs. Bezug-Zeile (slice-014) · `done/`-Lifecycle-Link-Exemption als Gate-Policy-Änderung (slice-025) · `smoke.sh:89` toter `@@BLOCKED_SET@@`-Check (slice-036) · git-Vorbedingung der emittierten `make gates` ([`ADR-0007`](../../../../docs/plan/adr/0007-bootstrap-phasen.md) INFO I-1, slice-038) | Wartung — **kein** Welle-Trigger; bei nächster Harness-Wartungsrunde | Harness-Wartung ohne Welle (Muster slice-026/027): je kleiner Slice bzw. conventions-Adaption |
| **E · Konditional** | optionale .bats-Lint-Abdeckung (slice-008) → [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) · Codex-Hook real verifizieren + Pfad-Härtung (slice-007) | .bats: CO-001-Auflösungs-Trigger (bats-Logik mit Verzweigung wächst) · Codex-Hook: eingesetzte Codex-Version wechselt | Carveout (aktiv) bzw. benannter Follow-up (**kein** Gate → **kein** Carveout) |

## Meilensteine

| Meilenstein | Welle(n) | Trigger | Status |
|---|---|---|---|
| M1 — lauffähiger Offline-Kern (`cmd/ai-harness-init` parst + emittiert Gate-Baseline + legt Templates ab, ohne Netz) | welle-01 | slice-001a/001b/002/003 done | **erreicht (2026-07-18)** |
| M2 — vollständiger Bootstrap (inkl. Sprachskelett-Generator + Root-README) | welle-02 **und** welle-03 | slice-005 + slice-024 in `done/` **und** Voll-E2E-Smoke grün (welle-03-Closure) | **erreicht (2026-07-22)** |
| M3 — durchsetzender, phasierter Harness (emittierter Repo erzwingt den Prozess: Hooks + Command-Guard + Workflow-Anleitung; Bootstrap phasiert + idempotent: doc-führt auch für die Zielsprache, `add-lang`/Mono-Repo) | welle-04 **und** welle-05 | welle-04 + welle-05 in `done/` **und** `make full-smoke` grün über die Durchsetzungs- + Idempotenz-Fitness (Guard blockt, Gate-Nachweis-Kreis geschlossen, 2. Init-Lauf idempotent, kein Prune) | **erreicht (2026-07-23)** |

## Abhängigkeitsgraph

```mermaid
flowchart LR
    W1[welle-01<br/>Offline-Kern]
    W2[welle-02<br/>Distributions-Umbau]
    W3[welle-03<br/>README & Voll-Smoke]
    W4[welle-04<br/>Durchsetzung & Emission]
    W5[welle-05<br/>Bootstrap-Phasen]
    W1 --> W2 --> W3 --> W4 --> W5
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
