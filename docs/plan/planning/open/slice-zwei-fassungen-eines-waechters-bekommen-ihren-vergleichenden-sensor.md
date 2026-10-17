# Slice slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor: Zwei Fassungen eines Wächters bekommen ihren vergleichenden Sensor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt
nur durch `git mv` (Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** ohne Welle — reaktiv, ein Eintrag des Beobachtungs-Registers über der Schwelle; keine
Closure-Bedingung jenseits der DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** Jedes Paar aus Dogfood-Fassung und Vorlagen-Fassung (`history-range-guard`,
`stop-require-gates`, `record-gates`, `close-welle`) trägt einen Sensor in `make test`, der die
**benannte** Abweichungsmenge des Paares hält — eine nicht benannte Abweichung in einer Fassung wird
rot statt still grün.

Anlass: Punkt (c) von `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`, in dessen
Closure ausgeschnitten: der Rückführ-Trigger dort („braucht ein Paar mehr als eine benannte
Abweichung") ist eingetreten. Gemessen von Implementer, Reviewer und Verifier unabhängig per `diff`
über die Paare, Kommentarzeilen herausgenommen (`diff <(grep -vE '^[[:space:]]*#' <dogfood>)
<(grep -vE '^[[:space:]]*#' <vorlage>)`, Vorlagen unter `internal/emit/templates/enforce/`):

- `history-range-guard.sh`: zwei Abweichungen im Code — die Test-Einstiege `--decide`/`--decide-staged`
  mit anderem Usage-String und der Meldungstext `--decide-staged` gegen `--staged`; 14 Diff-Zeilen.
- `stop-require-gates.sh`: eine — der Pfad `harness/tools/working-tree-hash.sh` gegen
  `tools/harness/working-tree-hash.sh`.
- `record-gates.sh`: zwei — derselbe Pfad und „([`ADR-0083`](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 4)" in einer Meldung.
- `close-welle.md` (Vorlage unter `internal/emit/templates/commands/`): durchgehend, 224 bis 243
  Diff-Zeilen; die Vorlage trägt ANPASSEN-Platzhalter, ein kommentar-bereinigter Vergleich ist dort
  nicht definiert.

Der Pfad-Unterschied `harness/tools` gegen `tools/harness` zieht sich durch zwei Paare und ist der
gemeinsame Normalisierungs-Kandidat.

**Liefer-Punkte (drei):**

1. `history-range-guard`: Vergleich mit den zwei benannten Abweichungen (Test-Einstiege, Meldungstext).
2. `stop-require-gates` und `record-gates`: Vergleich mit der gemeinsamen Pfad-Normalisierung und,
   für `record-gates`, dem ADR-Verweis in der Meldung als benannter Abweichung.
3. `close-welle`: der Slice entscheidet, ob und was ein Vergleich dort hält; trägt keiner, steht die
   Lücke benannt am Paar.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein Vergleich über die vier Paare hinaus** — Bestand bleibt bis zum nächsten Register-Beleg
  stehen; die Menge wächst nicht ohne Befund.
- **Das Angleichen der Fassungen.** Der Sensor hält die benannte Abweichung, er hebt sie nicht auf;
  ob eine Abweichung die richtige Dauerform ist, ist Sache von `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus`
  (dort ist Abweichung zulässig, hier ist sie benannt).
- **Die digest-only Pins** (bats, shellcheck, actionlint im `Makefile`; curl-Digest in
  `harness/tools/tap-nachzug.sh`, `harness/tools/traeger-fetch.sh` und deren Vorlagen-Kopie) —
  anderer Gegenstand: ein Tag, gegen den ein Nacht-Lauf den Digest halten könnte, fehlt; die
  Vollständigkeit kuratierter Listen und die Gleichheit der curl-Kopien sind eine andere Kopplung
  (Roadmap, *Nächste Wellen*, Zeile *Vollständigkeits-Wächter für kuratierte Listen*).

## 2. Definition of Done

- [ ] **(1) `history-range-guard`:** ein Vergleich Dogfood gegen Vorlage läuft in `make test`; die
      Abweichungen nennt der Slice namentlich; eine nicht benannte ist rot gesehen.
- [ ] **(2) `stop-require-gates` und `record-gates`:** wie (1) je Paar, mit der Pfad-Normalisierung als
      einer benannten Abweichung; rot gesehen je Paar.
- [ ] **(3) `close-welle`:** die Entscheidung, ob und was ein Vergleich dort hält, ist getroffen und
      im Sensor oder als benannte Grenze am Paar sichtbar; ein Vergleich, falls gebaut, ist rot gesehen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/*.bats` (Datei benennt der Implementer) | neu | Vergleich je Paar mit benannter Abweichungsmenge (1, 2, 3) |
| `harness/README.md` §Werkzeuge | update, falls ein Ziel entsteht | neue Ziele mit Bindung |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Auftraggeber; kein fachlicher Vorgänger.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn `close-welle` einen eigenen Normalisierer braucht, der mehr
  als einen Liefer-Punkt trägt — dann ist (3) ein eigener Slice.
- `in-progress` → `open` (blockiert): wenn die benannte Abweichungsmenge eines Paares eine Entscheidung
  des Architect braucht, ob die Abweichung zulässig ist.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die benannten Abweichungen wachsen zu einer Ausnahmeliste, die den Vergleich aushöhlt — **Ausgang:**
  offen bis Closure.

## 7. Closure-Notiz

— bei Closure.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), Kürzel `ALL` — die einzige Sub-Area,
der das Register Beobachtungen zuordnet.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen.
[`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
(5 Belege, Stand `geplant` auf diesen Slice) — der Gegenstand; Nachbar
[`BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md)
(dort ist Abweichung zulässig, hier benannt); [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md)
(8 Belege) berührt diesen Slice nicht — sein Gegenstand ist die Pin-Kopplung, nicht die Fassung eines Wächters.

Alle berührten Sub-Areas GF.
