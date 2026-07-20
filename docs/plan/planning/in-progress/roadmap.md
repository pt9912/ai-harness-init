# Roadmap

**Status:** Aktiv. **Letzte Änderung:** 2026-07-20.

**Format-Regel:** Die Roadmap ist eine Reihenfolge von **Wellen**,
keine Reihenfolge von Terminen (siehe
[Kurs Modul 6](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-06-roadmap.md)).
Termine werden — falls überhaupt — als Konsequenz der Wellen-Schätzung
gezeigt, nicht als Treiber.

---

## Aktuelle Welle

**Welle-ID:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md) — **umgeplant 2026-07-20**
**Start:** 2026-07-18 (Trigger „welle-01 done" erfüllt; die Umplanung setzt den Start nicht zurück)
**Geplantes Ende:** offen

**Slice-IDs:** slice-022a (Baseline-Fetch additiv, [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) → slice-022b
(Embed raus, [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)) → slice-025 (Bootstrap-Kette absichern,
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)) → slice-023 (Go-Skelett-Generator,
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)) → slice-004b (Verdrahten: Gerüst + Init-Flow).
Strikt sequenziell. slice-004a liegt bereits in `done/`.

**Closure-Trigger:** die drei Slices in `done/`, `make gates` grün, **Tier-2-`make smoke` grün**,
Carveout-Audit 0/dokumentiert, Closure-Notiz. Der **Voll**-E2E-Smoke ist bewusst welle-03s
Kriterium ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) Happy-Path braucht die Root-README). Details in der
[welle-02-Plan-Datei](../welle-02-fetch-und-readme.md).

> **Stand (2026-07-20, nicht Teil der Wellen-Ordnung):** Der **Distributionsmodell-Pivot**
> ([`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) Accepted, CR [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), neue
> [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) ist **in die Planung überführt**: welle-02 wurde **umgeplant**
> statt geschlossen (Modul 6 — eine Welle endet durch Closure-Kriterien, nicht durch
> Kappen), slice-004b **re-gescopet** statt aufgelöst (Muster:
> [slice-015](../done/slice-015-zitat-sensor.md)), slice-005 nach welle-03 umgehängt. Das
> **Doc-Fundament ist fertig + gate-grün** (Lastenheft v0.7.0); der **Code** (embed→fetch,
> Generator, Verdrahtung) ist jetzt geschnitten und folgt. **slice-022 wurde bei der
> Ist-Messung vor der Implementierung in 022a/022b geteilt** (Modul-5-Rücksprung, wie
> slice-001→001a/b und slice-004→004a/b) — Grund: ZIP≠Tar-Umbau plus ein bis dahin
> unbemerktes Loch (der Ziel-Verifier für [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)s Prüfsummen-AC).
> **Nächster Schritt:** slice-022a implementieren (`/implement-slice`). Offene
> Aufräum-Punkte (kein Gate-Bruch): stale Links auf die superseded Skelett-Fetch-ADR in
> welle-01/Root-README.

## Nächste Wellen

| Welle | Trigger | Wichtigste Slices | Geschätzter Aufwand |
|---|---|---|---|
| [welle-03-readme-und-smoke](../welle-03-readme-und-smoke.md) | welle-02 in `done/` | slice-005 (Root-README, [`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2)) · slice-024 (Voll-E2E-Smoke, [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)) | S–M |

## Meilensteine

| Meilenstein | Welle(n) | Trigger | Status |
|---|---|---|---|
| M1 — lauffähiger Offline-Kern (`cmd/ai-harness-init` parst + emittiert Gate-Baseline + legt Templates ab, ohne Netz) | welle-01 | slice-001a/001b/002/003 done | **erreicht (2026-07-18)** |
| M2 — vollständiger Bootstrap (inkl. Sprachskelett-Generator + Root-README) | welle-02 **und** welle-03 | slice-005 + slice-024 in `done/` **und** Voll-E2E-Smoke grün (welle-03-Closure) | offen |

## Abhängigkeitsgraph

```mermaid
flowchart LR
    W1[welle-01<br/>Offline-Kern]
    W2[welle-02<br/>Distributions-Umbau]
    W3[welle-03<br/>README & Voll-Smoke]
    W1 --> W2 --> W3
```

## Abgeschlossene Wellen

| Welle | Abschluss | Closure-Notiz |
|---|---|---|
| [welle-01-offline-kern](../done/welle-01-offline-kern.md) | 2026-07-18 | [welle-01-results.md](../done/welle-01-results.md) |

## Historische Trigger-Verschiebungen

| Datum | Was wurde geändert? | Warum? |
|---|---|---|
| 2026-07-20 | **slice-025 neu** (Bootstrap-Kette absichern), eingeschoben **vor** slice-023/004b; Kette jetzt 022a→022b→025→023→004b | Die Teil-Bootstrap-Klasse stand bei ihrer **vierten** Wiederholung (slice-002 I1 → 003 I1 → 004a L3 → 022a I1). Die in slice-004a protokollierte Lösung („gemeinsamer Pre-Flight") war dreimal einem Folge-Slice zugewiesen und nie geliefert; ein viertes Weiterreichen wäre ein Muster, kein Plan. Eigener Slice statt Carveout, weil der Trigger nicht *erreichbar* fehlte, sondern die Zuweisung nicht trug |
| 2026-07-20 | **slice-022 → slice-022a/022b re-sliced** (vor der Implementierung, Modul-5-Rücksprung; Kette jetzt 022a→022b→023→004b) | Ist-Messung deckte auf: der Fetch-Umbau ist ZIP≠Tar (Kernlogik, kein „update"), und [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)s Prüfsummen-AC braucht einen **Ziel-Verifier**, den weder Template-Satz noch Emit-Pfad liefern — zusammen über der Ein-Sitzungs-Review-Linie. 022a additiv, 022b räumt ab; Zwischenzustand von `skel-drift.bats` bewacht |
| 2026-07-20 | **welle-02 umgeplant** (nicht geschlossen): Ziel auf den Distributions-Umbau fokussiert, slice-022/023 neu, slice-004b re-gescopet, slice-005 nach welle-03 umgehängt; **welle-03 neu**; **M2 auf welle-02+welle-03** verteilt | [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) machte das Wellen-Ziel („Skelett vom Kurs-Tag holen") und den Closure-Trigger ungültig. Kappen wäre die Auditierbarkeits-Lücke aus Modul 6 („Welle ≠ Sprint") — dieselbe Umplanungs-Antwort wie beim Go-Pivot 2026-07 |
| 2026-07-18 | welle-01 geschlossen; welle-02 aktiviert; M1 erreicht | Trigger „alle welle-01-Slices `done/` + `make gates` grün" erfüllt |
| 2026-07 | welle-01-Slices auf die Go-Ära re-geschnitten (slice-001 → 001a/001b) | Impl-Sprache Go / native Binaries ([`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md)); slice-001 zu groß (Modul-5-Rücksprung) |
