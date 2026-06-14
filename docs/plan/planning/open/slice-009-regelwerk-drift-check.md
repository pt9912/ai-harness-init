# Slice slice-009: Regelwerk-Drift-Check

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-03-durchsetzung-und-emission (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor).

**Autor:** Demo. **Datum:** 2026-06-14.

---

## 1. Ziel

`make regelwerk-check` erkennt **Upstream-Drift** des Regelwerk-Cache
([`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)): es vergleicht einen beim Pinnen gespeicherten **Upstream-Hash**
mit dem aktuellen Upstream-Stand und meldet Abweichung für ein **manuelles**
Digest-Re-Review. Läuft **außerhalb** des per-Session-Hooks und **außerhalb**
von `gates` — der Hook bleibt offline/reproduzierbar, `make gates` netzfrei.

## 2. Definition of Done

- [ ] `make regelwerk-check` holt die Upstream-URL, bildet `sha256` und
      vergleicht mit dem beim Pinnen abgelegten Upstream-Hash; **kein** Drift →
      exit 0, Drift → nonzero + klare Meldung; Fetch-Fehler ≠ Drift (eigener
      Exit/Hinweis, nicht „verändert").
- [ ] Upstream-Pin-Hash beim Pinnen abgelegt (im Cache-Header oder als
      `harness/`-Sidecar) — reproduzierbar ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); der Cache bleibt ein
      Digest (kein Verbatim-Vergleich, daher **Upstream**-Hash, nicht
      Cache-Inhalt).
- [ ] **Nicht** in `gates` und **kein** Sensor-Promotion (Netz-Abhängigkeit
      bräche das offline-/out-of-the-box-grüne Gate-Prinzip, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) —
      als **Maintenance-Target** dokumentiert (manuell/CI/scheduled).
- [ ] Bei Drift ist die Aktion ein **manuelles** Digest-Re-Review (Mensch/Agent)
      + Pin-Hash-Aktualisierung; der Check aktualisiert **nichts** automatisch.
- [ ] `make gates` grün (neuer Target bricht nichts); Closure-Notiz mit
      Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | `regelwerk-check`-Target (Fetch + `sha256`-Vergleich), **nicht** in `gates` |
| `harness/` (Upstream-Pin-Hash) | neu | gespeicherter Upstream-`sha256` zum Pin-Zeitpunkt |
| `harness/conventions.md` ([`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)) | update | Drift-Check-Mechanik + Pin-Pflege ergänzen |
| ggf. CI-Workflow | neu | scheduled Drift-Check (Folge) |

## 4. Trigger

Sofort startbar (reine Harness-Mechanik, unabhängig vom Go-CLI); setzt den
Cache aus slice-007 voraus.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Netz-Abhängigkeit:** bewusst **nicht** in `gates` — sonst bräche `make gates`
  in offline/air-gapped-Umgebungen ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Anti-Ziel). Nur Maintenance/CI.
- **Fetch-Mechanik:** Host-`curl` (simpel) vs. gepinntes Minimal-Image
  (Docker-only-Familie, [`ADR-0003`](../../adr/0003-go-native-binaries.md)) — im Slice entscheiden und festhalten.
- **Pin-Pflege:** der Upstream-Hash muss beim Cache-Refresh **mitgepflegt**
  werden, sonst Dauer-Drift-Alarm; im Refresh-Schritt verankern.
- **Upstream-Verfügbarkeit/Rate-Limit** (`raw.githubusercontent.com`): Check
  tolerant — Fetch-Fehler klar von „Drift" trennen.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
`harness/` ist GF (Doc führt); die Mechanik teilt den Adaptions-Block
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks), [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor)).
