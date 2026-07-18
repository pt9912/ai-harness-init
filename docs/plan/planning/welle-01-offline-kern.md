# Welle welle-01: Offline-Kern

**Status:** in-progress

**Zielmeilenstein:** M1 (lauffähiger Offline-Kern)

**Verantwortlich:** Demo. **Datum:** 2026-06-13.

---

## 1. Welle-Ziel

Ein lauffähiges `cmd/ai-harness-init`, das **ohne Netz** seinen Kern
leistet: Argumente parsen mit korrekten Fehlerpfaden, die
Doc-Gate-Baseline emittieren und Templates zweiklassig ablegen. Spiegelt
die Negative-/Boundary-Akzeptanzkriterien von [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) sowie [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
und [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7).

## 2. Trigger (Welle startet)

- Harness-Bootstrap abgeschlossen ([`ADR-0001`](../../../docs/plan/adr/0001-skelett-distribution.md) accepted, `make docs-check` grün).

## 3. Closure-Prozedur (Welle schließt) — fünf Schritte mit Beleg

Nach [Kurs Modul 6 §Wellen-Closure-Prozedur](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-06-roadmap.md).
Erst wenn alle fünf Belege vorliegen, ist die Welle *auditierbar* geschlossen — jeder
Schritt hinterlässt einen Beleg, keiner ein Datum:

1. **Trigger prüfen.** slice-001a, slice-001b, slice-002, slice-003 liegen in `done/`; `make gates`
   grün (inkl. der in slice-001b promoteten Go-Gates `build`/`lint`); Smoke: Bootstrap in tmp-Repo
   offline → erwartete Dateien vorhanden ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Vorstufe, voller Smoke erst
   nach welle-02). Beobachtbare Bedingung, kein Kalendertag.
2. **Carveout-Audit der Welle** ([Modul 7](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-07-carveouts.md)).
   Jeder offene Carveout wird geprüft: aufgelöst, verlängert (mit Folge-Slice) oder als
   permanent akzeptiert. Die Welle darf *mit* dokumentiertem Carveout schließen — nie
   mit stillem rotem Gate. (welle-01 hat derzeit keine Carveouts; der Audit ist dann
   eine belegte „0 offen"-Feststellung, kein Auslassen.)
3. **Closure-Notiz `done/welle-01-results.md` schreiben.** Hält fest, *was gelernt
   wurde*: geliefert · was funktionierte · was anders lief · **Steering-Loop-Einträge**
   (geschärfte Regel / neuer Sensor / benannte Spec-Lücke) · Folge-Slices · Verifikation
   (die Belege aus Schritt 1). Ohne Lerneintrag ist die Welle nicht „fertig", nur „weg".
4. **Wave-Self-Close-Commit.** Ein einzelner, beobachtbarer Commit markiert den
   Abschluss — der Audit sieht *einen* Punkt, an dem die Welle schloss, statt eines
   verstreuten Verschwindens.
5. **Roadmap fortschreiben.** welle-01 wandert in [`roadmap.md`](in-progress/roadmap.md)
   aus *Aktuelle Welle* in *Abgeschlossene Wellen* (mit Zeiger auf die Closure-Notiz);
   die erste Zeile aus *Nächste Wellen* wird zur neuen *Aktuellen Welle*. Löste ein
   Trigger eine Umplanung aus, bekommt *Historische Trigger-Verschiebungen* ihren Eintrag.

## 4. Slices in dieser Welle

| Slice | Titel | Status | Bezug |
|---|---|---|---|
| [slice-001a](done/slice-001a-cli-skeleton.md) | CLI-Skeleton (Go) + go-test-Gate | done | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [slice-001b](open/slice-001b-go-gates.md) | Go-Gates build/lint + Promotion | open | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [slice-002](open/slice-002-doc-gate-emit.md) | Doc-Gate-Baseline emittieren | open | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-003](open/slice-003-template-ablage.md) | Zweiklassige Template-Ablage | open | [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) |

## 5. Abhängigkeiten

- Blockiert: welle-02 (Picker/README setzen auf dem CLI-Skeleton auf).
- Wird blockiert von: keine (erste Welle).
- Intern: slice-002 und slice-003 setzen auf dem Arg-Parser/Skeleton aus
  slice-001a auf; slice-001b (build/lint-Gates) hängt an slice-001a.

## 6. Out-of-Scope für diese Welle

- Netz-Zugriff jeder Art (Sprachskelett-Fetch → welle-02, [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)).
- Root-README-Emit (→ welle-02, [`LH-FA-05`](../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2)).
- **Happy-Path-Voll-Smoke von [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)** (`make gates` grün end-to-end nach
  Bootstrap) → welle-02/slice-005. welle-01 deckt von [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) nur die
  Negative-/Boundary-AC und das Argument-Parsen ab.
- Inhaltliche Urteilsschritte (Spec/ADR/Modus) — global out-of-scope.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf done/welle-01-results.md (§3 Schritt 3). -->
