# ADR-0077: Neue wellenlose Slices werden bei der Slice-Closure einzeln archiviert — der Altbestand bleibt bei ADR-0041

**Status:** Proposed

**Datum:** 2026-10-02

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — Träger der Archivierung),
[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (**Accepted** — Altbestand;
Alternative D),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (wem die Anweisung gehört),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)

**Schärft:** `—` — Prozess-Entscheidung ohne Spec-Stratum.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

**Gemessen** — `ls docs/plan/planning/done/slice-*.md | wc -l` zählt die flachen Slice-Dateien;
`find docs/plan/planning -name '*.zip' | wc -l` → **0**: nichts ist archiviert, der wellenlose
Bestand wächst mit jeder Closure. Die Quelle (`.harness/baseline/v6.13.0/regelwerk/modul-06-roadmap.md`,
Tabelle *Träger im Repo ohne Wellen*) führt für *Zeitdokumente archivieren* die Slice-Closure,
*„Schlüssel ist der Slice: `done/slice-<Kennung>-archiv.zip`, **flach** neben dem Stub"*. Diese Tabelle
gilt nach ihrer Überschrift dem **Repo ohne Wellen**; dieses Repo und das emittierte Ziel fahren
Wellen, dort sammelt die Wellen-Closure die wellenlosen Slices ein (selbe Datei,
§Wellen-Closure-Prozedur, Schritt 4). Die Baseline **verlangt** den Einzel-Slice-Weg hier also
nicht — er ist eine Wahl dieses Repos, und diese ADR trifft sie.

**Warum ADR-0041 Alternative D verwarf, und was davon heute noch trägt.** Zwei Gründe: (a) die
Tabelle gelte dem Repo ohne Wellen — sie bleibt wahr, macht D aber zur **Wahl**, nicht zum
Fehler; (b) **57** Läufe mit je eigenem Verweis-Nachzug statt einem — das war ein Preis des
*Altbestands*. Für einen **neuen** Slice entfällt (b): ein Lauf je Closure, und eingehende
Verweise aus eingefrorenen Artefakten stehen nach §3.11 bei der Kennung, nicht beim Pfad. Der
Gegengrund, der bleibt: die offene Vorbedingung aus ADR-0041 Festlegung 4 (eingehende Verweise
auf Review-Reports) — sie trifft jeden Lauf, auch diesen, und braucht hier einen Rückfall
(Festlegung 1).

## Entscheidung

**Wir wählen Option C: neue wellenlose Slices werden bei der Slice-Closure einzeln archiviert,
Mitglieder einer Welle weiter mit der Welle, der Altbestand bleibt bei ADR-0041.** Vier
Festlegungen.

**1. Regel und Rückfall — in diesem Repo und im emittierten Ziel.** Ein Slice mit
`Welle: ohne Welle` wird nach Review, Verifikation, Paarungen und `git mv` nach `done/` — in dieser
Folge, im Planner-Kontext (`AGENTS.md` §3.10) — als `done/slice-<Kennung>-archiv.zip` neben einem
gekürzten Stub archiviert; Archiv, Stub und Verweis-Nachzug sind **ein** Commit (kein `git mv`
darin, §3.3 greift nicht). Sperrt die Verweis-Vorprüfung (`haenger`), **bleibt der Slice flach**,
die Closure-Notiz nennt die Sperre, und die nächste Wellen-Closure sammelt ihn wie bisher ein —
die Sperre blockiert die Closure nicht. Die Wellen-Closure sammelt Slices mit eigenem Archiv
**nicht** erneut ein; das schärft ADR-0041 Festlegung 5 für diese Teilmenge und gilt neben ihr.

**2. Der Altbestand bleibt bei ADR-0041, unverändert, nicht ausgeführt.** Seine Festlegungen
(Schlüssel `altbestand`, Grenze = Lauf, Vollzug an den Ausgang der Verweise gebunden) gelten
weiter; diese ADR öffnet den Vollzug nicht. Ob und wann er läuft, ist Auftraggeber-Entscheidung
(unten).

**3. Träger.** Ein **eigenes Unterkommando `archive-slice <kennung>`** des Produkt-Binärs, nicht
ein Schalter an `archive-welle`: dessen Argument ist eine Welle-Kennung, und sein Vertrag
(Welle-Plan, Ergebnisnotiz, `untergrenze`) trifft einen Einzel-Slice nicht. Gepackt, gestubt und
nachgezogen wird mit dem Code aus `internal/archive` (ADR-0033 Festlegung 1). Dieser ADR gehört
die Entscheidung über Name, Schlüssel und Rückfall; **Folge-Slices als Bedarf, nicht
geschnitten:** (i) das Unterkommando samt Test und Mutationsfall — und die Einsammel-Regel, die
einen Slice mit eigenem Archiv von der Welle-Closure und vom `altbestand`-Lauf ausnimmt;
(ii) die `make`-Ziele (Dogfood-`Makefile`, das emittierte Fragment `archivierung.mk`, Sensors-Zeile,
`harness/sensors/archive-welle.md`) und die Anweisung im emittierten Slice-Abschluss
(`implement-slice.md` §Closure — nicht `close-welle.md`, das die Wellen-Closure führt) samt
Stufe im `full-smoke`; (iii) die Planner-Anweisung dieses Repos, bei der ausführenden Rolle
(ADR-0028).

**4. Abweichung von der Baseline: ja, ein `MR`-Bedarf.** Die Baseline weist dem Repo mit Wellen
das Einsammeln aller seither wellenlos Geschlossenen der Wellen-Closure zu; die Einzel-Archive
schränken diese Menge ein — nach [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) damit eine Adaption, kein bloßer Zusatz. Den Eintrag
schreibt der Architect nach `Accepted`, in eigenem Commit. Er entfällt, wenn der Auftraggeber
Festlegung 1 verwirft oder dieses Repo keine Wellen mehr fährt (dann gilt die Baseline-Form
unmittelbar).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Nichts tun: die Wellen-Closure sammelt weiter ein | Baseline-konform ohne `MR`; kein Werkzeug-Aufwand | Der flache Bestand wächst bis zur nächsten Welle-Closure weiter; `welle-09` ruht — der Zeitpunkt ist nicht beobachtbar |
| B — Nur den Altbestand ausführen | Räumt den Bestand, ein Lauf | Neue Slices fielen sofort wieder flach an; die Wiederholung bleibt |
| **C — Einzel-Archiv bei der Slice-Closure (gewählt)** | Schlüssel ist der Slice — keine Zuordnung, kein Urteil; Baseline-Form (`slice-<Kennung>-archiv.zip`); Rückfall auf den bestehenden Weg | Zweiter Weg neben der Welle-Closure → `MR`; die Einsammel-Regel muss Slices mit Archiv kennen |
| D — Schalter `archive-welle --slice` | Kein neuer Unterkommando-Name | Verwischt den Vertrag von `archive-welle` (Argument ist Welle-Kennung) |

## Konsequenzen

- Positiv: der wellenlose Bestand wächst nicht mehr; keine Altbestands-Entscheidung nötig, um
  anzufangen.
- Negativ: zwei Archiv-Wege; die Mischform ist abweichend und braucht `MR` und Einsammel-Regel.
- Folgepflicht: drei Folge-Slices (Festlegung 3), `MR` nach `Accepted`.

## Fitness Function (falls maschinell prüfbar)

Keine Zeile ist heute rot herstellbar — der Träger existiert nicht; §3.6 verlangt das Rot im
jeweiligen Folge-Slice.

| Festlegung | Rot, das der Folge-Slice herstellen muss | Wächter |
|---|---|---|
| 1 | `archive-slice` auf einen Slice mit `Welle:` ≠ `ohne Welle` oder auf einen Slice mit Hänger bricht ab, ohne zu schreiben; ein archivierter Slice wird von `archive-welle --vorschau` nicht erneut eingesammelt | Go-Test + Mutationsfall in `test/mutations/` |
| 3 | Name im Dispatch ≠ Name in `Makefile`/`archivierung.mk` | `test/unterkommando-kopplung.bats` (um den Namen erweitern) |
| 2, 4 | **Lücke:** ob der Altbestand ausgeführt ist und ob ein `MR` existiert, hält kein Sensor ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): benannt, nicht behauptet) | — |

## Offene Entscheidungen des Auftraggebers

1. **Festlegung 1 überhaupt?** Option C (Empfehlung) · A (Baseline-konform, kein `MR`).
2. **Altbestand:** (a) sofort ausführen · (b) nach dem ersten Einzel-Archiv-Lauf, der den
   Hänger-Ausgang an einem realen Fall misst (**Empfehlung** — neue Slices hängen nicht am
   Altbestand) · (c) liegen lassen (ADR-0041 Option C; die Wellen-Archivierung wäre dann wegen
   `untergrenze` dauerhaft gesperrt).
3. **Emittiertes Ziel:** gleiche Regel (Empfehlung, Festlegung 1 gilt für beide) · nur dieses Repo.

## Re-Evaluierungs-Trigger

- Ein Einzel-Archiv-Lauf endet an `haenger` und der Rückfall tritt ein zweites Mal ein
  (beobachtbar in Closure-Notizen): die Vorbedingung aus ADR-0041 Festlegung 4 trägt für neue
  Slices nicht.
- Die Baseline ändert die Tabelle *Träger im Repo ohne Wellen* oder Schritt 4 der
  Wellen-Closure (Freshness-Audit des nächsten Sprungs).
- Dieses Repo fährt keine Wellen mehr (keine flache `welle-*.md`, keine Zeile unter *Nächste
  Wellen*): die Baseline-Form gilt direkt, die Abweichung entfällt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-02 | Proposed | Architect-Lauf |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-NNNN` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
