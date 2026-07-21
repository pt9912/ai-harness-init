# Slice slice-005: Root-README emittieren

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** [welle-03-readme-und-smoke](../welle-03-readme-und-smoke.md) *(umgehängt
2026-07-20 von welle-02 — [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md)-Pivot; Inhalt unberührt)*. Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2), [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen).

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

`cmd/ai-harness-init` emittiert die Root-`README.md` aus der
project-readme-Vorlage; der Pointer-/Trust-Abschnitt steht als
**gate-sichere Vorwärts-Verweise**, bis die Ziele existieren.

## 2. Definition of Done

- [ ] [`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2) erfüllt: Root-README aus Vorlage, Projektname gestempelt.
- [ ] Vorwärts-Verweise gate-sicher: kein Markdown-Link auf noch fehlende Ziele (Inline-Code/Plain-Text), `make docs-check` im Zielrepo grün.
- [ ] Der emittierte Stand ist smoke-fähig — der **Voll-E2E-Beweis** selbst ist [slice-024](../open/slice-024-voll-smoke.md) ([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)/[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) und wird hier **nicht** behauptet.
- [ ] Go-Test: README vorhanden, gestempelt, `docs-check` grün.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init` | update | README-Emit-Schritt + Stempelung |
| `cmd/ai-harness-init/readme_test.go` | neu | Existenz, Stempelung, gate-sichere Verweise |

## 4. Trigger

welle-02 in `done/` (der umgebaute Emit-Pfad steht) — damit startet welle-03. slice-005
ist deren **erster** Slice; [slice-024](../open/slice-024-voll-smoke.md) setzt auf ihm auf.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.
Schließt zusammen mit [slice-024](../open/slice-024-voll-smoke.md) die welle-03 und erreicht **M2**.

## 6. Risiken und offene Punkte

- Gate-Sicherheit der Vorwärts-Verweise ist der kritische Punkt: ein
  versehentlicher Link auf ein noch fehlendes Ziel bricht `docs-check`
  im frischen Repo (Anti-Ziel [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
