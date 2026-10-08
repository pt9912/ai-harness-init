# Architect-Verdikt zu M-1 — `reviews` als dritte ausbleibende Position im emittierten Doc-Gate

**Rolleninhaber:** Architect (ai-harness-init-Team, pt9912) · **Bezug:**
[`MR-054`](../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel),
[`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) ·
**Eingang:** Review `2026-10-08-emittierte-gate-vorlage-review.md`, Finding M-1.

**Verdikt 3 (Modul 8): die Position ist legitim, ihr Träger fehlte — nachgezogen als
[`MR-086`](../../harness/conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate),
mit Kopf-Marke an `MR-054` nach `MR-032`.**

- `reviews` scheitert an Kriterium 1 (der Dogfood fährt es nicht) und Kriterium 2 (Sonde B: ein
  frisches Ziel startet rot) aus `MR-054` Setzung 1. „Bleibt aus, als begründeter Kommentar-Block
  mit Trigger" ist damit die Anwendung von Setzung 3; gefehlt hat nur, dass deren Aufzählung die
  dritte Position nennt. Ein Folge-MR genügt; eine ADR wäre die falsche Ebene für eine Aufzählung
  in einem Konventions-Eintrag.
- **Für den Implementer: keine Änderung aus M-1.** Der Diff `d4850268` bleibt, wie er ist.
- **Akzeptiertes Negativ:** Der Test-Kommentar in `internal/emit/emit_test.go` verankert den Block
  an „MR-054 Setzung 3". Er bleibt stehen: die Kopf-Marke an `MR-054` führt in einem Schritt zu
  `MR-086`, und ein Nachzug brächte keine Zusage hinzu.
- Der Trigger im Kommentar-Block ist die Bedingung für den Adopter; der Auflösungs-Trigger von
  `MR-086` ist die Bedingung für das Werkzeug. Beide sind nicht gleich und müssen es nicht sein.
- L-1 und L-2 sind keine Architektur-Fragen; sie bleiben beim Implementer.
