# Slice slice-gate-ausgang-schreibt-die-adresse-aus: Der Gate-Ausgang schreibt die Adresse aus

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. (1) Bündel? Nein. (2) Gemeinsames Closure-Kriterium? Nein.
(3) **Reaktiv:** eine Register-Beobachtung über der Schwelle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird).

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.2 (eine Suppression braucht einen begründeten,
zentralen Eintrag), [`AGENTS.md`](../../../../AGENTS.md) §3.1 (ein Gate darf nicht mehr behaupten,
als es misst), [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(die Link-Pflicht, die die drei Ausgänge erzeugt).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

**Ziel:** Eine Fundstelle, die ein Doku-Gate rot färbt, hat drei Ausgänge — die Adresse ausschreiben,
die Zeile mit einem Marker stumm schalten, die Nennung umformulieren. Wann die Auskunft schwerer
wiegt als der kürzere Weg, steht an einem Norm-Artefakt.

Die Klasse hat keinen Zielort: Ein Wächter wäre in dieser Richtung keiner — ein Gate misst, ob eine
genannte Adresse auflöst, nicht ob eine fehlt; die umformulierte Zeile ist grün, gerade weil sie
keine Adresse mehr trägt. Beleg:
[`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
(3 Belege).

**Ausdrücklich NICHT in diesem Slice:**

- **Die Marker-Mechanik.** Der Zeilen-Marker und `scan.ignore` bleiben, wie sie sind; dieser Slice
  regelt ihre **Wahl**, nicht ihr Verhalten.
- **Eine Räumung bestehender Marker.** Gebunden ist der Ausgang, der gewählt wird.
- **Ein Sensor über die Auskunfts-Dichte.** Sie ist ein Urteil und kein Muster.

## 2. Definition of Done

- [ ] Das Kriterium steht an einem Norm-Artefakt: wann eine gerötete Fundstelle ihre Adresse
      ausschreibt, statt sie stumm zu schalten oder umzuformulieren.
- [ ] Der Zielort nennt die Asymmetrie: der ausschreibende Ausgang kostet eine Signatur- oder
      Aufruf-Änderung, die zwei anderen kosten eine Zeile.
- [ ] Rot gesehen: eine Fundstelle, die über den Marker-Ausgang grün wird, wird nach dem Kriterium
      behandelt **oder** die Zusage ist auf das eingeschränkt, was der Lauf hält.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`AGENTS.md`](../../../../AGENTS.md) §3 | update | Träger des Kriteriums |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | die drei Ausgänge und ihre Kosten |
| [`test/`](../../../../test) | neu | Rot-Beleg über einer über den Marker grün gewordenen Fundstelle |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn das Kriterium für mehrere Gate-Module zugleich gefasst wird.
- `in-progress` → `open` (blockiert): wenn der Träger eine Gate-Senkung verlangt.

## 5. Closure-Trigger

DoD vollständig, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Das Kriterium bleibt ein Urteil und wirkt nur über den Schreibenden — **Ausgang:** weiter offen →
  `BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`.
- Es greift nur für die drei bekannten Ausgänge, ein vierter bleibt unbeschrieben — **Ausgang:**
  weiter offen → `BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*`; Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
[`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
über der Schwelle.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
