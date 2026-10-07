# Verifikation — slice-full-smoke-erkennt-unveroeffentlichtes-artefakt

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-07 · **Gegenstand:** Commits `0a10b0f4`,
`0bd9ac93`, `2663b1e3` gegen Plan/DoD (Stand `in-progress/`), ADR-0058 Festlegung 2,
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
Review-Report `2026-10-07-404-review.md` las den Diff vollständig; 551/552 und 553 über
`make mutate` stammen von dort und sind nicht nachgefahren (Stichprobe statt Wiederholung).

## Verdikte je Liefer-Punkt

- **DoD 1 — Einordnung: bestätigt.** Muster (5) `curl: \(22\) The requested URL returned error: [0-9]+`,
  Herkunft (drei Jobs) am Muster, `KLASSE[4]` in der Beleg-Zeile, Grenze im Kopf
  (`git diff 0a10b0f4~1 2663b1e3 -- harness/tools/full-smoke-ausgang.sh`). bats-Fälle (L5, zitiert,
  Job `112925525011`) und (B3, `curl: (23)`, als Abwandlung gekennzeichnet) vorhanden. Gebunden-Meldung
  551/552 aus dem Review übernommen (`mutate: 2 ok, 0 Befund(e)`); die Zitat-Herkunft (Log-Zeilen
  664–681) ist nicht gegen `gh api` nachgeprüft (Netz-Lauf ausgelassen).
- **DoD 2 — Reale Quelle: bestätigt, Rot-Beleg selbst gefahren.** Mutation 553 per Skript auf
  `internal/emit/templates/enforce/traeger.mk` angewandt, `make full-smoke` → `EXIT 2` (24 s), gelesen:
  ```text
  curl: (22) The requested URL returned error: 404
  full-smoke: FEHLER — AUSGANG LEITUNG: make traeger-fetch im frischen Klon (golang). …
  full-smoke:   Beleg (Muster 5 von 5, Klasse: Release-Asset nicht abrufbar): curl: (22) The requested URL returned error: 404
  ```
  **Gegenprobe** (553 + 551, Muster weg) → `EXIT 2`, `AUSGANG BAUM: make traeger-fetch im frischen
  Klon (golang). Keine der 4 gefuehrten Formen … in den 2 gelesenen Zeilen` — das Rot trägt die
  behauptete Ursache. Beide Mutationen danach per `git checkout --` zurückgenommen, Baum sauber.
  Closure-Trigger 2 damit erfüllt.
- **DoD 3 — Doku: bestätigt.** `docs/user/releasing.md` Schritt 6 nennt `AUSGANG LEITUNG`, Stufe,
  Klasse und curl-Zeile — deckungsgleich mit der gelesenen Ausgabe oben; Doppelgänger-Liste (F1)
  nachgezogen. Kein Wächter (wie DoD selbst sagt).
- **`make full-smoke` unverändert:** `EXIT 0` (149 s), Stufe `TRAEGER-FETCH IM ZIEL` OK.
- **`make gates`:** nach dem Commit dieses Berichts, Ergebnis im Handback an den Planner.

## Plan-vs-Code

- Plan → Code: alle vier Zeilen aus §3 umgesetzt; drei Mutationsfälle wie geplant.
- Code → Plan: `harness/sensors/full-smoke.md` (F5-Nachlauf) und der Kommentar in
  `test/mutations/187` stehen nicht in §3 — reine Vertrags-/Kommentarprosa, Bedeutung stimmt mit dem
  Verhalten überein; ohne Befund. `553` setzt `=` statt `?=` — Abweichung vom Wortlaut „zieht den
  emittierten `TRAEGER_TAG`", in Fall-Kopf und Commit begründet (Dogfood-Export, F4).

## Offene Punkte für Planner/Architect

- **Risiko §6 Punkt 2** („Stufe liegt spät, fast voller Lauf"): gemessen nicht zutreffend — der Lauf
  bricht nach 24 s bei Zeile 343 von 347 bzw. 337 von 3605 (grün); Ausgang *entfallen* liegt nahe.
- **F4** (full-smoke misst den Dogfood-Pin statt des emittierten, Name ungewacht) bestätigt sich im
  Verhalten von 553 unter `?=`; Planner-Entscheidung, nicht dieses Slice.
- **F2** (Rückführungs-Trigger §4 durch die akzeptierte Grenze erfüllt) und **F3** (DNS/Timeout →
  BAUM) bleiben beim Planner.

## Negativbefunde

- Muster-Index/Klassen-Index: Beleg-Zeile nennt „Muster 5 von 5" mit Klasse, die übrigen Muster
  ohne Klasse — ohne Befund.
- ADR-0058 Festlegung 2: kein Ausweichen, beide Läufe bleiben rot — ohne Befund.
