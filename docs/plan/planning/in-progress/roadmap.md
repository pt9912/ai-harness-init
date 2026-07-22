# Roadmap

**Status:** Aktiv. **Letzte Änderung:** 2026-07-21.

**Format-Regel:** Die Roadmap ist eine Reihenfolge von **Wellen**,
keine Reihenfolge von Terminen (siehe
[Kurs Modul 6](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-06-roadmap.md)).
Termine werden — falls überhaupt — als Konsequenz der Wellen-Schätzung
gezeigt, nicht als Treiber.

---

## Aktuelle Welle

**Welle-ID:** [welle-04-durchsetzung-und-emission](../welle-04-durchsetzung-und-emission.md)
**Start:** 2026-07-22 (Trigger erfüllt: welle-03 in `done/` + [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) — Picker → **Tool-als-Quelle** — **accepted** nach unabhängigem Review-Pass; welle-04 voll aktiv)
**Geplantes Ende:** offen

**Slice-IDs:** slice-030 (Reviewer-/Closure-Skill emittieren, de-risk, [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), **done**) → slice-031 (Durchsetzungs-Mechanik: Gate-Nachweis/Stop-Hook/`.claude/settings.json`, Tool-als-Quelle, **done**) → slice-032 (Command-Guard + BLOCKED-Set je `--lang`, **done** → [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) komplett emittiert) → slice-033 (Workflow-Commands, [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), **done** → Anleitung komplett emittiert). **Alle 4 Slices in `done/`.**
**Nächster Schritt:** `/close-welle welle-04` — die Welle ist **closure-reif** (alle Slices `done`, Emission komplett: Durchsetzung [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) + Anleitung [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)). Beim Closure zu adressieren: die 2 benannten Folgepunkte unten + welle-04 §4-Tabelle-Stale (`CLAUDE.md` noch als slice-031-Scope gelistet, [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) → autort).
**Benannter `open/`-Folgepunkt (slice-031-Closure):** git-Repo-Vorbedingung der emittierten `make gates` (`record-gates` startet mit `git rev-parse`) — im Ziel undokumentiert; beim welle-04-Closure als Doku-Zeile oder optionales Bootstrap-`git init` entscheiden.

**Closure-Trigger:** alle vier Slices in `done/`, `make gates` grün, **`make full-smoke` grün** (emittiertes Repo trägt Durchsetzung + Commands, `make gates` dort out-of-the-box grün, Guard blockt die Ziel-Toolchain, kein node/jq — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), **`make mutate` grün**, Carveout-Audit 0/dokumentiert, Closure-Notiz. **a-check ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) bewusst nicht in dieser Welle** (hängt an hexagonalen Schichten). Details in der [welle-04-Plan-Datei](../welle-04-durchsetzung-und-emission.md).

## Nächste Wellen

Cluster A ist als **welle-04 aktiv** (oben). Keine weitere gefilte Welle danach — die
Kandidaten **B/C/D** stehen im Backlog unten, je mit Trigger-Bedingung; einer bekommt
seine Plandatei per `cp`, sobald sein erster Slice geschnitten wird.

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
> Tag" (slice-011) → slice-018.

| Cluster | Folge-Punkte (Herkunfts-Slice) | Trigger (Bedingung) | Vorgesehene Ablage |
|---|---|---|---|
| **A · Durchsetzung & Emission** | Durchsetzungs-Emit ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`ADR-0004`](../../../../docs/plan/adr/0004-durchsetzungs-emission.md), BLOCKED-Set je `--lang`) · Arch-Gate a-check ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) · Workflow-Command-Emit ([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) | welle-03 in `done/` (green-before-extend: erst Baseline grün, dann Emit-Fläche erweitern) | **welle-04 aktiv (2026-07-22)** — [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) entsperrte die Quelle (Picker → Tool-als-Quelle); slice-030 geschnitten. a-check ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) bleibt aufgeschoben (hexagonale Schichten) |
| **B · Freshness** | go-freshness-Sensor · SKEL_GO_VERSION=latest Web-Lookup (slice-023) · mechanische Freshness für Quellen-Links / BASELINE_TAG (slice-012) · Regelwerk-Refresh-Mechanik (slice-007) | erste beobachtete Pin-/Tag-/Quellen-Drift, oder M2 erreicht | kleine Welle „Freshness-Sensoren" (netz/nächtlich, Muster [slice-018](../done/slice-018-baseline-freshness.md)) bzw. Einzel-Slices |
| **C · Doc-Gate-Härtung** | Prosa-Zahlen-Provenienz (slice-011/015) · Anker-Fragment-Sensor (slice-014) · citations-Modul / Zitat gegen Zeilenspanne (slice-015) | erneutes Auftreten einer der Befund-Klassen (Muster slice-026: neun Instanzen → Sensor) | kleine Welle bzw. Einzel-Slices |
| **D · Doku/Prozess-Reconciliation** | architecture.md an die [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md)-Klasse nachziehen (slice-023) · README nennt stale d-check-Pin (slice-019) · „≤3-DoD"-Regel klären (slice-013) · lastenheft_refs vs. Bezug-Zeile (slice-014) · `done/`-Lifecycle-Link-Exemption als Gate-Policy-Änderung (slice-025) | Wartung — **kein** Welle-Trigger; bei nächster Harness-Wartungsrunde | Harness-Wartung ohne Welle (Muster slice-026/027): je kleiner Slice bzw. conventions-Adaption |
| **E · Konditional** | optionale .bats-Lint-Abdeckung (slice-008) → [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) · Codex-Hook real verifizieren + Pfad-Härtung (slice-007) | .bats: CO-001-Auflösungs-Trigger (bats-Logik mit Verzweigung wächst) · Codex-Hook: eingesetzte Codex-Version wechselt | Carveout (aktiv) bzw. benannter Follow-up (**kein** Gate → **kein** Carveout) |

## Meilensteine

| Meilenstein | Welle(n) | Trigger | Status |
|---|---|---|---|
| M1 — lauffähiger Offline-Kern (`cmd/ai-harness-init` parst + emittiert Gate-Baseline + legt Templates ab, ohne Netz) | welle-01 | slice-001a/001b/002/003 done | **erreicht (2026-07-18)** |
| M2 — vollständiger Bootstrap (inkl. Sprachskelett-Generator + Root-README) | welle-02 **und** welle-03 | slice-005 + slice-024 in `done/` **und** Voll-E2E-Smoke grün (welle-03-Closure) | **erreicht (2026-07-22)** |

## Abhängigkeitsgraph

```mermaid
flowchart LR
    W1[welle-01<br/>Offline-Kern]
    W2[welle-02<br/>Distributions-Umbau]
    W3[welle-03<br/>README & Voll-Smoke]
    W4[welle-04<br/>Durchsetzung & Emission]
    W1 --> W2 --> W3 --> W4
```

## Abgeschlossene Wellen

| Welle | Abschluss | Closure-Notiz |
|---|---|---|
| [welle-01-offline-kern](../done/welle-01-offline-kern.md) | 2026-07-18 | [welle-01-results.md](../done/welle-01-results.md) |
| [welle-02-fetch-und-readme](../done/welle-02-fetch-und-readme.md) | 2026-07-21 | [welle-02-results.md](../done/welle-02-results.md) |
| [welle-03-readme-und-smoke](../done/welle-03-readme-und-smoke.md) | 2026-07-22 | [welle-03-results.md](../done/welle-03-results.md) |

## Historische Trigger-Verschiebungen

| Datum | Was wurde geändert? | Warum? |
|---|---|---|
| 2026-07-20 | **slice-027 neu** (CI), Harness-Wartung ohne Welle; `make mutate` zusätzlich als Closure-Kriterium in welle-02/03 verankert | Gemessen beim Berichten der slice-026-Restrisiken: es gibt **keine CI**, und `make mutate` stand in keinem Trigger — ein Sensor ohne Auslöser. Schwerer wiegt: [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) benennt seit 2026-06-13 als Restlücke des Gate-Nachweises „frischer Klon … (**CI ist dort das Netz**)" — dieses Netz existiert nicht, die Lücke ist seither unabgedeckt |
| 2026-07-20 | **slice-026 neu** (Mutations-Sensor `make mutate`), Harness-Wartung ohne Welle; Empfehlung: vor den restlichen welle-02-Slices | [`AGENTS.md`](../../../../AGENTS.md) §3.6 entstand aus neun Instanzen einer Befund-Klasse — hat aber **kein** computational feedback, anders als 3.1–3.5. Modul 9: „Hard Rule nur in einem Quadranten ist halb durchgesetzt … Beides ist Pflicht." Beleg kam sofort: der 022b-Re-Review-Befund N-1 ist eine Instanz der Klasse, entstanden **nach** 3.6 und von `make gates` nicht bemerkt |
| 2026-07-20 | **slice-025 neu** (Bootstrap-Kette absichern), eingeschoben **vor** slice-023/004b; Kette jetzt 022a→022b→025→023→004b | Die Teil-Bootstrap-Klasse stand bei ihrer **vierten** Wiederholung (slice-002 I1 → 003 I1 → 004a L3 → 022a I1). Die in slice-004a protokollierte Lösung („gemeinsamer Pre-Flight") war dreimal einem Folge-Slice zugewiesen und nie geliefert; ein viertes Weiterreichen wäre ein Muster, kein Plan. Eigener Slice statt Carveout, weil der Trigger nicht *erreichbar* fehlte, sondern die Zuweisung nicht trug |
| 2026-07-20 | **slice-022 → slice-022a/022b re-sliced** (vor der Implementierung, Modul-5-Rücksprung; Kette jetzt 022a→022b→023→004b) | Ist-Messung deckte auf: der Fetch-Umbau ist ZIP≠Tar (Kernlogik, kein „update"), und [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)s Prüfsummen-AC braucht einen **Ziel-Verifier**, den weder Template-Satz noch Emit-Pfad liefern — zusammen über der Ein-Sitzungs-Review-Linie. 022a additiv, 022b räumt ab; Zwischenzustand von `skel-drift.bats` bewacht |
| 2026-07-20 | **welle-02 umgeplant** (nicht geschlossen): Ziel auf den Distributions-Umbau fokussiert, slice-022/023 neu, slice-004b re-gescopet, slice-005 nach welle-03 umgehängt; **welle-03 neu**; **M2 auf welle-02+welle-03** verteilt | [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) machte das Wellen-Ziel („Skelett vom Kurs-Tag holen") und den Closure-Trigger ungültig. Kappen wäre die Auditierbarkeits-Lücke aus Modul 6 („Welle ≠ Sprint") — dieselbe Umplanungs-Antwort wie beim Go-Pivot 2026-07 |
| 2026-07-18 | welle-01 geschlossen; welle-02 aktiviert; M1 erreicht | Trigger „alle welle-01-Slices `done/` + `make gates` grün" erfüllt |
| 2026-07 | welle-01-Slices auf die Go-Ära re-geschnitten (slice-001 → 001a/001b) | Impl-Sprache Go / native Binaries ([`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md)); slice-001 zu groß (Modul-5-Rücksprung) |
