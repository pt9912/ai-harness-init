# Roadmap

**Status:** Aktiv. **Letzte Änderung:** 2026-07-18.

**Format-Regel:** Die Roadmap ist eine Reihenfolge von **Wellen**,
keine Reihenfolge von Terminen (siehe
[Kurs Modul 6](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-06-roadmap.md)).
Termine werden — falls überhaupt — als Konsequenz der Wellen-Schätzung
gezeigt, nicht als Treiber.

---

## Aktuelle Welle

**Welle-ID:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md)
**Start:** 2026-07-18 (Trigger „welle-01 done" erfüllt)
**Geplantes Ende:** offen

**Closure-Trigger:** slice-004a/004b (Sprachskelett-Fetch + Verdrahten, [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)) und slice-005
(Root-README, [`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2)) in `done/`, `make gates` grün; slice-005 bringt den
Voll-E2E-`make gates`-Smoke des Bootstraps ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) Happy-Path). Details in der
[welle-02-Plan-Datei](../welle-02-fetch-und-readme.md).

> **Stand (2026-07-18, nicht Teil der Wellen-Ordnung):** slice-004a (Skelett-Fetch) in `done/`.
> **slice-004b** (Merge/Verdrahten) `open/` — **blockiert, bis eine Layering-ADR** die Datei-Ownership
> (Skelett-Schicht ↔ Harness-Emit-Schicht: wer besitzt `AGENTS.md`/`Makefile`) entscheidet.
> **slice-005** (Root-README + der aufgeschobene Voll-Smoke) `open/`. **Nächster Schritt:** die
> Layering-ADR schreiben (entsperrt slice-004b) — oder slice-005.

## Nächste Wellen

| Welle | Trigger | Wichtigste Slices | Geschätzter Aufwand |
|---|---|---|---|
| _(noch nicht geplant — welle-02 ist jetzt die Aktuelle Welle)_ | — | — | — |

## Meilensteine

| Meilenstein | Welle(n) | Trigger | Status |
|---|---|---|---|
| M1 — lauffähiger Offline-Kern (`cmd/ai-harness-init` parst + emittiert Gate-Baseline + legt Templates ab, ohne Netz) | welle-01 | slice-001a/001b/002/003 done | **erreicht (2026-07-18)** |
| M2 — vollständiger Bootstrap (inkl. Sprachskelett-Picker + Root-README) | welle-02 | slice-004a/004b/005 done | offen |

## Abhängigkeitsgraph

```mermaid
flowchart LR
    W1[welle-01<br/>Offline-Kern]
    W2[welle-02<br/>Fetch & README]
    W1 --> W2
```

## Abgeschlossene Wellen

| Welle | Abschluss | Closure-Notiz |
|---|---|---|
| [welle-01-offline-kern](../done/welle-01-offline-kern.md) | 2026-07-18 | [welle-01-results.md](../done/welle-01-results.md) |

## Historische Trigger-Verschiebungen

| Datum | Was wurde geändert? | Warum? |
|---|---|---|
| 2026-07-18 | welle-01 geschlossen; welle-02 aktiviert; M1 erreicht | Trigger „alle welle-01-Slices `done/` + `make gates` grün" erfüllt |
| 2026-07 | welle-01-Slices auf die Go-Ära re-geschnitten (slice-001 → 001a/001b) | Impl-Sprache Go / native Binaries ([`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md)); slice-001 zu groß (Modul-5-Rücksprung) |
