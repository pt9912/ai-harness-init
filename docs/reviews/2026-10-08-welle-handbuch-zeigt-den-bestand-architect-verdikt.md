# Welle-Closure welle-handbuch-zeigt-den-bestand — Architect-Verdikt (Schritte 2 ADR-Zweig und 3b)

- **Rolle:** Architect · **an:** Planner, Auftraggeber (eine Frage, unten) · **Eingang:**
  `2026-10-08-welle-handbuch-zeigt-den-bestand-audit-vorlage`, Abschnitte A und B · **Bezug:**
  [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
  [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), Baseline-Regelwerk `v6.17.0`,
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2 und 3
- **Gemessen auf:** `3bb51569`
- **Ergebnis:** keine Folge-ADR, kein Norm-Artefakt geändert, kein neuer Slice. Kein Ausgang wechselt.
  Ein neuer Beleg (Mutations-Anker). Eine Frage an den Auftraggeber.

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig

**Bestätigt, wie die Vorlage es misst:** keine ADR, kein `MR`, kein Pin-, Baseline- oder Release-Sprung im
Fenster. Damit feuert kein Re-Evaluierungs-Trigger. Einziger Auflösungs-Trigger in
[`AGENTS.md`](../../AGENTS.md) lautet *permanent*, also ist keine Zeile zu entfernen. V-1 (Modus 0600 gegen
`LH-FA-14`/ADR-0022) bleibt beim Auftraggeber. Für das Audit ist dazu kein Verdikt nötig.

## B — 3b je Eintrag

| Eintrag | Verdikt | Grund |
|---|---|---|
| `abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt` | kein Sensor möglich | wie im Verdikt zu `welle-adopter-weg-im-ziel`: ob ein Vorgang die Annahme eines Kriteriums widerlegt, ist ein Urteil über Bedeutung. Träger bleibt die Übergabe nach §3.10. |
| `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` | kein Sensor möglich (diese Unterklasse) | Der Beleg aus slice-195 betrifft den **Geltungsumfang**, den die Nutzerdoku einer emittierten Datei zuschreibt. Er fällt weder in die Adress- noch in die Bedingungs-Hälfte, die das Vorgänger-Verdikt benennt. Ob ein Doku-Satz zum Inhalt einer Datei passt, ist ein Vergleich von Aussagen. Das Review hat ihn gefangen (LOW-1, im Slice behoben). **Akzeptiertes Negativ.** |
| `plan-abweichung-landet-im-commit-bericht-statt-im-plan` | kein Sensor möglich | Grenze aus `state.md`: ein Commit trägt keine Slice-Kennung. Träger ist der Plan-vs-Code-Diff des Verifiers, und der hat V-1 gefunden. |
| `regel-rand-ohne-benannte-luecke` | geplanter Träger fängt es | `slice-181` verlangt eine vollständige Grenzen-Liste oder Fail-closed. Genau das fehlte bei 3 von 5 Formfehlern in `handbuch-baum.sh`. |
| `zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel` | geplanter Träger fängt es | `slice-069` bindet je Zusicherungs-Hälfte einen Fall. Beide Belege (`TestModeIsOwnerOnly` ohne Fall, Richtung *angelegt, nicht genannt*) sind solche Hälften. |
| `zusage-neben-geaenderter-ableitung-bleibt-stehen` | kein Sensor möglich (diese Unterklasse) | Alle drei neuen Belege sind Nicht-Anker-Unterklassen: Handbuch-Prosa und ein Testkopf. `state.md` nennt sie schon als *„Regel ohne Sensor"*, `slice-153` trägt nur die Anker-Hälfte. Wo ein Fall billig war, hat der Slice ihn an einen Sensor gehängt (`handbuch-baum.sh`, Fälle 612/613). Ausgang unverändert; die Gruppierung ist Sache des Auftraggebers (C). |
| `zusage-nennt-sensor-der-form-nicht-sieht` | geplanter Träger fängt es | `slice-181`: *„zerlegt die Form, oder urteilt nicht"*. Das ist der Fall `-X`-Operand; im Slice ist er schon fail-closed geschlossen. |

### `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` (verkörpert in MR-071)

**(1) Zählung: ja, 7. Beleg.** Der Review-Report ist ein abgeschlossener Vorgang (`modul-06` §Das
Beobachtungs-Register), und datierte Report-Kennungen als Evidence-Dateiname sind im Register üblich
(`ls docs/plan/planning/observations/BEO-ALL/*/evidence/ | grep -E '^20[0-9]{2}-'`). Der Planner legt
`evidence/2026-10-08-mutations-anker-29-247-review.md` an. Ein Vorgang, ein Beleg: der Fix-Commit
`98bfab0b` zählt nicht zusätzlich. Bei MR-071, Auflösungs-Trigger 3 (*drei weitere Vorgänge*), sind damit
**2 von 3** erreicht (vorher `slice-fall-406-trifft-die-umgebaute-zerlegung`).

**(2) Die Prosa erreicht diese Form nicht, ein Sensor ist baubar.** Der Geltungsbereich von MR-071 ist die
**Anlage**. Beide Fälle hatten bei der Anlage gültige Anker. Gebrochen sind sie an späteren, berechtigten
Änderungen (`f9fa9e13`, `087f990d`), und deren Autor kennt den Fall nicht. Der Planner liest das richtig:
mehr Prosa trägt hier nichts. Heutiger Sensor ist `make mutate`, nur nachts. Dadurch kommt der Befund einen
Tag später und ist einen Implementer- und einen Review-Lauf wert.

**Benannter Sensor:** Bedingung 2 des Treibers (*„Mutation hat nicht gegriffen … Patch veraltet?"*,
`grep -n 'nicht gegriffen' harness/tools/mutate.sh`) läuft für jeden Fall **ohne Grün-Vorlauf und ohne
Testlauf** in `make gates`. Dabei wendet der Lauf den Fall auf eine Kopie seiner `# files:` an und
verlangt, dass jede davon sich ändert.
- **Form:** ein Modus des bestehenden Treibers, kein zweites Skript. Zwei Fassungen derselben
  Greift-Prüfung würden auseinanderlaufen.
- **Schwelle:** die des Treibers, *jede Zieldatei ändert sich*. **Nicht** *„genau eine Zeile"*: MR-071
  setzt diese Schwelle nicht, und ein Gate, das schärfer ist als die Entscheidung, prüft etwas, das niemand
  entschieden hat (`modul-11` §Fitness Function ohne Standard-Tool).
- **Rot an der realen Quelle:** `git show 98bfab0b^:test/mutations/<29|247>-…` gegen den heutigen
  Quellbestand muss rot werden; HEAD muss grün sein.
- **Grenze:** fängt nicht `mutations-fall-an-zeilennummer-verankert`. Ein Zeilennummern-Anker ändert immer
  irgendetwas.
- **Folge für die Norm:** der Satz *„Kein Sensor hält die Anlage"* in MR-071 §Grenze wird damit falsch.
  Der liefernde Slice bekommt einen Nachfolge-`MR` mit Kopf-Marke (MR-032). Den schreibt der Architect. Da
  der Sensor das Gate schärft, ist keine ADR nötig (`AGENTS.md` §3.5).

**Kein bestehender Slice trägt diesen Sensor.** `slice-119` zählt Wächter ohne Fall, also eine andere
Menge. `slice-der-mutations-lauf-ist-begrenzbar` filtert Fälle für einen Lauf und prüft nicht, ob sie
greifen. Die Suche nach `nicht gegriffen|Patch veraltet|sed-Anker` in `open/`, `next/` und `in-progress/`
trifft nur `slice-075`, und der handelt von etwas anderem. Ein Slice wäre also nötig.

## Frage an den Auftraggeber

**Wird der Anker-Sensor jetzt als Slice geschnitten, oder erst wenn MR-071 auslöst (3 von 3)?**

- **Option A, jetzt schneiden (Empfehlung).** Das Warten kostet, was der Sensor einspart: einen
  weiteren roten Nachtlauf und einen Reparatur-Lauf mit Review. Die Prosa kann den dritten Fall nicht
  verhindern.
- **Option B, auf den Trigger warten.** Ausgang bleibt *verkörpert*, `make mutate` bleibt der Sensor. Beim
  dritten weiteren Vorgang wird geschnitten, wie MR-071 es vorsieht.

Bis zur Entscheidung ändert sich nichts am Ausgang (*verkörpert*, MR-071). Bei A trägt der neue Slice den
Ausgang *geplant*. Den Slice legt der Planner an.

**Für den Planner:** neue Evidence-Datei wie oben. In `state.md` den Zähler 7 und *„2 von 3 seit der
Verkörperung"* fortschreiben. Die übrigen sechs Ausgänge bleiben unverändert.
