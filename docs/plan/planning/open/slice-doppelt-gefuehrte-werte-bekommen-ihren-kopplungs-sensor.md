# Slice slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor: Doppelt geführte Werte bekommen ihren Kopplungs-Sensor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt
nur durch `git mv` (Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** ohne Welle — reaktiv, ein Eintrag des Beobachtungs-Registers über der Schwelle; keine
Closure-Bedingung jenseits der DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md), [`ADR-0085`](../../adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-10-08.

---

## 1. Ziel und Abgrenzung

**Ziel:** Jeder Wert, den das Repo an zwei Stellen führt, ist an einen Sensor gekoppelt, der die
zweite Stelle gegen die erste hält — ein Pin-Zug oder eine Fassungs-Änderung, die eine Stelle
vergisst, wird rot statt still grün.

**Ausdrücklich NICHT in diesem Slice:**

- Der Mutations-Fall für die vorhandene Pin-Kopplung — `slice-pin-kopplung-bekommt-ihren-mutations-fall`
  trägt ihn; dort ist der Wächter vorhanden, hier fehlt er.
- Ein Pin-Zug selbst — anderer Vorgang; der Sensor misst die Kopplung, er bewegt keinen Wert.
- Paare über die drei unten genannten hinaus — Bestand bleibt bis zum nächsten Register-Beleg
  stehen; die Menge wächst nicht ohne Befund.

**Register-Ausgang, den dieser Slice zusätzlich trägt:**
[`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/state.md)
steht *geplant* auf diesem Slice. Eine Fixture, die einen realen Wert nachbaut, ist ein doppelt
geführter Wert; DoD (a) bricht dafür den **realen** Pin-Wert. Die Abgrenzung oben gilt weiter: neue
Paare kommen mit dem nächsten Register-Beleg, nicht mit diesem Ausgang.

## 2. Definition of Done

- [ ] **(a) Fallbacks:** die wert-hardcodenden Fallbacks in `harness/tools/smoke.sh` und
      `harness/tools/full-smoke.sh` sind netzlos in `make gates` an den Pin gekoppelt; ein
      verfälschter **realer** Pin-Wert ist rot gesehen.
- [ ] **(b) Digest:** der `@sha256`-Digest jedes Image-Pins wird nächtlich mit Netz gegen seinen Tag
      gehalten (wie `regelwerk-check`, nicht in `make gates`); ein verfälschter Digest ist rot gesehen.
- [ ] **(c) Zwei Fassungen:** ein kommentar-bereinigter Vergleich je Paar aus Dogfood und Vorlage
      (`history-range-guard`, `stop-require-gates`/`record-gates`, `close-welle`) läuft in
      `make test`; die erlaubten Abweichungen nennt der Slice, eine nicht erlaubte ist rot gesehen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder in §7 notiert, dass keine Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/smoke.sh`, `harness/tools/full-smoke.sh` | update | Fallback liest den Pin oder wird gegen ihn geprüft (a) |
| `.github/workflows/upstream-drift.yml` + `make`-Ziel | update / neu | nächtliche Digest-Prüfung (b) |
| `test/*.bats` | neu | Fassungs-Vergleich der drei Paare (c), Pin-Kopplung (a) |
| `harness/README.md` §Sensors/§Werkzeuge | update | neue Ziele mit Bindung |

## 4. Trigger

**Start** (`next` → `in-progress`): priorisiert, `Verantwortlich:` gesetzt.

- `in-progress` → `next`: eines der drei Paare braucht mehr als eine benannte Abweichung — dann ist
  (c) ein eigener Slice.
- `in-progress` → `open`: (b) verlangt eine Workflow-Änderung, die eine Entscheidung des Architect
  zum CI-Regime braucht.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die erlaubten Abweichungen in (c) wachsen zu einer Ausnahmeliste, die den Vergleich aushöhlt —
  **Ausgang:** offen bis Closure.
- (b) hängt am Netz und an der Registry; ein Ausfall darf keinen Push blockieren — **Ausgang:** offen
  bis Closure.

## 7. Closure-Notiz

— bei Closure.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), Kürzel `ALL` — die einzige Sub-Area,
der das Register Beobachtungen zuordnet.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/pin-digest-ohne-waechter` und
`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` über der Schwelle, Stand
`geplant` auf diesen Slice; Nachbar `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus` (dort ist
Abweichung zulässig, hier nicht).

Alle berührten Sub-Areas GF.

