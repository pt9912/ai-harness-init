# Slice slice-formel-skelett-nennt-die-fassungs-ausnahme: Das Formel-Skelett nennt die eine Fassungs-Ausnahme, statt breiter zu behaupten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Ein einzelner Doku-Satz; sein Closure-Trigger beobachtet
nichts, was die DoD darunter nicht ohnehin belegt.

**Bezug:** [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) (Festlegung 1 lässt
genau einen Wert ins Binary reisen — die Fassung), [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix),
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfugbar).

**Berührte Spec-Stellen:** — (Doku-Satz am Skelett).

**Verantwortlich:** —.

**Autor:** Planner. **Datum:** 2026-09-23.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice.

**Ziel:** Der Kopf-Kommentar des Formel-Skeletts
([`internal/emit/templates/homebrew-formula.rb.tmpl`](../../../../internal/emit/templates/homebrew-formula.rb.tmpl))
behauptet *„kein Wert reist im Binary"* — überbreit seit
[`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 1 (die Fassung reist
per `ldflags` in jedes Release-Binary). Der Satz trägt die Ausnahme: *kein Wert reist im Binary
außer der Fassung* — ein Satz, nicht eine zweite Quelle für die Festlegung (der Skelett-Satz
verweist auf [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md), er ordnet nicht neu).

**Ausdrücklich NICHT in diesem Slice:**

- **Kein weiteres Formel-Griff** — der Skelett-Satz bleibt bei der einen
  Ausnahme; jede weitere Aussage darüber wäre eine zweite Quelle. — **Schicht-Abgrenzung**.
- **Der Emissions-Griff bleibt der gleiche.** Das Skelett wird je Release
  befüllt; der Nachzug ändert die Form, nicht den Vorgang. — **Bestand
  bleibt bewusst stehen** mit demselben Grund.
- **Kein Re-Publish eines Releases.** Die Zusage lebt im Quell-Skelett; der
  nächste Schnitt trägt sie in das Asset. — **Es wäre ein anderer Vorgang**.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice.

- [ ] **(1) Der Skelett-Kommentar nennt die Ausnahme.** Der Satz lautet *„kein Wert reist im
      Binary außer der Fassung (die Injektion, [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
      Festlegung 1)"* — der Zeiger ersetzt die breite Aussage, er formuliert die Festlegung
      nicht um.
      **Rot:** `make gates` — `docs-check` hält die Referenz auf die ADR.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor — Rollenwechsel nach Schritt 8
      des Minimal Agent Workflow, kein Self-Review. **Bei einem Ein-Satz-Slice:** der Review
      kann als Stich-Befund im Closure-Commit berichtet werden, wenn der Diff ein Byte-Satz
      bleibt; sonst eigener Report.
- [ ] Closure-Notiz mit Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben — der Eintrag
      [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-zu-erwartenden-fundstellen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
      trägt den Ausgang dieses Vorkommens.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang.
- [ ] Die drei Paarungen — dieses Repo führt Wellen-Betrieb; der Träger ist die nächste
      Welle-Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/templates/homebrew-formula.rb.tmpl`](../../../../internal/emit/templates/homebrew-formula.rb.tmpl) | update | der Kopf-Kommentar nennt die eine Ausnahme statt der breiten Aussage |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`.

**Start** (`open` → `next`): WIP-Limit frei. **Rückführung:** entfällt — ein Satz, kein Gegenstand
für eine Zerlegung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`.

1. `make gates` ist grün.
2. Der Skelett-Satz nennt die Ausnahme und ihren Anker ([`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
   Festlegung 1), nicht die Festlegung selbst — gelesen vor dem Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

1. **Der Skelett-Satz wird an zwei Stellen gelesen** (Skeleton und emittierte Formel je Release).
   *Absehbar:* entfallen — der Satz ändert die Form, nicht den Vorgang; die Emissions-Prüfung
   hält den Skeleton-Bestand weiter.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`.

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang>
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — der Träger ist die nächste Welle-Closure.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `internal/emit/templates/` — in `*`. Die
berührte Sub-Area erfüllt das Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** Der Eintrag
[`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
trägt den Ausgang dieses Vorkommens; sein Zähler steht über der Schwelle, der Ausgang ist
zugewiesen — dieser Slice vollzieht die geplante Regel.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).